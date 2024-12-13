import 'package:flutter/material.dart';
import 'package:social_app/components/button.dart';
import 'package:social_app/components/text_field.dart';
import 'package:social_app/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //get auth service
  final AuthService _authService = AuthService();

  // Text Editing Controllers
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  //sign user in
  void signIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    //try sign in
    try {
      await _authService.signInWithEmailPassword(
        _emailTextController.text,
        _passwordTextController.text,
      );

      //pop loading circle
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      //pop loading circle
      Navigator.pop(context);

      //display error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 50),

                //title
                const Text(
                  'Log-In',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 50),

                //message
                Text(
                  "Welcome back, you've been missed!",
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 25),

                //email text field
                MyTextField(
                  controller: _emailTextController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //password text field
                MyTextField(
                  controller: _passwordTextController,
                  hintText: "Password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //sign in button
                MyButton(
                  onTap: signIn,
                  text: "Sign In",
                ),

                const SizedBox(height: 25),

                //go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
