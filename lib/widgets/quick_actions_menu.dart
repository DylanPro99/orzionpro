import 'package:flutter/material.dart';

class QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });
}

class QuickActionsMenu extends StatelessWidget {
  final List<QuickAction> actions;
  final bool isVisible;

  const QuickActionsMenu({
    super.key,
    required this.actions,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: actions.map((action) => _buildActionButton(context, action)).toList(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, QuickAction action) {
    return Material(
      color: action.color?.withOpacity(0.1) ?? Theme.of(context).primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action.icon,
                size: 18,
                color: action.color ?? Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: action.color ?? Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSelected;
  final bool isVisible;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.onSelected,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(suggestion),
                onPressed: () => onSelected(suggestion),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ContextIndicator extends StatelessWidget {
  final int tokenCount;
  final int maxTokens;
  final String description;

  const ContextIndicator({
    super.key,
    required this.tokenCount,
    required this.maxTokens,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (tokenCount / maxTokens).clamp(0.0, 1.0);
    final color = percentage < 0.5
        ? Colors.green
        : percentage < 0.75
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
