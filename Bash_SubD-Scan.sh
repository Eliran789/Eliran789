#!/bin/bash

url = $1

if [ ! -d "$url" ]; then
  mkdir $url
fi

if [ ! -d "$url"/recon ]; then
  mkdir $url/recon
fi

echo "[+] Enumerating for sub-domains with Sublist3r..."
sublist3r -d $url -o $url/recon/Sublist3r.txt &> /dev/null
cat $url/recon/Sublist3r >> $url/recon/subs.txt

echo "[+] Enumerating for sub-domains with Amass..."
amass enum -d $url >> $url/recon/Amass.txt
cat $url/recon/Amass.txt >> $url/recon/subs.txt

echo "[+] Enumerating for sub-domains with AssetFinder..."
assetfinder -subs-only $url >> $url/recon/Assetfinder.txt
cat $url/recon/Assetfinder.txt >> $url/recon/subs.txt

echo "==================================================="

echo "[+] Deleting duplicates and sorting..."
cat $url/recon/final.txt | sort | uniq > final.txt

echo "[+]Probing for HTTP/HTTPS Live websites..."
cat $url/recon/final.txt | httprobe >> $url/recon/live_webs.txt

echo "=================================================="

echo "[+] Scanning for back-end URIs with prog-lang details..."
for domain in $(cat $url/recon/live_webs.txt); do
  echo "Scanning: $domain"
  dirsearch -u "$domain" -e -t 50 --random-agent >> $url/recon/lang.txt &> /dev/null
done
