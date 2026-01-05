import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/player.dart';
import '../../providers/auth_provider.dart';
import '../../providers/players_provider.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';

class PlayerFormScreen extends StatefulWidget {
  final Player? player;

  const PlayerFormScreen({super.key, this.player});

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool _isLoading = false;

  bool get isEditing => widget.player != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.player!.name;
      _phoneController.text = widget.player!.phone ?? '';
      _emailController.text = widget.player!.email ?? '';
      _notesController.text = widget.player!.notes ?? '';
      _weightController.text = widget.player!.weight?.toString() ?? '';
      _heightController.text = widget.player!.height?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final playersProvider = Provider.of<PlayersProvider>(context, listen: false);

    final player = Player(
      id: widget.player?.id,
      trainerId: authProvider.trainerId!,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      weight: _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text.trim()),
      height: _heightController.text.trim().isEmpty ? null : double.tryParse(_heightController.text.trim()),
      createdAt: widget.player?.createdAt,
    );

    bool success;
    if (isEditing) {
      success = await playersProvider.updatePlayer(player);
    } else {
      final newPlayer = await playersProvider.createPlayer(player);
      success = newPlayer != null;
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing 
              ? (l10n?.saveChanges ?? 'تم الحفظ') 
              : (l10n?.success ?? 'تمت الإضافة')),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(playersProvider.error ?? (l10n?.error ?? 'خطأ في الحفظ')),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing 
            ? (l10n?.editPlayer ?? 'تعديل اللاعب') 
            : (l10n?.addPlayer ?? 'إضافة لاعب')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name Field
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              validator: (value) => Validators.required(value, fieldName: l10n?.fullName ?? 'الاسم'),
              decoration: InputDecoration(
                labelText: '${l10n?.fullName ?? 'الاسم الكامل'} *',
                prefixIcon: const Icon(Icons.person_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
              decoration: InputDecoration(
                labelText: l10n?.phone ?? 'رقم الهاتف',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n?.email ?? 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Weight & Height Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n?.weight ?? 'الوزن (كغ)',
                      prefixIcon: const Icon(Icons.monitor_weight_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n?.height ?? 'الطول (سم)',
                      prefixIcon: const Icon(Icons.height_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes Field
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n?.paymentNotes ?? 'ملاحظات',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.notes_outlined),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(isEditing 
                      ? (l10n?.saveChanges ?? 'حفظ التغييرات') 
                      : (l10n?.addPlayer ?? 'إضافة لاعب')),
            ),
          ],
        ),
      ),
    );
  }
}
