import 'package:flutter/material.dart';
import 'package:meal_plan_app/src/imports/imports_widgets.dart';
import 'package:meal_plan_app/src/imports/imports_backend.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String peso = '0';
  String altura = '0';
  String imc = '0';
  String hidratacao = '0';
  String calorias = '0';
  String proteinas = '0';
  String carboidratos = '0';
  String gorduras = '0';
  String refeicoes = '0';
  bool formCompleted = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
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
        peso = data['peso'].toString();
        altura = data['altura'].toString();
        imc = data['imc'].toStringAsFixed(1);
        calorias = data['daily_needs']['calorias'].toString();
        proteinas = data['daily_needs']['proteinas'].toString();
        carboidratos = data['daily_needs']['carboidratos'].toString();
        gorduras = data['daily_needs']['gorduras'].toString();
        refeicoes = data['daily_needs']['refeicoes'].toString();
        hidratacao = data['hidratacao'].toString();
        formCompleted = true;
        loading = false;
      });
    } else {
      setState(() {
        formCompleted = false;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : formCompleted
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const HomePageTitles(title: 'Daily Targets'),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CalorieCard(
                              title: 'Carbs',
                              value: carboidratos,
                              unit: 'kcal',
                              color: Colors.red,
                            ),
                            CalorieCard(
                              title: 'Protein',
                              value: proteinas,
                              unit: 'g',
                              color: Colors.green,
                            ),
                            CalorieCard(
                              title: 'Fat',
                              value: gorduras,
                              unit: 'g',
                              color: const Color.fromARGB(251, 161, 147, 13),
                            ),
                            CalorieCard(
                              title: 'Total',
                              value: calorias,
                              unit: 'Kcal',
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        WaterIntakeCard(
                          intake: '$hidratacao ml',
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Body measurement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        BodyMeasurementCard(
                          weightValue: '$peso kg',
                          height: '$altura cm',
                          bmi: '$imc BMI',
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Next meal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const MealCard(
                          mealType: 'Breakfast',
                          description: 'Bread, Peanut butter, Apple',
                        ),
                      ],
                    ),
                  ),
                )
              : IntermediateMessage(
                  message: 'Você ainda não preencheu suas informações',
                  onButtonPressed: () {
                    Navigator.pushNamed(context, '/forms');
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ação ao clicar no botão flutuante
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
