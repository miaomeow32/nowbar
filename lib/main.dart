import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await windowManager.ensureInitialized();


  const windowOptions = WindowOptions(

    size: Size(520, 64),

    minimumSize: Size(520, 64),

    maximumSize: Size(520, 64),

    center: true,

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


  // bitsdojo_window設定
  doWhenWindowReady(() {

    final win = appWindow;


    win.minSize = const Size(520, 64);

    win.size = const Size(520, 64);


    win.alignment = Alignment.center;


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

      ),


      home: const NowBarHome(),

    );

  }

}




class NowBarHome extends StatelessWidget {

  const NowBarHome({super.key});



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: Colors.transparent,


      body: GestureDetector(

        onPanStart: (_) {

          windowManager.startDragging();

        },


        child: Container(

          margin: const EdgeInsets.all(0),


          decoration: BoxDecoration(

            color: const Color(0xff181818),


            borderRadius:

                BorderRadius.circular(12),


            boxShadow: const [

              BoxShadow(

                blurRadius: 15,

                color: Colors.black54,

              ),

            ],

          ),


          child: Row(

            children: [


              const SizedBox(width: 8),



              Container(

                width: 45,

                height: 45,


                decoration: BoxDecoration(

                  borderRadius:

                      BorderRadius.circular(8),


                  color: Colors.grey,

                ),


                child: const Center(

                  child: Text(

                    "🎵",

                    style: TextStyle(

                      fontSize: 22,

                    ),

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


                onPressed: () {},


                icon: const Icon(

                  Icons.play_circle_fill,

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

    );

  }

}