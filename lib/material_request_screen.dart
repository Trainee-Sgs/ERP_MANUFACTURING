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
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    )
        : null,
    automaticallyImplyLeading: false,
    title: Text(title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
        bg = AppColors.successLight; fg = AppColors.success; break;
      case 'inprogress':
        bg = AppColors.inProgressLight; fg = AppColors.inProgress; break;
      case 'pending':
        bg = AppColors.pendingLight; fg = AppColors.pending; break;
      default:
        bg = AppColors.border; fg = AppColors.textSecondary;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sw * 0.008),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(sw * 0.015)),
      child: Text(label,
          style: TextStyle(
              fontSize: sw * 0.028, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ─── Summary Strip (public) ───────────────────────────────────────────────────
class SummaryStrip extends StatelessWidget {
  final List<SpareItem> spares;
  final double sw;
  const SummaryStrip({super.key, required this.spares, required this.sw});

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
        _statBox('Shortage', '$shortage',
            shortage > 0 ? AppColors.danger : AppColors.success, sw),
      ]),
    );
  }

  Widget _divider(double sw) =>
      Container(width: 1, height: sw * 0.12, color: _teal.withOpacity(0.2));

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
  const SpareStockCard({super.key, required this.spare, required this.sw});

  @override
  Widget build(BuildContext context) {
    final sufficient = spare.isSufficient;

    return AppCard(
      color: sufficient ? AppColors.surface : AppColors.dangerLight,
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
              sufficient ? Icons.check_circle_outline : Icons.warning_amber_outlined,
              color: sufficient ? AppColors.success : AppColors.danger,
              size: sw * 0.05,
            ),
          ),
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(spare.name,
                  style: TextStyle(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text(spare.partNo,
                  style: TextStyle(
                      fontSize: sw * 0.028, color: AppColors.textSecondary)),
            ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.025, vertical: sw * 0.01),
            decoration: BoxDecoration(
              color: sufficient ? AppColors.successLight : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(sw * 0.015),
            ),
            child: Text(
              sufficient ? 'In Stock' : 'Short',
              style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w700,
                  color: sufficient ? AppColors.success : AppColors.danger),
            ),
          ),
        ]),
        SizedBox(height: sw * 0.03),
        const Divider(color: AppColors.border, height: 1),
        SizedBox(height: sw * 0.025),
        Row(children: [
          _statCol('Required', '${spare.required} ${spare.uom}',
              AppColors.textPrimary, sw),
          Container(width: 1, height: sw * 0.08, color: AppColors.border),
          _statCol('In Stock', '${spare.inStock} ${spare.uom}',
              sufficient ? AppColors.success : AppColors.danger, sw),
          Container(width: 1, height: sw * 0.08, color: AppColors.border),
          _statCol(
            'Gap',
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
                color: sufficient ? AppColors.success : AppColors.danger,
                fontWeight: FontWeight.w500),
          ),
        ],
      ]),
    );
  }

  Widget _statCol(String label, String val, Color valColor, double sw) =>
      Expanded(
        child: Column(children: [
          Text(label,
              style: TextStyle(
                  fontSize: sw * 0.028, color: AppColors.textSecondary)),
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

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hasShortage = mr.items.any((i) => i.available < i.required);

    return AppCard(
      onTap: onTap,
      color: hasShortage ? AppColors.dangerLight : AppColors.surface,
      child: Row(children: [
        Container(
          width: sw * 0.105,
          height: sw * 0.105,
          decoration: BoxDecoration(
            color: mr.status == 'approved'
                ? AppColors.successLight
                : AppColors.pendingLight,
            borderRadius: BorderRadius.circular(sw * 0.025),
          ),
          child: Icon(
            mr.status == 'approved'
                ? Icons.check_circle_outline
                : Icons.pending_outlined,
            color: mr.status == 'approved'
                ? AppColors.success
                : AppColors.pending,
            size: sw * 0.055,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${mr.id} · ${mr.jobRef}',
                style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text('${mr.items.length} items · By ${mr.requestedBy}',
                style: TextStyle(
                    fontSize: sw * 0.03, color: AppColors.textSecondary)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusBadge(
            label: mr.status == 'approved' ? 'Approved' : 'Pending',
            status: mr.status == 'approved' ? 'completed' : 'pending',
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
              child: Text('Stock Short',
                  style: TextStyle(
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger)),
            ),
          ],
        ]),
      ]),
    );
  }
}

// ─── MR Response Card (public) ────────────────────────────────────────────────
class MRResponseCard extends StatelessWidget {
  final MaterialRequest mr;
  final VoidCallback onTap;
  const MRResponseCard({super.key, required this.mr, required this.onTap});

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
            color: shortage ? AppColors.dangerLight : AppColors.successLight,
            borderRadius: BorderRadius.circular(sw * 0.025),
          ),
          child: Icon(
            shortage ? Icons.warning_amber_outlined : Icons.check_circle_outline,
            color: shortage ? AppColors.danger : AppColors.success,
            size: sw * 0.055,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${mr.id} · ${mr.jobRef}',
                style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            SizedBox(height: sw * 0.005),
            Text('${spares.length} components · By ${mr.requestedBy}',
                style: TextStyle(
                    fontSize: sw * 0.03, color: AppColors.textSecondary)),
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
          StatusBadge(label: 'Approved', status: 'completed'),
          SizedBox(height: sw * 0.01),
          Text('Tap to view stock',
              style: TextStyle(fontSize: sw * 0.027, color: AppColors.textHint)),
        ]),
      ]),
    );
  }
}

// ─── MR Detail Page (public) ──────────────────────────────────────────────────
class MRDetailPage extends StatelessWidget {
  final MaterialRequest mr;
  const MRDetailPage({super.key, required this.mr});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildTealAppBar(
        title: 'Material Request',
        showBack: true,
        context: context,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: Center(
              child: StatusBadge(
                label: mr.status == 'approved' ? 'Approved' : 'Pending',
                status: mr.status == 'approved' ? 'completed' : 'pending',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(mr.id,
              style: TextStyle(
                  fontSize: sw * 0.055,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          SizedBox(height: sw * 0.01),
          Text(mr.jobRef,
              style: TextStyle(
                  fontSize: sw * 0.035, color: AppColors.textSecondary)),
          SizedBox(height: sw * 0.05),
          AppCard(
            color: AppColors.background,
            child: Column(children: [
              InfoRow(label: 'Requested By', value: mr.requestedBy),
              InfoRow(label: 'Job Card', value: mr.jobRef),
              InfoRow(
                  label: 'Date',
                  value:
                  '${mr.requestDate.day}/${mr.requestDate.month}/${mr.requestDate.year}'),
            ]),
          ),
          SizedBox(height: sw * 0.05),
          Text('Requested Items',
              style: TextStyle(
                  fontSize: sw * 0.042,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          SizedBox(height: sw * 0.03),
          ...mr.items.map((item) {
            final sufficient = item.available >= item.required;
            return Padding(
              padding: EdgeInsets.only(bottom: sw * 0.025),
              child: AppCard(
                color: sufficient ? AppColors.surface : AppColors.dangerLight,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            color: sufficient
                                ? AppColors.success
                                : AppColors.danger,
                            size: sw * 0.05,
                          ),
                        ),
                        SizedBox(width: sw * 0.025),
                        Expanded(
                            child: Text(item.name,
                                style: TextStyle(
                                    fontSize: sw * 0.035,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary))),
                        Text(item.uom,
                            style: TextStyle(
                                fontSize: sw * 0.03,
                                color: AppColors.textSecondary)),
                      ]),
                      SizedBox(height: sw * 0.025),
                      Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Required',
                                    style: TextStyle(
                                        fontSize: sw * 0.028,
                                        color: AppColors.textSecondary)),
                                Text('${item.required}',
                                    style: TextStyle(
                                        fontSize: sw * 0.038,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary)),
                              ]),
                        ),
                        Container(
                            width: 1,
                            height: sw * 0.075,
                            color: AppColors.border),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Available',
                                    style: TextStyle(
                                        fontSize: sw * 0.028,
                                        color: AppColors.textSecondary)),
                                Text('${item.available}',
                                    style: TextStyle(
                                        fontSize: sw * 0.038,
                                        fontWeight: FontWeight.w800,
                                        color: sufficient
                                            ? AppColors.success
                                            : AppColors.danger)),
                              ]),
                        ),
                        Container(
                            width: 1,
                            height: sw * 0.075,
                            color: AppColors.border),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Gap',
                                    style: TextStyle(
                                        fontSize: sw * 0.028,
                                        color: AppColors.textSecondary)),
                                Text(
                                  sufficient
                                      ? '—'
                                      : '${(item.required - item.available).toStringAsFixed(0)} short',
                                  style: TextStyle(
                                      fontSize: sw * 0.032,
                                      fontWeight: FontWeight.w700,
                                      color: sufficient
                                          ? AppColors.textHint
                                          : AppColors.danger),
                                ),
                              ]),
                        ),
                      ]),
                    ]),
              ),
            );
          }),
          if (mr.status == 'pending') ...[
            SizedBox(height: sw * 0.05),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: Text('Reject',
                      style: TextStyle(fontSize: sw * 0.035)),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _teal, foregroundColor: Colors.white),
                  child: Text('Approve & Issue',
                      style: TextStyle(fontSize: sw * 0.032)),
                ),
              ),
            ]),
          ],
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

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(mr.jobRef);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildTealAppBar(
        title: 'Stock Response',
        showBack: true,
        context: context,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: Center(
              child: StatusBadge(label: 'Approved', status: 'completed'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(mr.id,
              style: TextStyle(
                  fontSize: sw * 0.055,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          SizedBox(height: sw * 0.01),
          Text('${mr.jobRef} · By ${mr.requestedBy}',
              style: TextStyle(
                  fontSize: sw * 0.035, color: AppColors.textSecondary)),
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
                label: Text('Back', style: TextStyle(fontSize: sw * 0.035)),
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
                    backgroundColor: _teal, foregroundColor: Colors.white),
                icon: Icon(Icons.check_circle_outline, size: sw * 0.04),
                label: Text('Issue Stock', style: TextStyle(fontSize: sw * 0.032)),
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
  const MRCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildTealAppBar(
        title: 'New Material Request',
        showBack: true,
        context: context,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AppDropdown(
            label: 'Job Card',
            items: [
              'JC-001 · Solar Panel 400W Mono',
              'JC-002 · Solar Panel 400W Mono',
              'JC-003 · Solar Street Light 60W',
            ],
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
  State<MaterialRequestScreen> createState() => _MaterialRequestScreenState();
}

class _MaterialRequestScreenState extends State<MaterialRequestScreen> {
  int _tab = 0;

  List<MaterialRequest> get _pending =>
      SampleData.materialRequests.where((r) => r.status == 'pending').toList();

  List<MaterialRequest> get _completed =>
      SampleData.materialRequests.where((r) => r.status == 'approved').toList();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Container(
          color: _teal,
          padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.03),
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
              ? _buildPendingList(sw)
              : _buildResponsesList(sw),
        ),
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

  Widget _buildPendingList(double sw) {
    if (_pending.isEmpty) {
      return Center(
        child: Text('No pending requests',
            style:
            TextStyle(color: AppColors.textSecondary, fontSize: sw * 0.04)),
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

  Widget _buildResponsesList(double sw) {
    if (_completed.isEmpty) {
      return Center(
        child: Text('No responses yet',
            style:
            TextStyle(color: AppColors.textSecondary, fontSize: sw * 0.04)),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(sw * 0.05),
      itemCount: _completed.length,
      separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
      itemBuilder: (_, i) => MRResponseCard(
        mr: _completed[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MRResponseDetailPage(mr: _completed[i])),
        ),
      ),
    );
  }
}