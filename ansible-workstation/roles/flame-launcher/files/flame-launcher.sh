#!/bin/bash

while getopts v:r:h flag
do
    case "${flag}" in
      v) version=${OPTARG};;
      r) remote=${OPTARG};;
      h) echo "Run with -v {flame version} -r true or false e.g. ./flame-launcher.sh -v 2024.2.2 -r true"
         exit 0;;
      *) echo "Invalid flag"; exit 1;;
    esac
done

# Ensure both -v and -r arguments are provided
if [ -z "$version" ] || [ -z "$remote" ]; then
  echo "Error: Both -v (version) and -r (remote) arguments are mandatory."
  echo "Usage: ./flame-launcher.sh -v {version} -r {true|false}"
  exit 1
fi

if [[ $remote == "true" ]];
then
  echo "Setting config to remote."
  config="Remote"
elif [[ -n $(/usr/sbin/lspci | grep Blackmagic) ]];
then
  echo "Setting config to BMD."
  config="BMD"
elif [[ -n $(/usr/sbin/lspci | grep AJA) ]];
then
  echo "Setting config to AJA."
  config="AJA"
else
  echo "No card detected. Setting remote audio only.";
  config="Remote"
fi

/usr/bin/cp /usr/local/flame_launcher/${config}.cfg /opt/Autodesk/flame_${version}/cfg/init.cfg
/opt/Autodesk/flame_${version}/bin/startApplication
