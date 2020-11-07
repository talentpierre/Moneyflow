#!/bin/bash

countdown() {
  secs=$1
  shift
  msg=$@
  while [ $secs -gt 0 ]
  do
    printf "\r\033[KWaiting %.d seconds $msg" $((secs--))
    sleep 1
  done
  echo
}

read -p "Address: " var_adress
read -p "Amount: " var_amount

i=0

while true
do
i=$((i+1))
echo "Pay for ride, count: $i"
vorher=$(date +%s)
#lncli --network=testnet sendpayment --dest=$var_adress --amt=$var_amount --data 80000=abc002 --keysend
bash pay.sh $var_adress $var_amount > /dev/null 2>&1 &
nachher=$(date +%s)
echo ""
echo ""
gebraucht=$(($nachher - $vorher))
echo "Gebraucht: $gebraucht"

secondsleft=$((5 - $gebraucht))
echo "secondsleft: $secondsleft"
countdown $secondsleft
#sleep $secondsleft
#sleep 2
#echo "Sleep $1 Sekunde(n)"

done
exit


vorher=$(date +%s)
sleep $1
nachher=$(date +%s)

gebraucht=$(($nachher - $vorher))
echo "Gebraucht: $gebraucht"

secondsleft=$((10 - $gebraucht))
echo "secondsleft: $secondsleft"

done
