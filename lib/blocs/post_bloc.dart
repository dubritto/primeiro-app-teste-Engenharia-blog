import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clube_da_obra/model/post_model.dart';
import 'package:rxdart/rxdart.dart';

enum PostState{IDLE, LOADING, DONE, FAIL, SUCCESS}

class PostBloc extends BlocBase{

  final _dataController = BehaviorSubject<Map>();
  final _loadingController = BehaviorSubject<bool>();
  final _createdController = BehaviorSubject<bool>();


  Stream<Map> get outData => _dataController.stream;
  Stream<bool> get outLoading => _loadingController.stream;
  Stream<bool> get outCreated => _createdController.stream;

  String feedBackId;
  DocumentSnapshot post;

  Map<String, dynamic> unsavedData;

  PostBloc({this.feedBackId, this.post}){
    if(post != null){
      unsavedData = Map.of(post.data);
      unsavedData["images"] = List.of(post.data["images"]);

      _createdController.add(true);
    }else{
      unsavedData = {
        "subjects" : null, "description": null, "images": []
      };

      _createdController.add(false);
    }

    _dataController.add(unsavedData);
  }



  @override
  void dispose() {
    _dataController.close();
    _loadingController.close();
    _createdController.close();
  }




  /*savePostModel(PostModel postModel){
    _stateController.add(PostState.LOADING);


    Future.delayed(Duration(seconds: 3));

    _stateController.add(PostState.DONE);

    return true;
  }*/


}