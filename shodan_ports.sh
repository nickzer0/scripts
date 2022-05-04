#!/bin/bash
# Input API key and feed a list of domains to look up open ports on that domain using Shodan API
# Returns IP and ports in JSON

domains=$1
apikey=''

for dom in `cat $domains`; do
        ip=`host $dom | grep "has address" | awk '{print $4}'`
        echo "Domain: $dom"
        curl -X GET "https://api.shodan.io/shodan/host/$ip?key=$apikey" -s | jq '{ip: .ip_str, ports: .ports}'
done


exit 0
