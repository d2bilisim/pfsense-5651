!/bin/sh

SSL_CN="hotspot.pfsense.biz.tr"
SSL_EMAIL="hotspot@pfsense.biz.tr"
SSL_O="Monospot"
SSL_C="TR"
SSL_ST="Istanbul"
SSL_L="Kartal"

mkdir -p /logimza/.openssl

# Gerekirse sifirla
# cd /logimza/.openssl
# rm -rf password.txt CA/ ssl/

# Zaman damgasi icin OpenSSL ayarlari
fetch https://bitbucket.org/mono/pfsense-5651/raw/master/openssl.cnf -o /logimza/.openssl/openssl.cnf

# Sertifika icin rasgele sifre olusturuyoruz

touch /logimza/.openssl/password.txt
openssl rand -base64 32 > /logimza/.openssl/password.txt
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
openssl req -config /logimza/.openssl/openssl.cnf -passout file:/logimza/.openssl/password.txt -days 3650 -x509 -newkey rsa:2048 -sha256 -subj "/CN=$SSL_CN/emailAddress=$SSL_EMAIL/O=$SSL_O/C=$SSL_C/ST=$SSL_ST/L=$SSL_L" -out /logimza/.openssl/ssl/cacert.pem -outform PEM
cp /logimza/.openssl/ssl/cacert.pem /logimza/.openssl/CA/
cp /logimza/.openssl/ssl/privkey.pem /logimza/.openssl/CA/private/cakey.pem

# TSA icin Sertifika olustur
openssl genrsa -aes256 -passout file:/logimza/.openssl/password.txt -out /logimza/.openssl/ssl/tsakey.pem 2048
openssl req -new -key /logimza/.openssl/ssl/tsakey.pem -passin file:/logimza/.openssl/password.txt -sha256 -out /logimza/.openssl/ssl/tsareq.csr
openssl ca -config /logimza/.openssl/openssl.cnf -passin file:/logimza/.openssl/password.txt -days 3650 -batch -in /logimza/.openssl/ssl/tsareq.csr -subj "/CN=$SSL_CN/emailAddress=$SSL_EMAIL/O=$SSL_O/C=$SSL_C/ST=$SSL_ST/L=$SSL_L" -out /logimza/.openssl/ssl/tsacert.pem
cp /logimza/.openssl/ssl/tsacert.pem /logimza/.openssl/CA/
cp /logimza/.openssl/ssl/tsakey.pem /logimza/.openssl/CA/private/
