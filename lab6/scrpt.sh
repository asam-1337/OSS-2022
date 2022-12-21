#!/bin/bash

gcc 2."$1".c

./a.out & pstree | grep a.out
