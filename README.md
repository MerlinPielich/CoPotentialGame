## Assembly game

### Project description
We will be implementing the game together:

Merlin Pielich 4847490

Michael Hempel  6531695

Os to use: Home made.

libraries:
* GLFW
* glew
* OpenGL
* C standard library

Rendering will be done directly by passing variables to openGL (using glew). 
Can be seen in the game description


### Game description
* The game is rendered in 2D
* The player is a cute little orb/ball/thing
* The player controls this object with WASD
* The player will interact with the game, solely by using the keyboard
* There are objects bouncing around
* There is a clock in the top right corner that shows the player how much time, since the beginning of the game, has passed.
* Whenever the player character collides with one of the bouncing objects, the game ends
* Optional: After x amount of time, the number of bouncing objects increases
* When the game ends
* The scores will be stored in a file
* The players score will be shown in relation to the other scores
* player 1, 2, 3, 4… etc.
* The player can then restart the game
* The player will be scored based on the time they managed to survive
* Sprites will be used to distinguish between player, background and bouncing balls (or whatever they may be)
