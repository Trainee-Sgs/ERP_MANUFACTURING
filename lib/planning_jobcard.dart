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

    return Scaffold(
      backgroundColor: AppColors.background,
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
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Title ──────────────────────────────────────────────────────────
          Text(job.productName,
              style: TextStyle(
                  fontSize: sw * 0.055,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          SizedBox(height: sw * 0.01),
          Text(job.id,
              style: TextStyle(
                  fontSize: sw * 0.035, color: AppColors.textSecondary)),
          SizedBox(height: sw * 0.05),

          // ── Job info card ──────────────────────────────────────────────────
          AppCard(
            color: AppColors.background,
            child: Column(children: [
              InfoRow(label: 'Plan Reference', value: job.planRef),
              InfoRow(label: 'Quantity', value: '${job.qty} units'),
              InfoRow(label: 'Assigned To', value: job.assignedTo),
              InfoRow(label: 'Machine', value: job.machine),
              InfoRow(
                  label: 'Start Date',
                  value:
                  '${job.startDate.day}/${job.startDate.month}/${job.startDate.year}'),
              InfoRow(
                  label: 'End Date',
                  value:
                  '${job.endDate.day}/${job.endDate.month}/${job.endDate.year}'),
            ]),
          ),
          SizedBox(height: sw * 0.05),

          // ── Operations ─────────────────────────────────────────────────────
          Text('Operations',
              style: TextStyle(
                  fontSize: sw * 0.042,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          SizedBox(height: sw * 0.03),
          _opRow('1', 'Cell Tabbing & Stringing', 'completed', job.assignedTo, sw),
          _opRow('2', 'Lamination', job.status, job.machine, sw),
          _opRow('3', 'Framing & Junction Box Fitting', 'pending', '—', sw),
          _opRow('4', 'Testing & Quality Check', 'pending', '—', sw),
          SizedBox(height: sw * 0.05),

          // ── Spares / Components needed ─────────────────────────────────────
          Row(children: [
            Expanded(
              child: Text('Spares & Components',
                  style: TextStyle(
                      fontSize: sw * 0.042,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
            Builder(builder: (_) {
              final shortCount = spares.where((s) => !s.isSufficient).length;
              if (shortCount == 0) return const SizedBox.shrink();
              return Container(
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
              );
            }),
          ]),
          SizedBox(height: sw * 0.03),

          ...spares.map((s) => Padding(
            padding: EdgeInsets.only(bottom: sw * 0.025),
            child: _SpareRow(spare: s, sw: sw),
          )),

          SizedBox(height: sw * 0.05),

          // ── Action buttons ─────────────────────────────────────────────────
          Row(children: [
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
                ),
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: _teal, foregroundColor: Colors.white),
                icon: Icon(Icons.play_circle_outline, size: sw * 0.04),
                label: Text('Update Status',
                    style: TextStyle(fontSize: sw * 0.03)),
              ),
            ),
          ]),
          SizedBox(height: sw * 0.05),
        ]),
      ),
    );
  }

  Widget _opRow(
      String num, String name, String status, String resource, double sw) =>
      Padding(
        padding: EdgeInsets.only(bottom: sw * 0.02),
        child: AppCard(
          child: Row(children: [
            Container(
              width: sw * 0.07,
              height: sw * 0.07,
              decoration: BoxDecoration(
                color: status == 'completed'
                    ? AppColors.successLight
                    : status == 'inprogress'
                    ? AppColors.inProgressLight
                    : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: status == 'completed'
                    ? Icon(Icons.check,
                    size: sw * 0.035, color: AppColors.success)
                    : Text(num,
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.w700,
                      color: status == 'inprogress'
                          ? AppColors.inProgress
                          : AppColors.textSecondary,
                    )),
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: sw * 0.032,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
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
    final pct = spare.required > 0
        ? (spare.inStock / spare.required).clamp(0.0, 1.0)
        : 1.0;

    return AppCard(
      color: const Color(0xFFF5F5F5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: sw * 0.085,
            height: sw * 0.085,
            decoration: BoxDecoration(
              color: sufficient ? AppColors.successLight : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(
              sufficient
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_outlined,
              color: sufficient ? AppColors.success : AppColors.danger,
              size: sw * 0.045,
            ),
          ),
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spare.name,
                      style: TextStyle(
                          fontSize: sw * 0.033,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text(spare.partNo,
                      style: TextStyle(
                          fontSize: sw * 0.027,
                          color: AppColors.textSecondary)),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Need: ${spare.required} ${spare.uom}',
                style: TextStyle(
                    fontSize: sw * 0.028, color: AppColors.textSecondary)),
            Text('Stock: ${spare.inStock} ${spare.uom}',
                style: TextStyle(
                    fontSize: sw * 0.03,
                    fontWeight: FontWeight.w700,
                    color: sufficient ? AppColors.success : AppColors.danger)),
          ]),
        ]),
        SizedBox(height: sw * 0.02),
        ProgressBar(
          value: pct,
          color: sufficient ? AppColors.success : AppColors.danger,
        ),
        if (!sufficient) ...[
          SizedBox(height: sw * 0.008),
          Text('${spare.gap} ${spare.uom} short — procurement needed',
              style: TextStyle(
                  fontSize: sw * 0.027,
                  color: AppColors.danger,
                  fontWeight: FontWeight.w500)),
        ],
      ]),
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
      backgroundColor: AppColors.background,
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

        // ── Content ────────────────────────────────────────────────────────
        Expanded(
          child: _tab == 0
              ? _buildPending(sw)
              : _buildResponses(sw, spares),
        ),

        // ── New request CTA ────────────────────────────────────────────────
        Container(
          color: AppColors.surface,
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

    return AppCard(
      onTap: onTap,
      color: const Color(0xFFF5F5F5), // ← was: hasShortage ? AppColors.dangerLight : AppColors.surface
      child: Column(children: [
        Row(children: [
          Container(
            width: sw * 0.105,
            height: sw * 0.105,
            decoration: BoxDecoration(
              color: AppColors.inProgressLight,
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Icon(Icons.assignment_outlined,
                color: AppColors.inProgress, size: sw * 0.055),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.productName,
                      style: TextStyle(
                          fontSize: sw * 0.035,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
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
        const Divider(color: AppColors.border, height: 1),
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
    );
  }
}