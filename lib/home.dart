// import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:editor/trimmer.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';

import 'common.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  ///video 1
  File? video1File;
  VideoPlayerController? video1Controller;
  Future? video1Init;

  ///video 2
  File? video2File;
  VideoPlayerController? video2Controller;
  Future? video2Init;

  ///merged video
  File? mergedVideo;
  VideoPlayerController? mergeVideoController;
  Future? mergeVideoInit;

  Future<void> initializePlayer1() async {
    video1Controller = VideoPlayerController.file(video1File!);
    setState(() {});
    await Future.wait([video1Controller!.initialize()]);
    video1Controller!.play();
    video1Controller!.setLooping(true);
  }

  Future<void> initializePlayer2() async {
    video2Controller = VideoPlayerController.file(video2File!);
    setState(() {});
    await Future.wait([video2Controller!.initialize()]);
    video2Controller!.play();
    video2Controller!.setLooping(true);
  }

  Future<void> initializeMergeVideoPlayer() async {
    mergeVideoController = VideoPlayerController.file(mergedVideo!);
    setState(() {});
    await Future.wait([mergeVideoController!.initialize()]);
    mergeVideoController!.play();
    mergeVideoController!.setLooping(true);
  }

  Future<void> _onImageButtonPressed(ImageSource source, bool isVideo1) async {
    final XFile? file = await _picker.pickVideo(
        source: source, maxDuration: const Duration(seconds: 10));
    if (file != null) {
      trimVideo(file, isVideo1);
    }
  }

  @override
  void deactivate() {
    if (video1Controller != null) {
      video1Controller!.setVolume(0.0);
      video1Controller!.pause();
    }
    if (video2Controller != null) {
      video2Controller!.setVolume(0.0);
      video2Controller!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    video2Controller!.dispose();
    video1Controller!.dispose();
    super.dispose();
  }

  Widget _previewVideo() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: 200,
              width: 150,
              color: Colors.red,
              child: video1File != null && video1Controller != null
                  ? FutureBuilder(
                      future: video1Init,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          return VideoPlayer(video1Controller!);
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    )
                  : TextButton(
                      onPressed: () {
                        _onImageButtonPressed(ImageSource.gallery, true);
                      },
                      child: const Text("video 1"),
                    ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              height: 200,
              width: 150,
              color: Colors.greenAccent,
              child: video2File != null && video2Controller != null
                  ? FutureBuilder(
                      future: video2Init,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          return VideoPlayer(video2Controller!);
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    )
                  : TextButton(
                      onPressed: () {
                        _onImageButtonPressed(ImageSource.camera, false);
                      },
                      child: const Text("video 2"),
                    ),
            ),
          ],
        ),

        ///play pause buttons
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (video1Controller != null) {
                        video1Controller!.pause();
                      }
                    },
                    child: const Text("pause video 1"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (video1Controller != null) {
                        video1Controller!.play();
                      }
                    },
                    child: const Text("play video 1"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (video2Controller != null) {
                        video2Controller!.pause();
                      }
                    },
                    child: const Text("pause video 2"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (video2Controller != null) {
                        video2Controller!.play();
                      }
                    },
                    child: const Text("play video 2"),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (video1File != null && video2File != null)
          ElevatedButton(
            onPressed: () {
              if (!isLoading) {
                _videoMerger(video1File!, video2File!);
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
            ),
            child: Text(isLoading ? "processing.." : "Merge two videos"),
          ),
        const SizedBox(
          height: 10,
        ),

        ///merged video player
        if (mergedVideo != null && mergeVideoController != null)
          SizedBox(
            height: 100,
            width: 150,
            child: FutureBuilder(
              future: mergeVideoInit,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const CircularProgressIndicator();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return VideoPlayer(mergeVideoController!);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
      ],
    );
  }

  void _videoMerger(File file1, File file2) async {
    print("_videoMerger");
    setState(() {
      isLoading = true;
    });
    final appDir = await getApplicationSupportDirectory();
    String rawDocumentPath = appDir.path;
    final outputPath =
        "$rawDocumentPath/${DateTime.now().microsecondsSinceEpoch}.mp4";
    print(file1.path);
    print(file2.path);
    print(outputPath);
    // String path = "assets/sample.mp4";
    String commandToExecute =
        '-y -i ${file1.path} -i ${file2.path} -r 24000/1001 -filter_complex \'[0:v:0][0:a:0][1:v:0][1:a:0]concat=n=2:v=1:a=1[out]\' -map \'[out]\' $outputPath';

    // "-y -i ${file1.path} -i ${file2.path} -r 24000/1001 -filter_complex '[0:v] [0:a] [1:v] [1:a] concat=n=2:v=1:a=1 [v] [a]' -map [v] -map [a] -c:v libx264 $outputPath";
    FFmpegKit.executeAsync(commandToExecute, (session) async {
      final state =
          FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();

      debugPrint("FFmpeg process exited with state $state and rc $returnCode");
      setState(() {
        isLoading = false;
      });
      if (ReturnCode.isSuccess(returnCode)) {
        // ignore: use_build_context_synchronously
        showSnack(context, "FFmpeg processing completed successfully.");
        debugPrint("FFmpeg processing completed successfully.");
        debugPrint('Video successfully saved');
        mergedVideo = File(outputPath);
        setState(() {
          if (mergedVideo != null) {
            mergeVideoInit = initializeMergeVideoPlayer();
          }
        });
        // onSave(_outputPath);
      } else {
        // ignore: use_build_context_synchronously
        showSnack(context, 'FFmpeg processing failed.');
        debugPrint("FFmpeg processing failed.");
        debugPrint('Couldn\'t save the video');
        // onSave(null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: _previewVideo(),
      ),
    );
  }

  void trimVideo(XFile? video, bool isVideo1) async {
    if (isVideo1) {
      video1File = await Navigator.push(context,
          MaterialPageRoute(builder: (ctx) => TrimmerView(File(video!.path))));
      // video1File = File(video!.path);
      setState(() {
        if (video1File != null) {
          video1Init = initializePlayer1();
        }
      });
    } else {
      video2File = await Navigator.push(context,
          MaterialPageRoute(builder: (ctx) => TrimmerView(File(video!.path))));
      // video2File = File(video!.path);
      setState(() {
        if (video2File != null) {
          video2Init = initializePlayer2();
        }
      });
    }
  }
}
