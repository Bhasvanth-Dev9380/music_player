import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:wear/wear.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AmbientMode(
      builder: (BuildContext context, WearMode mode, Widget? child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: mode == WearMode.active?  ColorScheme.fromSeed(seedColor: Colors.deepPurple): const ColorScheme.dark(),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late  StreamSubscription<RotaryEvent> rotarySubscription;
  bool isPlaying = false;
  final player = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
   rotarySubscription=
    rotaryEvents.listen((RotaryEvent event) {
      if (event.direction == RotaryDirection.clockwise) {
        _incrementCounter();
        // Do something.
      } else if (event.direction == RotaryDirection.counterClockwise) {
        _decrementCounter();
        // Do something.
      }
    });

   player.onPlayerStateChanged.listen((state) {
     setState(() {
       isPlaying = state == PlayerState.playing;
     });
   });

   player.onDurationChanged.listen((newDuration) {
     setState(() {
       duration = newDuration;
     });
   });

   player.onPositionChanged.listen((newPosition) {
     setState(() {
       position = newPosition;
     });
   });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    rotarySubscription.cancel();
    player.release();
    super.dispose();
  }
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      if(position.inSeconds >=1){
        player.seek(Duration(seconds: position.inSeconds +1));
      }
    });
  }

  void _decrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter--;
      if(position.inSeconds < duration.inSeconds){
        player.seek(Duration(seconds: position.inSeconds -1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(alignment: Alignment.center, children: [
              SleekCircularSlider(
                appearance: CircularSliderAppearance(
                    size: MediaQuery.of(context).size.height / 2,
                    customColors:
                    CustomSliderColors(dotColor: Colors.deepPurple),
                    customWidths: CustomSliderWidths(
                        progressBarWidth: 5, handlerSize: 10)),
                initialValue: position.inSeconds.toInt() +0.5 ,
                max: duration.inSeconds.toInt() + 1,
                onChange: (value) {
                  player.seek(Duration(seconds: value.toInt()));
                  player.play(AssetSource('aigiri.mp3'));
                },
              ),
              ClipRRect(
                child: Container(
                  height: MediaQuery.of(context).size.height / 2.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/aigiri.jpg'),
                    ),
                  ),
                ),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  child: IconButton(onPressed: () {
                    if(isPlaying){
                      player.pause();
                    }else{
                      player.play(AssetSource('aigiri.mp3'));
                    }
                  }, icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow_rounded),

                  ),
                ),
                Text(
                  '${position.inSeconds}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
