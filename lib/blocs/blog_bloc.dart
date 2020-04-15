import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class BlogBloc extends BlocBase{

  final _blogController = BehaviorSubject();

  Map<String, Map<String, dynamic>> _users = {};

  Firestore _firestore = Firestore.instance;

  BlogBloc(){
    _addBlogListener();
  }

  void _addBlogListener(){
    _firestore.collection("users").snapshots().listen((snapshot){
      snapshot.documentChanges.forEach((change){
        String uid = change.document.documentID;
        switch(change.type){
          case DocumentChangeType.added:
            _users[uid] = change.document.data;
            break;
          case DocumentChangeType.modified:
            _users[uid].addAll(change.document.data);
            break;
          case DocumentChangeType.removed:
            _users.remove(uid);
            break;
        }
      });
    });
  }

  void subscribeToFeedBack(String uid) async {
     _firestore.collection("users").document(uid)
        .collection("feedback").getDocuments();

  }

  @override
  void dispose() {
    _blogController.close();
  }

}