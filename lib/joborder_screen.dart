import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _teal = Color(0xFF26A69A);
const _tealLight = Color(0xFFE0F2F1);
const _tealDark = Color(0xFF00695C);
const _amber = Color(0xFFF57F17);
const _amberLight = Color(0xFFFFF8E1);

// ─────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────

class ProductSplit {
  String label;
  int qty;
  String priority;
  DateTime? deadline;

  ProductSplit({
    this.label = '',
    this.qty = 0,
    this.priority = 'High',
    this.deadline,
  });
}

class ProductPlan {
  List<ProductSplit> splits;
  bool done;
  ProductPlan() : splits = [], done = false;
  int get planned => splits.fold(0, (a, s) => a + s.qty);

  DateTime? get earliestDeadline {
    final dates = splits
        .where((s) => s.deadline != null)
        .map((s) => s.deadline!)
        .toList();
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.first;
  }
}

class OrderProduct {
  String name;
  int qty;
  String productId;
  OrderProduct({required this.name, required this.qty, this.productId = ''});
}

class JobOrder {
  final String id;
  final String customer;
  final DateTime deliveryDate;
  String status;
  final List<OrderProduct> products;
  final List<ProductPlan> planning;

  JobOrder({
    required this.id,
    required this.customer,
    required this.deliveryDate,
    this.status = 'pending',
    required this.products,
  }) : planning = List.generate(products.length, (_) => ProductPlan());

  int get totalQty => products.fold(0, (a, p) => a + p.qty);
  int get plannedCount => planning.where((p) => p.done).length;
}

// ─────────────────────────────────────────
// SHARED APPBAR HELPER
// ─────────────────────────────────────────

PreferredSizeWidget _buildTealAppBar({
  required String title,
  String? subtitle,
  List<Widget>? actions,
  bool showBack = true,
  BuildContext? context,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    backgroundColor: _teal,
    elevation: 0,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: _teal,
      statusBarIconBrightness: Brightness.light,
    ),
    leading: showBack && context != null
        ? IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    )
        : null,
    automaticallyImplyLeading: false,
    title: subtitle != null
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        Text(subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    )
        : Text(title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700)),
    actions: actions,
    bottom: bottom,
  );
}

// ─────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool light;
  const _StatusBadge({required this.status, this.light = false});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    final bgColor = light
        ? Colors.white24
        : (isActive ? Colors.green.shade100 : Colors.orange.shade100);
    final textColor = light
        ? Colors.white
        : (isActive ? Colors.green.shade700 : Colors.orange.shade700);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// SUMMARY CHIP
// ─────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label, value;
  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _teal)),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// ORDER SUMMARY BAR
// ─────────────────────────────────────────

class _OrderSummaryBar extends StatelessWidget {
  final List<JobOrder> orders;
  const _OrderSummaryBar({required this.orders});

  @override
  Widget build(BuildContext context) {
    final total = orders.length;
    final active = orders.where((o) => o.status == 'active').length;
    final pending = orders.where((o) => o.status == 'pending').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Total', value: '$total', color: _teal),
          _DividerLine(),
          _StatItem(
              label: 'Active', value: '$active', color: Colors.green.shade600),
          _DividerLine(),
          _StatItem(
              label: 'Pending',
              value: '$pending',
              color: Colors.orange.shade600),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 28, width: 1, color: Colors.grey.shade200);
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: color)),
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
    ],
  );
}

// ─────────────────────────────────────────
// LEVEL 1 — JOB ORDER LIST
// ─────────────────────────────────────────

class JobOrderScreen extends StatefulWidget {
  const JobOrderScreen({super.key});
  @override
  State<JobOrderScreen> createState() => _JobOrderScreenState();
}

class _JobOrderScreenState extends State<JobOrderScreen> {
  final List<JobOrder> _orders = [
    JobOrder(
      id: 'JO-001',
      customer: 'Rajan Industries',
      status: 'active',
      deliveryDate: DateTime(2026, 4, 25),
      products: [
        OrderProduct(name: 'Steel Frame', qty: 100, productId: 'PRD-0001'),
        OrderProduct(name: 'Bolt Set', qty: 500, productId: 'PRD-0002'),
      ],
    ),
    JobOrder(
      id: 'JO-002',
      customer: 'Tamil Tech Pvt Ltd',
      status: 'pending',
      deliveryDate: DateTime(2026, 4, 30),
      products: [
        OrderProduct(name: 'Control Panel', qty: 40, productId: 'PRD-0003'),
        OrderProduct(name: 'Wire Harness', qty: 120, productId: 'PRD-0004'),
      ],
    ),
  ];

  String _initials(String name) =>
      name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _OrderSummaryBar(orders: _orders),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
              itemCount: _orders.length,
              itemBuilder: (ctx, idx) {
                final order = _orders[idx];
                return _CustomerNameCard(
                  order: order,
                  initials: _initials(order.customer),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _ProductListScreen(
                          order: order,
                          initials: _initials(order.customer),
                          onRefresh: () => setState(() {}),
                        ),
                      ),
                    );
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Order',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () async {
          final newOrder = await Navigator.push<JobOrder>(
            context,
            MaterialPageRoute(builder: (_) => const CreateJobOrderScreen()),
          );
          if (newOrder != null) setState(() => _orders.add(newOrder));
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// CUSTOMER NAME CARD
// ─────────────────────────────────────────

class _CustomerNameCard extends StatelessWidget {
  final JobOrder order;
  final String initials;
  final VoidCallback onTap;

  const _CustomerNameCard({
    required this.order,
    required this.initials,
    required this.onTap,
  });

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
              const BoxDecoration(color: _tealLight, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _tealDark),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.customer,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined,
                          size: 12, color: _teal),
                      const SizedBox(width: 4),
                      Text(
                        'Delivery: ${_fmt(order.deliveryDate)}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: _tealDark,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (order.plannedCount > 0) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: order.plannedCount / order.products.length,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(_teal),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.plannedCount}/${order.products.length} planned',
                      style: const TextStyle(fontSize: 10, color: _teal),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: order.status),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// LEVEL 2 — PRODUCT LIST
// ─────────────────────────────────────────

class _ProductListScreen extends StatefulWidget {
  final JobOrder order;
  final String initials;
  final VoidCallback onRefresh;

  const _ProductListScreen({
    required this.order,
    required this.initials,
    required this.onRefresh,
  });

  @override
  State<_ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<_ProductListScreen> {
  JobOrder get order => widget.order;

  int get _completedCount => order.planning.where((p) => p.done).length;
  int get _pendingCount => order.products.length - _completedCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildTealAppBar(
        title: order.customer,
        subtitle: order.id,
        showBack: true,
        context: context,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: _StatusBadge(status: order.status, light: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: _teal.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _SummaryChip(
                    label: 'Total Products',
                    value: '${order.products.length}'),
                const SizedBox(width: 8),
                _SummaryChip(label: 'Completed', value: '$_completedCount'),
                const SizedBox(width: 8),
                _SummaryChip(label: 'Pending', value: '$_pendingCount'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: order.products.length,
              itemBuilder: (ctx, i) => _ProductCard(
                product: order.products[i],
                plan: order.planning[i],
                productIndex: i,
                onTapPlanning: () => _openPlanning(i),
                isLast: i == order.products.length - 1,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: _addProduct,
      ),
    );
  }

  void _openPlanning(int prodIdx) async {
    final plan = order.planning[prodIdx];
    final product = order.products[prodIdx];
    final available =
    product.qty - plan.planned > 0 ? product.qty - plan.planned : product.qty;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductionPlanningFormScreen(
          order: order,
          prodIdx: prodIdx,
          availableQty: available,
          onCreated: (split) {
            setState(() {
              plan.splits.add(split);
              plan.done = true;
            });
            widget.onRefresh();
          },
        ),
      ),
    );
    setState(() {});
  }

  void _addProduct() async {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final idCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Product',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(
                labelText: 'Product ID',
                hintText: 'e.g. PRD-0005',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'e.g. Steel Rod',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity *',
                hintText: 'e.g. 100',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _teal),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
              if (name.isEmpty || qty <= 0) return;
              setState(() {
                final newIdx = order.products.length;
                order.products.add(OrderProduct(
                  name: name,
                  qty: qty,
                  productId: idCtrl.text.trim().isEmpty
                      ? 'PRD-${(newIdx + 1).toString().padLeft(4, '0')}'
                      : idCtrl.text.trim(),
                ));
                order.planning.add(ProductPlan());
              });
              widget.onRefresh();
              Navigator.pop(ctx);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// PRODUCT CARD
// ─────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final OrderProduct product;
  final ProductPlan plan;
  final VoidCallback onTapPlanning;
  final bool isLast;
  final int productIndex;

  const _ProductCard({
    required this.product,
    required this.plan,
    required this.onTapPlanning,
    required this.productIndex,
    this.isLast = false,
  });

  String get _displayId =>
      product.productId.isNotEmpty
          ? product.productId
          : 'PRD-${(productIndex + 1).toString().padLeft(4, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: plan.done ? _teal : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.tag, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _displayId,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('Qty: ',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          '${product.qty}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onTapPlanning,
              child: Container(
                width: 88,
                decoration: BoxDecoration(
                  color: plan.done
                      ? const Color(0xFFF1FAF9)
                      : const Color(0xFFF9F9F9),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  border:
                  const Border(left: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: plan.done ? _tealLight : _teal,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        plan.done ? Icons.check : Icons.event_note_outlined,
                        size: 18,
                        color: plan.done ? _tealDark : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      plan.done ? 'Re-plan' : 'Planning',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: plan.done ? _tealDark : _teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// CREATE JOB ORDER SCREEN
// ─────────────────────────────────────────

class CreateJobOrderScreen extends StatefulWidget {
  const CreateJobOrderScreen({super.key});

  @override
  State<CreateJobOrderScreen> createState() => _CreateJobOrderScreenState();
}

class _CreateJobOrderScreenState extends State<CreateJobOrderScreen> {
  final _idCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  DateTime? _deliveryDate;
  String _status = 'pending';
  final List<OrderProduct> _products = [];

  final _prodNameCtrl = TextEditingController();
  final _prodQtyCtrl = TextEditingController();
  final _prodIdCtrl = TextEditingController();

  bool get _canSave =>
      _idCtrl.text.trim().isNotEmpty &&
          _customerCtrl.text.trim().isNotEmpty &&
          _products.isNotEmpty &&
          _deliveryDate != null;

  void _addProduct() {
    final name = _prodNameCtrl.text.trim();
    final qty = int.tryParse(_prodQtyCtrl.text.trim()) ?? 0;
    if (name.isEmpty || qty <= 0) return;
    final id = _prodIdCtrl.text.trim().isEmpty
        ? 'PRD-${(_products.length + 1).toString().padLeft(4, '0')}'
        : _prodIdCtrl.text.trim();
    setState(() {
      _products.add(OrderProduct(name: name, qty: qty, productId: id));
      _prodNameCtrl.clear();
      _prodQtyCtrl.clear();
      _prodIdCtrl.clear();
    });
  }

  void _removeProduct(int i) => setState(() => _products.removeAt(i));

  Future<void> _pickDeliveryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _teal)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deliveryDate = picked);
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _save() {
    if (!_canSave) return;
    Navigator.pop(
      context,
      JobOrder(
        id: _idCtrl.text.trim(),
        customer: _customerCtrl.text.trim(),
        deliveryDate: _deliveryDate!,
        status: _status,
        products: List.from(_products),
      ),
    );
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _customerCtrl.dispose();
    _prodNameCtrl.dispose();
    _prodQtyCtrl.dispose();
    _prodIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: _buildTealAppBar(
        title: 'New Job Order',
        showBack: true,
        context: context,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 30),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(label: 'Order Details'),
                const SizedBox(height: 12),
                _FormRow(children: [
                  _Editable(
                    label: 'ORDER ID *',
                    child: _PPTextField(
                        controller: _idCtrl, hint: 'e.g. JO-003'),
                  ),
                  _Editable(
                    label: 'STATUS',
                    child: _PPDropdown(
                      hint: '-- Select --',
                      value: _status,
                      items: const ['pending', 'active', 'completed'],
                      onChanged: (v) =>
                          setState(() => _status = v ?? 'pending'),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                _Editable(
                  label: 'CUSTOMER NAME *',
                  child: _PPTextField(
                      controller: _customerCtrl, hint: 'Customer name...'),
                ),
                const SizedBox(height: 10),
                _Editable(
                  label: 'DELIVERY DATE *',
                  child: GestureDetector(
                    onTap: _pickDeliveryDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 15,
                            color:
                            _deliveryDate != null ? _teal : Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _deliveryDate == null
                              ? 'Select delivery date'
                              : _fmtDate(_deliveryDate!),
                          style: TextStyle(
                              fontSize: 13,
                              color: _deliveryDate == null
                                  ? Colors.grey
                                  : Colors.black87),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(label: 'Products'),
                const SizedBox(height: 12),
                _PPTextField(
                    controller: _prodIdCtrl,
                    hint: 'Product ID (optional)...'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _PPTextField(
                          controller: _prodNameCtrl,
                          hint: 'Product name...'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _prodQtyCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Qty',
                          hintStyle: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF4F6F8),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 11),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                              BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide:
                              BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: const BorderSide(
                                  color: _teal, width: 1.5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _addProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7)),
                        ),
                        child: const Icon(Icons.add, size: 20),
                      ),
                    ),
                  ],
                ),
                if (_products.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ..._products.asMap().entries.map((e) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _tealLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border:
                      Border.all(color: _teal.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                              color: _teal, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.value.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87)),
                              Text(e.value.productId,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _teal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Qty: ${e.value.qty}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: _tealDark,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeProduct(e.key),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _canSave ? _save : null,
                icon: const Icon(Icons.save_outlined, size: 17),
                label: const Text('Create Order',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _canSave ? _teal : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BOM DATA MODELS
// ─────────────────────────────────────────

class BomItem {
  final String itemCode;
  final String itemName;
  final int qtyPerUnit;
  final int stock;

  const BomItem({
    required this.itemCode,
    required this.itemName,
    required this.qtyPerUnit,
    required this.stock,
  });
}

class BomData {
  final String bomId;
  final String bomLabel;
  final List<BomItem> items;

  const BomData({
    required this.bomId,
    required this.bomLabel,
    required this.items,
  });
}

const List<BomData> kBomRegistry = [
  BomData(
    bomId: '1',
    bomLabel: 'BOM-001 · Steel Frame Assembly',
    items: [
      BomItem(
          itemCode: 'SFA-0001',
          itemName: 'Steel Rod 20mm',
          qtyPerUnit: 10,
          stock: 45),
      BomItem(
          itemCode: 'SFA-0002',
          itemName: 'Corner Bracket',
          qtyPerUnit: 4,
          stock: 20),
      BomItem(
          itemCode: 'SFA-0003',
          itemName: 'Welding Wire 1kg',
          qtyPerUnit: 2,
          stock: 8),
    ],
  ),
  BomData(
    bomId: '2',
    bomLabel: 'BOM-002 · Bolt Set Pack',
    items: [
      BomItem(
          itemCode: 'BSP-0001',
          itemName: 'M8 Bolt x50',
          qtyPerUnit: 50,
          stock: 300),
      BomItem(
          itemCode: 'BSP-0002',
          itemName: 'M8 Nut x50',
          qtyPerUnit: 50,
          stock: 280),
      BomItem(
          itemCode: 'BSP-0003',
          itemName: 'M8 Washer x50',
          qtyPerUnit: 50,
          stock: 500),
    ],
  ),
  BomData(
    bomId: '3',
    bomLabel: 'BOM-003 · Control Panel Unit',
    items: [
      BomItem(
          itemCode: 'CPU-0001',
          itemName: 'MCB 32A',
          qtyPerUnit: 2,
          stock: 15),
      BomItem(
          itemCode: 'CPU-0002',
          itemName: 'RCCB 63A',
          qtyPerUnit: 1,
          stock: 4),
      BomItem(
          itemCode: 'CPU-0003',
          itemName: 'DIN Rail 35mm',
          qtyPerUnit: 3,
          stock: 20),
    ],
  ),
  BomData(
    bomId: '4',
    bomLabel: 'BOM-004 · Wire Harness Kit',
    items: [
      BomItem(
          itemCode: 'WHK-0001',
          itemName: 'DING DONG BELL (GALAXY)',
          qtyPerUnit: 12,
          stock: 0),
      BomItem(
          itemCode: 'WHK-0002',
          itemName: '8M-S METAL BOX',
          qtyPerUnit: 12,
          stock: 178),
    ],
  ),
];

BomData? _bomForLabel(String label) {
  try {
    return kBomRegistry.firstWhere((b) => b.bomLabel == label);
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────
// BOM AUTO-MAP BY PRODUCT INDEX
// ─────────────────────────────────────────

BomData? _autoMapBom(int prodIdx, List<OrderProduct> products) {
  final pid = products[prodIdx].productId.toUpperCase();
  if (pid == 'PRD-0001') return kBomRegistry[0];
  if (pid == 'PRD-0002') return kBomRegistry[1];
  if (pid == 'PRD-0003') return kBomRegistry[2];
  if (pid == 'PRD-0004') return kBomRegistry[3];
  if (prodIdx == 0) return kBomRegistry[0];
  return null;
}

// ─────────────────────────────────────────
// BOM PICKER BOTTOM SHEET
// ─────────────────────────────────────────

Future<BomData?> _showBomPicker(BuildContext context) async {
  return showModalBottomSheet<BomData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BomPickerSheet(),
  );
}

class _BomPickerSheet extends StatefulWidget {
  const _BomPickerSheet();

  @override
  State<_BomPickerSheet> createState() => _BomPickerSheetState();
}

class _BomPickerSheetState extends State<_BomPickerSheet> {
  String _search = '';

  List<BomData> get _filtered => kBomRegistry
      .where((b) =>
  b.bomLabel.toLowerCase().contains(_search.toLowerCase()) ||
      b.items.any((i) =>
      i.itemName.toLowerCase().contains(_search.toLowerCase()) ||
          i.itemCode.toLowerCase().contains(_search.toLowerCase())))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.list_alt_outlined, color: _teal, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Select BOM',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child:
                    const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search BOM or item...',
                hintStyle:
                const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon:
                const Icon(Icons.search, size: 18, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF4F6F8),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: _teal, width: 1.5)),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Text(
                'No BOM found',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 14),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final bom = _filtered[i];
                return _BomPickerCard(
                  bom: bom,
                  onTap: () => Navigator.pop(context, bom),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BomPickerCard extends StatelessWidget {
  final BomData bom;
  final VoidCallback onTap;
  const _BomPickerCard({required this.bom, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _tealLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'BOM-${bom.bomId.padLeft(3, '0')}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _tealDark),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bom.bomLabel.contains('·')
                        ? bom.bomLabel.split('·').last.trim()
                        : bom.bomLabel,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${bom.items.length} items',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...bom.items.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.itemCode,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontFamily: 'monospace'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.itemName,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
            if (bom.items.length > 2)
              Text(
                '+${bom.items.length - 2} more items',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// LEVEL 3 — PRODUCTION PLANNING FORM SCREEN
// ─────────────────────────────────────────

class ProductionPlanningFormScreen extends StatefulWidget {
  final JobOrder order;
  final int prodIdx;
  final int availableQty;
  final void Function(ProductSplit) onCreated;

  static int _planCounter = 52;

  const ProductionPlanningFormScreen({
    super.key,
    required this.order,
    required this.prodIdx,
    required this.availableQty,
    required this.onCreated,
  });

  @override
  State<ProductionPlanningFormScreen> createState() =>
      _ProductionPlanningFormScreenState();
}

class _ProductionPlanningFormScreenState
    extends State<ProductionPlanningFormScreen> {
  String? _selectedBom;
  BomData? _bomData;
  int _qty = 0;
  String _priority = '';
  String _productionType = '';
  DateTime? _deadline;
  bool _isAutoFilled = false;

  final _qtyCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late final String _planId;
  late final String _today;

  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];
  final List<String> _prodTypeOptions = [
    'Assembly',
    'Fabrication',
    'Machining',
    'Packaging',
    'Testing'
  ];

  @override
  void initState() {
    super.initState();
    ProductionPlanningFormScreen._planCounter++;
    _planId =
    'PP-2026-${ProductionPlanningFormScreen._planCounter.toString().padLeft(4, '0')}';
    final n = DateTime.now();
    _today =
    '${n.day.toString().padLeft(2, '0')}-${n.month.toString().padLeft(2, '0')}-${n.year}';

    // ── AUTO-FILL BOM for mapped products ──
    final autoMap = _autoMapBom(widget.prodIdx, widget.order.products);
    if (autoMap != null) {
      _bomData = autoMap;
      _selectedBom = autoMap.bomLabel;
      _isAutoFilled = true;
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _operatorCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _selectedBom != null &&
          _qty > 0 &&
          _qty <= widget.availableQty &&
          _deadline != null &&
          _priority.isNotEmpty &&
          _productionType.isNotEmpty;

  // ── BOM picker only for non-auto-filled products ──
  // Auto-filled products: BOM field is fully read-only, no picker
  Future<void> _openBomPicker() async {
    if (_isAutoFilled) return; // ✅ Auto-filled BOM — edit blocked
    final selected = await _showBomPicker(context);
    if (selected != null) {
      setState(() {
        _bomData = selected;
        _selectedBom = selected.bomLabel;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _teal)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  void _reset() {
    setState(() {
      // ✅ BOM is never reset — always read-only
      _qty = 0;
      _priority = '';
      _productionType = '';
      _deadline = null;
    });
    _qtyCtrl.clear();
    _operatorCtrl.clear();
    _descCtrl.clear();
  }

  void _savePlan() {
    widget.onCreated(ProductSplit(
      label: _selectedBom!,
      qty: _qty,
      priority: _priority,
      deadline: _deadline,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final product = order.products[widget.prodIdx];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: _buildTealAppBar(
        title: 'Production Planning',
        subtitle: order.id,
        showBack: true,
        context: context,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _Tab(label: 'Production Planning · $_planId', active: true),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 30),
              children: [
                _Banner2(
                  text:
                  'Job Order: ${order.id} — ${order.customer} | ${product.name}',
                ),
                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    children: [
                      _FormRow(children: [
                        _ReadOnly(label: 'PLAN ID', value: _planId),
                        _ReadOnly(label: 'ORDER NO', value: order.id),
                      ]),
                      const SizedBox(height: 10),
                      _FormRow(children: [
                        _ReadOnly(
                            label: 'PRODUCT CODE',
                            value: product.productId.isNotEmpty
                                ? product.productId
                                : 'PRD-${(widget.prodIdx + 1).toString().padLeft(4, '0')}'),
                        _ReadOnly(
                            label: 'PRODUCT NAME', value: product.name),
                      ]),
                      const SizedBox(height: 10),

                      // ── BOM ID FIELD — FULLY READ-ONLY ──────────────────
                      _Editable(
                        label: 'BOM ID',
                        child: _isAutoFilled
                            ? _AutoFilledBomField(
                          // ✅ onClear removed — cannot change BOM
                          bom: _bomData!,
                        )
                            : _BomPickerField(
                          selected: _bomData,
                          onTap:
                          _openBomPicker, // blocked inside if auto-filled
                        ),
                      ),

                      const SizedBox(height: 10),
                      _FormRow(children: [
                        _ReadOnly(
                            label: 'CUSTOMER NAME', value: order.customer),
                        _Editable(
                          label: 'QUANTITY *',
                          child: _PPQtyField(
                            controller: _qtyCtrl,
                            maxQty: widget.availableQty,
                            onChanged: (v) => setState(() => _qty = v),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      _FormRow(children: [
                        _Editable(
                          label: 'OPERATOR',
                          child: _PPTextField(
                              controller: _operatorCtrl,
                              hint: 'Operator name...'),
                        ),
                        _Editable(
                          label: 'DATE *',
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F6F8),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: Colors.grey.shade300),
                              ),
                              child: Row(children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 15,
                                    color: _deadline != null
                                        ? _teal
                                        : Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  _deadline == null
                                      ? 'Delivery date'
                                      : _fmtDate(_deadline!),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: _deadline == null
                                          ? Colors.grey
                                          : Colors.black87),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      _FormRow(children: [
                        _Editable(
                          label: 'PRIORITY *',
                          child: _PPDropdown(
                            hint: '-- Select --',
                            value: _priority.isEmpty ? null : _priority,
                            items: _priorityOptions,
                            itemColor: _priorityColor,
                            onChanged: (v) =>
                                setState(() => _priority = v ?? ''),
                          ),
                        ),
                        _Editable(
                          label: 'PRODUCTION TYPE *',
                          child: _PPDropdown(
                            hint: '-- Select --',
                            value: _productionType.isEmpty
                                ? null
                                : _productionType,
                            items: _prodTypeOptions,
                            onChanged: (v) =>
                                setState(() => _productionType = v ?? ''),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      _Editable(
                        label: 'JOB DESCRIPTION',
                        child: _PPTextField(
                            controller: _descCtrl,
                            hint: 'Job description...'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                              color: _teal,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 8),
                        const Text('Item Details',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87)),
                        const Spacer(),
                        if (_bomData != null)
                          _Pill(
                              text:
                              'BOM ID: ${_bomData!.bomId}  ·  ${_bomData!.items.length} rows'),
                      ]),
                      const SizedBox(height: 10),
                      _ItemTable(bomData: _bomData, splitQty: _qty),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding:
                        const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Reset',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _canSave ? _savePlan : null,
                      icon: const Icon(Icons.save_outlined, size: 17),
                      label: const Text('Save Plan',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _canSave ? _teal : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                        const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// AUTO-FILLED BOM FIELD
// ✅ Fully read-only — no edit/clear button
// ─────────────────────────────────────────

class _AutoFilledBomField extends StatelessWidget {
  final BomData bom;

  // ✅ onClear parameter removed completely
  const _AutoFilledBomField({required this.bom});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8), // grey = read-only appearance
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [

          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bom.bomLabel,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ),
          // ✅ Edit icon button completely removed — no way to change BOM
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// BOM PICKER FIELD
// ✅ Read-only appearance when no BOM selected
//    (for non-auto products, picker still works)
// ─────────────────────────────────────────

class _BomPickerField extends StatelessWidget {
  final BomData? selected;
  final VoidCallback onTap;
  const _BomPickerField({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected != null
              ? const Color(0xFFF0FBF9)
              : const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected != null
                ? _teal.withOpacity(0.4)
                : Colors.grey.shade300,
            width: selected != null ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected != null
                  ? Icons.check_circle_outline
                  : Icons.list_alt_outlined,
              size: 16,
              color: selected != null ? _teal : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selected != null ? selected!.bomLabel : '-- Select BOM --',
                style: TextStyle(
                  fontSize: 13,
                  color: selected != null ? Colors.black87 : Colors.grey,
                  fontWeight: selected != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: selected != null ? _teal : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ITEM DETAILS TABLE
// ─────────────────────────────────────────

class _ItemTable extends StatelessWidget {
  final BomData? bomData;
  final int splitQty;
  const _ItemTable({required this.bomData, required this.splitQty});

  @override
  Widget build(BuildContext context) {
    if (bomData == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        alignment: Alignment.center,
        child: Text(
          'Select a BOM to view item details',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── HEADER ─────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A), // teal bg
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white),
            ),
            child: const Row(
              children: [
                SizedBox(width: 32, child: _TH('', isDarkHeader: true)),
                SizedBox(width: 110, child: _TH('ITEM CODE', isDarkHeader: true)),
                SizedBox(width: 190, child: _TH('ITEM NAME', isDarkHeader: true)),
                SizedBox(
                  width: 72,
                  child: _TH('Required QTY', center: true, isDarkHeader: true),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ─── ROWS ─────────────────────
          ...bomData!.items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final mult = splitQty > 0 ? splitQty : 1;
            final totalQty = item.qtyPerUnit * mult;

            return Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
              decoration: BoxDecoration(
                color: i.isEven ? const Color(0xFFF5F5F5) : Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 32),

                  SizedBox(
                    width: 110,
                    child: Text(
                      item.itemCode,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 190,
                    child: Text(
                      item.itemName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 72,
                    child: _ColorCell(
                      value: '$totalQty',
                      fg: _tealDark,
                      bg: _tealLight,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 6),

          // ─── FOOTER ─────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total Rows: ${bomData!.items.length}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SMALL HELPER WIDGETS
// ─────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 4,
      height: 16,
      decoration: BoxDecoration(
          color: _teal, borderRadius: BorderRadius.circular(2)),
    ),
    const SizedBox(width: 8),
    Text(label,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87)),
  ]);
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  const _Tab({required this.label, required this.active});

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      border: Border(
          bottom: BorderSide(
              color: active ? _teal : Colors.transparent, width: 2)),
    ),
    child: Text(label,
        style: TextStyle(
            fontSize: 11,
            fontWeight:
            active ? FontWeight.w700 : FontWeight.w400,
            color: active ? _teal : Colors.grey.shade500)),
  );
}

class _Banner2 extends StatelessWidget {
  final String text;
  const _Banner2({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.green.shade300),
    ),
    child: Row(children: [
      const Icon(Icons.check_circle_outline,
          color: Colors.green, size: 16),
      const SizedBox(width: 8),
      Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w600))),
    ]),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2))
      ],
    ),
    child: child,
  );
}

class _FormRow extends StatelessWidget {
  final List<Widget> children;
  const _FormRow({required this.children});

  @override
  Widget build(BuildContext context) {
    final List<Widget> spaced = [];
    for (int i = 0; i < children.length; i++) {
      spaced.add(Expanded(child: children[i]));
      if (i < children.length - 1) spaced.add(const SizedBox(width: 10));
    }
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start, children: spaced);
  }
}

class _ReadOnly extends StatelessWidget {
  final String label, value;
  const _ReadOnly({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FL(label),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: 11, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(value,
            style: const TextStyle(
                fontSize: 13, color: Colors.black87)),
      ),
    ],
  );
}

class _Editable extends StatelessWidget {
  final String label;
  final Widget child;
  const _Editable({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FL(label),
      const SizedBox(height: 4),
      child,
    ],
  );
}

class _FL extends StatelessWidget {
  final String t;
  const _FL(this.t);

  @override
  Widget build(BuildContext context) => Text(t,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.3));
}

class _PPDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final Color Function(String)? itemColor;

  const _PPDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F6F8),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        hint: Text(hint,
            style:
            const TextStyle(fontSize: 13, color: Colors.grey)),
        icon: const Icon(Icons.keyboard_arrow_down,
            color: Colors.grey, size: 18),
        items: items
            .map((item) => DropdownMenuItem(
          value: item,
          child: Text(item,
              style: TextStyle(
                  fontSize: 13,
                  color: itemColor != null
                      ? itemColor!(item)
                      : Colors.black87,
                  fontWeight: itemColor != null
                      ? FontWeight.w600
                      : FontWeight.normal)),
        ))
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

class _PPQtyField extends StatelessWidget {
  final TextEditingController controller;
  final int maxQty;
  final void Function(int) onChanged;
  const _PPQtyField(
      {required this.controller,
        required this.maxQty,
        required this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: '0',
      hintStyle:
      const TextStyle(fontSize: 13, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF4F6F8),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 11, vertical: 11),
      isDense: true,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide:
          const BorderSide(color: _teal, width: 1.5)),
    ),
    onChanged: (v) {
      int parsed = int.tryParse(v) ?? 0;
      if (parsed > maxQty) {
        parsed = maxQty;
        controller.value = TextEditingValue(
            text: '$parsed',
            selection: TextSelection.collapsed(
                offset: '$parsed'.length));
      }
      onChanged(parsed);
    },
  );
}

class _PPTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _PPTextField(
      {required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(fontSize: 13, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF4F6F8),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 11, vertical: 11),
      isDense: true,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide:
          const BorderSide(color: _teal, width: 1.5)),
    ),
  );
}

class _TH extends StatelessWidget {
  final String text;
  final bool center;
  final bool isDarkHeader;
  const _TH(this.text, {this.center = false, this.isDarkHeader = true});

  @override
  Widget build(BuildContext context) => Text(text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: TextStyle(
          fontSize: 11,
          color: isDarkHeader ? Colors.white70 : Colors.grey.shade700,
          fontWeight: FontWeight.w600));
}

class _ColorCell extends StatelessWidget {
  final String value;
  final Color fg, bg;
  const _ColorCell(
      {required this.value, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 4),
    padding:
    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(4)),
    alignment: Alignment.center,
    child: Text(value,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 12,
            color: fg,
            fontWeight: FontWeight.w700)),
  );
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
        color: _tealLight, borderRadius: BorderRadius.circular(20)),
    child: Text(text,
        style: const TextStyle(
            fontSize: 11,
            color: _tealDark,
            fontWeight: FontWeight.w600)),
  );
}

Color _priorityColor(String p) {
  switch (p) {
    case 'High':
      return Colors.red.shade500;
    case 'Medium':
      return _amber;
    default:
      return Colors.green.shade600;
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(label,
        style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600)),
  );
}