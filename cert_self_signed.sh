#!/usr/bin/env bash 
# This is used to generate certificate with an existed CA or self-signed certificates based on openssl!
# Author: Minpu Kang
# Github: https://github.com/MinpuKang/generate-self-signed-certificate
# Version: 
#       1.0, 2021-09-24
#       2.0, 2026-10-28, add keyUsage and extendedKeyUsage
#       2.1, 2026-11-09, update Alternative Name with multiple FQDNs or IPs in CSR and then in certificates
#                        add new paramter "-root" to generate root CA only

########################################
#   No edits below this line
########################################

script_name=`basename $0`
dir_cert_name="dir_cert_"`date +%Y%m%d%H%M%S`
rootca_cert=""
rootca_key=""
self_cert_name=""

###HELP
usage()
{
cat <<EOF 
This is used to generate certificate with an existed CA or self-signed certificates based on openssl!
Version: 2.1

Usage:
 ${script_name} [-h] -c ConfigFile [-ca CACert -key CAKey] [-root]

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
    user@host > ${script_name} -h
 
 2. Generate a ROOT CA only:
    user@host > ${script_name} -c config.cfg -root

 3. Generate a ROOT CA and self-signed certificate:
    user@host > ${script_name} -c config.cfg

 4. Generate certificate with an existd ROOT CA:
    user@host > ${script_name} -c config.cfg -ca ca.crt -key ca.key
    OR
    user@host > ${script_name} -c config.cfg -ca /home/user/ca.crt -key ca.key
 
---------------------------------------------------------------------------------

EOF

exit 
}

#file is there
is_file()
{
    if [ ! -f  $1 ];then
        if [ $2 == "cfg" ];then
            echo;echo -e "\033[31mERROR: File of Configuration(${1}) is not existed! \033[0m";echo;exit;
        fi
        if [ $2 == "rootca_cert" ];then
            echo;echo -e "\033[31mERROR: Root CA(${1}) is not existed! \033[0m";echo;exit;
        fi  
        if [ $2 == "rootca_key" ];then
            echo;echo -e "\033[31mERROR: Root CA Key(${1}) is not existed! \033[0m";echo;exit;
        fi  
    fi
}

#is empty or not
is_empty()
{
    if [ -z $2 ];then
        if [ $1 == "-c" ];then
            echo;echo -e "\033[31mERROR: missing the value for \"-c\"! \033[0m";echo;usage;exit;
        elif [ $1 == "-ca" ];then
            echo;echo -e "\033[31mERROR: missing the value for \"-ca\"! \033[0m";echo;usage;exit;
        elif [ $1 == "-key" ];then
            echo;echo -e "\033[31mERROR: missing the value for \"-key\"! \033[0m";echo;usage;exit;
        else 
            echo;echo -e "\033[31mERROR: missing mandatory parameters! \033[0m";echo;usage;exit;
        fi 
    fi
}


### Generate Root CA
gen_rootca_cert()
{
    echo -e "\033[34m[INFO] Generating CA key files \033[0m"
    openssl genrsa -out ${rootca_key} 4096
    echo 
    
    echo -e "\033[34m[INFO] Generating Root CA \033[0m"
    openssl req -new -x509 -days 36500 -key ${rootca_key} -out ${rootca_cert} -set_serial `echo $RANDOM` -subj "/${Subject_PreCN_ROOT}/CN=${CN_ROOTCA}" -addext "keyUsage = critical, digitalSignature, keyEncipherment, keyCertSign" -addext "extendedKeyUsage = serverAuth, clientAuth"
    echo

    echo -e "\033[34m[INFO] Generating ROOT CA in PEM \033[0m"
    cat `pwd`"/${rootca_cert}" `pwd`"/${rootca_key}" >  `pwd`"/${dir_cert_name}/ca.pem"
    echo "Done"
    echo 
}

### Sign Certificate
gen_sign_cert()
{
    echo -e "\033[34m[INFO] Generating key files \033[0m"
    openssl genrsa -out ${dir_cert_name}/${self_cert_name}.key 4096
    echo 
    
    echo -e "\033[34m[INFO] Generating CSR \033[0m"
    openssl req -new -key ${dir_cert_name}/${self_cert_name}.key -out ${dir_cert_name}/${self_cert_name}.csr -subj "/${Subject_PreCN_Cert}/CN=${CN_Cert}" -addext "keyUsage = critical, digitalSignature, keyEncipherment" -addext "extendedKeyUsage = serverAuth, clientAuth" -addext "subjectAltName = ${Alt_names}"
    echo 
    
    echo -e "\033[34m[INFO] Generating self signed certs \033[0m"
    #openssl x509 -req -days 36500 -in ${dir_cert_name}/${self_cert_name}.csr -CA ${rootca_cert} -CAkey ${rootca_key} -set_serial `echo $RANDOM` -extfile <(printf "subjectAltName=${Alt_names}") -out ${dir_cert_name}/${self_cert_name}.crt -copy_extensions copy
    openssl x509 -req -days 36500 -in ${dir_cert_name}/${self_cert_name}.csr -CA ${rootca_cert} -CAkey ${rootca_key} -set_serial `echo $RANDOM` -out ${dir_cert_name}/${self_cert_name}.crt -copy_extensions copy
    echo 
    
    echo -e "\033[34m[INFO] Generating PEM of client certificate \033[0m"
    cat `pwd`"/${dir_cert_name}/${self_cert_name}.crt" `pwd`"/${dir_cert_name}/${self_cert_name}.key" > `pwd`"/${dir_cert_name}/${self_cert_name}.pem"
    echo "Done"
    echo 
}

## is a certificate
is_cert(){
    openssl x509 -noout -modulus -in $1 >/dev/null 2>&1
    if [[ `echo $?` -ne 0 ]];then
        echo;echo -e "\033[31mERROR: $1 is not a certificate! \033[0m";echo;exit;
    fi 
}

## is a private key
is_pri_key(){
    openssl rsa -noout -modulus -in $1 >/dev/null 2>&1
    if [[ `echo $?` -ne 0 ]];then
        echo;echo -e "\033[31mERROR: $1 is not a private key! \033[0m";echo;exit;
    fi 
}

####
dir_create(){
    if [ ! -f ${1} ];then
        mkdir ${1}
    fi 
}


###
gen_alt_names(){
    # Local variable for the function input argument
    local input_str="$1"
    
    # Define the regular expression for IPv4 validation
    local ip_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    
    # Set IFS to comma and read the input string into an array
    local items
    IFS=',' read -r -a items <<< "$input_str"
    
    # Initialize an empty array to store the processed results with prefixes
    local output_items=()
    local item
    local result

    # Loop through each element in the array
    for item in "${items[@]}"; do
        # Strip leading and trailing whitespace from the element
        item=$(echo "$item" | xargs)
        
        # Skip processing if the element is empty
        if [ -z "$item" ]; then
            continue
        fi

        # Check if the element is an IP or a DNS and prepend the correct prefix
        if [[ $item =~ $ip_regex ]]; then
            result="IP:$item"
        else
            result="DNS:$item"
        fi
        
        # Append the processed item to the output array
        output_items+=("$result")
    done

    # Join the array elements back into a single string using a comma separator
    # and echo it so the calling script can capture the value
    (IFS=,; echo "${output_items[*]}")
}


if [ -z $1 ];then
    echo -e "\033[31mERROR: missing mandatory parameters! \033[0m";echo
    usage 
fi

while [ -n "$1" ]; do
{
    case $1 in
        -c) cfg_file=$2;is_empty $1 $cfg_file;is_file $cfg_file cfg;shift;;
        -ca) rootca_cert=$2;is_empty $1 $rootca_cert;is_file $rootca_cert rootca_cert;is_cert $rootca_cert;shift;;
        -key) rootca_key=$2;is_empty $1 $rootca_key;is_file $rootca_key rootca_key;is_pri_key $rootca_key;shift;;
        -root) rootca="only";shift;;
        -h) usage;;
        *) echo -e "\033[31mInvalid arg: $1 \033[0m";echo;usage;;
    esac
    shift
}
done


### get the subject from configuration file
CN_ROOTCA=`cat ${cfg_file}| grep -E "^CN_ROOTCA" | awk -F ":" '{print $2}' | sed 's/^ *//'`
Subject_PreCN_ROOT=`cat ${cfg_file}| grep -E "^Subject_PreCN_ROOT" | awk -F ":" '{print $2}' | sed 's/^ *//'`

CN_Cert=`cat ${cfg_file}| grep -E "^CN_Cert" | awk -F ":" '{print $2}' | sed 's/^ *//' | awk -F ","  '{print $1}'`
Subject_PreCN_Cert=`cat ${cfg_file}| grep -E "^Subject_PreCN_Cert" | awk -F ":" '{print $2}' | sed 's/^ *//'`
Alt_names=$(gen_alt_names "$(cat ${cfg_file} | grep -E "^CN_Cert" | awk -F ":" '{print $2}')")

self_cert_name=${CN_Cert}


if [[ -f $cfg_file ]] && [[ $rootca == "only" ]] ;then 
    if [[ $CN_ROOTCA == "" ]] || [[ $Subject_PreCN_ROOT == "" ]];then 
        echo -e "\033[31mERROR: Subject for ROOT CA is not fully set, please check the config file! \033[0m"
        echo
        usage
    fi 
    rootca_cert="${dir_cert_name}/ca.crt"
    rootca_key="${dir_cert_name}/ca.key"
    dir_create ${dir_cert_name}
    gen_rootca_cert
    mv ${dir_cert_name} rootCA_${dir_cert_name#dir_cert_}
### generate certificates with existing CA
elif [[ -f $cfg_file ]] && [[ $rootca_cert != "" ]] && [[ $rootca_key != "" ]];then 
    if [[ `diff -eq <(openssl x509 -noout -modulus -in $rootca_cert | openssl md5) <(openssl rsa -noout -modulus -in $rootca_key | openssl md5)` == "" ]];then
        if [[ $CN_Cert == "" ]] || [[ $Subject_PreCN_Cert == "" ]];then 
            echo -e "\033[31mERROR: Subject for client is not fully set, please check the config file! \033[0m"
            echo
            usage
        fi 
        dir_create ${dir_cert_name}
        gen_sign_cert
        echo -e "\033[34m[INFO] Copy CA certificate and key to target folder! \033[0m";
        echo "Done"
        cp ${rootca_cert} ${dir_cert_name}
        cp ${rootca_key} ${dir_cert_name}
    else
        echo;echo -e "\033[31mERROR: CA certificate ($rootca_cert) and CA private key ($rootca_key) do not match! \033[0m";echo;exit
    fi
### generate ROOT CA and certificates
elif [[ -f $cfg_file ]] && [[ $rootca_cert == "" ]] && [[ $rootca_key == "" ]];then 
    if [[ $CN_ROOTCA == "" ]] || [[ $Subject_PreCN_ROOT == "" ]];then 
        echo -e "\033[31mERROR: Subject for ROOT CA is not fully set, please check the config file! \033[0m"
        echo
        usage
    fi 
    if [[ $CN_Cert == "" ]] || [[ $Subject_PreCN_Cert == "" ]];then 
        echo -e "\033[31mERROR: Subject for client is not fully set, please check the config file! \033[0m"
        echo
        usage
    fi 
    rootca_cert="${dir_cert_name}/ca.crt"
    rootca_key="${dir_cert_name}/ca.key"
    dir_create ${dir_cert_name}
    gen_rootca_cert
    gen_sign_cert
else
    echo -e "\033[31mERROR: Missed parameters, -c for config file, -ca for root ca, -key for root ca key, -ca and -key are in pair! \033[0m";echo 
    usage
fi 

if [[ $rootca != "only" ]];then
    echo;echo -e "\033[34m[RESULT] Certificates are generated and in below folder: \033[0m"
    echo "Certificates in folder: "`pwd`"/${dir_cert_name}"
    ls -l ${dir_cert_name} | awk 'NR>=2 {print $9}' 
    
    echo;echo -e "\033[34m[Verify] Verify and Check Certificate: \033[0m"
    openssl verify -verbose -CAfile ${rootca_cert} `pwd`"/${dir_cert_name}/${self_cert_name}.pem"
    echo 
    
    echo -e "\033[34m[INFO] More CLIs to check certificate: \033[0m"
    echo "openssl verify -verbose -CAfile ${rootca_cert} `pwd`"/${dir_cert_name}/${self_cert_name}.pem""
    echo "openssl x509 -noout -text -in ${rootca_cert}"
    echo "openssl req -text -noout -in `pwd`/${dir_cert_name}/${self_cert_name}.csr"
    echo "openssl x509 -noout -text -in `pwd`/${dir_cert_name}/${self_cert_name}.crt"
    echo "openssl x509 -noout -text -in `pwd`/${dir_cert_name}/${self_cert_name}.pem"
    echo 
fi 

