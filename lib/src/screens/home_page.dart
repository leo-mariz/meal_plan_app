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
  List<Map<String, String>> mealPlan = [];
  int editCount = 0;
  bool showMessageDialog = false;

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
      print(data);
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
        editCount = data['editCount'];
        formCompleted = true;
        loading = false;
        Map<String, dynamic> mealPlanData =
            Map<String, dynamic>.from(data['meal_plan']);
        mealPlan = mealPlanData.entries
            .map((entry) => Map<String, String>.from(entry.value))
            .toList();
      });
    } else if (response.statusCode == 404) {
      setState(() {
        formCompleted = false;
        loading = false;
      });
    } else {
      formCompleted = true;
      print('Erro');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    // Navegar para a página de login
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _editMeal(int mealIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    print(mealIndex);

    // Aqui você pode querer passar outras informações, como as informações do usuário e da refeição atual.
    final response = await http.post(
      Uri.parse('$baseUrl/edit_meal'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'mealIndex': mealIndex}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        final updatedMeal = Map<String, String>.from(data['updatedMeal']);
        mealPlan[mealIndex] = updatedMeal;
        editCount = data['editCount'];
      });
    } 
    if (response.statusCode == 403) {
    setState(() {
      showMessageDialog = true;
    });}
    print('Failed to edit meal');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Perfil'),
              onTap: () {
                // Ação para navegar para o perfil
              },
            ),
            ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _logout),
          ],
        ),
      ),
      body: Stack(
        children: [
          loading
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
                            Text(
                              'Generate new meal: $editCount/3',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...mealPlan.map((meal) {
                              return MealCard(
                                mealType: meal.keys.first,
                                description: meal.values.first.split('\n'),
                                onEdit: () {
                                  if (editCount < 3) {
                                    _editMeal(mealPlan.indexOf(meal));
                                  } else {
                                    setState(() {
                                      showMessageDialog = true;
                                    });
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    )
                  : CustomMessageDialog(
                      title: 'Informações incompletas',
                      message: 'Preencha suas informações para continuar',
                      buttonText: 'Preencher',
                      onButtonPressed: () {
                        Navigator.pushNamed(context, '/forms');
                      },
                    ),
          if (showMessageDialog)
            CustomMessageDialog(
              title: 'Limite de Edições Alcançado',
              message: 'Você atingiu o limite de 3 edições permitidas.',
              buttonText: 'Fechar',
              onButtonPressed: () {
                setState(() {
                  showMessageDialog = false;
                });
              },
            ),
        ]),
       );
  }
}

      