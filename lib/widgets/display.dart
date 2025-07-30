import 'package:flutter/material.dart';

class Display extends StatelessWidget {
  final String value;        // current input or result
  final String? operator;    // "+", "-", etc.
  final String? firstOperand;

  const Display({
    super.key,
    required this.value,
    this.operator,
    this.firstOperand,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final hasTopLine = firstOperand != null && operator != null;

    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.20,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      alignment: Alignment.bottomRight,
      decoration: BoxDecoration(
        color: const Color.fromARGB(55, 93, 98, 104),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (hasTopLine)
            Text(
              '$firstOperand $operator',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 20,
                
              ),
              textAlign: TextAlign.right,
            ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: textTheme.displaySmall?.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.w300,
              ),
              maxLines: 1,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
