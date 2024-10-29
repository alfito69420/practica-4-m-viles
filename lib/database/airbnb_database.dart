import 'package:p4pmsn/database/database_provider.dart';
import 'package:p4pmsn/model/airbnb_model.dart';

class AirbnbDatabase {
  Future<int> insertAirbnb(AirbnbModel airbnb) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('airbnb', {
      'id_airbnb': airbnb.id_airbnb,
      'descripcion': airbnb.descripcion,
      'direccion': airbnb.direccion,
      'habitaciones': airbnb.habitaciones,
      'banos': airbnb.banos,
      'precio_dia': airbnb.precio_dia,
      'id_categoria': airbnb.id_categoria,
    });
    return id;
  }

  Future<AirbnbModel?> getAirbnb(int idAirbnb) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'airbnb',
      where: 'id_airbnb = ?',
      whereArgs: [idAirbnb],
    );
    if (results.isNotEmpty) {
      return AirbnbModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<AirbnbModel>> getAirbnbByCategoria(int idCategoria) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'airbnb',
      where: 'id_categoria = ?',
      whereArgs: [idCategoria],
    );
    return results.map((airbnb) => AirbnbModel.fromMap(airbnb)).toList();
  }
  

  Future<List<AirbnbModel>> getAirbnbs() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('airbnb');
    return results.map((airbnb) => AirbnbModel.fromMap(airbnb)).toList();
  }

  Future<int> updateAirbnb(AirbnbModel airbnb) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'airbnb',
      {
        'id_airbnb': airbnb.id_airbnb,
        'descripcion': airbnb.descripcion,
        'direccion': airbnb.direccion,
        'habitaciones': airbnb.habitaciones,
        'banos': airbnb.banos,
        'precio_dia': airbnb.precio_dia,
        'id_categoria': airbnb.id_categoria,
      },
      where: 'id_airbnb = ?',
      whereArgs: [airbnb.id_airbnb],
    );
  }

  Future<int> deleteAirbnb(int idAirbnb) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'airbnb',
      where: 'id_airbnb = ?',
      whereArgs: [idAirbnb],
    );
  }
}
