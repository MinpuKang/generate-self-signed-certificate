# Introduction
This is a shell script for generating self signed certificate based a configuration file.

It can generate a CA and then sign certificates to client.

It can also sign certificates to client based on existing CA with CA CRT and CA Private Key.

# Usage
```

[test@wsl:generate-self-signed-certificate-main]$ ./cert_self_signed.sh -h
This is used to generate certificate with an existed CA or self-signed certificates based on openssl!
Version: 2.1

Usage:
 cert_self_signed.sh [-h] -c ConfigFile [-ca CACert -key CAKey] [-root]

Options:
 -h        Show the help
 -c        Config File for Certificate Subject
 -root     Generate Root CA only
 -ca       An existed CA certificate(with relative path or absolute path)
 -key      The existed CA private key file(with relative path or absolute path)
           Note: -ca and -key must be set in pair.

For Example:
---------------------------------------------------------------------------------
 1. Show Help:
    user@host > cert_self_signed.sh -h
 
 2. Generate a ROOT CA only:
    user@host > cert_self_signed.sh -c config.cfg -root

 3. Generate a ROOT CA and self-signed certificate:
    user@host > cert_self_signed.sh -c config.cfg

 4. Generate certificate with an existd ROOT CA:
    user@host > cert_self_signed.sh -c config.cfg -ca ca.crt -key ca.key
    OR
    user@host > cert_self_signed.sh -c config.cfg -ca /home/user/ca.crt -key ca.key
 
---------------------------------------------------------------------------------
```
# Paramters in Config File
1. For Root CA：

  Two parameters are defined: CN_ROOTCA is a FQDN for Root CA, Subject_PreCN_ROOT is the Subject for Common Name including, and format is below:
  
    CN_ROOTCA: Value
 
    Subject_PreCN_ROOT: Value
 
  for example: 
 
    CN_ROOTCA: www.hk314.top
 
    Subject_PreCN_ROOT: C=CN/ST=LN/L=DL/O=HK/OU=Root

2. For Client Certificate:

  Two parameters are defined: CN_Cert is a FQDN for Root CA, Subject_PreCN_Cert is the Subject for Common Name including, and format is below:
  
    CN_Cert: Value
    
    Subject_PreCN_Cert: Value
    
  for example: 
  
    CN_Cert: self.cert.hk314.top
    
    Subject_PreCN_Cert: C=CN/ST=LN/L=DL/O=HK/OU=Self

# An example for generate Root CA and sign certificate:
```
[test@wsl:generate-self-signed-certificate-main]$ ./cert_self_signed.sh -c config.cfg 
[INFO] Generating CA key files 

[INFO] Generating Root CA 

[INFO] Generating ROOT CA in PEM 
Done

[INFO] Generating key files 

[INFO] Generating CSR 

[INFO] Generating self signed certs 
Certificate request self-signature ok
subject=C = CN, ST = LN, L = DL, O = HK, OU = Self, CN = self.cert.hk314.top

[INFO] Generating PEM of client certificate 
Done


[RESULT] Certificates are generated and in below folder: 
Certificates in folder: /home/test/generate-self-signed-certificate-main/dir_cert_20261109192730
ca.crt
ca.key
ca.pem
self.cert.hk314.top.crt
self.cert.hk314.top.csr
self.cert.hk314.top.key
self.cert.hk314.top.pem

[Verify] Verify and Check Certificate: 
/home/test/generate-self-signed-certificate-main/dir_cert_20261109192730/self.cert.hk314.top.pem: OK

[INFO] More CLIs to check certificate: 
openssl verify -verbose -CAfile dir_cert_20261109192730/ca.crt /home/test/generate-self-signed-certificate-main/dir_cert_20261109192730/self.cert.hk314.top.pem
openssl x509 -noout -text -in dir_cert_20261109192730/ca.crt
openssl req -text -noout -in /home/test/generate-self-signed-certificate-main/dir_cert_20261109192730/self.cert.hk314.top.csr
openssl x509 -noout -text -in /home/test/generate-self-signed-certificate-main/dir_cert_20261109192730/self.cert.hk314.top.crt
openssl x509 -noout -text -in /home/test/generate-self-signed-certificate-main/dir_cert_20261109192730/self.cert.hk314.top.pem

[test@wsl:generate-self-signed-certificate-main]$
```

# An example to generate root CA only
```
[test@wsl:generate-self-signed-certificate-main]$ ./cert_self_signed.sh -c config.cfg -root
[INFO] Generating CA key files 

[INFO] Generating Root CA 

[INFO] Generating ROOT CA in PEM 
Done

```

# An example to sign certificate with exising CA
```
[test@wsl:generate-self-signed-certificate-main]$ ./cert_self_signed.sh -c config.cfg -ca rootCA_20261109192655/ca.crt -key rootCA_20261109192655/ca.key
[INFO] Generating key files 

[INFO] Generating CSR 

[INFO] Generating self signed certs 
Certificate request self-signature ok
subject=C = CN, ST = LN, L = DL, O = HK, OU = Self, CN = self.cert.hk314.top

[INFO] Generating PEM of client certificate 
Done

[INFO] Copy CA certificate and key to target folder! 
Done

[RESULT] Certificates are generated and in below folder: 
Certificates in folder: /home/test/generate-self-signed-certificate-main/dir_cert_20261109192720
ca.crt
ca.key
self.cert.hk314.top.crt
self.cert.hk314.top.csr
self.cert.hk314.top.key
self.cert.hk314.top.pem

[Verify] Verify and Check Certificate: 
/home/test/generate-self-signed-certificate-main/dir_cert_20261109192720/self.cert.hk314.top.pem: OK

[INFO] More CLIs to check certificate: 
openssl verify -verbose -CAfile rootCA_20261109192655/ca.crt /home/test/generate-self-signed-certificate-main/dir_cert_20261109192720/self.cert.hk314.top.pem
openssl x509 -noout -text -in rootCA_20261109192655/ca.crt
openssl req -text -noout -in /home/test/generate-self-signed-certificate-main/dir_cert_20261109192720/self.cert.hk314.top.csr
openssl x509 -noout -text -in /home/test/generate-self-signed-certificate-main/dir_cert_20261109192720/self.cert.hk314.top.crt
openssl x509 -noout -text -in /home/test/generate-self-signed-certificate-main/dir_cert_20261109192720/self.cert.hk314.top.pem

[test@wsl:generate-self-signed-certificate-main]$ 
```

Additional, here is an introduction of [What is a Digital Signature in Chinese translated](https://www.ruanyifeng.com/blog/2011/08/what_is_a_digital_signature.html) from [An introduction to Digital Signatures, by David Youd](http://www.youdzone.com/signature.html).

