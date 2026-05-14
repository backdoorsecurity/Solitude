su -l SECURITY -c "DISPLAY=:0 XAUTHORITY=/root/.Xauthority /usr/bin/firejail --debug --profile=/SECURITY/.config/firejail/falkon/falkon.profile /usr/bin/falkon"
