# computercraft
Lua scripts for Minecrafts Computercraft Mod

## getGithub
Can be used to download programs from this repository onto a turtle. The name of the program can be a command line argument

`getGithub strip`

downloads the _strip_ program.

With

`wget https://raw.githubusercontent.com/Erlkoenigs/computercraft/master/getGithub.lua getGithub.lua`

this script can be loaded onto the turtle initially.

## strip
Creates parallel 1x2 tunnels (or "strips"). On it's way back down the strip the turtle will scan for and mine ore veins.
If, at any point, the turtles inventory is full, it will return to an item chest, dump its contents and return back to where it left off.

Variable parameters:
* direction in which new strip will be created
* amount of strips that will be created
* length of strips

Parameters can be input via command line arguments:

`strip r 5 50`

This creates 5 strips to the right of the starting position with a length of 50.
Alternatively the turtle will ask for these parameters one by one.

Setup:
* chest to dump items into behind the starting position
* chest with fuel to the left of the item chest
* chest with torches to the left of the fuel chest

The turtle will try to fill the fuel and troch slots to 64 items every time it returns to dump its inventory into the item chest.
If there's not enough fuel or torches in the chest, it will wait until there is.

The entrance of a finished strip can be marked by a torch. The turtle will do the same and skip, but still count, marked strips.

## quarry
This script makes the turtle place Land Marks in a horizontal rectangular area with a variable width and depth. This is needed to start a Buildcraft Quarry.

A Buildcraft Quarry mines a volume of blocks underneath its starting area. The starting area is setup and defined by Land Marks that have to be placed in a square with a maximum size of 63 by 63 blocks.

Usage:
* The turtle has to be set on one of the corners of the area you want to mark
* It will always turn left, thus it will create the square of Land Marks to the front left of its starting position
* In the first slot it needs fuel
* In the second slot it needs 4 Land Marks
* In the third slot it needs a dummy material like dirt or cobblestone. If one of the quarrys corners would be in the air, the dummy material is placed as a base to place the Land Mark on

Problems:
* This script wont detect liquids. It will place a Land Mark even when it's under water/lava, which will wash away and drop the Land Mark immediately.
* It only turns left
* Materials have to be put in manually and into specific slots
* The turtle doesn't check for Land Marks and dummy material

## lavaTunnel
This program will create a 1x2 tunnel of variable length by placing a dummy material above, below and to the sides of it. This can be used to clear a path of a lava flow.

Usage:
* place turtle in front of a lava flow you want to pass
* input fuel in the first slot
* input dummy material in the second slot
* start the program and input the desired length of the tunnel
