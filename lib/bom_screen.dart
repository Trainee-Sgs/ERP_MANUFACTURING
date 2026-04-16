import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';
import 'models.dart';

const _teal = Color(0xFF26A69A);
const _tealLight = Color(0xFFE0F2F1);
const _tealDark = Color(0xFF00695C);

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
    leading: showBack && context != null
        ? IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded,
          color: Colors.white),
      onPressed: () => Navigator.pop(context),
    )
        : null,
    automaticallyImplyLeading: false,
    title: subtitle != null
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        Text(
          subtitle,
          style:
          const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    )
        : Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
    actions: actions,
    bottom: bottom,
  );
}

// ─────────────────────────────────────────────
// Reusable Teal Bottom Sheet Wrapper
// ─────────────────────────────────────────────
class _TealBottomSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final double heightFactor;
  final List<Widget>? actions;

  const _TealBottomSheet({
    required this.title,
    this.subtitle,
    required this.child,
    this.heightFactor = 0.92,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final mq = MediaQuery.of(context);

    return Container(
      height: mq.size.height * heightFactor,
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
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              sw * 0.04,
              sw * 0.02,
              sw * 0.04,
              sw * 0.02,
            ),
            child: Row(
              children: [
                Expanded(
                  child: subtitle != null
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppColors.textSecondary, size: 24),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOM Screen
// ─────────────────────────────────────────────
class BomScreen extends StatefulWidget {
  const BomScreen({super.key});

  @override
  State<BomScreen> createState() => _BomScreenState();
}

class _BomScreenState extends State<BomScreen> {
  String _search = '';
  String _filter = 'All';
  List<BomItem> _boms = List.from(SampleData.boms);

  void _openCreateBom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateBomBottomSheet(
        onCreateBom: (productName, category, version) {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddMaterialsBottomSheet(
              productName: productName,
              category: category,
              version: version,
              onBomCreated: (newBom) {
                setState(() {
                  _boms.add(newBom);
                });
              },
            ),
          );
        },
      ),
    );
  }

  void _updateBom(BomItem updatedBom) {
    setState(() {
      final index = _boms.indexWhere((b) => b.id == updatedBom.id);
      if (index != -1) {
        _boms[index] = updatedBom;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(sw),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(sw * 0.05),
              child: Column(
                children: [
                  _buildFilters(sw),
                  SizedBox(height: sw * 0.04),
                  ..._filteredBoms().map(
                        (b) => Padding(
                      padding: EdgeInsets.only(bottom: sw * 0.03),
                      child: _BomCard(
                        bom: b,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BomDetailPage(
                              bom: b,
                              onBomUpdated: _updateBom,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildAddButton(sw),
        ],
      ),
    );
  }

  Widget _buildTopBar(double sw) => Container(
    color: _teal,
    padding:
    EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.03),
    child: Column(
      children: [
        SizedBox(height: sw * 0.03),
        TextField(
          onChanged: (v) => setState(() => _search = v),
          style: TextStyle(
              fontSize: sw * 0.035, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search product name or BOM ID...',
            hintStyle: TextStyle(fontSize: sw * 0.035),
            prefixIcon: Icon(Icons.search,
                size: sw * 0.045, color: AppColors.textHint),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.025),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.025),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.025),
              borderSide:
              const BorderSide(color: Colors.white, width: 1.5),
            ),
            contentPadding:
            EdgeInsets.symmetric(vertical: sw * 0.025),
          ),
        ),
      ],
    ),
  );

  Widget _buildFilters(double sw) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: ['All', 'Active', 'Draft', 'Archived']
          .map(
            (f) => Padding(
          padding: EdgeInsets.only(right: sw * 0.02),
          child: GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04, vertical: sw * 0.02),
              decoration: BoxDecoration(
                color: _filter == f ? _teal : AppColors.surface,
                borderRadius:
                BorderRadius.circular(sw * 0.05),
                border: Border.all(
                  color:
                  _filter == f ? _teal : AppColors.border,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  fontSize: sw * 0.032,
                  fontWeight: FontWeight.w600,
                  color: _filter == f
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      )
          .toList(),
    ),
  );

  List<BomItem> _filteredBoms() {
    var list = _boms;
    if (_search.isNotEmpty) {
      list = list
          .where((b) => b.productName
          .toLowerCase()
          .contains(_search.toLowerCase()))
          .toList();
    }
    if (_filter != 'All') {
      list = list
          .where((b) => b.status == _filter.toLowerCase())
          .toList();
    }
    return list;
  }

  Widget _buildAddButton(double sw) => Container(
    color: AppColors.surface,
    padding: EdgeInsets.fromLTRB(
      sw * 0.04,
      sw * 0.04,
      sw * 0.04,
      sw * 0.04 + MediaQuery.of(context).viewPadding.bottom,
    ),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openCreateBom,
        style: ElevatedButton.styleFrom(
          backgroundColor: _teal,
          foregroundColor: Colors.white,
        ),
        icon: Icon(Icons.add, size: sw * 0.045),
        label: Text('Create New BOM',
            style: TextStyle(fontSize: sw * 0.035)),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// BOM Detail Page — Edit button opens component editor
// ─────────────────────────────────────────────
class BomDetailPage extends StatefulWidget {
  final BomItem bom;
  final Function(BomItem) onBomUpdated;

  const BomDetailPage({
    super.key,
    required this.bom,
    required this.onBomUpdated,
  });

  @override
  State<BomDetailPage> createState() => _BomDetailPageState();
}

class _BomDetailPageState extends State<BomDetailPage> {
  late List<BomMaterial> _materials;

  @override
  void initState() {
    super.initState();
    // Deep copy so edits are local to this page
    _materials = SampleData.bomMaterials
        .map((m) => BomMaterial(
      name: m.name,
      uom: m.uom,
      quantity: m.quantity,
    ))
        .toList();
  }

  void _openEditComponents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditComponentsBottomSheet(
        materials: _materials,
        onSaved: (updatedMaterials) {
          setState(() {
            _materials = updatedMaterials;
          });
          // Also update the BOM materialCount
          final updatedBom = BomItem(
            id: widget.bom.id,
            productName: widget.bom.productName,
            category: widget.bom.category,
            version: widget.bom.version,
            status: widget.bom.status,
            materialCount: updatedMaterials.length,
            updatedAt: DateTime.now(),
          );
          widget.onBomUpdated(updatedBom);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildTealAppBar(
        title: widget.bom.productName,
        subtitle: '${widget.bom.id} · ${widget.bom.version}',
        context: context,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: _openEditComponents,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: sw * 0.03),
            Text(
              'Components',
              style: TextStyle(
                fontSize: sw * 0.04,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: sw * 0.04),
            ..._materials.map(
                  (m) => Padding(
                padding: EdgeInsets.only(bottom: sw * 0.02),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: sw * 0.09,
                        height: sw * 0.09,
                        decoration: BoxDecoration(
                          color: _tealLight,
                          borderRadius: BorderRadius.circular(sw * 0.02),
                        ),
                        child: Icon(Icons.memory_outlined,
                            color: _teal, size: sw * 0.050),
                      ),
                      SizedBox(width: sw * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              style: TextStyle(
                                fontSize: sw * 0.034,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: sw * 0.008),
                            Text(
                              m.uom,
                              style: TextStyle(
                                fontSize: sw * 0.030,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: sw * 0.030,
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: sw * 0.004),
                          Text(
                            '${m.quantity}',
                            style: TextStyle(
                              fontSize: sw * 0.030,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Edit Components Bottom Sheet
// Opens all components as live-editable rows
// ─────────────────────────────────────────────
class EditComponentsBottomSheet extends StatefulWidget {
  final List<BomMaterial> materials;
  final Function(List<BomMaterial>) onSaved;

  const EditComponentsBottomSheet({
    super.key,
    required this.materials,
    required this.onSaved,
  });

  @override
  State<EditComponentsBottomSheet> createState() =>
      _EditComponentsBottomSheetState();
}

class _EditComponentsBottomSheetState
    extends State<EditComponentsBottomSheet> {
  late List<_EditableRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.materials
        .map((m) => _EditableRow.fromMaterial(m))
        .toList();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _saveAll(BuildContext ctx) {
    final updated = _rows.map((r) {
      return BomMaterial(
        name: r.nameCtrl.text.isEmpty
            ? 'Unnamed Component'
            : r.nameCtrl.text,
        uom: r.uom,
        quantity: double.tryParse(r.qtyCtrl.text) ?? 0,

      );
    }).toList();

    widget.onSaved(updated);
    Navigator.pop(ctx);

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: const Text('Components updated successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return _TealBottomSheet(
      title: 'Edit Components',
      subtitle: '${_rows.length} components',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                sw * 0.05,
                sw * 0.04,
                sw * 0.05,
                keyboardH + sw * 0.04,
              ),
              child: Column(
                children: [
                  ..._rows.asMap().entries.map((e) {
                    final idx = e.key;
                    final row = e.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: sw * 0.025),
                      child: _EditableRowWidget(
                        row: row,
                        sw: sw,
                        index: idx,
                        canDelete: _rows.length > 1,
                        onDelete: () => setState(() {
                          row.dispose();
                          _rows.removeAt(idx);
                        }),
                      ),
                    );
                  }),

                ],
              ),
            ),
          ),
          // Save bar
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(
              sw * 0.05,
              sw * 0.03,
              sw * 0.05,
              sw * 0.04 + bottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(color: AppColors.border, height: 1),
                SizedBox(height: sw * 0.03),
                Row(
                  children: [
                    Icon(Icons.layers_outlined,
                        size: sw * 0.035,
                        color: AppColors.textSecondary),
                    SizedBox(width: sw * 0.015),
                    Text(
                      '${_rows.length} component${_rows.length == 1 ? '' : 's'}',
                      style: TextStyle(
                          fontSize: sw * 0.03,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: sw * 0.04),
                          side: const BorderSide(color: _teal),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: sw * 0.035, color: _teal),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _saveAll(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: sw * 0.04),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(Icons.check_circle_outline,
                            size: sw * 0.045),
                        label: Text(
                          'Save Changes',
                          style: TextStyle(
                              fontSize: sw * 0.038,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Editable row model
// ─────────────────────────────────────────────
class _EditableRow {
  final TextEditingController nameCtrl;
  final TextEditingController itemCodeCtrl; // UI only, not saved to model
  final TextEditingController qtyCtrl;
  String uom;

  _EditableRow({
    String name = '',
    String itemCode = '',
    String qty = '',
    this.uom = 'pcs',
  })  : nameCtrl = TextEditingController(text: name),
        itemCodeCtrl = TextEditingController(text: itemCode),
        qtyCtrl = TextEditingController(text: qty);

  factory _EditableRow.fromMaterial(BomMaterial m) => _EditableRow(
    name: m.name,
    qty: m.quantity.toString(),
    uom: m.uom,
  );

  void dispose() {
    nameCtrl.dispose();
    itemCodeCtrl.dispose();
    qtyCtrl.dispose();
  }
}

// ─────────────────────────────────────────────
// Editable row widget
// ─────────────────────────────────────────────
class _EditableRowWidget extends StatelessWidget {
  final _EditableRow row;
  final double sw;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;

  const _EditableRowWidget({
    required this.row,
    required this.sw,
    required this.index,
    required this.canDelete,
    required this.onDelete,
  });

  InputDecoration _compact(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
        fontSize: sw * 0.028, color: AppColors.textHint),
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sw * 0.02),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sw * 0.02),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sw * 0.02),
      borderSide: const BorderSide(color: _teal, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(
        horizontal: sw * 0.025, vertical: sw * 0.02),
    isDense: true,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(sw * 0.025),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: sw * 0.06,
                height: sw * 0.06,
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(sw * 0.015),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w700,
                      color: _teal,
                    ),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Component ${index + 1}',
                style: TextStyle(
                  fontSize: sw * 0.03,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (canDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: EdgeInsets.all(sw * 0.015),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius:
                      BorderRadius.circular(sw * 0.015),
                    ),
                    child: const Icon(Icons.delete_outline,
                        size: 20, color: Color(0xFFD32F2F)),
                  ),
                ),
            ],
          ),
          SizedBox(height: sw * 0.025),
          // Item Code (UI display only)
          Text(
            'Item Code',
            style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: sw * 0.015),
          TextField(
            controller: row.itemCodeCtrl,
            style: TextStyle(
                fontSize: sw * 0.032, color: AppColors.textPrimary),
            decoration: _compact('PC-001'),
          ),
          SizedBox(height: sw * 0.025),
          // Component Name
          Text(
            'Component Name',
            style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: sw * 0.015),
          TextField(
            controller: row.nameCtrl,
            style: TextStyle(
                fontSize: sw * 0.032, color: AppColors.textPrimary),
            decoration:
            _compact('e.g. Monocrystalline Silicon Cell 6"'),
          ),
          SizedBox(height: sw * 0.02),
          // Quantity + UOM
          Row(
            children: [
              SizedBox(width: sw * 0.025),
              Expanded(
                flex: 3,
                child: StatefulBuilder(
                  builder: (ctx, setSelf) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UOM',
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: sw * 0.015),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                          BorderRadius.circular(sw * 0.02),
                          border:
                          Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: row.uom,
                            isExpanded: true,
                            isDense: true,
                            items: [
                              'pcs',
                              'kg',
                              'g',
                              'm',
                              'm²',
                              'ltr',
                              'set'
                            ]
                                .map((u) => DropdownMenuItem(
                                value: u, child: Text(u)))
                                .toList(),
                            onChanged: (v) =>
                                setSelf(() => row.uom = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: sw * 0.030),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: sw * 0.028,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: sw * 0.015),
                    TextField(
                      controller: row.qtyCtrl,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                          decimal: true),
                      style: TextStyle(
                          fontSize: sw * 0.032,
                          color: AppColors.textPrimary),
                      decoration: _compact('0'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sw * 0.025),
            ],
          ),
          SizedBox(height: sw * 0.015),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Create BOM — Bottom Sheet
// ─────────────────────────────────────────────
class CreateBomBottomSheet extends StatefulWidget {
  final void Function(String productName, String category, String version)
  onCreateBom;
  const CreateBomBottomSheet({super.key, required this.onCreateBom});

  @override
  State<CreateBomBottomSheet> createState() =>
      _CreateBomBottomSheetState();
}

class _CreateBomBottomSheetState extends State<CreateBomBottomSheet> {
  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  String selectedCategory = 'PV Module';

  @override
  void dispose() {
    nameCtrl.dispose();
    codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return _TealBottomSheet(
      title: 'Create New BOM',
      heightFactor: 0.85,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          sw * 0.05,
          sw * 0.05,
          sw * 0.05,
          bottomInset + bottomPadding + sw * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FormLabel(label: 'Product Name', sw: sw),
            SizedBox(height: sw * 0.02),
            TextField(
              controller: nameCtrl,
              decoration: _inputDecoration(
                'e.g. Solar Panel 400W Mono',
                sw,
                prefixIcon: Icons.solar_power_outlined,
              ),
            ),
            SizedBox(height: sw * 0.035),
            _FormLabel(label: 'Product Code', sw: sw),
            SizedBox(height: sw * 0.02),
            TextField(
              controller: codeCtrl,
              decoration: _inputDecoration(
                'PC-001',
                sw,
                prefixIcon: Icons.solar_power_outlined,
              ),
            ),
            SizedBox(height: sw * 0.035),
            _FormLabel(label: 'Category', sw: sw),
            SizedBox(height: sw * 0.02),
            Container(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(sw * 0.025),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: [
                    'PV Module',
                    'Solar Lighting',
                    'Solar Pump',
                    'Off-Grid System',
                    'Inverter',
                    'Battery Pack'
                  ]
                      .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => selectedCategory = v!),
                ),
              ),
            ),
            SizedBox(height: sw * 0.05),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onCreateBom(
                    nameCtrl.text.isEmpty ? 'New BOM' : nameCtrl.text,
                    selectedCategory,
                    codeCtrl.text.isEmpty ? 'v1.0' : codeCtrl.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  padding:
                  EdgeInsets.symmetric(vertical: sw * 0.04),
                ),
                child: Text('Add Materials',
                    style: TextStyle(fontSize: sw * 0.035)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Add Materials — Bottom Sheet
// ─────────────────────────────────────────────
class AddMaterialsBottomSheet extends StatefulWidget {
  final String productName;
  final String category;
  final String version;
  final Function(BomItem)? onBomCreated;

  const AddMaterialsBottomSheet({
    super.key,
    required this.productName,
    required this.category,
    required this.version,
    this.onBomCreated,
  });

  @override
  State<AddMaterialsBottomSheet> createState() =>
      _AddMaterialsBottomSheetState();
}

class _AddMaterialsBottomSheetState
    extends State<AddMaterialsBottomSheet> {
  final List<_MaterialRow> rows = [_MaterialRow()];

  void _showSuccess() {
    final sw = MediaQuery.of(context).size.width;

    final newBom = BomItem(
      id: 'BOM-${DateTime.now().millisecondsSinceEpoch}',
      productName: widget.productName,
      category: widget.category,
      version: widget.version,
      status: 'active',
      materialCount: rows.length,
      updatedAt: DateTime.now(),
    );

    if (widget.onBomCreated != null) {
      widget.onBomCreated!(newBom);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sw * 0.025)),
        content: Row(
          children: [
            Icon(Icons.check_circle,
                color: Colors.white, size: sw * 0.045),
            SizedBox(width: sw * 0.025),
            Expanded(
              child: Text(
                'BOM created for "${widget.productName}" with ${rows.length} component${rows.length == 1 ? '' : 's'}',
                style: TextStyle(
                    fontSize: sw * 0.032, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return _TealBottomSheet(
      title: 'Add Materials',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                sw * 0.05,
                sw * 0.04,
                sw * 0.05,
                keyboardH + sw * 0.04,
              ),
              child: Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: sw * 0.01),
                      ],
                    ),
                  ),
                  SizedBox(height: sw * 0.04),
                  ...rows.asMap().entries.map((e) {
                    final idx = e.key;
                    final row = e.value;
                    return Padding(
                      padding:
                      EdgeInsets.only(bottom: sw * 0.025),
                      child: _MaterialRowWidget(
                        row: row,
                        sw: sw,
                        index: idx,
                        canDelete: rows.length > 1,
                        onDelete: () =>
                            setState(() => rows.removeAt(idx)),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () =>
                        setState(() => rows.add(_MaterialRow())),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: sw * 0.035),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                        BorderRadius.circular(sw * 0.025),
                        border:
                        Border.all(color: _teal, width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline,
                              size: sw * 0.045, color: _teal),
                          SizedBox(width: sw * 0.02),
                          Text(
                            'Add Another Component',
                            style: TextStyle(
                              fontSize: sw * 0.033,
                              fontWeight: FontWeight.w600,
                              color: _teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      height: keyboardH > 0 ? keyboardH : sw * 0.04),
                ],
              ),
            ),
          ),
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(
              sw * 0.05,
              sw * 0.03,
              sw * 0.05,
              sw * 0.04 + bottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(color: AppColors.border, height: 1),
                SizedBox(height: sw * 0.03),
                Row(
                  children: [
                    Icon(Icons.layers_outlined,
                        size: sw * 0.035,
                        color: AppColors.textSecondary),
                    SizedBox(width: sw * 0.015),
                    Text(
                      '${rows.length} component${rows.length == 1 ? '' : 's'} added',
                      style: TextStyle(
                          fontSize: sw * 0.03,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.03),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showSuccess();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          vertical: sw * 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.check_circle_outline,
                        size: sw * 0.045),
                    label: Text(
                      'Create BOM',
                      style: TextStyle(
                          fontSize: sw * 0.038,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────
InputDecoration _inputDecoration(String hint, double sw,
    {IconData? prefixIcon}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: sw * 0.035, color: AppColors.textHint),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon,
          size: sw * 0.045, color: AppColors.textHint)
          : null,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw * 0.025),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw * 0.025),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw * 0.025),
        borderSide: const BorderSide(color: _teal, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
          vertical: sw * 0.025, horizontal: sw * 0.04),
    );

class _MaterialRow {
  final nameCtrl = TextEditingController();
  final itemCodeCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final scrapCtrl = TextEditingController();
  String uom = 'pcs';
}

class _MaterialRowWidget extends StatelessWidget {
  final _MaterialRow row;
  final double sw;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;

  const _MaterialRowWidget({
    required this.row,
    required this.sw,
    required this.index,
    required this.canDelete,
    required this.onDelete,
  });

  InputDecoration _compact(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
        fontSize: sw * 0.028, color: AppColors.textHint),
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sw * 0.02),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sw * 0.02),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(sw * 0.02),
      borderSide: const BorderSide(color: _teal, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(
        horizontal: sw * 0.025, vertical: sw * 0.02),
    isDense: true,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(sw * 0.025),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: sw * 0.06,
                height: sw * 0.06,
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(sw * 0.015),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w700,
                      color: _teal,
                    ),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Component ${index + 1}',
                style: TextStyle(
                  fontSize: sw * 0.03,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (canDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: EdgeInsets.all(sw * 0.015),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius:
                      BorderRadius.circular(sw * 0.015),
                    ),
                    child: const Icon(Icons.delete_outline,
                        size: 20, color: Color(0xFFD32F2F)),
                  ),
                ),
            ],
          ),
          SizedBox(height: sw * 0.025),
          Text(
            'Item Code',
            style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: sw * 0.015),
          TextField(
            controller: row.itemCodeCtrl,
            style: TextStyle(
                fontSize: sw * 0.032, color: AppColors.textPrimary),
            decoration: _compact('PC-001'),
          ),
          SizedBox(height: sw * 0.025),
          Text(
            'Component Name',
            style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: sw * 0.015),
          TextField(
            controller: row.nameCtrl,
            style: TextStyle(
                fontSize: sw * 0.032, color: AppColors.textPrimary),
            decoration:
            _compact('e.g. Monocrystalline Silicon Cell 6"'),
          ),
          SizedBox(height: sw * 0.02),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: sw * 0.028,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: sw * 0.015),
                    TextField(
                      controller: row.qtyCtrl,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                          decimal: true),
                      style: TextStyle(
                          fontSize: sw * 0.032,
                          color: AppColors.textPrimary),
                      decoration: _compact('0'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sw * 0.025),
              Expanded(
                flex: 3,
                child: StatefulBuilder(
                  builder: (ctx, setSelf) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UOM',
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: sw * 0.015),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                          BorderRadius.circular(sw * 0.02),
                          border:
                          Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: row.uom,
                            isExpanded: true,
                            isDense: true,
                            items: [
                              'pcs',
                              'kg',
                              'g',
                              'm',
                              'm²',
                              'ltr',
                              'set'
                            ]
                                .map((u) => DropdownMenuItem(
                                value: u, child: Text(u)))
                                .toList(),
                            onChanged: (v) =>
                                setSelf(() => row.uom = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: sw * 0.025),
            ],
          ),
          SizedBox(height: sw * 0.02),
          Text(
            'Scrap %',
            style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: sw * 0.015),
          TextField(
            controller: row.scrapCtrl,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
                fontSize: sw * 0.032, color: AppColors.textPrimary),
            decoration: _compact('0'),
          ),
        ],
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;
  final double sw;

  const _FormLabel({required this.label, required this.sw});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: sw * 0.032,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );
}

class _BomCard extends StatelessWidget {
  final BomItem bom;
  final VoidCallback onTap;

  const _BomCard({required this.bom, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: sw * 0.105,
                height: sw * 0.105,
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(sw * 0.025),
                ),
                child: Icon(Icons.account_tree_outlined,
                    color: _teal, size: sw * 0.055),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bom.productName,
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: sw * 0.008),
                    Text(
                      '${bom.id} · ${bom.category}',
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: bom.status == 'active' ? 'Active' : 'Draft',
                status: bom.status == 'active'
                    ? 'completed'
                    : 'pending',
              ),
            ],
          ),
          SizedBox(height: sw * 0.03),
          const Divider(color: AppColors.border, height: 1),
          SizedBox(height: sw * 0.03),
          Row(
            children: [
              _chip(Icons.layers_outlined, bom.version, sw),
              SizedBox(width: sw * 0.03),
              _chip(Icons.memory_outlined,
                  '${bom.materialCount} components', sw),
              const Spacer(),
              Icon(Icons.chevron_right,
                  color: AppColors.textHint, size: sw * 0.045),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, double sw) => Row(
    children: [
      Icon(icon, size: sw * 0.035, color: AppColors.textSecondary),
      SizedBox(width: sw * 0.01),
      Text(label,
          style: TextStyle(
              fontSize: sw * 0.03,
              color: AppColors.textSecondary)),
    ],
  );
}