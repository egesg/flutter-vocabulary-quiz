import 'package:flutter/material.dart';
import 'package:csv/csv.dart' as csv;

void main() => runApp(const VocabularyQuiz());

class VocabularyQuiz extends StatelessWidget {
  const VocabularyQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<List<dynamic>> vocabularyData = [];
  int currentIndex = 0;
  TextEditingController answerController = TextEditingController();
  String feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    loadVocabularyData();
  }

  void loadVocabularyData() async {
    String csvData = await DefaultAssetBundle.of(context)
        .loadString('assets/vocabulary.csv');
    List<List<dynamic>> csvTable =
        const csv.CsvToListConverter().convert(csvData);
    setState(
      () {
        vocabularyData = csvTable.sublist(1); // Exclude the header row
      },
    );
  }

  void checkAnswer() {
    String userAnswer = answerController.text.toLowerCase();
    String correctAnswer = vocabularyData[currentIndex][0].toLowerCase();

    if (userAnswer == correctAnswer) {
      showAlert('Correct!');
    } else {
      showAlert('Wrong!', correctAnswer);
    }
  }

  void showAlert(String title, [String? message]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message ?? ''),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                answerController.clear();
                setState(
                  () {
                    currentIndex = (currentIndex + 1) % vocabularyData.length;
                    if (currentIndex == 0) {
                      showEndOfQuizAlert();
                    }
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  void showEndOfQuizAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End of Quiz'),
          content: const Text('You have reached the end of the quiz.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Start Over'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentIndex = 0;
                });
              },
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
        title: const Text('Vocabulary Quiz'),
      ),
      backgroundColor: Colors.deepOrangeAccent,
      body: vocabularyData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    vocabularyData[currentIndex][1],
                    style: const TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      child: TextField(
                        controller: answerController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Translation',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      textStyle: const TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                    onPressed: checkAnswer,
                    child: const Text('Check Answer'),
                  ),
                  const SizedBox(height: 40.0),
                  Text(feedbackMessage),
                ],
              ),
            ),
    );
  }
}
