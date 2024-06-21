import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/firebase/firebase_auth.dart';
import 'package:mnnit/pages/home_page.dart';
import 'package:mnnit/pages/landing_page.dart';
import 'package:mnnit/widgets/toggle_theme_button.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: const [
          ToggleThemeButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(labelText: 'Email'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(),
                  ),
                );
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  String selectedGender = 'Select Gender';
  final GlobalKey _formKey = GlobalKey();
  final Auth auth = Auth();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: const [
          ToggleThemeButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: InputBorder.none,
                ),
                controller: name,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  } else if (value.contains(RegExp(r'[!-?]'))) {
                    return 'Name cannot contain special characters';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: InputBorder.none,
                ),
                controller: email,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  } else if (!value.contains('@gmail.com')) {
                    return 'Enter a valid Email';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              StatefulBuilder(
                builder: (context, genderState) {
                  return DropdownButtonFormField<String>(
                    value: selectedGender,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    // decoration: InputDecoration(
                    //   labelText: 'Gender',
                    //   icon: const Icon(Icons.people),
                    //   floatingLabelAlignment: FloatingLabelAlignment.center,
                    //   border: OutlineInputBorder(
                    //     borderSide: const BorderSide(),
                    //     borderRadius: BorderRadius.circular(15),
                    //   ),
                    // ),
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
                      if (value == null || value.isEmpty || value == 'Select') {
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                controller: password,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle sign up
                  auth.register(
                    email: email.text.trim(),
                    password: password.text.trim(),
                    name: name.text.trim(),
                    gender: selectedGender,
                  ).then((value) => Navigator.push(context, MaterialPageRoute(builder: (context)=>LandingPage())))
                    //   .then(
                    // (value) {
                    //   verify(value, context);
                    // },
                  // );
                ;},
                child: const Text('Sign Up'),
              ),
              TextButton(
                  onPressed: () {}, child: const Text('send login emial'))
            ],
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
