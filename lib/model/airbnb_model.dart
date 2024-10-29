class AirbnbModel {
  int? id_airbnb;
  String? descripcion;
  String? direccion;
  int? habitaciones;
  int? banos;
  double? precio_dia;
  int? id_categoria;

  AirbnbModel({
    this.id_airbnb, 
    this.descripcion, 
    this.direccion, 
    this.habitaciones, 
    this.banos, 
    this.precio_dia, 
    this.id_categoria
  });

  factory AirbnbModel.fromMap(Map<String, dynamic> airbnb) {
    return AirbnbModel(
      id_airbnb: airbnb['id_airbnb'],
      descripcion: airbnb['descripcion'],
      direccion: airbnb['direccion'],
      habitaciones: airbnb['habitaciones'],
      banos: airbnb['banos'],
      precio_dia: airbnb['precio_dia'],
      id_categoria: airbnb['id_categoria'],
    );
  }
}
