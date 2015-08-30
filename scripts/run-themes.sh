#! /bin/sh

self=`basename $0`

case `echo -n` in
-n) echon () { echo    "$@\c"; } ;;
*)  echon () { echo -n "$@"  ; }
esac

themes_list () {
	find themes \
		-maxdepth 1 \
		-mindepth 1 \
		-type d \! -name '.*' \
		-printf "%f\n" |
	sort
}

hugo_theme () {
	(set -x; hugo server -vw --port=1313 --theme="$@" >&2) &
	echo $!
}

for t in `themes_list`
do
	theme_id=`hugo_theme $t`
	sleep 2

	case $theme_id in
	'') echo "$self: error starting theme \"$t\""
	    exit 2
	    ;;
	*) trap "(set -x;kill $theme_id); exit" 1 2 3 15
	   echo
	   echon "*** Theme \"$t\" server ID => $theme_id, hit return for next theme: "
	esac >&2

	read ok
	kill $theme_id
	trap 1 2 3 15
done
