#!/bin/bash
ScriptDir=$PWD;
TimeStart=$(date +%s);
source $ScriptDir/android_set_variables.rc;
ProjectPaths=("frameworks/base" \
              "packages/apps/Settings" \
              "hardware/libhardware" \
              #"device/sony/$PhoneName" \
              "hardware/sony/DASH" \
              #"kernel/sony/msm8x60" \
              "vendor/sony" \
              );

for ProjectPath in ${ProjectPaths[*]}
do

  echo "";
  echo "";
  echo " [ Rebasing $ProjectPath ]";
  echo "";

  cd $AndroidDir/$ProjectPath;
  git fetch github cm-12.1;
  git rebase github/cm-12.1;
  git push -f $UpstreamPrivate cm-12.1;

done;

TimeDiff=$(($(date +%s)-$TimeStart));
echo "";
echo "";
echo " [ Done in $TimeDiff secs ]";
echo "";
read key;
