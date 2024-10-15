import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'HomePage.dart'; // Ensure this matches your app's home page path

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrol-GPS'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          '“To Protect, and to Serve.”',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Image.asset(
                          'assets/images/NationalAmbelem.jpeg',
                          height: 150,
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                String email = _usernameController.text;
                                String password =
                                    _passwordController.text;

                                // Call Firebase login method
                                _loginWithEmailAndPassword(email, password);
                              }
                            },
                            child: _isLoading
                                ? const CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                                : Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: <Color>[
                                    Color(0xFFFF9933), // Saffron
                                    Color(0xFFFFFFFF), // White
                                    Color(0xFF138808), // Green
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.0, 0.5, 1.0],
                                ),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 40,
                                  minHeight: 40,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Color(0xFF000080), // Blue
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Patrol-GPS helps ensure the safety of your community by enabling easy monitoring and tracking.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white12,
              padding: const EdgeInsets.symmetric(vertical: 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      // Handle privacy policy
                    },
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(color: Colors.black, fontSize: 12.0),
                    ),
                  ),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.black, fontSize: 10.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginWithEmailAndPassword(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to HomePage on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle authentication errors
      String message = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
