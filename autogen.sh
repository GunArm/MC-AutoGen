#!/bin/bash
#set -x

# How to use:
# 0.  Put this script in your minecraft server root with LaunchServer.sh
# 1.  From the minecraft server root directory, run your server inside a 'screen' session with the following command
#        screen -dmSL minecraft sh LaunchServer.sh
# 2.  Log your player in
# 3.  Set the 'user' line below to your player name
# 4.  To start exploring run
#        ./autogen.sh
# 5.  Press CTRL-C to stop (assuming you don't reach max_distance)
# 6.  If you want to resume, from the previously quit *jump number* run: 
#        ./autogen.sh [jumpnumber]

# Note: It teleports to the max height first and then "climbs" in y-jumps to try to trigger some of the ruins proximity command blocks


user="Gun_Arm";
startx=0;
startz=0;
jump=110;
max_distance=10000; # block distance to bail

miny=60;
jumpy=17;
maxy=260;
if [ -z "$1" ]; then skip=0; else skip=$1; fi

function cool_cpu
{
    threshold=25
    current=$(mpstat 1 1 | awk '$12 ~ /[0-9.]+/ { print int(100 - $12 + 0.5) }')
    while [[ "$current" -ge "$threshold" ]]; do
        echo "CPU% $current >= $threshold"
        current=$(mpstat 1 1 | awk '$12 ~ /[0-9.]+/ { print int(100 - $12 + 0.5) }')
    done
}

function check_session
{
    if ! screen -list | grep -q "minecraft"; then
        echo "Server screen-session is not active"
        quit;
    fi
}

function teleport
{
    check_session;
    screen -S minecraft -p 0 -L -X stuff "/tp $user $1 $2 $3
"
}

function use_location
{
    MCX=$1;
    MCZ=$2;

    teleport $MCX $maxy $MCZ;
    cool_cpu;
    
    if [[ 1 -eq 1 ]]; then
        for (( height=$miny; $height < $maxy; height=$(($height + $jumpy)) ))
        {
            echo "y->$height"
            teleport $MCX $height $MCZ;

            sleep .5;
        }
    cool_cpu;
    fi
    sleep 1;
}

function quit
{
    exit 1;
}

function react_to_output
{
    if [ ! -f "screenlog.0" ]; then return; fi
    mv screenlog.0 screenlog.tmp
    if grep -q "That player cannot be found" "screenlog.tmp"; then
	      echo "$user is not connected."
        quit;
    fi
    rm screenlog.tmp
}

function spiral 
{
    rm screenlog.*

    x=0;
    y=0;
    dx=0;
    dy=-1;
	
    t=$(($max_distance / $jump)) 
    total_jumps=$(($t * $t));
	
    #cool_cpu;
    #teleport $startx $maxy $startz
    cool_cpu;

    for (( i=1; $i < $total_jumps + 1; i=$(($i + 1)) ))
    {
        react_to_output;
        
        MCX=$(($startx + $jump * $x));
        MCZ=$(($startz + $jump * $y));

        if [[ $i -ge $skip ]]; then 
            echo "$i out of $total_jumps : MC x,y : $MCX, $MCZ";
            use_location $MCX $MCZ;
        else 
            echo "skipping jump $i";
        fi
	

        if [[ ( $x -eq $y ) || ( ( $x -lt 0 ) && ( $x -eq $((-1 * $y)) ) ) || ( ( $x -gt 0 ) && ( $x -eq $((1 - $y)) ) ) ]]; then
            t=$dx;
            dx=$((-1 * $dy));
            dy=$t;
        fi
		
        x=$(($x + $dx));
        y=$(($y + $dy));
    }
    echo "Exploration Completed!";
}

spiral
