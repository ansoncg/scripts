#!/bin/bash

nCasos=10

cd ..
make
make t
yes | cp programa Casos
yes | cp teste Casos
cd Casos

for i in {1..$nCasos} ; do
   if [ $(./programa < $i.in) = $(cat $i.out) ]; then
      printf "$i - Certo\n"
   else
      printf "$i - Errado\n"
   fi
done 

printf "\nProcurando por leaks...\n"

for i in {1..$nCasos} ; do
   printf "\nCaso $i:\n"
   (./teste < $i.in) | grep "Tirando output"
done

printf "\n"
