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
# Coded by corsicanu
#
# Few things that need to be set even if unrooted
#

# Tamper fuse prop set to 0 on running system
    /volt/fakeprop -n ro.boot.warranty_bit "0"
    /volt/fakeprop -n ro.warranty_bit "0"
# Fix safetynet flags
    /volt/fakeprop -n ro.boot.veritymode "enforcing"
    /volt/fakeprop -n ro.boot.verifiedbootstate "green"
    /volt/fakeprop -n ro.boot.flash.locked "1"
    /volt/fakeprop -n ro.boot.ddrinfo "00000001"
    /volt/fakeprop -n ro.build.selinux "1"
# Samsung related flags
    /volt/fakeprop -n ro.fmp_config "1"
    /volt/fakeprop -n ro.boot.fmp_config "1"
    /volt/fakeprop -n sys.oem_unlock_allowed "0"
    /volt/fakeprop -n ro.knox.enhance.zygote.aslr "1"



