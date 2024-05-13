#!/system/bin/sh
AGVARR="$@"; SCRIPT="$0"; AGV1="$1"; AGV2="$2"; AGV3="$3"; AGV4="$4"; AGV5="$5"; exec 2>/dev/null; MYSCRIPT="$(realpath "$0")"; MYPATH="${MYSCRIPT%/*}"; busybox="$MYPATH/libbusybox.so"; PATH="$MYPATH:$PATH:/sbin:/system/bin:/system/xbin"; cmds="$SCRIPT $AGVARR"


if [ ! -f "$MYPATH/libbusybox.so" ]; then
echo "Missing libbusybox.so"; exit 1
fi
chmod 775 "$MYPATH/"*

RC='\033[0m' RED='\033[0;31m' BRED='\033[1;31m' GRAY='\033[1;30m' BLUE='\033[0;34m' BBLUE='\033[1;34m' CYAN='\033[0;34m' CYAN='\033[1;34m' WHITE='\033[1;37m' GREEN='\033[0;32m' BGREEN='\033[1;32m' YELLOW='\033[1;33m' PURPLE='\033[0;35m' BPURPLE='\033[1;35m' ORANGE='\033[0;33m'

test -z "$USER_ID" && USER_ID="$(id -u)"

API=$(getprop ro.build.version.sdk)
  ABI=$(getprop ro.product.cpu.abi)
  if [ "$ABI" = "x86" ]; then
    ARCH=x86
    ABI32=x86
    IS64BIT=false
  elif [ "$ABI" = "arm64-v8a" ]; then
    ARCH=arm64
    ABI32=armeabi-v7a
    IS64BIT=true
  elif [ "$ABI" = "x86_64" ]; then
    ARCH=x64
    ABI32=x86
    IS64BIT=true
  else
    ARCH=arm
    ABI=armeabi-v7a
    ABI32=armeabi-v7a
    IS64BIT=false
  fi

DEVICE_API="$API"
DEVICE_ABI="$ABI"
DEVICE_ARCH="$ARCH"
DEVICE_ABI32="$ABI32"
DEVICE_64BIT="$IS64BIT"


SYSTEM_AS_ROOT=true
if mount | grep rootfs | grep -q " / " || mount | grep tmpfs | grep -q " / "; then
SYSTEM_AS_ROOT=false
fi

magisk_name="magisk32"
[ "$IS64BIT" == true ] && magisk_name="magisk64"

help(){
echo "Magisk Installer script for emulator
usage: inmagisk [OPTION]
Available option:
 install                       Open Menu for install Magisk
 install:<build>               Install/Update Magisk
 uninstall                     Uninstall Magisk and its modules"
}

ui_print(){ echo -e "$1"; }
cre(){
echo -ne "${GRAY}@$1${RC}"
}



text_press_enter_menu="PRESS ENTER TO BACK TO MENU"
text_cannot_mm="Cannot install or this app is adready installed"
text_success_mm="Install success!"
text_warn_uninstall_magisk="Do you want to uninstall Magisk?"
text_done="Done!"
text_saved_magisk_apk_to="Saved Magisk APK to"
text_mount_rw_system="Mount system partition (Read-write)"
text_mount_ro_system="Mount system partition (Read-only)"
text_obtain_root="Obtain ROOT access..."
text_obtain_root_failed="Cannot obtain ROOT access"
text_recommended="Recommended"
text_install_app="Install Magisk app"
text_install_app_sug="Please install Magisk app by yourself"
text_install="Install"
text_setup="Initialize Magisk Core"
text_rm_magisk_files="Cleaning trash files"
text_extract_magisk_apk="Extract Magisk APK"
text_failed_mount_system="Looks like the system partition is locked at read-only"
text_enter_magisk_apk="Enter path to your Magisk APK"
text_example="Example"
text_unpack_ramdisk="Unpack the ramdisk image"
text_unpack_ramdisk_fail="Unable to unpack the ramdisk image"
text_patch_ramdisk="Patching ramdisk image"
text_repack_ramdisk="Repack new ramdisk image"
text_repack_ramdisk_fail="Unable to repack new ramdisk image"
text_enter_path_ramdisk="Enter path to your ramdisk"
text_new_ramdisk="New ramdisk image was saved to"
text_uninstall_fail="! No Magisk found on system or GearLock"
text_cannot_mount_part="Unable to mount the partition!"
text_wrong_input="Wrong input, please enter again correctly"
text_enter_part="Enter the ${BGREEN}partition${RC} number where you got this ${BPURPLE}Android-x86 OS${RC} installed"
text_enter_ramdisk="Enter the ${BGREEN}ramdisk.img${RC} number from this ${BPURPLE}Android-x86 OS${RC}"
text_unpatch_ramdisk="Remove patch with magisk from ramdisk"
text_backup_not_exist="Backup not exist, cannot uninstall"
text_uninstall_magisk_in="Uninstall Magisk from system and GearLock"
text_restore_original_ramdisk="Restore ramdisk back to original"
text_choice=CHOICE
text_run_with_root="Run script with root access"
text_cannot_install_magisk="Unable to install Magisk!"
text_cannot_uninstall_magisk="Unable to uninstall Magisk!"
text_added_bs_module="Added Bluestacks Fix Magisk modules"
text_magisk_patched_ramdisk="Magisk patched ramdisk image detected"
text_saved_ramdisk_info="Saved ramdisk information to" 
text_unsupport_ramdisk_format="Unsupported ramdisk format"
text_tell_remove_rusty_magisk="You may have rust-magisk installed, please remove it if present!!!"
text_magisk_tmpfs_directory="Magisk tmpfs path"
text_use_current_ramdisk_info="Do you want to use the current ramdisk information"
text_install_gearlock="Please install GearLock first"
text_building_gxp="Build GearLock extension"
text_saved_magisk_gxp_to="Saved extension to"
text_uninstalling_magisk="Uninstall Magisk and its related files"
text_system_not_writeable="System is not writeable! Cannot completely uninstall."
text_grant_inter_access_permission="Please grant app the permission to access Internal Storage"
text_select_magisk_app="Select Magisk version you want to install"
text_guide_rm_magisk_app="Type \"rm\" with a number to delete target version"
text_ask_keep_modules="Do you want to preserve modules (Only remove Magisk)?"
text_cannot_detect_target_ramdisk="Unable to detect target ramdisk"
text_find_ramdisk_auto="It's difficult to detect target ramdisk correctly.
Do you want to automatically find the target ramdisk?"
text_enter_url="Custom link"

print_ramdisk_method(){
pd "light_cyan" "Install Magisk into ramdisk image"
echo "  1 - Direct install"
echo "  2 - Select ramdisk image and patch"
echo -n "[CHOICE]: "
}

print_unpatch_ramdisk(){
pd "light_cyan" "Remove Magisk in ramdisk"
echo "  1 - Direct uninstall"
echo "  2 - Select ramdisk image and patch"
echo -n "[CHOICE]: "
}

print_gxp_method(){
pd "light_cyan" "Install Magisk by using GearLock"
echo "  1 - Direct install"
echo "  2 - Export GearLock extension (GXP)"
echo -n "[CHOICE]: "
}

blissos_open_menu(){
echo -e "- If you are using ${BPURPLE}Bluestacks${RC} emulator"
echo -e "You can use ${BGREEN}BSTweaker 6.8.5+${RC} to enable Root access"

pd none "- If you are using ${BPURPLE}Android x86${RC} (BlissOS)"
pd none "You can press ${BGREEN}Alt+F1${RC} and type this command:"


}

print_info(){
p none "   Magisk: "; $hasMagisk && pd light_green "$(magisk -v) ($(magisk -V))" || pd light_red "Not installed"
p none "   Android Level: "; [ "$SDK" -lt "28" ] && pd light_red "$SDK" || pd light_green "$SDK"
p none "   System-as-root: "; [ "$SYSTEM_AS_ROOT" == "true" ] && pd light_green "$SYSTEM_AS_ROOT" || pd light_red "$SYSTEM_AS_ROOT"
}


warn_reboot(){
echo " The device will reboot after a few seconds"
  pd yellow " IF THE EMULATOR FREEZES, SIMPLY JUST REBOOT IT"
}

disable_magisk(){
[ -f "$DLPATH/disable" ] && p light_red "[ON]" || p light_red "[OFF]"
}

disable_magisk_process(){
[ -f "$DLPATH/disable" ] && rm -rf "$DLPATH/disable" || touch "$DLPATH/disable"
}

need_root_access(){

[ "$(whoami)" == "root" ] || abortc light_red "! Need root access to perform this action"
}

print_menu(){
pd gray  "=============================================="
echo "   Magisk Installer Script"
echo "   by HuskyDG (Modified by Hieu GL Lite)"
# please don't change this or use "by HuskyDG + your name" for credits :((
echo -e "$(print_info)"
pd gray "=============================================="
echo "  1 - Install/Update Magisk"
pd gray "      Integrate Magisk root into Android x86 emulator"
echo "  2 - Uninstall Magisk"
pd gray "      Remove Magisk and its modules"
echo "  3 - Install Magisk Modules Manager"
pd gray "      Module manager for Magisk"
echo "  4 - Remove all other root methods"
pd gray "      Only use if you cannot find Disable root option"
echo "----------"
echo " 0 - Exit menu"
p none "[CHOICE]: "
}

print_method(){
pd gray "=============================================="
echo "   Install/Update Magisk"
pd gray "=============================================="
pd light_cyan "Install Magisk method"
echo "  1 - Install Magisk into \"/system\""
pd gray "      The system partition must be mounted as read-write"
pd gray "      Recommended for Android Emulator such as NoxPlayer, MEmu, ..."
echo "  2 - Install Magisk into ramdisk image (systemless)"
pd gray "      Use this option if you can find ramdisk.img"
pd gray "      Do not support system-as-root"
echo "  3 - Install Magisk by using GearLock (system/systemless)"
pd gray "      Use GearLock to active Magisk"
pd gray "      Recommended for Android x86 project"
echo "  4 - Update binary file into \"/data\""
pd gray "      Update Magisk without having to modify system/ramdisk again"
pd gray "      Magisk must be installed by this script"
echo "----------"
if [ ! -z "$MAGISK_VER_CODE" ] && [ "$MAGISK_VER_CODE" -lt "23010" ]; then
echo "  m - Minimal Magisk mode: `p light_red "$MINIMAL_MAGISK"`"
pd gray "      Only MagiskSU and MagiskHide"
fi
echo "  0 - Exit menu"
pd light_red "* Note: Uninstall rusty-magisk to avoid conflicts"
p none "[CHOICE]: "

}

print_magisk_builds(){
echo "  1 - Canary `cre topjohnwu`"
echo "  2 - Alpha `cre vvb2060`"
echo "  3 - Canary v23001 `cre topjohnwu`"
echo "  4 - Stable v23.0 `cre topjohnwu`"
echo "  5 - Canary `cre TheHitMan7`"
echo "  e - $text_enter_url"
}


print_menu_install(){

pd gray "=============================================="
echo "   Install/Update Magisk"
pd gray "=============================================="
pd light_cyan "ONLINE"
print_magisk_builds
pd light_cyan "OFFLINE"
echo "  a - Stable v24.1"
echo "  x - Choose and install from another Magisk APK"
echo "  z - Select downloaded Magisk APK"
pd green "* Please check my wiki page to select suitable Magisk build"
p none "[CHOICE]: "

}




language_vn(){

text_press_enter_menu="PRESS ENTER TO BACK TO MENU"
text_cannot_mm="Cannot install or this app is adready installed"
text_success_mm="Install success!"
text_warn_uninstall_magisk="Do you want to uninstall Magisk?"
text_done="Done!"
text_saved_magisk_apk_to="Saved Magisk APK to"
text_mount_rw_system="Mount system partition (Read-write)"
text_mount_ro_system="Mount system partition (Read-only)"
text_obtain_root="Obtain ROOT access..."
text_obtain_root_failed="Cannot obtain ROOT access"
text_recommended="Recommended"
text_install_app="Install Magisk app"
text_install_app_sug="Please install Magisk app by yourself"
text_install="Install"
text_setup="Initialize Magisk Core"
text_rm_magisk_files="Cleaning trash files"
text_extract_magisk_apk="Extract Magisk APK"
text_failed_mount_system="Looks like the system partition is locked at read-only"
text_enter_magisk_apk="Enter path to your Magisk APK"
text_example="Example"
text_unpack_ramdisk="Unpack the ramdisk image"
text_unpack_ramdisk_fail="Unable to unpack the ramdisk image"
text_patch_ramdisk="Patching ramdisk image"
text_repack_ramdisk="Repack new ramdisk image"
text_repack_ramdisk_fail="Unable to repack new ramdisk image"
text_enter_path_ramdisk="Enter path to your ramdisk"
text_new_ramdisk="New ramdisk image was saved to"
text_uninstall_fail="! No Magisk found on system or GearLock"
text_cannot_mount_part="Unable to mount the partition!"
text_wrong_input="Wrong input, please enter again correctly"
text_enter_part="Enter the ${BGREEN}partition${RC} number where you got this ${BPURPLE}Android-x86 OS${RC} installed"
text_enter_ramdisk="Enter the ${BGREEN}ramdisk.img${RC} number from this ${BPURPLE}Android-x86 OS${RC}"
text_unpatch_ramdisk="Remove patch with magisk from ramdisk"
text_backup_not_exist="Backup not exist, cannot uninstall"
text_uninstall_magisk_in="Uninstall Magisk from system and GearLock"
text_restore_original_ramdisk="Restore ramdisk back to original"
text_choice=CHOICE
text_run_with_root="Run script with root access"
text_cannot_install_magisk="Unable to install Magisk!"
text_cannot_uninstall_magisk="Unable to uninstall Magisk!"
text_added_bs_module="Added Bluestacks Fix Magisk modules"
text_magisk_patched_ramdisk="Magisk patched ramdisk image detected"
text_saved_ramdisk_info="Saved ramdisk information to" 
text_unsupport_ramdisk_format="Unsupported ramdisk format"
text_tell_remove_rusty_magisk="You may have rust-magisk installed, please remove it if present!!!"
text_magisk_tmpfs_directory="Magisk tmpfs path"
text_use_current_ramdisk_info="Do you want to use the current ramdisk information"
text_install_gearlock="Please install GearLock first"
text_building_gxp="Build GearLock extension"
text_saved_magisk_gxp_to="Saved extension to"
text_uninstalling_magisk="Uninstall Magisk and its related files"
text_system_not_writeable="System is not writeable! Cannot completely uninstall."
text_grant_inter_access_permission="Please grant app the permission to access Internal Storage"
text_select_magisk_app="Select Magisk version you want to install"
text_guide_rm_magisk_app="Type \"rm\" with a number to delete target version"
text_ask_keep_modules="Do you want to preserve modules (Only remove Magisk)?"
text_cannot_detect_target_ramdisk="Unable to detect target ramdisk"
text_find_ramdisk_auto="It's difficult to detect target ramdisk correctly.
Do you want to automatically find the target ramdisk?"
text_enter_url="Custom link"
need_root_access(){

[ "$(whoami)" == "root" ] || abortc light_red "! Cần quyền truy cập root để thực hiện hành động này"
}


print_ramdisk_method(){
pd "light_cyan" "Cài đặt Magisk vào đĩa ảnh ramdisk"
echo "  1 - Cài đặt trực tiếp"
echo "  2 - Chọn đĩa ảnh ramdisk và vá"
echo -n "[CHỌN]: "
}

print_gxp_method(){
pd "light_cyan" "Cài đặt Magisk bằng GearLock"
echo "  1 - Cài đặt trực tiếp"
echo "  2 - Tạo tệp mở rộng GearLock (GXP)"
echo -n "[CHỌN]: "
}

print_unpatch_ramdisk(){
pd "light_cyan" "Loại bỏ Magisk khỏi ramdisk"
echo "  1 - Gỡ cài đặt trực tiếp"
echo "  2 - Chọn đĩa ảnh ramdisk và vá"
echo -n "[CHỌN]: "
}



warn_reboot(){
echo " Thiết bị sẽ khởi động trong vài giây nữa"
echo " NẾU HỆ THỐNG KHÔNG PHẢN HỒI, VUI LÒNG KHỞI ĐỘNG LẠI"
}

print_menu(){
pd gray  "=============================================="
echo "   Magisk on Android x86"
echo "   by HuskyDG"
# please don't change this or use "by HuskyDG + your name" for credits :((
echo -e "$(print_info)"
pd gray "=============================================="
echo "  1 - Cài đặt hoặc cập nhật Magisk"
pd gray "      Triển khai Magisk root vào Android-x86"
echo "  2 - Gỡ cài đặt Magisk"
pd gray "      Loại bỏ Magisk và các mô-đun của nó"
echo "  3 - Cài đặt trình quản lí Magisk mô-đun"
pd gray "      Quản lí mô-đun thay thế cho Magisk"
echo "  4 - Loại bỏ các phương pháp ROOT khác"
pd gray "      Chỉ sử dụng khi bạn không tìm thấy tùy chọn để tắt Root"
echo "----------"
echo " 0 - Thoát khỏi menu"
p none "[CHỌN]: "
}

blissos_open_menu(){
echo -e "- Nếu bạn đang sử dụng giả lập ${BPURPLE}Bluestacks${RC}"
echo -e "Bạn có thể sử dụng ${BGREEN}BSTweaker 6.8.5+${RC} để bật quyền Root"

pd none "- Nếu bạn đang sử dụng ${BPURPLE}Android x86${RC} như BlissOS";
pd none "Bạn có thể nhấn ${BGREEN}ALT+F1${RC} và gõ dòng lệnh:"
}

print_menu_install(){

pd gray "=============================================="
echo "   Install/Update Magisk"
pd gray "=============================================="
pd light_cyan "TRỰC TUYẾN"
print_magisk_builds
pd light_cyan "NGOẠI TUYẾN"
echo "  a - Stable v24.1"
echo "  x - Chọn và cài đặt từ Magisk APK khác"
echo "  z - Chọn phiên bản Magisk APK đã tải"
pd green "* Vui lòng kiểm tra trang wiki của tôi để chọn bản dựng Magisk phù hợp"
p none "[CHỌN]: "

}

print_method(){
pd gray "=============================================="
echo "   Cài đặt hoặc cập nhật Magisk"
pd gray "=============================================="
pd light_cyan "Phương thức cài đặt Magisk"
echo "  1 - Cài đặt Magisk vào \"/system\""
pd gray "      Phân vùng hệ thống có thể gắn kết đọc ghi"
pd gray "      Khuyên dùng cho các giả lập Android như NoxPlayer, MEmu, ..."
echo "  2 - Cài đặt Magisk vào ramdisk.img (systemless)"
pd gray "      Sử dụng tùy chọn này nếu bạn tìm thấy Ramdisk"
pd gray "      Không hỗ trợ system-as-root"
echo "  3 - Cài đặt Magisk bằng GearLock (system/systemless)"
pd gray "      Cần có GearLock, sử dụng GearLock để kích hoạt Magisk"
pd gray "      Khuyên dùng cho Android x86 project"
echo "  4 - Cập nhật nhị phân vào trong \"/data\""
pd gray "      Cập nhật Magisk mà không cần phải sửa đổi lại hệ thống hoặc ramdisk.img"
pd gray "      Magisk phải được cài đặt bởi script này"
echo "----------"
if [ ! -z "$MAGISK_VER_CODE" ] && [ "$MAGISK_VER_CODE" -lt "23010" ]; then
echo "  m - Minimal Magisk mode: `p light_red "$MINIMAL_MAGISK"`"
pd gray "      Chỉ có MagiskSU và MagiskHide"
fi
echo "  0 - Thoát khỏi menu"
pd light_red "* Lưu ý: Gỡ bỏ rusty-magisk để tránh bị xung đột"
p none "[CHỌN]: "

}




}


LANGUAGE="$(getprop persist.sys.locale)"
case "$LANGUAGE" in
"vi-VN")
    language_vn
    ;;
esac




mount_rw_system(){
IS_SYSTEM_MOUNT=false
if mount | grep rootfs | grep -q " / " || mount | grep tmpfs | grep -q " / "; then
# legacy rootfs
mount -o rw,remount "/system" && IS_SYSTEM_MOUNT=true
else
# system-as-root, mount "/"
mount -o rw,remount "/" && IS_SYSTEM_MOUNT=true
fi
}

mount_ro_system(){
IS_SYSTEM_MOUNT=false
if mount | grep rootfs | grep -q " / " || mount | grep tmpfs | grep -q " / "; then
# legacy rootfs
mount -o ro,remount "/system" && IS_SYSTEM_MOUNT=true
else
# system-as-root, mount "/"
mount -o ro,remount "/" && IS_SYSTEM_MOUNT=true
fi
}



p(){
COLOR=$1;TEXT="$2";escape="$1"
[ "$COLOR" == "black" ] && escape="0;30"
[ "$COLOR" == "red" ] && escape="0;31"
[ "$COLOR" == "green" ] && escape="0;32"
[ "$COLOR" == "orange" ] && escape="0;33"
[ "$COLOR" == "blue" ] && escape="0;34"
[ "$COLOR" == "purple" ] && escape="0;35"
[ "$COLOR" == "cyan" ] && escape="0;36"
[ "$COLOR" == "light_gray" ] && escape="0;37"
[ "$COLOR" == "gray" ] && escape="1;30"
[ "$COLOR" == "light_red" ] && escape="1;31"
[ "$COLOR" == "light_green" ] && escape="1;32"
[ "$COLOR" == "yellow" ] && escape="1;33"
[ "$COLOR" == "light_blue" ] && escape="1;34"
[ "$COLOR" == "light_purple" ] && escape="1;35"
[ "$COLOR" == "light_cyan" ] && escape="1;36"
[ "$COLOR" == "white" ] && escape="1;37"
[ "$COLOR" == "none" ] && escape="0"
code="\033[${escape}m"
end_code="\033[0m"
echo -en "$code$TEXT$end_code"
}


pd(){
p "$1" "$2"; echo
}





abortc(){
ERR_CODE="$3"
pd "$1" "$2"; 
test -z "$ERR_CODE" && ERR_CODE=1
exit "$ERR_CODE"
}

if [ "$AGV1" != "noexec" ]; then

priv_dir=/data/local/tmp/Magisk
cd "$priv_dir"
DLPATH="$priv_dir/magisk"

if [ ! -d "$DLPATH" ]; then
rm -rf "$DLPATH" 2>/dev/null
mkdir -p "$DLPATH" 2>/dev/null
fi

mkdir "$DLPATH/save"

link(){ (
agv1="$1"; agv2="$2"
[ ! -f "$DLPATH/$agv2" ] && rm -rf "$DLPATH/$agv2" 2>/dev/null
ln -s "$(which "$agv1")" "$DLPATH/$agv2" 2>/dev/null
) }

link "libapp.so" "magisk.apk"
link "libbusybox.so" "busybox"
link "liblegacy.so" "legacy.zip"
link "libbash.so" "menu"
link "libgxp.so" "gearlock_extension.zip"

CACHEDIR="$priv_dir/cache/$$"
DISKINFO="/data/adb/diskinfo"
APKFILE="$JOBPWD/magisk.apk"
MAGISKCORE="/system/etc/magisk"

busybox_bin(){
mkdir -p "$DLPATH/bin"
"$busybox" busybox --install -s "$DLPATH/bin"
PATH="$DLPATH/bin:$PATH"
}
hasMagisk=false
[ ! -z "$(which magisk)" ] && [ ! -z "$(magisk -v)" ] && hasMagisk=true
busybox_bin 2>/dev/null


open_main(){
if [ "$AGV1" == "option" ] && [ "$AGV2" == "help" ]; then
help; exit
fi
if [ "$USER_ID" != "0" ]; then
    p none "$text_run_with_root ? <Y/n> "
    read ROOT
    if [ "$ROOT" == "Y" -o "$ROOT" == "y" ]; then
    export UNSHARE_MM=0
    export ASH_STANDALONE=1
        pd yellow "$text_obtain_root..."
        ( su -c "$cmds" || /system/xbin/su -c "$cmds" || /system/bin/su -c "$cmds" || /sbin/su -c "$cmds" ) 2>/dev/null
        ERR_CODE="$?"
        if [ "$ERR_CODE" != 0 ]; then
            
            pd "light_red" "$text_obtain_root_failed"
            blissos_open_menu
            pd light_cyan "/data/data/io.github.huskydg.magiskonnox/magisk/menu"
            
        fi
        exit 
    elif ! [ "$ROOT" == "N" -o "$ROOT" == "n" ]; then
        exit
    fi
fi
while true; do 
main; 
done
}

fi

SDK="$(getprop ro.build.version.sdk)"

function cmdline() { 
	awk -F"${1}=" '{print $2}' < /proc/cmdline | cut -d' ' -f1 2> /dev/null
}

get_magisk_path(){

MAGISK_TMP="$(magisk --path)"
MAGISKDIR="$MAGISK_TMP/.magisk"
[ "$MAGISK_TMP" ] && MAGISK_MIRROR="$MAGISKDIR/mirror"
# SYSTEMDIR="/system"
# SYSTEMROOTDIR="/"
# [ "$MAGISK_TMP" ] && SYSTEMROOTDIR="/system_root"

# umount to make sure there are no magisk module mount on these folder

( umount -l /system/etc
umount -l /system/etc/*
umount -l /system/addon.d
umount -l /system/addon.d/*
umount -l /system/etc/magisk
umount -l /system/etc/init
umount -l /system/etc/magisk/*
umount -l /system/etc/init/* 
umount -l /magisk
umount -l /magisk/*
 ) &

# no need to use Magisk's mirror anymore

SYSTEMDIR="/system"
SYSTEMROOTDIR="/"

}



# This script is write by HuskyDG
ARG1="$1"
JOBPWD="${0%/*}"
bb=/data/local/tmp/busybox

get_tmpdir(){

TMPDIR="$CACHEDIR"
[ "$USER_ID" == "0" ] && TMPDIR=/dev/tmp

}
get_tmpdir

abort(){
ERR_CODE="$2"
echo "$1"; 
test -z "$ERR_CODE" && ERR_CODE=1
exit "$ERR_CODE"
}





gxp_template="$DLPATH/gearlock_extension.zip"

unshare_environment(){
if [ ! "$UNSHARE_MM" == "1" ]; then
export UNSHARE_MM=1
export ASH_STANDALONE=1
"$busybox" unshare -m "$busybox" sh -o standalone "$SCRIPT" "$AGV1" "$AGV2" "$AGV3" "$AGV4" "$AGV5"
exit
fi
}

[ "$USER_ID" == "0" ] && unshare_environment 2>/dev/null

[ "$USER_ID" == "0" ] && get_magisk_path

ISENCRYPTED=false
  grep ' /data ' /proc/mounts | grep -q 'dm-' && ISENCRYPTED=true
  [ "$(getprop ro.crypto.state)" = "encrypted" ] && ISENCRYPTED=true

canary_v23001_magisk_link="https://github.com/topjohnwu/magisk-files/blob/4f737b70868eb3f8b71e48518f919819cbf5ad63/app-debug.apk?raw=true"
stable_magisk_link="https://github.com/topjohnwu/Magisk/releases/download/v23.0/Magisk-v23.0.apk"
canary_magisk_link="https://github.com/topjohnwu/magisk-files/blob/canary/app-debug.apk?raw=true"
alpha_magisk_link="https://github.com/vvb2060/magisk_files/blob/alpha/app-release.apk?raw=true"
lite_magisk_link="https://github.com/vvb2060/magisk_files/blob/master/app-release.apk?raw=true"


clean_flash(){
umount -l "$TMPDIR"
rm -rf "$TMPDIR"
}

turn_back(){
p yellow "$text_press_enter_menu"
read
}

random(){
VALUE=$1; TYPE=$2; PICK="$3"; PICKC="$4"
TMPR=""
HEX="0123456789abcdef"; HEXC=16
CHAR="qwertyuiopasdfghjklzxcvbnm"; CHARC=26
NUM="0123456789"; NUMC=10
COUNT=$(seq 1 1 $VALUE)
list_pick=$HEX; C=$HEXC
[ "$TYPE" == "char" ] &&  list_pick=$CHAR && C=$CHARC 
[ "$TYPE" == "number" ] && list_pick=$NUM && C=$NUMC 
[ "$TYPE" == "custom" ] && list_pick="$PICK" && C=$PICKC 
      for i in $COUNT; do
          random_pick=$(( $RANDOM % $C))
          echo -n ${list_pick:$random_pick:1}
      done

}

random_str(){
random_length=$(random 1 custom 56789 5);
random $random_length custom "qwertyuiopasdfghjklzxcvbnm0123456789QWERTYUIOPASDFGHJKLZXCVBNM" 63 | base64 | sed "s/=//g"
}




magisk_loader(){

MAGISKTMP_TYPE="$1"
test -z "$MAGISKTMP_TYPE" && MAGISKTMP_TYPE=1
MAGISKTMP=/sbin

[ "$MAGISK_IN_DEV" == "1" -o "$MAGISK_IN_DEV" == "true" ] && MAGISKTMP_TYPE=3

magisk_overlay=`random_str`
magisk_postfsdata=`random_str`
magisk_service=`random_str`
magisk_daemon=`random_str`
magisk_boot_complete=`random_str`
magisk_loadpolicy=`random_str`
dev_random=`random_str`

case "$MAGISKTMP_TYPE" in
1)
    #legacy rootfs
    mount_sbin="mount -o rw,remount /
rm -rf /.backup_sbin
mkdir /.backup_sbin
ln /sbin/* /.backup_sbin
mnt_tmpfs /sbin
clone /.backup_sbin /sbin"
    remove_backup="
rm -rf /.backup_sbin 
mount -o ro,remount /"
    ;;
2)
     #system-as-root
     mount_sbin="overlay /sbin"
     ;;
3)
     #system-as-root, /sbin is removal
     MAGISKTMP="/dev/$dev_random"
     mount_sbin="mkdir -p \"$MAGISKTMP\"
mnt_tmpfs \"$MAGISKTMP\""
     ;;
esac

LOAD_MODULES_POLICY="for module in \$(ls /data/adb/modules); do
              if ! [ -f \"/data/adb/modules/\$module/disable\" ] && [ -f \"/data/adb/modules/\$module/sepolicy.rule\" ]; then
                  echo \"## * module sepolicy: \$module\" >>\"\$MAGISKTMP/.magisk/sepolicy.rules\"
                  cat  \"/data/adb/modules/\$module/sepolicy.rule\" >>\"\$MAGISKTMP/.magisk/sepolicy.rules\"
                  echo \"\" >>\"\$MAGISKTMP/.magisk/sepolicy.rules\"
                  
              fi
          done
\$MAGISKTMP/magiskpolicy --live --apply \"\$MAGISKTMP/.magisk/sepolicy.rules\""

unset LOG_MAGISK
unset FORCE_MAGISKHIDE
unset ADD_FORCE_MAGISKHIDE
CDMAGISKUPDATE="[ -d \"/data/.magisk_binary\" ] && cd /data/.magisk_binary
chcon u:object_r:app_data_file:s0 /data/.magisk_binary"
RM_RUSTY_MAGISK="#remove rusty-magisk to make sure it is not conflicted
              exec u:r:su:s0 -- rm -rf /data/.rusty-magisk
              rm /data/.rusty-magisk/magisk.apk
              rm /data/.rusty-magisk/magisk
              rm /data/ghome/.local/bin/rusty-magisk"

ADDITIONAL_SCRIPT="( # addition script
rm -rf /data/adb/post-fs-data.d/fix_mirror_mount.sh
rm -rf /data/adb/service.d/fix_modules_not_show.sh
rm -rf /data/adb/service.d/hide_modified_initrc.sh
echo \"
SCRIPT=\\\"\\\$0\\\"
( #fix bluestacks
MIRROR_SYSTEM=\\\"\$MAGISKTMP/.magisk/mirror/system\\\"
test ! -d \\\"\\\$MIRROR_SYSTEM/android/system\\\" && exit
test \\\"\\\$(cd /system; ls)\\\" == \\\"\\\$(cd \\\"\\\$MIRROR_SYSTEM\\\"; ls)\\\" && exit
mount --bind \\\"\\\$MIRROR_SYSTEM/android/system\\\" \\\"\\\$MIRROR_SYSTEM\\\" )
( #fix mount data mirror
function cmdline() { 
	awk -F\\\"\\\${1}=\\\" '{print \\\$2}' < /proc/cmdline | cut -d' ' -f1 2> /dev/null
}
SRC=\\\"\\\$(cmdline SRC)\\\"
test -z \\\"\\\$SRC\\\" && exit
LIST_TEST=\\\"
/data
/data/adb
/data/adb/magisk
/data/adb/modules
\\\"
count=0
for folder in \\\$LIST_TEST; do
test \\\"\\\$(ls -A \$MAGISKTMP/.magisk/mirror/\\\$folder 2>/dev/null)\\\" == \\\"\\\$(ls -A \\\$folder 2>/dev/null)\\\" && count=\\\$((\\\$count + 1))
done
test \\\"\\\$count\\\" == 4 && exit
count=0
for folder in \\\$LIST_TEST; do
test \\\"\\\$(ls -A \$MAGISKTMP/.magisk/mirror/data/\\\$SRC/\\\$folder 2>/dev/null)\\\" == \\\"\\\$(ls -A \\\$folder 2>/dev/null)\\\" && count=\\\$((\\\$count + 1))
done
if [ \\\"\\\$count\\\" == 4 ]; then
mount --bind \\\"\$MAGISKTMP/.magisk/mirror/data/\\\$SRC/data\\\" \\\"\$MAGISKTMP/.magisk/mirror/data\\\"
fi )
rm -rf \\\"\\\$SCRIPT\\\"
\" >/data/adb/post-fs-data.d/fix_mirror_mount.sh
echo \"
SCRIPT=\\\"\\\$0\\\"
while [ \\\"\\\$(\$MAGISKTMP/magisk resetprop sys.boot_completed)\\\" != \\\"1\\\" ]
  do
    sleep 1
  done
sleep 3
LIST=\\\"
$magisk_postfsdata
$magisk_service
$magisk_daemon
$magisk_boot_complete
$magisk_loadpolicy
$magisk_overlay
\\\"
for service in \\\$LIST; do
\$MAGISKTMP/magisk resetprop --delete init.svc.\\\$service
\$MAGISKTMP/magisk resetprop --delete init.svc_debug_pid.\\\$service
done
rm -rf \\\"\\\$SCRIPT\\\"\" >/data/adb/service.d/hide_modified_initrc.sh
echo \"
SCRIPT=\\\"\\\$0\\\"
CHECK=\\\"/data/adb/modules/.mk_\\\$RANDOM\\\$RANDOM\\\"
touch \\\"\\\$CHECK\\\"
test \\\"\\\$(ls -A \$MAGISKTMP/.magisk/modules 2>/dev/null)\\\" != \\\"\\\$(ls -A /data/adb/modules 2>/dev/null)\\\" && mount --bind \$MAGISKTMP/.magisk/mirror/data/adb/modules \$MAGISKTMP/.magisk/modules
rm -rf \\\"\\\$CHECK\\\"
rm -rf \\\"\\\$SCRIPT\\\"\" >/data/adb/service.d/fix_modules_not_show.sh
chmod 755 /data/adb/service.d/hide_modified_initrc.sh
chmod 755 /data/adb/service.d/fix_modules_not_show.sh
chmod 755 /data/adb/post-fs-data.d/fix_mirror_mount.sh; )"

if [ "$MINIMAL_MAGISK" == "true" ]; then
LOAD_MODULES_POLICY=""
ADDITIONAL_SCRIPT=""
ADD_FORCE_MAGISKHIDE="mkdir -p $MAGISKTMP/.magisk/modules
mkdir -p /data/adb/modules_minimal/force_magiskhide
mount --bind /data/adb/modules_minimal $MAGISKTMP/.magisk/modules
echo \"id=force_magiskhide
name=Force Enable MagiskHide
version=v1.0
versionCode=10000
author=HuskyDG
description=Always enable MagiskHide whenever MagiskHide cannot persist after restart\" >/data/adb/modules_minimal/force_magiskhide/module.prop"
FORCE_MAGISKHIDE="rm -rf /data/adb/modules_minimal/force_magiskhide/remove
if [ ! -f \"/data/adb/modules_minimal/force_magiskhide/disable\" ]; then 
$MAGISKTMP/magisk magiskhide disable
$MAGISKTMP/magisk magiskhide enable
fi
[ -f \"/data/adb/modules_minimal/hosts/remove\" ] && rm -rf /data/adb/modules_minimal/hosts
rm -rf /data/adb/modules_minimal/hosts/update
[ ! -f \"/data/adb/modules_minimal/hosts/disable\" ] && mount --bind $MAGISKTMP/.magisk/modules/hosts/system/etc/hosts /system/etc/hosts
"
unset CDMAGISKUPDATE
fi


overlay_loader="#!$MAGISKBASE/busybox sh

export PATH=/sbin:/system/bin:/system/xbin


mnt_tmpfs(){ (
# MOUNT TMPFS ON A DIRECTORY
MOUNTPOINT=\"\$1\"
mkdir -p \"\$MOUNTPOINT\"
mount -t tmpfs -o \"mode=0755\" tmpfs \"\$MOUNTPOINT\" 2>/dev/null
) }



mnt_bind(){ (
# SHORTCUT BY BIND MOUNT
FROM=\"\$1\"; TO=\"\$2\"
if [ -L \"\$FROM\" ]; then
SOFTLN=\"\$(readlink \"\$FROM\")\"
ln -s \"\$SOFTLN\" \"\$TO\"
elif [ -d \"\$FROM\" ]; then
mkdir -p \"\$TO\" 2>/dev/null
mount --bind \"\$FROM\" \"\$TO\"
else
echo -n 2>/dev/null >\"\$TO\"
mount --bind \"\$FROM\" \"\$TO\"
fi
) }

clone(){ (
FROM=\"\$1\"; TO=\"\$2\"; IFS=\$\"
\"
[ -d \"\$TO\" ] || exit 1;
( cd \"\$FROM\" && find * -prune ) | while read obj; do
( if [ -d \"\$FROM/\$obj\" ]; then
mnt_tmpfs \"\$TO/\$obj\"
else
mnt_bind \"\$FROM/\$obj\" \"\$TO/\$obj\" 2>/dev/null
fi ) &
sleep 0.05
done
) }

overlay(){ (
# RE-OVERLAY A DIRECTORY
FOLDER=\"\$1\";
TMPFOLDER=\"/dev/vm-overlay\"
#_____
PAYDIR=\"\${TMPFOLDER}_\${RANDOM}_\$(date | base64)\"
mkdir -p \"\$PAYDIR\"
mnt_tmpfs \"\$PAYDIR\"
#_________
clone \"\$FOLDER\" \"\$PAYDIR\"
mount --move \"\$PAYDIR\" \"\$FOLDER\"
rm -rf \"\$PAYDIR\"
#______________
) }

exit_magisk(){
echo -n >/dev/.magisk_unblock
}


API=\$(getprop ro.build.version.sdk)
  ABI=\$(getprop ro.product.cpu.abi)
  if [ \"\$ABI\" = \"x86\" ]; then
    ARCH=x86
    ABI32=x86
    IS64BIT=false
  elif [ \"\$ABI\" = \"arm64-v8a\" ]; then
    ARCH=arm64
    ABI32=armeabi-v7a
    IS64BIT=true
  elif [ \"\$ABI\" = \"x86_64\" ]; then
    ARCH=x64
    ABI32=x86
    IS64BIT=true
  else
    ARCH=arm
    ABI=armeabi-v7a
    ABI32=armeabi-v7a
    IS64BIT=false
  fi

magisk_name=\"magisk32\"
[ \"\$IS64BIT\" == true ] && magisk_name=\"magisk64\"

# umount previous /sbin tmpfs overlay

count=0
( magisk --stop ) &

umount -l /init.rc
umount -l /system/etc/init/hw/init.rc

until ! mount | grep -q \" /sbin \"; do
[ "$count" -gt "10" ] && break
umount -l /sbin 2>/dev/null
sleep 0.1
count=$(($count+1))
test ! -d /sbin && break
done

$mount_sbin


chcon u:r:rootfs:s0 /sbin

[ -f \"/data/.magisk_binary/remove\" ] && rm -rf \"/data/.magisk_binary\"

cd $MAGISKBASE
$CDMAGISKUPDATE 

test ! -f \"./\$magisk_name\" && { echo -n >/dev/.overlay_unblock; exit_magisk; exit 0; }

MAGISKTMP=$MAGISKTMP
MAGISKBIN=/data/adb/magisk
mkdir -p \$MAGISKBIN 2>/dev/null
for mdir in modules post-fs-data.d service.d; do
test ! -d /data/adb/\$mdir && rm -rf /data/adb/\$mdir
mkdir /data/adb/\$mdir 2>/dev/null
done
for file in magisk32 magisk64 magiskinit; do
  cp -af ./\$file \$MAGISKTMP/\$file 2>/dev/null
  chmod 755 \$MAGISKTMP/\$file
  TEXT_LOG=\"add \$MAGISKBIN/\$file\"
  cp -af ./\$file \$MAGISKBIN/\$file 2>/dev/null
  chmod 755 \$MAGISKBIN/\$file
done
cp -af ./magiskboot \$MAGISKBIN/magiskboot
cp -af ./busybox \$MAGISKBIN/busybox
cp -af ./loadpolicy.sh \$MAGISKTMP
cp -af ./assets/* \$MAGISKBIN



ln -s ./\$magisk_name \$MAGISKTMP/magisk 2>/dev/null
ln -s ./magisk \$MAGISKTMP/su 2>/dev/null
ln -s ./magisk \$MAGISKTMP/resetprop 2>/dev/null
ln -s ./magisk \$MAGISKTMP/magiskhide 2>/dev/null
ln -s ./magiskinit \$MAGISKTMP/magiskpolicy 2>/dev/null

mkdir -p \$MAGISKTMP/.magisk/mirror
mkdir \$MAGISKTMP/.magisk/block
touch \$MAGISKTMP/.magisk/config
$ADD_FORCE_MAGISKHIDE

cd \$MAGISKTMP
# SELinux stuffs
ln -sf ./magiskinit magiskpolicy
if [ -f /vendor/etc/selinux/precompiled_sepolicy ]; then
  ./magiskpolicy --load /vendor/etc/selinux/precompiled_sepolicy --live --magisk 2>&1
elif [ -f /sepolicy ]; then
  ./magiskpolicy --load /sepolicy --live --magisk 2>&1
else
  ./magiskpolicy --live --magisk 2>&1
fi

#remount system read-only
$remove_backup
mount -o ro,remount /
mount -o ro,remount /system
mount -o ro,remount /vendor
mount -o ro,remount /product
mount -o ro,remount /system_ext

restorecon -R /data/adb/magisk

$ADDITIONAL_SCRIPT
$LOAD_MODULES_POLICY

touch /dev/.overlay_unblock
UID_MYAPP=\$(ls -ld \"$priv_dir\" | awk '{ print \$3 }') || UID_MYAPP=root
chown \$UID_MYAPP:\$UID_MYAPP /data/.magisk_binary
rm -rf /dev/.overlay_unblock
sleep 3

[ ! -f \"\$MAGISKTMP/magisk\" ] && exit_magisk
# test ! \"\$(pidof magiskd)\" && exit_magisk

( while [ \"\$(getprop sys.boot_completed)\" != \"1\" ]
  do
    sleep 1
  done


$FORCE_MAGISKHIDE
# hide magisk modify init.rc
 ) &

"

cd "$JOBPWD"
shloadpolicy="#!$MAGISKBASE/busybox sh
#stub"
EXPORT_PATH="export PATH /sbin:/system/bin:/system/xbin:/vendor/bin:/gearlock/bin:/apex/com.android.runtime/bin:/apex/com.android.art/bin"

magiskloader="

         on early-init
             $EXPORT_PATH
              

          on post-fs-data
$RM_RUSTY_MAGISK
              start logd
              start adbd
              rm /dev/.overlay_unblock
              rm /dev/.magisk_unblock
              start $magisk_overlay
              wait /dev/.overlay_unblock 10
              rm /dev/.overlay_unblock
              
              start $magisk_daemon
              start $magisk_loadpolicy
              start $magisk_postfsdata
              wait /dev/.magisk_unblock 40
              rm /dev/.magisk_unblock

          service $magisk_overlay $MAGISKBASE/busybox sh -o standalone $MAGISKBASE/overlay.sh
             user root
             group root 
             seclabel u:r:su:s0
             oneshot

          service $magisk_loadpolicy $MAGISKBASE/busybox sh -o standalone $MAGISKTMP/loadpolicy.sh
              user root
              seclabel u:r:magisk:s0
              oneshot

          service $magisk_postfsdata $MAGISKTMP/magisk --post-fs-data
              user root
              seclabel u:r:magisk:s0
              oneshot

          service $magisk_service $MAGISKTMP/magisk --service
              class late_start
              user root
              seclabel u:r:magisk:s0
              oneshot

         service $magisk_daemon $MAGISKTMP/magisk --daemon
              user root
              seclabel u:r:magisk:s0
              oneshot

          on property:sys.boot_completed=1
              start $magisk_boot_complete

          service $magisk_boot_complete $MAGISKTMP/magisk --boot-complete
              user root
              seclabel u:r:magisk:s0
              oneshot"

[ "$MINIMAL_MAGISK" == "true" ] && magiskloader="

         on early-init
             $EXPORT_PATH


          on post-fs-data
              start logd
              start adbd
$RM_RUSTY_MAGISK
              
          on property:sys.boot_completed=1
          
          rm /dev/.overlay_unblock
          start $magisk_overlay
          wait /dev/.overlay_unblock 10
          rm /dev/.overlay_unblock
          start $magisk_daemon
          start $magisk_loadpolicy

          service $magisk_overlay $MAGISKBASE/busybox sh -o standalone $MAGISKBASE/overlay.sh
             user root
             group root
             seclabel u:r:su:s0
             oneshot

          service $magisk_loadpolicy $MAGISKBASE/busybox sh -o standalone $MAGISKTMP/loadpolicy.sh
              user root
              seclabel u:r:magisk:s0
              oneshot

         service $magisk_daemon $MAGISKTMP/magisk --daemon
              user root
              seclabel u:r:magisk:s0
              oneshot


"

}

extract_magisk_apk(){

[ "$IS64BIT" == "true" ] && mkdir -p "$TMPDIR/magisk32"
mkdir -p "$TMPDIR/magisk"
mkdir -p "$TMPDIR/magisktool"
 

unzip -oj "$APKFILE" "lib/$ABI/*" -d "$TMPDIR/magisk" &>/dev/null
chmod -R 777 "$TMPDIR/magisk"
ln -s "./libmagiskinit.so" "$TMPDIR/magisk/magiskinit"

if [ "$IS64BIT" == "true" ]; then
unzip -oj "$APKFILE" "lib/$ABI32/*" -d "$TMPDIR/magisk32" &>/dev/null
ln -s "./libmagiskinit.so" "$TMPDIR/magisk32/magiskinit"
chmod -R 777 "$TMPDIR/magisk32"
fi

rm -rf "$MAGISKCORE/.rw" 2>/dev/null
touch "$MAGISKCORE/.rw" 2>/dev/null  || abortc light_red "$text_cannot_install_magisk"
rm -rf "$MAGISKCORE/.rw" 2>/dev/null

for file in magisk32 magisk64 magiskinit busybox; do
rm -rf $MAGISKCORE/$file
done

( cd "$TMPDIR/magisk"
for file in lib*.so; do
  chmod 755 $file
  cp -f "$file" "$MAGISKCORE/${file:3:${#file}-6}" && echo "  add magisk binary: ${file:3:${#file}-6}"
done

if [ "$IS64BIT" == "true" ]; then
cd "$TMPDIR/magisk32"
for file in lib*.so; do
  chmod 755 $file
  [ ! -f "$MAGISKCORE/${file:3:${#file}-6}" ] && cp -f "$file" "$MAGISKCORE/${file:3:${#file}-6}" && echo "  add magisk binary: ${file:3:${#file}-6}"
done

fi

if [ ! -f "$MAGISKCORE/magisk64" ] && [ "$IS64BIT" == "true" ]; then
"$TMPDIR/magisk/magiskinit" -x magisk "$MAGISKCORE/magisk64" && echo "  add magisk binary: magisk64"
fi

if [ ! -f "$MAGISKCORE/magisk32" ]; then
    whatmagisk="magisk"
    [ "$IS64BIT" == "true" ] && whatmagisk="magisk32"
"$TMPDIR/$whatmagisk/magiskinit" -x magisk "$MAGISKCORE/magisk32" && echo "  add magisk binary: magisk32"
fi

)

mkdir -p "$MAGISKCORE/assets"
unzip -oj "$APKFILE" 'assets/*' -x 'assets/chromeos/*' -d "$MAGISKCORE/assets" &>/dev/null

}

unpatch_ramdisk(){
RAMDISK="$1"
REPLACE_CURRENT="$2"

#magisk in ramdisk

MAGISKBASE="/magisk"

echo "******************************"
echo "      Magisk uninstaller"
echo "******************************"

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"
[ ! -f "$RAMDISK" ] && abortc light_red "! Ramdisk does not exist!"

echo "- $text_unpack_ramdisk"
mkdir -p "$TMPDIR/ramdisk"

( cd "$TMPDIR/ramdisk" && zcat "$RAMDISK" | cpio -iud ) || abortc light_red "! $text_unpack_ramdisk_fail"
echo "- $text_unpatch_ramdisk"
# restore init.rc
if [ -f "$TMPDIR/ramdisk/magisk/init.rc" ]; then
# found init.rc backup!
cat "$TMPDIR/ramdisk/magisk/init.rc" >"$TMPDIR/ramdisk/init.rc"
else
abortc light_red "$text_backup_not_exist" 2
fi

rm -rf "$TMPDIR/ramdisk/magisk"
echo "- $text_repack_ramdisk"
NEWRAMDISK="/sdcard/Magisk/unpatch_ramdisk_$RANDOM$RANDOM.img"
if [ "$REPLACE_CURRENT" != "true" ]; then
mkdir -p "/sdcard/Magisk" 2>/dev/null
echo "- $text_new_ramdisk"
echo "  $NEWRAMDISK"
else
[ -f "${RAMDISK}.bak" ] || mv "${RAMDISK}" "${RAMDISK}.bak"
NEWRAMDISK="$RAMDISK"
fi
( cd "$TMPDIR/ramdisk" && find * | cpio -o -H newc | gzip >$NEWRAMDISK ) || abortc light_red "! $text_repack_ramdisk_fail" 2
rm -rf /data/.magisk_binary 2>/dev/null
clean_flash
echo "- $text_done"
true


}

check_magisk_apk(){
[ ! -f "$APKFILE" ] && abortc light_red "! File does not exist"
unzip -oj "$APKFILE" 'assets/util_functions.sh' -d "$TMPDIR" &>/dev/null

MAGISK_VER=""
MAGISK_VER_CODE=""
[ -f "$TMPDIR/util_functions.sh" ] || abortc light_red "This apk is not Magisk app" 2
MAGISK_VERINFO="$( . $TMPDIR/util_functions.sh; echo "$MAGISK_VER $MAGISK_VER_CODE"; )"
MAGISK_VER="$(echo "$MAGISK_VERINFO" | awk '{ print $1 }')"
MAGISK_VER_CODE="$(echo "$MAGISK_VERINFO" | awk '{ print $2 }')"
pd green "** Magisk version: $MAGISK_VER ($MAGISK_VER_CODE)"
}

patch_ramdisk(){
RAMDISK="$1"
REPLACE_CURRENT="$2"

#magisk in ramdisk

MAGISKBASE="/magisk"

echo "******************************"
echo "      Magisk installer"
echo "******************************"

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"


[ ! -f "$RAMDISK" ] && abortc light_red "! Ramdisk does not exist!"

magisk_loader

check_magisk_apk

echo "- $text_unpack_ramdisk"

#unpack ramdisk to TMPDIR

mkdir -p "$TMPDIR/ramdisk"

( cd "$TMPDIR/ramdisk" && zcat "$RAMDISK" | cpio -iud ) || abortc light_red "! $text_unpack_ramdisk_fail"
echo "- $text_patch_ramdisk"
# ramdisk was unpack to $TMPDIR/ramdisk
[ -d "$TMPDIR/ramdisk/sbin" ] || magisk_loader 3

if file "$TMPDIR/ramdisk/init" | grep "x86" | grep -q "32-bit"; then
    ARCH=x86
    ABI32=x86
    IS64BIT=false
    ABI=x86
  elif file "$TMPDIR/ramdisk/init" | grep "arm64" | grep -q "64-bit"; then
    ARCH=arm64
    ABI32=armeabi-v7a
    IS64BIT=true
    ABI=arm64-v8a
  elif file "$TMPDIR/ramdisk/init" | grep "x86-64" | grep -q "64-bit"; then
    ARCH=x64
    ABI32=x86
    IS64BIT=true
    ABI=x86_64
  else
    ARCH=arm
    ABI=armeabi-v7a
    ABI32=armeabi-v7a
    IS64BIT=false
  fi
echo "- ${text_magisk_tmpfs_directory}: $MAGISKTMP"
echo "- ARCH: $ARCH, 64-bit: $IS64BIT"

mkdir "$TMPDIR/ramdisk/magisk"
if [ -f "$TMPDIR/ramdisk/magisk/init.rc" ]; then
# found init.rc backup!
cat "$TMPDIR/ramdisk/magisk/init.rc" >"$TMPDIR/ramdisk/init.rc"
echo "- $text_magisk_patched_ramdisk"
echo "$magiskloader" >>"$TMPDIR/ramdisk/init.rc"
else
# no backup init
cp "$TMPDIR/ramdisk/init.rc" "$TMPDIR/ramdisk/magisk/init.rc"
echo "$magiskloader" >>"$TMPDIR/ramdisk/init.rc"
fi
rm -rf "$TMPDIR/ramdisk/magisk/loadpolicy.sh" "$TMPDIR/ramdisk/magisk/overlay.sh"
echo "$shloadpolicy" >"$TMPDIR/ramdisk/magisk/loadpolicy.sh"
echo "$overlay_loader" >"$TMPDIR/ramdisk/magisk/overlay.sh"
echo "( mount -o rw,remount /
cat "/magisk/init.rc" >/init.rc
rm -rf /magisk
mount -o ro,remount / ) &" >>"$TMPDIR/ramdisk/magisk/overlay.sh"
chmod 755 "$TMPDIR/ramdisk/init.rc"
( MAGISKCORE="$TMPDIR/ramdisk/magisk"; IS64BIT=true; extract_magisk_apk )
chmod -R 777 "$TMPDIR/ramdisk/magisk"
echo "- $text_repack_ramdisk"
NEWRAMDISK="/sdcard/Magisk/magisk_ramdisk_$RANDOM$RANDOM.img"
if [ "$REPLACE_CURRENT" != "true" ]; then
mkdir -p "/sdcard/Magisk" 2>/dev/null
echo "- $text_new_ramdisk:"
echo "  $NEWRAMDISK"
else
[ -f "${RAMDISK}.bak" ] || mv "${RAMDISK}" "${RAMDISK}.bak"
NEWRAMDISK="$RAMDISK"
fi
( cd "$TMPDIR/ramdisk" && find * | cpio -o -H newc | gzip >$NEWRAMDISK ) || abortc light_red "! $text_repack_ramdisk_fail"
rm -rf /data/.magisk_binary
clean_flash
echo "- $text_done"
true
}


update_magiskbin(){
need_root_access
rm -rf /data/.magisk_binary
mkdir -p /data/.magisk_binary
rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"
check_magisk_apk

( MAGISKCORE="/data/.magisk_binary"; extract_magisk_apk
mkdir -p $MAGISKBIN 2>/dev/null
unzip -oj "$APKFILE" 'assets/*' -x 'assets/chromeos/*' -d $MAGISKBIN &>/dev/null
mkdir $NVBASE/modules 2>/dev/null
mkdir $POSTFSDATAD 2>/dev/null
mkdir $SERVICED 2>/dev/null )

chmod -R 750 /data/.magisk_binary
clean_flash

}

extension_info(){
cat <<EOF
#######################################################################################################
#####=============================== Package/Extension Information ===============================#####
NAME="Magisk_extension" #Package/Extension Name

TYPE="Extension" #Specify (Package / Extension)

AUTHOR="HuskyDG" #Your name as the Developer/Owner/Packer

VERSION="$MAGISK_VER" #Specify the Version of this package/extension

SHORTDESC="An extension to provide Magisk for Android x86" #Provide a short description about this package/extension

C_EXTNAME="Magisk_extension" #For Specifing a custom name for your extension script (\$NAME is used if not defined)
#######################################################################################################
######=============================== Package/Extension Functions ===============================######

REQSYNC="yes" #Require Sync (Deafult - yes)

REQREBOOT="no" #(Deafult - no) Use if your package/extension modifies any major system file

GEN_UNINS="yes" #(Deafult - yes) If you want GearLock to generate a uninstallation script itself

SHOW_PROG="yes" #(Default - yes) Whether to show extraction progress while loading the pkg/extension

DEF_HEADER="yes" #(Default -yes) Whether to use the default header which print's the info during zygote

######=============================== Package/Extension Functions ===============================######
#######################################################################################################
EOF
}

extension_unins(){
cat <<EOF


GEARHOME="\$GHOME"
GEARBOOT="\$GEARHOME/gearboot/overlay/magisk"

rm -rf "\$GEARHOME/gearboot/overlay/rusty-magisk"
rm -rf "\$GEARBOOT" 2>/dev/null
rm -rf "\$GEARHOME/.local/magisk" 2>/dev/null
rm -rf \$GEARHOME/unins/Magisk_* 2>/dev/null
rm -rf \\
/cache/*magisk* /cache/unblock /data/*magisk* /data/cache/*magisk* /data/property/*magisk* \\
/data/Magisk.apk /data/busybox /data/custom_ramdisk_patch.sh /data/adb/*magisk* \\
/data/adb/post-fs-data.d /data/adb/service.d /data/adb/modules* \\
/data/unencrypted/magisk /metadata/magisk /persist/magisk /mnt/vendor/persist/magisk /data/.magisk_binary /magisk \\
/data/ghome/unins/Magisk_* /system/ghome/unins/Magisk_*
if test "\$BOOTCOMP" == "yes"; then
echo "- The device will reboot after a few seconds"
(sleep 8; reboot) &
fi

EOF
}


install_magisk_gearlock(){
echo "******************************"
echo "      Magisk installer"
echo "******************************"
SYSTEMLESS=true
GEARHOME=/data/ghome
if [ -d "$GEARHOME" ]; then
true # stub
elif [ -d "/system/ghome" ]; then
GEARHOME="/system/ghome"
SYSTEMLESS=false
else
abortc light_red "$text_install_gearlock !"
fi
GEARBOOT="$GEARHOME/gearboot/overlay/magisk/init"
echo "- GearLock Home: $GEARHOME"
$SYSTEMLESS && echo "- Systemless mode!"
GEARLOCK=true
mkdir -p "$TMPDIR"
INITRC=/init.rc
INITRC2=/system/etc/init/hw/init.rc
rm -rf "$GEARHOME/gearboot/overlay/rusty-magisk"
GEAR_INITDIR="$GEARBOOT"
if [ ! -f "$INITRC" ]; then
# Android 11 new init.rc
INITRC="$INITRC2"
GEAR_INITDIR="$GEARBOOT/system/etc/init/hw"
fi
NEW_INITRC="$GEAR_INITDIR/init.rc"
rm -rf "$GEARBOOT"
mkdir -p "$GEAR_INITDIR"
first_setup
rm -rf $GEARHOME/unins/Magisk_* 2>/dev/null


echo "$(extension_info)

do_unins_custom(){
$(extension_unins)
}">"$GEARHOME/unins/Magisk_extension_$MAGISK_VER"
setup_magisk_env
echo "- $text_install Magisk loader..."
rm -rf $MAGISKCORE/overlay.sh
echo "$overlay_loader" >"$MAGISKCORE/overlay.sh"
touch "$GEARBOOT/init.superuser.rc"
cp "$INITRC" "$NEW_INITRC"
echo "$magiskloader" >>"$NEW_INITRC"
rm -rf "$MAGISKCORE/loadpolicy.sh"
echo "$shloadpolicy" >"$MAGISKCORE/loadpolicy.sh"
clean_flash
echo "- $text_done"
}

first_setup(){
need_root_access

check_magisk_apk

if mount | grep rootfs | grep -q " / " || mount | grep tmpfs | grep -q " / "; then
# legacy rootfs
MAGISKBASE="/system/etc/magisk"
SYSTEMTYPE=1
elif [ -d "/sbin" ]; then
# SAR
MAGISKBASE="/magisk"
MAGISKCORE="/magisk"
SYSTEMTYPE=3
fi

if [ "$GEARLOCK" == "true" ]; then
MAGISKBASE="$GEARHOME/.local/magisk"
MAGISKCORE="$GEARHOME/.local/magisk"
fi

magisk_loader "$SYSTEMTYPE"

if [ -e "/init" ] && [ -e "/init.real" ]; then
pd light_red "$text_tell_remove_rusty_magisk"
# /dev mode to not conflit with rusty-Magisk
magisk_loader 3
fi
echo "- ${text_magisk_tmpfs_directory}: $MAGISKTMP"
rm -rf "$MAGISKCORE"
mkdir -p "$MAGISKCORE"
}



setup_magisk_env(){

echo "- $text_extract_magisk_apk"

extract_magisk_apk

}




build_gxp(){
GEARLOCK=true
echo "******************************"
echo "      Magisk installer"
echo "******************************"
get_tmpdir
MAGISKBASE="PLACEHOLDER_MAGISKBASE"
MAGISKCORE="$TMPDIR/gxp/gearlock/magisk"
rm -rf "$TMPDIR"
mkdir -p "$MAGISKCORE"
check_magisk_apk
magisk_loader 3
echo "- ${text_magisk_tmpfs_directory}: $MAGISKTMP"
unzip -o "$gxp_template" -d "$TMPDIR/gxp" &>/dev/null
extract_magisk_apk
echo "- $text_install Magisk loader..."
rm -rf $MAGISKCORE/overlay.sh
echo "$overlay_loader" >"$MAGISKCORE/overlay.sh"
rm -rf "$TMPDIR/gxp/gearlock/magisk.rc"
echo "$magiskloader" >"$TMPDIR/gxp/gearlock/magisk.rc"
rm -rf "$MAGISKCORE/loadpolicy.sh"
echo "$shloadpolicy" >"$MAGISKCORE/loadpolicy.sh"
extension_info > "$TMPDIR/gxp/!zygote.sh"
extension_unins >"$TMPDIR/gxp/uninstall.sh"
echo "- $text_building_gxp"
cd "$TMPDIR/gxp" || abortc light_red "$text_cannot_install_magisk"
libzip.so -r "$TMPDIR/gxp.zip" "./" &>/dev/null
[ ! -d "/sdcard/Magisk" ] && rm -rf "/sdcard/Magisk"
mkdir -p "/sdcard/Magisk"
EXTENSION_ZIP="/sdcard/Magisk/magisk-extension-$MAGISK_VER.gxp"
rm -rf "$EXTENSION_ZIP"
cp "$TMPDIR/gxp.zip" "$EXTENSION_ZIP" || abortc light_red "$text_grant_inter_access_permission"
echo "- $text_saved_magisk_gxp_to"
echo "  $EXTENSION_ZIP"
clean_flash
echo "- $text_done"

}




install_magisk(){
GEARLOCK=false

echo "******************************"
echo "      Magisk installer"
echo "******************************"

first_setup

echo "- $text_mount_rw_system"
mount_rw_system
$IS_SYSTEM_MOUNT || abortc "light_red" "! $text_failed_mount_system"

umount -l /system/bin
umount -l /system/bin/*

echo "- $text_setup"
rm -rf "$MAGISKCORE"
mkdir -p "$MAGISKCORE"
chown root:root "$MAGISKCORE"
chmod 750 "$MAGISKCORE"

setup_magisk_env


echo "- $text_install Magisk loader..."
rm -rf $MAGISKCORE/overlay.sh
echo "$overlay_loader" >"$MAGISKCORE/overlay.sh"
rm -rf "/system/etc/init/magisk.rc"
echo "$magiskloader" >"/system/etc/init/magisk.rc"
rm -rf "$MAGISKCORE/loadpolicy.sh"
echo "$shloadpolicy" >"$MAGISKCORE/loadpolicy.sh"
echo "- $text_mount_ro_system"
mount_ro_system

if [ ! "$build_name" == "Custom" ]; then
STUB_MAGISK_APK="$(find /data/user_de/0/*/dyn/current.apk -type f 2>/dev/null)"
echo "- $text_install_app..."
if [ -z "$STUB_MAGISK_APK" ]; then
    pm uninstall com.topjohnwu.magisk &>/dev/null
    pm install "$APKFILE" &>/dev/null || echo "* $text_install_app_sug"
else
    echo "$STUB_MAGISK_APK" | while read magisk_dyn; do
        cat "$APKFILE" >"$magisk_dyn"
    done
fi
mkdir -p "/sdcard/Magisk"
rm -rf "/sdcard/Magisk/Magisk.apk"
cp "$APKFILE" "/sdcard/Magisk/Magisk.apk"
echo "- $text_saved_magisk_apk_to /sdcard/Magisk/Magisk.apk"
fi
clean_flash
echo "- $text_done"
}




uninstall_magisk(){
echo "******************************"
echo "      Magisk uninstaller"
echo "******************************"
need_root_access
FOUND_MAGISK=false
SYSTEMLESS=true
FILE_LIST1="
/data/ghome/gearboot/overlay/magisk
/data/ghome/gearboot/overlay/rusty-magisk
/data/ghome/.local/magisk
"

for file in $FILE_LIST1; do
test -d $file && FOUND_MAGISK=true
done

FILE_LIST2="
/system/ghome/gearboot/overlay/rusty-magisk
/system/ghome/gearboot/overlay/magisk
/system/ghome/.local/magisk
/magisk
/system/etc/magisk
"

for file in $FILE_LIST2; do
test -d $file && FOUND_MAGISK=true && SYSTEMLESS=false
done

$FOUND_MAGISK || abortc light_red "$text_uninstall_fail"

if [ "$SYSTEMLESS" == "false" ]; then
echo "- $text_mount_rw_system"
mount_rw_system
$IS_SYSTEM_MOUNT || abortc "light_red" "! $text_failed_mount_system"

MAGISKCOREDIR=/magisk
[ ! -d "/magisk" ] && MAGISKCOREDIR=/system/etc/magisk

rm -rf "$MAGISKCOREDIR/.rw" 2>/dev/null
touch "$MAGISKCOREDIR/.rw" 2>/dev/null  || abortc light_red "$text_system_not_writeable"
rm -rf "$MAGISKCOREDIR/.rw" 2>/dev/null

fi

echo "- $text_uninstalling_magisk..."

for fun in $FILE_LIST1 $FILE_LIST2 /system/etc/init/magisk.rc; do
rm -rf "$fun"
done

if $REMOVE_MAGISK_DATA; then

ADDOND=/system/addon.d/99-magisk.sh
if [ -f $ADDOND ]; then
  rm -f "/$ADDOND"
fi
echo "- $text_rm_magisk_files"
rm -rf \
/cache/*magisk* /cache/unblock /data/*magisk* /data/cache/*magisk* /data/property/*magisk* \
/data/Magisk.apk /data/busybox /data/custom_ramdisk_patch.sh /data/adb/*magisk* \
/data/adb/post-fs-data.d /data/adb/service.d /data/adb/modules* \
/data/unencrypted/magisk /metadata/magisk /persist/magisk /mnt/vendor/persist/magisk /data/.magisk_binary /magisk \
/data/ghome/unins/Magisk_* /system/ghome/unins/Magisk_*

if [ "$SYSTEMLESS" == "false" ]; then
echo "- $text_mount_ro_system"
mount_ro_system
fi
cd /
  echo "********************************************"
  warn_reboot
  echo "********************************************"
(sleep 8; /system/bin/reboot)&
fi
echo "- $text_done"

}


unsu(){
clear
ui_print " ";
echo "******************************"
ui_print "unSU Script";
ui_print "by osm0sis @ xda-developers"; #keep credit
echo "******************************"
echo "- $text_mount_rw_system"
mount_rw_system
$IS_SYSTEM_MOUNT || abortc "light_red" "! $text_failed_mount_system"

mount --bind /system /system

rm -rf "/system/.rw" 2>/dev/null
touch "/system/.rw" 2>/dev/null  || { umount -l /system; abortc light_red "$text_system_not_writeable"; }
rm -rf "/system/.rw" 2>/dev/null


if [ -e /data/su ]; then
  ui_print "Removing phh's SuperUser...";
  rm -rf /data/app/me.phh.superuser* /data/data/me.phh.superuser* /data/su;
  bootmsg=1;
fi;


if [ -e /cache/su.img -o -e /data/su.img ]; then
  ui_print "Removing SuperSU Systemless (su.img)...";
  umount /su;
  rm -rf /cache/su.img /data/su.img /data/adb/suhide;
  bootmsg=1;
  supersu=1;
fi;

bindsbin=$(dirname `find /data -name supersu_is_here | head -n1`);
if [ -e "$bindsbin" ]; then
  ui_print "Removing SuperSU Systemless (BINDSBIN at $bindsbin)...";
  rm -rf $bindsbin /data/app/eu.chainfire.suhide* /data/user*/*/eu.chainfire.suhide*;
  bootmsg=1;
  supersu=1;
fi;

if [ -e /system/bin/.ext/.su ]; then
  ui_print "Removing SuperSU...";
  mount -o rw,remount /system;

  rm -rf /system/.pin /system/.supersu \
         /system/app/Superuser.apk /system/app/SuperSU \
         /system/bin/.ext /system/bin/app_process_init \
         /system/etc/.installed_su_daemon /system/etc/install-recovery.sh /system/etc/init.d/99SuperSUDaemon \
         /system/lib/libsupol.so /system/lib64/libsupol.so /system/su.d \
         /system/xbin/daemonsu /system/xbin/su /system/xbin/sugote /system/xbin/sugote-mksh /system/xbin/supolicy;

  mv -f /system/bin/app_process32_original /system/bin/app_process32;
  mv -f /system/bin/app_process64_original /system/bin/app_process64;
  mv -f /system/bin/install-recovery_original.sh /system/bin/install-recovery.sh;

  cd /system/bin;
  if [ -e app_process64 ]; then
    ln -sf app_process64 app_process;
  elif [ -e app_process32 ]; then
    ln -sf app_process32 app_process;
  fi;
  supersu=1;
fi;

if [ "$supersu" ]; then
  rm -rf /cache/.supersu /cache/SuperSU.apk \
         /data/.supersu /data/SuperSU.apk \
         /data/app/eu.chainfire.supersu* /data/user*/*/eu.chainfire.supersu*;
fi;

if [ -e /system/bin/su -a "$(strings /system/xbin/su | grep koush)" ]; then
  ui_print "Removing Koush's SuperUser...";
  mount -o rw,remount /system;

  rm -rf /system/app/Superuser.apk /system/bin/su \
         /system/etc/.has_su_daemon /system/etc/.installed_su_daemon /system/xbin/su \
         /cache/su /cache/Superuser.apk /cache/install-recovery-sh \
         /data/app/com.koushikdutta.superuser* /data/user*/*/com.koushikdutta.superuser*;
fi;

if [ -e /system/addon.d/51-addonsu.sh ]; then
  ui_print "Removing LineageOS addonsu...";
  mount -o rw,remount /system;
  rm -rf /system/addon.d/51-addonsu.sh /system/bin/su \
         /system/etc/init/superuser.rc /system/xbin/su;
fi;

if [ -e /system/bin/su -o -e /system/xbin/su ]; then
  ui_print "Removing ROM su binary...";
  mount -o rw,remount /system;
  rm -rf /system/bin/su /system/xbin/su;
fi;
umount -l /system
echo "- $text_mount_ro_system"
mount_ro_system
}

download_magisk_apk(){
if [ "$install_offline" != "true" ]; then
    
     
    echo "- Downloading Magisk APK..."
    rm -rf "$DLPATH/app.tmp"
    rm -rf "$DLPATH/app.apk"
mirror_git="https://gh.api.99988866.xyz/"
 

    wget -O "$DLPATH/app.tmp" "$URL" 2>/dev/null && mv -f "$DLPATH/app.tmp" "$DLPATH/app.apk" 2>/dev/null
    [ -f "$DLPATH/app.apk" ] || wget -O "$DLPATH/app.tmp" "$mirror_git$URL" 2>/dev/null && mv -f "$DLPATH/app.tmp" "$DLPATH/app.apk" 2>/dev/null
    [ -f "$DLPATH/app.apk" ] || abortc none "! Cannot download Magisk APK"
    APKFILE="$DLPATH/app.apk"
fi
rm -rf "$DLPATH/util_functions.sh"; unzip -oj "$APKFILE" 'assets/util_functions.sh' -d "$DLPATH" &>/dev/null
      MAGISK_VERINFO="$( . $DLPATH/util_functions.sh; echo "$MAGISK_VER $MAGISK_VER_CODE"; )"
MAGISK_VER="$(echo "$MAGISK_VERINFO" | awk '{ print $1 }')"
MAGISK_VER_CODE="$(echo "$MAGISK_VERINFO" | awk '{ print $2 }')"
      [ -z "$MAGISK_VER" -o -z "$MAGISK_VER_CODE" ] && abortc light_red "This APK is not Magisk app"
      cp -af "$APKFILE" "$DLPATH/save/$MAGISK_VER($MAGISK_VER_CODE)"
}


install_option_process(){
clear

( download_magisk_apk
   install_option_method
 )
}

install_option_method(){
MINIMAL_MAGISK=false
while true; do
clear
pd light_cyan "- Magisk build: $MAGISK_VER($MAGISK_VER_CODE)"
nomethod=false
print_method
read method
case "$method" in
1)
    install_command="install_magisk"
    ;;
2)
    patch_ramdisk_method
    ;;
3)
    gearlock_method
    ;;
4)
    install_command="update_magiskbin"
    ;;
"m")
    if [ "$MAGISK_VER_CODE" -lt "23010" ]; then
       if $MINIMAL_MAGISK; then
       MINIMAL_MAGISK=false
       else
       MINIMAL_MAGISK=true
       fi
    fi
    nomethod=true
    ;;
0)
    exit 0
    ;;
*)
    nomethod=true
    ;;
esac
$nomethod || break
done
$nomethod || { clear; $install_command "$RAMDISK"; }

}

ramdisk_direct_install(){
CONTINUE=1
echo -n "$text_find_ramdisk_auto ? <Y/n> "
read autom
if [ "$autom" == "Y" -o "$autom" == "y" ]; then
( find_ramdisk_image
patch_ramdisk "$RAMDISK" "true" )
test "$?" == 0 && CONTINUE=0
umount -l /dev/os_disk_*
echo "Unmount all disks..."
elif ! [ "$autom" == "N" -o "$autom" == "n" ]; then
        exit
fi
if [ "$CONTINUE" == "1" ]; then
VAR_OSROOT="$(cat $DISKINFO/blockdev)"
VAR_RAMDISK="$(cat $DISKINFO/ramdisk)"
RAMDISK="$VAR_RAMDISK"
if [ "$VAR_OSROOT" ] && [ "$VAR_RAMDISK" ]; then
( echo -n "${text_use_current_ramdisk_info}? <Y/n> "
read opt
if [ "$opt" == "Y" -o "$opt" == "y" ]; then
mount_disk
( patch_ramdisk "$RAMDISK" "true" )
ERR_CODE=$?
umount_disk
exit $ERR_CODE 
elif ! [ "$opt" == "N" -o "$opt" == "n" ]; then
        exit
else
exit 1
fi )
if [ "$?" == "1" ]; then
table_list
patch_ramdisk "$RAMDISK" "true"
umount_disk
fi
else
table_list
patch_ramdisk "$RAMDISK" "true"
umount_disk
fi
fi
}

ramdisk_direct_uninstall(){
CONTINUE=1
echo -n "$text_find_ramdisk_auto ? <Y/n> "
read autom
if [ "$autom" == "Y" -o "$autom" == "y" ]; then
( find_ramdisk_image
unpatch_ramdisk "$RAMDISK" "true" )
test "$?" == 0 && CONTINUE=0
umount -l /dev/os_disk_*
echo "Unmount all disks..."
elif ! [ "$autom" == "N" -o "$autom" == "n" ]; then
        exit
fi
if [ "$CONTINUE" == "1" ]; then
VAR_OSROOT="$(cat $DISKINFO/blockdev)"
VAR_RAMDISK="$(cat $DISKINFO/ramdisk)"
RAMDISK="$VAR_RAMDISK"
if [ "$VAR_OSROOT" ] && [ "$VAR_RAMDISK" ]; then
( echo -n "${text_use_current_ramdisk_info}? <Y/n> "
read opt
if [ "$opt" == "Y" -o "$opt" == "y" ]; then
mount_disk
( unpatch_ramdisk "$RAMDISK" "true" )
ERR_CODE=$?
umount_disk
exit $ERR_CODE
elif ! [ "$opt" == "N" -o "$opt" == "n" ]; then
        exit
else
exit 1
fi )
if [ "$?" == "1" ]; then
table_list
unpatch_ramdisk "$RAMDISK" "true"
umount_disk
fi
else
table_list
unpatch_ramdisk "$RAMDISK" "true"
umount_disk
fi
fi
}


patch_ramdisk_method(){
RAMDISK=""
print_ramdisk_method
read c
case "$c" in
    1)
        need_root_access
        install_command="ramdisk_direct_install"
        ;;
     2)
        echo "$text_enter_path_ramdisk"
        p none "> "
        read RAMDISK
        install_command="patch_ramdisk"
        ;;
      *)
        nomethod=true
        ;;
esac
}

gearlock_method(){
RAMDISK=""
print_gxp_method
read c
case "$c" in
    1)
        need_root_access
        install_command="install_magisk_gearlock"
        ;;
     2)
        
        install_command="build_gxp"
        ;;
      *)
        nomethod=true
        ;;
esac
}



install_option(){
clear
print_menu_install
read build
install_magisk=true
install_offline=false
MINIMAL_MAGISK=false
APKFILE="$DLPATH/magisk.apk"
case $build in
1)
    build_name="Canary"
    URL="$canary_magisk_link"
    ;;
2)
    build_name="Alpha"
    URL="$alpha_magisk_link"
    ;;
3)
    build_name="Canary"
    URL="$canary_v23001_magisk_link"
    ;;
4)
    build_name="Stable"
    URL="$stable_magisk_link"
    ;;
5)
    build_name="Canary"
    URL="https://github.com/TheHitMan7/Magisk-Files/blob/master/channel/app-release.apk?raw=true"
    ;;
"e")
    echo -n "[URL]: "
    read URL
    [ -z "$URL" ] && install_magisk=false
    ;;
"a")
   build_name="Alpha"
    install_offline=true
    ;;
"x")
    build_name="Custom"
    install_offline=true
    echo "$text_enter_magisk_apk"
    p none "$text_example: "; pd gray "/sdcard/Magisk.apk"
    p none "> "
    read custom_magisk_apk
    APKFILE="$custom_magisk_apk"
    [ ! -f "$APKFILE" ] && abortc light_red "Magisk APK does not exist"
    ;;
"z")
    install_offline=true
    list_apk
    ;;

*)
    install_magisk=false
    ;;
esac

if [ "$install_magisk" == "true" ]; then
    clear
    install_option_process
fi

    

}

uninstall_option(){
clear
pd gray "=============================================="
echo "   Uninstall Magisk"
pd gray "=============================================="
echo "   1 - $text_uninstall_magisk_in"
echo "   2 - $text_restore_original_ramdisk"
echo -n "[$text_choice]: "
read c
case "$c" in
1)
   ( need_root_access; p none "$text_warn_uninstall_magisk <Y/n> "
    read uni
    if [ "$uni" == "y" -o "$uni" == "Y" ]; then
    p none "$text_ask_keep_modules <Y/n> "
    REMOVE_MAGISK_DATA=true
    read uni2
    [ "$uni2" == "y" -o "$uni2" == "Y" ] && REMOVE_MAGISK_DATA=false
    clear
    uninstall_magisk
    fi )
   ;;
2)
   unpatch_ramdisk_method
   ;;
esac
}

unpatch_ramdisk_method(){
print_unpatch_ramdisk
read c
case "$c" in
1)
      ( need_root_access; clear; ramdisk_direct_uninstall )
      ;;
2)
       echo "$text_enter_path_ramdisk"
       echo -n "> "
       read RAMDISK
       clear
       ( unpatch_ramdisk "$RAMDISK" )
       ;;
esac
}



try_mount_it(){
echo -e "Mounting ${BGREEN}${VAR_OSROOT}${RC} to ${BPURPLE}${OSROOT}${RC}"
mount -o ro "$VAR_OSROOT" "$OSROOT"
mount -t ext4 "$VAR_OSROOT" "$OSROOT"
mount -o rw,remount "$OSROOT" && IS_MOUNT=true
mount.ntfs "$VAR_OSROOT" "$OSROOT" && IS_MOUNT=true
$IS_MOUNT || echo -e "${BRED}$text_cannot_mount_part${RC}" 
}

try_umount_it(){
if [ "$GEARROOT" ]; then
for block in $GEARROOT; do
if [ "$block" != "/system" ]; then
echo -ne "Unmount ${BPURPLE}${block}${RC}... "
umount -l "$block" && echo -e "${BGREEN}SUCCESS!${RC}" || echo -e "${BRED}FAILED!${RC}"
fi
done
fi
}


mount_disk(){
IS_MOUNT=false
[ -z "$OSROOT" ] && OSROOT=/dev/os_disk
umount -l "$OSROOT"
rm -rf "$OSROOT"
mkdir "$OSROOT"
GEARROOT="$(mount | grep "^${VAR_OSROOT}" | awk '{ print $3 }')"
try_mount_it
if [ "$IS_MOUNT" == "false" ]; then
try_umount_it
try_mount_it
fi
}

umount_disk(){
echo -ne "Unmount ${BPURPLE}/dev/os_disk${RC}... "
umount -l /dev/os_disk && echo -e "${BGREEN}SUCCESS!${RC}" || echo -e "${BRED}FAILED!${RC}" 
}

table_blockdev(){
echo " ------- Partition Table -------"
BLOCKDEVS="$(/system/bin/blkid -s LABEL -s TYPE | grep -v loop | grep -v "/sr" | awk 'NF')"
#BLOCKDEVS="/dev/block/example"
echo "$BLOCKDEVS" | nl -s "]. "
echo "     0]. Exit table"
IS_MOUNT=false
while true; do
echo -ne "+ $text_enter_part >>"
read -r c
VAR_OSROOT="$(echo "$BLOCKDEVS" | sed -n "$c p" 2>/dev/null | cut -d : -f1)"
OSROOT=/dev/os_disk
if [ "$c" == "0" ]; then
exit
elif [ -z "$c" ] || [ -z "$VAR_OSROOT" ]; then
			echo -e "${RED}! $text_wrong_input ...${RC}"
else
# mount the partition for us
    mount_disk
    $IS_MOUNT && break
fi
done
}

find_ramdisk_image(){
RAMDISK=""
BLOCKDEVS="$(blkid | grep -v loop | grep -v "/sr" | awk 'NF' | cut -d : -f1)"
BIMGVAR="$(cmdline BOOT_IMAGE)"
SRCVAR="$(cmdline SRC)"
[ -z "$SRCVAR" ] && SRCVAR="$(dirname "$BIMGVAR")"
[ "$SRCVAR" == "." ] && SRCVAR="android"
count=0
RAMDISK="/gearlock/gearroot/$SRCVAR/ramdisk.img"
if [ ! -f "$RAMDISK" ]; then
unset RAMDISK
for VAR_OSROOT in $BLOCKDEVS; do
count="$(($count + 1))"
OSROOT="/dev/os_disk_$count"
mount_disk
TARGET_ROOT="$OSROOT/$SRCVAR"
if [ -d "$TARGET_ROOT" ] && [ -f "$TARGET_ROOT/findme" ] && [ -f "$TARGET_ROOT/initrd.img" ] && [ -f "$TARGET_ROOT/ramdisk.img" ] && file "$TARGET_ROOT/ramdisk.img" | grep -q " gzip "; then
RAMDISK="$TARGET_ROOT/ramdisk.img"
break;
fi
done
fi
[ -z "$RAMDISK" ] && abortc light_red "$text_cannot_detect_target_ramdisk"
echo -e "- Target ramdisk: ${BGREEN}${RAMDISK}${RC}"
}


table_ramdisk(){
SELECTED_RAMDISK=false
    test -f $DISKINFO/blockdev || rm -rf $DISKINFO/blockdev
    echo -n "$VAR_OSROOT" >$DISKINFO/blockdev
    echo "------- CHOICE RAMDISK -------:"
    LIST_OS="$(find "$OSROOT"  -mindepth 2 -maxdepth 2 -name "$chkFile" 2>/dev/null)"
    [ -z "$LIST_OS" ] && pd light_red "     No ramdisk!" || echo "$LIST_OS" | nl -s "]. "
    echo "     r]. Re-mount partition"
    echo "     0]. Exit table"
    while true; do
    echo -ne "$text_enter_ramdisk >>"
    read -r c
    VAR_RAMDISK=$(echo "$LIST_OS" | sed -n "$c p" 2>/dev/null | cut -d : -f1)
    if [ "$c" == "0" ]; then
        exit
    elif [ "$c" == r ]; then
        break
    elif [ -z "$c" ] || [ -z "$VAR_OSROOT" ]; then
			echo -e "${RED}! $text_wrong_input ...${RC}"
    elif file "$VAR_RAMDISK" | grep -q " gzip "; then
        echo -e "- Target ramdisk: ${BGREEN}${VAR_RAMDISK}${RC}"
        test -f $DISKINFO/ramdisk || rm -rf $DISKINFO/ramdisk
        echo -n "$VAR_RAMDISK" >$DISKINFO/ramdisk
        RAMDISK="$VAR_RAMDISK"
        echo -e "- $text_saved_ramdisk_info ${BGREEN}/data/adb/diskinfo${RC}"
        SELECTED_RAMDISK=true
        break
    else
        echo -n "${RED}! $text_unsupport_ramdisk_format${RC}"
    fi
    done
}


mount_fail_pick_again(){
echo -e "${RED}! $text_cannot_mount_part${RC}"
sleep 1
table_blockdev
}

bluestacks_fix(){ (
MODDIR=/data/adb/modules/bluestacks-fix
MODDIR2=/data/adb/modules_update/bluestacks-fix
mkdir -p $MODDIR
mkdir -p $MODDIR2
echo "MAGISKTMP=\$(magisk --path) || MAGISKTMP=/sbin
MIRROR_SYSTEM=\"\$MAGISKTMP/.magisk/mirror/system\"
test ! -d \"\$MIRROR_SYSTEM/android/system\" && exit
mount --bind \"\$MIRROR_SYSTEM/android/system\" \"\$MIRROR_SYSTEM\"">$MODDIR2/post-fs-data.sh
MODPROP="id=bluestacks-fix
name=Bluestacks System Fix
version=v1.0
versionCode=10000
author=HuskyDG
description=Fix the incorrect Bluestacks system partition that breaks Magisk modules"
echo "$MODPROP" >$MODDIR/module.prop
echo "$MODPROP" >$MODDIR2/module.prop
echo -n >$MODDIR/update
pd light_green "$text_added_bs_module"
) 2>/dev/null 
}


table_list(){
RESET_DISKINFO="$1"
while true; do
clear
mkdir -p "$DISKINFO"
BLOCKDEV="$(cat $DISKINFO/blockdev)"
VAR_RAMDISK="$(cat $DISKINFO/ramdisk)"
if [ -z "$BLOCKDEV" ]; then
    table_blockdev
else
    VAR_OSROOT="$BLOCKDEV"
    echo -ne "Mount this device block?: ${BPURPLE}${BLOCKDEV}${RC} ? <Y/n>"; read m
    if [ "$m" == "Y" -o "$m" == "y" ]; then
        mount_disk
        $IS_MOUNT || mount_fail_pick_again
    else
        table_blockdev
     fi
fi

chkFile="ramdisk.img"
#test_if_ramdisk
# find Android x86 folder

if $IS_MOUNT; then
    table_ramdisk
fi
$SELECTED_RAMDISK && break
done
}

list_apk(){ 
while true; do
clear
pd light_cyan "$text_select_magisk_app"
LIST_APK="$(cd "$DLPATH/save" && find * -prune -type f)"
echo "$LIST_APK"  | nl -s "]. "
echo "----------"
echo "     0]. Exit here"
echo "$text_guide_rm_magisk_app"
echo -n "[$text_choice]: "
read -r capk
if [ "$capk" == 0 ]; then
exit
elif [ ! -z "$capk" ] && [ -f "$DLPATH/save/$(echo "$LIST_APK" | sed -n "$capk p" 2>/dev/null | cut -d : -f1)" ]; then
APKFILE="$DLPATH/save/$(echo "$LIST_APK" | sed -n "$capk p" 2>/dev/null | cut -d : -f1)"
break
elif [ "$(echo "$capk" | awk '{ print $1 }')" == "rm" ]; then
rm -rf "$DLPATH/save/$(echo "$LIST_APK" | sed -n "$(echo -n "$capk" | awk '{ print $2 }') p" 2>/dev/null | cut -d : -f1)"
else
echo -en "${RED}! $text_wrong_input ...${RC}"; read
fi
done

}


main(){
clear
print_menu
read option
no_turn_back=false
case $option in
1)
   ( install_option )
    ;;
2)
    uninstall_option
    ;;
3)
   rm -rf "$DLPATH/fmm.apk"
   cp "$MYPATH/libmm.so" "$DLPATH/fmm.apk"
    pm install "$DLPATH/fmm.apk" &>/dev/null && pd light_green "$text_success_mm" || pd light_red "$text_cannot_mm"
    ;;
4)
    (need_root_access; unsu)
    ;;
0)
    exit 0
    ;;
*)
    no_turn_back=true
    ;;
esac
$no_turn_back || turn_back
}

install_option_dd(){
download_magisk_apk
case "$AGV3" in
    "system")
        (need_root_access; install_magisk)
        ;;
     "ramdisk")
         (need_root_access; ramdisk_direct_install)
         ;;
     "ramdisk-patch")
         (patch_ramdisk "$AGV4")
         ;;
     "export-gxp")
         ( build_gxp )
         ;;
     *)
         install_option_method
         ;;
esac
}





APKFILE="$DLPATH/magisk.apk"
if [ "$AGV1" != "noexec" ]; then
    if [ "$AGV1" == "option" ]; then
        case "$AGV2" in
            "install")
                install_option;
                ;;

            "install:alpha")
    build_name="Alpha"
    URL="$alpha_magisk_link"
    install_option_dd
    ;;
            "install:canary")
    build_name="Canary"
    URL="$canary_magisk_link"
    install_option_dd
    ;;
            "install:stable")
    build_name="Stable"
    URL="$stable_magisk_link"
    install_option_dd
    ;;
            "install:offline")
    build_name="Alpha"
    install_offline=true
    install_option_dd
    ;;
            "install:custom")
    build_name="Custom"
    install_offline=true
    APKFILE="$AGV5"
    install_option_dd
    ;;
            "install:"*)
                echo "Invaild Magisk build. Available build: canary, alpha, stable"
            ;;
            "uninstall")
            uninstall_option
            ;;
            *)
            open_main
            ;;
            
        esac
    else
        open_main
    fi
fi; clean_flash 2>/dev/null; true