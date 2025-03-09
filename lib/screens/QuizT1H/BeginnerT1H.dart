import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';

class BeginnerT1H extends StatefulWidget {
  @override
  _BeginnerT1HState createState() => _BeginnerT1HState();
}

class _BeginnerT1HState extends State<BeginnerT1H> {
  final List<Map<String, dynamic>> questions = [
    {
      "question": "What civilization founded the city of Carthage?",
      "options": ["Romans", "Phoenicians", "Greeks", "Egyptians"],
      "answer": 1
    },
    {
      "question": "What was a common material used for Carthaginian votive stelae?",
      "options": ["Bronze", "Marble", "Limestone", "Clay"],
      "answer": 2
    },
    {
      "question": "Which goddess was frequently depicted in Carthaginian religious symbols?",
      "options": ["Tanit", "Athena", "Isis", "Venus"],
      "answer": 0
    },
  ];

  int currentQuestionIndex = 0;
  int? selectedOption;
  int remainingTime = 15;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          _timer.cancel();
          nextQuestion();
        }
      });
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        currentQuestionIndex = 0;
      }
      selectedOption = null;
      remainingTime = 15; // Reset timer for the next question
      _startTimer(); // Restart timer
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: -1,
            width: 525,
            height: 90,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff003add),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
            ),
          ),

          // Timer Text Countdown (Top Left)
          Positioned(
            top: 95,
            left: 25,
            child: Text(
              '⏳ $remainingTime ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Timer Progress Bar
          Positioned(
            top: 130,
            left: 25,
            right: 25,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: Duration(seconds: 1),
                    width: MediaQuery.of(context).size.width * (remainingTime / 15),
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xff003add),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 163,
            left: 23,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: Stack(
                children: [
                  Image.network(
                    'https://www.worldhistory.org/uploads/images/5178.jpg',
                    width: 347,
                    height: 223,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 80,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Text(
                        questions[currentQuestionIndex]["question"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 400,
            left: 38,
            child: Column(
              children: List.generate(
                questions[currentQuestionIndex]["options"].length,
                    (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = index;
                      });
                    },
                    child: _optionButton(
                      questions[currentQuestionIndex]["options"][index],
                      selectedOption == index,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: 250,
              height: 124,
              decoration: BoxDecoration(
                color: Color(0xff003add).withOpacity(0.35),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 3,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 45,
            left: 127,
            child: GestureDetector(
              onTap: selectedOption != null ? nextQuestion : null,
              child: Container(
                width: 137,
                height: 47,
                decoration: BoxDecoration(
                  color: selectedOption != null ? Color(0xff003add) : Colors.grey,
                  borderRadius: BorderRadius.circular(28.75),
                ),
                child: Center(
                  child: Text(
                    "NEXT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _optionButton(String text, bool isSelected) {
    return Container(
      width: 319,
      height: 72,
      decoration: BoxDecoration(
        color: isSelected ? Color(0xff001f7a) : Color(0xff003add).withOpacity(0.57),
        borderRadius: BorderRadius.circular(8.79),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
