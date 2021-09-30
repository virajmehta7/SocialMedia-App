import 'package:flutter/material.dart';

class CenterPhoto extends StatefulWidget {
  final username, photo;
  const CenterPhoto({Key key, this.username, this.photo}) : super(key: key);

  @override
  _CenterPhotoState createState() => _CenterPhotoState();
}

class _CenterPhotoState extends State<CenterPhoto> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: (){
          Navigator.pop(context);
        },
        behavior: HitTestBehavior.translucent,
        child: Card(
          margin: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Text(widget.username,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
                child: Image.network(widget.photo),
              ),
            ]
          ),
        ),
      )
    );
  }
}