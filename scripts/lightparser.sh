#!/bin/bash
## This is the Parsing Process
## For Lists that barely need it

## Variables
source /etc/piholeparser/scriptvars/variables.var

####################
## File Lists     ##
####################

echo ""
printf "$green"   "Filtering Lists that are already in the correct format."
echo ""

## Start File Loop
for f in $LIGHTPARSE
do

echo ""
printf "$blue"    "___________________________________________________________"
echo ""
printf "$green"   "Processing list from $f"
echo ""

## Process sources within file.lst
for source in `cat $f`;
do

## Set Variables (again, I guess)
source /etc/piholeparser/scriptvars/variables.var

echo ""
printf "$cyan"    "$source"
echo "" 

####################
## Download Lists ##
####################

if [[ -z $UPCHECK ]]
then
printf "$yellow"    "Fetching List From Local File"
sudo curl --silent -L $source >> $TEMPFILE
sudo cat $TEMPFILE >> $ORIGFILE
sudo rm $TEMPFILE
else 
SOURCEIPFETCH=`ping -c 1 $UPCHECK | gawk -F'[()]' '/PING/{print $2}'`
SOURCEIP=`echo $SOURCEIPFETCH`
printf "$yellow"    "Fetching List from $UPCHECK located at the IP of $SOURCEIP"
sudo wget -q -O $TEMPFILE $source
sudo cat $TEMPFILE >> $ORIGFILE
sudo rm $TEMPFILE
fi

## Source completion
done

echo -e "\t`wc -l $ORIGFILE | cut -d " " -f 1` lines downloaded"
ORIGFILESIZE=$(stat -c%s "$ORIGFILE")
printf "$yellow"  "Size of $ORIGFILE = $ORIGFILESIZE bytes."

timestamp=`date`
if 
[ "$ORIGFILESIZE" -eq 0 ]
then
sudo echo "$FNAME list was an empty file upon download $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
else
echo ""
fi

####################
## Create Mirrors ##
####################

echo ""
printf "$green"   "Attempting creation of mirror file"
echo ""

## Copy original, one for mirror, one for next step
sudo cp $ORIGFILE $MFILENAME

## Github has a 100mb limit, and empty files are useless
MFILESIZE=$(stat -c%s "$MFILENAME")
timestamp=`date`
if 
[ "$MFILESIZE" -ge "$GITHUBLIMIT" ]
then
echo ""
printf "$red"     "Size of $MFILENAME = $MFILESIZE bytes."
printf "$red"     "Mirror File Too Large For Github. Deleting."
sudo echo "$FNAME list was too large to mirror on github. $MFILESIZE bytes $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
sudo rm $MFILENAME
elif
[ "$MFILESIZE" -eq 0 ]
then
echo ""
printf "$red"     "Size of $MFILENAME = $MFILESIZE bytes. Deleting."
sudo echo "$FNAME list was an empty file $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
sudo rm $MFILENAME
else
echo ""
printf "$yellow"     "Size of $MFILENAME = $MFILESIZE bytes."
printf "$yellow"  "Creating Mirror of Unparsed File."
sudo mv $MFILENAME /etc/piholeparser/mirroredlists/
sudo rename "s/.mirror.txt/.txt/" /etc/piholeparser/mirroredlists/*.txt
fi

####################
## Pre-Processing ##
####################

## Copy for Pre-Processing
sudo mv $ORIGFILE $PRE

echo ""
printf "$green"   "Checking for domain requirements"
echo ""

## Remove lines without letters
echo ""
PARSECOMMENT="removing lines without letters"
printf "$yellow"  "$PARSECOMMENT ..."
sudo sed '/[a-z]/!d' < $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## delete lines without a period
echo ""
PARSECOMMENT="removing lines without a period"
printf "$yellow"  "$PARSECOMMENT ..."
sudo sed '/[.]/!d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

echo ""
printf "$green"   "Checking for definately not domain name stuff"
echo ""

## Remove comments
echo ""
PARSECOMMENT="removing comments"
printf "$yellow"  "$PARSECOMMENT..."
sudo sed '/^\s*#/d' $PRE > $POST
sudo rm $PRE
sudo mv $POST $PRE
sudo sed 's/[#]/\'$'\n/g' $PRE > $POST
sudo rm $PRE
sudo mv $POST $PRE
sudo sed '/[#]/d' $PRE > $POST
sudo rm $PRE
sudo mv $POST $PRE
sudo sed '/[!]/d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT ."
sudo mv $POST $PRE

## delete lines with forward slash
echo ""
PARSECOMMENT="removing lines containing a forward slash"
printf "$yellow"  "$PARSECOMMENT ..."
sudo sed '/[/]/d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## remove asterisk lines
echo ""
PARSECOMMENT="removing asterisk lines"
printf "$yellow"  "$PARSECOMMENT ..."
sudo sed '/[*]/d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## Remove Empty Lines
echo ""
PARSECOMMENT="removing empty lines"
printf "$yellow"  "$PARSECOMMENT ..."
sudo sed '/^$/d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

echo ""
printf "$green"   "Checking for periods where they shouldn't be for a real domain"
echo ""

## delete lines that start with a period
echo ""
PARSECOMMENT="removing lines that start with a period"
printf "$yellow"  "$PARSECOMMENT ..."
sed '/^[.],/d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## delete lines that end with a period
echo ""
PARSECOMMENT="removing lines that end with a period"
printf "$yellow"  "$PARSECOMMENT ..."
sed '/[.]$/d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## delete lines with localhost
echo ""
PARSECOMMENT="removing lines containing localhost"
printf "$yellow"  "$PARSECOMMENT ..."
sudo sed '/localhost/d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## Remove IP addresses
echo ""
PARSECOMMENT="removing IP addresses"
printf "$yellow"  "$PARSECOMMENT ..."
sudo sed 's/^PRIMARY[ \t]*//' $PRE > $POST
sudo rm $PRE
sudo mv $POST $PRE 
sudo sed 's/blockeddomain.hosts[ \t]*//' $PRE > $POST
sudo rm $PRE
sudo mv $POST $PRE
sudo sed 's/^0.0.0.0[ \t]*//' $PRE > $POST
sudo rm $PRE
sudo mv $POST $PRE
sudo sed 's/^127.0.0.1[ \t]*//' $PRE > $POST
sudo rm $PRE
sudo mv $POST $PRE
sudo sed 's/^::1[ \t]*//' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## Duplicate Removal
echo ""
PARSECOMMENT="removing duplicates"
printf "$yellow"  "$PARSECOMMENT ..."
sort -u $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## Done with sifting
sudo mv $PRE $PFILENAME

####################
## Complete Lists ##
#################### 

echo ""
printf "$green"   "Attempting Creation of Parsed List."
echo ""

## Github has a 100mb limit, and empty files are useless
PFILESIZE=$(stat -c%s "$PFILENAME")
timestamp=`date`
if
[ "$PFILESIZE" -ge "$GITHUBLIMIT" ]
then
echo ""
printf "$red"     "Size of $PFILENAME = $PFILESIZE bytes."
printf "$red"     "Parsed File Too Large For Github. Deleting."
sudo echo "Parsed $FNAME list too large for github. $PFILESIZE bytes $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
sudo rm $PFILENAME
elif
[ "$PFILESIZE" -eq 0 ]
then
echo ""
printf "$red"     "Size of $PFILENAME = $PFILESIZE bytes. Deleting."
sudo echo "Parsed $FNAME list was an empty file $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
sudo rm $PFILENAME
else
echo ""
printf "$yellow"  "Size of $PFILENAME = $PFILESIZE bytes."
printf "$yellow"  "File will be moved to the parsed directory."
sudo mv $PFILENAME /etc/piholeparser/parsed/
sudo rename "s/.parsed.txt/.txt/" /etc/piholeparser/parsed/*.txt
fi

printf "$magenta" "___________________________________________________________"
echo ""

## End File Loop
done
