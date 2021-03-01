# Copyright (c) 2018, Cody Opel <cwopel@chlorm.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


use epm
use platform
use github.com/chlorm/elvish-stl/os
use github.com/chlorm/elvish-stl/path


fn install-rc [source target]{
    if (os:is-symlink $target) {
        if (==s (os:readlink $target) $source) {
            return
        } else {
            os:unlink $target
        }
    } elif (and (not (os:is-file $target'.original')) (os:is-file $target)) {
        os:move $target $target'.original'
    } elif (os:is-file $target) {
        os:remove $target
    }

    if $platform:is-windows {
        os:copy $source $target
    } else {
        os:symlink $source $target
    }
}

fn init {
    var url = 'github.com/chlorm/elvish-as-default-shell'
    var libDir = (epm:metadata $url)['dst']

    if $platform:is-windows {
        var rcFile = $libDir'/rc/Microsoft.PowerShell_profile.ps1'
        var installPath = (powershell.exe -NonInteractive -Command 'echo $profile')
        install-rc $rcFile $installPath
        return
    }

    var rcFiles = [
        'bash_profile'
        'bashrc'
        'kshrc'
        'profile'
        'zprofile'
        'zshrc'
    ]

    var home = (get-env HOME)
    for i $rcFiles {
        install-rc $libDir'/rc/'$i $home'/.'$i
    }
}

init
