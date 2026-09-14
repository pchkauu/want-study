import 'package:flutter/material.dart';
import 'package:study/src/domain/_barrel.dart';

const studyWarningColor = Color(0xFFF2B35F);

final class StudySurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;

  const StudySurface({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color,
    this.borderColor,
    this.radius = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

final class StudySectionHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? trailing;

  const StudySectionHeader({
    required this.title,
    this.description,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineMedium,
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 20), trailing!],
      ],
    );
  }
}

final class StudyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData actionIcon;

  const StudyStateView({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.add,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: StudySurface(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final class StudySkeleton extends StatelessWidget {
  final bool compact;

  const StudySkeleton({this.compact = false, super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    Widget block(double height, {double? width}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    return Semantics(
      label: 'Загрузка',
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            block(30, width: 240),
            const SizedBox(height: 24),
            if (compact)
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: block(double.infinity)),
                    const SizedBox(height: 16),
                    Expanded(child: block(double.infinity)),
                  ],
                ),
              )
            else
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 2, child: block(double.infinity)),
                    const SizedBox(width: 18),
                    Expanded(child: block(double.infinity)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String lessonStatusLabel(LessonStatusV1 value) => switch (value) {
  LessonStatusV1.planned => 'Запланирован',
  LessonStatusV1.studying => 'Изучается',
  LessonStatusV1.homework => 'Домашняя работа',
  LessonStatusV1.mastered => 'Освоен',
};

Color lessonStatusColor(BuildContext context, LessonStatusV1 value) {
  final scheme = Theme.of(context).colorScheme;
  return switch (value) {
    LessonStatusV1.planned => scheme.onSurfaceVariant,
    LessonStatusV1.studying => scheme.primary,
    LessonStatusV1.homework => studyWarningColor,
    LessonStatusV1.mastered => scheme.tertiary,
  };
}

final class LessonStatusBadge extends StatelessWidget {
  final LessonStatusV1 status;

  const LessonStatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final color = lessonStatusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        lessonStatusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
