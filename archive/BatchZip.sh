#! /bin/bash

shopt -s expand_aliases
alias 7zz="/Users/anpoliros/Applications/7z2403-mac/7zz"

for file in $(ls);
do
    7zz a -pPHOTOSzbc23980813 $file.zip $file
done
