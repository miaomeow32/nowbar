import 'dart:convert';
import 'dart:io';
import 'dart:async';


class PlayerData {


  final String jsonPath =
      r"C:\dev\nowbar\nowplaying.json";


  final String commandPath =
      r"C:\dev\nowbar\command.json";



  String title = "";

  String artist = "";

  String image = "";


  bool isPlaying = false;


  double duration = 1;

  double position = 0;



  double syncPosition = 0;

  DateTime? lastSync;



  Timer? timer;


  Function? onUpdate;





  void start(){


    timer = Timer.periodic(

      const Duration(milliseconds:200),

          (_) {

        read();

      },

    );


  }







  Future<void> read() async {


    try{


      final file = File(jsonPath);



      if(!await file.exists()){

        return;

      }




      final text =
      await file.readAsString();




      final data =
      jsonDecode(text);





      title =
          data["title"]?.toString() ?? "";


      artist =
          data["artist"]?.toString() ?? "";


      image =
          data["image"]?.toString() ?? "";





      bool playing =
          data["isPlaying"] == true;



      double newDuration =
      (data["duration"] ?? 1)
          .toDouble();



      double newPosition =
      (data["position"] ?? 0)
          .toDouble();




      duration =
          newDuration;



      // 再生位置同期

      syncPosition =
          newPosition;


      lastSync =
          DateTime.now();


      position =
          newPosition;



      isPlaying =
          playing;




      if(onUpdate != null){

        onUpdate!();

      }


    }

    catch(e){

      print(
          "PlayerData error $e"
      );

    }


  }








  double get smoothPosition {


    if(
    isPlaying &&
        lastSync != null
    ){


      double value =

          syncPosition +

              DateTime.now()
                  .difference(lastSync!)
                  .inMilliseconds
                  /
                  1000;




      if(value > duration){

        value = duration;

      }


      return value;


    }


    return position;


  }









  Future<void> command(String value) async {


    try{


      await File(commandPath)

          .writeAsString(

        jsonEncode({

          "command":value

        }),

      );


    }

    catch(e){

      print(e);

    }


  }








  void dispose(){

    timer?.cancel();

  }


}