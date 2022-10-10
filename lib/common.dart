import 'package:flutter/material.dart';

///progress dialogue with content
void progressDialogue(BuildContext context, {required String content}) {
  AlertDialog alert = AlertDialog(
    key: const ObjectKey('loader'),
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            child: Row(
              children: [
                Flexible(child: Text(content)),
                const SizedBox(
                  width: 10,
                ),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  showDialog<dynamic>(
    //prevent outside touch
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      //prevent Back button press
      return WillPopScope(onWillPop: () async => false, child: alert);
    },
  );
}

///snack bar
showSnack(BuildContext context, String message) {
  final snackBar = SnackBar(content: Text(message));
  ScaffoldMessenger.of(context).showSnackBar(
    snackBar,
  );
}
