# CS4303Group14
- Split-screen - DONE
    - Note that every time you call a draw statement (line, zoom, translate, fill, etc) you need to call CS4303SPACEHAUL.offScreenBuffer.(line, zoom, translate, etc). This is because we draw to the buffer, and then later draw to the screen. Sorry about the inconvenience. 
- Player movement - DONE
    - Move player 1 with WASD keys, W thrusts in current direction, S reverses, A and D rotate/
    - Player 2 moves with arrow keys, as above.
- Gravity initial framework - DONE
    - Body superclass should be extended to all bodies that exert or are impacted by gravity.
    - We can make it more complicated and realistic if we want later, I just wanted to have something working now.