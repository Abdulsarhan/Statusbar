#!/usr/bin/env sh

# Define included/excluded modules
declare -A MODULES=(
    [datetime]=1
    [uptime]=1
    [memory_used]=1
    [memory_total]=1
    [memory_percentage]=1
    [cpu_usage]=1
    [packets_received]=
    [packets_sent]=
    [volume]=1
    [mutestate]=1
)

# Define associated get functions
get_datetime() {
    date +"%a. %b %e, %G %I:%M %p"
}

get_uptime() {
    uptime -p | sed 's/up //'
}

get_memory_used() {
    free -h | awk 'NR==2 {print substr ($3, 1, length($3)-1)}'
}

get_memory_total() {
    free -h | awk 'NR==2 {print substr ($2, 1, length($2)-1)}'
}

get_memory_percentage() {
    free | awk 'NR==2 {printf "%.2f", $3/$2 * 100}'
}

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}'
}

get_packets_received() {
    ip -s link show wlan0 | awk '/RX:/{getline; print "RX packets:", $1}'
}

get_packets_sent() {
    ip -s link show wlan0 | awk '/TX:/{getline; print "TX packets:", $1}'
}

get_volume() {
    amixer sget Master | awk 'NR==6 {print substr ($5, 2, length($5)-2)}' | awk '{print substr($1, 1, length($1)-1)}'
}

get_mutestate() {
    amixer sget Master | awk 'NR==6 {print substr ($6, 2, length($6)-2)}'
}
    for VAR in datetime uptime memory_used memory_total memory_percentage cpu_usage packets_received packets_sent volume mutestate; do
        if [ -z "${MODULES[$VAR]}" ]; then
            NOTINCLUDED+="$VAR "
            continue
        fi
    done
            echo "Warning: $NOTINCLUDED is not set in MODULES." 

            #sleep 5;
# Call get functions and update the variables
while true; do
    # Reset variables to empty
    datetime=""
    uptime=""
    memory_used=""
    memory_total=""
    memory_percentage=""
    cpu_usage=""
    packets_received=""
    packets_sent=""
    volume=""
    mutestate=""

    for VAR in datetime uptime memory_used memory_total memory_percentage cpu_usage packets_received packets_sent volume mutestate; do
        if [ -z "${MODULES[$VAR]}" ]; then
            echo "" >/dev/null 2>&1
            continue
        fi

        if [ "${MODULES[$VAR]}" -eq 1 ]; then
            value=$(get_$VAR)
            if [ -n "$value" ]; then
                eval "$VAR=\"$value\""
            fi
        fi
    done

    # Update volume_string based on mutestate and volume
    case $mutestate in
        on) #if not muted
            if [ -n "$volume" ]; then
                if [ "$volume" -eq 0 ]; then
                    volume_string=" : $volume%"
                elif [ "$volume" -ge 1 ] && [ "$volume" -le 40 ]; then
                    volume_string=" : $volume%"
                elif [ "$volume" -ge 41 ] && [ "$volume" -le 100 ]; then
                    volume_string="  : $volume%"
                else
                    volume_string=" TOO LOUD : $volume%"
                fi
            else
                volume_string=""
            fi
            ;;
        off) #if muted
            if [ -n "$volume" ]; then
                volume_string="󰝟 : $volume%"
            else
                volume_string=""
            fi
            ;;
        *)
            volume_string=""
            ;;
    esac
    
    if echo "$cpu_usage" | grep -Eq '^[0-9]+$'; then
        xsetroot -name "[ $volume_string ] [  : $memory_used/$memory_total ($memory_percentage%) ] [  : $cpu_usage.0% ] $datetime "
        else
        xsetroot -name "[ $volume_string ] [  : $memory_used/$memory_total ($memory_percentage%) ] [  : $cpu_usage% ] $datetime "
    fi
    #Uncomment the line bellow if your WM uses the standard output instead of xsetroot.
    #echo -e "[\033[38;5;214m \033[0m$volume_string ] \033[38;5;27m[ \033[38;5;39mmem : \033[38;5;27m$memory_used/$memory_total \033[38;5;27m($memory_percentage%\033[38;5;27m) ] \033[38;5;30m[ \033[38;5;37m : \033[38;5;33m$cpu_usage%\033[38;5;30m ] \033[38;5;244m$datetime\033[0m"

    sleep 1;
done
