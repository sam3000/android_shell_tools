#!/bin/bash
ScriptDir=$PWD;
ScriptsDir=$ScriptDir;
FullTimeStart=$(date +%s);
BuildMode="$2";

# Android Selection
function android_selection() { source ./android_choose_rom.sh 1 n n; }
android_selection;

# Development Scripts
source $ScriptsDir/android_set_variables.rc;


# Dependencies Deletion
if ls "$AndroidDir/device/"*"/$PhoneName/"*.dependencies 1> /dev/null 2>&1; then
  rm "$AndroidDir/device/"*"/$PhoneName/"*.dependencies;
fi;

# Sources Updates
if [[ ! "$BuildMode" =~ "test" && ! "$BuildMode" =~ "nosync" ]]; then
  cd $ScriptsDir/;
  #source $ScriptsDir/android_sync_github.sh "automatic";

  #if [ ! -z "$AndroidDev" ]; then
    #cd $ScriptsDir/;
    #source $ScriptsDir/android_rebase.sh "automatic";
  #fi;

  #cd $ScriptsDir/;
  #if [ ! -z "$AndroidForce" ]; then
  #  source $ScriptsDir/android_sync_force.sh "automatic";
  #else
  #  source $ScriptsDir/android_sync.sh "automatic";
  #fi;
fi;

# System Output Cleaning
if [[ "$BuildMode" =~ "clean" ]]; then
  echo "";
  echo " [ Cleaning outputs ]";
  echo "";
  cd $AndroidDir/;
  make clean;
elif [[ ! "$BuildMode" =~ "nowipe" ]] && [[ ! "$BuildMode" =~ "test" || "$BuildMode" =~ "wipe" ]] && [ -d "$OutDir/system" ]; then
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
  repo forall -c 'echo "Cleaning project ${REPO_PROJECT}"; \
                  git rebase --abort >/dev/null 2>&1; \
                  git stash -u >/dev/null 2>&1; \
                  git reset --hard HEAD >/dev/null 2>&1;';
  repo sync --current-branch --detach --force-broken --force-sync;

  # Additional changes
  cd $AndroidDir/packages/apps/Mms/;
  git fetch http://AdrianDC@review.cyanogenmod.org/a/CyanogenMod/android_packages_apps_Mms-caf refs/changes/75/129975/5 && git cherry-pick FETCH_HEAD;
fi;

# ROM Build
BuildSuccess="";
if [[ ! "$BuildMode" =~ "synconly" ]]; then
  cd $ScriptsDir/;
  android_selection;
  source $ScriptsDir/android_brunch.sh "automatic" "$BuildMode";

  # ROM Successful
  if [ -f "$AndroidResult" ]; then
    BuildSuccess="true";
  fi;

  # ROM Upload
  if [[ ! "$BuildMode" =~ "local" ]]; then
    cd $ScriptsDir/;
    if [[ ! "$BuildMode" =~ "test" ]]; then
      source $ScriptsDir/android_server_upload.sh "$AndroidResult" "Huashan/CyanogenMod-12.1" "automatic";
    else
      source $ScriptsDir/android_server_upload.sh "$AndroidResult" "Development" "automatic";
    fi;
    if [ ! -z "$BuildSuccess" ] && [[ "$BuildMode" =~ "rmoutdevice" ]] && [ -d "$OutDir" ]; then
      echo "";
      echo " [ $PhoneName - Removing output folder ]";
      echo "";
      TargetFile=$(basename "$AndroidResult");
      if [ -f "$TargetDir/$TargetFile" ]; then
        rm -f "$TargetDir/$TargetFile";
      fi;
      cp "$AndroidResult" "$TargetDir/$TargetFile";
      rm -rf "$OutDir/";
    fi;
  fi;
else
  BuildSuccess="true";
fi;

# Build Finished
FullTimeDiff=$(($(date +%s)-$FullTimeStart));
echo "";
if [ ! -z "$BuildSuccess" ]; then
  echo " [ Build : Success in $FullTimeDiff secs ]";
else
  echo " [ Build : Fail in $FullTimeDiff secs ]";
fi;
echo "";
if [ -z "$1" ]; then
  read key;
fi;
