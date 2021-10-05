import 'package:coolname/views/bottomSheet/addVideos.dart';
import 'package:flutter/material.dart';

class VideosTabPage extends StatefulWidget {
  const VideosTabPage({Key key}) : super(key: key);

  @override
  _VideosTabPageState createState() => _VideosTabPageState();
}

class _VideosTabPageState extends State<VideosTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch',
          style: TextStyle(
              color: Colors.black,
              fontSize: 22
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.black,
              size: 25,
            ),
            onPressed: (){
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddVideos(),
              );
            },
          ),
        ],
      ),
    );
  }
}