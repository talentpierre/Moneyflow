#!/bin/bash

read -p "Address: " var_adress
read -p "Amount: " var_amount

i=0

while true
do
i=$((i+1))
echo "Pay for ride, count: $i"
time lncli sendpayment --dest=$var_adress --amt=$var_amount --keysend
echo ""
echo ""
sleep 4
done
