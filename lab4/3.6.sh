#!/bin/bash
num=`echo -e "$USER$HOME" | tr -d "\n" | wc -c`
echo "$USER $HOME $num"
