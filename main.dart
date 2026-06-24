import 'dart:io';

import 'colors.dart';
import 'engine.dart';

var error = '';
void main(List<String> args) {
  bool autoSolve;
  String rawFile;
  if (args[0] == '-a') {
    autoSolve = true;
    rawFile = File(args[1]).readAsStringSync();
  } else {
    autoSolve = false;
    rawFile = File(args[0]).readAsStringSync();
  }
  rawFile = rawFile.replaceAll(RegExp(r'\r\n'), '\n');
  rawFile = rawFile.replaceAll(RegExp(r'\n\r'), '\n');
  var puzzleStr = rawFile.endsWith('\n')
      ? rawFile.substring(0, rawFile.length - 1)
      : rawFile;
  var engine = SudokuEngine(puzzleStr, autoSolve);
  inputLoop(engine);
}

void inputLoop(SudokuEngine engine) {
  var skipBoard = false;
  while (!engine.solved) {
    if (skipBoard) {
      skipBoard = false;
    } else {
      print(engine.getBoardString());
    }

    if (!error.isEmpty) {
      print(red(error));
      error = '';
    } else {
      print('');
    }

    stdout.write('${engine.autoSolve ? "[auto] " : ""}sudoku > ');
    var input = stdin.readLineSync();
    if (input != null) {
      if (input == 'exit') {
        return;
      }
      if (input == 'auto') {
        engine.toggleAutoSolve();
        continue;
      }
      if (input == 'solve') {
        engine.solve();
        continue;
      }
      if (input == 'help' || input == '') {
        showHelp();
        // Skip printing the board after showing help
        skipBoard = true;
        continue;
      }
      var (row, col, val) = parseInput(input);
      if (row != null && col != null && val != null)
        error = engine.placeVal(row, col, val);
    }
  }
  print(engine.getBoardString());
}

void showHelp() {
  print(
    '''
Enter a guess or a command (see below).
A guess is a row (a-i), column (1-9), and value (1-9) to place in the puzzle.
\tex: 'a45' places '5' at row 'a' col '4'
A guessed value must be a candidate for that cell.

Commands:
\tsolve:\ttry to solve the puzzle
\tauto:\ttoggle auto-solve and try to solve the puzzle if enabled
\thelp:\tshow help
\texit:\texit the program

Note: Auto-solve will only place values that are the only candidate for a cell. It will not guess.
      If auto-solve is enabled, it will try to solve the puzzle after each guess.''',
  );
}

var aCode = 'a'.codeUnitAt(0);
var iCode = 'i'.codeUnitAt(0);

(int?, int?, int?) parseInput(String input) {
  var parts = input.length == 3 ? input.split('') : input.split(' ');
  if (parts.length != 3) {
    error = 'Invalid number of arguments';
    return (null, null, null);
  }
  var rowStr = parts[0];
  var colStr = parts[1];
  var valStr = parts[2];
  if (rowStr.length > 1 ||
      rowStr.codeUnitAt(0) < aCode ||
      rowStr.codeUnitAt(0) > iCode) {
    error = 'Invalid row: ${rowStr}';
    return (null, null, null);
  }
  var parsedRow = rowStr.codeUnitAt(0) - aCode;
  var parsedCol = int.tryParse(colStr);
  var parsedVal = int.tryParse(valStr);
  if (parsedCol == null || parsedCol < 1 || parsedCol > 9) {
    error = 'Invalid col: ${colStr}';
    return (null, null, null);
  }
  if (parsedVal == null || parsedVal < 1 || parsedVal > 9) {
    error = 'Invalid value: ${valStr}';
    return (null, null, null);
  }
  return (parsedRow, parsedCol - 1, parsedVal);
}
