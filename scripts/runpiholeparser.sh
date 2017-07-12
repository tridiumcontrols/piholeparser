#!/bin/bash
## This is the central script that ties the others together

## Variables
source /etc/piholeparser/scripts/scriptvars/staticvariables.var

## Start File Loop
## For .sh files In The mainscripts Directory
for f in $RUNSCRIPTSALL
do

# Dynamic Variables
source /etc/piholeparser/scripts/scriptvars/dynamicvariables.var

## Loop Variables
SCRIPTTEXT=""$BNAMEPRETTYSCRIPTTEXT"."
timestamp=$(echo `date`)

printf "$blue"    "$DIVIDERBAR"
echo ""
printf "$cyan"   "$SCRIPTTEXT $timestamp"

## Clear Temp Before
bash $DELETETEMPFILE

## Run Script
bash $f

## Clear Temp After
bash $DELETETEMPFILE

echo "" | sudo tee --append $RECENTRUN
printf "$magenta" "$DIVIDERBAR"
echo ""

## End Of Loop
done
