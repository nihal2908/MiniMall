import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/firebase/firebase_auth.dart';
import 'package:mnnit/firebase/user_manager.dart';
import 'package:mnnit/pages/landing_page.dart';
import 'package:mnnit/pages/register_page.dart';
import 'package:mnnit/widgets/custom_textformfield.dart';
import 'package:mnnit/widgets/toggle_theme_button.dart';
import 'package:mnnit/customFunctions/validator_functions.dart';

class LoginPage extends StatelessWidget {
  final Auth auth = Auth();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _LoginFormKey = GlobalKey<FormState>();

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
          key: _LoginFormKey,
          child: Column(
            children: <Widget>[
              CustomTextFormField(
                labelText: 'Email',
                controller: email,
                validator: emailValidator,
              ),
              SizedBox(height: 20,),
              CustomPasswordField(
                labelText: 'Password',
                controller: password,
                validator: passwordValidator,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if(_LoginFormKey.currentState!.validate()) {
                    await auth.login(
                        context: context,
                        email: email.text,
                        password: password.text
                    ).then((value) async {
                      if (value != null) {
                        await UserManager.initializeUserId();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LandingPage(initialPage: 0,),
                          ),
                        );
                      }
                    });
                  }
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
                  'Create Account',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}