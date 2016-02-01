#!/bin/bash
ScriptDir=$PWD;
ScriptsDir=$ScriptDir;
FullTimeStart=$(date +%s);
BuildMode="$2";
source $ScriptsDir/android_set_variables.rc;
source $ScriptsDir/Bash/bash_huashan.rc;

# Dependencies Deletion
if ls "$AndroidDir/device/"*"/$PhoneName/"*.dependencies 1> /dev/null 2>&1; then
  rm "$AndroidDir/device/"*"/$PhoneName/"*.dependencies;
fi;

# System Output Cleaning
if [[ ! "$BuildMode" =~ "test" || "$BuildMode" =~ "wipe" ]] && [ -d "$OutDir/system" ]; then
  echo "";
  echo " [ System - Wiping /system output ]";
  rm -rf "$OutDir/system";
  echo "";
  echo "Output folder '/system' deleted";
  echo "";
fi;

# Sources Sync
if [[ ! "$BuildMode" =~ "test" && ! "$BuildMode" =~ "nosync" ]]; then
  echo "";
  echo " [ Syncing $PhoneName repositories ]";
  echo "";
  cd $AndroidDir/;
  reposa;
fi;

# ROM Build
BuildSuccess=0;
if [[ ! "$BuildMode" =~ "synconly" ]]; then
  cd $ScriptsDir/;
  source $ScriptsDir/android_brunch.sh "automatic";

  # ROM Successful
  if [ -f "$AndroidResult" ]; then
    BuildSuccess=1;
  fi;

  # ROM Upload
  if [[ ! "$BuildMode" =~ "local" ]]; then
    cd $ScriptsDir/;
    if [[ ! "$BuildMode" =~ "test" ]]; then
      source $ScriptsDir/android_server_upload.sh "$AndroidResult" "Huashan-CM-13.0" "automatic";
    else
      source $ScriptsDir/android_server_upload.sh "$AndroidResult" "Developers-ROMs" "automatic";
    fi;
    if [ $BuildSuccess ] && [[ "$BuildMode" =~ "rmoutdevice" ]] && [ -d "$OutDir" ]; then
      rm -rf "$OutDir/";
    fi;
  fi;
else
  BuildSuccess=1;
fi;

# Build Finished
FullTimeDiff=$(($(date +%s)-$FullTimeStart));
echo "";
if [ $BuildSuccess ]; then
  echo " [ Build : Success in $FullTimeDiff secs ]";
else
  echo " [ Build : Fail in $FullTimeDiff secs ]";
fi;
echo "";
if [ -z "$2" ]; then
  read key;
fi;