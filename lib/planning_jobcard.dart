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

  bool get _isSteelFrame => job.id == 'JC-004';

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
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Green job-order banner (like Image 1) ──────────────────────────
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

          // ── Form-style info card (Image 1 layout) ─────────────────────────
          _sectionCard(
            sw: sw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fullFormField(
                  label: 'PLAN REFERENCE',
                  value: job.planRef,
                  sw: sw,
                ),
                SizedBox(height: sw * 0.04),

                _fullFormField(
                  label: 'JOB CARD NO',
                  value: job.id,
                  sw: sw,
                ),
                SizedBox(height: sw * 0.04),

                _fullFormField(
                  label: 'PRODUCT CODE',
                  value: 'PRD-0001',
                  sw: sw,
                ),
                SizedBox(height: sw * 0.04),

                _fullFormField(
                  label: 'PRODUCT NAME',
                  value: job.productName,
                  sw: sw,
                ),
                SizedBox(height: sw * 0.04),

                _fullFormField(
                  label: 'ASSIGNED TO',
                  value: job.assignedTo,
                  sw: sw,
                ),
                SizedBox(height: sw * 0.04),

                _fullFormField(
                  label: 'MACHINE',
                  value: job.machine,
                  sw: sw,
                ),
                SizedBox(height: sw * 0.04),

                _fullFormField(
                  label: 'QUANTITY',
                  value: '${job.qty} units',
                  sw: sw,
                ),
                SizedBox(height: sw * 0.04),

                _fullFormField(
                  label: 'START DATE',
                  value: '${job.startDate.day}/${job.startDate.month}/${job.startDate.year}',
                  sw: sw,
                  // icon: Icons.calendar_today_outlined,
                ),
                SizedBox(height: sw * 0.04),

                _fullFormField(
                  label: 'END DATE',
                  value: '${job.endDate.day}/${job.endDate.month}/${job.endDate.year}',
                  sw: sw,
                  // icon: Icons.calendar_today_outlined,
                ),
              ],
            ),
          ),

        // ── Spares & Components ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.02, sw * 0.04, 0),
            child: Row(children: [
              Text('Spares & Components',
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
                  child: Text('$shortCount short',
                      style: TextStyle(
                          fontSize: sw * 0.028,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger)),
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

          // ── Action buttons ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.06),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _MRFromJobCardPage(jobId: job.id),
                    ),
                  ),
                  icon: Icon(Icons.list_alt_outlined, size: sw * 0.04),
                  label: Text('Material Request',
                      style: TextStyle(fontSize: sw * 0.03)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _teal,
                    side: const BorderSide(color: _teal),
                    padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                  ),
                  icon: Icon(Icons.play_circle_outline, size: sw * 0.04),
                  label: Text('Update Status',
                      style: TextStyle(fontSize: sw * 0.03)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, double sw) => Padding(
    padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.02, sw * 0.04, sw * 0.02),
    child: Row(children: [
      Container(
        width: sw * 0.012,
        height: sw * 0.05,
        decoration: BoxDecoration(
          color: _teal,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      SizedBox(width: sw * 0.025),
      Text(title,
          style: TextStyle(
              fontSize: sw * 0.042,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
    ]),
  );

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

  Widget _formRow({required double sw, required Widget left, required Widget right}) =>
      Row(children: [
        Expanded(child: left),
        SizedBox(width: sw * 0.04),
        Expanded(child: right),
      ]);

  Widget _formField({
    required String label,
    required String value,
    required double sw,
    IconData? icon,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: sw * 0.027,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.4)),
        SizedBox(height: sw * 0.015),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: sw * 0.035, vertical: sw * 0.032),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(sw * 0.02),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(children: [
            if (icon != null) ...[
              Icon(icon, size: sw * 0.038, color: AppColors.textSecondary),
              SizedBox(width: sw * 0.02),
            ],
            Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: sw * 0.033,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
      ]);

  Widget _fullFormField({
    required String label,
    required String value,
    required double sw,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: sw * 0.027,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.4)),
        SizedBox(height: sw * 0.015),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: sw * 0.035, vertical: sw * 0.032),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(sw * 0.02),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(value,
              style: TextStyle(
                  fontSize: sw * 0.033,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500)),
        ),
      ]);

  Widget _divider() => const Divider(color: Color(0xFFF0F0F0), height: 1);

  Widget _opRow(
      String num, String name, String status, String resource, double sw) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: sw * 0.025),
        child: Row(children: [
          Container(
            width: sw * 0.08,
            height: sw * 0.08,
            decoration: BoxDecoration(
              color: status == 'completed'
                  ? AppColors.successLight
                  : status == 'inprogress'
                  ? AppColors.inProgressLight
                  : const Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: status == 'completed'
                  ? Icon(Icons.check,
                  size: sw * 0.038, color: AppColors.success)
                  : Text(num,
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    fontWeight: FontWeight.w700,
                    color: status == 'inprogress'
                        ? AppColors.inProgress
                        : AppColors.textSecondary,
                  )),
            ),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontSize: sw * 0.034,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  SizedBox(height: sw * 0.005),
                  Text(resource,
                      style: TextStyle(
                          fontSize: sw * 0.03,
                          color: AppColors.textSecondary)),
                ]),
          ),
          StatusBadge(
            label: status == 'completed'
                ? 'Done'
                : status == 'inprogress'
                ? 'Active'
                : 'Pending',
            status: status == 'completed' ? 'completed' : status,
          ),
        ]),
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
    final pct = spare.required > 0
        ? (spare.inStock / spare.required).clamp(0.0, 1.0)
        : 1.0;

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
          Row(children: [
            Container(
              width: sw * 0.09,
              height: sw * 0.09,
              decoration: BoxDecoration(
                color: sufficient ? AppColors.successLight : AppColors.dangerLight,
                borderRadius: BorderRadius.circular(sw * 0.02),
              ),
              child: Icon(
                sufficient
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                color: sufficient ? AppColors.success : AppColors.danger,
                size: sw * 0.048,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spare.name,
                        style: TextStyle(
                            fontSize: sw * 0.034,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    SizedBox(height: sw * 0.005),
                    Text(spare.partNo,
                        style: TextStyle(
                            fontSize: sw * 0.028,
                            color: AppColors.textSecondary)),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Need: ${spare.required} ${spare.uom}',
                  style: TextStyle(
                      fontSize: sw * 0.029, color: AppColors.textSecondary)),
              SizedBox(height: sw * 0.005),
              Text('Stock: ${spare.inStock} ${spare.uom}',
                  style: TextStyle(
                      fontSize: sw * 0.031,
                      fontWeight: FontWeight.w700,
                      color: sufficient ? AppColors.success : AppColors.danger)),
            ]),
          ]),
          SizedBox(height: sw * 0.025),
          ProgressBar(
            value: pct,
            color: sufficient ? AppColors.success : AppColors.danger,
          ),
          if (!sufficient) ...[
            SizedBox(height: sw * 0.01),
            Text('${spare.gap} ${spare.uom} short — procurement needed',
                style: TextStyle(
                    fontSize: sw * 0.028,
                    color: AppColors.danger,
                    fontWeight: FontWeight.w500)),
          ],
        ]),
      ),
    );
  }
}

// ─── MR From Job Card Page ────────────────────────────────────────────────────
class _MRFromJobCardPage extends StatefulWidget {
  final String jobId;
  const _MRFromJobCardPage({required this.jobId});

  @override
  State<_MRFromJobCardPage> createState() => _MRFromJobCardPageState();
}

class _MRFromJobCardPageState extends State<_MRFromJobCardPage> {
  int _tab = 0;

  List<MaterialRequest> get _pending => SampleData.materialRequests
      .where((r) => r.status == 'pending' && r.jobRef == widget.jobId)
      .toList();

  List<MaterialRequest> get _responded => SampleData.materialRequests
      .where((r) => r.status == 'approved' && r.jobRef == widget.jobId)
      .toList();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(widget.jobId);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: buildTealAppBar(
        title: 'Material Request',
        showBack: true,
        context: context,
      ),
      body: Column(children: [
        // ── Toggle tabs ────────────────────────────────────────────────────
        Container(
          color: _teal,
          padding:
          EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.03),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Row(children: [
              _tabBtn('Pending', 0, sw),
              _tabBtn('Responses', 1, sw),
            ]),
          ),
        ),

        Expanded(
          child: _tab == 0
              ? _buildPending(sw)
              : _buildResponses(sw, spares),
        ),

        Container(
          color: Colors.white,
          padding: EdgeInsets.all(sw * 0.04),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MRCreatePage()),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _teal, foregroundColor: Colors.white),
              icon: Icon(Icons.add, size: sw * 0.045),
              label: Text('New Material Request',
                  style: TextStyle(fontSize: sw * 0.035)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _tabBtn(String label, int idx, double sw) {
    final active = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(sw * 0.01),
          padding: EdgeInsets.symmetric(vertical: sw * 0.025),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(sw * 0.02),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sw * 0.035,
              fontWeight: FontWeight.w700,
              color: active ? _teal : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPending(double sw) {
    if (_pending.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(sw * 0.08),
        child: Column(children: [
          Icon(Icons.inbox_outlined,
              size: sw * 0.15, color: AppColors.textHint),
          SizedBox(height: sw * 0.03),
          Text('No pending requests for ${widget.jobId}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: sw * 0.038,
                  color: AppColors.textSecondary)),
        ]),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(sw * 0.05),
      itemCount: _pending.length,
      separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
      itemBuilder: (_, i) => MRCard(
        mr: _pending[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MRDetailPage(mr: _pending[i])),
        ),
      ),
    );
  }

  Widget _buildResponses(double sw, List<SpareItem> spares) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(sw * 0.05),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SummaryStrip(spares: spares, sw: sw),
        SizedBox(height: sw * 0.04),
        Text('Component Stock Status',
            style: TextStyle(
                fontSize: sw * 0.042,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        SizedBox(height: sw * 0.03),
        ...spares.map((s) => Padding(
          padding: EdgeInsets.only(bottom: sw * 0.03),
          child: SpareStockCard(spare: s, sw: sw),
        )),
        if (_responded.isNotEmpty) ...[
          SizedBox(height: sw * 0.02),
          Text('Approved Requests',
              style: TextStyle(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          SizedBox(height: sw * 0.025),
          ..._responded.map((mr) => Padding(
            padding: EdgeInsets.only(bottom: sw * 0.025),
            child: MRResponseCard(
              mr: mr,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MRResponseDetailPage(mr: mr)),
              ),
            ),
          )),
        ],
        SizedBox(height: sw * 0.05),
      ]),
    );
  }
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