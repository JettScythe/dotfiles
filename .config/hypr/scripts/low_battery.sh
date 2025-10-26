#!/bin/sh

while true; do
    # Get the battery device path (assuming there is only one battery)
    battery_device=$(upower -e | grep BAT)
    
    # Query the battery information
    battery_info=$(upower -i "$battery_device")

    # Get the battery percentage and time to empty
    battery_percentage=$(echo "$battery_info" | grep -E "percentage" | awk '{print $2}' | tr -d '%')
    time_to_empty=$(echo "$battery_info" | grep -E "time to empty" | awk '{print $4, $5}')
    battery_state=$(echo "$battery_info" | grep -E "state" | awk '{print $2}')
    

    # Check if the battery percentage is 15 or less
    if [ "$battery_percentage" -le 15 ] && [ "$battery_state" == "discharging" ]; then
        notification_id=$(dunstify -u CRITICAL "Low battery: ${battery_percentage}% 
Time to empty: ${time_to_empty}" -p)
		# Check every 10 seconds to see if the battery has started charging
		while [ "$battery_state" = "discharging" ]; do
		    # Re-query the battery state
		    battery_state=$(upower -i "$battery_device" | grep -E "state" | awk '{print $2}')
		            
		    # If charging, close the notification using the ID
		    if [ "$battery_state" = "charging" ]; then
		    	dunstify -C "$notification_id"
		            break
		        fi
		        sleep 10
		    done
        sleep 240
    else
        sleep 120
    fi
done
