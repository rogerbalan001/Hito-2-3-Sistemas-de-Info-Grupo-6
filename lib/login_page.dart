import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/seed_service.dart';
import 'theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // Firebase responde de forma asíncrona, por eso esperamos (await).
    final error = await _auth.login(email, password);

    // Tras un await, el widget pudo haberse cerrado: validamos antes de usar context.
    if (!mounted) return;

    if (error == null) {
      // Siembra el catálogo de ejemplo la primera vez (idempotente y en
      // segundo plano: no demora la navegación). Requiere sesión activa.
      SeedService().seedAccommodationsIfEmpty();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión exitoso')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo en gradiente emerald -> azul -> púrpura, como en el diseño.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.emerald50, AppColors.blue50, AppColors.purple50],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Encabezado: ícono en caja redondeada + título.
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.emerald600,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.lock_outline,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Accede a tu cuenta para continuar',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                    const SizedBox(height: 28),

                    // Tarjeta del formulario.
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _fieldLabel('Correo Electrónico'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'correo@ejemplo.com',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _fieldLabel('Contraseña'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.mutedForeground,
                                ),
                                onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _login,
                              icon: const Icon(Icons.login, size: 20),
                              label: const Text('Iniciar Sesión'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          // Enlace para crear cuenta.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿No tienes cuenta?',
                                style: TextStyle(
                                    color: AppColors.mutedForeground,
                                    fontSize: 13),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/register'),
                                child: const Text(
                                  'Crear Cuenta',
                                  style: TextStyle(
                                    color: AppColors.emerald600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Caja de credenciales de demostración.
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.blue50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.blue200),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Credenciales de demostración:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blue700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Email: demo@correo.unimet.edu.ve\nPassword: demo123',
                                  style: TextStyle(
                                      fontSize: 11, color: AppColors.blue600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Al continuar, aceptas nuestros Términos de Servicio\ny Política de Privacidad',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
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
