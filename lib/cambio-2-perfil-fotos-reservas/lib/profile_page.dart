import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/auth_service.dart';
import 'services/image_upload_service.dart';
import 'services/profile_service.dart';
import 'services/session.dart';
import 'theme/app_theme.dart';
import 'add_accommodation_page.dart';

/// MÓDULO "Perfil de Usuario" (Hito 2, extendido).
/// Lee los datos del usuario logueado (email vía AuthService, datos extra vía
/// ProfileService/Firestore) y permite editar nombre, teléfono, rol, foto de
/// perfil, dirección, género, ocupación, fecha de nacimiento y una breve
/// biografía. El rol (Viajero / Operador turístico) prepara la gestión de
/// roles a futuro.
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthService();
  final _profile = ProfileService();
  final _images = ImageUploadService();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ocupacionController = TextEditingController();
  final _biografiaController = TextEditingController();

  static const _roles = ['Viajero', 'Operador turístico'];
  String _rol = 'Viajero';

  static const _generos = [
    'Femenino',
    'Masculino',
    'Otro',
    'Prefiero no decirlo',
  ];
  String? _genero;

  DateTime? _fechaNacimiento;

  // Foto de perfil: la que ya estaba guardada (URL) o una nueva elegida en
  // esta sesión de edición (XFile), todavía sin subir.
  String? _fotoUrlActual;
  XFile? _fotoNueva;
  bool _subiendoFoto = false;

  // Tipo de cuenta (solo lectura): true = Administrador, false = Viajero.
  // Lo determina el backend (AuthService.isCurrentUserAdmin); el usuario NO
  // puede cambiarlo desde la interfaz.
  bool _esAdmin = AuthService().isCurrentUserAdmin;

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
    _direccionController.dispose();
    _ocupacionController.dispose();
    _biografiaController.dispose();
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
      _direccionController.text = (datos?['direccion'] as String?) ?? '';
      _ocupacionController.text = (datos?['ocupacion'] as String?) ?? '';
      _biografiaController.text = (datos?['biografia'] as String?) ?? '';
      final rolGuardado = datos?['rol'] as String?;
      if (rolGuardado != null && _roles.contains(rolGuardado)) {
        _rol = rolGuardado;
      }
      final generoGuardado = datos?['genero'] as String?;
      if (generoGuardado != null && _generos.contains(generoGuardado)) {
        _genero = generoGuardado;
      }
      final fechaGuardada = datos?['fechaNacimiento'] as String?;
      if (fechaGuardada != null) {
        _fechaNacimiento = DateTime.tryParse(fechaGuardada);
      }
      _fotoUrlActual =
          (datos?['fotoUrl'] as String?) ?? _auth.currentUser?.photoURL;
      // El tipo de cuenta lo decide el backend según el correo, no el perfil.
      _esAdmin = AuthService().isCurrentUserAdmin;
      Session.setAdmin(_esAdmin);
      _cargando = false;
    });
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _elegirFoto() async {
    final foto = await _images.seleccionarImagen();
    if (foto == null) return;
    setState(() => _fotoNueva = foto);
  }

  Future<void> _elegirFechaNacimiento() async {
    final ahora = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(ahora.year - 20),
      firstDate: DateTime(1930),
      lastDate: ahora,
      helpText: 'Fecha de nacimiento',
    );
    if (elegida != null) {
      setState(() => _fechaNacimiento = elegida);
    }
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
      // Si se eligió una foto nueva, se sube primero a Storage.
      String? fotoUrl;
      if (_fotoNueva != null) {
        setState(() => _subiendoFoto = true);
        final uid = _auth.currentUser?.uid;
        if (uid != null) {
          fotoUrl = await _images.subirFotoPerfil(_fotoNueva!, uid);
        }
        if (mounted) setState(() => _subiendoFoto = false);
      }

      await _profile.guardarPerfil(
        nombre: nombre,
        telefono: telefono,
        rol: _rol,
        fotoUrl: fotoUrl,
        direccion: _direccionController.text.trim(),
        genero: _genero,
        ocupacion: _ocupacionController.text.trim(),
        fechaNacimiento: _fechaNacimiento?.toIso8601String(),
        biografia: _biografiaController.text.trim(),
      );
      if (fotoUrl != null) {
        setState(() {
          _fotoUrlActual = fotoUrl;
          _fotoNueva = null;
        });
      }
      _showMessage('Perfil actualizado correctamente');
    } catch (e) {
      _showMessage('No se pudo guardar el perfil: $e');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
          _subiendoFoto = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Guardia defensiva: si por alguna razón se llega aquí sin sesión activa
    // (por ejemplo, una sesión que expiró mientras la pantalla ya estaba
    // abierta), no se ofrece edición de perfil. El punto de entrada normal
    // ("Mi Perfil" en el menú de usuario) ya está oculto sin sesión, pero
    // esta pantalla no depende solo de eso para protegerse.
    if (_auth.currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 48, color: AppColors.mutedForeground),
                const SizedBox(height: 12),
                const Text(
                  'Debes iniciar sesión para ver o editar tu perfil.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Iniciar Sesión'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                // Avatar: foto de perfil si existe, o la inicial. Se toca
                // para elegir/cambiar la foto.
                Center(
                  child: GestureDetector(
                    onTap: _subiendoFoto ? null : _elegirFoto,
                    child: Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: AppColors.emerald100,
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          alignment: Alignment.center,
                          child: _fotoNueva != null
                              ? Image.network(_fotoNueva!.path,
                                  width: 88, height: 88, fit: BoxFit.cover)
                              : (_fotoUrlActual != null &&
                                      _fotoUrlActual!.isNotEmpty)
                                  ? Image.network(_fotoUrlActual!,
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Text(
                                        inicial,
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.emerald700,
                                        ),
                                      ))
                                  : Text(
                                      inicial,
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.emerald700,
                                      ),
                                    ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.emerald600,
                              shape: BoxShape.circle,
                            ),
                            child: _subiendoFoto
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.camera_alt_outlined,
                                    size: 14, color: Colors.white),
                          ),
                        ),
                      ],
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

                const _Label('Dirección'),
                TextField(
                  controller: _direccionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Calle, sector, ciudad',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                const _Label('Ocupación'),
                TextField(
                  controller: _ocupacionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Estudiante, Ingeniero/a, Comerciante',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                ),
                const SizedBox(height: 16),

                const _Label('Género'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _genero,
                      isExpanded: true,
                      hint: const Text('Selecciona una opción'),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.mutedForeground),
                      items: _generos
                          .map((g) =>
                              DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) => setState(() => _genero = val),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const _Label('Fecha de nacimiento'),
                InkWell(
                  onTap: _elegirFechaNacimiento,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cake_outlined,
                            size: 18, color: AppColors.mutedForeground),
                        const SizedBox(width: 10),
                        Text(
                          _fechaNacimiento == null
                              ? 'Sin definir'
                              : '${_fechaNacimiento!.day.toString().padLeft(2, '0')}/'
                                  '${_fechaNacimiento!.month.toString().padLeft(2, '0')}/'
                                  '${_fechaNacimiento!.year}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const _Label('Biografía'),
                TextField(
                  controller: _biografiaController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Cuéntanos un poco sobre ti (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                const _Label('Tipo de cuenta'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emerald200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _esAdmin
                            ? Icons.admin_panel_settings_outlined
                            : Icons.luggage_outlined,
                        size: 18,
                        color: AppColors.emerald700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _esAdmin ? 'Administrador' : 'Viajero',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.emerald700,
                        ),
                      ),
                    ],
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

                // Nota sobre el modo administrador (solo informativa).
                // El acceso de administrador lo concede el backend según el
                // correo autorizado; no se puede activar desde aquí.
                const SizedBox(height: 16),
                Text(
                  _esAdmin
                      ? 'Cuenta de administrador: ves todas las pestañas, '
                          'incluidas Operadores, Dashboard y Administración.'
                      : 'Cuenta de viajero: el acceso de administrador está '
                          'restringido a cuentas autorizadas.',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.mutedForeground),
                ),

                // Acceso al módulo de publicación (operadores/admin).
                if (_esAdmin) ...[
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
                      'Registra tu posada, camping, cabaña u otro alojamiento.',
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
