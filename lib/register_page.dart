import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Por favor completa todos los campos');
      return;
    }
    // El viajero (Unimetano) debe usar un correo institucional.
    if (!email.toLowerCase().endsWith('@unimet.edu.ve')) {
      _showMessage('El correo debe terminar en @unimet.edu.ve');
      return;
    }
    if (password.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    // Firebase responde de forma asíncrona, por eso esperamos (await).
    final error = await _auth.register(email, password);

    // Tras un await, el widget pudo haberse cerrado: validamos antes de usar context.
    if (!mounted) return;

    if (error != null) {
      _showMessage(error);
      return;
    }

    _showMessage('Cuenta creada exitosamente');
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta'), backgroundColor: Colors.green[800]),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo Electrónico (@unimet.edu.ve)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña (mín. 6 caracteres)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green[700]),
              onPressed: _register,
              child: const Text('Registrarse', style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}
