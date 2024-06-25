import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/customFunctions/validator_functions.dart';
import 'package:mnnit/firebase/firebase_auth.dart';
import 'package:mnnit/firebase/user_manager.dart';
import 'package:mnnit/pages/landing_page.dart';
import 'package:mnnit/pages/login_page.dart';
import 'package:mnnit/widgets/custom_textformfield.dart';
import 'package:mnnit/widgets/toggle_theme_button.dart';

class RegisterPage extends StatelessWidget {
  String selectedGender = 'Select Gender';
  final GlobalKey _RegisterFormKey = GlobalKey();
  final Auth auth = Auth();
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        actions: const [
          ToggleThemeButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _RegisterFormKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomTextFormField(
                    controller: name,
                    labelText: 'Name',
                    validator: nameValidator,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                    labelText: 'Email',
                    controller: email,
                    validator: emailValidator,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StatefulBuilder(
                    builder: (context, genderState) {
                      return DropdownButtonFormField<String>(
                        value: selectedGender,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        items: ['Select Gender', 'Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                            .toList(),
                        onChanged: (value) {
                          genderState(
                                () {
                              selectedGender = value!;
                            },
                          );
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty || value == 'Select Gender') {
                            return 'Required';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                    labelText: 'Password',
                    controller: password,
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Handle sign up
                      auth.register(
                        context: context,
                        email: email.text.trim(),
                        password: password.text.trim(),
                        name: name.text.trim(),
                        gender: selectedGender,
                      ).then((value) async {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>LandingPage(initialPage: 0,)));
                        await UserManager.initializeUserId();
                      });
                      //   .then(
                      // (value) {
                      //   verify(value, context);
                      // },
                      // );
                    },
                    child: const Text('Register'),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                      },
                      child: const Text('Login', style: TextStyle(color: Colors.white),
                      ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void verify(UserCredential value, BuildContext context) async {
    // Send the verification email initially
    value.user!.sendEmailVerification();

    int timeleft = 30;
    bool isVerified = false;

    Timer? countdownTimer;
    Timer? verificationTimer;

    void startCountdown(Function setState) {
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timeleft > 0) {
          setState(() {
            timeleft--;
          });
        } else {
          timer.cancel();
        }
      });
    }

    void startVerificationCheck(Function setState) {
      verificationTimer =
          Timer.periodic(const Duration(seconds: 5), (timer) async {
            // await value.user!.reload();
            if (value.user!.emailVerified) {
              setState(() {
                isVerified = true;
              });
              timer.cancel();
              countdownTimer?.cancel(); // Cancel the countdown timer if running
              Navigator.of(context).pop(); // Close the dialog when verified
            }
          });
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (countdownTimer == null) {
              startCountdown(setState);
            }

            if (verificationTimer == null) {
              startVerificationCheck(setState);
            }

            return AlertDialog(
              title: const Text('Please verify your email.'),
              content: const Text(
                  'A verification link is sent to your email. Please verify it\'s you.'),
              actions: [
                Column(
                  children: [
                    MaterialButton(
                      onPressed: timeleft > 0
                          ? null
                          : () {
                        value.user!.sendEmailVerification();
                        setState(() {
                          timeleft = 30;
                        });
                        startCountdown(setState);
                      },
                      child: const Text('Resend Link'),
                    ),
                    Text(timeleft > 0 ? 'Wait for $timeleft seconds' : ''),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
