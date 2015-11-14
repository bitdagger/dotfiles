# Browser
if [ -n "$DISPLAY" ] ; then
    BROWSER=chromium
else
    BROWSER=lynx
fi
export BROWSER
