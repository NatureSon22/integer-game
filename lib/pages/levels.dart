import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webloi/pages/operationlevels.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Levels extends StatefulWidget {
  const Levels(
      {super.key, required this.levelInfo, required this.loadLevelInfo});
  final Map<String, bool> levelInfo;
  final Function loadLevelInfo;

  @override
  State<Levels> createState() => _LevelsState();
}

class _LevelsState extends State<Levels> with SingleTickerProviderStateMixin {
  late Map<String, bool> levelInfo;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late List<Animation<Offset>> _animationList;
  final List<Offset> _offsetList = [
    const Offset(0.0, -1.0), // up - original
    const Offset(-1.0, 0.0), // left - original
    const Offset(1.0, 0.0), // right - original
  ];


  @override
  void initState() {
    super.initState();
    levelInfo = widget.levelInfo;
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);

    _animationList = _offsetList.map((offset) {
      return Tween(begin: offset, end: Offset.zero)
          .animate(_animationController);
    }).toList();

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showDialog(BuildContext context, List<String> text, int add) {
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
                        SystemNavigator.pop();
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

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Color(0xFF171617)),
        padding: const EdgeInsets.all(20.0),
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) => SizedBox(
                width: 200,
                child: SlideTransition(
                  position: _animationList[0],
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset('./assets/logo.png', width: 55, height: 55),
                        const Text(
                            'NumQuest',
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Color(0xFFFF3EFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                                fontFamily: 'Poppins'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) => SlideTransition(
                  position: _animationList[1],
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Column(
                      children: levelInfo.entries.map((entry) {
                        return LevelButton(
                          levelText: entry.key,
                          levelEnabled: entry.value,
                          levelInfo: widget.levelInfo,
                          loadLevelInfo: widget.loadLevelInfo,
                        );
                      }).toList(),
                    ),
                  ),
                )),
            AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) => SlideTransition(
                  position: _animationList[2],
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              _showDialog(context, ["Do you want to exit?", "Exit"], 12);
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color(0xFF49326B)),
                                padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    const EdgeInsets.symmetric(
                                        horizontal: 50.0,
                                        vertical: 15.0))),
                            child: const Text(
                              'EXIT',
                              style: TextStyle(
                                  color: Color(0xFFFF3EFF),
                                  fontFamily: 'Poppins',
                                  fontSize: 22),
                            )),
                      ],
                    ),
                  ),
                ))
          ],
        ));
  }
}

class LevelButton extends StatefulWidget {
  const LevelButton(
      {super.key,
      required this.levelText,
      required this.levelEnabled,
      required this.levelInfo,
      required this.loadLevelInfo});
  final String levelText;
  final bool levelEnabled;
  final Map<String, bool> levelInfo;
  final Function loadLevelInfo;

  @override
  State<LevelButton> createState() => _LevelButtonState();
}

class _LevelButtonState extends State<LevelButton> {
  late Map<String, Map<String, bool>> levelOperation;
  late Map<String, bool> levelOperationState;

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

  void setlevOperationState() async {
    levelOperation = await retrieveLevelOperation();
    levelOperationState = levelOperation[widget.levelText] ?? {};
  }

  @override
  void initState() {
    super.initState();
    setlevOperationState();
  }

  ColorFilter brightnessFilter(double brightness) {
    return ColorFilter.matrix([
      brightness,
      0,
      0,
      0,
      0,
      0,
      brightness,
      0,
      0,
      0,
      0,
      0,
      brightness,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20.0),
      child: TextButton(
        onPressed: () {
          if (widget.levelEnabled) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OperationLevel(
                          levelText: widget.levelText,
                          levelOperation: levelOperationState,
                          levelInfo: widget.levelInfo,
                          loadLevelInfo: widget.loadLevelInfo,
                        )));
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ColorFiltered(
              colorFilter: widget.levelEnabled
                  ? brightnessFilter(1.0)
                  : brightnessFilter(0.5),
              child: Image.asset(
                './assets/bglevel.png',
                fit: BoxFit.cover,
                color: Colors.white,
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            Text(
              widget.levelText.toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: widget.levelEnabled
                    ? const Color.fromRGBO(255, 255, 255, 1)
                    : const Color.fromARGB(255, 180, 179, 180),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
