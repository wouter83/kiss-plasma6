#!/bin/sh

PKG="$2"

case $1 in
    pre-build)
        cat /proc/uptime > "${KISS_TMPDIR:-/tmp}/_kiss_start"
    ;;
    
    post-build)
        IFS=. read -r _start _ < "${KISS_TMPDIR:-/tmp}/_kiss_start"
        IFS=. read -r _end _ < /proc/uptime
        
        rm -f "${KISS_TMPDIR:-/tmp}/_kiss_start"
        
        (
            _s=$((_end - _start))
            _h=$((_s / 60 / 60 % 24))
            _m=$((_s / 60 % 60))
            
            [ "$_h" = 0 ] || _u="${_u}${_h}h "
            [ "$_m" = 0 ] || _u="${_u}${_m}m "
            
            echo "-> %s %s\n" "$PKG" "Build finished in ${_u:-${_s}s}"
        )
    ;;
    queue-status|queue)
        [ -t 2 ] && {
            echo '\033]0;kiss: %s (%d/%d)\a' \
                "$2" "${3:-?}" "${4:-?}" >&2
        }
    ;;
     build-fail)
        echo "-> %s %s\a\n" "$2" "Dropped into shell"
        sh >/dev/tty
    ;;
esac
