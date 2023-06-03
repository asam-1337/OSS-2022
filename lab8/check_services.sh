#!/bin/bash

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S')]: $*" >&2
}

check() {
	if [ $1 -ne 0 ]; then
		err ${@:3}
		exit
	else
		echo $2
	fi
}


getunit() {
	local path=$(systemctl status $1 | sed -n 2p | cut -f2 -d"(" | cut -f1 -d";" | cut -f1 -d")")
	if [ -f "$path" ]; then
		echo "$path"
	else
		return 1
	fi
}

getextraperms() {
    getfacl $1 2>/dev/null | grep -v -E "^#" | grep -v "user::" | grep -E ":.w.$"
}

services=$(systemctl list-units --type=service | tail -n +2 | head -n -7 | cut -c 3- | cut -d ' ' -f 1)

for service in $services; do
    unit=$(getunit $service)
    perms=$(getextraperms $unit)
    if [ ! -z "$perms" ]; then
        echo "$service has a unit ($unit) with extra write permissions:"
        echo "  $perms"
    fi
    user=$(grep "User=" "$unit")

    readarray -t execs < <(grep -E "(ExecStart|ExecStartPre|ExecStartPost|ExecReload|ExecStop|ExecStopPost)=" "$unit")
    for directive in "${execs[@]}"; do
        execommand="${directive#*=}"
        executable=$(cut -f1 -d" " <<< "$execommand")
        executable="${executable/#-/}" # remove first -
        executableperms=$(getextraperms $executable)
        if [ ! -z "$executableperms" ]; then
            echo "$service has a directive (in $unit) with extra write permissions"
            echo "  directive: $directive"
            echo "  extra permissions: $executableperms"
        fi

        if [ ! "$user" = "User=root" ]; then
            owner=$(stat -c '%U' "$executable")
            if [ "$owner" = "root" ]; then
                if stat -L -c "%A" "$executable" | grep -q "s"; then
                    echo "$service is run under $user but has a directive (in $unit) with suid/guid executable owned by root"
                    echo "  directive: $directive"
                fi
            fi
        fi
    done
done
