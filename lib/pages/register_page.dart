import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/customFunctions/validator_functions.dart';
import 'package:mnnit/firebase/firebase_auth.dart';
import 'package:mnnit/pages/login_page.dart';
import 'package:mnnit/widgets/custom_textformfield.dart';
import 'package:mnnit/widgets/toggle_theme_button.dart';

class RegisterPage extends StatelessWidget {
  String selectedGender = 'Select Gender';
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
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
            key: _registerFormKey,
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
                  CustomPasswordField(
                    labelText: 'Create Password',
                    controller: password,
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: 6,),
                  Text('*The Password must contain atleast 8 characters.\n'
                      '*The Password must contain atleast one Uppercase alphabet.\n'
                      '*The Password must contain atleast one Lowercase alphabet.\n'
                      '*The Password must contain atleast one Special character.\n'
                      '*The Password must contain atleast one number.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_registerFormKey.currentState!.validate()) {
                        // Handle sign up
                        auth.register(
                          context: context,
                          email: email.text.trim(),
                          password: password.text.trim(),
                          name: name.text.trim(),
                          gender: selectedGender,
                        ).then((value) async {
                          verifyEmail(context, value);
                        });
                      }
                    },
                    child: const Text('Register'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
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

  void verifyEmail(BuildContext context, UserCredential value) async {
    // Send the verification email initially
    await value.user!.sendEmailVerification();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Please verify your email.'),
          content: const Text('Please verify your account by clicking the verification link sent to your gmail. After verifying, try to login with your credentials.'),
          actions: [
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Go to Login'),
            ),
          ],
        );
      },
    );
  }
}
