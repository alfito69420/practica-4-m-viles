import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final String dbName = 'AirbnbDB';
  static final int dbVersion = 1;
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    return _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    Directory folder = await getApplicationDocumentsDirectory();
    String pathDB = join(folder.path, dbName);
    return openDatabase(
      pathDB,
      version: dbVersion,
      onCreate: (db, version) async {
        // TABLAS
        await db.execute('''
          CREATE TABLE usuario (
            id_usuario INTEGER PRIMARY KEY,
            nombre TEXT,
            apellido TEXT,
            genero TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE categoria (
            id_categoria INTEGER PRIMARY KEY,
            categoria TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE airbnb (
            id_airbnb INTEGER PRIMARY KEY,
            descripcion TEXT,
            direccion TEXT,
            habitaciones INTEGER,
            banos INTEGER,
            precio_dia REAL,
            id_categoria INTEGER,
            FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria)
          )
        ''');
        
        await db.execute('''
          CREATE TABLE reservacion (
            id_reservacion INTEGER PRIMARY KEY,
            fecha_ini TEXT,
            fecha_fini TEXT,
            estatus TEXT,
            habitaciones INTEGER,
            id_usuario INTEGER,
            id_airbnb INTEGER,
            FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
            FOREIGN KEY (id_airbnb) REFERENCES airbnb (id_airbnb)
          )
        ''');

        await db.execute('''
          CREATE TABLE alarma (
            id_alarma INTEGER PRIMARY KEY,
            fecha TEXT,
            descripcion TEXT,
            id_reservacion INTEGER,
            FOREIGN KEY (id_reservacion) REFERENCES reservacion (id_reservacion)
          )
        ''');

        //INSERCIONES 
        // Usuarios
        await db.execute('''
          INSERT INTO usuario (nombre, apellido, genero) VALUES
          ('Gustavo', 'Martínez', 'Masculino'),
          ('Marta', 'Hernández', 'Femenino'),
          ('Luis Alberto', 'López', 'Masculino'),
          ('Elisa', 'Granados', 'Femenino'),
          ('Andrés', 'Cantera', 'Masculino')
        ''');

        // Categorías
        await db.execute('''
          INSERT INTO categoria (categoria) VALUES
          ('Departamento'),
          ('Casa'),
          ('Habitación privada')
        ''');

        // AirBnB
        await db.execute('''
          INSERT INTO airbnb (descripcion, direccion, habitaciones, banos, precio_dia, id_categoria) VALUES
          ('Departamento moderno en el centro', 'Jacales 87, Salamanchester', 2, 1, 50.0, 1),
          ('Casa familiar con jardín', 'Avenida Tulipanes 456, Irakpuato', 5, 3, 450.0, 2),
          ('Habitación en condominio de lujo', 'Ruta Bruselas 920, Leondres', 1, 1, 75.0, 3),
          ('Habitación privada en el centro de Celayork', 'Zicarinas 101, Celayork', 1, 1, 50.0, 3),
          ('Casa pequeña amueblada en ', 'Puebletas de Aldama 886, Guanawashington', 3, 1, 250.0, 2),
          ('Departamento donde se hospedó Jenni Rivera', 'Azalea 33A, Silaodelphia', 2, 1, 150.0, 1),
          ('Casa grande y colonial en las afueras de la ciudad', 'De La Plata 145, Celayork', 5, 4, 1000.0, 2)
        ''');

        // Reservaciones
        await db.execute('''
          INSERT INTO reservacion (fecha_ini, fecha_fini, estatus, habitaciones, id_usuario, id_airbnb) VALUES
          ('2024-10-28', '2024-11-02', 'Confirmada', 2, 1, 1),
          ('2024-10-30', '2024-11-05', 'Confirmada', 5, 2, 2),
          ('2024-11-01', '2024-11-07', 'Cancelada', 1, 3, 3),
          ('2024-11-03', '2024-11-08', 'En proceso', 1, 4, 4),
          ('2024-11-05', '2024-11-10', 'Confirmada', 3, 5, 5),
          ('2024-11-07', '2024-11-12', 'Confirmada', 2, 1, 6),
          ('2024-11-10', '2024-11-15', 'Confirmada', 5, 2, 7)
        ''');

        // Alarmas
        await db.execute('''
          INSERT INTO alarma (fecha, descripcion, id_reservacion) VALUES
            ('2024-10-26', 'Recordatorio de reservación para el Departamento moderno en el centro', 1),
            ('2024-10-28', 'Recordatorio de reservación para la Casa familiar con jardín', 2),
            ('2024-10-30', 'Recordatorio de reservación para la Habitación en condominio de lujo', 3),
            ('2024-11-01', 'Recordatorio de reservación para la Habitación privada en el centro de Celayork', 4),
            ('2024-11-03', 'Recordatorio de reservación para la Casa pequeña amueblada', 5),
            ('2024-11-05', 'Recordatorio de reservación para el Departamento donde se hospedó Jenni Rivera', 6),
            ('2024-11-08', 'Recordatorio de reservación para la Casa grande y colonial en las afueras de la ciudad', 7)
          ''');
      },
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}


