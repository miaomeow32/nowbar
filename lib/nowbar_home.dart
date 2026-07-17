import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:window_manager/window_manager.dart';

import 'player_data.dart';



class NowBarHome extends StatefulWidget {

  const NowBarHome({super.key});


  @override
  State<NowBarHome> createState()
      => _NowBarHomeState();

}







class _NowBarHomeState
    extends State<NowBarHome> {


  final PlayerData player =
      PlayerData();



  int imageVersion = 0;


  DateTime? lastModified;









  @override
  void initState(){

    super.initState();



    player.onUpdate = () async {


      if(player.image.isNotEmpty){


        try{


          final file =
          File(player.image);



          if(await file.exists()){


            final modified =
            await file.lastModified();



            if(lastModified != modified){


              lastModified =
                  modified;



              imageVersion++;




              // Flutter画像キャッシュ削除

              PaintingBinding
                  .instance
                  .imageCache
                  .clear();

              PaintingBinding
                  .instance
                  .imageCache
                  .clearLiveImages();


            }


          }


        }
        catch(_){}


      }




      if(mounted){

        setState((){});

      }


    };



    player.start();


  }









  String timeText(double sec){


    int s =
        sec.floor();


    int m =
        s ~/ 60;


    int ss =
        s % 60;



    return
        "$m:${ss.toString().padLeft(2,'0')}";


  }









  Widget albumImage(){


    if(
    player.image.isNotEmpty &&
        File(player.image).existsSync()
    ){


      final file =
      File(player.image);



      int stamp = 0;



      try{

        stamp =
            file.lastModifiedSync()
                .millisecondsSinceEpoch;

      }
      catch(_){}





      return Image(

        key:

        ValueKey(
  "${file.path}_${stamp}_$imageVersion",
),



        image:

        FileImage(
          file,
        ),



        width:45,

        height:45,



        fit:

        BoxFit.cover,



        gaplessPlayback:false,



        errorBuilder:

            (context,error,stack){


          return Container(

            color:
            const Color(0xff333333),

          );


        },


      );


    }





    return Container(

      color:
      const Color(0xff333333),

    );


  }









  @override
  void dispose(){


    player.dispose();


    super.dispose();


  }









  @override
  Widget build(BuildContext context){



    double position =
        player.smoothPosition;



    double progress =
        player.duration <= 0
            ?
        0
            :
        position / player.duration;



    progress =
        progress.clamp(0,1);







    return Scaffold(

      backgroundColor:
      Colors.transparent,



      body:


      ClipRRect(

        borderRadius:
        BorderRadius.circular(8),



        child:


        GestureDetector(

          onPanStart:(_){

            windowManager.startDragging();

          },



          child:


          Container(

            padding:

            const EdgeInsets.symmetric(
              horizontal:8,
            ),



            decoration:

            BoxDecoration(

              color:
              const Color(0xff181818),


              borderRadius:
              BorderRadius.circular(8),

            ),




            child:


            Row(

              children:[



                SizedBox(

                  width:45,

                  height:45,


                  child:

                  ClipRRect(

                    borderRadius:
                    BorderRadius.circular(6),


                    child:

                    albumImage(),


                  ),

                ),





                const SizedBox(width:8),






                Expanded(

                  child:


                  Column(

                    mainAxisAlignment:
                    MainAxisAlignment.center,


                    crossAxisAlignment:
                    CrossAxisAlignment.start,



                    children:[



                      AnimatedSwitcher(

  duration:
  const Duration(milliseconds:300),


  layoutBuilder:
      (currentChild, previousChildren){

    return Stack(

      alignment:
      Alignment.centerLeft,


      children:[

        ...previousChildren,

        if(currentChild != null)
          currentChild,

      ],

    );

  },


  transitionBuilder:
      (child, animation){

    return FadeTransition(

      opacity: animation,


      child:

      SlideTransition(

        position:

        Tween<Offset>(

          begin:
          const Offset(0,0.08),

          end:
          Offset.zero,

        ).animate(animation),


        child: child,

      ),

    );

  },


  child:

  Text(

    player.title.isEmpty

        ?

    "No Music"

        :

    player.title,


    key:

    ValueKey(player.title),


    maxLines:1,


    overflow:
    TextOverflow.ellipsis,


    style:

    const TextStyle(

      fontSize:13,

      fontWeight:
      FontWeight.bold,

    ),

  ),

),






AnimatedSwitcher(

  duration:
  const Duration(milliseconds:300),


  layoutBuilder:
      (currentChild, previousChildren){

    return Stack(

      alignment:
      Alignment.centerLeft,


      children:[

        ...previousChildren,

        if(currentChild != null)
          currentChild,

      ],

    );

  },


  transitionBuilder:
      (child, animation){

    return FadeTransition(

      opacity: animation,


      child:

      SlideTransition(

        position:

        Tween<Offset>(

          begin:
          const Offset(0,0.08),

          end:
          Offset.zero,

        ).animate(animation),


        child: child,

      ),

    );

  },


  child:

  Text(

    player.artist,


    key:

    ValueKey(player.artist),


    maxLines:1,


    overflow:
    TextOverflow.ellipsis,


    style:

    const TextStyle(

      fontSize:10,

      color:
      Colors.white70,

    ),

  ),

),





                      Row(

                        children:[



                          Expanded(

                            child:

                            LinearProgressIndicator(

                              value:
                              progress,


                              minHeight:
                              3,


                            ),

                          ),





                          const SizedBox(width:5),





                          Text(

                            "${timeText(position)}/${timeText(player.duration)}",


                            style:

                            const TextStyle(

                              fontSize:8,

                              color:
                              Colors.white60,

                            ),

                          ),


                        ],

                      ),



                    ],

                  ),

                ),






                IconButton(

                  padding:
                  EdgeInsets.zero,


                  constraints:
                  const BoxConstraints(),



                  icon:

                  const Icon(

                    Icons.skip_previous,

                    size:20,

                  ),



                  onPressed:(){

                    player.command(
                      "previous",
                    );

                  },

                ),








                IconButton(

                  padding:
                  EdgeInsets.zero,


                  constraints:
                  const BoxConstraints(),



                  icon:

                  Icon(

                    player.isPlaying

                        ?

                    Icons.pause_circle

                        :

                    Icons.play_circle_fill,


                    size:28,

                  ),



                  onPressed:(){


                    player.command(
                      "playpause",
                    );


                  },


                ),







                IconButton(

                  padding:
                  EdgeInsets.zero,


                  constraints:
                  const BoxConstraints(),



                  icon:

                  const Icon(

                    Icons.skip_next,

                    size:20,

                  ),



                  onPressed:(){


                    player.command(
                      "next",
                    );


                  },


                ),






                const SizedBox(width:4),



              ],

            ),

          ),

        ),

      ),

    );


  }


}