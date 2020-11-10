import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg_a.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCircle(
                    color: const Color(0xFFacc99b),
                    size: 30.0,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    'Carregando',
                    style: TextStyle(
                      letterSpacing: 2.0,
                      fontSize: 16.0,
                      color: const Color(0xFFacc99b),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
