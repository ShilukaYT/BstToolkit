@echo off

echo Starting BlueStacks...
Start "" "C:\Program Files\BlueStacks_nxt\HD-Player.exe" --instance Nougat32 --hidden
timeout /t 20 >nul

echo Restarting ADB Server
adb kill-server
adb start-server

echo Connecting...
adb connect 127.0.0.1:5555

echo Installing SuperSU app
adb -s 127.0.0.1:5555 install common\Superuser.apk

echo Copying files to install SuperSU binary

adb -s 127.0.0.1:5555 shell mkdir /data/local/tmp/SuperSU >nul
adb -s 127.0.0.1:5555 push common\Superuser.apk /data/local/tmp/SuperSU >nul
adb -s 127.0.0.1:5555 push x86\su.pie /data/local/tmp/SuperSU >nul
adb -s 127.0.0.1:5555 push common\install-recovery.sh /data/local/tmp/SuperSU >nul
adb -s 127.0.0.1:5555 push x86\libsupol.so /data/local/tmp/SuperSU >nul
adb -s 127.0.0.1:5555 push x86\supolicy /data/local/tmp/SuperSU >nul

Echo Mounting system...
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c setenforce 0

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c mount -o rw,remount,rw /
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c mount -o rw,remount,rw /system
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c mount -o rw,remount,exec,rw /storage/emulated

echo Copying files to system...
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c mkdir /system/app/SuperSU
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c cp /data/local/tmp/SuperSU/Superuser.apk /system/app/SuperSU/SuperSU.apk
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c cp /data/local/tmp/SuperSU/su.pie /system/xbin/su
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c cp /data/local/tmp/SuperSU/su.pie /system/xbin/daemonsu
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c cp /data/local/tmp/SuperSU/install-recovery.sh /system/etc/install-recovery.sh
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c cp /data/local/tmp/SuperSU/libsupol.so /system/lib/libsupol.so
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c cp /data/local/tmp/SuperSU/supolicy /system/xbin/supolicy

echo Installing SuperSU binary...
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chmod 0644 /system/app/SuperSU/SuperSU.apk
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chcon u:object_r:system_file:s0 /system/app/SuperSU/SuperSU.apk

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chmod 0755 /system/etc/install-recovery.sh
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chcon u:object_r:toolbox_exec:s0 /system/etc/install-recovery.sh

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c ln -s /system/etc/install-recovery.sh /system/bin/install-recovery.sh

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chmod 0755 /system/xbin/su
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chcon u:object_r:system_file:s0 /system/xbin/su

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c mkdir /system/bin/.ext/

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chmod 0755 /system/xbin/daemonsu
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chcon u:object_r:system_file:s0 /system/xbin/daemonsu

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chmod 0755 /system/xbin/supolicy
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chcon u:object_r:system_file:s0 /system/xbin/supolicy

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chmod 0644 /system/lib/libsupol.so
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chcon u:object_r:system_file:s0 /system/lib/libsupol.so

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c cp /system/bin/app_process32 /system/bin/app_process32_original
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chmod 0755 /system/bin/app_process32_original
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chcon u:object_r:zygote_exec:s0 /system/bin/app_process32_original

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c cp /system/bin/app_process32 /system/bin/app_process_init
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chmod 0755 /system/bin/app_process_init
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c chcon u:object_r:zygote_exec:s0 /system/bin/app_process_init

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c rm -rf /system/bin/app_process
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c rm -rf /system/bin/app_process32

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c ln -s /system/xbin/daemonsu /system/bin/app_process

adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c ln -s /system/xbin/daemonsu /system/bin/app_process32

adb -s 127.0.0.1:5555 shell /system/xbin/su --install

echo Cleaning files...
adb -s 127.0.0.1:5555 shell /system/xbin/bstk/su -c rm -rR -f /data/local/tmp/SuperSU

echo Restarting BlueStacks...
Start "" /B adb -s 127.0.0.1:5555 reboot
adb disconnect 127.0.0.1:5555
timeout /t 10 >nul
taskkill /IM HD-Player.exe /F >nul
taskkill /IM BstkSVC.exe /F >nul
Start "" "C:\Program Files\BlueStacks_nxt\HD-Player.exe" --instance Nougat32 --cmd launchApp --package "eu.chainfire.supersu"
pause