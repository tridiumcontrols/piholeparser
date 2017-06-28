#!/bin/bash
## This should show what lines are not making it through gravity.sh

## Vars
source /etc/piholeparser/scripts/scriptvars/staticvariables.var
CURRENTUSER="$(whoami)"
GRAVITY=/etc/pihole/gravity.list
GRAVITYSH=/etc/.pihole/gravity.sh
#ANTIGRAV=/home/"$CURRENTUSER"/antigrav.list
ANTIGRAV=/home/pi/antigrav.list

## whiptail required
WHATITIS=whiptail
WHATPACKAGE=whiptail
if
which $WHATITIS >/dev/null;
then
:
else
printf "$yellow"  "Installing $WHATITIS"
apt-get install -y $WHATPACKAGE
fi

## Remove old antigrav
if
ls $ANTIGRAV &> /dev/null;
then
rm $ANTIGRAV
else
:
fi

## Update Gravity
# pihole -g
{ if
(whiptail --title "piholeparser" --yes-button "No" --no-button "Yes" --yesno "Do you want to run Gravity Now?" 10 80) 
then
echo "not running gravity"
else
bash $GRAVITYSH
fi }

## Trim IP from HOSTS format
HOSTIP=$(whiptail --inputbox "What IP Needs to be removed?" 10 80 "192.168.1.99" 3>&1 1>&2 2>&3)
sed "s/^$HOSTIP\s\+[ \t]*//" < $GRAVITY > $TEMPFILE

## WhatDiff
gawk 'NR==FNR{a[$0];next} !($0 in a)' $BIGAPLE $TEMPFILE > $ANTIGRAV
HOWMANYLINES=$(echo -e "`wc -l $ANTIGRAV | cut -d " " -f 1`")
printf "$yellow"  "Antigrav File contains $HOWMANYLINES Domains that are not used by gravity."
rm $TEMPFILE