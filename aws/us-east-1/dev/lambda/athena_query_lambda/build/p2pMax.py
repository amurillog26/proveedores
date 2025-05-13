# This lambda will support requests from an aws bedrock agent
# Creation date February 2025

import os
import json
import boto3
import time
import pandas as pd
from datetime import datetime
import logging

# Configure the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables for Athena configuration
ATHENA_DATABASE = os.environ["ATHENA_DATABASE"]
S3_OUTPUT = os.environ["S3_OUTPUT"]
REGION = os.environ["REGION"]

# Initialize the Athena client
athena_client = boto3.client("athena", region_name=REGION)


def execute_query(query, database=ATHENA_DATABASE, s3_output=S3_OUTPUT, max_wait=30):
    """
    Executes a query in Amazon Athena and retrieves the results.

    Args:
        query (str): The SQL query to execute
        database (str): The Athena database name
        s3_output (str): S3 location where query results will be stored
        max_wait (int): Maximum waiting time in seconds before timeout

    Returns:
        dict: Query results from Athena

    Raises:
        Exception: If query fails or times out
    """
    try:
        # Start the query execution
        response = athena_client.start_query_execution(
            QueryString=query,
            QueryExecutionContext={"Database": database},
            ResultConfiguration={"OutputLocation": s3_output},
        )
        query_execution_id = response["QueryExecutionId"]
        logger.info(f"Query started: {query_execution_id}")

        start_time = time.time()

        # Poll for query completion
        while True:
            response = athena_client.get_query_execution(QueryExecutionId=query_execution_id)
            status = response["QueryExecution"]["Status"]["State"]
            if status in ["SUCCEEDED", "FAILED", "CANCELLED"]:
                break
            if time.time() - start_time > max_wait:
                raise Exception("Query timeout exceeded")
            time.sleep(2)

        # Check if query succeeded
        if status != "SUCCEEDED":
            raise Exception(f"Query failed with status: {status}")

        # Get the query results
        results = athena_client.get_query_results(QueryExecutionId=query_execution_id)
        return results
    except Exception as e:
        logger.error("Error: %s", str(e))
        raise

def process_results_to_df(results):
    """
    Converts Athena query results into a pandas DataFrame.

    Args:
        results (dict): Athena query results

    Returns:
        pandas.DataFrame: DataFrame containing the query results
    """
    rows = results["ResultSet"]["Rows"]
    if not rows or len(rows) < 1:
        return pd.DataFrame()

    # Extract column headers from the first row
    headers = [col.get("VarCharValue", "") for col in rows[0]["Data"]]

    # Extract data from remaining rows
    data = [
        [col.get("VarCharValue", None) for col in row["Data"]]
        for row in rows[1:]
    ]
    return pd.DataFrame(data, columns=headers)

# Business Logic Functions

#1
def account_statement(provider_code):
    """
    Retrieves account statement information for a specific provider.

    Args:
        provider_code (str): The provider's account code

    Returns:
        str: JSON string containing account statement data or error message
    """
    query_account_statement = f"""
    SELECT cuenta,
    nombre_1 AS nombre,
    referencia,
    importe_en_moneda_doc,
    moneda_del_documento,
    fecha_de_pago
    FROM p2pholcim.df126_questions
    WHERE cuenta = {provider_code}
    """
    results = execute_query(query_account_statement)
    df = process_results_to_df(results)

    # Check if results were found
    if df.empty:
        return json.dumps({"message": "No documents found for this provider."})

    # Calculate total amount
    total_importe = df["importe_en_moneda_doc"].astype(float).sum()

    message = "Below we are sending you your account status as of today, containing documents due or overdue."

    return json.dumps({
        "message": message,
        "total_importe": total_importe,
        "data": json.loads(df.to_json(orient="records"))
    })


#2
def invoice_statement(provider_code, invoice_number, country='Mexico'):
    """
    Checks the payment status of a specific invoice for a provider.

    Args:
        provider_code (str): The provider's account code
        invoice_number (str): The invoice reference number
        country (str): Provider's country, defaults to 'Mexico'

    Returns:
        str: JSON string containing invoice payment status information
    """
    # First check if invoice is already paid (in df46 table)
    query_df46 = f"""
    SELECT fecha_compensacion
    FROM p2pholcim.df46_questions
    WHERE cuenta = {provider_code} AND referencia = '{invoice_number}'
    """
    results_df46 = execute_query(query_df46)
    df46 = process_results_to_df(results_df46)

    if not df46.empty:
        fecha_compensacion = df46.iloc[0, 0]
        return json.dumps({"message": f"Your invoice was paid on {fecha_compensacion}"})

    # Check if invoice is pending payment (in df126 table)
    query_df126 = f"""
    SELECT fecha_de_pago
    FROM p2pholcim.df126_questions
    WHERE cuenta = {provider_code} AND referencia = '{invoice_number}'
    """
    results_df126 = execute_query(query_df126)
    df126 = process_results_to_df(results_df126)

    if not df126.empty:
        fecha_de_pago = df126.iloc[0, 0]

        # Payment schedule by country
        payment_schedule = {
            "Nicaragua": {"Proveedores Nacionales": "Viernes"},
            "Costa Rica": {"Proveedores Nacionales": "Días 1 y 15"},
            "El Salvador": {"Proveedores Nacionales": "Martes"},
            "México": {"Proveedores Nacionales": "Martes"},
            "Colombia": {"Proveedores Nacionales": "Jueves cada 15 días"},
            "ABS": {"Proveedores Nacionales": "Miércoles"},
            "Argentina": {"Proveedores Nacionales": "Miércoles"},
            "Ecuador": {"Proveedores Nacionales": "Días 1 y 15"},
            "Brasil": {"Proveedores Nacionales": "Días 15 y 30"}
        }

        cronograma = payment_schedule.get(country, {}).get("Proveedores Nacionales", "Unknown")
        return json.dumps({
            "message": f"Your invoice is pending payment, the payment date is {fecha_de_pago}. ",
            "schedule": f"Payment dates are {cronograma}. If the payment date falls on a holiday, your payment will be made on the next business day."
        }, ensure_ascii=False)

    # If not found in either table
    return json.dumps({"message": "The invoice has not yet been recorded in the system."})

# 3
def special_payment_status(request_number):
    """
    Checks the status of a special payment request.

    Args:
        request_number (str): The special payment request number

    Returns:
        str: JSON string containing the payment status
    """
    query_sp = f"""
    SELECT numero_de_solicitud, texto_del_estatus
    FROM p2pholcim.df3_questions
    WHERE numero_de_solicitud = {request_number}
    """
    results = execute_query(query_sp)
    df = process_results_to_df(results)

    if not df.empty:
        estado_pago = df.iloc[0, 1]
        return json.dumps({"message": f"We confirm that the status of the special payment is {estado_pago}"})

    return json.dumps({"message": "Your payment has not yet been entered into the system"})


# 4
def payment_details(provider_code, compensation_date):
    """
    Retrieves payment details for a specific provider on a given date.

    Args:
        provider_code (str): The provider's account code
        compensation_date (str): The payment date in dd/mm/yyyy format

    Returns:
        str: JSON string containing payment details
    """
    # Convert date from dd/mm/yyyy to yyyy-mm-dd format for Athena
    formatted_date = datetime.strptime(compensation_date, "%d/%m/%Y").strftime("%Y-%m-%d")

    query_pd = f"""
    SELECT cuenta, nombre_1,
    fecha_compensacion,
    importe_en_moneda_local,
    moneda_local
    FROM p2pholcim.df46_questions
    WHERE cuenta = {provider_code}
    AND fecha_compensacion = DATE '{formatted_date}'
    """
    results = execute_query(query_pd)
    df = process_results_to_df(results)

    if df.empty:
        return json.dumps({"message": "No payment details found for the provided date."})

    # Calculate total payment amount
    total_pago = df["importe_en_moneda_local"].astype(float).sum()
    message = "Below we are sending you the details of your payment."

    return json.dumps({
        "message": message,
        "total_pago": total_pago,
        "data": json.loads(df.to_json(orient="records"))
    })


# 5
def travel_expenditures(provider_code, invoice_number):
    """
    Checks the status of travel expense invoices.

    Args:
        provider_code (str): The provider's account code
        invoice_number (str): The invoice reference number

    Returns:
        str: JSON string containing travel expense status
    """
    query_te = f"""
    SELECT cuenta,
    nombre_1,
    fecha_compensacion,
    importe_en_moneda_doc,
    moneda_del_documento,
    referencia
    FROM p2pholcim.df126_questions
    WHERE cuenta = {provider_code} AND referencia = '{invoice_number}'
    """
    results = execute_query(query_te)
    df = process_results_to_df(results)

    if df.empty:
        return json.dumps({"message": "Invoice has not yet been recorded in the system."})

    fecha_compensacion = df.iloc[0]["fecha_compensacion"]

    if fecha_compensacion is None:
        return json.dumps({"message": "No compensation date available for this invoice."})

    # Convert compensation_date to datetime format and compare with today
    fecha_hoy = datetime.today().date()
    try:
        fecha_compensacion = datetime.strptime(fecha_compensacion, "%Y-%m-%d").date()
    except ValueError:
        return json.dumps({"message": "Error in the compensation date format retrieved from Athena."})

    if fecha_compensacion > fecha_hoy:
        return json.dumps({
            "message": f"The scheduled payment date is {fecha_compensacion}.",
            "note": "Note: Keep in mind the employee payment calendar. Advances are paid every Thursday and reimbursements and discounts are paid on the third Thursday of each month (everything is based on what is recorded by Wednesday at 2pm)."
        })
    else:
        return json.dumps({"message": f"The payment was made on {fecha_compensacion}."})


# 6
def purchase_delivery_date(purchase_order, purchase_position):
    """
    Retrieves delivery date information for a specific purchase order and position.

    Args:
        purchase_order (str): The purchase order number
        purchase_position (str): The position within the purchase order

    Returns:
        str: JSON string containing delivery date information
    """
    query_po = f"""
    SELECT
    opco,
    compania,
    nombre_planta,
    po,
    posicion,
    material,
    descripcion,
    cantidad_por_entregar,
    valor_item_po,
    proveedor,
    nombre_proveedor,
    fecha_entrega_actualizada_proveedor,
    fecha_de_entrega
    FROM p2pholcim.df7_questions
    WHERE po = {purchase_order} AND posicion = {purchase_position}
    """
    results = execute_query(query_po)
    df = process_results_to_df(results)

    if df.empty:
        return json.dumps({"message": "No information found for the indicated order and position."})

    # Get the updated and original delivery dates
    fecha_actualizada = df.iloc[0]["fecha_entrega_actualizada_proveedor"]
    fecha_entrega = df.iloc[0]["fecha_de_entrega"]

    if fecha_actualizada:
        return json.dumps({"message": f"The delivery date for your order is {fecha_actualizada}."})
    else:
        return json.dumps({
            "message": f"No updated delivery date was found. The estimated delivery date is {fecha_entrega}. Envie un correo solicitando este detalle", 
            "data": json.loads(df.to_json(orient="records"))
        })

# Mapping actions to their corresponding functions
ACTION_FUNCTIONS = {
    "account_statement": account_statement,
    "invoice_statement": invoice_statement,
    "special_payment_status": special_payment_status,
    "payment_details": payment_details,
    "travel_expenditures": travel_expenditures,
    "purchase_delivery_date": purchase_delivery_date
}

def lambda_handler(event, context):
    try:
        logger.info(f"Received event: {json.dumps(event)}")

        function_name = event.get("function")
        raw_parameters = event.get("parameters", [])
        action_group = event.get("actionGroup")
        message_version = event.get("messageVersion", "1.0")

        # Convert parameters to dict
        params = {param["name"]: param["value"] for param in raw_parameters}
        logger.info(f"Calling function: {function_name} with params: {params}")

        if function_name not in ACTION_FUNCTIONS:
            return {
                "messageVersion": message_version,
                "response": {
                    "actionGroup": action_group,
                    "function": function_name,
                    "functionResponse": {
                        "responseBody": {
                            "TEXT": {
                                "body": f"Function '{function_name}' not supported."
                            }
                        }
                    }
                }
            }

        # Call the function and parse result
        result_str = ACTION_FUNCTIONS[function_name](**params)
        result_dict = json.loads(result_str)

        # Convert dictionary into plain text response (or customize as needed)
        message = result_dict.get("message", "Here is your response.")
        body_text = message

        if "total_importe" in result_dict:
            body_text += f"\n\nTotal: {round(result_dict['total_importe'], 2)}"

        if "data" in result_dict:
            try:
                data_list = json.loads(result_dict["data"]) if isinstance(result_dict["data"], str) else result_dict["data"]
                for row in data_list:
                    row_str = ", ".join(f"{k}: {v}" for k, v in row.items())
                    body_text += f"\n- {row_str}"
            except Exception as e:
                logger.warning("Could not parse data list")

        return {
            "messageVersion": message_version,
            "response": {
                "actionGroup": action_group,
                "function": function_name,
                "functionResponse": {
                    "responseBody": {
                        "TEXT": {
                            "body": body_text
                        }
                    }
                }
            }
        }

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            "messageVersion": "1.0",
            "response": {
                "actionGroup": event.get("actionGroup", "unknown"),
                "function": event.get("function", "unknown"),
                "functionResponse": {
                    "responseBody": {
                        "TEXT": {
                            "body": f"Internal error occurred: {str(e)}"
                        }
                    }
                }
            }
        }
