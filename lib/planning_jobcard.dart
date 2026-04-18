import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';
import 'models.dart';
import 'material_request_screen.dart' hide StatusBadge;

const _teal = Color(0xFF26A69A);

// ─── Job Card Screen ───────────────────────────────────────────────────────────
class JobCardScreen extends StatelessWidget {
  const JobCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: EdgeInsets.all(sw * 0.05),
        itemCount: SampleData.jobCards.length,
        separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
        itemBuilder: (_, i) => _JobCardTile(
          job: SampleData.jobCards[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => JobDetailPage(job: SampleData.jobCards[i])),
          ),
        ),
      ),
    );
  }
}

// ─── Job Detail Page ──────────────────────────────────────────────────────────
class JobDetailPage extends StatelessWidget {
  final JobCard job;
  const JobDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(job.id);
    final shortCount = spares.where((s) => !s.isSufficient).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: buildTealAppBar(
        title: 'Job Card',
        showBack: true,
        context: context,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: Center(
              child: StatusBadge(
                label: job.status == 'inprogress' ? 'In Progress' : 'Pending',
                status: job.status,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Green job-order banner ───────────────────────────────────
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(sw * 0.04),
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    border: Border.all(color: const Color(0xFF81C784), width: 1.2),
                    borderRadius: BorderRadius.circular(sw * 0.03),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle_outline,
                        color: Color(0xFF43A047), size: 22),
                    SizedBox(width: sw * 0.025),
                    Expanded(
                      child: Text(
                        'Job Card: ${job.id} — ${job.productName}',
                        style: TextStyle(
                          fontSize: sw * 0.037,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ]),
                ),

                // ── Form-style info card ─────────────────────────────────────
                _sectionCard(
                  sw: sw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fullFormField(label: 'JOB CARD NO',  value: 'JC001',         sw: sw),
                      _fullFormField(label: 'PRODUCT CODE', value: 'PRD-0001',      sw: sw),
                      _fullFormField(label: 'PRODUCT NAME', value: job.productName, sw: sw),
                      _fullFormField(label: 'ASSIGNED TO',  value: job.assignedTo,  sw: sw),
                      _fullFormField(label: 'QUANTITY',     value: '${job.qty} units', sw: sw),
                      _fullFormField(
                        label: 'DELIVERY DATE',
                        value: '${job.startDate.day}/${job.startDate.month}/${job.startDate.year}',
                        sw: sw,
                      ),
                      _fullFormField(label: 'ASSIGNED TO',  value: job.assignedTo,  sw: sw),

                    ],
                  ),
                ),

                // ── Items ────────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.04, sw * 0.04, 0),
                  child: Row(children: [
                    Text('Items',
                        style: TextStyle(
                            fontSize: sw * 0.042,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const Spacer(),
                    if (shortCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025, vertical: sw * 0.01),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(sw * 0.015),
                        ),
                      ),
                  ]),
                ),

                SizedBox(height: sw * 0.03),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: Column(
                    children: spares.map((s) => Padding(
                      padding: EdgeInsets.only(bottom: sw * 0.03),
                      child: _SpareRow(spare: s, sw: sw),
                    )).toList(),
                  ),
                ),

                SizedBox(height: sw * 0.04),
              ]),
            ),
          ),

          // ── Action button (fixed above nav bar) ───────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.02, sw * 0.04, sw * 0.03),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(

                        builder: (_) => const MaterialRequestScreen(showBack: true),
                      ),
                    ),
                    icon: Icon(Icons.list_alt_outlined, size: sw * 0.05),
                    label: Text('Material Request',
                        style: TextStyle(fontSize: sw * 0.04)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: _teal),
                      padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionCard({required double sw, required Widget child}) => Container(
    margin: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.01),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(sw * 0.03),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2)),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(sw * 0.04),
      child: child,
    ),
  );

  Widget _fullFormField({
    required String label,
    required String value,
    required double sw,
    Color? valueColor,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: sw * 0.025),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: sw * 0.35,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: sw * 0.03,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Text(
              ':',
              style: TextStyle(
                fontSize: sw * 0.03,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: sw * 0.033,
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}

// ─── Spare Row widget ─────────────────────────────────────────────────────────
class _SpareRow extends StatelessWidget {
  final SpareItem spare;
  final double sw;
  const _SpareRow({required this.spare, required this.sw});

  @override
  Widget build(BuildContext context) {
    final sufficient = spare.isSufficient;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(sw * 0.04),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _spareRow(label: 'ITEM NAME', value: spare.name,   sw: sw),
          _spareRow(label: 'ITEM NO',   value: spare.partNo, sw: sw),
          _spareRow(label: 'REQUIRED',  value: '${spare.required} ${spare.uom}', sw: sw),
        ]),
      ),
    );
  }

  Widget _spareRow({
    required String label,
    required String value,
    required double sw,
    Color? valueColor,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: sw * 0.022),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: sw * 0.35,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: sw * 0.03,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Text(
              ':',
              style: TextStyle(
                fontSize: sw * 0.03,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: sw * 0.033,
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}

// ─── Job Card Tile ─────────────────────────────────────────────────────────────
class _JobCardTile extends StatelessWidget {
  final JobCard job;
  final VoidCallback onTap;
  const _JobCardTile({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(job.id);
    final hasShortage = spares.any((s) => !s.isSufficient);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(sw * 0.03),
          child: Padding(
            padding: EdgeInsets.all(sw * 0.04),
            child: Column(children: [
              Row(children: [
                Container(
                  width: sw * 0.12,
                  height: sw * 0.12,
                  decoration: BoxDecoration(
                    color: AppColors.inProgressLight,
                    borderRadius: BorderRadius.circular(sw * 0.025),
                  ),
                  child: Icon(Icons.assignment_outlined,
                      color: AppColors.inProgress, size: sw * 0.06),
                ),
                SizedBox(width: sw * 0.035),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.productName,
                            style: TextStyle(
                                fontSize: sw * 0.036,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        SizedBox(height: sw * 0.005),
                        Text('${job.id} · ${job.planRef}',
                            style: TextStyle(
                                fontSize: sw * 0.03,
                                color: AppColors.textSecondary)),
                      ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StatusBadge(
                    label: job.status == 'inprogress' ? 'In Progress' : 'Pending',
                    status: job.status,
                  ),
                  if (hasShortage) ...[
                    SizedBox(height: sw * 0.01),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.02, vertical: sw * 0.007),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(sw * 0.015),
                      ),
                      child: Text('Parts Short',
                          style: TextStyle(
                              fontSize: sw * 0.025,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger)),
                    ),
                  ],
                ]),
              ]),
              SizedBox(height: sw * 0.03),
              const Divider(color: Color(0xFFF0F0F0), height: 1),
              SizedBox(height: sw * 0.025),
              Row(children: [
                Icon(Icons.person_outline,
                    size: sw * 0.035, color: AppColors.textSecondary),
                SizedBox(width: sw * 0.01),
                Expanded(
                  child: Text(job.assignedTo,
                      style: TextStyle(
                          fontSize: sw * 0.03, color: AppColors.textSecondary)),
                ),
                Icon(Icons.settings_outlined,
                    size: sw * 0.035, color: AppColors.textSecondary),
                SizedBox(width: sw * 0.01),
                Text(job.machine,
                    style: TextStyle(
                        fontSize: sw * 0.03, color: AppColors.textSecondary)),
                SizedBox(width: sw * 0.03),
                Text('${job.qty} units',
                    style: TextStyle(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}