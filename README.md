# SudokuCli

A simple sudoku cli game. Can read puzzles from input. Currently only works on 9x9 games. Can auto solve simple puzzles when passed the -a flag.

This works by calculating the candidates for any given box. If auto solve is on, it will search for any box with a single candidate, place that value in the box, and then restart the search for a new single-candidate box. If none are found it will return to the input loop.

It can be run with the following command:

```bash
dart main.dart [-a] {puzzle_file}
```

A user can pass a value in the form of `[row][col][value]`. If that is a valid value for that square, it will be placed and candidates will be updated, otherwise an error will be shown. There is no backtracking for now so once a value is placed it cannot be changed.

## Future plans

- improve solving tricks
- allow value replacement
- indicate starting values
- handle different sized games
