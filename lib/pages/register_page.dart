import 'package:flutter/material.dart';
import 'package:social_app/components/button.dart';
import 'package:social_app/components/text_field.dart';
import 'package:social_app/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //get auth service
  final AuthService _authService = AuthService();

  // Text Editing Controllers
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _confirmTextController = TextEditingController();

  //sign user up
  void signUp() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    //check passwords match
    if (_passwordTextController.text != _confirmTextController.text) {
      //pop loading circle
      Navigator.pop(context);

      //display error message
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords don't match!"),
        ),
      );

      return;
    }

    //try sign user up
    try {
      await _authService.signUpWithEmailPassword(
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
                  'Sign-Up',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 50),

                //message
                Text(
                  "Lets create an account for you!",
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

                //confirm password text field
                MyTextField(
                  controller: _confirmTextController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //sign up button
                MyButton(
                  onTap: signUp,
                  text: "Sign Up",
                ),

                const SizedBox(height: 25),

                //go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login now",
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
