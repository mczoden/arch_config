set --universal --export BROWSER chromium
set --universal --export EDITOR vim
set --universal --export GREP_COLOR 36
set fish_greeting

env -i HOME=$HOME dash -l -c printenv | sed -e '/PATH/s/:/ /g;s/=/ /;s/^/set -x /' | source

set --universal fish_user_paths ~/pro/le-jour $fish_user_paths
set --unexport fish_color_valid_path
