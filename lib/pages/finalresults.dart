import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webloi/pages/home.dart';

class Results extends StatefulWidget {
  const Results({super.key});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1D1E21),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      alignment: Alignment.center,
      // padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const BannerBoard(),
          Image.asset("./assets/trophy.gif"),
          const Positioned(
            top: 0,
            child: ScoreBoard()),
          const NextBoard()
        ],
      ),
    );
  }
}

class BannerBoard extends StatelessWidget {
  const BannerBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 30.0),
        decoration: BoxDecoration(
            color: const Color(0xFF49326B),
            borderRadius: BorderRadius.circular(50)),
        child: const Text(
          "Final Results",
          style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontFamily: "Poppins",
              decoration: TextDecoration.none),
        ));
  }
}

class ScoreBoard extends StatefulWidget {
  const ScoreBoard({super.key});

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}
const TextStyle textStyle = TextStyle(
    fontFamily: "Poppins",
    fontSize: 25,
    color: Colors.white,
    decoration: TextDecoration.none);

class _ScoreBoardState extends State<ScoreBoard> {
  List<int> scoreGame = [];

  Future<void> setScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<int> score = ["EasyScore", "AverageScore", "DifficultScore"]
        .map((key) => int.tryParse(prefs.getString(key) ?? "") ?? 0)
        .toList();

    setState(() {
      scoreGame = score;
    });
  }

  @override
  void initState() {
    super.initState();
    setScore();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300,
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Easy: ", style: textStyle),
                Text(scoreGame[0].toString(), style: textStyle)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Average: ", style: textStyle),
                Text(scoreGame[1].toString(), style: textStyle)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Difficult: ", style: textStyle),
                Text(scoreGame[2].toString(), style: textStyle)
              ],
            )
          ],
        ));
  }
}

class NextBoard extends StatelessWidget {
  const NextBoard({super.key});

  Future<void> resetSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFA996C6),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Center(
            child: Text(
              "You're an absolute champ!",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 18,
                  color: Colors.black,
                  decoration: TextDecoration.none),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: TextButton(
                onPressed: () {
                  resetSharedPreferences().then((_) => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Home())));
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF49326B)),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 65),
                  ),
                ),
                child: const Text(
                  "Restart Game",
                  style: TextStyle(
                      fontFamily: "Poppins",
                      color: Colors.white,
                      fontSize: 20,
                      decoration: TextDecoration.none),
                )),
          )
        ],
      ),
    );
  }
}
