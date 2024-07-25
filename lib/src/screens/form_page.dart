import 'package:flutter/material.dart';
import 'package:plano_alimentar_ai/src/imports/imports_widgets.dart';
import 'package:plano_alimentar_ai/src/imports/imports_backend.dart';
import 'package:http/http.dart' as http;

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  FormPageState createState() => FormPageState();
}

class FormPageState extends State<FormPage> {
  int _currentStep = 0;

  // final ScrollController scrollController = ScrollController();

  final List<Map<String, List<dynamic>>> _labels = [
    {
      'Peso (kg)': ['text', []],
      'Altura (cm)': ['text', []],
      'Idade': ['text', []],
      'Sexo': [
        'dropdown',
        ['Masculino', 'Feminino']
      ],
    },
    {
      'Você pratica algum dos exercícios abaixo?': [
        'checkbox',
        ['Musculação', 'Corrida', 'Natação', 'Ciclismo', 'Outro']
      ],
      'Qual a sua frequência de exercícios (dias/semana)?': [
        'radio',
        ['1 a 2', '3 a 4', '5 a 7', 'Não pratico exercícios']
      ],
      'Qual a duração de exercícios (min/dia)?': [
        'radio',
        [
          'Menos de 30',
          '30 a 60',
          '60 a 90',
          'Mais de 90',
          'Não pratico exercícios'
        ]
      ],
      'Qual o seu biotipo?': [
        'radio',
        ['Ectomorfo', 'Mesomorfo', 'Endomorfo']
      ],
      'Qual a sua meta?': [
        'radio',
        [
          'Ganho de massa muscular',
          'Perda de peso',
          'Manutenção de peso',
          'Saúde'
        ]
      ],
    },
    {
      'Você possui alguma das condições abaixo?': [
        'checkbox',
        [
          'Diabetes',
          'Doença Celíaca',
          'Intolerância a lactose',
          'Outra',
          'Não possuo nenhuma condição'
        ]
      ],
      'Você pratica alguma dieta?': [
        'checkbox',
        ['Cetogênica', 'Vegana', 'Vegetariana', 'Outra', 'Não']
      ],
      'Qual a frequência de consumo (dias na semana) de legumes?': [
        'radio',
        ['0', '1 a 2', '3 a 4', '5 a 6', 'Todos os dias']
      ],
      'Qual a frequência de consumo (dias na semana) de frutas?': [
        'radio',
        ['0', '1 a 2', '3 a 4', '5 a 6', 'Todos os dias']
      ],
      'Qual a frequência de consumo (dias na semana) de verduras?': [
        'radio',
        ['0', '1 a 2', '3 a 4', '5 a 6', 'Todos os dias']
      ],
      'Qual a frequência de consumo (dias na semana) de carnes?': [
        'radio',
        ['0', '1 a 2', '3 a 4', '5 a 6', 'Todos os dias']
      ],
      'Que alimentos você não estaria disposto a incluir na sua dieta?': [
        'checkbox',
        [
          'Legumes',
          'Frutas',
          'Verduras',
          'Carnes',
          'Podem ser incluídos todos os alimentos'
        ]
      ],
    },
    {
      'Você faz consumo de suplementos?': [
        'checkbox',
        [
          'Whey Protein',
          'Creatina',
          'BCAA',
          'Outro',
          'Não faço uso de suplementos'
        ]
      ],
      'Caso recomendado, você faria uso de suplementos?': [
        'checkbox',
        ['Sim', 'Não']
      ],
    },
    // {
    //   'Você gostaria de adicionar as medidas do seu corpo para que possamos personalizar ainda mais seu plano nutricional?': [
    //     'checkbox', ['Sim', 'Adicionarei em outro momento']
    //   ],
    // },
    // {
    //   'Você gostaria de nos enviar suas informações de exames para que possamos personalizar ainda mais seu plano nutricional?': [
    //     'checkbox', ['Sim', 'Adicionarei em outro momento']
    //   ],
    // },
  ];

  final List<String> _topics = [
    'peso',
    'altura',
    'idade',
    'sexo',
    'exercicios',
    'frequencia_exercicios',
    'duracao_exercicios',
    'biotipo',
    'meta',
    'condicoes',
    'dieta',
    'frequencia_legumes',
    'frequencia_frutas',
    'frequencia_verduras',
    'frequencia_carnes',
    'alimentos_excluidos',
    'suplementos',
    'uso_suplementos',
    'medidas_corpo',
    'informacoes_exames'
  ];

  late final List<TextEditingController> _controllers = List.generate(
    _labels.expand((element) => element.keys).length,
    (index) => TextEditingController(),
  );

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _submitForm() async {
    showLoadingDialog(context);

    final Map<String, String> formData = {};
    for (var i = 0; i < _controllers.length; i++) {
      formData[_topics[i]] = _controllers[i].text;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    final response = await http.post(
      Uri.parse('$baseUrl/submit_form'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(formData),
    );
    
    hideLoadingDialog(context);

    if (response.statusCode == 201) {
      // Sucesso
      if (!mounted) return;
      Navigator.pushNamed(context, '/home');
    } else {
      // Falha no envio do formulário
      print('Falha ao enviar formulário');
    }
  }

  void _nextStep() {
    final startIndex = _labels
        .sublist(0, _currentStep)
        .fold(0, (sum, map) => sum + map.keys.length);
    final endIndex = startIndex + _labels[_currentStep].keys.length;
    final currentControllers = _controllers.sublist(startIndex, endIndex);

    bool allFilled =
        currentControllers.every((controller) => controller.text.isNotEmpty);

    if (allFilled) {
      if (_currentStep < _labels.length - 1) {
        setState(() {
          _currentStep++;
          // scrollController.jumpTo(0);
        });
      } else {
        _submitForm();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, preencha todas as informações antes de continuar.'),
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        // scrollController.jumpTo(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = _labels
        .sublist(0, _currentStep)
        .fold(0, (sum, map) => sum + map.keys.length);
    final endIndex = startIndex + _labels[_currentStep].keys.length;
    final currentControllers = _controllers.sublist(startIndex, endIndex);

    return Scaffold(
      body: AuthBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AppBar(
                title: const Text('Questionário Inicial',
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                // child: SingleChildScrollView(
                // controller: scrollController,
                child: MultipleChoiceForm(
                  controllers: currentControllers,
                  labels: _labels[_currentStep],
                  buttonText: 'Próximo',
                  onButtonPressed: _nextStep,
                  // ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    FormPageButton(
                      text: 'Voltar',
                      onPressed: _previousStep,
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    // _scrollController.dispose();
    super.dispose();
  }
}
