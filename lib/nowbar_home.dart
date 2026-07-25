import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image/image.dart' as img;
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



  // ジャケットから取得した色

  Color themeColor =
    const Color(0xff2196f3);








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



              // 色更新

              updateThemeColor();



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









  // =========================
  // ジャケット色取得
  // =========================

  Future<void> updateThemeColor() async {


    try{


      final file =
          File(player.image);



      if(!await file.exists())
        return;



      final bytes =
          await file.readAsBytes();



      final image =
          img.decodeImage(bytes);



      if(image == null)
        return;



      Map<String,int> colors = {};



      for(
        int y = 0;
        y < image.height;
        y += 10
      ){


        for(
          int x = 0;
          x < image.width;
          x += 10
        ){


          final pixel =
              image.getPixel(x,y);



          int r =
              pixel.r.toInt();


          int g =
              pixel.g.toInt();


          int b =
              pixel.b.toInt();



          int brightness =
              (r + g + b) ~/ 3;



          // 黒・白を除外

          if(
            brightness < 35 ||
            brightness > 230
          ){

            continue;

          }



          // 近い色をまとめる

          r =
          (r ~/ 20) * 20;


          g =
          (g ~/ 20) * 20;


          b =
          (b ~/ 20) * 20;



          String key =
              "$r,$g,$b";



          colors[key] =
              (colors[key] ?? 0) + 1;


        }

      }



      if(colors.isEmpty)
        return;



      String result =
          colors.entries
              .reduce(
                (a,b)=>
                a.value > b.value
                    ?
                a
                    :
                b,
              )
              .key;



      List<int> rgb =
          result
              .split(",")
              .map(int.parse)
              .toList();



            Color newColor =
          Color.fromARGB(
            255,
            rgb[0],
            rgb[1],
            rgb[2],
          );


      // =========================
      // 文字用カラー補正
      // =========================

      double brightness =
          (newColor.red +
          newColor.green +
          newColor.blue) / 3;



      double r =
          newColor.red.toDouble();

      double g =
          newColor.green.toDouble();

      double b =
          newColor.blue.toDouble();



      // 暗い色なら明るくする

      if(brightness < 100){

        r += 90;
        g += 90;
        b += 90;

      }


      // 明るすぎる色は少し暗く

      if(brightness > 220){

        r *= 0.75;
        g *= 0.75;
        b *= 0.75;

      }



      newColor =
          Color.fromARGB(

            255,

            r.clamp(0,255).toInt(),

            g.clamp(0,255).toInt(),

            b.clamp(0,255).toInt(),

          );



      if(mounted){

        setState((){

          themeColor =
              newColor;

        });

      }


    }
    catch(e){


      debugPrint(
        "Theme color error : $e",
      );


    }

  }
    // =========================
  // 背景ジャケット
  // =========================

  Widget backgroundImage(){


    if(
      player.image.isNotEmpty &&
      File(player.image).existsSync()
    ){


      return Positioned.fill(

        child:

        Image.file(

          File(player.image),


          key:

          ValueKey(
            "background_$imageVersion",
          ),


          fit:

          BoxFit.cover,


        ),

      );


    }


    return const SizedBox();

  }









  // =========================
  // 左側ジャケット
  // =========================

  Widget albumImage(){


    if(
      player.image.isNotEmpty &&
      File(player.image).existsSync()
    ){


      final file =
          File(player.image);



      return Image(

        key:

        ValueKey(
          "${file.path}_$imageVersion",
        ),



        image:

        FileImage(
          file,
        ),



        fit:

        BoxFit.cover,



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


          Stack(

            children:[



              // 背景画像

              backgroundImage(),






              // ぼかし

              Positioned.fill(

                child:

                BackdropFilter(

                  filter:

                  ImageFilter.blur(

                    sigmaX:8,

                    sigmaY:8,

                  ),



                  child:

                  Container(

                    color:

                    Colors.black.withOpacity(
                      0.35,
                    ),

                  ),

                ),

              ),






              // 暗幕

              Positioned.fill(

                child:

                Container(

                  color:

                  Colors.black.withOpacity(
                    0.25,
                  ),

                ),

              ),






              // メインUI

              Container(

                padding:

                const EdgeInsets.symmetric(

                  horizontal:8,

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





                    const SizedBox(
                      width:8,
                    ),






                    Expanded(

                      child:

                      Column(

                        mainAxisAlignment:

                        MainAxisAlignment.center,


                        crossAxisAlignment:

                        CrossAxisAlignment.start,



                        children:[



                          TweenAnimationBuilder<Color?>(
  tween: ColorTween(
    end: themeColor,
  ),
  duration: const Duration(
    milliseconds: 600,
  ),

  builder: (context, color, child){

    return Text(

      player.title.isEmpty
          ?
      "No Music"
          :
      player.title,


      maxLines:1,

      overflow:
      TextOverflow.ellipsis,


      style: TextStyle(

        fontSize:13,

        fontWeight:
        FontWeight.bold,


        color:
        color,

      ),

    );

  },

),





                          Text(

                            player.artist,


                            maxLines:

                            1,


                            overflow:

                            TextOverflow.ellipsis,


                            style:

                            TextStyle(

                              fontSize:10,


                              color:

                              themeColor.withOpacity(
                                0.75,
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


                                  color:

                                  themeColor,


                                ),

                              ),





                              const SizedBox(
                                width:5,
                              ),





                              Text(

                                "${timeText(position)}/${timeText(player.duration)}",


                                style:

                                const TextStyle(

                                  fontSize:8,


                                  color:

                                  Colors.white70,

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


                        color:

                        themeColor,


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






                    const SizedBox(
                      width:4,
                    ),



                  ],

                ),

              ),

            ],

          ),

        ),

      ),

    );


  }








  @override
  void dispose(){


    player.dispose();


    super.dispose();

  }


}