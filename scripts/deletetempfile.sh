#!/bin/bash
## This should be run alot, to make sure the temp file doesn't get screwed up

## Variables
source /etc/piholeparser/scriptvars/staticvariables.var

WHATITIS="Temporary File"
CHECKME=$TEMPFILE
timestamp=$(echo `date`)
if
ls $CHECKME &> /dev/null;
then
sudo rm $CHECKME
sudo echo "* $WHATITIS Removed. $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
else
sudo echo "* $WHATITIS Not Removed. $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
fi