# Introduction
This is a shell script for generating self signed certificate based a configuration file.
It can generate a CA and then sign certificates to client.
It can also sign certificates to client based on existing CA with CA CRT and CA Private Key.

# Usage
[coreuser@HK:ca_self_signed]$ ./cert_self_signed.sh -h
This is used to generate certificate with an existed CA or self-signed certificates based on openssl!
Version: 1.0

Usage:
 cert_self_signed.sh [-h] -c ConfigFile [-ca CACert -key CAKey] 

Options:
 -h        Show the help
 -c        Config File for Certificate Subject
 -ca       An existed CA certificate(with relative path or absolute path)
 -key      The existed CA private key file(with relative path or absolute path)
           Note: -ca and -key must be set in pair.

For Example:
---------------------------------------------------------------------------------
 1. Show Help:
    user@host > cert_self_signed.sh -h
 
 2. Generate a ROOT CA and self-signed certificate:
    user@host > cert_self_signed.sh -c config.cfg

 3. Generate certificate with an existd ROOT CA:
    user@host > cert_self_signed.sh -c config.cfg -ca ca.crt -key ca.key
    OR
    user@host > cert_self_signed.sh -c config.cfg -ca /home/user/ca.crt -key ca.key
 
---------------------------------------------------------------------------------

# Paramters in Config File
1. For Root CA：
  Two parameters are defined: CN_ROOTCA is a FQDN for Root CA, Subject_PreCN_ROOT is the Subject for Common Name including, and format is below:
    CN_ROOTCA: <Value>
    Subject_PreCN_ROOT: <Value>
  for example: 
    CN_ROOTCA: www.hk314.top
    Subject_PreCN_ROOT: C=CN/ST=LN/L=DL/O=HK/OU=Root

2. For Client Certificate:
  Two parameters are defined: CN_Cert is a FQDN for Root CA, Subject_PreCN_Cert is the Subject for Common Name including, and format is below:
    CN_Cert: <Value>
    Subject_PreCN_Cert: <Value>
  for example: 
    CN_Cert: self.cert.hk314.top
    Subject_PreCN_Cert: C=CN/ST=LN/L=DL/O=HK/OU=Self

# An example for generate Root CA and sign certificate:
[coreuser@HK:ca_self_signed]$ ./cert_self_signed.sh -c config.cfg
[INFO] Generating CA key files 
Generating RSA private key, 4096 bit long modulus (2 primes)
....................................................................................................................................................................++++
..................................................................................................................................................................++++
e is 65537 (0x010001)

[INFO] Generating Root CA 
Can't load /home/coreuser/.rnd into RNG
140651893559744:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/home/coreuser/.rnd

[INFO] Generating ROOT CA in PEM 
Done

[INFO] Generating key files 
Generating RSA private key, 4096 bit long modulus (2 primes)
......................++++
...............++++
e is 65537 (0x010001)

[INFO] Generating CSR 
Can't load /home/coreuser/.rnd into RNG
140347426673088:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/home/coreuser/.rnd

[INFO] Generating self signed certs 
Signature ok
subject=C = CN, ST = LN, L = DL, O = HK, OU = Self, CN = self.cert.hk314.top
Getting CA Private Key

[INFO] Generating PEM of client certificate 
Done


[RESULT] Certificates are generated and in below folder: 
Certificates in folder: /mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210254
ca.crt
ca.key
ca.pem
self.cert.hk314.top.crt
self.cert.hk314.top.csr
self.cert.hk314.top.key
self.cert.hk314.top.pem

[Verify] Verify and Check Certificate: 
/mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210254/self.cert.hk314.top.pem: OK

[INFO] More CLIs to check certificate: 
openssl verify -verbose -CAfile dir_cert_20210924210254/ca.crt /mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210254/self.cert.hk314.top.pem
openssl x509 -noout -text -in dir_cert_20210924210254/ca.crt
openssl req -text -noout -in /mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210254/self.cert.hk314.top.csr
openssl x509 -noout -text -in /mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210254/self.cert.hk314.top.crt
openssl x509 -noout -text -in /mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210254/self.cert.hk314.top.pem

# An example to sign certificate with exising CA:
[coreuser@HK:ca_self_signed]$ ./cert_self_signed.sh -c config.cfg1 -ca dir_cert_20210924210254/ca.crt -key dir_cert_20210924210254/ca.key 
[INFO] Generating key files 
Generating RSA private key, 4096 bit long modulus (2 primes)
................................................................................................................................................................++++
........................................................................++++
e is 65537 (0x010001)

[INFO] Generating CSR 
Can't load /home/coreuser/.rnd into RNG
139696556020160:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/home/coreuser/.rnd

[INFO] Generating self signed certs 
Signature ok
subject=C = CN, ST = LN, L = DL, O = HK, OU = Self, CN = self1.cert.hk314.top
Getting CA Private Key

[INFO] Generating PEM of client certificate 
Done

[INFO] Copy CA certificate and key to target folder! 
Done

[RESULT] Certificates are generated and in below folder: 
Certificates in folder: /mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210442
ca.crt
ca.key
self1.cert.hk314.top.crt
self1.cert.hk314.top.csr
self1.cert.hk314.top.key
self1.cert.hk314.top.pem

[Verify] Verify and Check Certificate: 
/mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210442/self1.cert.hk314.top.pem: OK

[INFO] More CLIs to check certificate: 
openssl verify -verbose -CAfile dir_cert_20210924210254/ca.crt /mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210442/self1.cert.hk314.top.pem
openssl x509 -noout -text -in dir_cert_20210924210254/ca.crt
openssl req -text -noout -in /mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210442/self1.cert.hk314.top.csr
openssl x509 -noout -text -in /mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210442/self1.cert.hk314.top.crt
openssl x509 -noout -text -in /mnt/c/Users/eminpka/Desktop/ca_self_signed/dir_cert_20210924210442/self1.cert.hk314.top.pem

