enum ChessPieceType { king, queen, rook, knight, bishop, pawn }

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;

  ChessPiece(
      {required this.type, required this.isWhite, required this.imagePath});
}
