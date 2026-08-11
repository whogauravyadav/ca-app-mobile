import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_buttons.dart';
import '../widgets/exam_multi_select.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late List<String> _exams;
  String? _examsError;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _name = TextEditingController(text: user?.name ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _exams = List<String>.from(user?.exams ?? const []);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_exams.isEmpty) {
      setState(() => _examsError = 'Select at least one exam');
      return;
    }
    setState(() {
      _loading = true;
      _examsError = null;
    });
    ref.read(authProvider.notifier).clearError();
    final ok = await ref.read(authProvider.notifier).updateProfile(
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          exams: _exams,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      context.pop();
    } else {
      final err = ref.read(authProvider).error;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please sign in'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Name required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        initialValue: user.email,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                          helperText: 'Email cannot be changed',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Phone is required';
                          }
                          if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) {
                            return 'Enter a valid 10-digit Indian mobile';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      ExamMultiSelectField(
                        selectedKeys: _exams,
                        errorText: _examsError,
                        onChanged: (keys) => setState(() {
                          _exams = keys;
                          _examsError =
                              keys.isEmpty ? 'Select at least one exam' : null;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Save changes',
                  loading: _loading,
                  onPressed: _save,
                  icon: Icons.check_rounded,
                ),
              ],
            ),
    );
  }
}
