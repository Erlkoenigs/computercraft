# computercraft
Lua scripts for Minecrafts Computercraft Mod

## strip
Creates parallel 1x2 tunnels (or "stips"). On it's way back down the strip the turtle will scan for and mine ore veins.
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
* chest to dump items into behind the strating position
* chest with fuel to the left of the item chest
* chest with torches to the left of the fuel chest

The turtle will try to fill the fuel and troch slots to 64 items every time it returns to dump its inventory into the item chest.
If there's not enough fuel of torches in the chest, it will wait until there is.
