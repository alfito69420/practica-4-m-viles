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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF64CCF2),
        currentIndex: selectedIndex,
        elevation: 0,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month,color: Colors.white,),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.white),
            label: 'Historial',
          )
        ],
      ),
    );
  }
}
