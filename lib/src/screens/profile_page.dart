import 'package:flutter/material.dart';
import 'package:meal_plan_app/src/imports/imports_widgets.dart';
import 'package:meal_plan_app/src/imports/imports_backend.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController sexoController = TextEditingController();
  // Adicione controladores para todos os campos necessários

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    final response = await http.get(
      Uri.parse('$baseUrl/user_info'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        pesoController.text = data['peso'].toString();
        alturaController.text = data['altura'].toString();
        idadeController.text = data['idade'].toString();
        sexoController.text = data['sexo'].toString();
        // Carregue todos os campos necessários
      });
    } else {
      // Trate o erro
    }
  }

  Future<void> _saveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    final response = await http.post(
      Uri.parse('$baseUrl/update_user_info'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'peso': pesoController.text,
        'altura': alturaController.text,
        'idade': idadeController.text,
        'sexo': sexoController.text,
        // Envie todos os campos necessários
      }),
    );

    if (response.statusCode == 200) {
      // Sucesso
    } else {
      // Trate o erro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: pesoController,
              decoration: InputDecoration(labelText: 'Peso'),
            ),
            TextField(
              controller: alturaController,
              decoration: InputDecoration(labelText: 'Altura'),
            ),
            TextField(
              controller: idadeController,
              decoration: InputDecoration(labelText: 'Idade'),
            ),
            TextField(
              controller: sexoController,
              decoration: InputDecoration(labelText: 'Sexo'),
            ),
            // Adicione todos os campos necessários
            ElevatedButton(
              onPressed: _saveUserInfo,
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}