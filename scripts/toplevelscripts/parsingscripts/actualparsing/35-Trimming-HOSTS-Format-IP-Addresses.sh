#!/bin/bash
## Content Filtering and IP addresses

## Variables
script_dir=$(dirname $0)
SCRIPTVARSDIR="$script_dir"/../../../scriptvars/
STATICVARS="$SCRIPTVARSDIR"staticvariables.var
if
[[ -f $STATICVARS ]]
then
source $STATICVARS
else
echo "Static Vars File Missing, Exiting."
exit
fi

cat $TEMPFILEL | sed 's/^PRIMARY\s\+[ \t]*//; s/^localhost\s\+[ \t]*//; s/blockeddomain.hosts\s\+[ \t]*//; s/^0.0.0.0\s\+[ \t]*//; s/^127.0.0.1\s\+[ \t]*//; s/^::1\s\+[ \t]*//' > $TEMPFILEM
