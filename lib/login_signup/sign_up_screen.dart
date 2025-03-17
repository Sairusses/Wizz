import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../custom_widgets/custom_text_form_field.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatelessWidget{
  SignUpScreen({super.key});
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 75,),
              SignUpHeader(),
              SizedBox(height: 30),
              CustomTextFormField(
                controller: usernameController,
                labelText: "Full Name",
                hint: "Enter your full name",
                prefixIcon: Icon(Icons.person, color: Colors.black,),
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              CustomTextFormField(
                controller: confirmPasswordController,
                labelText: "Confirm Password",
                hint: "Re-enter your password",
                prefixIcon: Icon(Icons.lock, color: Colors.black,),
                isPassword: true,
              ),
              SizedBox(height: 30,),
              SignUpButton(usernameController: usernameController, emailController: emailController, passwordController: passwordController, confirmPasswordController: confirmPasswordController,),
              SizedBox(height: 20),
              ContinueWithDivider(),
              SizedBox(height: 20),
              SocialButtons(),
              SignInTextButton()

            ],
          ),
        ),
      ),
    );
  }


}

class SignUpHeader extends StatelessWidget{
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: Image(
                image: AssetImage('assets/wizz_logo.png'),
                fit: BoxFit.fill
            ),
          ),
        ),
        Center(
            child: Text('Start managing projects with AI assistance',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.normal, color:  Colors.black
                ),
            ),
        ),
      ],
    );
  }

}

class SignInTextButton extends StatelessWidget{
  const SignInTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
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
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            });
          },
          child: Text(
            "Sign In",
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

class SignUpButton extends StatelessWidget{
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  const SignUpButton({super.key, required this.usernameController, required this.emailController, required this.passwordController, required this.confirmPasswordController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async{
          if(passwordController.text == confirmPasswordController.text){
            await AuthService().signup(username: usernameController.text, email: emailController.text, password: passwordController.text, context: context);
          }else{
            Fluttertoast.showToast(
                msg: 'Passwords do not match.',
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: Colors.grey,
                textColor: Colors.black54,
                fontSize: 14,
                gravity: ToastGravity.SNACKBAR
            );
          }
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            )
        ),
        child: Text('Sign Up'),
      ),
    );
  }
}