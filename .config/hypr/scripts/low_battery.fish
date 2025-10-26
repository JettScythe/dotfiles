#!/usr/bin/env fish

function get_battery_info
    set battery_device (upower -e | string match '*BAT*')
    set battery_info (upower -i $battery_device)

    set battery_percentage (echo $battery_info | string match -r 'percentage:\s*[0-9]+' | string replace -r '[^0-9]' '')
    set battery_state (echo $battery_info | string match -r 'state:\s*\w+' | string replace -r 'state:\s*' '')
    set time_to_empty (echo $battery_info | string match -r 'time to empty:\s*[0-9.]+\s*\w+' | string replace -r 'time to empty:\s*' '')

    echo "$battery_percentage|$battery_state|$time_to_empty"
end

while true
    set info (get_battery_info)
    set battery_percentage (echo $info | cut -d '|' -f1)
    set battery_state (echo $info | cut -d '|' -f2)
    set time_to_empty (echo $info | cut -d '|' -f3)

    if test $battery_percentage -le 15; and test $battery_state = discharging
        set notification_id (dunstify -u CRITICAL "Low battery: $battery_percentage% 
Time to empty: $time_to_empty" -p)

        while test $battery_state = discharging
            set info (get_battery_info)
            set battery_state (echo $info | cut -d '|' -f2)

            if test $battery_state = charging
                dunstify -C $notification_id
                break
            end
            sleep 10
        end

        sleep 240
    else
        sleep 120
    end
end
