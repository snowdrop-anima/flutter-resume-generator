import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customizable Text Resume Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ResumeHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ResumeHomePage extends StatefulWidget {
  @override
  _ResumeHomePageState createState() => _ResumeHomePageState();
}

class _ResumeHomePageState extends State<ResumeHomePage> {
  double fontSize = 16.0;
  Color fontColor = Colors.black;
  Color backgroundColor = Colors.white;
  String resumeText = 'Press "Generate Resume" to load!';

  Future<void> fetchResume(String name) async {
  final proxyUrl = 'https://api.allorigins.win/raw?url=';
  final targetUrl = Uri.encodeComponent('https://expressjs-api-resume-random.onrender.com/resume?name=$name');
  final url = Uri.parse('$proxyUrl$targetUrl');

  try {
    final response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List skills = data['skills'];
      List projects = data['projects'];
      String projectText = projects.map((p) =>
          "- ${p['title']}: ${p['description']} (${p['startDate']} to ${p['endDate']})").join("\n");

      setState(() {
        resumeText =
            "Name: ${data['name']}\n"
            "Phone: ${data['phone']}\n"
            "Email: ${data['email']}\n"
            "Twitter: ${data['twitter']}\n"
            "Address: ${data['address']}\n"
            "\nSummary: ${data['summary']}\n"
            "\nSkills:\n- ${skills.join("\n- ")}\n"
            "\nProjects:\n$projectText";
      });
    } else {
      setState(() {
        resumeText = "Failed to load resume. Status Code: ${response.statusCode}";
      });
    }
  } catch (e) {
    print('Error: $e');
    setState(() {
      resumeText = "Error fetching data!";
    });
  }
}

  void showColorPicker(bool isFont) {
    Color tempColor = isFont ? fontColor : backgroundColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isFont ? 'Pick Font Color' : 'Pick Background Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                setState(() {
                  if (isFont) {
                    fontColor = color;
                  } else {
                    backgroundColor = color;
                  }
                });
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resume Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Customize your resume:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Font Size Slider
            Row(
              children: [
                Text("Font Size: ", style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Slider(
                    value: fontSize,
                    min: 12,
                    max: 30,
                    divisions: 18,
                    label: fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        fontSize = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            // Color Pickers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => showColorPicker(true),
                  child: Text("Font Color"),
                ),
                ElevatedButton(
                  onPressed: () => showColorPicker(false),
                  child: Text("Background Color"),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Resume Display
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    resumeText,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: fontColor,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 15),

            // Generate Button
            ElevatedButton(
              onPressed: () => fetchResume("Anima"),
              child: Text('Generate Resume'),
            ),
          ],
        ),
      ),
    );
  }
}