import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();


  const windowOptions = WindowOptions(

    size: Size(520, 55),

    minimumSize: Size(520, 55),

    maximumSize: Size(520, 55),

    backgroundColor: Colors.transparent,

    skipTaskbar: false,

    titleBarStyle: TitleBarStyle.hidden,

  );


  await windowManager.waitUntilReadyToShow(

    windowOptions,

    () async {

      await windowManager.show();

      await windowManager.focus();

      await windowManager.setAlwaysOnTop(true);

    },

  );


  doWhenWindowReady(() {

    final win = appWindow;


    win.minSize = const Size(520, 55);

    win.size = const Size(520, 55);


    win.show();

  });


  runApp(const NowBarApp());

}



class NowBarApp extends StatelessWidget {

  const NowBarApp({super.key});


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,


      theme: ThemeData(

        brightness: Brightness.dark,

        scaffoldBackgroundColor: Colors.transparent,

      ),


      home: const NowBarHome(),

    );

  }

}

class SongInfo {

  final String title;

  final String artist;

  final String imagePath;


  const SongInfo({

    required this.title,

    required this.artist,

    required this.imagePath,

  });

}

class NowBarHome extends StatefulWidget {

  const NowBarHome({super.key});

  @override
  State<NowBarHome> createState() => _NowBarHomeState();

}


class _NowBarHomeState extends State<NowBarHome> {

  bool isPlaying = false;


  final List<SongInfo> songs = [

  const SongInfo(

    title: "Blinding Lights",

    artist: "The Weeknd",

    imagePath: "assets/jacket.png",

  ),


  const SongInfo(

    title: "Starboy",

    artist: "The Weeknd",

    imagePath: "assets/jacket2.png",

  ),

];


int currentSong = 0;


SongInfo get song => songs[currentSong];


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: Colors.transparent,


      body: ClipRRect(

        borderRadius: BorderRadius.circular(8),


        child: GestureDetector(

          onPanStart: (_) {

            windowManager.startDragging();

          },


          child: Container(

            decoration: BoxDecoration(

              color: const Color(0xff181818),

              borderRadius: BorderRadius.circular(8),

            ),


            child: Row(

              children: [


                const SizedBox(width: 8),



                SizedBox(

  width: 80,

  height: 80,

  child: AnimatedSwitcher(

    duration: const Duration(milliseconds: 300),

    transitionBuilder: (child, animation) {

      return FadeTransition(

        opacity: animation,

        child: child,

      );

    },

    child: ClipRRect(

      key: ValueKey(song.imagePath),

      borderRadius: BorderRadius.circular(8),

      child: Image.asset(

        song.imagePath,

        fit: BoxFit.cover,

      ),

    ),

  ),

),



                const SizedBox(width: 10),



                Expanded(

                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,

                    crossAxisAlignment: CrossAxisAlignment.start,


                    children: [


                      AnimatedSwitcher(

  duration: const Duration(milliseconds: 300),

  layoutBuilder: (currentChild, previousChildren) {

    return Stack(

      alignment: Alignment.centerLeft,

      children: [

        ...previousChildren,

        if (currentChild != null) currentChild,

      ],

    );

  },

  transitionBuilder: (child, animation) {

    return FadeTransition(

      opacity: animation,

      child: child,

    );

  },

  child: Text(

    song.title,

    key: ValueKey(song.title),

    overflow: TextOverflow.ellipsis,

    style: const TextStyle(

      fontSize: 15,

      fontWeight: FontWeight.bold,

    ),

  ),

),



                      AnimatedSwitcher(

  duration: const Duration(milliseconds: 300),

  layoutBuilder: (currentChild, previousChildren) {

    return Stack(

      alignment: Alignment.centerLeft,

      children: [

        ...previousChildren,

        if (currentChild != null) currentChild,

      ],

    );

  },

  transitionBuilder: (child, animation) {

    return FadeTransition(

      opacity: animation,

      child: child,

    );

  },

  child: Text(

    song.artist,

    key: ValueKey(song.artist),

    style: const TextStyle(

      fontSize: 12,

      color: Colors.white70,

    ),

  ),

),

                    ],

                  ),

                ),



                IconButton(

  padding: EdgeInsets.zero,

  constraints: const BoxConstraints(),


  onPressed: () {

    setState(() {

      currentSong--;


      if (currentSong < 0) {

        currentSong = songs.length - 1;

      }

    });

  },


  icon: const Icon(

    Icons.skip_previous,

    size: 22,

  ),

),



IconButton(

  padding: EdgeInsets.zero,

  constraints: const BoxConstraints(),


  onPressed: () {

    setState(() {

      isPlaying = !isPlaying;

    });

  },


  icon: Icon(

    isPlaying

        ? Icons.pause_circle

        : Icons.play_circle_fill,


    size: 32,

  ),

),



                IconButton(

                  padding: EdgeInsets.zero,

                  constraints: const BoxConstraints(),

                  onPressed: () {

                    setState(() {

                      currentSong++;

                      if (currentSong >= songs.length) {

                        currentSong = 0;

                      }

                    });

                  },

                  icon: const Icon(

                    Icons.skip_next,

                    size: 22,

                  ),

                ),

                const SizedBox(width: 8),

              ],

            ),

          ),

        ),

      ),

    );

  }

}