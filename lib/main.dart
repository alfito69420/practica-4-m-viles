import 'package:flutter/material.dart';
import 'package:p4pmsn/extras/notification_methods.dart';
import 'package:p4pmsn/screen/reservaciones_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  initializeDateFormatting('es_ES', null).then((_) {
    runApp(MyApp());
  });
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
      home: ReservacionesScreen(),
      //initialRoute: '/eventos', // Ruta inicial
      // routes: {
      //   '/nav': (context) => NavigationBarApp(),
      //   '/eventos': (context) => EventosScreen(),
      //   '/historial': (context) => HistorialRentasScreen(), // Ruta para la pantalla de historial de rentas
      //   '/detalleR': (context) => DetalleRentaScreen(), // Ruta para la pantalla de detalle de renta
      //   '/agregarRenta': (context)=> AgregarRentaScreen(),
      // },
    );
  }
}
