import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../widgets/timer_painter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final ConfettiController confettiController;
  late final AnimationController timerController;
  late final AnimationController textController;
  late final Animation<double> textAnimation;

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController();
    timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    timerController.reverse(
        from: timerController.value == 0.0 ? 1.0 : timerController.value);
    textController = AnimationController(
      duration: const Duration(seconds: 5),
      reverseDuration: const Duration(seconds: 5),
      vsync: this,
    );
    timerController.addListener(() {
      if (timerController.status == AnimationStatus.dismissed) {
        textController.forward().then((value) => textController.reverse());
      }
    });
    textAnimation =
        CurvedAnimation(parent: textController, curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  String get timerString {
    Duration duration = timerController.duration! * timerController.value;
    int value = 10 - duration.inSeconds;
    if (value == 10) {
      confettiController.play();
    }
    return '00:58:${(value + 18).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: AnimatedBuilder(
          animation: timerController,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/spring.png',
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.grey.withOpacity(0.8),
                    height: timerController.value *
                        MediaQuery.of(context).size.height,
                  ),
                ),
                timerController.value == 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int index = 0; index < 2; index++)
                            ConfettiWidget(
                              confettiController: confettiController,
                              blastDirectionality:
                                  BlastDirectionality.explosive,
                              emissionFrequency: 0.05,
                              numberOfParticles: 30,
                            )
                        ],
                      )
                    : const SizedBox(),
                Align(
                  alignment: FractionalOffset.center,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: timerController.value != 0
                        ? Stack(
                            children: <Widget>[
                              Center(
                                child: SizedBox(
                                  width: 250,
                                  height: 250,
                                  child: CustomPaint(
                                    painter: TimerPainter(
                                      animation: timerController,
                                      backgroundColor: Colors.transparent,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: FractionalOffset.center,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      timerString,
                                      style: TextStyle(
                                        fontSize: 40.0,
                                        fontFamily: 'Sarbaz',
                                        color: Colors.green.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ScaleTransition(
                            scale: textAnimation,
                            child: Center(
                                child: Text(
                              'نوروز 1402 مبارک',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Sarbaz',
                                fontSize: 70,
                              ),
                              textAlign: TextAlign.center,
                            )),
                          ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
