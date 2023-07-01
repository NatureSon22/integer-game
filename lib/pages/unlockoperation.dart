import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webloi/pages/finalresults.dart';
import 'package:webloi/pages/operationlevels.dart';

class UnlockOperation extends StatefulWidget {
  const UnlockOperation(
      {super.key,
      required this.correct,
      required this.wrong,
      required this.levelAchieved,
      required this.levelOperation,
      required this.levelInfo,
      required this.loadLevelInfo,
      required this.levelText,
      required this.operation});
  final int correct;
  final int wrong;
  final String levelAchieved;
  final String levelText;
  final Map<String, bool> levelOperation;
  final Map<String, bool> levelInfo;
  final Function loadLevelInfo;
  final String operation;

  @override
  State<UnlockOperation> createState() => _UnlockOperationState();
}

class _UnlockOperationState extends State<UnlockOperation> {
  bool isAchieved = false;
  late Map<String, Map<String, bool>> levelOperationState;
  late Map<String, bool> levelOperation = {};

  bool checkAchieved() {
    return widget.correct > widget.wrong;
  }

  Future<void> setUpPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isAchieved) {
    int score = int.tryParse(prefs.getString("${widget.levelText}Score") ?? "") ?? 0;
    score += widget.correct;

      String setScore = jsonEncode(score);
      prefs.setString("${widget.levelText}Score", setScore);
      if (widget.levelAchieved == "DIVISION") {
        if (widget.levelText == "Easy") {
          await prefs.setBool("stateLevelAverage", true);

          levelOperationState = {
            ...levelOperationState,
            "Average": {
              "ADDITION": true,
              "SUBTRACTION": false,
              "MULTIPLICATION": false,
              "DIVISION": false,
            }
          };
          String levelOperationStateJson = jsonEncode(levelOperationState);
          prefs.setString("levelOperation", levelOperationStateJson);
        } else if (widget.levelText == "Average") {
          await prefs.setBool("stateLevelDifficult", true);

           levelOperationState = {
            ...levelOperationState, 
            "Difficult": {
              "ADDITION": true,
              "SUBTRACTION": false,
              "MULTIPLICATION": false,
              "DIVISION": false,
            }
          };
          String levelOperationStateJson = jsonEncode(levelOperationState);
          prefs.setString("levelOperation", levelOperationStateJson);
        }
      } else {
        if (widget.operation == "ADDITION") {
          levelOperation["SUBTRACTION"] = true;
        } else if (widget.operation == "SUBTRACTION") {
          levelOperation["MULTIPLICATION"] = true;
        } else if (widget.operation == "MULTIPLICATION") {
          levelOperation["DIVISION"] = true;
        }
        levelOperationState[widget.levelText] = levelOperation;
        String levelOperationStateJson = jsonEncode(levelOperationState);
        prefs.setString("levelOperation", levelOperationStateJson);
      }
    }
  }

  Future<Map<String, Map<String, bool>>> retrieveLevelOperation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? levelOperationJson = prefs.getString("levelOperation");
    if (levelOperationJson != null) {
      Map<String, dynamic> levelOperationMap = jsonDecode(levelOperationJson);
      Map<String, Map<String, bool>> levelOperation = levelOperationMap.map(
        (key, value) => MapEntry(key, Map<String, bool>.from(value)),
      );
      return levelOperation;
    } else {
      return {
        "Easy": {
          "ADDITION": true,
          "SUBTRACTION": false,
          "MULTIPLICATION": false,
          "DIVISION": false,
        }
      };
    }
  }

  Future<void> getLevelOperation() async {
    levelOperationState = await retrieveLevelOperation();
    setState(() {
      levelOperation = levelOperationState[widget.levelText]!;
    });
  }

  void loadLevelOperationFailed() {
    levelOperation = widget.levelOperation;
  }

  void loadLevelOperation() async {
    getLevelOperation();
    setUpPreference();
  }

  @override
  void initState() {
    super.initState();
    isAchieved = checkAchieved();
    if (isAchieved) {
      loadLevelOperation();
    } else {
      loadLevelOperationFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF171617),
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AchievementBoard(
              isAchieved: isAchieved, levelAchieved: widget.levelAchieved),
          ScoreBoard(correct: widget.correct, wrong: widget.wrong),
          NextBoard(
              isAchieved: isAchieved,
              operation: widget.operation,
              levelAchieved: widget.levelAchieved,
              levelOperation: levelOperation,
              levelInfo: widget.levelInfo,
              loadLevelInfo: widget.loadLevelInfo,
              levelText: widget.levelText,
              getLevelOperation: getLevelOperation)
        ],
      ),
    );
  }
}

class AchievementBoard extends StatefulWidget {
  const AchievementBoard(
      {super.key, required this.isAchieved, required this.levelAchieved});
  final bool isAchieved;
  final String levelAchieved;

  @override
  State<AchievementBoard> createState() => _AchievementBoardState();
}

class _AchievementBoardState extends State<AchievementBoard> {
  @override
  Widget build(BuildContext context) {
    const TextStyle titleStyle = TextStyle(
        fontSize: 12,
        fontFamily: 'Poppins',
        color: Colors.white,
        decoration: TextDecoration.none);
    const TextStyle levelStyle = TextStyle(
        fontSize: 12,
        fontFamily: 'Poppins',
        color: Color(0xFFE2B808),
        decoration: TextDecoration.none);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: const Color(0xFF49326B),
        borderRadius: BorderRadius.circular(70.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFE843A1),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                './assets/ribbon.png',
                width: 60.0,
                height: 60.0,
              ),
            ),
          ),
          Column(
            children: [
              const Text(
                "Achievement unlocked",
                style: titleStyle,
              ),
              Row(
                children: [
                  Text(
                    widget.isAchieved ? "Complete: " : "Failure to  ",
                    style: titleStyle,
                  ),
                  Text(
                    widget.isAchieved ? widget.levelAchieved : "SUCCESS",
                    style: levelStyle,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ScoreBoard extends StatefulWidget {
  const ScoreBoard({super.key, required this.correct, required this.wrong});
  final int correct;
  final int wrong;
  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

const TextStyle txtStyle = TextStyle(
    fontFamily: "Poppins",
    fontSize: 28,
    color: Colors.white,
    decoration: TextDecoration.none);

class _ScoreBoardState extends State<ScoreBoard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: const Text("Your Results", style: txtStyle)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Correct:",
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 28,
                    color: Color(0xFF00BF63),
                    decoration: TextDecoration.none),
              ),
              Text(widget.correct.toString(), style: txtStyle)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Wrong:",
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 28,
                    color: Color(0xFFFF3131),
                    decoration: TextDecoration.none),
              ),
              Text(widget.wrong.toString(), style: txtStyle)
            ],
          )
        ],
      ),
    );
  }
}

class NextBoard extends StatelessWidget {
  const NextBoard(
      {super.key,
      required this.isAchieved,
      required this.operation,
      required this.levelAchieved,
      required this.levelOperation,
      required this.levelInfo,
      required this.loadLevelInfo,
      required this.levelText,
      required this.getLevelOperation});
  final bool isAchieved;
  final String operation;
  final String levelAchieved;
  final String levelText;
  final Map<String, bool> levelOperation;
  final Map<String, bool> levelInfo;
  final Function loadLevelInfo;
  final Function getLevelOperation;

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
          Text(
            isAchieved ? "You rock!" : "Study hard!",
            style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 22,
                color: Colors.black,
                decoration: TextDecoration.none),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: TextButton(
                onPressed: () {
                  if (isAchieved) {
                    if(levelText == "Difficult" && operation == "DIVISION") {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Results()));
                    }else {
                    getLevelOperation().then((_) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OperationLevel(
                                    levelText: levelText,
                                    levelOperation: levelOperation,
                                    levelInfo: levelInfo,
                                    loadLevelInfo: loadLevelInfo,
                                  )));
                    });
                    }
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OperationLevel(
                                levelText: levelText,
                                levelOperation: levelOperation,
                                levelInfo: levelInfo,
                                loadLevelInfo: loadLevelInfo)));
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF49326B)),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 65),
                  ),
                ),
                child: Text(
                  isAchieved ? (levelText == "Difficult" && operation == "DIVISION") ? "Final Results" : "Next Level" : "Try Again!", 
                  style: const TextStyle(
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
