# Copyright (c) 2018, Cody Opel <codyopel@gmail.com>
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

# Rename existing files to file.old or something

fn install-rc [source target]{
  if (and ?(test -f $target'.original') ?(test -f $target)) {
    return
  }

  if ?(test -L $target) {
    if ?(==s (readlink -f $target) $source) {
      return
    } else {
      unlink $target
    }
  } elif (and (not ?(test -f $target'.original')) ?(test -f $target)) {
    mv $target $target'.original'
  } elif ?(test -f $target) {
    rm $target
  }

  ln -s $source $target
}

fn init {
  local:rc-files = [
    'bash_profile'
    'bashrc'
    'kshrc'
    'profile'
    'zlogout'
    'zprofile'
    'zshrc'
  ]

  local:home = (get-env HOME)

  for local:i $rc-files {
    # FIXME: hardcoded path, need a way to get elvish lib dir
    install-rc \
      $home'/.elvish/lib/github.com/chlorm/elvish-as-default-shell/rc/'$i \
      $home'/.'$i
  }
}

init
