set --erase LANGUAGE
set --erase LC_CTYPE

set --universal --export BROWSER chromium
set --universal --export EDITOR vim
set --universal --export GREP_COLOR 36
set fish_greeting

env -i HOME=$HOME dash -l -c printenv | sed -e '/PATH/s/:/ /g;s/=/ /;s/^/set -x /' | source

set PATH ~/pro/le-jour $PATH
set --unexport fish_color_valid_path

set --universal __mc_os (uname)
