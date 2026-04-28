import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/features/travel/viewmodel/travel_viewmodel.dart';

class CreateTravelScreen extends ConsumerStatefulWidget {
  const CreateTravelScreen({super.key});

  @override
  ConsumerState<CreateTravelScreen> createState() => _CreateTravelScreenState();
}

class _CreateTravelScreenState extends ConsumerState<CreateTravelScreen> {
  final _destinationController = TextEditingController();
  final _purposeController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isHijab = false;
  bool _isGenerating = false;

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blueAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _generatePlan() async {
    if (_destinationController.text.isEmpty || _purposeController.text.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tüm alanları doldurun')));
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final startDateStr = "${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}";
      final endDateStr = "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}";

      await ref.read(travelViewModelProvider.notifier).generatePlan(
        destination: _destinationController.text,
        startDate: startDateStr,
        endDate: endDateStr,
        purpose: _purposeController.text,
        isHijab: _isHijab,
      );

      if (mounted) {
        Navigator.pop(context); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = _startDate != null && _endDate != null
        ? "${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}"
        : "Tarih Seçin";

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Seyahat Planı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Yapay zeka asistanınız, gideceğiniz şehrin hava durumuna ve seyahat amacınıza göre dolabınızdan size özel bir valiz hazırlayacak.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: 'Gidilecek Şehir/Ülke',
                prefixIcon: const Icon(Icons.location_on_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDateRange,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Seyahat Tarihleri',
                  prefixIcon: const Icon(Icons.date_range_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(dateText, style: theme.textTheme.titleMedium),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _purposeController,
              decoration: InputDecoration(
                labelText: 'Seyahat Amacı (Örn: İş, Yaz Tatili, Kayak)',
                prefixIcon: const Icon(Icons.card_travel_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Tesettür Kombinleri'),
              subtitle: const Text('Valizinize uygun şal ve eşarplar eklenir.'),
              value: _isHijab,
              onChanged: (val) => setState(() => _isHijab = val),
              secondary: const Icon(Icons.checkroom_rounded),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generatePlan,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isGenerating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_isGenerating ? 'Valiz Hazırlanıyor...' : 'Valizimi Hazırla'),
            ),
          ],
        ),
      ),
    );
  }
}
