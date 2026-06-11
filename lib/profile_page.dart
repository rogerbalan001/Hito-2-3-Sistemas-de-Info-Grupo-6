import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'services/session.dart';
import 'theme/app_theme.dart';
import 'add_accommodation_page.dart';

/// MÓDULO "Perfil de Usuario" (Hito 2).
/// Lee los datos del usuario logueado (email vía AuthService, datos extra vía
/// ProfileService/Firestore) y permite editar nombre, teléfono y rol.
/// El rol (Viajero / Operador turístico) prepara la gestión de roles a futuro.
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthService();
  final _profile = ProfileService();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();

  static const _roles = ['Viajero', 'Operador turístico'];
  String _rol = 'Viajero';

  // Modo de la app: true = Administrador, false = Viajero.
  bool _esAdmin = Session.isAdmin.value;

  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    final datos = await _profile.obtenerPerfil();
    if (!mounted) return;
    setState(() {
      // Si no hay perfil guardado aún, usamos el displayName de la cuenta.
      _nombreController.text =
          (datos?['nombre'] as String?) ?? (_auth.currentUser?.displayName ?? '');
      _telefonoController.text = (datos?['telefono'] as String?) ?? '';
      final rolGuardado = datos?['rol'] as String?;
      if (rolGuardado != null && _roles.contains(rolGuardado)) {
        _rol = rolGuardado;
      }
      // Sincroniza el modo de la app (admin/viajero) con lo guardado.
      _esAdmin = (datos?['modo'] as String?) == 'admin';
      Session.setAdmin(_esAdmin);
      _cargando = false;
    });
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _guardar() async {
    final nombre = _nombreController.text.trim();
    final telefono = _telefonoController.text.trim();

    if (nombre.isEmpty) {
      _showMessage('El nombre no puede estar vacío');
      return;
    }

    setState(() => _guardando = true);
    try {
      await _profile.guardarPerfil(
        nombre: nombre,
        telefono: telefono,
        rol: _rol,
      );
      _showMessage('Perfil actualizado correctamente');
    } catch (e) {
      _showMessage('No se pudo guardar el perfil: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  /// Cambia el modo de la app. Para activar Administrador pide la contraseña;
  /// para volver a Viajero no pide nada.
  Future<void> _cambiarModo(bool admin) async {
    if (admin == _esAdmin) return;

    if (admin) {
      final ok = await _pedirPasswordAdmin();
      if (ok != true) return;
    }

    Session.setAdmin(admin);
    setState(() => _esAdmin = admin);
    try {
      await _profile.guardarModo(admin ? 'admin' : 'viajero');
    } catch (_) {
      // Aunque falle la persistencia, el modo ya se aplicó en esta sesión.
    }
    _showMessage(admin
        ? 'Modo Administrador activado'
        : 'Modo Viajero activado');
  }

  /// Diálogo que solicita la contraseña de administrador.
  Future<bool?> _pedirPasswordAdmin() {
    final controller = TextEditingController();
    String? error;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Modo Administrador'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Ingresa la contraseña para activar el modo '
                      'administrador.'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    obscureText: true,
                    autofocus: true,
                    onSubmitted: (_) {
                      if (controller.text == Session.adminPassword) {
                        Navigator.pop(dialogContext, true);
                      } else {
                        setStateDialog(
                            () => error = 'Contraseña incorrecta');
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text == Session.adminPassword) {
                      Navigator.pop(dialogContext, true);
                    } else {
                      setStateDialog(
                          () => error = 'Contraseña incorrecta');
                    }
                  },
                  child: const Text('Activar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? 'Sin sesión';
    final base =
        _nombreController.text.isNotEmpty ? _nombreController.text : email;
    final inicial = base.substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: AppColors.emerald700),
            onPressed: () async {
              await _auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Avatar con la inicial.
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.emerald100,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    email,
                    style: const TextStyle(
                        color: AppColors.mutedForeground, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),

                const _Label('Nombre completo'),
                TextField(
                  controller: _nombreController,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}), // refresca la inicial
                  decoration: const InputDecoration(
                    hintText: 'Tu nombre',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),

                const _Label('Teléfono'),
                TextField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+58 ...',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                const _Label('Tipo de cuenta'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _rol,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.mutedForeground),
                      items: _roles
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _rol = val ?? _rol),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    child: _guardando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Guardar cambios'),
                  ),
                ),

                // Selector de MODO de la aplicación.
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                const _Label('Modo de la aplicación'),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _ModoBtn(
                        label: 'Viajero',
                        icon: Icons.luggage_outlined,
                        active: !_esAdmin,
                        onTap: () => _cambiarModo(false),
                      ),
                      _ModoBtn(
                        label: 'Administrador',
                        icon: Icons.admin_panel_settings_outlined,
                        active: _esAdmin,
                        onTap: () => _cambiarModo(true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _esAdmin
                      ? 'Ves todas las pestañas, incluidas Operadores, '
                          'Dashboard y Administración.'
                      : 'Modo viajero: no se muestran Operadores, Dashboard '
                          'ni Administración.',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.mutedForeground),
                ),

                // Acceso al módulo de publicación (operadores).
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.emerald50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_business_outlined,
                        color: AppColors.emerald700),
                  ),
                  title: const Text('Publicar un alojamiento',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                    'Para operadores: registra tu posada, camping o cabaña.',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddAccommodationPage()),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}

/// Botón segmentado para elegir el modo (Viajero / Administrador).
class _ModoBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ModoBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: active ? AppColors.emerald600 : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: active ? Colors.white : AppColors.mutedForeground),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
