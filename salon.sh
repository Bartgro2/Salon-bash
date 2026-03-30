#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Display services first
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
echo "Here are the services we offer:"
echo "$SERVICES" | while read ID NAME; do
  NAME=$(echo $NAME | xargs)
  echo "$ID) $NAME"
done

# Prompt for valid service selection
SERVICE_ID_SELECTED=""
while [[ -z $SERVICE_ID_SELECTED ]]; do
  read -p "Please select a service by number: " INPUT
  INPUT=$(echo $INPUT | xargs)

  case $INPUT in
    1) SERVICE_ID_SELECTED=1; SERVICE_NAME="cut" ;;
    2) SERVICE_ID_SELECTED=2; SERVICE_NAME="color" ;;
    3) SERVICE_ID_SELECTED=3; SERVICE_NAME="perm" ;;
    4) SERVICE_ID_SELECTED=4; SERVICE_NAME="style" ;;
    5) SERVICE_ID_SELECTED=5; SERVICE_NAME="trim" ;;
    *)
      echo -e "\nI could not find that service. Please choose again:"
      # Re-display the services
      echo "$SERVICES" | while read ID NAME; do
        NAME=$(echo $NAME | xargs)
        echo "$ID) $NAME"
      done
      ;;
  esac
done

# Customer info
read -p "What's your phone number? " CUSTOMER_PHONE
CUSTOMER_PHONE=$(echo $CUSTOMER_PHONE | xargs)

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
CUSTOMER_ID=$(echo $CUSTOMER_ID | xargs)

if [[ -z $CUSTOMER_ID ]]; then
  read -p "I don't have a record for that phone number. What's your name? " CUSTOMER_NAME
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs)
  $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
  CUSTOMER_ID=$(echo $CUSTOMER_ID | xargs)
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;" | xargs)
fi

# Service time
read -p "What time would you like your $SERVICE_NAME appointment? " SERVICE_TIME
SERVICE_TIME=$(echo $SERVICE_TIME | xargs)

# Insert appointment
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Confirmation
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."