#!/bin/bash

# Takes a list of NTLMv1 hashes from Responder.py and parses them into a crackable format
# ready for hashcat:
# ./hashcat --username -m 14000 -a 3 -1 charsets/DES_full.charset --hex-charset hashes.txt ?1?1?1?1?1?1?1?1

file=$1

while read line; do
        user=`echo $line | cut -d ':' -f 1`
        ct1=`python3 ntlmv1.py --ntlmv1 $line | grep 'CT1' | cut -d ':' -f 2 | tr -d ' '`
        ct2=`python3 ntlmv1.py --ntlmv1 $line | grep 'CT2' | cut -d ':' -f 2 | tr -d ' '`
        echo ''$user''p1:''$ct1''':1122334455667788' | tee -a output.txt
        echo ''$user''p2:''$ct2''':1122334455667788' | tee -a output.txt
done < $file

echo "Finished"
