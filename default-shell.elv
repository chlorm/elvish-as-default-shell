# Copyright (c) 2018, 2020-2022, Cody Opel <cwopel@chlorm.net>
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
use github.com/chlorm/elvish-stl/exec
use github.com/chlorm/elvish-stl/os
use github.com/chlorm/elvish-stl/path
use github.com/chlorm/elvish-stl/platform


fn remove-old-rc {|target|
    var orig = $target'.original'
    if (and (not (os:is-file $orig)) (os:is-file $target)) {
        os:move $target $orig
    }
    if (os:is-file $target) {
        os:remove $target
    }
}

fn update-symlink {|source target|
    if (os:is-symlink $target) {
        if (==s (os:readlink $target) $source) {
            return
        }
        os:unlink $target
    }
    os:symlink $source $target
}

fn create-parent-dirs {|target|
    var targetDir = (path:dirname $target)
    if (not (os:is-dir $targetDir)) {
        os:makedirs $targetDir
    }
}

fn install-rc {|source target|
    remove-old-rc $target
    update-symlink $source $target
}

fn install-rc-windows {|source target|
    remove-old-rc $target
    create-parent-dirs $target
    os:copy $source $target
}

fn init-session-windows {|libDir|
    var rcFile = (path:join $libDir 'rc' 'Microsoft.PowerShell_profile.ps1')
    var psProfileArgs = [ 'echo' '$profile' ]
    try {
        # Look for powershell-core
        install-rc-windows $rcFile (exec:ps-out &cmd='pwsh' $@psProfileArgs)
    } catch _ { }
    install-rc-windows $rcFile (exec:ps-out $@psProfileArgs)
}

fn init-session-unix {|libDir|
    var rcFiles = [
        'bash_profile'
        'bashrc'
        'kshrc'
        'profile'
        'zprofile'
        'zshrc'
    ]

    var home = (path:home)
    for i $rcFiles {
        var s = (path:join $libDir 'rc' $i)
        var t = (path:join $home '.'$i)
        install-rc $s $t
    }
}

fn init-session {
    var url = 'github.com/chlorm/elvish-as-default-shell'
    var libDir = (epm:metadata $url)['dst']

    if $platform:is-windows {
        init-session-windows $libDir
        return
    }

    init-session-unix $libDir
}
