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



class NowBarHome extends StatefulWidget {

  const NowBarHome({super.key});

  @override
  State<NowBarHome> createState() => _NowBarHomeState();

}


class _NowBarHomeState extends State<NowBarHome> {

  bool isPlaying = false;


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


              borderRadius:

                  BorderRadius.circular(8),


            ),


            child: Row(

              children: [


                const SizedBox(width: 8),



                Container(

                  width: 50,

                  height: 50,


                  decoration: BoxDecoration(

                    color: Colors.grey,

                    borderRadius:

                        BorderRadius.circular(8),

                  ),


                  child: ClipRRect(

  borderRadius: BorderRadius.circular(8),

  child: Image.asset(

    "assets/jacket.png",

    fit: BoxFit.cover,

  ),

),

                ),



                const SizedBox(width: 10),



                const Expanded(

                  child: Column(

                    mainAxisAlignment:

                        MainAxisAlignment.center,


                    crossAxisAlignment:

                        CrossAxisAlignment.start,


                    children: [


                      Text(

                        "Blinding Lights",

                        overflow:

                            TextOverflow.ellipsis,


                        style: TextStyle(

                          fontSize: 15,

                          fontWeight:

                              FontWeight.bold,

                        ),

                      ),



                      Text(

                        "The Weeknd",

                        style: TextStyle(

                          fontSize: 12,

                          color:

                              Colors.white70,

                        ),

                      ),

                    ],

                  ),

                ),



                IconButton(

                  padding: EdgeInsets.zero,

                  constraints:

                      const BoxConstraints(),


                  onPressed: () {},


                  icon: const Icon(

                    Icons.skip_previous,

                    size: 22,

                  ),

                ),



                IconButton(

  padding: EdgeInsets.zero,

  constraints:
      const BoxConstraints(),

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

                  constraints:

                      const BoxConstraints(),


                  onPressed: () {},


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