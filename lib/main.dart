import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: InputScreen(),
    );
  }
}

class InputScreen extends StatelessWidget {
  final TextEditingController systolicController = TextEditingController();
  final TextEditingController diastolicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLOOD PRESSURE MONITER'),
        backgroundColor: Color.fromARGB(255, 194, 243, 33),
      ),
      backgroundColor: const Color.fromARGB(255, 252, 242, 179),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            
            SizedBox(height: 20),
            TextFormField(
              controller: systolicController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: InputDecoration(
                labelText: 'Systolic (40-180) mm Hg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              textInputAction: TextInputAction.next,
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
              autofocus: true,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: diastolicController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: InputDecoration(
                labelText: 'Diastolic (40-120) mm Hg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(context),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submit(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 243, 33, 51),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              child: Text('SHOW INFORMATION'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final systolic = double.tryParse(systolicController.text);
    final diastolic = double.tryParse(diastolicController.text);
    if (systolic != null &&
        systolic >= 40 &&
        systolic <= 180 &&
        diastolic != null &&
        diastolic >= 40 &&
        diastolic <= 120) {
      Get.to(() => InformationScreen(systolic: systolic, diastolic: diastolic));
    } else {
      Get.defaultDialog(
        title: 'Error',
        middleText:
            'Please enter valid blood pressure values (Systolic: 40-180 mm Hg, Diastolic: 40-120 mm Hg).',
      );
    }
  }
}

class InformationScreen extends StatelessWidget {
  final double systolic;
  final double diastolic;

  InformationScreen({Key? key, required this.systolic, required this.diastolic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String category = _getCategory(systolic, diastolic);

    return Scaffold(
      appBar: AppBar(
        title: Text('BLOOD PRESSURE INFORMATION'),
        backgroundColor: const Color.fromARGB(255, 184, 243, 33),
      ),
      backgroundColor: const Color.fromARGB(255, 251, 252, 179),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Blood Pressure Category',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Systolic: $systolic mm Hg',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Diastolic: $diastolic mm Hg',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Category: $category',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String categoryTitle, String systolicRange,
      String diastolicRange, String userCategory,
      {bool isEmergency = false}) {
    bool isSelected = categoryTitle.toUpperCase() == userCategory.toUpperCase();
    return DataRow(
      cells: [
        DataCell(Text(categoryTitle)),
        DataCell(Text(systolicRange)),
        DataCell(Text(diastolicRange)),
      ],
      selected: isSelected,
      onSelectChanged: (bool? selected) {
        if (isEmergency) {
          showDialog(
            context: Get.context!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Emergency'),
                content: Text('Seek immediate medical attention.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        }
      },
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) return Colors.red[100];
        return null; // Use default value for other states and unselected rows.
      }),
    );
  }

  String _getCategory(double systolic, double diastolic) {
    if (systolic >= 180 || diastolic > 120) {
      return 'Hypertensive Crisis';
    } else if (systolic >= 140 || diastolic >= 90) {
      return 'High Blood Pressure\n(Stage 2)';
    } else if (systolic >= 130 || diastolic >= 80) {
      return 'High Blood Pressure\n(Stage 1)';
    } else if (systolic >= 120) {
      return 'Elevated';
    } else {
      return 'Normal';
    }
  }
}
