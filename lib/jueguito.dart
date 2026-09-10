bool canInsertUnique(List<int> numbers, int newNumber) {
  Set<int> uniqueNumbers = numbers.toSet();
  
  if (uniqueNumbers.length != numbers.length) {
    return false; 
  }
  
  return !uniqueNumbers.contains(newNumber); 
}

enum CellState { unused, used, scored }

enum GridRegion {
  red1, red2,
  blue1, blue2,
  green1, green2,
  purple1, purple2,
  yellow1, yellow2, yellow3, yellow4, yellow5
}

class Cell {
  final CellState state;
  final int number;
  final GridRegion region;

  const Cell({
    required this.state,
    required this.number,
    required this.region,
  });
}

class StatusGridData {
  final List<Cell> _cells = const [
    Cell(state: CellState.scored, number: 99, region: GridRegion.red1),
    Cell(state: CellState.used, number: 42, region: GridRegion.red1),
    Cell(state: CellState.unused, number: 7, region: GridRegion.red2),
    Cell(state: CellState.scored, number: 10, region: GridRegion.yellow1),
    Cell(state: CellState.used, number: 15, region: GridRegion.yellow5),
    Cell(state: CellState.unused, number: 22, region: GridRegion.blue1),
    Cell(state: CellState.scored, number: 33, region: GridRegion.blue1),
  ];

  List<Cell> get cells => List.unmodifiable(_cells);


  List<int> getValuesByRegion(GridRegion targetRegion) {
    return _cells
        .where((cell) => cell.region == targetRegion) 
        .map((cell) => cell.number)                  
        .toList();                                
  }
}



class RedValidator {
  bool canInsert(List<int> numbers, int newNumber) {
    Set<int> uniqueNumbers = numbers.toSet();
    
    if (uniqueNumbers.length != numbers.length) {
      return false; 
    }
    
    return !uniqueNumbers.contains(newNumber); 
  }
}

class YellowValidator {
  bool canInsert(List<int> numbers, int newNumber) {
    Set<int> uniqueNumbers = numbers.toSet();
    
    if (uniqueNumbers.length != numbers.length) {
      return false; 
    }
    
    return !uniqueNumbers.contains(newNumber); 
  }
}

class BlueValidator {
  int? _firstAcceptedNumber;

  bool canInsert(List<int> numbers, int newNumber) {
    if (_firstAcceptedNumber == null) {
      _firstAcceptedNumber = newNumber;
      return true;
    }

    return newNumber == _firstAcceptedNumber;
  }

  void reset() {
    _firstAcceptedNumber = null;
    }
 }

 class GreenValidator {
  bool canInsert(List<int> numbers, int newNumber) {
    return true; 
  }
}  

class PurpleValidator{
  final Set<int> _acceptedNumbers = {};

  bool canInsert(List<int> number, int newNumber){
    if(_acceptedNumbers.contains(newNumber)){
      return true;
    }

    if(_acceptedNumbers.length < 2){
      _acceptedNumbers.add(newNumber);
      return true;
    }

    return false;
  }

  void reset(){
    _acceptedNumbers.clear();
  }
} 