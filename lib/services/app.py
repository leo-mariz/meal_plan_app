from flask import Flask, request, jsonify
from flask_bcrypt import Bcrypt
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from flask_cors import CORS
import re
from openai import OpenAI
from dotenv import load_dotenv
import json

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///meuapp.db'
app.config['SECRET_KEY'] = 'uma_chave_secreta_bem_segura'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
jwt = JWTManager(app)
CORS(app)

load_dotenv()
client = OpenAI()


# FUNÇÕES AUXILIARES
def contem_numero(s):
    return bool(re.search(r'\d', s))


def generate_prompt(infos):
    prompt = f"""
    Você é um assistente de inteligência artificial e vai criar um plano alimentar personalizado para um usuário com base nas informações abaixo:

    - Peso: {infos['peso']} kg
    - Altura: {infos['altura']} cm
    - Idade: {infos['idade']} anos
    - Sexo: {infos['sexo']}
    - Exercícios: {infos['exercicios']}
    - Frequência: {infos['frequencia_exercicios']} dias/semana
    - Duração: {infos['duracao_exercicios']} min/dia
    - Biotipo: {infos['biotipo']}
    - Meta: {infos['meta']}
    - Condições de saúde: {infos['condicoes']}
    - Dieta atual: {infos['dieta']}
    - Frequência de legumes: {infos['frequencia_legumes']} dias/semana
    - Frequência de frutas: {infos['frequencia_frutas']} dias/semana
    - Frequência de verduras: {infos['frequencia_verduras']} dias/semana
    - Frequência de carnes: {infos['frequencia_carnes']} dias/semana
    - Alimentos excluídos: {infos['alimentos_excluidos']}
    - Suplementos: {infos['suplementos']}
    - Uso de suplementos: {infos['uso_suplementos']}

    Crie um plano alimentar diário detalhado e personalizado de acordo com as informações acima incluindo:
    1. Kcal, proteínas, carboidratos e gorduras por dia.
    2. Distribuição de macronutrientes e kcal por refeição.
    3. Preferências, restrições e objetivos.
    4. Sugestões de suplementação.

    Formato da resposta:
    **Necessidades diárias:**
        - Calorias totais por dia: kcal
        - Proteínas totais por dia: g
        - Carboidratos totais por dia: g
        - Gorduras totais por dia: g
        - Quantidade de refeições por dia: n

    **Plano Alimentar Personalizado:**
    - Refeição 1. Nome da refeição:
        - Quantidade. Alimento 1 ou suplemento 1. Kcal 1. Proteínas 1. Carboidratos 1. Gorduras 1.
        - Quantidade. Alimento 2 ou suplemento 2. Kcal 2. Proteínas 2. Carboidratos 2. Gorduras 2.
        - Quantidade. Alimento n ou suplemento n. Kcal n. Proteínas n. Carboidratos n. Gorduras n.
    - Refeição m. Nome da refeição:
        -...

    **Sugestões de Suplementação:** (caso haja)
    - ...

    **Observações:** (caso haja)
    - ...

    Calcule a quantidade de alimentos e suplementos com base nas necessidades e preferências do usuário. Não é necessário nos retornar novamente as informações do usuário já passadas, apenas o plano alimentar que será criado.
    """
    return prompt


def generate_meal_plan(infos):
    prompt = generate_prompt(infos)
    completion = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "Você é uma AI especializada em nutrição e será responsável por montar um plano alimentar personalizado para o nosso usuário, de acordo com as informações pessoais que ele nos enviou."},
            {"role": "user", "content": prompt}
        ],
        max_tokens=1500
    )

    meal_plan = completion.choices[0].message.content
    usage_tokens = completion.usage.completion_tokens
    prompt_tokens = completion.usage.prompt_tokens
    return meal_plan, usage_tokens, prompt_tokens


def extract_daily_needs(text):
    pattern = re.compile(
        r'- Calorias totais por dia: (\d+)\s*kcal\s*\n'
        r'\s*- Proteínas totais por dia: (\d+)\s*g\s*\n'
        r'\s*- Carboidratos totais por dia: (\d+)\s*g\s*\n'
        r'\s*- Gorduras totais por dia: (\d+)\s*g\s*\n'
        r'\s*- Quantidade de refeições por dia: (\d+)', re.MULTILINE)

    match = pattern.search(text)

    if match:
        return {
            'calorias': int(match.group(1)),
            'proteinas': int(match.group(2)),
            'carboidratos': int(match.group(3)),
            'gorduras': int(match.group(4)),
            'refeicoes': int(match.group(5))
        }
    return None


def extract_meal_details(text):
    # Padrão para capturar todas as refeições e seus detalhes
    meal_pattern = re.compile(
        r'- Refeição \d+\.? ([^\n]+):\n((?: {4}- .+\n)+)', re.MULTILINE)

    matches = meal_pattern.findall(text)

    meals = {}
    for match in matches:
        meal_name = match[0].strip()
        foods = match[1].split('\n')[:-1]
        meals[meal_name] = foods

    return meals


def init_db():
    with app.app_context():
        db.create_all()


# MODELS
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    form_completed = db.Column(db.Boolean, default=False, nullable=False)
    meal_plans = db.relationship('MealPlan', backref='user', lazy=True)
    daily_needs = db.relationship('DailyNeeds', backref='user', uselist=False)


class UserInfo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    peso = db.Column(db.Float)
    altura = db.Column(db.Integer)
    idade = db.Column(db.Integer)
    sexo = db.Column(db.String(10))
    exercicios = db.Column(db.String(255))
    frequencia_exercicios = db.Column(db.String(20))
    duracao_exercicios = db.Column(db.String(20))
    biotipo = db.Column(db.String(20))
    meta = db.Column(db.String(50))
    condicoes = db.Column(db.String(255))
    dieta = db.Column(db.String(50))
    frequencia_legumes = db.Column(db.String(20))
    frequencia_frutas = db.Column(db.String(20))
    frequencia_verduras = db.Column(db.String(20))
    frequencia_carnes = db.Column(db.String(20))
    alimentos_excluidos = db.Column(db.String(255))
    suplementos = db.Column(db.String(255))
    uso_suplementos = db.Column(db.String(255))


class DailyNeeds(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    calorias = db.Column(db.Integer, nullable=False)
    proteinas = db.Column(db.Integer, nullable=False)
    carboidratos = db.Column(db.Integer, nullable=False)
    gorduras = db.Column(db.Integer, nullable=False)
    refeicoes = db.Column(db.Integer, nullable=False)


class MealPlan(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    meal_plan = db.Column(db.Text, nullable=False)


# ROUTES

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    existing_user = User.query.filter_by(email=data['email']).first()
    if existing_user:
        return jsonify({'message': 'Email já cadastrado'}), 400

    hashed_password = bcrypt.generate_password_hash(
        data['password']).decode('utf-8')
    new_user = User(
        username=data['username'],
        email=data['email'],
        password=hashed_password
    )
    db.session.add(new_user)
    db.session.commit()

    access_token = create_access_token(
        identity={'email': new_user.email, 'username': new_user.username})
    return jsonify({'token': access_token, 'message': 'Usuário registrado com sucesso'}), 201


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(email=data['email']).first()
    if user and bcrypt.check_password_hash(user.password, data['password']):
        access_token = create_access_token(
            identity={'email': user.email, 'username': user.username})
        return jsonify({'token': access_token, 'form_completed': user.form_completed}), 200
    return jsonify({'message': 'Credenciais inválidas'}), 401


@app.route('/submit_form', methods=['POST'])
@jwt_required()
def submit_form():
    data = request.get_json()
    current_user = get_jwt_identity()
    user = User.query.filter_by(email=current_user['email']).first()

    if not user:
        return jsonify({'message': 'Usuário não encontrado'}), 404

    user_info = UserInfo(
        user_id=user.id,
        peso=data.get('peso'),
        altura=data.get('altura'),
        idade=data.get('idade'),
        sexo=data.get('sexo'),
        exercicios=data.get('exercicios'),
        frequencia_exercicios=data.get('frequencia_exercicios'),
        duracao_exercicios=data.get('duracao_exercicios'),
        biotipo=data.get('biotipo'),
        meta=data.get('meta'),
        condicoes=data.get('condicoes'),
        dieta=data.get('dieta'),
        frequencia_legumes=data.get('frequencia_legumes'),
        frequencia_frutas=data.get('frequencia_frutas'),
        frequencia_verduras=data.get('frequencia_verduras'),
        frequencia_carnes=data.get('frequencia_carnes'),
        alimentos_excluidos=data.get('alimentos_excluidos'),
        suplementos=data.get('suplementos'),
        uso_suplementos=data.get('uso_suplementos'),
    )

    print(user_info)
    db.session.add(user_info)
    user.form_completed = True

    meal_plan_text, usage_tokens, prompt_tokens = generate_meal_plan(data)
    daily_needs_data = extract_daily_needs(meal_plan_text)
    meal_details = extract_meal_details(meal_plan_text)

    if daily_needs_data:
        daily_needs = DailyNeeds(
            user_id=user.id,
            calorias=daily_needs_data['calorias'],
            proteinas=daily_needs_data['proteinas'],
            carboidratos=daily_needs_data['carboidratos'],
            gorduras=daily_needs_data['gorduras'],
            refeicoes=daily_needs_data['refeicoes']
        )
        db.session.add(daily_needs)

    meal_plan = MealPlan(
        user_id=user.id,
        meal_plan=json.dumps(meal_details, ensure_ascii=False),
    )

    db.session.add(meal_plan)

    db.session.commit()

    return jsonify({'message': 'Formulário enviado com sucesso'}), 201


@app.route('/user_info', methods=['GET'])
@jwt_required()
def user_info():
    current_user = get_jwt_identity()
    user = User.query.filter_by(email=current_user['email']).first()
    if not user:
        return jsonify({'message': 'Usuário não encontrado'}), 404

    user_info = UserInfo.query.filter_by(user_id=user.id).first()
    if not user_info:
        return jsonify({'message': 'Informações do usuário não encontradas'}), 404

    daily_needs = DailyNeeds.query.filter_by(user_id=user.id).first()
    meal_plan = MealPlan.query.filter_by(user_id=user.id).first()

    return jsonify({
        'peso': user_info.peso,
        'altura': user_info.altura,
        'idade': user_info.idade,
        'sexo': user_info.sexo,
        'imc': user_info.peso / ((user_info.altura / 100) ** 2),
        'hidratacao': int(user_info.peso)*35,
        'daily_needs': {
            'calorias': daily_needs.calorias,
            'proteinas': daily_needs.proteinas,
            'carboidratos': daily_needs.carboidratos,
            'gorduras': daily_needs.gorduras,
            'refeicoes': daily_needs.refeicoes,
        } if daily_needs else None,
        'meal_plan': json.loads(meal_plan.meal_plan) if meal_plan else None,
    }), 200


# MAIN
if __name__ == '__main__':
    init_db()
    app.run(debug=True, host='0.0.0.0')
