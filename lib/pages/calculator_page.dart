import 'package:calculator/enums/operation_type.dart';
import 'package:calculator/pages/historic_page.dart';
import 'package:calculator/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  late String displayNumber;
  late List<String> historic;
  bool hasResult = false;
  final NumberFormat numberFormatter = NumberFormat("#,##0.##", "pt_BR");

  @override
  void initState() {
    displayNumber = '0';
    historic = [];
    hasResult = false;
    super.initState();
  }

  String formatResult(double value) {
    return numberFormatter.format(value);
  }

  void setOperationType(OperationTypeEnum newType) {
    final lastChar = displayNumber.characters.last;
    if (OperationTypeEnum.values.any((op) => op.symbol == lastChar)) return;

    setState(() {
      hasResult = false;
      displayNumber += newType.symbol;
    });
  }

  void deleteLastChar() {
    setState(() {
      if (displayNumber.length > 1) {
        displayNumber = displayNumber.substring(0, displayNumber.length - 1);
      } else {
        displayNumber = '0';
      }
    });
  }

  void clear() {
    setState(() {
      displayNumber = '0';
    });
  }

  void appendNumber(String stringNumber) {
    setState(() {
      if (hasResult) {
        displayNumber = stringNumber;
        hasResult = false;
        return;
      }

      if (displayNumber == "0") {
        displayNumber = stringNumber;
      } else {
        displayNumber += stringNumber;
      }
    });
  }

  List<double> parseNumbers(String expression) {
    RegExp regExp = RegExp(r'[0-9]+\.?[0-9]*');
    return regExp
        .allMatches(expression)
        .map((e) => double.parse(e.group(0)!))
        .toList();
  }

  List<OperationTypeEnum> getOperators(String expression) {
    return expression.characters
        .where((x) => OperationTypeEnum.values.any((op) => op.symbol == x))
        .map((x) => OperationTypeEnum.values.firstWhere((op) => op.symbol == x))
        .toList();
  }

  void resolvePriorityOperations(
    List<double> numbers,
    List<OperationTypeEnum> operators,
  ) {
    int index = 0;
    while (index < operators.length && numbers.length > index + 1) {
      if (operators[index] == OperationTypeEnum.multiplication) {
        numbers[index] *= numbers[index + 1];
        numbers.removeAt(index + 1);
        operators.removeAt(index);
      } else if (operators[index] == OperationTypeEnum.division) {
        numbers[index] /= numbers[index + 1];
        numbers.removeAt(index + 1);
        operators.removeAt(index);
      } else {
        index++;
      }
    }
  }

  double resolveAdditionAndSubtraction(
    List<double> numbers,
    List<OperationTypeEnum> operators,
  ) {
    int index = 0;
    while (index < operators.length && numbers.length > index + 1) {
      if (operators[index] == OperationTypeEnum.addition) {
        numbers[index] += numbers[index + 1];
      } else if (operators[index] == OperationTypeEnum.subtraction) {
        numbers[index] -= numbers[index + 1];
      }
      numbers.removeAt(index + 1);
      operators.removeAt(index);
    }
    return numbers.first;
  }

  void calculate() {
    String expression = displayNumber.replaceAll('.', '').replaceAll(',', '.');

    final lastChar = expression.characters.last;
    if (OperationTypeEnum.values.any((op) => op.symbol == lastChar)) return;

    final numbers = parseNumbers(expression);
    final operations = getOperators(expression);

    if (numbers.length < 2 || operations.isEmpty) return;

    resolvePriorityOperations(numbers, operations);
    final result = resolveAdditionAndSubtraction(numbers, operations);
    final formattedResult = formatResult(result);

    setState(() {
      displayNumber = formattedResult;
      historic.add("${expression.replaceAll('.', ',')} = $formattedResult");
      hasResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 250),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  HistoricPage(historic: historic),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                final slide = Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation);

                                return SlideTransition(
                                  position: slide,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                        ),
                      );
                    },
                    child: const Icon(Icons.history, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // DISPLAY
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    displayNumber,
                    key: ValueKey(displayNumber),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOTÕES
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      ButtonWidget(
                        text: "C",
                        onPressed: clear,
                        color: Colors.grey.shade700,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "\u232B",
                        onPressed: deleteLastChar,
                        color: Colors.grey.shade700,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "÷",
                        onPressed: () =>
                            setOperationType(OperationTypeEnum.division),
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ButtonWidget(
                        text: "7",
                        onPressed: () => appendNumber("7"),
                        color: Colors.grey.shade900,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "8",
                        onPressed: () => appendNumber("8"),
                        color: Colors.grey.shade900,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "9",
                        onPressed: () => appendNumber("9"),
                        color: Colors.grey.shade900,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "x",
                        onPressed: () =>
                            setOperationType(OperationTypeEnum.multiplication),
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ButtonWidget(
                        text: "4",
                        onPressed: () => appendNumber("4"),
                        color: Colors.grey.shade900,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "5",
                        onPressed: () => appendNumber("5"),
                        color: Colors.grey.shade900,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "6",
                        onPressed: () => appendNumber("6"),
                        color: Colors.grey.shade900,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "-",
                        onPressed: () =>
                            setOperationType(OperationTypeEnum.subtraction),
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ButtonWidget(
                        text: "1",
                        onPressed: () => appendNumber("1"),
                        color: Colors.grey.shade900,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "2",
                        onPressed: () => appendNumber("2"),
                        color: Colors.grey.shade900,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "3",
                        onPressed: () => appendNumber("3"),
                        color: Colors.grey.shade900,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "+",
                        onPressed: () =>
                            setOperationType(OperationTypeEnum.addition),
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ButtonWidget(
                          text: "0",
                          onPressed: () => appendNumber("0"),
                          color: Colors.grey.shade900,
                          textColor: Colors.white,
                        ),
                      ),
                      ButtonWidget(
                        text: ",",
                        onPressed: () => appendNumber(","),
                        color: Colors.grey.shade900,
                        textColor: Colors.white,
                      ),
                      ButtonWidget(
                        text: "=",
                        onPressed: calculate,
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
