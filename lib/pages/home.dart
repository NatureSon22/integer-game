import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webloi/pages/levels.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final Map<String, bool> levelInfo = {};

  Future<void> loadLevel() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    levelInfo["Easy"] = pref.getBool("stateLevelEasy") ?? true;
    levelInfo["Average"] = pref.getBool("stateLevelAverage") ?? false;
    levelInfo["Difficult"] = pref.getBool("stateLevelDifficult") ?? false;
  }

  Future<void> resetSharedPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 150.0),
      decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[
        Color.fromARGB(255, 159, 39, 180),
        Color.fromARGB(255, 91, 22, 104)
      ])),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Image.asset('./assets/logo.png', width: 100, height: 100),
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    child: const Text('NumQuest', style: TextStyle(
                      color:   Color(0xFFFF3EFF),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.1,
                      decoration: TextDecoration.none
                    )),
                  ),
                ],
              ),
              TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 67, 12, 78)),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                    ),
                    elevation: MaterialStateProperty.all<double>(5.0),
                    shadowColor: MaterialStateProperty.all<Color>(const Color(0xFF49326B)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    loadLevel().then((_) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Levels(levelInfo: levelInfo, loadLevelInfo: loadLevel,)));
                    });
                  },

                  child: const Text('START GAME',
                      style: TextStyle(
                          color:  Color(0xFFFF3EFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          fontFamily: 'Poppins',
                          decoration: TextDecoration.none)))
            ],
          ),
        ],
      ),
    );
  }
}
