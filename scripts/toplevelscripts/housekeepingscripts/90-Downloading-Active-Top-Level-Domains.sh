#!/bin/bash
## This Recreates The Valid TLD file

## Variables
script_dir=$(dirname $0)
SCRIPTVARSDIR="$script_dir"/../../scriptvars/
STATICVARS="$SCRIPTVARSDIR"staticvariables.var
if
[[ -f $STATICVARS ]]
then
source $STATICVARS
else
echo "Static Vars File Missing, Exiting."
exit
fi

CHECKME=$VALIDDOMAINTLD
if
ls $CHECKME &> /dev/null;
then
rm $CHECKME
fi

for f in $VALIDDOMAINTLDLINKS
do

for source in `cat $f`;
do

printf "$lightblue"    "$DIVIDERBARB"
echo ""

## Filenaming Vars
BASEFILENAME=$(echo `basename $f | cut -f 1 -d '.'`)
source $DYNOVARS

printf "$cyan"    "The Source In The File Is:"
printf "$yellow"    "$source"
echo ""

if
[[ $source != https* ]]
then
printf "$yellow"    "$BASEFILENAME List Does NOT Use https."
fi

printf "$cyan"    "Pinging $BASEFILENAME To Check Host Availability."

## Check to see if source's host is online
if
[[ -n $UPCHECK ]]
then
SOURCEIPFETCH=`ping -c 1 $UPCHECK | gawk -F'[()]' '/PING/{print $2}'`
SOURCEIP=`echo $SOURCEIPFETCH`
elif
[[ -z $UPCHECK ]]
then
printf "$red"    "$BASEFILENAME Host Unavailable."
fi
if
[[ -n $SOURCEIP ]]
then
printf "$green"    "Ping Test Was A Success!"
elif
[[ -z $SOURCEIP ]]
then
printf "$red"    "Ping Test Failed."
fi
echo ""

## Check if file is modified since last download
if 
[[ -f $CURRENTTLDLIST ]]
then
remote_file="$source"
local_file="$CURRENTTLDLIST"
modified=$(curl --silent --head $remote_file | awk -F: '/^Last-Modified/ { print $2 }')
remote_ctime=$(date --date="$modified" +%s)
local_ctimea=$(stat -c %z "$local_file")
local_ctime=$(date --date="$local_ctimea" +%s)
DIDWECHECKONLINEFILE=true
fi
if
[[ -n $DIDWECHECKONLINEFILE && $local_ctime -lt $remote_ctime ]]
then
printf "$yellow"    "File Has Changed Online."
rm $CURRENTTLDLIST
elif
[[ -n $DIDWECHECKONLINEFILE && $local_ctime -gt $remote_ctime ]]
then
MAYBESKIPDL=true
printf "$green"    "File Not Updated Online. No Need To Process."
fi

CHECKME=$VALIDDOMAINTLD
if
ls $CHECKME &> /dev/null;
then
rm $CHECKME
fi

timestamp=$(echo `date`)
if
[[ -z $MAYBESKIPDL && -n $SOURCEIP ]]
then
printf "$cyan"    "Fetching List From $UPCHECK Located At The IP address Of "$SOURCEIP"."
curl -s -H "$agent" -L $source >> $CURRENTTLDLIST
HOWMANYTLD=$(echo -e "`wc -l $CURRENTTLDLIST | cut -d " " -f 1`")
echo "$HOWMANYTLD Valid TLD's in $BASEFILENAME"
fi
touch $CURRENTTLDLIST
cat $CURRENTTLDLIST >> $VALIDDOMAINTLD
done

unset CURRENTTLDLIST
unset MAYBESKIPDL

echo ""
printf "$orange" "$DIVIDERBARB"
echo ""

done

printf "$lightblue"    "$DIVIDERBARB"
echo ""

CHECKME=$TLDCOMPARED
if
ls $CHECKME &> /dev/null;
then
rm $CHECKME
fi

## Cleanup File
printf "$cyan"    "Formatting And Removing Duplicatates From TLD List."
mv $VALIDDOMAINTLD $BTEMPFILE
cat $BTEMPFILE | sed '/[/]/d; /\#\+/d; s/\s\+$//; /^$/d; /[[:blank:]]/d; /[.]/d; s/\([A-Z]\)/\L\1/g' > $BFILETEMP
rm $BTEMPFILE
cat -s $BFILETEMP | sort -u | gawk '{if (++dup[$0] == 1) print $0;}' > $VALIDDOMAINTLD
rm $BFILETEMP
HOWMANYTLD=$(echo -e "`wc -l $VALIDDOMAINTLD | cut -d " " -f 1`")
printf "$yellow"    "$HOWMANYTLD Valid TLD's Total."
echo ""

## Backup TLD list if not there
CHECKME=$VALIDDOMAINTLDBKUP
if
ls $CHECKME &> /dev/null;
then
rm $CHECKME
fi
cp $VALIDDOMAINTLD $VALIDDOMAINTLDBKUP

## Anything New?
printf "$cyan"    "Checking For New TLD's."
gawk 'NR==FNR{a[$0];next} !($0 in a)' $VALIDDOMAINTLDBKUP $VALIDDOMAINTLD > $TLDCOMPARED
HOWMANYTLDNEW=$(echo -e "`wc -l $TLDCOMPARED | cut -d " " -f 1`")
if
[[ "$HOWMANYTLDNEW" != 0 ]]
then
printf "$yellow"    "$HOWMANYTLDNEW New TLD's."
echo "* $HOWMANYTLDNEW New TLD's" | tee --append $RECENTRUN &>/dev/null
else
printf "$yellow"    "No New TLD's"
fi

CHECKME=$VALIDDOMAINTLDBKUP
if
ls $CHECKME &> /dev/null;
then
rm $CHECKME
fi
cp $VALIDDOMAINTLD $VALIDDOMAINTLDBKUP

CHECKME=$TRYNACATCHFIlES
if
ls $CHECKME &> /dev/null;
then
rm $CHECKME
fi
