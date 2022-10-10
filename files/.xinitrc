#!/bin/bash
#

# export GALLIUM_DRIVER=llvmpipe
# Make sure XDG_RUNTIME_DIR is unprivilaged
#chmod +t /tmp;

true 'export XDG_RUNTIME_DIR="/tmp/.boodg";
mkdir -m 0700 -p "$XDG_RUNTIME_DIR" && chmod +t "$XDG_RUNTIME_DIR";
#sudo chmod 777 "$XDG_RUNTIME_DIR" && sudo chown -h axon:axon "$XDG_RUNTIME_DIR";
'

# Re-execute with dbus
true 'if test ! -v DBUS_LAUNCHED; then {
	echo "Re-launching self via dbus-launch";
	DBUS_LAUNCHED=true exec dbus-run-session "$0"; 
} else {
	unset DBUS_LAUNCHED;
} fi'

: "${DISPLAY:=":0"}"
export DISPLAY

# Load profile
for file in "/etc/profile" "$HOME/.profile" "/etc/xprofile" "$HOME/.xprofile"; do
    if [ -f "$file" ]; then
        echo "Loading profile from $file";
        . "$file"
    fi
done

# Load resources
for file in "$HOME/.Xresources" "/etc/X11/Xresources"; do
    if [ -f "$file" ]; then
        echo "Loading resource: $file"
        xrdb -merge "$file"
    fi
done

# Load keymaps
for file in "$HOME/.Xkbmap" "/etc/X11/Xkbmap"; do
    if [ -f "$file" ]; then
        echo "Loading keymap: $file"
        setxkbmap `cat "$file"`
        XKB_IN_USE=yes
    fi
done

# Load xmodmap if not using XKB
if [ -z "$XKB_IN_USE" ]; then
    for file in "$HOME/.Xmodmap" "/etc/X11/Xmodmap"; do
        if [ -f "$file" ]; then
           echo "Loading modmap: $file"
           xmodmap "$file"
        fi
    done
fi

unset XKB_IN_USE

# Run all system xinitrc shell scripts
#xinitdir="/etc/X11/xinit/xinitrc.d"
# if [ -d "$xinitdir" ]; then
#     for script in $xinitdir/*; do
#         echo "Loading xinit script $script"
#         if [ -x "$script" -a ! -d "$script" ]; then
#             . "$script"
#         fi
#     done
# fi


function process_not_running() {
	local _proc;
	for _proc in "$@"; do {
		pgrep "$_proc" 1>/dev/null || return 1;
	} done
}

# Desktop session
source $HOME/.xdesktop.xfce;