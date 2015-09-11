#!/bin/bash
# input:  date source.IP destination.IP
# date is in format of: YYYY-MM-DD

display_usage() {
        echo -e "\n\nUSAGE: getPcap IP start_time end_time\n\n"
}

# if three arguments not supplied, display usage
if [ $# -ne 3 ]; then
        display_usage
        exit 1
fi

# check whether user had supplied -h or --help . If yes display usage
if [[ ($# == "--help") || ($# == "-h") ]]; then
        display_usage
        exit 0
fi

# Displays a list of directories in packet capture directory and prompt for which
# file to edit

# Set the prompt for the select command
PS3="Choose interface or 'q' to quit: "
echo -e "\n\n"

# Create a list of files to display
dirList=$(find /nsm/sensor_data/ -maxdepth 1 -mindepth 1 -type d | sort)

# Show a menu and ask for input. If the user entered a valid choice,
# then invoke the editor on that file
select dir in $dirList; do
    if [ -n "$dir" ]; then
        int=$dir
    else
                exit
    fi
    break
done

# Displays a list of directories in packet capture directory and prompt for which
# file to edit

# Set the prompt for the select command
PS3="Choose date or 'q' to quit: "
echo -e "\n\n"

# Create a list of files to display
dirList=$(find $int/dailylogs -maxdepth 1 -mindepth 1 -type d | sort)

# Show a menu and ask for input. If the user entered a valid choice,
# then invoke the editor on that file
select dir in $dirList; do
    if [ -n "$dir" ]; then
        pdate=$dir
    else
                exit
    fi
    break
done

cd $pdate
rm /tmp/merged.pcap

# from: http://unroutable.blogspot.com/2015/07/extracting-traffic-from-rolling-capture.html
# find all files created between the times of $2 and $3
find . -newerct $2 ! -newerct $3 | xargs -I {} tcpdump -r {} -w /tmp/{} host $1
# merge all pcaps created in /home/so/pcap into one file
mergecap -w /tmp/merged.pcap /tmp/snort*
# remove all pcaps used to created the merged pcap
rm /tmp/snort.log*

echo -e "\n\nMerged PCAP is /tmp/merged.pcap\n\n"
