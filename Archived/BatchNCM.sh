#! /bin/bash

shopt -s expand_aliases
alias ncmdump="/opt/homebrew/Cellar/ncmdump/1.2.1/bin/ncmdump"

for file in $(ls)
do
    ncmdump -d ./
done