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

display() {
    if [ $(wc -l <<< "$1") -lt 30 ]; then
        echo "$1"
    else
        less <<< "$1"
    fi
}

listselect() {
	local -n list=$1
	list+=("Справка" "Выход")
	select opt in "${list[@]}"; do
	case $opt in
		Выход) return 0;;
		Справка) echo $2;;
		*)
			if [[ -z $opt ]]; then
				echo "Ошибка: введите число из списка" >&2
			else
				return $REPLY
			fi
			;;
	esac
	done
}

getunit() {
	local path=$(systemctl status $1 | sed -n 2p | cut -f2 -d"(" | cut -f1 -d";" | cut -f1 -d")")
	if [ -f "$path" ]; then
		echo "$path"
	else
		return 1
	fi
}

if [ "$EUID" -ne 0 ]; then
	echo "Запустите программу с правами администратора"
	exit
fi

if [ "$1" = "--help" ]; then
	echo 'Лабораторная работа "Управление системными службами и журналами (systemctl, journalctl)"

Данный скрипт позволяет интерактивно управлять службами и журналами.
Запустите скрипт без аргументов чтобы увидеть список возможностей.
'
	exit
fi

PS3=$'\n> '
options=(
	"Поиск системных служб"
	"Вывести список процессов и связанных с ними systemd служб"
    "Управление службами"
	"Поиск событий в журнале"
	"Справка"
	"Выйти"
)

select opt in "${options[@]}"
do
	case $opt in
	"Поиск системных служб")
		read -p "Введите имя службы или его часть: " filepath
        display "$(systemctl list-units --type=service | tail -n +2 | head -n -7 | grep "$filepath")"
		;;

	"Вывести список процессов и связанных с ними systemd служб")
        display "$(ps xaww -o'pid,unit,args' | grep -P '^\s+\d+\s+(\w|[@-])*\.service ')"
        ;;

	"Управление службами")
		readarray -t services < <(systemctl list-units --type=service | tail -n +2 | head -n -7 | cut -c 3- | cut -d ' ' -f 1)
		listselect services "Введите число, соответствующее интересующему сервису"
		res=$?
		[ $res == 0 ] && continue
		service=${services[res - 1]}
		select opt in "Включить службу" "Отключить службу" "Запустить/перезапустить службу" "Остановить службу" "Вывести содержимое юнита службы" "Отредактировать юнит службы" "Справка" "Назад"; do
		case $opt in
            "Включить службу")
                systemctl enable "$service"
                check $? "Служба включена" "Ошибка включения службы"
                ;;
            "Отключить службу")
                systemctl disable "$service"
                check $? "Служба выключена" "Ошибка выключения службы"
                ;;
            "Запустить/перезапустить службу")
                systemctl restart "$service"
                check $? "Служба перезапущена" "Ошибка перезапуска службы"
                ;;
            "Остановить службу")
                systemctl stop "$service"
                check $? "Служба остановлена" "Ошибка остановки службы"
                ;;
            "Вывести содержимое юнита службы")
                cat "$(getunit $service)"
                ;;
            "Отредактировать юнит службы")
                nano "$(getunit $service)"
                ;;
            "Справка")
                echo "Выбирете операцию на службой $service"
                ;;
            "Назад")
                break
                ;;
	        *) echo "Неправильная команда $REPLY";;
		esac
		done
		;;
	"Поиск событий в журнале")
		read -p "Введите имя службы или его часть: " servicename
		read -p "Введите степень важности: " priority
		read -p "Введите строку поиска: " query
		journalctl -p "$priority" -u "$servicename" -g "$query"
		;;
	"Справка")
		echo "Введите интересующую вас команду"
		;;
	"Выйти")
		break
		;;
	*) echo "Неправильная команда $REPLY";;
	esac
done
