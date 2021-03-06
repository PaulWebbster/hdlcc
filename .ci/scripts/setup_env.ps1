# This file is part of HDL Code Checker.
#
# Copyright (c) 2016 Andre Souto
#
# HDL Code Checker is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# HDL Code Checker is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with HDL Code Checker.  If not, see <http://www.gnu.org/licenses/>.

write-host "Configured builder is $env:BUILDER"

if ($env:ARCH -eq 32) {
    $env:python_path = "C:\Python$env:PYTHON_VERSION"
} else {
    $env:python_path = "C:\Python$env:PYTHON_VERSION-x64"
}

$env:PATH="$env:python_path;$env:python_path\Scripts;$env:PATH"

Start-Process "git" -RedirectStandardError git.log -Wait -NoNewWindow -ArgumentList `
    "submodule update --init --recursive"
get-content git.log

if ($env:APPVEYOR -eq "True") {
    appveyor DownloadFile https://bootstrap.pypa.io/get-pip.py
    if (!$?) {write-error "Something went wrong, exiting"; exit -1}
    python get-pip.py
}

pip install -r requirements.txt
pip install git+https://github.com/suoto/rainbow_logging_handler
if (!$?) {write-error "Something went wrong, exiting"; exit -1}

# if (!(Test-Path $env:CACHE_PATH)) {
#     new-item "$env:CACHE_PATH" -type directory -force
# }

if ("$env:BUILDER" -eq "msim") {
    echo "Installing MSIM"
    . "$env:APPVEYOR_BUILD_FOLDER\\.ci\\scripts\\setup_msim.ps1"
    if (!$?) {write-error "Something went wrong, exiting"; exit -1}
} elseif ("$env:BUILDER" -eq "ghdl") {
    echo "Installing GHDL"
    . "$env:APPVEYOR_BUILD_FOLDER\\.ci\\scripts\\setup_ghdl.ps1"
    if (!$?) {write-error "Something went wrong, exiting"; exit -1}
} else {
    echo "No builder selected"
}

pip install -U -e $env:APPVEYOR_BUILD_FOLDER
if (!$?) {write-error "Something went wrong, exiting"; exit -1}

write-host "Arch is $env:ARCH, Python selected is $env:python_path"

