import 'dart:io';

import './engine.dart';

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
  print(engine.getBoardString());
  while (!engine.solved) {
    if (!error.isEmpty) {
      print(error);
      error = '';
    }
    stdout.write('sudoku > ');
    var input = stdin.readLineSync();
    if (input != null) {
      if (input == 'exit') {
        return;
      }
      if (input == 'help' || input == '') {
        showHelp();
        continue;
      }
      var (row, col, val) = parseInput(input);
      if (row == null || col == null || val == null) {
      } else
        error = engine.placeVal(row, col, val);
      print(engine.getBoardString());
    }
  }
}

void showHelp() {
  print('Available commands:');
  print('\thelp:\t\t\t\tshow help');
  print('\texit:\t\t\t\ttexit the program');
  print("\trow[a-i]col[1-9]val[1-9]:\tplace 'val' at row and col");
  print("\t  ex: a45\t\t\tplaces '5' at row 'a' col '4'");
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
