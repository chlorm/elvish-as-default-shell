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


use github.com/chlorm/elvish-stl/os


fn install-rc [source target]{
  if (and (os:is-file $target'.original') (os:is-file $target)) {
    return
  }

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

  os:symlink $source $target
}

fn init {
  local:rc-files = [
    'bash_profile'
    'bashrc'
    'kshrc'
    'profile'
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
