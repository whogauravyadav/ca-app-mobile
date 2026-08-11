import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/exam_catalog.dart';
import '../core/theme.dart';

/// Multi-select exam picker shown as a field that opens a bottom sheet.
class ExamMultiSelectField extends StatelessWidget {
  const ExamMultiSelectField({
    super.key,
    required this.selectedKeys,
    required this.onChanged,
    this.options = ExamCatalog.defaults,
    this.errorText,
  });

  final List<String> selectedKeys;
  final ValueChanged<List<String>> onChanged;
  final List<ExamOption> options;
  final String? errorText;

  Future<void> _openPicker(BuildContext context) async {
    final draft = Set<String>.from(selectedKeys);

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Select target exams',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can choose more than one',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: MediaQuery.of(ctx).size.height * 0.5,
                      child: ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (_, i) {
                          final opt = options[i];
                          final checked = draft.contains(opt.key);
                          return CheckboxListTile(
                            value: checked,
                            activeColor: AppColors.primaryDark,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              opt.label,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onChanged: (v) {
                              setModal(() {
                                if (v == true) {
                                  draft.add(opt.key);
                                } else {
                                  draft.remove(opt.key);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(ctx).pop(draft.toList()..sort()),
                      child: Text(
                        draft.isEmpty
                            ? 'Done'
                            : 'Done (${draft.length} selected)',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = selectedKeys.map(ExamCatalog.labelFor).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Target exams',
            prefixIcon: const Icon(Icons.school_outlined),
            errorText: errorText,
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          child: InkWell(
            onTap: () => _openPicker(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: labels.isEmpty
                  ? Text(
                      'Tap to select exams',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: labels
                          .map(
                            (l) => Chip(
                              label: Text(
                                l,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                              backgroundColor: AppColors.primary,
                              side: BorderSide.none,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
