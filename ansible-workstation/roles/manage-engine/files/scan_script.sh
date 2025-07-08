#!/bin/bash

host="$1"
port="5454"
enc_key="adL0g0nAppPwd_"
dirPath=$HOME/sdptmp
serverUrl=https://sdpondemand.manageengine.in
agent=false
canUpload=true
md=md5
if [ "X$1" = "X" ]; then
    echo "Usage : scan_script.sh <Probe Host> [Port]"
    exit 1
fi
argument=$1
sw_scan="true"
apiKey=""
verbose="false"
encType="-aes-128-cbc"

for var in "$@"
do
    if [[ $var == *"server="* ]] || [[ $var == *"serverUrl="* ]]; then
        serverUrl=`echo $var | cut -d "=" -f2`
        echo $serverUrl
    fi
    if [[ $var == *"apiKey"* ]]; then
        apiKey=$var
        agent=true
    fi
    if [[ $var == *"sw_scan="* ]]; then
        if [[ $var == *"true"* ]]; then
            sw_scan="true"
        fi
    fi
    if [[ $var = "-v" ]]; then
        verbose="true"
    fi
    if [[ $var == *"path="* ]]; then
         dirPath=$(echo $(echo $var | cut -d'=' -f 2)/sdptmp)
         echo "dirPath set to [$dirPath]"
    fi
    if [[ $var == *"encType="* ]]; then
	encType=`echo $var | cut -d'=' -f2`
	echo Custom encryption used. $encType
    fi
done

mkdir -p $dirPath
last_scan=$dirPath/last_scan

if [ "X$apiKey" != "X" ]
then
	if [ -f "$last_scan" ]
	then
	     currtime=`date +"%s"`
             filetime=`date -r "$last_scan" +"%s"`
	     filetimeplus=$(($filetime + 300))
	     if [ $currtime -gt  $filetimeplus ]
             then
		     echo Scan result xml can be uploaded to server
	     else
		     echo Time interval must be 5 minutes to upload scan result
		     canUpload=false
	     fi 		
	fi	
	agent=true
fi
if [ "$sw_scan" == "false" ]
then
	mkdir -p $dirPath
	echo "Software scan disabled"
	echo "no software scan" > "$dirPath/no_software_scan.txt"
else	
	rm -f  $dirPath/no_software_scan.txt
	echo "Software Scan enabled"
fi
if [ "$agent" = false -a "X$2" != "X" ]
then
    if [[ $2 != *"sw_scan="* ]]; then
	if [[ $2 != *"encType="* ]]; then
		port=$2
	fi		
    fi	
fi

checkAndDeleteFile()
{
    if [ -f $1 ]
    then 
        rm -f $1
        if [ $? -ne 0 ]
        then
            echo "Unable to delete $1. QUITTING"
            exit 1
        fi
    fi
}

checkAndDeleteFiles()
{
    checkAndDeleteFile $dirPath/ae_scan.sh
    checkAndDeleteFile $dirPath/ae_scan.sh_enc
    checkAndDeleteFile $dirPath/scan_result.xml
    checkAndDeleteFile $dirPath/scan_result.xml_enc
    checkAndDeleteFile $dirPath/scan_result.enc
}

downloadScanScript()
{
    echo "Going to download scan script from Probe"
    downloadstr="GET_LIN_SCRIPT"
    unamestr=`uname`
    echo $unamestr
    if [ "Darwin" = "$unamestr" ]
    then
        downloadstr="GET_MAC_SCRIPT"
    fi
    if [ "-aes-256-cbc" = "$encType" ]
    then
	if $verbose
	then
		echo "Going to request data from probe using $encType"
	fi
	dataToSend=`echo $downloadstr | openssl enc -a -base64 $encType -pass pass:$enc_key -md $md 2>/dev/null`	
    else
	dataToSend=`echo $downloadstr | openssl enc -nosalt -base64 $encType -pass pass:$enc_key -md $md 2>/dev/null`	
    fi
    echo $dataToSend | nc $host $port > $dirPath/ae_scan.sh_enc
    echo "Downloaded scan script"
    if [ "-aes-256-cbc" = "$encType" ]
    then
	if $verbose
        then
                echo "Going to decrypt data from probe using $encType"
        fi
	base64 -d $dirPath/ae_scan.sh_enc | openssl enc -d -aes-256-cbc -pass pass:$enc_key -md md5 -out $dirPath/ae_scan.sh 2>/dev/null
    else
	openssl enc -d -a $encType -in $dirPath/ae_scan.sh_enc -nosalt -pass pass:$enc_key -md $md -out $dirPath/ae_scan.sh 2>/dev/null	
    fi
    if [ $? -ne 0 ]
    then
        echo "Decrypt failed"
        exit 1
    fi
    echo "Decrypted scan script"
}
downloadScanScriptFromServer()
{
    echo "Going to download scan script from server"
    downloadstr="scanscript/ae_scan.sh"
    unamestr=`uname`
    if [ "Darwin" = "$unamestr" ]
    then
        downloadstr="scanscript/mac_ae_scan.sh"
    else
     if [ "AIX" = "$unamestr" ]
	 then
      downloadstr="scanscript/aix_ae_scan.sh"
     fi	  
    fi
	echo $serverUrl/$downloadstr
	curl -o $dirPath/ae_scan.sh $serverUrl/$downloadstr > "$dirPath/curlmessage.txt"  2>&1
	if [ $? -eq 0 ]
        then
            echo "Successfully downloaded scan script"
        else
            echo "Failed to download scan script"
            cat $dirPath/curlmessage.txt	
        fi
	rm -f $dirPath/curlmessage.txt
}
executeScript()
{
    bash $dirPath/ae_scan.sh $dirPath
}

uploadScanResult()
{
    if [ "-aes-256-cbc" = "$encType" ]
    then
	dataToSend=`echo "SCAN_RESULT" | openssl enc -base64 $encType -pass pass:$enc_key -md $md 2>/dev/null`
	openssl enc -base64 $encType -in $dirPath/scan_result.xml -md $md -pass pass:$enc_key -out $dirPath/scan_result.xml_enc 2>/dev/null
    else
	dataToSend=`echo "SCAN_RESULT" | openssl enc -nosalt -base64 $encType -pass pass:$enc_key -md $md 2>/dev/null`
	openssl enc -nosalt -base64 $encType -in $dirPath/scan_result.xml -md $md -pass pass:$enc_key -out $dirPath/scan_result.xml_enc 2>/dev/null
    fi
    echo "Encrypted scan result"

    echo $dataToSend > $dirPath/scan_result.enc
    
    cat $dirPath/scan_result.xml_enc >> $dirPath/scan_result.enc

    echo "Going to upload scan result to Probe"
	
    cat $dirPath/scan_result.enc | nc -w 1 $host $port
}
uploadScanResultToServer()
{
   hostfile=`hostname`
   unamestr=`uname`
   if [ "AIX" = "$unamestr" ]
   then
      mv $dirPath/scan_result.xml $dirPath/${hostfile}.xml
   else
      mv -v $dirPath/scan_result.xml $dirPath/${hostfile}.xml	   
   fi
   
   if $verbose 
   then
   	curl -v  -F "file=@"$dirPath/${hostfile}.xml  $serverUrl/agent/upload?$apiKey > "$dirPath/curlmessage.txt"  2>&1
        if [ $? -eq 0 ]
        then
	   echo "Successfully uploaded scan result to server" 
	   touch $last_scan
        else
	  echo "Problem while uploading to server"
        fi
	cat $dirPath/curlmessage.txt 
        rm -f $dirPath/curlmessage.txt
   else
  	 response=$(curl --write-out %{http_code} --silent --output a.txt -F "file=@"$dirPath/${hostfile}.xml  $serverUrl/agent/upload?$apiKey)
	  if [ $response -eq 200 ]
   	  then
        	 echo "Successfully uploaded scan result to server"
          	 touch $last_scan
   	  else
        	echo "Problem while uploading to server,error=$response"
         fi
   fi
}

checkAndDeleteFiles
if $agent
then
	if $canUpload
	then
		downloadScanScriptFromServer
		echo executing script
		executeScript
	        uploadScanResultToServer
	else
		 echo  Not uploading to server 
	fi	
else
	downloadScanScript
	executeScript
	uploadScanResult	
fi
checkAndDeleteFiles


