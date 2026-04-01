import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/medicalrecord.dart';
import '../../theme.dart';

class PatientMedicalRecords extends StatefulWidget {
  final User user;
  const PatientMedicalRecords({Key? key, required this.user}) : super(key: key);

  @override
  State<PatientMedicalRecords> createState() => _PatientMedicalRecordsState();
}

class _PatientMedicalRecordsState extends State<PatientMedicalRecords> {
  List<MedicalRecord> records  = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() => isLoading = true);
    try { records = await ApiService.getMedicalRecords(); } catch (_) {}
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medical Records'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchData),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
          : records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No medical records yet',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (_, i) =>
                      _recordCard(records.reversed.toList()[i]),
                ),
    );
  }

  Widget _recordCard(MedicalRecord r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.description_rounded,
                      color: AppColors.accentGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Medical Record',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      Text(r.visitDate.isNotEmpty ? r.visitDate : '—',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ),
                Text(r.recordCode,
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          // ── Details ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow('Diagnosis', r.diagnosis,
                    Icons.medical_information_rounded, AppColors.accentTeal),
                const Divider(height: 20),
                _detailRow('Treatment', r.treatment,
                    Icons.healing_rounded, AppColors.accentBlue),
                const Divider(height: 20),
                _detailRow('Prescription', r.prescription,
                    Icons.medication_rounded, AppColors.accentOrange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: AppDecorations.iconBadge(color),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.label),
              const SizedBox(height: 3),
              Text(value.isNotEmpty ? value : '—', style: AppTextStyles.bodyBold),
            ],
          ),
        ),
      ],
    );
  }
}
