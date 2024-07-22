import 'package:flutter/material.dart';
import 'package:meal_plan_app/src/imports/imports_widgets.dart';
import 'package:meal_plan_app/src/imports/imports_backend.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'As senhas não são iguais';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', data['token']);

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return CustomMessageDialog(
            title: '🎉 Bem-vindo!',
            message:
                'Que bom ter você conosco! Precisamos de algumas informações para continuar...',
            buttonText: 'Preencher Informações',
            onButtonPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/forms');
            },
          );
        },
      );
    } else if (response.statusCode == 400 || response.statusCode == 400) {
      setState(() {
        _errorMessage = jsonDecode(response.body)['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const PageTitle(
                      mainTitle: 'Nutri App',
                      subtitle: 'Cadastre-se para continuar'),
                  const SizedBox(height: 40),
                  CustomForm(
                    controllers: [
                      _nameController,
                      _emailController,
                      _passwordController,
                      _confirmPasswordController
                    ],
                    labels: const ['Nome', 'Email', 'Senha', 'Confirmar Senha'],
                    buttonText: 'Cadastrar',
                    onButtonPressed: _register,
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: const Text(
                      'Já possui uma conta? Entrar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
