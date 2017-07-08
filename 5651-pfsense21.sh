#!/bin/sh

SSL_CN="dolpway.d2bilisim.com.tr"
SSL_EMAIL="dolpway@d2bilisim.com.tr"
SSL_O="D2 Bilgi Teknolojileri"
SSL_C="TR"
SSL_ST="Istanbul"
SSL_L="Sisli"

# Gerekirse sifirla
# rm -rf /logimza/.openssl/password.txt /logimza/.openssl/CA/ /logimza/.openssl/ssl/ /usr/local/www/log_browser /sbin/logimza-imzala.sh /sbin/dhcptibduzenle.sh

# Zaman damgasi icin OpenSSL ayarlari
mkdir -p /logimza/.openssl
fetch https://raw.githubusercontent.com/d2bilisim/pfsense-5651/master/openssl.cnf 
mv openssl.cnf /logimza/.openssl/openssl.cnf

# Sertifika icin rasgele sifre olusturuyoruz
touch /logimza/.openssl/password.txt
/usr/local/bin/openssl rand -base64 32 > /logimza/.openssl/password.txt
cat /logimza/.openssl/password.txt

# Sertifika olusturma islemleri

# Gerekli klasor ve dosyalari olustur
mkdir -p /logimza/.openssl/ssl
mkdir -p /logimza/.openssl/CA/private
mkdir -p /logimza/.openssl/CA/newcerts
touch /logimza/.openssl/CA/index.txt
touch /logimza/.openssl/CA/serial
echo 011E > /logimza/.openssl/CA/serial
touch /logimza/.openssl/CA/tsaserial
echo 011E > /logimza/.openssl/CA/tsaserial

# CA olustur
cd /logimza/.openssl/ssl
/usr/local/bin/openssl req -config /logimza/.openssl/openssl.cnf -passout file:/logimza/.openssl/password.txt -days 3650 -x509 -newkey rsa:2048 -sha256 -subj "/CN=$SSL_CN/emailAddress=$SSL_EMAIL/O=$SSL_O/C=$SSL_C/ST=$SSL_ST/L=$SSL_L" -out /logimza/.openssl/ssl/cacert.pem -outform PEM
cp /logimza/.openssl/ssl/cacert.pem /logimza/.openssl/CA/
cp /logimza/.openssl/ssl/privkey.pem /logimza/.openssl/CA/private/cakey.pem

# TSA icin Sertifika olustur
/usr/local/bin/openssl genrsa -aes256 -passout file:/logimza/.openssl/password.txt -out /logimza/.openssl/ssl/tsakey.pem 2048
/usr/local/bin/openssl req -new -key /logimza/.openssl/ssl/tsakey.pem -passin file:/logimza/.openssl/password.txt -sha256 -out /logimza/.openssl/ssl/tsareq.csr
/usr/local/bin/openssl ca -config /logimza/.openssl/openssl.cnf -passin file:/logimza/.openssl/password.txt -days 3650 -batch -in /logimza/.openssl/ssl/tsareq.csr -subj "/CN=$SSL_CN/emailAddress=$SSL_EMAIL/O=$SSL_O/C=$SSL_C/ST=$SSL_ST/L=$SSL_L" -out /logimza/.openssl/ssl/tsacert.pem
cp /logimza/.openssl/ssl/tsacert.pem /logimza/.openssl/CA/
cp /logimza/.openssl/ssl/tsakey.pem /logimza/.openssl/CA/private/

# log_browser ve imzalama betiklerini yukle
fetch https://github.com/d2bilisim/log_browser/archive/master.zip 
mv master.zip /tmp/log_browser.zip
unzip -d /usr/local/www /tmp/log_browser.zip
mv /usr/local/www/log_browser-master /usr/local/www/log_browser
rm /tmp/log_browser.zip
fetch https://raw.githubusercontent.com/d2bilisim/pfsense-5651/master/dogrula-pfsense21.php 
mv dogrula-pfsense21.php /usr/local/www/log_browser/dogrula.php
fetch https://raw.githubusercontent.com/d2bilisim/pfsense-5651/master/logimza-imzala-pfsense21.sh 
mv logimza-imzala-pfsense21.sh /sbin/logimza-imzala.sh
fetch https://raw.githubusercontent.com/d2bilisim/pfsense-5651/master/dhcptibduzenle.sh 
mv dhcptibduzenle.sh /sbin/dhcptibduzenle.sh
chmod +x /sbin/logimza-imzala.sh /sbin/dhcptibduzenle.sh