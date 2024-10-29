import 'dart:collection';
import 'package:p4pmsn/database/reservacion_database.dart';
import 'package:p4pmsn/database/usuario_database.dart';
import 'package:p4pmsn/extras/app_notifier.dart';
import 'package:table_calendar/table_calendar.dart';

class Reservation {
  final String title;

  const Reservation(this.title);

  @override
  String toString() => title;
}

ReservacionDatabase reservacionDB = new ReservacionDatabase();
UsuarioDatabase usuarioDatabase = new UsuarioDatabase();

final kReservs = LinkedHashMap<DateTime, List<Reservation>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

void cargarReservaciones() async {
  kReservs.clear();
  final eventos = await reservacionDB.getReservaciones();
  for (var evento in eventos) {
    final date = (evento.fecha_ini!);
    final userReserv = await usuarioDatabase.getUsuario(evento.id_usuario!); // Saca el usuario k hizo reserv.
    if (kReservs[date] == null) {
      kReservs[date] = [];
    }
    kReservs[date]!.add(Reservation('Reservación de ${userReserv!.nombre} ${userReserv!.apellido}'));
  }
  AppNotifier.banEvents.value = !AppNotifier.banEvents.value;
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);