import 'package:flutter/material.dart';

class BomItem {
  final String id, productName, category, version, status;
  final int materialCount;
  final DateTime updatedAt;
  BomItem({required this.id, required this.productName, required this.category,
    required this.version, required this.status, required this.materialCount,
    required this.updatedAt});
}

class BomMaterial {
  final String name, uom;
  final double quantity;
  BomMaterial({required this.name, required this.uom,
    required this.quantity});
}

class ProductionPlan {
  final String id, productName, bomRef, status, priority;
  final int plannedQty, completedQty;
  final DateTime deadline;
  ProductionPlan({required this.id, required this.productName, required this.bomRef,
    required this.status, required this.priority, required this.plannedQty,
    required this.completedQty, required this.deadline});
}

class JobCard {
  final String id, productName, planRef, status, assignedTo, machine;
  final String description; // ← NEW
  final int qty;
  final DateTime startDate, endDate;
  JobCard({required this.id, required this.productName, required this.planRef,
    required this.status, required this.assignedTo, required this.machine,
    required this.qty, required this.startDate, required this.endDate,
    this.description = ''}); // ← NEW (optional with default)
}

// ─── Spare Item ───────────────────────────────────────────────────────────────
class SpareItem {
  final String partNo;
  final String name;
  final int required;
  final int inStock;
  final String uom;

  const SpareItem({
    required this.partNo,
    required this.name,
    required this.required,
    required this.inStock,
    required this.uom,
  });

  bool get isSufficient => inStock >= required;
  int get gap => required - inStock;
}

// ─── Material Request ─────────────────────────────────────────────────────────
class MaterialRequest {
  final String id, jobRef, requestedBy, status;
  final String itemName;
  final double qty;
  final String uom;
  final DateTime requestDate;
  final List<MaterialRequestItem> items;

  MaterialRequest({
    required this.id,
    required this.jobRef,
    required this.requestedBy,
    required this.status,
    required this.requestDate,
    required this.items,
    this.itemName = '',
    this.qty = 0,
    this.uom = 'pcs',
  });
}

class MaterialRequestItem {
  final String name, uom;
  final double required, available;
  MaterialRequestItem({required this.name, required this.uom,
    required this.required, required this.available});
}

class QcRecord {
  final String id, productName, jobRef, inspector, status;
  final int totalQty, passQty, failQty;
  final DateTime date;
  QcRecord({required this.id, required this.productName, required this.jobRef,
    required this.inspector, required this.status, required this.totalQty,
    required this.passQty, required this.failQty, required this.date});
}

// ─── Job Order Models ─────────────────────────────────────────────────────────

class PlanSplit {
  final String priority;
  final DateTime? deadline;
  const PlanSplit({required this.priority, this.deadline});
}

class ProductPlan {
  final int planned;
  final bool done;
  final List<PlanSplit> splits;
  const ProductPlan({
    required this.planned,
    this.done = false,
    this.splits = const [],
  });
}

class OrderProduct {
  final String name;
  final int qty;
  const OrderProduct({required this.name, required this.qty});
}

class JobOrder {
  final String id;
  final String ref;
  final DateTime deliveryDate;
  final List<OrderProduct> products;
  final List<ProductPlan> planning;
  const JobOrder({
    required this.id,
    required this.ref,
    required this.deliveryDate,
    required this.products,
    required this.planning,
  });
}

// ─── Sample spares data keyed by job card id ──────────────────────────────────
final Map<String, List<SpareItem>> _jobSpares = {
  'JC-001': [
    SpareItem(partNo: 'SP-101', name: 'Monocrystalline Cell 6"',  required: 144, inStock: 200, uom: 'Nos'),
    SpareItem(partNo: 'SP-102', name: 'EVA Encapsulant Film',      required: 4,   inStock: 2,   uom: 'm²'),
    SpareItem(partNo: 'SP-103', name: 'TPT Back Sheet',            required: 4,   inStock: 0,   uom: 'm²'),
    SpareItem(partNo: 'SP-104', name: 'MC4 Junction Box',          required: 2,   inStock: 5,   uom: 'Nos'),
  ],
  'JC-002': [
    SpareItem(partNo: 'SP-201', name: 'Tempered Solar Glass 3.2mm', required: 2,  inStock: 1,   uom: 'Nos'),
    SpareItem(partNo: 'SP-202', name: 'Anodised Aluminium Frame',   required: 4,  inStock: 8,   uom: 'Nos'),
    SpareItem(partNo: 'SP-203', name: 'Bypass Diode',               required: 6,  inStock: 0,   uom: 'Nos'),
  ],
  'JC-003': [
    SpareItem(partNo: 'SP-301', name: 'LED Street Light Driver 60W', required: 10, inStock: 10, uom: 'Nos'),
    SpareItem(partNo: 'SP-302', name: 'LiFePO4 Battery 60Ah',        required: 10, inStock: 6,  uom: 'Nos'),
    SpareItem(partNo: 'SP-303', name: 'Solar Charge Controller 10A', required: 10, inStock: 0,  uom: 'Nos'),
    SpareItem(partNo: 'SP-304', name: 'Mounting Pole Bracket',       required: 10, inStock: 15, uom: 'Nos'),
  ],
  'JC-004': [
    SpareItem(partNo: 'SP-401', name: 'Steel Rod 20mm',   required: 1000, inStock: 450, uom: 'Nos'),
    SpareItem(partNo: 'SP-402', name: 'Corner Bracket',   required: 400,  inStock: 400, uom: 'Nos'),
    SpareItem(partNo: 'SP-403', name: 'Welding Wire 1kg', required: 200,  inStock: 80,  uom: 'Nos'),
  ],
};

List<SpareItem> sparesFor(String jobId) =>
    _jobSpares[jobId] ?? _jobSpares['JC-001']!;

// ---------------------------------------------------------------------------
// Sample Data
// ---------------------------------------------------------------------------
class SampleData {
  // ── Bill of Materials ──────────────────────────────────────────────────────
  static List<BomItem> boms = [
    BomItem(
      id: 'BOM-001',
      productName: 'Solar Panel 400W Mono',
      category: 'PV Module',
      version: 'v2.1',
      status: 'active',
      materialCount: 6,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    BomItem(
      id: 'BOM-002',
      productName: 'Solar Street Light 60W',
      category: 'Solar Lighting',
      version: 'v1.3',
      status: 'active',
      materialCount: 4,
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    BomItem(
      id: 'BOM-003',
      productName: 'Solar Water Pump 1HP',
      category: 'Solar Pump',
      version: 'v3.0',
      status: 'draft',
      materialCount: 8,
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BomItem(
      id: 'BOM-004',
      productName: 'Solar Home System 1kW',
      category: 'Off-Grid System',
      version: 'v1.0',
      status: 'active',
      materialCount: 10,
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // ── BOM Materials ─────────────────────────────────────────────────────────
  static List<BomMaterial> bomMaterials = [
    BomMaterial(name: 'Monocrystalline Silicon Cell 6"', uom: 'pcs',  quantity: 72),
    BomMaterial(name: 'Tempered Solar Glass 3.2mm',      uom: 'm²',   quantity: 1.96),
    BomMaterial(name: 'EVA Encapsulant Film',             uom: 'm²',   quantity: 3.92),
    BomMaterial(name: 'TPT Back Sheet',                   uom: 'm²',   quantity: 1.96),
    BomMaterial(name: 'Anodised Aluminium Frame',         uom: 'pcs',  quantity: 1),
    BomMaterial(name: 'MC4 Junction Box',                 uom: 'pcs',  quantity: 1),
  ];

  // ── Production Plans ───────────────────────────────────────────────────────
  static List<ProductionPlan> plans = [
    ProductionPlan(
      id: 'PP-001',
      productName: 'Solar Panel 400W Mono',
      bomRef: 'BOM-001',
      status: 'inprogress',
      priority: 'High',
      plannedQty: 1000,
      completedQty: 450,
      deadline: DateTime.now().add(const Duration(days: 3)),
    ),
    ProductionPlan(
      id: 'PP-002',
      productName: 'Solar Street Light 60W',
      bomRef: 'BOM-002',
      status: 'pending',
      priority: 'Medium',
      plannedQty: 500,
      completedQty: 0,
      deadline: DateTime.now().add(const Duration(days: 7)),
    ),
    ProductionPlan(
      id: 'PP-003',
      productName: 'Solar Water Pump 1HP',
      bomRef: 'BOM-003',
      status: 'completed',
      priority: 'Low',
      plannedQty: 750,
      completedQty: 750,
      deadline: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ── Job Cards ──────────────────────────────────────────────────────────────
  static List<JobCard> jobCards = [
    JobCard(
      id: 'JC-001',
      productName: 'Solar Panel 400W Mono',
      planRef: 'PP-001',
      status: 'inprogress',
      assignedTo: 'Rajan Kumar',
      machine: 'Laminator L-01',
      qty: 500,
      description: 'Lamination and assembly of 400W monocrystalline solar panels.',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 2)),
    ),
    JobCard(
      id: 'JC-002',
      productName: 'Solar Panel 400W Mono',
      planRef: 'PP-001',
      status: 'pending',
      assignedTo: 'Suresh M',
      machine: 'Framing Press F-02',
      qty: 500,
      description: 'Framing and encapsulation of solar panel modules.',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 3)),
    ),
    JobCard(
      id: 'JC-003',
      productName: 'Solar Street Light 60W',
      planRef: 'PP-002',
      status: 'pending',
      assignedTo: 'Murugan S',
      machine: 'Assembly Station A-01',
      qty: 500,
      description: 'Assembly of 60W solar street light units with battery integration.',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 4)),
    ),
    JobCard(
      id: 'JC-004',
      productName: 'Steel Frame',
      planRef: 'JO-001',
      status: 'pending',
      assignedTo: 'Rajan Industries',
      machine: 'Fabrication Station F-01',
      qty: 100,
      description: 'Fabrication and welding of steel mounting frames.',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 5)),
    ),
  ];

  // ── Job Orders ─────────────────────────────────────────────────────────────
  static final List<JobOrder> jobOrders = [
    JobOrder(
      id: 'JO-001',
      ref: 'REF-001',
      deliveryDate: DateTime(2026, 4, 25),
      products: const [
        OrderProduct(name: 'Solar Panel 400W Mono', qty: 1000),
        OrderProduct(name: 'Solar Street Light 60W', qty: 500),
      ],
      planning: [
        ProductPlan(
          planned: 450,
          done: false,
          splits: [
            PlanSplit(
              priority: 'High',
              deadline: DateTime.now().add(const Duration(days: 3)),
            ),
          ],
        ),
        const ProductPlan(planned: 0, done: false),
      ],
    ),
    JobOrder(
      id: 'JO-002',
      ref: 'REF-002',
      deliveryDate: DateTime(2026, 4, 25),
      products: const [
        OrderProduct(name: 'Solar Water Pump 1HP', qty: 750),
        OrderProduct(name: 'Solar Home System 1kW', qty: 200),
      ],
      planning: [
        ProductPlan(
          planned: 750,
          done: true,
          splits: [
            PlanSplit(
              priority: 'Low',
              deadline: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
        ),
        ProductPlan(
          planned: 80,
          done: false,
          splits: [
            PlanSplit(
              priority: 'Medium',
              deadline: DateTime.now().add(const Duration(days: 10)),
            ),
          ],
        ),
      ],
    ),
  ];

  // ── Material Requests ──────────────────────────────────────────────────────
  static List<MaterialRequest> materialRequests = [
    MaterialRequest(
      id: 'MR-001',
      jobRef: 'JC-001',
      requestedBy: 'Rajan Kumar',
      status: 'approved',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
      itemName: 'Monocrystalline Silicon Cell 6"',
      qty: 36000,
      uom: 'pcs',
      items: [
        MaterialRequestItem(
          name: 'Monocrystalline Silicon Cell 6"',
          uom: 'pcs',
          required: 36000,
          available: 42000,
        ),
        MaterialRequestItem(
          name: 'EVA Encapsulant Film',
          uom: 'm²',
          required: 1960,
          available: 2400,
        ),
        MaterialRequestItem(
          name: 'MC4 Junction Box',
          uom: 'pcs',
          required: 500,
          available: 620,
        ),
      ],
    ),
    MaterialRequest(
      id: 'MR-002',
      jobRef: 'JC-003',
      requestedBy: 'Murugan S',
      status: 'pending',
      requestDate: DateTime.now(),
      itemName: 'LED Street Light Driver 60W',
      qty: 500,
      uom: 'pcs',
      items: [
        MaterialRequestItem(
          name: 'LED Street Light Driver 60W',
          uom: 'pcs',
          required: 500,
          available: 430,
        ),
        MaterialRequestItem(
          name: 'LiFePO4 Battery 60Ah',
          uom: 'pcs',
          required: 500,
          available: 560,
        ),
      ],
    ),
    MaterialRequest(
      id: 'MR-003',
      jobRef: 'JC-004',
      requestedBy: 'Rajan Industries',
      status: 'pending',
      requestDate: DateTime.now(),
      itemName: 'Steel Rod 20mm',
      qty: 1000,
      uom: 'Nos',
      items: [
        MaterialRequestItem(
          name: 'Steel Rod 20mm',
          uom: 'Nos',
          required: 1000,
          available: 450,
        ),
        MaterialRequestItem(
          name: 'Corner Bracket',
          uom: 'Nos',
          required: 400,
          available: 400,
        ),
        MaterialRequestItem(
          name: 'Welding Wire 1kg',
          uom: 'Nos',
          required: 200,
          available: 80,
        ),
      ],
    ),
  ];

  // ── QC Records ─────────────────────────────────────────────────────────────
  static List<QcRecord> qcRecords = [
    QcRecord(
      id: 'QC-001',
      productName: 'Solar Panel 400W Mono',
      jobRef: 'JC-001',
      inspector: 'Priya QC',
      status: 'completed',
      totalQty: 200,
      passQty: 192,
      failQty: 8,
      date: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    QcRecord(
      id: 'QC-002',
      productName: 'Solar Street Light 60W',
      jobRef: 'JC-003',
      inspector: 'Karthik QC',
      status: 'pending',
      totalQty: 150,
      passQty: 0,
      failQty: 0,
      date: DateTime.now(),
    ),
  ];
}