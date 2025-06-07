import 'package:flutter/material.dart';
import 'package:testing/auth/auth_services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  // Get auth service 
  final authServices = AuthServices();

  // Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // sign up button pressed
  void signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // check that password match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return ;
    }

    // attempt sign up ...
    try {
      await authServices.signUpWithEmailPassword(email, password);

      //pop this register
      Navigator.pop(context);
    }
    catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [
          //email
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
            ),
          ),

          //pasword
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: "Password",
            ),
            obscureText: true,
          ),

          // confirm pasword
          TextField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(
              labelText: "Confirm Password",
            ),
            obscureText: true,
          ),

          const SizedBox(height: 12),
          // button 

          ElevatedButton(
            onPressed: signUp, 
            child: const Text("Sign Up"),
          ),
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}