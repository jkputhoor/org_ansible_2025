#!/bin/csh -f
echo $0

set i = `dirname "$0"`
cd "$i"
set j = `basename "$i"`
set dir = `dirname "$i"`

chmod -R 777 "${dir}/$j"



###### WIndows ####



###### Mac ####

# Step needed to grant AppleScript permissions to send events to Terminal


codesign --deep --force -v -s "RE: Vision Effects" -o runtime --entitlements=script.entitlements ./RVLDisplayStatusInTerminal.app
codesign --deep --force -v -s "RE: Vision Effects" -o runtime --entitlements=script.entitlements ./RVLDisplayStatusInSafari.app
codesign --deep --force -v -s "RE: Vision Effects" -o runtime --entitlements=script.entitlements ./RVLSetServerLocation.app


#Also lets try to notarize each .app
csh ../../../../../AppleNotarization/notarize.csh ./RVLDisplayStatusInTerminal.app
csh ../../../../../AppleNotarization/notarize.csh ./RVLDisplayStatusInSafari.app
csh ../../../../../AppleNotarization/notarize.csh ./RVLSetServerLocation.app





