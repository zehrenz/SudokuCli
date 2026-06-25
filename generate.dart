import 'dart:io';
import 'dart:math';

import 'engine.dart';

void main() {
  var puzzleStr = readEmpty();

  int passed = 0;
  int failed = 0;
  for (int i = 0; i < 100; i++) {
    var engine = SudokuEngine(puzzleStr, true);
    if (generateBoard(engine)) {
      passed++;
    } else {
      failed++;
    }
  }
  print('Passed: $passed');
  print('Failed: $failed');
}

bool generateBoard(SudokuEngine engine) {
  int index = 0;
  while (!engine.solved) {
    int row = index ~/ 9;
    int col = index % 9;
    if (engine.cells[row][col].value == 0) {
      try {
        fillInHouses(row, col, engine);
      } catch (e) {
        print(engine.getBoardString());
        print(
          'Tried to fill in houses for row ${row + 1} col ${col + 1} but got an error:',
        );
        print('Error: $e');
        return false;
      }
    }
    index++;
  }
  print(engine.getBoardString());
  return true;
}

String readEmpty() {
  var rawFile = File('./puzzles/empty.txt').readAsStringSync();
  rawFile = rawFile.replaceAll(RegExp(r'\r\n'), '\n');
  rawFile = rawFile.replaceAll(RegExp(r'\n\r'), '\n');
  var puzzleStr = rawFile.endsWith('\n')
      ? rawFile.substring(0, rawFile.length - 1)
      : rawFile;
  return puzzleStr;
}

extension RandomElement<T> on Iterable<T> {
  T get randomElement => elementAt(Random().nextInt(length));
}

void fillInHouses(int row, int col, SudokuEngine engine) {
  fillRow(row, engine);
  fillCol(col, engine);
  fillBox(row ~/ 3, col ~/ 3, engine);
}

void fillRow(int row, SudokuEngine engine) {
  for (int col = 0; col < 9; col++) {
    var cell = engine.cells[row][col];
    if (cell.value == 0) {
      engine.placeVal(row, col, cell.candidates.randomElement);
    }
  }
}

void fillCol(int col, SudokuEngine engine) {
  for (int row = 0; row < 9; row++) {
    var cell = engine.cells[row][col];
    if (cell.value == 0) {
      engine.placeVal(row, col, cell.candidates.randomElement);
    }
  }
}

void fillBox(int boxRow, int boxCol, SudokuEngine engine) {
  for (int row = boxRow * 3; row < boxRow * 3 + 3; row++) {
    for (int col = boxCol * 3; col < boxCol * 3 + 3; col++) {
      var cell = engine.cells[row][col];
      if (cell.value == 0) {
        engine.placeVal(row, col, cell.candidates.randomElement);
      }
    }
  }
}
