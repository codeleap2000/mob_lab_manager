import 'package:flutter/material.dart';
import 'package:mob_lab_manger/features/auth/domain/entities/password_validation_result.dart';

class PasswordConditionsWidget extends StatelessWidget {
  final List<PasswordValidationRule> rules;
  final String currentPassword;

  const PasswordConditionsWidget({
    super.key,
    required this.rules,
    required this.currentPassword,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final metColor = Colors.green.shade400;
    final unmetColor = isDarkMode ? Colors.red.shade300 : Colors.red.shade600;
    final defaultTextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return Padding(
      padding:
          const EdgeInsets.only(top: 8.0, bottom: 4.0, left: 4.0, right: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rules.map((rule) {
          // Call the validator function directly to get the current validity
          final bool isRuleMet = rule.validator(currentPassword);

          final color = isRuleMet ? metColor : unmetColor;
          final icon = isRuleMet
              ? Icons.check_circle_outline_rounded
              : Icons.highlight_off_rounded;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rule.description,
                    style: TextStyle(
                      // If rule is met, use default text color, otherwise use the unmetColor (red)
                      color: isRuleMet ? defaultTextColor : color,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
