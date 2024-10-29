import 'package:p4pmsn/database/database_provider.dart';
import 'package:p4pmsn/model/alarma_model.dart';

class AlarmaDatabase {
  Future<int> insertAlarma(AlarmaModel alarma) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('alarma', {
      'id_alarma': alarma.id_alarma,
      'fecha': alarma.fecha?.toIso8601String(),
      'descripcion': alarma.descripcion,
      'id_reservacion': alarma.id_reservacion,
    });
    return id;
  }

  Future<AlarmaModel?> getAlarma(int alarmaId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'alarma',
      where: 'id_alarma = ?',
      whereArgs: [alarmaId],
    );
    if (results.isNotEmpty) {
      return AlarmaModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<AlarmaModel>> getAlarmas() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('alarma');
    return results.map((alarma) => AlarmaModel.fromMap(alarma)).toList();
  }

  Future<int> updateAlarma(AlarmaModel alarma) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'alarma',
      {
        'id_alarma': alarma.id_alarma,
        'fecha': alarma.fecha?.toIso8601String(),
        'descripcion': alarma.descripcion,
        'id_reservacion': alarma.id_reservacion,
      },
      where: 'id_alarma = ?',
      whereArgs: [alarma.id_alarma],
    );
  }

  Future<int> deleteAlarma(int alarmaId) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'alarma',
      where: 'id_alarma = ?',
      whereArgs: [alarmaId],
    );
  }
}
