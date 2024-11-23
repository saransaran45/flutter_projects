import 'package:chess/game_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "CHESS",
            style: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'Montserrat',
                fontSize: 30.0),
          ),
          //Lottie Asset
          Lottie.asset('lib/images/chess.json'),
          //Play game
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20.0),
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  side: BorderSide(
                      color: Color.fromARGB(255, 189, 189, 189), width: 2.0)),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => GameBoard()));
              },
              child: Text(
                "PLAY CHESS",
                style: TextStyle(
                    color: Colors.grey[400],
                    fontFamily: 'Montserrat',
                    fontSize: 18.0),
              )),
          SizedBox(
            height: 10.0,
          ),
          //Quitgame
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20.0),
                  backgroundColor: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  side: BorderSide(
                      color: Color.fromARGB(255, 189, 189, 189), width: 2.0)),
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text(
                "QUIT CHESS",
                style: TextStyle(
                    color: Colors.grey[400],
                    fontFamily: 'Montserrat',
                    fontSize: 18.0),
              )),
        ]),
      ),
    );
  }
}
