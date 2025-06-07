import 'package:flutter/material.dart';
import 'package:testing/auth/auth_services.dart';
import 'package:testing/views/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Get auth service 
  final authServices = AuthServices();

  // Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void login() async{
    //prepare data

    final email = _emailController.text;
    final password = _passwordController.text;

    // attempt login ...
    try {
      await authServices.signInWithEmailPassword(email, password);
    }
    catch(e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
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

          const SizedBox(height: 12),
          // button 

          ElevatedButton(
            onPressed: login, 
            child: const Text("Login"),
          ),
          
          const SizedBox(height: 12),
          // go to register page to sign up
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return RegisterPage();
                  },
                ),
              );
            },
            child: Center(
              child: Text("Don't have an account? Sign up"),
            ),
          ),
        ],
      ),
    );
  }
}