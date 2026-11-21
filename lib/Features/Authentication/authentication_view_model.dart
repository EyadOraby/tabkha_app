// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tabkha_app/Features/Authentication/Views/login_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/onboarding_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/splash_view.dart';
import 'package:tabkha_app/Models/user_model.dart';
import 'package:tabkha_app/Services/navigation_services.dart';
import 'package:tabkha_app/common/flash_widgets.dart';
import 'package:tabkha_app/constants/app_collection_references.dart';
import 'package:tabkha_app/constants/app_status_enum.dart';

class AuthenticationViewModel with ChangeNotifier {
  User? userCredential;
  UserData? userData;
  FirebaseFirestore? _instance;
  Status status = Status.success;

  Future<void> signUp(String email, String password, String fullName,
      String userName, BuildContext context) async {
    try {
      status = Status.loading;
      notifyListeners();
      FirebaseAuth.instance.setLanguageCode('en');

      UserCredential? credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null && credential.user!.uid != "") {
        // Set user data after sign up
        userCredential = credential.user;
        _instance = FirebaseFirestore.instance;
        await _instance!
            .collection(AppCollectionReferences.users)
            .doc(credential.user!.uid)
            .set({
          "full_name": fullName,
          "user_name": userName,
          "email": email,
          "role": "user",
        });
        // Get User data to use during the app
        getUserData(credential.user!.uid);
        status = Status.success;
        notifyListeners();
      } else {
        status = Status.failed;
        notifyListeners();
      }
      NavigationsServices.pushReplacementNamed(context, LoginView.routeName);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        FlashWidgets.showErrorBar(context: context, message: "Weak password");
      } else if (e.code == 'email-already-in-use') {
        FlashWidgets.showErrorBar(
            context: context, message: "E-mail is already in use");
      }
      status = Status.failed;
      notifyListeners();
    } catch (e) {
      FlashWidgets.showErrorBar(
          context: context, message: "Something went wrong");
      status = Status.failed;
      notifyListeners();
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      status = Status.loading;
      notifyListeners();
      UserCredential? credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null && credential.user!.uid != "") {
        userCredential = credential.user;
        getUserData(credential.user!.uid);
        status = Status.success;
        notifyListeners();
        NavigationsServices.pushReplacementNamed(
            context, OnboardingView.routeName);
      } else {
        status = Status.failed;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        FlashWidgets.showErrorBar(context: context, message: "User not found");
        status = Status.failed;
        notifyListeners();
      } else if (e.code == 'wrong-password') {
        FlashWidgets.showErrorBar(context: context, message: "Wrong password");
        status = Status.failed;
        notifyListeners();
      }
      status = Status.failed;
      notifyListeners();
    } catch (e) {
      FlashWidgets.showErrorBar(
          context: context, message: "Something went wrong");
      status = Status.failed;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      status = Status.loading;
      notifyListeners();
      userCredential = null;
      userData = null;
      await FirebaseAuth.instance.signOut();
      status = Status.success;
      notifyListeners();
      NavigationsServices.pushReplacementNamed(context, SplashView.routeName);
    } catch (e) {
      status = Status.failed;
      notifyListeners();
      // FlashWidgets.showErrorBar(
      //     context: context, message: "Something went wrong");
    }
  }

  Future<void> getUserData(String userID) async {
    status = Status.loading;
    notifyListeners();
    _instance = FirebaseFirestore.instance;

    var results = await _instance!
        .collection(AppCollectionReferences.users)
        .doc(userID)
        .get();
    var results2 = results.data();
    userData = UserData.fromJson(results2!, userID);
    status = Status.success;
    notifyListeners();
  }

  Future<void> changePassword(String newPassword, BuildContext context) async {
    status = Status.loading;
    notifyListeners();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User currentUser = firebaseAuth.currentUser!;
    currentUser.updatePassword(newPassword).then((_) {
      status = Status.success;
      notifyListeners();
      FlashWidgets.showSuccessBar(
          context: context, message: "Password changed successfully!");
      Navigator.of(context).pop();
    }).catchError((err) {
      FlashWidgets.showErrorBar(
          context: context, message: "Something went wrong");
      status = Status.failed;
      notifyListeners();
    });
  }

  Future<void> changePhoneNumber(
      String newPhoneNumber, BuildContext context) async {
    try {
      status = Status.loading;
      notifyListeners();
      _instance = FirebaseFirestore.instance;
      await _instance!
          .collection(AppCollectionReferences.users)
          .doc(userCredential!.uid)
          .update({
        "phone_number": newPhoneNumber,
      });
      getUserData(userCredential!.uid);
      FlashWidgets.showSuccessBar(
          context: context, message: "Phone number changed successfully!");
      status = Status.success;
      notifyListeners();
      Navigator.of(context).pop();
    } catch (error) {
      FlashWidgets.showErrorBar(
          context: context, message: "Something went wrong");
      status = Status.failed;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      status = Status.loading;
      notifyListeners();
      _instance = FirebaseFirestore.instance;
      await _instance!
          .collection(AppCollectionReferences.users)
          .doc(userCredential!.uid)
          .update({
        "deleted": true,
      });
      status = Status.success;
      notifyListeners();
      logout(context);
    } catch (error) {
      status = Status.failed;
      notifyListeners();
      FlashWidgets.showErrorBar(
          context: context, message: "Something went wrong");
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    status = Status.loading;
    notifyListeners();
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((value) {
      status = Status.success;
      notifyListeners();
      FlashWidgets.showSuccessBar(
          context: context,
          message: "Reset password request sent successfully!");
      Navigator.of(context).pop();
    }).catchError((e) {
      status = Status.failed;
      notifyListeners();
      FlashWidgets.showErrorBar(
          context: context, message: "Something went wrong");
    });
  }
}
