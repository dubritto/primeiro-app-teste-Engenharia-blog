import 'dart:async';
import 'dart:io';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clube_da_obra/validator/signup_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';


enum ProfileState { IDLE, LOADING, SUCCESS, FAIL }

class ProfileBloc extends BlocBase with SignUpValidators{

  final _occupationController = BehaviorSubject<String>();
  final _nameController = BehaviorSubject<String>();
  final _descriptionBioController = BehaviorSubject<String>();


  final _stateController = BehaviorSubject<ProfileState>();



  Stream<String> get outOccupation =>
      _occupationController.stream.transform(validateOccupation);
  Stream<String> get outName =>
      _nameController.stream.transform(validateName);
  Stream<String> get outDescriptionBio =>
      _descriptionBioController.stream.transform(validateDescriptionBio);
  Stream<ProfileState> get outState => _stateController.stream;


  Stream<bool> get outSubmitValid =>
      Observable.combineLatest3(outName, outOccupation, outDescriptionBio,(a, b, c) => true);

  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeOccupation => _occupationController.sink.add;
  Function(String) get changeDescriptionBio => _descriptionBioController.sink.add;


  StreamSubscription _streamSubscription;
  


  File image;
  String idUserLogIn;
  bool upImage = false;



  Future recoveryImage(String sourceImage) async {

    File selectImage;

    switch(sourceImage){
      case "camera":
        selectImage = await ImagePicker.pickImage(source: ImageSource.camera);
        image = selectImage;
        break;
      case "gallery":
        selectImage = await ImagePicker.pickImage(source: ImageSource.gallery);
        image = selectImage;

        break;
    }
  }
  ProfileBloc(){
    _streamSubscription = FirebaseAuth.instance.onAuthStateChanged.listen((user) async {
      if(image != null){
        if(await upImage == true){
          _stateController.add(ProfileState.SUCCESS);
        } else {
          _stateController.add(ProfileState.FAIL);
        }
      } else {
        _stateController.add(ProfileState.IDLE);
      }
    });
  }


  Future uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference rootFolder = storage.ref();
    StorageReference file = rootFolder
    .child("profileImages")
    .child(idUserLogIn + ".jpg");

    StorageUploadTask task = file.putFile(image);

    task.events.listen((StorageTaskEvent storageEvent){

      if(storageEvent.type == StorageTaskEventType.progress){
        _stateController.add(ProfileState.LOADING);

      }else if(storageEvent.type == StorageTaskEventType.success){
        _stateController.add(ProfileState.SUCCESS);

      }

    });
  }

  recoveryDataUser() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser userLogIn = await auth.currentUser();
    idUserLogIn = userLogIn.uid;

  }

  Future<bool> verifyPrivileges(FirebaseUser user) async {
    return await Firestore.instance.collection("users").document(user.uid).get().then((doc){
      if(doc.data != null){
        return true;
      } else {
        return false;
      }
    }).catchError((e){
      return false;
    });
  }

  @override
  void dispose() {

    _nameController.close();
    _occupationController.close();
    _descriptionBioController.close();
    _stateController.close();

    _streamSubscription.cancel();

  }



}