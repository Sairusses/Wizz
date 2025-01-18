import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wizz/custom_widgets/custom_text_form_field.dart';
import 'package:wizz/services/auth_service.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatelessWidget{
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginScreenState();
  }
}
class LoginScreenState extends StatelessWidget{
  LoginScreenState({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    emailController.text = 'abc@abc.abc';
    passwordController.text = 'abc@abc.abc';
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 50,),
                Header(),
                SizedBox(height: 30),
                CustomTextFormField(
                  controller: emailController,
                  labelText: "Email",
                  hint: "Enter your email",
                  prefixIcon: Icon(Icons.email, color: Colors.black,),
                ),
                SizedBox(height: 20),
                CustomTextFormField(
                  controller: passwordController,
                  labelText: "Password",
                  hint: "Enter your password",
                  prefixIcon: Icon(Icons.lock, color: Colors.black,),
                  isPassword: true,
                ),
                SizedBox(height: 5),
                ForgotPasswordButton(),
                SizedBox(height: 5,),
                LoginButton(emailController: emailController, passwordController: passwordController),
                SizedBox(height: 20,),
                ContinueWithDivider(),
                SizedBox(height: 20,),
                SocialButtons(),
                SignUpTextButton()
              ],
        
            ),
          ),
      ),
    );
  }
}

class SignUpTextButton extends StatelessWidget{
  const SignUpTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Don't have an acount?",
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Inter',
            color: Colors.black54
          ),
        ),
        TextButton(
            onPressed: () {
              Future.delayed(Duration(milliseconds: 150), () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              });
            },
            child: Text(
              "Sign Up",
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Inter',
                  color: Colors.black
              ),
            ),
        )
      ],
    );
  }

}

class LoginButton extends StatelessWidget{
  final TextEditingController emailController;
  final TextEditingController passwordController;
  const LoginButton({super.key, required this.emailController, required this.passwordController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: ElevatedButton(
          onPressed: () async{
            await AuthService().login(email: emailController.text, password: passwordController.text, context: context);
            },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              )
          ),
        child: Text('Log in'),
      ),
  );
  }

}

class ForgotPasswordButton extends StatelessWidget{
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: TextButton(onPressed: (){
            //CODE LOGIC HERE
          },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    color: Colors.grey[900]
                ),
              )
          ),
        )
      ],
    );
  }

}

class Header extends StatelessWidget{
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: SizedBox(
            height: 40,
            width: 40,
            child: Image(
              image: AssetImage('assets/wizz_icon.png'),
              fit: BoxFit.fill
            ),
          ),
        ),
        SizedBox(height: 35,),
        Center(
          child: Text('Welcome to Wizz',
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 24, fontFamily: 'Inter', color: Colors.black
          ),
          ),
        ),
        SizedBox(height: 15),
        Center(
            child: Text('Simplify Project Management with AI',
                style: TextStyle(
                    fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.normal, color:  Colors.black
                )
            )
        ),
      ],
    );
  }

}

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {

            },

            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            child: Image.asset(
              'assets/google.png',
              height: 24,
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () {

            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            child: Image.asset(
              'assets/facebook.png',
              height: 24,
            ),
          ),
        ),
      ],
    );
  }
}

class ContinueWithDivider extends StatelessWidget {
  const ContinueWithDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[500], // Line color
            thickness: .5,       // Line thickness
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10), // Space around text
          child: Text(
            "Or continue with",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[500], // Line color
            thickness: .5,       // Line thickness
          ),
        ),
      ],
    );
  }
}
