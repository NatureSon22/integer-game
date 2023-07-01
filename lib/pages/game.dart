import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webloi/pages/unlockoperation.dart';

class Game extends StatefulWidget {
  const Game(
      {super.key,
      required this.operation,
      required this.levelOperation,
      required this.levelInfo,
      required this.loadLevelInfo,
      required this.levelText});
  final String operation;
  final Map<String, bool> levelOperation;
  final Map<String, bool> levelInfo;
  final Function loadLevelInfo;
  final String levelText;

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  String number = "0";
  int score = 0;
  int wrongCount = 0;
  int answer = 0;
  int questionCount = 1;
  int maxOperationLevel = 10;
  int first = 0;
  int second = 0;
  Color numColor = Colors.white;

  String getOperation() {
    String currentOperation = "";
    switch (widget.operation) {
      case "ADDITION":
        currentOperation = "+";
        break;
      case "SUBTRACTION":
        currentOperation = "-";
        break;
      case "MULTIPLICATION":
        currentOperation = "*";
        break;
      case "DIVISION":
        currentOperation = "÷";
        break;
    }
    return currentOperation;
  }

  Map<String, String> equation = {
    'firstNum': "",
    'secondNum': "",
    "answer": "",
    'operation': ""
  };

  dynamic getAnswer(int firstNum, int secondNum, String operation) {
    dynamic ans = 0;
    switch (operation) {
      case "+":
        ans = firstNum + secondNum;
        break;
      case "-":
        ans = firstNum - secondNum;
        break;
      case "*":
        ans = firstNum * secondNum;
        break;
      case "÷":
        ans = firstNum / secondNum;
        break;
    }
    return ans;
  }

  void numRange() {
    switch(widget.levelText) {
      case "Easy":  // 5 - 20
        first = Random().nextInt(26) + 5;
        second = Random().nextInt(26) + 5;
        break;
      case "Average":
        first = Random().nextInt(26) + 25;
        second = Random().nextInt(26) + 25;
        break;
      case "Difficult":
        first = Random().nextInt(26) + 45;
        second = Random().nextInt(26) + 45;
        break;
    }
  }

  void _generateEquationInBackground() {
    late String operation;
    String answer;
    numRange();
    operation = getOperation();
    if (operation == "÷") {
      double result = getAnswer(first, second, operation);
      if (result % 1 == 0) {
        answer = result.toInt().toString();
      } else {
        _generateEquationInBackground();
        return;
      }
    } else {
      answer = getAnswer(first, second, operation).toString();
    }

    setState(() {
      equation["firstNum"] = first.toString();
      equation["secondNum"] = second.toString();
      equation["answer"] = answer;
      equation["operation"] = operation;
    });
  }

  void checkAnswer() {
    bool answerResult = equation["answer"] == number;
    if (answerResult) {
      setState(() {
        ++score;
      });
    } else {
      ++wrongCount;
    }

    changeNumColor(answerResult);
  }

  void changeNumColor(bool answerResult) {
    setState(() {
      numColor = answerResult ? const Color(0xFF00BF63) : const Color(0xFFFF3131);
    });

    Timer(const Duration(milliseconds: 900), () {
      setState(() {
        numColor = Colors.white;
        number = "0";
        questionCount++;
    }); 
    });
  }

  void updateNumber(String input) {
    setState(() {
      if (number.startsWith("0")) {
        number = number.substring(1);
      }

      if (input == "+") {
        if (number.startsWith("-")) {
          number = number.substring(1);
        }
      } else if (input == "-") {
        number = (number.startsWith("-")) ? number.substring(1) : "-$number";
      } else if (number.length < 5) {
        number += input;
      }
    });
  }

  void deleteNum() {
    setState(() {
      number = number.substring(0, number.length - 1);
    });

    if (number.isEmpty) {
      setState(() {
        number = "0";
      });
    }
  }

  void clearNum() {
    setState(() {
      number = "0";
    });
  }

  void restartGame() {
    setState(() {
      score = 0;
      questionCount = 0;
      _generateEquationInBackground();
      number = "0";
    });
  }

  bool checkLevel() {
    if (questionCount - 1 == maxOperationLevel) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnlockOperation(
                correct: score,
                wrong: wrongCount,
                levelAchieved: widget.operation,
                levelOperation: widget.levelOperation,
                levelInfo: widget.levelInfo,
                loadLevelInfo: widget.loadLevelInfo,
                levelText: widget.levelText,
                operation: widget.operation),
          ));
      return false;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _generateEquationInBackground();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF171617),
      ),
      padding: const EdgeInsets.only(
          top: 30.0, bottom: 5.0, left: 20.0, right: 20.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Utilities(restart: restartGame),
          GameStatus(
              score: score.toString(),
              questionCount: questionCount.toString(),
              maxOperationLevel: maxOperationLevel.toString()),
          Equation(number: number, equation: equation, numColor: numColor),
          NumPad(
              updateNumber: updateNumber,
              deleteNum: deleteNum,
              clearNum: clearNum,
              generate: _generateEquationInBackground,
              checkAnswer: checkAnswer,
              checkLevel: checkLevel)
        ],
      ),
    );
  }
}

class Utilities extends StatefulWidget {
  const Utilities({super.key, required this.restart});
  final Function restart;

  @override
  State<Utilities> createState() => _UtilitiesState();
}

class _UtilitiesState extends State<Utilities> {
  void _showDialog(
      BuildContext context, List<String> text, Function function, int add) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF171617),
            content: Text(
              text[0],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            actions: [
              Container(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        function();
                      },
                      style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(horizontal: 20.0 + add)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF49326B)),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white)),
                      child: Text(
                        text[1],
                        style: const TextStyle(fontFamily: "Poppins"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  const EdgeInsets.symmetric(horizontal: 20.0)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF49326B)),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white)),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

  void leaveGame() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void restartGame() {
    widget.restart();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            _showDialog(
                context, ["Do you want to exit?", "Exit"], leaveGame, 12);
          },
          child: const Icon(FontAwesomeIcons.signOutAlt,
              size: 25.0, color: Color(0xFFFF3EFF)),
        ),
        Image.asset('./assets/logo.png', width: 25, height: 25),
        GestureDetector(
          onTap: () {
            _showDialog(
                context,
                [
                  "Do you want to restart?",
                  "Restart",
                ],
                restartGame,
                0);
          },
          child: const Icon(FontAwesomeIcons.redo,
              size: 22.0, color: Color(0xFFFF3EFF)),
        )
      ],
    );
  }
}

class GameStatus extends StatefulWidget {
  const GameStatus(
      {super.key,
      required this.score,
      required this.questionCount,
      required this.maxOperationLevel,});
  final String score;
  final String questionCount;
  final String maxOperationLevel;

  @override
  State<GameStatus> createState() => _GameStatusState();
}

const TextStyle style = TextStyle(
    decoration: TextDecoration.none,
    fontFamily: "Poppins",
    fontSize: 12,
    color: Color(0xFFFFFFFF));

class _GameStatusState extends State<GameStatus> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(
            top: 15.0, bottom: 8.0, left: 25.0, right: 25.0),
        decoration: BoxDecoration(
            color: const Color(0xFF49326B),
            border: Border.all(
                color: const Color.fromARGB(255, 248, 248, 248),
                width: 1,
                style: BorderStyle.solid)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text("Level: ", style: style),
                Text(
                  "Easy",
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color: Color(0xFFFAD52A)),
                )
              ],
            ),
            Row(
              children: [
                const Text("Q: ", style: style),
                Text("${widget.questionCount}/${widget.maxOperationLevel}",
                    style: style)
              ],
            ),
            Row(
              children: [
                const Text("Correct: ", style: style),
                Text(widget.score, style: style),
              ],
            )
          ],
        ));
  }
}

class Equation extends StatefulWidget {
  const Equation({super.key, required this.number, required this.equation, required this.numColor});
  final String number;
  final Map<String, String> equation;
  final Color numColor;


  @override
  State<Equation> createState() => _EquationState();
}

class _EquationState extends State<Equation> {
  late TextStyle answerStyle;
  TextStyle style2 = const TextStyle(
    decoration: TextDecoration.none,
    fontSize: 40,
    fontFamily: "Poppins",
    color: Color(0xFFFFFFFF),
  );

  @override
  void initState() {
    super.initState();
    answerStyle = TextStyle(
      decoration: TextDecoration.none,
      fontSize: 40,
      fontFamily: "Poppins",
      color: widget.numColor,
    );
  }

  @override
  void didUpdateWidget(Equation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.numColor != oldWidget.numColor) {
      setState(() {
        answerStyle = TextStyle(
          decoration: TextDecoration.none,
          fontSize: 40,
          fontFamily: "Poppins",
          color: widget.numColor,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 65),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(""),
                Text(widget.equation["firstNum"]!, style: style2),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 65),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.equation["operation"]!, style: style2),
                Text(widget.equation["secondNum"]!, style: style2),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: Color.fromARGB(255, 255, 254, 254),
                        width: 4.0,
                        style: BorderStyle.solid))),
            width: 170,
            child: Center(
              child: Text(widget.number.toString(), style: answerStyle),
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteButtons extends StatefulWidget {
  const DeleteButtons(
      {super.key, required this.deleteNum, required this.clearNum});
  final Function deleteNum;
  final Function clearNum;

  @override
  State<DeleteButtons> createState() => _DeleteButtonsState();
}

class _DeleteButtonsState extends State<DeleteButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 80,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xFFD97D16)),
            ),
            onPressed: () {
              widget.clearNum();
            },
            child: const Text(
              "AC",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 80,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xFFD97D16)),
            ),
            onPressed: () {
              widget.deleteNum();
            },
            child: const Text(
              "DEL",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NumButton extends StatefulWidget {
  const NumButton({super.key, required this.num, required this.updateNumber});
  final String num;
  final Function updateNumber;

  @override
  State<NumButton> createState() => _NumButtonState();
}

class _NumButtonState extends State<NumButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(const Color(0xFF49326B))),
        onPressed: () {
          widget.updateNumber(widget.num);
        },
        child: Text(
          widget.num,
          style: const TextStyle(
              fontSize: 20, fontFamily: "Poppins", color: Colors.white),
        ),
      ),
    );
  }
}

class Pad extends StatefulWidget {
  const Pad(
      {super.key,
      required this.updateNumber,
      required this.generate,
      required this.checkAnswer,
      required this.checkLevel});
  final Function updateNumber;
  final Function generate;
  final Function checkAnswer;
  final Function checkLevel;

  @override
  State<Pad> createState() => _PadState();
}

class _PadState extends State<Pad> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NumButton(num: "1", updateNumber: widget.updateNumber),
              NumButton(num: "2", updateNumber: widget.updateNumber),
              NumButton(num: "3", updateNumber: widget.updateNumber),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NumButton(num: "4", updateNumber: widget.updateNumber),
              NumButton(num: "5", updateNumber: widget.updateNumber),
              NumButton(num: "6", updateNumber: widget.updateNumber)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NumButton(num: "7", updateNumber: widget.updateNumber),
              NumButton(num: "8", updateNumber: widget.updateNumber),
              NumButton(num: "9", updateNumber: widget.updateNumber)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NumButton(num: "+", updateNumber: widget.updateNumber),
              NumButton(num: "0", updateNumber: widget.updateNumber),
              NumButton(num: "-", updateNumber: widget.updateNumber),
            ],
          ),
          CheckButton(
              generate: widget.generate,
              checkAnswer: widget.checkAnswer,
              checkLevel: widget.checkLevel)
        ],
      ),
    );
  }
}

class CheckButton extends StatefulWidget {
  const CheckButton(
      {super.key,
      required this.generate,
      required this.checkAnswer,
      required this.checkLevel});
  final Function generate;
  final Function checkAnswer;
  final Function checkLevel;

  @override
  State<CheckButton> createState() => _CheckButtonState();
}

class _CheckButtonState extends State<CheckButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0xFF00BF63)),
        ),
        onPressed: () {
          widget.checkAnswer();
          Timer(const Duration(milliseconds: 900), () {
             if (widget.checkLevel()) {
              widget.generate();
            }
          });
        },
        child: const Text(
          "CHECK",
          style: TextStyle(
            fontSize: 25,
            fontFamily: "Poppins",
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class NumPad extends StatefulWidget {
  const NumPad(
      {super.key,
      required this.updateNumber,
      required this.deleteNum,
      required this.clearNum,
      required this.generate,
      required this.checkAnswer,
      required this.checkLevel});
  final Function updateNumber;
  final Function clearNum;
  final Function deleteNum;
  final Function generate;
  final Function checkAnswer;
  final Function checkLevel;

  @override
  State<NumPad> createState() => _NumPadState();
}

class _NumPadState extends State<NumPad> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          DeleteButtons(deleteNum: widget.deleteNum, clearNum: widget.clearNum),
          Pad(
              updateNumber: widget.updateNumber,
              generate: widget.generate,
              checkAnswer: widget.checkAnswer,
              checkLevel: widget.checkLevel)
        ],
      ),
    );
  }
}
