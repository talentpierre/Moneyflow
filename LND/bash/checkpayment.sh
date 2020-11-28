#!/bin/bash

func_setInvoiceVariable () {
	tempvar=$(jq -r ".invoices[0].$2" lastinvoice.txt)
	printf -v $1 "$tempvar"
	unset tempvar
}

var_macaroonpath="/home/pi/.lnd/readonly.macaroon"
var_tlscertpath="/home/pi/.lnd/tls.cert"
var_rpcserver="192.168.192.10"
var_satoshi=10
var_seconds=5
lncli --network=testnet listinvoices --max_invoices 1 > /home/admin/Moneyflow/LND/bash/lastinvoice.txt
#lncli --network=testnet --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices --max_invoices 1 > /home/pi/Moneyflow/LND/bash/lastinvoice.txt
func_setInvoiceVariable rhash r_hash
func_setInvoiceVariable settledate settle_date
account=0
checktime=$(date '+%s')

while true
do
oldrhash=$rhash
oldsettledate=$settledate

lncli --network=testnet listinvoices --max_invoices 1 > /home/admin/Moneyflow/LND/bash/lastinvoice.txt && sleep 1
#lncli --network=testnet --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices --max_invoices 1 > /home/pi/Moneyflow/LND/bash/lastinvoice.txt

openstate='OPEN'
func_setInvoiceVariable state state
if [ "$state" != "$openstate" ]
then
    echo "######STATE-BEDINGUNG#######"
    func_setInvoiceVariable sat amt_paid_sat
    func_setInvoiceVariable rhash r_hash
    func_setInvoiceVariable settledate settle_date
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
   account=$((account+1))
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
#   python3 relay-on.py &
else
   echo Stop!
#   python3 relay-off.py &
fi
echo ""

#sleep 1

done
