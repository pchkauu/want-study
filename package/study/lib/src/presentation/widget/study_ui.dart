import 'package:flutter/material.dart';
import 'package:study/src/domain/_barrel.dart';

const studyWarningColor = Color(0xFFE0AA62);

Future<T?> showStudyDialogV1<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) async {
  ModalRoute<dynamic>? route;
  final disableAnimations = MediaQuery.disableAnimationsOf(context);
  final result = await showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    transitionDuration: disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, __) {
      route ??= ModalRoute.of(dialogContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SizedBox(
                width: MediaQuery.sizeOf(dialogContext).width,
                height: double.infinity,
                child: builder(dialogContext),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
    ),
  );
  await route?.completed;
  return result;
}

final class StudySideSheet extends StatelessWidget {
  final Widget title;
  final Widget child;
  final List<Widget> actions;

  const StudySideSheet({
    required this.title,
    required this.child,
    required this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 20,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 26, 18, 20),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTextStyle(
                    style: theme.textTheme.headlineSmall!,
                    child: title,
                  ),
                ),
                IconButton(
                  tooltip: 'Закрыть',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              child: child,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 10,
              children: actions,
            ),
          ),
        ],
      ),
    );
  }
}

final class StudyBackdrop extends StatelessWidget {
  final Widget child;

  const StudyBackdrop({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerLowest,
      child: CustomPaint(
        painter: _StudyGridPainter(
          color: scheme.outlineVariant.withValues(alpha: 0.22),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.82, -0.94),
              radius: 1.05,
              colors: [
                scheme.primary.withValues(alpha: 0.1),
                Colors.transparent,
              ],
              stops: const [0, 0.72],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

final class _StudyGridPainter extends CustomPainter {
  final Color color;

  const _StudyGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    const step = 48.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StudyGridPainter oldDelegate) =>
      oldDelegate.color != color;
}

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
    this.radius = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? Colors.transparent),
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
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.hasBoundedHeight ? constraints.maxHeight : 0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: StudySurface(
                padding: const EdgeInsets.fromLTRB(40, 36, 40, 42),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.14,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        icon,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
        borderRadius: BorderRadius.circular(8),
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
