#!/bin/bash

# Requirements:
# 1 - pdftoppm
# 2 - tesseract
# 3 - tesseract lang that you need

if [ "$1" = "" ]; then
    echo "Give it a file"
    exit
fi

if [ "$2" = "" ]; then
    lang="eng"
    echo "Using eng as language"
else
    lang="$2"
fi

mkdir tmps
cd tmps || exit

pdftoppm ../"$1" tmp -png
imgs=$(ls tmp*.png)
for img in $imgs; do
    tesseract -l "$lang" "$img" "$img" 
    rm "$img"
done

cat tmp* > result_ocr.txt
rm tmp*
mv result_ocr.txt ..
cd .. || exit
rmdir tmps
