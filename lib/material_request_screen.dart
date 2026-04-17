import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';
import 'models.dart';

const _teal = Color(0xFF26A69A);

PreferredSizeWidget buildTealAppBar({
  required String title,
  List<Widget>? actions,
  bool showBack = true,
  BuildContext? context,
}) {
  return AppBar(
    backgroundColor: _teal,
    elevation: 0,
    leading: showBack && context != null
        ? IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded,
          color: Colors.white),
      onPressed: () => Navigator.pop(context),
    )
        : null,
    automaticallyImplyLeading: false,
    title: Text(title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700)),
    actions: actions,
  );
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label, status;
  const StatusBadge({super.key, required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    Color bg, fg;
    switch (status) {
      case 'completed':
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case 'inprogress':
        bg = AppColors.inProgressLight;
        fg = AppColors.inProgress;
        break;
      case 'pending':
        bg = AppColors.pendingLight;
        fg = AppColors.pending;
        break;
      default:
        bg = AppColors.border;
        fg = AppColors.textSecondary;
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.025, vertical: sw * 0.008),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(sw * 0.015)),
      child: Text(label,
          style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w700,
              color: fg)),
    );
  }
}

// ─── Summary Strip (public) ───────────────────────────────────────────────────
class SummaryStrip extends StatelessWidget {
  final List<SpareItem> spares;
  final double sw;
  const SummaryStrip(
      {super.key, required this.spares, required this.sw});

  @override
  Widget build(BuildContext context) {
    final total = spares.length;
    final available = spares.where((s) => s.isSufficient).length;
    final shortage = total - available;

    return Container(
      decoration: BoxDecoration(
        color: _teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: _teal.withOpacity(0.25)),
      ),
      child: Row(children: [
        _statBox('Total', '$total', _teal, sw),
        _divider(sw),
        _statBox('Available', '$available', AppColors.success, sw),
        _divider(sw),
        _statBox('Remaining', '$shortage',
            shortage > 0 ? AppColors.danger : AppColors.success, sw),
      ]),
    );
  }

  Widget _divider(double sw) => Container(
      width: 1, height: sw * 0.12, color: _teal.withOpacity(0.2));

  Widget _statBox(String label, String val, Color color, double sw) =>
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: sw * 0.03),
          child: Column(children: [
            Text(val,
                style: TextStyle(
                    fontSize: sw * 0.055,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: sw * 0.028,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      );
}

// ─── Spare Stock Card (public) ────────────────────────────────────────────────
class SpareStockCard extends StatelessWidget {
  final SpareItem spare;
  final double sw;
  const SpareStockCard(
      {super.key, required this.spare, required this.sw});

  @override
  Widget build(BuildContext context) {
    final sufficient = spare.isSufficient;

    return AppCard(
      color: sufficient ? AppColors.surface : AppColors.dangerLight,
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: sw * 0.09,
            height: sw * 0.09,
            decoration: BoxDecoration(
              color: sufficient
                  ? AppColors.successLight
                  : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(
              sufficient
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_outlined,
              color: sufficient ? AppColors.success : AppColors.danger,
              size: sw * 0.05,
            ),
          ),
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spare.name,
                      style: TextStyle(
                          fontSize: sw * 0.035,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text(spare.partNo,
                      style: TextStyle(
                          fontSize: sw * 0.028,
                          color: AppColors.textSecondary)),
                ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.025, vertical: sw * 0.01),
            decoration: BoxDecoration(
              color: sufficient
                  ? AppColors.successLight
                  : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(sw * 0.015),
            ),
            child: Text(
              sufficient ? 'Issue' : 'Short',
              style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w700,
                  color:
                  sufficient ? AppColors.success : AppColors.danger),
            ),
          ),
        ]),
        SizedBox(height: sw * 0.03),
        const Divider(color: AppColors.border, height: 1),
        SizedBox(height: sw * 0.025),
        Row(children: [
          _statCol('Required', '${spare.required} ${spare.uom}',
              AppColors.textPrimary, sw),
          Container(
              width: 1, height: sw * 0.08, color: AppColors.border),
          _statCol(
              'Issue',
              '${spare.inStock} ${spare.uom}',
              sufficient ? AppColors.success : AppColors.danger,
              sw),
          Container(
              width: 1, height: sw * 0.08, color: AppColors.border),
          _statCol(
            'Remaining',
            sufficient ? '—' : '${spare.gap} short',
            sufficient ? AppColors.textHint : AppColors.danger,
            sw,
          ),
        ]),
        if (spare.required > 0) ...[
          SizedBox(height: sw * 0.025),
          ProgressBar(
            value: (spare.inStock / spare.required).clamp(0.0, 1.0),
            color: sufficient ? AppColors.success : AppColors.danger,
          ),
          SizedBox(height: sw * 0.01),
          Text(
            sufficient
                ? 'Fully available'
                : '${((spare.inStock / spare.required) * 100).toStringAsFixed(0)}% available — need to procure ${spare.gap} ${spare.uom}',
            style: TextStyle(
                fontSize: sw * 0.028,
                color:
                sufficient ? AppColors.success : AppColors.danger,
                fontWeight: FontWeight.w500),
          ),
        ],
      ]),
    );
  }

  Widget _statCol(
      String label, String val, Color valColor, double sw) =>
      Expanded(
        child: Column(children: [
          Text(label,
              style: TextStyle(
                  fontSize: sw * 0.028,
                  color: AppColors.textSecondary)),
          SizedBox(height: sw * 0.005),
          Text(val,
              style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.w800,
                  color: valColor)),
        ]),
      );
}

// ─── MR Card (public) ─────────────────────────────────────────────────────────
class MRCard extends StatelessWidget {
  final MaterialRequest mr;
  final VoidCallback onTap;
  const MRCard({super.key, required this.mr, required this.onTap});

  bool get _isSteelFrame => mr.jobRef == 'JC-004';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hasShortage = mr.items.any((i) => i.available < i.required);
    final spares = sparesFor(mr.jobRef);

    return AppCard(
      onTap: onTap,
      color: hasShortage ? AppColors.dangerLight : AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: sw * 0.105,
            height: sw * 0.105,
            decoration: BoxDecoration(
              color: _isSteelFrame
                  ? const Color(0xFFE8F5E9)
                  : mr.status == 'approved'
                  ? AppColors.successLight
                  : AppColors.pendingLight,
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Icon(
              _isSteelFrame
                  ? Icons.architecture
                  : mr.status == 'approved'
                  ? Icons.check_circle_outline
                  : Icons.pending_outlined,
              color: _isSteelFrame
                  ? const Color(0xFF388E3C)
                  : mr.status == 'approved'
                  ? AppColors.success
                  : AppColors.pending,
              size: sw * 0.055,
            ),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${mr.id} · ${mr.jobRef}',
                      style: TextStyle(
                          fontSize: sw * 0.035,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text('${mr.items.length} items · By ${mr.requestedBy}',
                      style: TextStyle(
                          fontSize: sw * 0.03,
                          color: AppColors.textSecondary)),
                  if (_isSteelFrame)
                    Padding(
                      padding: EdgeInsets.only(top: sw * 0.006),
                      child: Text('Steel Frame Structure',
                          style: TextStyle(
                              fontSize: sw * 0.027,
                              color: const Color(0xFF388E3C),
                              fontWeight: FontWeight.w600)),
                    ),
                ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusBadge(
              label: mr.status == 'approved' ? 'Approved' : 'Pending',
              status:
              mr.status == 'approved' ? 'completed' : 'pending',
            ),
            if (hasShortage) ...[
              SizedBox(height: sw * 0.01),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.02, vertical: sw * 0.008),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(sw * 0.015),
                ),
              ),
            ],
          ]),
        ]),

        // ── Component requirement summary ──────────────────────────────────
        SizedBox(height: sw * 0.05),
      ]),
    );
  }
}

// ─── MR Response Card (public) ────────────────────────────────────────────────
class MRResponseCard extends StatelessWidget {
  final MaterialRequest mr;
  final VoidCallback onTap;
  const MRResponseCard(
      {super.key, required this.mr, required this.onTap});

  bool get _isSteelFrame => mr.jobRef == 'JC-004';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(mr.jobRef);
    final shortage = spares.any((s) => !s.isSufficient);

    return AppCard(
      onTap: onTap,
      color: shortage ? AppColors.dangerLight : AppColors.surface,
      child: Row(children: [
        Container(
          width: sw * 0.105,
          height: sw * 0.105,
          decoration: BoxDecoration(
            color: _isSteelFrame
                ? const Color(0xFFE8F5E9)
                : shortage
                ? AppColors.dangerLight
                : AppColors.successLight,
            borderRadius: BorderRadius.circular(sw * 0.025),
          ),
          child: Icon(
            _isSteelFrame
                ? Icons.architecture
                : shortage
                ? Icons.warning_amber_outlined
                : Icons.check_circle_outline,
            color: _isSteelFrame
                ? const Color(0xFF388E3C)
                : shortage
                ? AppColors.danger
                : AppColors.success,
            size: sw * 0.055,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${mr.id} · ${mr.jobRef}',
                    style: TextStyle(
                        fontSize: sw * 0.035,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                SizedBox(height: sw * 0.005),
                Text(
                    '${spares.length} components · By ${mr.requestedBy}',
                    style: TextStyle(
                        fontSize: sw * 0.03,
                        color: AppColors.textSecondary)),
                if (_isSteelFrame)
                  Padding(
                    padding: EdgeInsets.only(top: sw * 0.006),
                    child: Text('Steel Frame Structure',
                        style: TextStyle(
                            fontSize: sw * 0.027,
                            color: const Color(0xFF388E3C),
                            fontWeight: FontWeight.w600)),
                  ),
                if (shortage) ...[
                  SizedBox(height: sw * 0.01),
                  Text(
                    '${spares.where((s) => !s.isSufficient).length} item(s) short',
                    style: TextStyle(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger),
                  ),
                ],
              ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusBadge(label: 'Issued', status: 'completed'),
          SizedBox(height: sw * 0.01),
          Text('Tap to view stock',
              style: TextStyle(
                  fontSize: sw * 0.027, color: AppColors.textHint)),
        ]),
      ]),
    );
  }
}

// ─── MR Detail Page (public) ──────────────────────────────────────────────────
class MRDetailPage extends StatelessWidget {
  final MaterialRequest mr;
  const MRDetailPage({super.key, required this.mr});

  bool get _isSteelFrame => mr.jobRef == 'JC-004';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(mr.jobRef);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildTealAppBar(
        title: 'Intent Request Detail',
        showBack: true,
        context: context,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: Center(
              child: StatusBadge(
                label: mr.status == 'approved' ? 'Approved' : 'Pending',
                status:
                mr.status == 'approved' ? 'completed' : 'pending',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Steel Frame banner ─────────────────────────────────────
              if (_isSteelFrame)
                Container(
                  margin: EdgeInsets.only(bottom: sw * 0.04),
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    border: Border.all(
                        color: const Color(0xFF388E3C).withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: EdgeInsets.all(sw * 0.025),
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFF388E3C).withOpacity(0.15),
                        borderRadius:
                        BorderRadius.circular(sw * 0.02),
                      ),
                      child: Icon(Icons.architecture,
                          color: const Color(0xFF388E3C),
                          size: sw * 0.05),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Steel Frame Structure',
                                style: TextStyle(
                                    fontSize: sw * 0.035,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF388E3C))),
                            Text('JC-004 · Fabrication Job',
                                style: TextStyle(
                                    fontSize: sw * 0.028,
                                    color: AppColors.textSecondary)),
                          ]),
                    ),
                  ]),
                ),

              Text(mr.id,
                  style: TextStyle(
                      fontSize: sw * 0.055,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              SizedBox(height: sw * 0.01),
              Text(mr.jobRef,
                  style: TextStyle(
                      fontSize: sw * 0.035,
                      color: AppColors.textSecondary)),
              SizedBox(height: sw * 0.05),

              AppCard(
                color: AppColors.background,
                child: Column(children: [
                  InfoRow(
                      label: 'Requested By',
                      value: mr.requestedBy),
                  InfoRow(label: 'Job Card', value: mr.jobRef),
                  InfoRow(
                      label: 'Date',
                      value:
                      '${mr.requestDate.day}/${mr.requestDate.month}/${mr.requestDate.year}'),
                ]),
              ),

              SizedBox(height: sw * 0.04),

              // ── Component Requirement Summary ──────────────────────────
              Row(children: [
                Icon(Icons.inventory_2_outlined,
                    color: _teal, size: sw * 0.045),
                SizedBox(width: sw * 0.02),
                Text('Components Required (${spares.length} total)',
                    style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ]),
              SizedBox(height: sw * 0.02),
              SummaryStrip(spares: spares, sw: sw),
              SizedBox(height: sw * 0.03),

              // Inline component requirement table
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(sw * 0.025),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04, vertical: sw * 0.025),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(children: [
                      Expanded(
                        flex: 5,
                        child: Text('COMPONENT',
                            style: TextStyle(
                                fontSize: sw * 0.026,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.4)),
                      ),
                      SizedBox(
                        width: sw * 0.22,
                        child: Text('REQUIRED',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: sw * 0.026,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.4)),
                      ),
                    ]),
                  ),
                  ...spares.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final s = entry.value;
                    final ok = s.isSufficient;
                    final isLast = idx == spares.length - 1;
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04, vertical: sw * 0.03),
                      decoration: BoxDecoration(
                        color: idx % 2 == 0
                            ? Colors.white
                            : const Color(0xFFFAFAFA),
                        borderRadius: isLast
                            ? const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        )
                            : null,
                        border: isLast
                            ? null
                            : const Border(
                            bottom: BorderSide(
                                color: Color(0xFFF0F0F0), width: 0.8)),
                      ),
                      child: Row(children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Icon(
                                    ok
                                        ? Icons.check_circle_outline
                                        : Icons.warning_amber_outlined,
                                    size: sw * 0.033,
                                    color: ok
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                  SizedBox(width: sw * 0.01),
                                  Expanded(
                                    child: Text(s.name,
                                        style: TextStyle(
                                            fontSize: sw * 0.034,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary)),
                                  ),
                                ]),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: sw * 0.043),
                                  child: Text(s.partNo,
                                      style: TextStyle(
                                          fontSize: sw * 0.032,
                                          color: AppColors.textSecondary)),
                                ),
                              ]),
                        ),
                        SizedBox(
                          width: sw * 0.24,
                          child: Text(
                            '${s.required} ${s.uom}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: sw * 0.034,
                                fontWeight: FontWeight.w800,
                                color: _teal),
                          ),
                        ),

                      ]),
                    );
                  }),
                ]),
              ),
              SizedBox(height: sw * 0.05),
            ]),
      ),
    );
  }
}

// ─── MR Response Detail Page (public) ────────────────────────────────────────
class MRResponseDetailPage extends StatelessWidget {
  final MaterialRequest mr;
  const MRResponseDetailPage({super.key, required this.mr});

  bool get _isSteelFrame => mr.jobRef == 'JC-004';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(mr.jobRef);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildTealAppBar(
        title: _isSteelFrame
            ? 'Steel Frame – Issue Response'
            : 'Issue Response',
        showBack: true,
        context: context,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: Center(
              child:
              StatusBadge(label: 'Issued', status: 'completed'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Steel Frame banner ─────────────────────────────────────
              if (_isSteelFrame)
                Container(
                  margin: EdgeInsets.only(bottom: sw * 0.04),
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    border: Border.all(
                        color: const Color(0xFF388E3C).withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: EdgeInsets.all(sw * 0.025),
                      decoration: BoxDecoration(
                        color: const Color(0xFF388E3C).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(sw * 0.02),
                      ),
                      child: Icon(Icons.architecture,
                          color: const Color(0xFF388E3C),
                          size: sw * 0.05),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Steel Frame Structure',
                                style: TextStyle(
                                    fontSize: sw * 0.035,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF388E3C))),
                            Text(
                                '${spares.where((s) => !s.isSufficient).length} component(s) need procurement',
                                style: TextStyle(
                                    fontSize: sw * 0.028,
                                    color: AppColors.textSecondary)),
                          ]),
                    ),
                  ]),
                ),

              Text(mr.id,
                  style: TextStyle(
                      fontSize: sw * 0.055,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              SizedBox(height: sw * 0.01),
              Text('${mr.jobRef} · By ${mr.requestedBy}',
                  style: TextStyle(
                      fontSize: sw * 0.035,
                      color: AppColors.textSecondary)),
              SizedBox(height: sw * 0.04),
              SummaryStrip(spares: spares, sw: sw),
              SizedBox(height: sw * 0.05),
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
              SizedBox(height: sw * 0.03),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, size: sw * 0.04),
                    label: Text('Back',
                        style: TextStyle(fontSize: sw * 0.035)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _teal,
                      side: const BorderSide(color: _teal),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white),
                    icon: Icon(Icons.check_circle_outline,
                        size: sw * 0.04),
                    label: Text('Issue Stock',
                        style: TextStyle(fontSize: sw * 0.032)),
                  ),
                ),
              ]),
              SizedBox(height: sw * 0.05),
            ]),
      ),
    );
  }
}

// ─── MR Create Page (public) ──────────────────────────────────────────────────
class MRCreatePage extends StatelessWidget {
  final String? preselectedJobId;
  const MRCreatePage({super.key, this.preselectedJobId});

  static const _jobItems = [
    'JC-001 · Solar Panel 400W Mono',
    'JC-002 · Solar Panel 400W Mono',
    'JC-003 · Solar Street Light 60W',
    'JC-004 · Steel Frame Structure',
  ];

  String? get _initialValue {
    if (preselectedJobId == null) return null;
    try {
      return _jobItems
          .firstWhere((e) => e.startsWith(preselectedJobId!));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isSteelFrame = preselectedJobId == 'JC-004';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildTealAppBar(
        title: 'New Intent Request',
        showBack: true,
        context: context,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (isSteelFrame)
            Container(
              margin: EdgeInsets.only(bottom: sw * 0.04),
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(sw * 0.03),
                border: Border.all(
                    color: const Color(0xFF388E3C).withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(Icons.architecture,
                    color: const Color(0xFF388E3C), size: sw * 0.05),
                SizedBox(width: sw * 0.025),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Steel Frame Structure – JC-004',
                            style: TextStyle(
                                fontSize: sw * 0.033,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF388E3C))),
                        Text(
                            'Materials will be auto-fetched for steel fabrication',
                            style: TextStyle(
                                fontSize: sw * 0.027,
                                color: AppColors.textSecondary)),
                      ]),
                ),
              ]),
            ),

          AppDropdown(
            label: 'Job Card',
            items: _jobItems,
            initialValue: _initialValue,
            onChanged: _noop,
          ),
          SizedBox(height: sw * 0.035),
          const AppTextField(
              label: 'Requested By',
              hint: 'Your name',
              prefixIcon: Icons.person_outline),
          SizedBox(height: sw * 0.035),
          const AppTextField(
              label: 'Notes',
              hint: 'Any special instructions...',
              maxLines: 2),
          SizedBox(height: sw * 0.05),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _teal, foregroundColor: Colors.white),
              child: Text('Create & Auto-fetch Materials',
                  style: TextStyle(fontSize: sw * 0.035)),
            ),
          ),
        ]),
      ),
    );
  }

  static void _noop(dynamic _) {}
}

// ─── Material Request Screen ──────────────────────────────────────────────────
class MaterialRequestScreen extends StatefulWidget {
  const MaterialRequestScreen({super.key});

  @override
  State<MaterialRequestScreen> createState() =>
      _MaterialRequestScreenState();
}

class _MaterialRequestScreenState extends State<MaterialRequestScreen> {
  int _tab = 0;

  List<MaterialRequest> get _intentRequests =>
      SampleData.materialRequests
          .where((r) => r.status == 'pending')
          .toList();

  List<MaterialRequest> get _issued =>
      SampleData.materialRequests
          .where((r) => r.status == 'approved')
          .toList();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
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
              _tabBtn('Intent Request', 0, sw),
              _tabBtn('Intent Issue', 1, sw),
            ]),
          ),
        ),
        Expanded(
          child: _tab == 0
              ? _buildIntentRequestList(sw)
              : _buildIssueList(sw),
        ),
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.all(sw * 0.04),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MRCreatePage()),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _teal, foregroundColor: Colors.white),
              icon: Icon(Icons.add, size: sw * 0.045),
              label: Text('New Intent Request',
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
              fontSize: sw * 0.033,
              fontWeight: FontWeight.w700,
              color: active ? _teal : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntentRequestList(double sw) {
    if (_intentRequests.isEmpty) {
      return Center(
        child: Text('No intent requests',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: sw * 0.04)),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(sw * 0.05),
      itemCount: _intentRequests.length,
      separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
      itemBuilder: (_, i) => MRCard(
        mr: _intentRequests[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MRDetailPage(mr: _intentRequests[i])),
        ),
      ),
    );
  }

  Widget _buildIssueList(double sw) {
    if (_issued.isEmpty) {
      return Center(
        child: Text('No issued requests',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: sw * 0.04)),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(sw * 0.05),
      itemCount: _issued.length,
      separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
      itemBuilder: (_, i) => MRResponseCard(
        mr: _issued[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  MRResponseDetailPage(mr: _issued[i])),
        ),
      ),
    );
  }
}