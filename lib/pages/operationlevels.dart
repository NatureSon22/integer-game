import 'package:flutter/material.dart';
import 'package:webloi/pages/game.dart';
import 'package:webloi/pages/levels.dart';

class OperationLevel extends StatefulWidget {
  const OperationLevel(
      {super.key,
      required this.levelText,
      required this.levelOperation,
      required this.levelInfo,
      required this.loadLevelInfo});
  final String levelText;
  final Map<String, bool> levelOperation;
  final Map<String, bool> levelInfo;
  final Function loadLevelInfo;

  @override
  State<OperationLevel> createState() => _OperationLevelState();
}

class _OperationLevelState extends State<OperationLevel>
    with SingleTickerProviderStateMixin {
  late Map<String, bool> operation;
  late Map<String, bool> levelInfo = {};
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late List<Animation<Offset>> _animationList;
  final List<Offset> _offsetList = [
    const Offset(0.0, -1.0),
    const Offset(-1.0, 0.0),
    const Offset(1.0, 0.0)
  ];

  @override
  void initState() {
    super.initState();
    operation = widget.levelOperation;
    _initializeLevelInfo();

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);

    _animationList = _offsetList.map((offset) {
      return Tween(begin: offset, end: Offset.zero)
          .animate(_animationController);
    }).toList();

    _opacityAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();
  }

  Future<void> _initializeLevelInfo() async {
    await widget.loadLevelInfo();
    setState(() {
      levelInfo = widget.levelInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF171617),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, __) => SizedBox(
              height: 500,
              child: SlideTransition(
                position: _animationList[1],
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: operation.entries.map((item) {
                        return OperationButton(
                            operation: item.key,
                            operationEnabled: item.value,
                            levelOperation: widget.levelOperation,
                            levelInfo: levelInfo,
                            loadLevelInfo: widget.loadLevelInfo,
                            levelText: widget.levelText);
                      }).toList()),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) => SizedBox(
              child: SlideTransition(
                position: _animationList[2],
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Levels(
                                        levelInfo: widget.levelInfo,
                                        loadLevelInfo: widget.loadLevelInfo)));
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFF49326B)),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.symmetric(
                                          horizontal: 50.0, vertical: 15.0))),
                          child: const Text(
                            'BACK',
                            style: TextStyle(
                                color: Color(0xFFFF3EFF),
                                fontFamily: 'Poppins',
                                fontSize: 22),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OperationButton extends StatefulWidget {
  const OperationButton(
      {super.key,
      required this.operation,
      required this.operationEnabled,
      required this.levelOperation,
      required this.levelInfo,
      required this.loadLevelInfo,
      required this.levelText});
  final String operation;
  final bool operationEnabled;
  final Map<String, bool> levelOperation;
  final Map<String, bool> levelInfo;
  final Function loadLevelInfo;
  final String levelText;

  @override
  State<OperationButton> createState() => _OperationButtonState();
}

class _OperationButtonState extends State<OperationButton> {
  late Color buttonColor;
  late Color textColor;

  @override
  void initState() {
    super.initState();
    buttonColor = widget.operationEnabled
        ? const Color.fromARGB(255, 96, 17, 112)
        : const Color.fromARGB(255, 69, 13, 82);
    textColor = widget.operationEnabled
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(255, 170, 170, 170);
  }

  void changeColors() {
    setState(() {
      buttonColor = Colors.white;
      textColor = const Color.fromARGB(255, 96, 17, 112);
    });

    // Delay the color change reset by 1 second (1000 milliseconds)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        buttonColor = const Color.fromARGB(255, 96, 17, 112);
        textColor = Colors.white;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 1.0,
        child: TextButton(
          onPressed: () async {
            if (widget.operationEnabled) {
              changeColors;
        
            Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Game(
                            operation: widget.operation,
                            levelOperation: widget.levelOperation,
                            levelInfo: widget.levelInfo,
                            loadLevelInfo: widget.loadLevelInfo,
                            levelText: widget.levelText,
                          )));
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 30),
            ),
          ),
          child: Text(
            widget.operation,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 30,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
