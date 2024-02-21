#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~ MY SALON ~~~\n"
echo -e "Welcome to my Salon\n"

LIST_SERVICES () {
  if [[ $1 ]]
    then
      echo -e "\n$1\n"
  fi
  SERVICE_LIST=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo -e $SERVICE_LIST | sed -r 's/ \|/\)/g'
  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_SELECTED ]] 
   then
     LIST_SERVICES "I'm sorry, we can't find that service, try entering one from the list below"
   else
     CHECK_DETAILS "$SERVICE_ID_SELECTED"
  fi
}

CHECK_DETAILS () {
  echo -e "\nwhat is your phone number?\n"
  read CUSTOMER_PHONE
  #check for name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #if none then ask for name
  if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      INSERT_INTO_CUSTOMERS=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
 BOOK_APPOINTMENT $1 "$CUSTOMER_NAME" "$CUSTOMER_ID"
}

BOOK_APPOINTMENT () {
  echo -e "\nWhat time would you like to book,$2?"
  read SERVICE_TIME
  SERVICE=$(echo $($PSQL "SELECT name FROM services WHERE service_id='$1'") | sed -r 's/^  */ /' )
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($3,$1,'$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
    then
     echo -e "I have put you down for a $SERVICE at $SERVICE_TIME, $2."
  fi
}
LIST_SERVICES "how can I help you?"