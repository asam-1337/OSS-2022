#!/bin/bash
md5sum *.txt | sort -k1 | uniq -w32 -cd | awk '{print $1, $3}' | tr ' ' '\t'
