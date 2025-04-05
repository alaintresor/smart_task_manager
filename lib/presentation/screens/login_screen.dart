import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Smart Tasks',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 10),

                Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 10),

                // Title text
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Sign in to access your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),

                // Email field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.grey[600],
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.grey[600],
                    ),
                    suffixIcon: Icon(
                      Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/task');
                  },
                  child: const Text('Log In', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 16),

                // Divider with text
                Row(
                  children: [
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey[400]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Google sign in button
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.network(
                    'https://image.similarpng.com/file/similarpng/very-thumbnail/2020/06/Logo-google-icon-PNG.png',
                    height: 24,
                    width: 24,
                  ),
                  label: Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Link to signup page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
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
