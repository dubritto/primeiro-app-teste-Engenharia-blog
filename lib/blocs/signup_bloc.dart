import 'dart:async';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:clube_da_obra/validator/signup_validator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SignUpState { IDLE, LOADING, SUCCESS, FAIL }

class SignUpBloc extends BlocBase with SignUpValidators {

  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _occupationController = BehaviorSubject<String>();
  final _nameController = BehaviorSubject<String>();
  final _descriptionBioController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<SignUpState>();

  Stream<String> get outEmail =>
      _emailController.stream.transform(validateEmail);
  Stream<String> get outPassword =>
      _passwordController.stream.transform(validatePassword);
  Stream<String> get outOccupation =>
      _occupationController.stream.transform(validateOccupation);
  Stream<String> get outName =>
      _nameController.stream.transform(validateName);
  Stream<String> get outDescriptionBio =>
      _descriptionBioController.stream.transform(validateDescriptionBio);

  Stream<SignUpState> get outState => _stateController.stream;

  Stream<bool> get outSubmitValid =>
      Observable.combineLatest5(outEmail, outPassword, outName, outOccupation, outDescriptionBio,(a, b, c, d, e) => true);

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeOccupation => _occupationController.sink.add;
  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeDescriptionBio => _descriptionBioController.sink.add;

  StreamSubscription _streamSubscription;

  SignUpBloc() {
    _streamSubscription =
        FirebaseAuth.instance.onAuthStateChanged.listen((user) async {
      if (user != null) {
        if (await verifyEmailBase(user)) {
          _stateController.add(SignUpState.SUCCESS);
        } else {
          FirebaseAuth.instance.signOut();
          _stateController.add(SignUpState.FAIL);
        }
      } else {
        _stateController.add(SignUpState.IDLE);
      }
    });
  }

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "email": _emailController.value,
      "name": _nameController.value,
      "occupation": _occupationController.value,
      "descriptionBio": _descriptionBioController.value,

    };

    return map;

  }

  void registerUser(){

    _stateController.add(SignUpState.LOADING);

    FirebaseAuth auth = FirebaseAuth.instance;
    Firestore db = Firestore.instance;
    auth.createUserWithEmailAndPassword(
        email: _emailController.value,
        password: _passwordController.value).then((firebaseUser){

      db.collection("users")
          .document(firebaseUser.user.uid)
          .setData(toMap());

    }).catchError((e){
      _stateController.add(SignUpState.FAIL);
    });

  }

  Future<bool> verifyEmailBase(FirebaseUser user) async {
    return await Firestore.instance.collection("users").document("email").get().then((doc){
      if(doc.data == null){
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
    _emailController.close();
    _passwordController.close();
    _nameController.close();
    _occupationController.close();
    _stateController.close();

    _streamSubscription.cancel();
  }
}
