#!/bin/bash

var_macaroonpath="/home/pi/.lnd/data/chain/bitcoin/mainnet/readonly.macaroon"
var_tlscertpath="/home/pi/.lnd/tls.cert"
var_rpcserver=""
var_seconds=10
var_satoshi=10
rhash=$(lncli --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices | tail -n 52 | grep r_hash | cut -d '"' -f 4)
account=0
checktime=$(date '+%s')

while true
do
oldrhash=$rhash
sat=$(lncli --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices | tail -n 52 | grep amt_paid_sat | cut -d '"' -f 4)
rhash=$(lncli --macaroonpath $var_macaroonpath --tlscertpath $var_tlscertpath --rpcserver $var_rpcserver listinvoices | tail -n 52 | grep r_hash | cut -d '"' -f 4)

#echo $(date)
#echo "Delta ist: $delta"
#echo "Account ist: $account"
#echo "rhash ist: $rhash"
#echo "oldrhash ist: $oldrhash"
echo ""

if [ $rhash != $oldrhash ] && [ $sat -eq $var_satoshi ]
then
   account=$((account+1))
fi

current=$(date '+%s')
delta=`expr $current - $checktime`

echo "Delta is: $delta"
if [ $delta -ge 10 ]
then
   [ $account -le 0 ] || account=$((account-1))
   checktime=$current
fi

echo "Account is: $account"
if [ "$account" -ge 1 ]
then
   echo Driving!
else
   echo Stop!
fi
echo ""

#sleep 1

done
