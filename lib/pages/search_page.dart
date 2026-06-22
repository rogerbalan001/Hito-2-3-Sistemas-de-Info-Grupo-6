bool _isLoading = false;
String? _errorMessage;

Future<void> _buscar() async {
  setState(() { _isLoading = true; _errorMessage = null; });
  try {
    final resultados = await AccommodationRepository().search(
      destino: _destinoController.text,
      presupuestoMax: _presupuesto,
    );
    setState(() { _resultados = resultados; });
  } catch (e) {
    setState(() { _errorMessage = e.toString(); });
  } finally {
    setState(() { _isLoading = false; });
  }
}

// En el build(): mostrar CircularProgressIndicator si _isLoading,
// o Text(_errorMessage) si _errorMessage != null, antes de renderizar la lista.
