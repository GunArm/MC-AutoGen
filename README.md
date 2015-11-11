# MC-AutoGen

Minecraft world auto-gen/pre-gen script which should always work and not depend on anything like bukkit or forge.  

It works by automatically sending commands to the server console to teleport the player in an expanding spiral from a starting point.  It has the ability to wait for the cpu to cool down from the work of each jump before continuing on.  The distance between the jumps is what I have found to be optimal.  It first teleports the player to a max height, waits for the cpu to cool as the new terrain generates and loads, then it climbs up a y range to try to trigger some of the ruins command blocks if there are any nearby.  

If you are not using ruins or don't care about the trying to thin out some of the proximity build command blocks, you can disable the y climbing in the use_location function.  

Aside from being self contained, independant of any mod configuration, this autogen solution has the advantage of generating a map if you do have a mapmod on the client which is being teleported around.


In order for the script to send commands to the server console, the console has to be run in a virtual terminal.  Use the command "screen -dmSL minecraft sh LaunchServer.sh".  You can attach to the screen session with "screen -r" if you still want manual access to the server console.  Then to start the teleporting, run "./autogen.sh".  If you stop it with control-c, note the jump number it was on.  You can resume with "./autogen [jumpnumber]".  

Please note that the script also reacts to the output of the server console.  If it tries to teleport, but the server says "the player is offline", the script will bail.  This is useful because when you leave this running over night, after exploring a very large area, the client sometimes crashes, I don't know why, maybe video memory.  The script stopping allows you to see what the last jump number was and resume.  For this to work, the script reads the console output which screen is writing to screenlog.0 thanks to the -L flag in the server launch command.  
TL;DR: For it to work right, put autogen.sh in the same folder as LaunchServer.sh and run all the commands from that folder as your working directory.


How to use:
0.  Put this script in your minecraft server root with LaunchServer.sh
1.  From the minecraft server root directory, run your server inside a 'screen' session with the following command
      screen -dmSL minecraft sh LaunchServer.sh
2.  Log your player in
3.  Set the 'user' line below to your player name
4.  To start exploring run
      ./autogen.sh
5.  Press CTRL-C to stop (assuming you don't reach max_distance)
6.  If you want to resume, from the previously quit *jump number* run: 
      ./autogen.sh [jumpnumber]
