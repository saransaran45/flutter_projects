import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'components/dead_piece.dart';
import 'helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // A 2-dimensional list represents the chess board
  late List<List<ChessPiece?>> board;

  //the currently selectedpiece on the board
  //if not selected then null
  ChessPiece? selectedPiece;
  //the row and col  index of the selected piece
  //-1 indicates no piece selected
  int selectedRow = -1;
  int selectedCol = -1;

  //A list of valid moves for the cureently selected piece
  //each move is represented as list of 2 elements : row and col
  List<List<int>> validMoves = [];
  //List of pieces thathave been taken
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];

  // a boolen to indicate whose turn it is
  bool isWhiteTurn = true;
  //user selected a piece
  //keep track of kings position to check forthe check
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  //INITIALISE BOARD
  void _initializeBoard() {
    //initialise boardwith null
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    //place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'lib/images/pawn.png');
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'lib/images/pawn.png');
    }
    //place rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png');
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png');
    //place knights
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png');
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png');
    //place bishops
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png');
    //place queens
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/images/queen.png');
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/queen.png');
    //place kings
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'lib/images/king.png');
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'lib/images/king.png');
    //assign newboard  value
    board = newBoard;
  }

  //USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      //no piece has been selectes yet this is the first selection
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      //there is a piece already selected,but user can select another oneof their pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
      //if there is a piece selected abd user taps on a square which is a valid move, move there
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }
      // if a piece is selected calculate its raw valid moves
      validMoves = calculateRealValidMoves(
          selectedRow, selectedCol, selectedPiece, true);
    });
  }

  //CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];
    if (piece == null) {
      return [];
    }
    //direction differ based on the color
    int direction = piece.isWhite ? -1 : 1;
    switch (piece.type) {
      case ChessPieceType.pawn:
        //pawn move forward  if square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        //pawn move two squares if they are in initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        //pawns can kill diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            (board[row + direction][col - 1]!.isWhite != piece.isWhite)) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            (board[row + direction][col + 1]!.isWhite != piece.isWhite)) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        //horizontal and vertical directions
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break; //blocked by a piece
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        //all possible Lshapes knight can move
        var knightMoves = [
          [-2, -1], //up 2 and left 1
          [-2, 1], //up 2 and right 1
          [-1, -2], //up 1 and left 2
          [-1, 2], //up 1 and right 2
          [1, -2], //down 1 and left 2
          [1, 2], //down 1 and left 2
          [2, -1], //down 2 and left 1
          [2, 1], //down 2 and left 1
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue; //blocked by a piece
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
        //digonal directions
        var directions = [
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break; //blocked by a piece
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        //all eight direction up,down,right,left and all 4 diagonals
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break; //blocked by a piece
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        //all eight direction
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
          [-1, -1], //up left
          [-1, 1], //up right
          [1, -1], //down left
          [1, 1], //down right
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue; //blocked by a piece
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      default:
    }
    return candidateMoves;
  }

  //CALCULATE REAL VALID MOVES
  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);
    //after generating all candidate moves filter out  if any would result ina hcek
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        //simulate future move if  it is safe
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  //MOVE PIECE
  void movePiece(int newRow, int newCol) {
    //if the newspot has enemy piecee
    if (board[newRow][newCol] != null) {
      //add captuerd piece to apprpriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }
    //check if piece being moved isking
    if (selectedPiece!.type == ChessPieceType.king) {
      //update theking pos
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }
    //move piece
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }
    //clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
    //check if its checkmate
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
          context: context,
          builder: (context) => Container(
                height: 300.0,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Color.fromARGB(255, 190, 190, 190))),
                  backgroundColor: Colors.grey[800],
                  title: Center(
                      child: Text(
                    "CHECK MATE",
                    style: TextStyle(
                        color: Colors.grey[400], fontFamily: 'Montserrat'),
                  )),
                  content: Lottie.asset('lib/images/chess.json'),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //exit button
                        TextButton(
                            style: TextButton.styleFrom(
                                side: BorderSide(
                                    width: 2.0,
                                    color: Color.fromARGB(255, 187, 187, 187))),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Exit",
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontFamily: 'Montserrat'),
                            )),
                        //play again button
                        TextButton(
                            style: TextButton.styleFrom(
                                side: BorderSide(
                                    width: 2.0,
                                    color: Color.fromARGB(255, 187, 187, 187))),
                            onPressed: resetGame,
                            child: Text(
                              "Play Again",
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontFamily: 'Montserrat'),
                            ))
                      ],
                    ),
                  ],
                ),
              ));
    }
    //change turns
    isWhiteTurn = !isWhiteTurn;
  }

  // CHECK IF KING IS IN CHECK
  bool isKingInCheck(bool isWhiteKing) {
    //get positionof the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;
    //check if any enemy piece can attack king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        //skipempty square piieces and piecesof same color asthe king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);
        //check  if the kings position is in the piece valid moves
        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  //SIMULATE A FUTURE MOVE TO SEE IF ITS SAFE
  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    //save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];
    //if the piece is the kking, save its current postion and update the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;
      //update the king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }
    //simulate the rows
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    //check if ur king is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    //restore the board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    //if the oiece was king restore its original positon
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    //if king in check =true,means its not a safe move , safe move =false
    return !kingInCheck;
  }

  //IS IT CHECK MATE
  bool isCheckMate(bool isWhiteKing) {
    //if the king is not in check it is not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }
    //if there is atleast one legal move for a ny player's pieces, then its not a check mate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        //skip empty square and pieces of other color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);
        //if piece has any valid moves then its not checkmate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
    //if none of the above conditions are met,then there are no legal moves left to make
    //its a check mate

    return true;
  }

  //RESET TO NEW GAME
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Column(
          children: [
            //WHITE PIECES TAKEN
            Expanded(
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: whitePiecesTaken.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) => DeadPiece(
                        imagePath: whitePiecesTaken[index].imagePath,
                        isWhite: true,
                      )),
            ),
            Text(
              'White piece graveyard',
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontFamily: 'Montserrat'),
            ),

            //GAME STATUS
            Text(
              checkStatus ? "CHECK" : "",
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                  fontFamily: 'Montserrat'),
            ),
            //CHESS BOARD
            Expanded(
              flex: 3,
              child: GridView.builder(
                  itemCount: 8 * 8,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) {
                    //get row and col
                    int row = index ~/ 8;
                    int col = index % 8;

                    //check ifthe current square is selected or not
                    bool isSelected = selectedRow == row && selectedCol == col;
                    bool isValidMove = false;
                    //check rowand col
                    for (var position in validMoves) {
                      if (position[0] == row && position[1] == col) {
                        isValidMove = true;
                      }
                    }
                    return Square(
                      isWhite: isWhite(index),
                      piece: board[row][col],
                      isSelected: isSelected,
                      onTap: () => pieceSelected(row, col),
                      isValidMove: isValidMove,
                    );
                  }),
            ),
            //BLACK PIECES TAKEN
            Text(
              'Black piece graveyard',
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontFamily: 'Montserrat'),
            ),
            Expanded(
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: blackPiecesTaken.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemBuilder: (context, index) => DeadPiece(
                        imagePath: blackPiecesTaken[index].imagePath,
                        isWhite: false,
                      )),
            ),
          ],
        ));
  }
}
