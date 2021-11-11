import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolname/utils/colors.dart';
import 'package:flutter/material.dart';
import '../tag.dart';

class SearchTags extends StatefulWidget {
  const SearchTags({Key key}) : super(key: key);

  @override
  _SearchTagsState createState() => _SearchTagsState();
}

class _SearchTagsState extends State<SearchTags> {

  TextEditingController search = TextEditingController();
  QuerySnapshot querySnapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              child: TextField(
                controller: search,
                decoration: InputDecoration(
                  hintText: 'Search hashtags',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                  ),
                  suffixIcon: IconButton(
                    onPressed: (){
                      FocusScope.of(context).unfocus();
                      FirebaseFirestore.instance
                          .collection('AllTags')
                          .where('tag', isGreaterThanOrEqualTo: search.text.trim().toLowerCase())
                          .where('tag', isLessThan: search.text.trim().toLowerCase() + 'z')
                          .get()
                          .then((value) {
                        setState(() {
                          querySnapshot = value;
                        });
                      });
                    },
                    icon: Icon(
                      Icons.search,
                      color: mlight,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.black
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.black
                    ),
                  ),
                ),
              ),
            ),
            if(querySnapshot != null)
              if(querySnapshot.docs.length == 0)
                Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Text('No results found for \n "${search.text.trim()}"',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w300
                      ),
                    )
                ),
            querySnapshot != null ?
            ListView.builder(
              shrinkWrap: true,
              itemCount: querySnapshot.docs.length,
              physics: ScrollPhysics(),
              itemBuilder: (context, index){
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: Text('#',
                            style: TextStyle(
                              color: mlight,
                              fontSize: 30
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(querySnapshot.docs[index].get("tag"),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Tag(
                      tag: querySnapshot.docs[index].get("tag"),
                    )));
                  },
                );
              },
            ) : Container(),
          ],
        ),
      ),
    );
  }
}