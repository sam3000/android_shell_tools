#!/bin/bash
timestart=$(date +%s);
filepath="root/";
filename="selinux";

if [ -f /media/sf_Desktop/$filename ]; then rm /media/sf_Desktop/$filename; fi;
if [ -d "$HOME/bin" ]; then PATH="$HOME/bin:$PATH"; fi;
cd /media/Android/;

echo "";
echo " [ Making the requested libraries ]";
echo "";
source ./build/envsetup.sh;
croot;
breakfast huashan;
make clean;
mmm ./external/sepolicy/;

timediff=$(($(date +%s)-$timestart));
cp /media/Android/out/target/product/huashan/$filepath$filename /media/sf_Desktop/$filename;
echo "";
echo "  \"adb push $filename /$filepath$filename\"";

while [ 1 ]
do
  echo "";
  echo " [ Upload new library files - Recovery / USB / mount system ]";
  echo "";
  printf "  Press enter to continue...";
  read key;

  echo "";
  cd /media/Android/out/target/product/huashan/;
  adb push $filepath$filename /$filepath$filename;
  echo "";
  echo " Rebooting...";
  sleep 5;
  adb reboot;

  echo "";
  echo " [ Done in $timediff secs ]";
  echo "";
  read key;
done;

