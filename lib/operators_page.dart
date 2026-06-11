import 'package:flutter/material.dart';
import 'data/mock_data.dart';
import 'models/accommodation.dart';
import 'theme/app_theme.dart';

/// Gestión de Publicaciones: operadores locales registran sus servicios.
class OperatorsPage extends StatefulWidget {
  const OperatorsPage({Key? key}) : super(key: key);
  @override
  State<OperatorsPage> createState() => _OperatorsPageState();
}

class _OperatorsPageState extends State<OperatorsPage> {
  final List<OperatorInfo> _operators = [...MockData.operators];
  bool _showForm = false;

  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  final _servicio = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _telefono.dispose();
    _servicio.dispose();
    super.dispose();
  }

  void _registrar() {
    if (_nombre.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _servicio.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios')),
      );
      return;
    }
    setState(() {
      _operators.add(OperatorInfo(
        id: 'op-${DateTime.now().millisecondsSinceEpoch}',
        name: _nombre.text.trim(),
        email: _email.text.trim(),
        phone: _telefono.text.trim(),
        services: 1,
        verified: false,
      ));
      _nombre.clear();
      _email.clear();
      _telefono.clear();
      _servicio.clear();
      _showForm = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Servicio registrado. Pendiente de verificación.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestión de Publicaciones',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Operadores locales pueden registrar sus servicios',
                      style: TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => setState(() => _showForm = !_showForm),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Registrar Servicio'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_showForm) _buildForm(),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth >= 980 ? 3 : (c.maxWidth >= 640 ? 2 : 1);
          final w = (c.maxWidth - 16 * (cols - 1)) / cols;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _operators
                .map((op) => SizedBox(width: w, child: _OperatorCard(op: op)))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nuevo Servicio Turístico',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _nombre,
            decoration: const InputDecoration(
              labelText: 'Nombre del Operador *',
              prefixIcon: Icon(Icons.business_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email *',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telefono,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _servicio,
            decoration: const InputDecoration(
              labelText: 'Nombre del Servicio *',
              prefixIcon: Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _registrar,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Registrar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperatorCard extends StatelessWidget {
  final OperatorInfo op;
  const _OperatorCard({required this.op});

  @override
  Widget build(BuildContext context) {
    final servicios = MockData.accommodations
        .where((a) => a.operatorId == op.id)
        .toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(op.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              _VerifiedBadge(verified: op.verified),
            ],
          ),
          const SizedBox(height: 10),
          _IconLine(icon: Icons.mail_outline, text: op.email),
          const SizedBox(height: 4),
          _IconLine(icon: Icons.phone_outlined, text: op.phone),
          const SizedBox(height: 4),
          _IconLine(
              icon: Icons.place_outlined,
              text: '${op.services} servicio(s) registrado(s)'),
          if (servicios.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            const Text('Servicios:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...servicios.map((Accommodation a) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(a.name,
                            style: const TextStyle(fontSize: 13)),
                      ),
                      Text('\$${a.pricePerNight.round()}/n',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.emerald700)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final bool verified;
  const _VerifiedBadge({required this.verified});
  @override
  Widget build(BuildContext context) {
    final color = verified ? AppColors.emerald700 : AppColors.amber600;
    final bg = verified ? AppColors.emerald50 : const Color(0xFFFFFBEB);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(verified ? Icons.check_circle_outline : Icons.error_outline,
              size: 12, color: color),
          const SizedBox(width: 4),
          Text(verified ? 'Verificado' : 'Pendiente',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconLine({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.mutedForeground),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.mutedForeground)),
        ),
      ],
    );
  }
}
