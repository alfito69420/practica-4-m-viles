class ReservacionModel {
  int? id_reservacion;
  DateTime? fecha_ini;
  DateTime? fecha_fini;
  String? estatus;
  int? habitaciones;
  int? id_usuario;
  int? id_airbnb;

  ReservacionModel({
    this.id_reservacion,
    this.fecha_ini,
    this.fecha_fini,
    this.estatus,
    this.habitaciones,
    this.id_usuario,
    this.id_airbnb,
  });

  factory ReservacionModel.fromMap(Map<String, dynamic> reservacion) {
    return ReservacionModel(
      id_reservacion: reservacion['id_reservacion'],
      fecha_ini: DateTime.parse(reservacion['fecha_ini']),
      fecha_fini: DateTime.parse(reservacion['fecha_fini']),
      estatus: reservacion['estatus'],
      habitaciones: reservacion['habitaciones'],
      id_usuario: reservacion['id_usuario'],
      id_airbnb: reservacion['id_airbnb'],
    );
  }
}
