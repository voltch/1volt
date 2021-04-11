#!/system/bin/sh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Originally Coded by Tkkg1994 @GrifoDev, enhanced by BlackMesa @XDAdevelopers
# enhanced once again corsicanu @XDAdevelopers with some code from 6h0st@ghost.com.ro
#

LOGFILE=/data/volt/volt.log

# Initial proper mounts
mount -t rootfs -o remount,rw rootfs
mount -o remount,rw /system
mount -o remount,rw /data
mount -o remount,rw /cache

log_print() {
  echo "$1"
  echo "$1" >> $LOGFILE
}

log_print "------------------------------------------------------"
log_print "**volt scripts started at $( date +"%d-%m-%Y %H:%M:%S" )**"

if [ ! -e /data/volt ]; then
    mkdir -p /data/volt
    chown -R root.root /data/volt
    chmod -R 755 /data/volt
fi

for FILE in /data/volt/*; do
    rm -f $FILE
done;

# Missing files spam log fix
if [ ! -f /data/system/fmmpassword.key ]; then
    touch /data/system/fmmpassword.key
    chmod 600 /data/system/fmmpassword.key
    chown system:system /data/system/fmmpassword.key
fi
if [ ! -f /data/system/users/0/personalist.xml ]; then
    touch /data/system/users/0/personalist.xml
    chmod 600 /data/system/users/0/personalist.xml
    chown system:system /data/system/users/0/personalist.xml
fi

# Remount rw
mount -o remount,rw -t auto /system

# Create init.d folder if not exist
if [ ! -d /system/etc/init.d ]; then
    mkdir -p /system/etc/init.d;
fi

chown -R root.root /system/etc/init.d;
chmod 777 /system/etc/init.d;

if [ "$(ls -A /system/etc/init.d)" ]; then
    chmod 777 /system/etc/init.d/*;

    for FILE in /system/etc/init.d/*; do
        log_print "Trying to execute - $FILE"
        sh $FILE >/dev/null;
        log_print "$FILE executed"
    done;
else
    log_print "No init.d files found"
fi

# Unmount
mount -t rootfs -o remount,ro rootfs
mount -o remount,ro /system
mount -o remount,rw /data
mount -o remount,ro /

# Exit
   log_print "**volt scripts finished at $( date +"%d-%m-%Y %H:%M:%S" )**"
   log_print "------------------------------------------------------"

# Wait for boot complete first
while [[ $(getprop sys.boot_completed) != "1" ]]; do
	sleep 1;
done

# Set maximum swappiness
echo 130 > /proc/sys/vm/swappiness;

# Set page-cluster to lowest to maximize performance
echo 0 > /proc/sys/vm/page-cluster;
