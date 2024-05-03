#!/usr/bin/env sh
while true; do
    sleep 1
    volume=$(amixer sget Master | awk 'NR==6 {print substr ($5, 2, length($5)-2)}' | awk '{print substr($1, 1, length($1)-1)}')
    mutestate=""
    mutestate=$(amixer sget Master | awk 'NR==6 {print substr ($6, 2, length($6)-2)}')

    if [ "$(date +'%S')" -eq 0 ]; then
        datetime=$(date +"%a. %b %e, %G %I:%M %p")
    fi

    seconds=$(date +'%S')
    if [ "$((10#$seconds % 5))" -eq 0 ]; then
        memory_used=$(free -h | awk 'NR==2 {print substr ($3, 1, length($3)-1)}')
        memory_total=$(free -h | awk 'NR==2 {print substr ($2, 1, length($2)-1)}')
        memory_percentage=$(free | awk 'NR==2 {printf "%.2f", $3/$2 * 100}';)
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    fi

    case $mutestate in
        on) #if not muted
            if [ "$volume" -eq 0 ]; then
                    volume_string=" : $volume%"
                elif
             [ "$volume" -ge 1 ] && [ "$volume" -le 40 ]; then
                    volume_string=" : $volume%"
                elif 
             [ "$volume" -ge 41 ] && [ "$volume" -le 100 ]; then
                    volume_string="  : $volume%"
                else

                    volume_string=" TOO LOUD : $volume%"
            fi
            ;;
        off) 
            volume_string="󰝟 : $volume%"
            ;;
    esac

    if echo "$cpu_usage" | grep -Eq '^[0-9]+$'; then
        xsetroot -name "[ $volume_string ] [  : $memory_used/$memory_total ($memory_percentage%) ] [  : $cpu_usage.0% ] $datetime "
        else
        xsetroot -name "[ $volume_string ] [  : $memory_used/$memory_total ($memory_percentage%) ] [  : $cpu_usage% ] $datetime "
    fi

done
