import 'package:flutter/material.dart';
import 'package:p4pmsn/screen/historial_screen.dart';
import 'package:p4pmsn/screen/reservaciones_screen.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavigationBarAppState();
}

class _NavigationBarAppState extends State<Navbar> {
  int selectedIndex = 0;
  final screens = [ReservacionesScreen(), HistorialScreen()];

  // Clave para el Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Reservaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE30F2C),
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Abre el drawer
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      drawer: myDrawer(),
    );
  }

  Widget myDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFFE0F3F)),
            currentAccountPicture: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: const Image(image: AssetImage("assets/airbnb.jpg"))),
            accountName: const Text("AirB&B"),
            accountEmail: const Text("Practica 4"),
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, "/historial");
            },
            title: const Text("Historial"),
            subtitle: const Text("Tus eventos pendientes"),
            leading: const Icon(Icons.history),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
          ),
        ],
      ),
    );
  }
}
