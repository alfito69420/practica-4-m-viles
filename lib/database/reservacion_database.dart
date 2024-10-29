import 'package:p4pmsn/database/database_provider.dart';
import 'package:p4pmsn/model/reservacion_model.dart';

class ReservacionDatabase {
  Future<int> insertReservacion(ReservacionModel reservacion) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('reservacion', {
      'fecha_ini': reservacion.fecha_ini.toString(),
      'fecha_fini': reservacion.fecha_fini.toString(),
      'estatus': reservacion.estatus,
      'habitaciones': reservacion.habitaciones,
      'id_usuario': reservacion.id_usuario,
      'id_airbnb': reservacion.id_airbnb,
    });
    return id;
  }

  Future<ReservacionModel?> getReservacion(int idReservacion) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'reservacion',
      where: 'id_reservacion = ?',
      whereArgs: [idReservacion],
    );
    if (results.isNotEmpty) {
      return ReservacionModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<ReservacionModel>> getReservaciones() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('reservacion');
    return results.map((reservacion) => ReservacionModel.fromMap(reservacion)).toList();
  }

  Future<List<ReservacionModel>> getReservacionesByFecha(String fecha) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('reservacion',where:'SUBSTR(fecha_ini, 1, 10) LIKE ?',whereArgs: [fecha],orderBy: 'fecha_ini');
    return results.map((reservacion) => ReservacionModel.fromMap(reservacion)).toList();
  }

  Future<int> updateReservacion(ReservacionModel reservacion) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'reservacion',
      {
        'fecha_ini': reservacion.fecha_ini.toString(),
        'fecha_fini': reservacion.fecha_fini.toString(),
        'estatus': reservacion.estatus,
        'habitaciones': reservacion.habitaciones,
        'id_usuario': reservacion.id_usuario,
        'id_airbnb': reservacion.id_airbnb,
      },
      where: 'id_reservacion = ?',
      whereArgs: [reservacion.id_reservacion],
    );
  }

  Future<int> deleteReservacion(int idReservacion) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'reservacion',
      where: 'id_reservacion = ?',
      whereArgs: [idReservacion],
    );
  }

  Future<List<ReservacionModel>> getReservacionesByUsuario(int usuarioId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'reservacion',
      where: 'id_usuario = ?',
      whereArgs: [usuarioId],
    );
    return results.map((reservacion) => ReservacionModel.fromMap(reservacion)).toList();
  }

  Future<List<ReservacionModel>> getReservacionesByStatus(String status) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'reservacion',
      where: 'estatus = ?',
      whereArgs: [status],
    );
    return results.map((reservacion) => ReservacionModel.fromMap(reservacion)).toList();
  }

}
