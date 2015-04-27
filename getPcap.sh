#!/bin/bash
# input:  date source.IP destination.IP
# date is in format of: YYYY-MM-DD

display_usage() {
        echo -e "\n\nUSAGE: getPcap source.ip destination.ip\n\n"
                echo -e "This script can take a long time to run against all PCap files."
}

# if less than two arguments supplied, display usage
if [ $# -le 1 ]; then
        display_usage
        exit 1
fi

# check whether user had supplied -h or --help . If yes display usage
if [[ ($# == "--help") || ($# == "-h") ]]; then
        display_usage
        exit 0
fi

# if output directory doesn't exist then create it
if [ ! -d "./pcap" ]; then
        mkdir ./pcap
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

rm ./pcap/*.pcap

x=1
# iterate through all pcap files and extract searched for packets
for i in `find $pdate -type f`;
  do
    echo $i
    tshark -r $i -R "(ip.src == $1 and ip.dst == $2) or (ip.dst == $1 and ip.src == $2)" -w ./pcap/$x.pcap
    x=$((x+1))
  done
# merge all pcaps created in /home/so/pcap into one file
rm ./pcap/pcap.out
mergecap ./pcap/* -w ./pcap/pcap.out
# remove all pcaps but leave pcap.out alone
rm ./pcap/*.pcap
# rename pcap.out to out.pcap so we can open it with Wireshark
mv ./pcap/pcap.out ./pcap/out.pcap
