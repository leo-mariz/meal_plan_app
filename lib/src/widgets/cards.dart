import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CalorieCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;

  const CalorieCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color)),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(unit, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}

class CalorieProgress extends StatelessWidget {
  final double percent;

  const CalorieProgress({
    required this.percent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 60.0,
      lineWidth: 13.0,
      animation: true,
      percent: percent,
      center: Text(
        "${(percent * 2500).toInt()} kcal left", // Example: 2500 kcal is the daily goal
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.blue,
    );
  }
}

class MealCard extends StatelessWidget {
  final String mealType;
  final String description;

  const MealCard({
    required this.mealType,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.food_bank),
        title: Text(mealType),
        subtitle: Text(description),
      ),
    );
  }
}

class BodyMeasurementCard extends StatelessWidget {
  final String weightValue;
  final String height;
  final String bmi;

  const BodyMeasurementCard({
    required this.weightValue,
    required this.height,
    required this.bmi,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.monitor_weight),
        title: Text(weightValue),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(height),
            Text(bmi),
          ],
        ),
      ),
    );
  }
}

class WaterIntakeCard extends StatelessWidget {
  final String intake;

  const WaterIntakeCard({
    required this.intake,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_drink),
        title: Text(intake),
      ),
    );
  }
}


