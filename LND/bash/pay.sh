#!/bin/bash

lncli --network=testnet sendpayment --dest=$1 --amt=$2 --data 80000=abc002 --keysend
