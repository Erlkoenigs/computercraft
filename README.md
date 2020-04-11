## getGithub
Downloads programs from this repository onto a turtle. The name of the program can be a command line argument:

`getGithub strip`

downloads the _strip_ program.

With

`wget https://raw.githubusercontent.com/Erlkoenigs/computercraft/master/getGithub.lua getGithub.lua`

this script can be loaded onto the turtle initially.

## strip
Creates parallel 1x2 tunnels (or "strips"). On it's way back down each strip the turtle will scan for and mine ore veins.
If, at any point, the turtles inventory is full, it will return to an item chest, dump its contents and return back to where it left off.

Variable parameters:
* direction in which new strips will be created
* amount of strips that will be created
* length of strips

Parameters can be input via command line arguments:

`strip r 5 50`

creates 5 strips to the right of the starting position with a length of 50.
Alternatively the turtle will ask for these parameters one by one.

Setup:
* chest to dump items into behind the starting position
* chest with fuel to the left of the item chest
* chest with torches to the left of the fuel chest

The turtle will try to fill the fuel and troch slots to 64 items every time it returns to dump its inventory into the item chest.
If there's not enough fuel or torches in the chests, it will wait until there is.

The entrance of a finished strip can be marked by a torch. The turtle will do the same and skip, but still count, marked strips.

Spacing between strips is 3 by default. This can be changed by modifying the _stripSpacing_ variable. The turtle will place torches every 12 blocks. This can be changed by modifying the _torchDistance_ variable.

## quarry
Mimics a buildcraft quarry with a variable radius und depth.

The starting position is the middle of the area it will mine.

The center block is excluded from the radius, the diameter is 2xr+1: _r = 2_ will mine a 5x5 area.

Can be used to level an area to a certain depth.

Needs fuel in the first slot.

## lavaTunnel
This program will create a 1x2 tunnel of variable length by placing a dummy material above, below and to the sides of it. This can be used to clear a path of a lava flow.

Usage:
* fuel in the first slot
* dummy material in the second slot

## bridge
Builds a simple bridge with a width of one block. 

The length is variable and can be input through command line arguments.

The turtle will not return after it is finished. 

If it is out of material, it will wait until it isn't.

Usage:
* fuel in first slot
* bridge material in second slot
