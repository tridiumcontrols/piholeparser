#!/bin/bash
## This creates my custom biglist

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

WHATITIS="All Parsed List (edited)"
timestamp=$(echo `date`)
if
[[ -f $BIGAPLE ]]
then
rm $BIGAPLE
echo "* $WHATITIS Removed. $timestamp" | tee --append $RECENTRUN &>/dev/null
else
echo "* $WHATITIS Not Removed. $timestamp" | tee --append $RECENTRUN &>/dev/null
fi

if
[[ ! -f $BLACKLISTTEMP ]]
then
printf "$red"  "Blacklist File Missing."
MISSINGBLACK=true
fi
if
[[ ! -f $WHITELISTTEMP ]]
then
printf "$red"  "Whitelist File Missing."
MISSINGWHITE=true
fi
if
[[ ! -f $BIGAPL ]]
then
printf "$red"  "Big List File Missing."
touch $BIGAPL
fi

printf "$cyan"  "Generating All Parsed List (edited)."
echo ""

## Add Blacklist Domains
if
[[ -z $MISSINGBLACK ]]
then
printf "$yellow"  "Adding Blacklist Domains."
cat $BLACKLISTTEMP $BIGAPL >> $FILETEMP
echo -e "`wc -l $FILETEMP | cut -d " " -f 1` lines after blacklist"
echo ""
else
cp $BIGAPL $FILETEMP
fi

## Remove Whitelist Domains
if
[[ -z $MISSINGWHITE ]]
then
printf "$yellow"  "Removing whitelist Domains."
#gawk 'NR==FNR{a[$0];next} !($0 in a)' $WHITELISTTEMP $FILETEMP >> $TEMPFILE
grep -Fvxf $WHITELISTTEMP $FILETEMP >> $TEMPFILE
rm $FILETEMP
mv $TEMPFILE $FILETEMP
echo -e "`wc -l $FILETEMP | cut -d " " -f 1` lines after whitelist"
echo ""
fi

## Dedupe
printf "$yellow"  "Removing Duplicates."
cat -s $FILETEMP | sort -u | gawk '{if (++dup[$0] == 1) print $0;}' >> $TEMPFILE
echo -e "`wc -l $TEMPFILE | cut -d " " -f 1` lines after deduping"
rm $FILETEMP
echo ""

## Github has a 100mb limit and empty files are useless
FETCHFILESIZE=$(stat -c%s $TEMPFILE)
timestamp=$(echo `date`)
if
[ "$FETCHFILESIZE" -ge "$GITHUBLIMIT" ]
then
printf "$red"     "Parsed File Too Large For Github. Deleting."
echo "* Allparsedlist list was too large to host on github. $FETCHFILESIZE bytes $timestamp" | tee --append $RECENTRUN &>/dev/null
echo "File exceeded Githubs 100mb limitation" | tee --append $TEMPFILE
mv $TEMPFILE $BIGAPLE
elif
[ "$FETCHFILESIZE" -eq 0 ]
then
printf "$red"     "File Empty"
echo "* Allparsedlist list was an empty file $timestamp" | tee --append $RECENTRUN &>/dev/null
mv $TEMPFILE $BIGAPLE
else
mv $TEMPFILE $BIGAPLE
printf "$yellow"  "Big List Edited Created Successfully."
fi
