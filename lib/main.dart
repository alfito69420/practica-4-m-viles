import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:p4pmsn/extras/navbar.dart';
import 'package:p4pmsn/extras/notification_methods.dart';
import 'package:p4pmsn/screen/detalle_reservacion_screen.dart';
import 'package:p4pmsn/screen/historial_screen.dart';
import 'package:p4pmsn/screen/reservaciones_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  await initializeDateFormatting('es_MX', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AirBnB App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Navbar(),
      routes: {
        '/nav': (context) => Navbar(),
        '/calendario': (context) => ReservacionesScreen(),
        '/historial': (context) => HistorialScreen(),
        // Ruta para la pantalla de historial
        '/reservacion': (context) => DetalleReservacionScreen(),
        // Ruta para la pantalla de detalle
      },
    );
  }
}
