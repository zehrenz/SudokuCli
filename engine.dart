const COL_HEADER = '   1   2   3   4   5   6   7   8   9 \n';
const ROW_HEADER = '  a  b  c  d  e  f  g  h  i ';
var ROW_SPLITTER = blue('  ---+---+---+---+---+---+---+---+---\n');
var SUB_ROW_SPLITTER =
    '  ---+---+---${blue('+')}---+---+---${blue('+')}---+---+---\n';

String blue(Object str) {
  return '\x1B[34m${str}\x1B[0m';
}

String red(Object str) {
  return '\x1B[31m${str}\x1B[0m';
}

class SudokuEngine {
  List<List<Cell>> cells;
  bool autoSolve;
  bool _solving = false;

  SudokuEngine(String strGrid, this.autoSolve)
    : this.cells = parseInput(strGrid) {
    updateAllCandidates();
    if (autoSolve) solve();
  }

  String placeVal(int row, int col, int val) {
    var cell = cells[row][col];
    if (cell.value != 0) {
      return 'Cell already has a value';
    } else if (!cell.candidates.contains(val)) {
      return '${val} is not a candidate for that cell';
    }
    cell.setValue(val);
    updateRow(row, val);
    updateCol(col, val);
    updateBox(row ~/ 3, col ~/ 3, val);
    if (autoSolve && !_solving) solve();
    return '';
  }

  void solve() {
    _solving = true;
    try {
      var changed = true;
      while (changed) {
        changed = false;
        for (int row = 0; row < 9; row++) {
          for (int col = 0; col < 9; col++) {
            var cell = cells[row][col];
            if (cell.value == 0 && cell.candidates.length == 1) {
              placeVal(row, col, cell.candidates.first);
              changed = true;
            }
          }
        }
      }
    } finally {
      _solving = false;
    }
  }

  void updateAllCandidates() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        updateCandidates(row, col);
      }
    }
  }

  void updateRow(int row, int val) {
    for (int col = 0; col < 9; col++) {
      cells[row][col].candidates.remove(val);
    }
  }

  void updateCol(int col, int val) {
    for (int row = 0; row < 9; row++) {
      cells[row][col].candidates.remove(val);
    }
  }

  void updateBox(int boxRow, int boxCol, int val) {
    var rowBase = boxRow * 3;
    var colBase = boxCol * 3;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        cells[row + rowBase][col + colBase].candidates.remove(val);
      }
    }
  }

  void updateCandidates(int row, int col) {
    var cell = cells[row][col];
    if (cell.value != 0) return;
    updateCandidatesByRow(row, cell);
    updateCandidatesByCol(col, cell);
    updateCandidatesByBox(row ~/ 3, col ~/ 3, cell);
  }

  void updateCandidatesByRow(int row, Cell cell) {
    for (int col = 0; col < 9; col++) {
      cell.candidates.remove(cells[row][col].value);
    }
  }

  void updateCandidatesByCol(int col, Cell cell) {
    for (int row = 0; row < 9; row++) {
      cell.candidates.remove(cells[row][col].value);
    }
  }

  void updateCandidatesByBox(int boxRow, int boxCol, Cell cell) {
    var rowBase = boxRow * 3;
    var colBase = boxCol * 3;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        cell.candidates.remove(cells[row + rowBase][col + colBase].value);
      }
    }
  }

  static List<List<Cell>> parseInput(String strGrid) {
    List<List<Cell>> newValues = [];
    var rows = strGrid.split('\n');
    if (rows.length != 9) throw Exception('Invalid row count: ${rows.length}');
    for (int r = 0; r < 9; r++) {
      var strRow = rows[r];
      List<Cell> row = [];
      var cols = strRow.split(',');
      if (cols.length != 9)
        throw Exception('Invalid col count: ${cols.length} in row: ${r}');
      for (var strCol in cols) {
        row.add(Cell(strCol));
      }
      newValues.add(row);
    }
    return newValues;
  }

  String buildStateString() {
    StringBuffer state = StringBuffer(COL_HEADER);
    for (int row = 0; row < 9; row++) {
      for (var subRow in [0, 1, 2]) {
        state.write(ROW_HEADER[(row * 3) + subRow + 1] + " ");
        for (int col = 0; col < 9; col++) {
          for (var subCol in [0, 1, 2]) {
            var cell = cells[row][col];
            if (cell.value != 0) {
              if (subRow != 1 || subCol != 1)
                state.write(' ');
              else
                state.write(blue(cell.value));
            } else {
              var val = ((subRow) * 3) + (1 + subCol);
              state.write(
                cell.candidates.contains(val)
                    ? cell.candidates.length == 1
                          ? red(val)
                          : val
                    : ' ',
              );
            }
          }
          if (col < 8)
            if ((col + 1) % 3 == 0)
              state.write(blue('|'));
            else
              state.write('|');
        }
        state.write('\n');
      }
      if (row < 8)
        if ((row + 1) % 3 == 0)
          state.write(ROW_SPLITTER);
        else
          state.write(SUB_ROW_SPLITTER);
    }
    return state.toString();
  }
}

class Cell {
  late int value;
  Set<int> candidates = {1, 2, 3, 4, 5, 6, 7, 8, 9};

  Cell(String strVal) {
    if (strVal.isEmpty || strVal == '0' || strVal == '-') {
      value = 0;
    } else {
      value = int.parse(strVal);
      candidates.clear();
    }
  }

  void setValue(int val) {
    value = val;
    candidates.clear();
  }
}
