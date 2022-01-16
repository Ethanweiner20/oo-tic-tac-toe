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
- **Class Dependencies / Number of Classes**:
  - Felt like my understanding of how to deal with dependencies, and where to place instance methods/variables, has improved just throughout the creation of this game
  - That said, I'm certainly still finding it a difficult tradeoff to navigate
  - **Feels like there's no way to "win"**:
    - We want the `Player` class to store player-specific info: marker, name, etc.
    - But `board` and `player` must interact on **some level**, which introduces dependencies that might be unnecessary
      - My solution: Not make them direct collaborators, but rather a more indirect dependency through just choosing a square #
      - Is this any better than a direct board<=>player coupling?
  - Main "issue" in program: some of the classes might not work well in isolation (requires board)
  - Decided to keep player and board "tightly coupled": players seemed to be better modeled as objects w/ roles (select square, retrieve name, etc.) -- it wouldn't read as well if all square selection & name retrieval logic were moved to the orchestration class
      - *Alternative*: Remove the `Player` classes, contain the move methods in `Game`
      - But then I lose out on the player-specific functionality, which felt good?
      - How to navigate this dilemma?
  - *Why?*
    - Intuition: Players are modely nicely as objects, each with a similar interface
    - Polymorphism between `User` and `Computer` (via inheritance): select squares, name retrieval, etc.
    - Small program => Dependency graph isn't *huge* (not much of an issue)
    - Adding dependencies was *necessary* for determining the optimal board square
      - Either the computer needs info about the board OR
      - the board needs to know about the player to find the optimal square for OR
      - the game needs to know about the individual squares => `Square` class dependencies
  - *Another Example*: Retrieving user & computer markers: Decided to keep this logic in the Game class. Why?
    - Possible markers are more of a game concern => `MARKERS` constant accessible
    directly in `TTTGame` class
    - Selection of computer marker *depends* on user marker selection => didn't want to pass the user marker over to the computer class -- felt like this was appropriate to be handled on the game-level
  - Interesting use: polymorphism w/ human VS computer players
- *What should be included in `initialize`*
  - Many parts of "initializing" the game require a good amount of work -- input retrieval, etc.
  - I decided to perform much of the `TTTGame` initialization in the `initialize` method itself, simply because it made sense from a naming perspective
  - I'm wondering if this is generally regarded as a good practice
    - Initialize to trivial values first, and then complete the full game setup somewhere else (e.g. in the `play` method)?
- Using more instance variables as a cache
  - e.g. `@final_winner` and `@result`
  - From a structural level, `TTTGame` does *have* a `@final_winner` and `@result` -- but only at certain points during the game. Most of the time, their value is simply `nil`. Is this a way that instance variables are commonly used?

## Improvements & Bonus Features

- Made `MARKER` an instance variable `@marker` for a given `Player`
- Extracted commonly used methods (across multiple programs) to modules

## More Improvements

- Bigger board (already implemented)
- More players (e.g. choose # of computers): computer & human
  - Appropriate for this assignment
  - Retrieve player # input on beginning
  - Question: How would the computer decide who to defend against?
    - Defensive/offensive algorithms would be more complicated...
  1. Update players instance variable to contain an array of players (humans &
  computers) X
    - Good use of **polymorphism**: any player
  2. Update existing methods to handle more than two users (e.g. display methods) X
  3. Update computer algorithm to handle multiple players X
    - Offensive *first* 
    - Defensive *second*, looping through multiple players to defend X
    - Middle square
    - Random