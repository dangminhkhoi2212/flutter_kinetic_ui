import 'package:flutter/material.dart';
import '../../tokens/kinetic_spacing.dart';
import '../../tokens/kinetic_typography.dart';
import '../../tokens/kinetic_theme.dart';

/// Defines a single column in a [KineticTable].
class KineticTableColumn<T> {
  const KineticTableColumn({
    required this.label,
    required this.builder,
    this.sortable = false,
    this.width,
  });

  /// The column header label.
  final String label;

  /// Builds the cell widget for a given row value.
  final Widget Function(T row) builder;

  /// Whether tapping the header calls [KineticTable.onSort].
  final bool sortable;

  /// Fixed pixel width for this column. If null the column is flexible.
  final double? width;
}

/// A horizontally scrollable data table.
///
/// Example:
/// ```dart
/// KineticTable<User>(
///   columns: [
///     KineticTableColumn(label: 'Name', builder: (u) => Text(u.name)),
///     KineticTableColumn(label: 'Email', builder: (u) => Text(u.email)),
///   ],
///   rows: users,
///   isStriped: true,
///   onRowTap: (u) => print(u.name),
/// )
/// ```
class KineticTable<T> extends StatelessWidget {
  const KineticTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onSort,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.isStriped = false,
    this.onRowTap,
  });

  /// The column definitions.
  final List<KineticTableColumn<T>> columns;

  /// The data rows.
  final List<T> rows;

  /// Called when a sortable column header is tapped.
  final void Function(int columnIndex, bool ascending)? onSort;

  /// Index of the currently sorted column, or null if none.
  final int? sortColumnIndex;

  /// Whether the current sort is ascending.
  final bool sortAscending;

  /// Whether to render alternating row backgrounds.
  final bool isStriped;

  /// Called when a data row is tapped.
  final void Function(T row)? onRowTap;

  @override
  Widget build(BuildContext context) {
    final theme = KineticTheme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderRow(
              columns: columns,
              theme: theme,
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              onSort: onSort,
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.border,
            ),
            ...List.generate(rows.length, (rowIndex) {
              final row = rows[rowIndex];
              final isOdd = rowIndex.isOdd;

              Color rowBackground = theme.background;
              if (isStriped && isOdd) {
                rowBackground = theme.muted.withValues(alpha: 0.5);
              }

              Widget rowWidget = _DataRow(
                row: row,
                columns: columns,
                theme: theme,
                background: rowBackground,
                onRowTap: onRowTap,
              );

              if (rowIndex < rows.length - 1) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    rowWidget,
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.border,
                    ),
                  ],
                );
              }

              return rowWidget;
            }),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow<T> extends StatelessWidget {
  const _HeaderRow({
    required this.columns,
    required this.theme,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
  });

  final List<KineticTableColumn<T>> columns;
  final KineticThemeData theme;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending)? onSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: theme.muted,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(columns.length, (index) {
          final column = columns[index];
          final isSorted = sortColumnIndex == index;

          Widget label = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                column.label,
                style: KineticTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.foreground,
                ),
              ),
              if (column.sortable) ...[
                const SizedBox(width: 4),
                Icon(
                  isSorted
                      ? (sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward)
                      : Icons.arrow_upward,
                  size: 14,
                  color: isSorted
                      ? theme.foreground
                      : theme.mutedForeground,
                ),
              ],
            ],
          );

          Widget cell = Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KineticSpacing.lg,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: label,
            ),
          );

          if (column.sortable && onSort != null) {
            cell = InkWell(
              onTap: () {
                final newAscending =
                    isSorted ? !sortAscending : true;
                onSort!(index, newAscending);
              },
              child: cell,
            );
          }

          if (column.width != null) {
            return SizedBox(
              width: column.width,
              height: 44,
              child: cell,
            );
          }

          return Expanded(
            child: SizedBox(
              height: 44,
              child: cell,
            ),
          );
        }),
      ),
    );
  }
}

class _DataRow<T> extends StatelessWidget {
  const _DataRow({
    required this.row,
    required this.columns,
    required this.theme,
    required this.background,
    required this.onRowTap,
  });

  final T row;
  final List<KineticTableColumn<T>> columns;
  final KineticThemeData theme;
  final Color background;
  final void Function(T row)? onRowTap;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      height: 48,
      color: background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(columns.length, (index) {
          final column = columns[index];

          Widget cell = Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KineticSpacing.lg,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DefaultTextStyle(
                style: KineticTypography.bodySmall.copyWith(
                  color: theme.foreground,
                ),
                child: column.builder(row),
              ),
            ),
          );

          if (column.width != null) {
            return SizedBox(
              width: column.width,
              height: 48,
              child: cell,
            );
          }

          return Expanded(
            child: SizedBox(
              height: 48,
              child: cell,
            ),
          );
        }),
      ),
    );

    if (onRowTap != null) {
      content = InkWell(
        onTap: () => onRowTap!(row),
        child: content,
      );
    }

    return content;
  }
}
