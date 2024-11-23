import 'package:chess/components/piece.dart';
import 'package:flutter/material.dart';

import '../values/values.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final void Function()? onTap;
  final bool isValidMove;
  Square(
      {super.key,
      required this.isWhite,
      required this.piece,
      required this.isSelected,
      required this.onTap,
      required this.isValidMove});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    //if selected, square is green
    if (isSelected) {
      squareColor = Colors.green;
    }
    //otherwise white or black
    else if (isValidMove) {
      squareColor = Colors.green[300];
    } else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
          margin: EdgeInsets.all(isValidMove ? 5.0 : 0.0),
          color: squareColor,
          child: (piece != null)
              ? Image.asset(
                  piece!.imagePath,
                  color: piece!.isWhite ? Colors.white : Colors.black,
                )
              : null),
    );
  }
}
