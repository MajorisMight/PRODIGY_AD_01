import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:lalcucator/widgets/display.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Calc extends StatefulWidget {
  const Calc({super.key});

  @override
  State<Calc> createState() => _CalcState();
}

class _CalcState extends State<Calc> {
  final buttonTextStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  final equalsStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  String currentInput = '0';
  String? operation;
  double? firstOperand;
  bool waitingForSecondOperand = false;

  Widget _buildButton(Widget child) {
    final isEqualsButton = child is Text && child.data == "=";
    final isClearButton = child is Text && child.data == "C";

    final buttonStyle = isEqualsButton
        ? FilledButton.styleFrom(
            enableFeedback: true,
            overlayColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withAlpha(30);
              }
              return Colors.transparent;
            }),
            minimumSize: const Size(64, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.blue.shade200,
            // foregroundColor: Colors.white,
          )
        : TextButton.styleFrom(
            enableFeedback: true,
            overlayColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withAlpha(30);
              }
              return Colors.transparent;
            }),
            minimumSize: const Size(64, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          );

    return FilledButton(
      style: buttonStyle,
      onPressed: () {
        HapticFeedback.lightImpact();
        _handleButtonPress(child);
      },

      onLongPress: isClearButton
          ? () {
              HapticFeedback.heavyImpact;
              setState(() {
                currentInput = '0';
                operation = null;
                firstOperand = null;
                waitingForSecondOperand = false;
              });
            }
          : null,
      child: child,
    );
  }

  void _handleButtonPress(Widget child) {
    setState(() {
      if (child is Text) {
        _handleTextButton(child.data!);
      } else if (child is Icon) {
        _handleIconButton(child.icon!);
      }
    });
  }

  void _handleTextButton(String value) {
    switch (value) {
      case "C":
        currentInput = '0';
        // operation = null;
        // firstOperand = null;
        // waitingForSecondOperand = false;
        break;

      case "\u00F7":
      case "\u00D7":
      case "-":
      case "+":
      case "%":
        if (firstOperand == null) {
          firstOperand = double.tryParse(currentInput);
        } else if (!waitingForSecondOperand) {
          firstOperand = double.tryParse(
            _calculate(firstOperand!, double.parse(currentInput), operation!),
          );
        }
        operation = value;
        waitingForSecondOperand = true;
        currentInput = '0';
        break;

      case ".":
        if (!currentInput.contains(".")) {
          currentInput += ".";
        }
        break;

      case "=":
        if (firstOperand != null &&
            operation != null &&
            !waitingForSecondOperand) {
          final result = _calculate(
            firstOperand!,
            double.parse(currentInput),
            operation!,
          );

          final box = Hive.box('history');
          final expression =
              "${formatOperand(firstOperand)} $operation $currentInput";
          box.add({"expression": expression, "result": result});

          currentInput = result;
          firstOperand = null;
          operation = null;
          waitingForSecondOperand = false;
        }
        break;

      default: // Numbers
        if (waitingForSecondOperand) {
          currentInput = value;
          waitingForSecondOperand = false;
        } else {
          currentInput = currentInput == "0" ? value : currentInput + value;
        }
        break;
    }
  }

  void _handleIconButton(IconData icon) {
    switch (icon) {
      case Icons.backspace:
        if (currentInput.length > 1) {
          currentInput = currentInput.substring(0, currentInput.length - 1);
        } else {
          currentInput = '0';
        }
        break;

      // case Icons.percent:
      //   double inputVal = double.tryParse(currentInput) ?? 0;
      //   currentInput = (inputVal / 100).toString();
      //   currentInput = double.parse(currentInput).toStringAsFixed(
      //       inputVal.truncateToDouble() == inputVal ? 0 : 6);
      //   currentInput =
      //       currentInput.replaceFirst(RegExp(r"\.?0+$"), ""); // trim zeroes
      //   break;

      default:
        break;
    }
  }

  String _calculate(double first, double second, String operation) {
    double result;
    switch (operation) {
      case '+':
        result = first + second;
        break;
      case '-':
        result = first - second;
        break;
      case '\u00D7':
        result = first * second;
        break;
      case '\u00F7':
        result = second != 0 ? first / second : double.nan;
        break;
      case '%':
        result = (first / 100) * second;
        break;
      default:
        result = 0;
        break;
    }

    return formatResult(result);
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      Text("C", style: buttonTextStyle),
      Text("%", style: buttonTextStyle),
      Icon(Icons.backspace),
      Text("\u00F7", style: buttonTextStyle),
      Text("7", style: buttonTextStyle),
      Text("8", style: buttonTextStyle),
      Text("9", style: buttonTextStyle),
      Text("\u00D7", style: buttonTextStyle),
      Text("4", style: buttonTextStyle),
      Text("5", style: buttonTextStyle),
      Text("6", style: buttonTextStyle),
      Text("-", style: buttonTextStyle),
      Text("1", style: buttonTextStyle),
      Text("2", style: buttonTextStyle),
      Text("3", style: buttonTextStyle),
      Text("+", style: buttonTextStyle),
      Text(".", style: buttonTextStyle),
      Text("0", style: buttonTextStyle),
      Text("=", style: equalsStyle),
      // const SizedBox.shrink(),
    ];

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Column(
          children: [
            Display(
              value: currentInput,
              operator: operation,
              firstOperand: formatOperand(firstOperand),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: List.generate(buttons.length, (index) {
                  final button = buttons[index];
                  final isEquals = button is Text && button.data == "=";

                  return StaggeredGridTile.count(
                    crossAxisCellCount: isEquals ? 2 : 1,
                    mainAxisCellCount: 1,
                    child: _buildButton(button),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatOperand(double? value) {
    if (value == null) return '';
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  String formatResult(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}
