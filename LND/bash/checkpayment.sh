#!/bin/bash

var_macaroonpath="/home/pi/.lnd/readonly.macaroon"
var_tlscertpath="/home/pi/.lnd/tls.cert"
var_rpcserver="192.168.192.10"
var_satoshi=10
#rhash=$(lncli --network=testnet --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices --max_invoices 1 | grep r_hash | cut -d '"' -f 4)
lncli --network=testnet --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices --max_invoices 1 > /home/pi/Moneyflow/LND/bash/lastinvoice.txt
rhash=$(cat lastinvoice.txt | grep r_hash | cut -d '"' -f 4)
settledate=$(cat lastinvoice.txt | grep settle_date | cut -d '"' -f 4)
account=0
checktime=$(date '+%s')

while true
do
oldrhash=$rhash
oldsettledate=$settledate

lncli --network=testnet --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices --max_invoices 1 > /home/pi/Moneyflow/LND/bash/lastinvoice.txt

openstate='OPEN'
state=$(cat lastinvoice.txt | grep state | cut -d '"' -f 4)
if [ "$state" != "$openstate" ]
then
    echo "######STATE-BEDINGUNG#######"
    sat=$(cat lastinvoice.txt | grep amt_paid_sat | cut -d '"' -f 4)
    rhash=$(cat lastinvoice.txt | grep r_hash | cut -d '"' -f 4)
    settledate=$(cat lastinvoice.txt | grep settle_date | cut -d '"' -f 4)
fi

settledelta=`expr $settledate - $oldsettledate`

echo "$(date)"
#echo "timestamp: $(date '+%s')"
echo "settledate: $settledate"
echo "settledelta: $settledelta"

if [ $rhash != $oldrhash ] && [ $sat -eq $var_satoshi ]
then
   if [ $settledelta -gt 60 ]
   then
      echo "!! settledelta -gt 60"
      account=$((account+1))
      checktime=$current
   fi
   account=$((account+5))
fi

current=$(date '+%s')
delta=`expr $current - $checktime`

echo "Delta is: $delta"
if [ $delta -ge $var_seconds ]
then
   [ $account -le 0 ] || account=$((account-1))
   checktime=$current
fi

echo "Account is: $account"
if [ "$account" -ge 1 ]
then
   echo Driving!
   python3 relay-on.py &
else
   echo Stop!
   python3 relay-off.py &
fi
echo ""

#sleep 1

done
