# Tic Tac Toe

## Approach

### Textual Description

Tic Tac Toe is a 2-player game in which each player (represented by a symbol 'X' or 'O') plays consecutive turns. The game takes place on a 3x3 board, with each spot on the board initially empty. On each turn, a player marks a spot. The game finishes once:
- A player has marked 3 consecutive spots (row, column, or diagonal), who is declared as the winner, OR
- The board is full, and no player has 3 spots in a row (tie)

### Nouns & Verbs

*Nouns*:

- Game
- Player
  - Symbol
  - Turn
- Board
  - Spot
- Result
- Row/Diagonal/Vertical

*Verbs*:

- Play
- Mark (a spot)

### Possible Class Hierarchy

Game
  Play
  Board
    Spot
  Player
    Mark

### Spike

## CRC


## Questions

Note: I display the game state after each move (both human & computer) to create
the effect of each player taking some "response time" to take a turn

- Acceptable `result` instance variable (used as a "cache" for tracking the
 state of a match)
  - Pro: Easier than passing the result around many methods
  - Con: It doesn't tie super well into the class hierarchy: a `result` isn't
  really an attribute of an entire `game`, but rather a singular match
- `TutorialBoard`: Create a new superclass to inherit from?
  - Is it bad to inherit more functionality than needed?
- I felt that using a `Player` class was reasonable here, for the following behaviors:
  - Moving + marking behavior
  - Player names
  - etc.
- *Class Dependencies / Number of Classes*
  - **Feels like there's no way to "win"**:
  - Main "issue" in program: some of the classes might not work well in isolation
  - In my program, I do add two `Player` classes, each w/ behaviors that player would exhibit (I did not take the LS suggestion of removing it)
  - However, this does add a bit of complexity to the "dependency graph" of my classes:
    - Game => Board, Player
    - Board => Square
    - e.g. `Player` has a dependency on `board` -- even though they aren't *direct collaborators*, the `board` is required to make a move
      - *Alternative*: Remove the `Player` classes, contain the move methods in `Game`
      - But then I lose out on the player-specific functionality, which felt good?
      - How to navigate this dilemma?
  - *My solution*: Less-tighlty couple the `board` and `player` by **only directly updating board in orchestration class**, but allowing for **square selection** in the player classes

## Improvements & Bonus Features

- Made `MARKER` an instance variable `@marker` for a given `Player`