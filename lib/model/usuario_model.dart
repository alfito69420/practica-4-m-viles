class UsuarioModel {
  int? id_usuario;
  String? nombre;
  String? apellido;
  String? genero;

  UsuarioModel({this.id_usuario, this.nombre, this.apellido, this.genero});

  factory UsuarioModel.fromMap(Map<String, dynamic> usuario) {
    return UsuarioModel(
      id_usuario: usuario['id_usuario'],
      nombre: usuario['nombre'],
      apellido: usuario['apellido'],
      genero: usuario['genero'],
    );
  }
}
