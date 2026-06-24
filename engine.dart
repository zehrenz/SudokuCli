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
  List<List<Box>> boxes;
  bool autoSolve;
  bool _solving = false;

  SudokuEngine(String strGrid, this.autoSolve)
    : this.boxes = parseInput(strGrid) {
    updateAllCandidates();
    if (autoSolve) solve();
  }

  String placeVal(int row, int col, int val) {
    var box = boxes[row][col];
    if (box.value != 0) {
      return 'Box already has a value';
    } else if (!box.candidates.contains(val)) {
      return '${val} is not a candidate for that box';
    }
    box.setValue(val);
    updateRow(row, val);
    updateCol(col, val);
    updateHome(row ~/ 3, col ~/ 3, val);
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
            var box = boxes[row][col];
            if (box.value == 0 && box.candidates.length == 1) {
              placeVal(row, col, box.candidates.first);
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
      boxes[row][col].candidates.remove(val);
    }
  }

  void updateCol(int col, int val) {
    for (int row = 0; row < 9; row++) {
      boxes[row][col].candidates.remove(val);
    }
  }

  void updateHome(int homeRow, int homeCol, int val) {
    var rowBase = homeRow * 3;
    var colBase = homeCol * 3;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        boxes[row + rowBase][col + colBase].candidates.remove(val);
      }
    }
  }

  void updateCandidates(int row, int col) {
    var box = boxes[row][col];
    if (box.value != 0) return;
    updateCandidatesByRow(row, box);
    updateCandidatesByCol(col, box);
    updateCandidatesByHome(row ~/ 3, col ~/ 3, box);
  }

  void updateCandidatesByRow(int row, Box box) {
    for (int col = 0; col < 9; col++) {
      box.candidates.remove(boxes[row][col].value);
    }
  }

  void updateCandidatesByCol(int col, Box box) {
    for (int row = 0; row < 9; row++) {
      box.candidates.remove(boxes[row][col].value);
    }
  }

  void updateCandidatesByHome(int homeRow, int homeCol, Box box) {
    var rowBase = homeRow * 3;
    var colBase = homeCol * 3;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        box.candidates.remove(boxes[row + rowBase][col + colBase].value);
      }
    }
  }

  static List<List<Box>> parseInput(String strGrid) {
    List<List<Box>> newValues = [];
    var rows = strGrid.split('\n');
    if (rows.length != 9) throw Exception('Invalid row count: ${rows.length}');
    for (int r = 0; r < 9; r++) {
      var strRow = rows[r];
      List<Box> row = [];
      var cols = strRow.split(',');
      if (cols.length != 9)
        throw Exception('Invalid col count: ${cols.length} in row: ${r}');
      for (var strCol in cols) {
        row.add(Box(strCol));
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
            var box = boxes[row][col];
            if (box.value != 0) {
              if (subRow != 1 || subCol != 1)
                state.write(' ');
              else
                state.write(blue(box.value));
            } else {
              var val = ((subRow) * 3) + (1 + subCol);
              state.write(
                box.candidates.contains(val)
                    ? box.candidates.length == 1
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

class Box {
  late int value;
  Set<int> candidates = {1, 2, 3, 4, 5, 6, 7, 8, 9};

  Box(String strVal) {
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
