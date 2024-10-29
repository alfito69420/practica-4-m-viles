import 'package:p4pmsn/database/database_provider.dart';
import 'package:p4pmsn/model/usuario_model.dart';

class UsuarioDatabase {
  Future<int> insertUsuario(UsuarioModel usuario) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('usuario', {
      'id_usuario': usuario.id_usuario,
      'nombre': usuario.nombre,
      'apellido': usuario.apellido,
      'genero': usuario.genero,
    });
    return id;
  }

  Future<UsuarioModel?> getUsuario(int idUsuario) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'usuario',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
    );
    if (results.isNotEmpty) {
      return UsuarioModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<UsuarioModel>> getUsuarios() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('usuario');
    return results.map((usuario) => UsuarioModel.fromMap(usuario)).toList();
  }

  Future<int> updateUsuario(UsuarioModel usuario) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'usuario',
      {
        'id_usuario': usuario.id_usuario,
        'nombre': usuario.nombre,
        'apellido': usuario.apellido,
        'genero': usuario.genero,
      },
      where: 'id_usuario = ?',
      whereArgs: [usuario.id_usuario],
    );
  }

  Future<int> deleteUsuario(int idUsuario) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'usuario',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
    );
  }
}
