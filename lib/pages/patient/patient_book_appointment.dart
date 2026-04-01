import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/doctor.dart';
import '../../theme.dart';

class PatientBookAppointment extends StatefulWidget {
  final User user;
  final List<Doctor> doctors;
  final VoidCallback? onBooked;

  const PatientBookAppointment({
    Key? key,
    required this.user,
    required this.doctors,
    this.onBooked,
  }) : super(key: key);

  @override
  State<PatientBookAppointment> createState() => _PatientBookAppointmentState();
}

class _PatientBookAppointmentState extends State<PatientBookAppointment> {
  Doctor?   _selectedDoctor;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _symptomsCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    super.dispose();
  }

  // ─── Pickers ──────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.darkGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.darkGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ─── Formatters ───────────────────────────────────────────────────────────

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  // ─── Submit ───────────────────────────────────────────────────────────────

  void _submit() async {
    if (_selectedDoctor == null) { _err('Please select a doctor'); return; }
    if (_selectedDate   == null) { _err('Please select a date');   return; }
    if (_selectedTime   == null) { _err('Please select a time');   return; }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.createAppointment(
        doctorCode: _selectedDoctor!.doctorCode,
        date: _fmtDate(_selectedDate!),
        time: _fmtTime(_selectedTime!),
        symptoms: _symptomsCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Appointment booked successfully!'),
        backgroundColor: AppColors.statusCompleted,
      ));
      widget.onBooked?.call();
      Navigator.pop(context);
    } catch (e) {
      _err('Failed to book appointment: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
    ));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Book an Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Select Doctor'),
            const SizedBox(height: 12),
            widget.doctors.isEmpty
                ? _emptyNote('No doctors available')
                : Column(children: widget.doctors.map(_doctorCard).toList()),
            const SizedBox(height: 24),

            _sectionTitle('Schedule'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _pickerTile(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: _selectedDate != null ? _fmtDate(_selectedDate!) : null,
                    placeholder: 'Select date',
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pickerTile(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    value: _selectedTime?.format(context),
                    placeholder: 'Select time',
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _sectionTitle('Symptoms (optional)'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 6),
                ],
              ),
              child: TextField(
                controller: _symptomsCtrl,
                maxLines: 4,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Describe your symptoms (e.g. fever for 2 days, cough...)',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            // ── Summary ─────────────────────────────────────────────
            if (_selectedDoctor != null || _selectedDate != null || _selectedTime != null) ...[
              const SizedBox(height: 28),
              _sectionTitle('Summary'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.darkCard,
                child: Column(
                  children: [
                    if (_selectedDoctor != null) ...[
                      _summaryRow('Doctor', _selectedDoctor!.name, Icons.person_rounded),
                      if (_selectedDoctor!.specialization != null)
                        _summaryRow('Specialization',
                            _selectedDoctor!.specialization!,
                            Icons.medical_services_rounded),
                    ],
                    if (_selectedDate != null)
                      _summaryRow('Date', _fmtDate(_selectedDate!),
                          Icons.calendar_today_rounded),
                    if (_selectedTime != null)
                      _summaryRow('Time', _selectedTime!.format(context),
                          Icons.access_time_rounded),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: AppColors.darkGreen.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: AppColors.accentGreen, strokeWidth: 2.5))
                    : const Text('Confirm Appointment',
                        style: TextStyle(fontSize: 16, letterSpacing: 0.3)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── Sub-widgets ──────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) =>
      Text(text, style: AppTextStyles.heading3);

  Widget _doctorCard(Doctor d) {
    final selected  = _selectedDoctor?.doctorCode == d.doctorCode;
    final available = d.availability?.toLowerCase() == 'available';

    return GestureDetector(
      onTap: available ? () => setState(() => _selectedDoctor = d) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.darkGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accentGreen : Colors.transparent,
            width: 2,
          ),
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: selected
                  ? AppColors.accentGreen
                  : AppColors.darkGreen.withOpacity(0.12),
              child: Text(
                d.name.isNotEmpty ? d.name[0].toUpperCase() : 'D',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: selected ? Colors.white : AppColors.darkGreen)),
                  if (d.specialization != null)
                    Text(d.specialization!,
                        style: TextStyle(
                            color: selected ? Colors.white70 : AppColors.textSecondary,
                            fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: available
                    ? Colors.green.withOpacity(selected ? 0.3 : 0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                available ? 'Available' : 'Unavailable',
                style: TextStyle(
                    color: available ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
          border: Border.all(
            color: hasValue ? AppColors.darkGreen.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.darkGreen, size: 20),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: 3),
            Text(value ?? placeholder,
                style: TextStyle(
                    color: hasValue ? AppColors.darkGreen : Colors.grey.shade400,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accentGreen),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _emptyNote(String text) => Container(
    padding: const EdgeInsets.all(16),
    decoration: AppDecorations.cardFlat,
    child: Text(text, style: AppTextStyles.caption),
  );
}
