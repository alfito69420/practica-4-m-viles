class AlarmaModel {
  int? id_alarma;
  DateTime? fecha;
  String? descripcion;
  int? id_reservacion;
  
  AlarmaModel({
    this.id_alarma,
    this.fecha,
    this.descripcion,
    this.id_reservacion,
  });

  factory AlarmaModel.fromMap(Map<String, dynamic> alarma) {
    return AlarmaModel(
      id_alarma: alarma['id_alarma'],
      fecha: DateTime.parse(alarma['fecha']),
      descripcion: alarma['descripcion'],
      id_reservacion: alarma['id_reservacion'],
    );
  }
}
