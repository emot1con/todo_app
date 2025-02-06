import 'package:flutter/material.dart';
import 'package:flutter_todo_list/provider/auth/auth_provider.dart';
import 'package:flutter_todo_list/screen/auth/login_screen.dart';
import 'package:flutter_todo_list/widgets/text_input_widget.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign-Up', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              spacing: 20,
              children: [
                Form(
                  key: value.formKeyRegister,
                  child: Column(
                    spacing: 20,
                    children: [
                      TextForm(
                        label: 'Name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          setState(() {
                            value.registerName = name;
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextForm(
                        label: 'Email',
                        icon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onSaved: (email) {
                          setState(() {
                            value.registerEmail = email;
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextForm(
                        label: 'Password',
                        icon: Icons.lock,
                        onSaved: (password) {
                          setState(() {
                            value.registerPassword = password;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (value.formKeyRegister.currentState!
                                .validate()) {
                              value.formKeyRegister.currentState!.save();
                              value.registerUser(
                                  value.registerName,
                                  value.registerEmail,
                                  value.registerPassword,
                                  context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: const Text(
                            'Sign-Up',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
