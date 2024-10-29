import 'dart:async';
import 'dart:math';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:p4pmsn/database/airbnb_database.dart';
import 'package:p4pmsn/database/reservacion_database.dart';
import 'package:p4pmsn/database/usuario_database.dart';
import 'package:p4pmsn/extras/app_notifier.dart';
import 'package:p4pmsn/extras/extras.dart';
import 'package:p4pmsn/extras/notification_methods.dart';
import 'package:p4pmsn/model/airbnb_model.dart';
import 'package:p4pmsn/model/reservacion_model.dart';
import 'package:p4pmsn/model/usuario_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';

class ReservacionesScreen extends StatefulWidget {
  const ReservacionesScreen({Key? key}) : super(key: key);

  @override
  State<ReservacionesScreen> createState() => _ReservacionesScreenState();
}

class _ReservacionesScreenState extends State<ReservacionesScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  ReservacionDatabase? reservacionDB;
  UsuarioDatabase? usuarioDatabase;
  AirbnbDatabase? airbnbDatabase;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel platform =
      MethodChannel('com.example.app/timezone');

  late tz.Location
      _local; // Almacenar la ubicación de la zona horaria

  @override
  void initState() {
    initializeNotifications();
    configureLocalTimeZone(); // Inicializar la zona horaria
    reservacionDB = ReservacionDatabase();
    usuarioDatabase = UsuarioDatabase();
    airbnbDatabase = AirbnbDatabase();
    cargarReservaciones();
    _selectedDay = _focusedDay;

    super.initState();
  }

  List<Reservation> _getReservsPerDay(DateTime day) {
    return kReservs[day] ?? [];
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    // Establecer la zona horaria de México (América/Mexico_City)
    _local = tz.getLocation(
        'America/Mexico_City'); // Obtener la ubicación de la zona horaria de México
    tz.setLocalLocation(
        _local); // Establecer la ubicación local en la zona horaria de México
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reservaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: ValueListenableBuilder(
        valueListenable: AppNotifier.banEvents,
        builder: (context, value, _) {
          return Container(
            color: Colors.blue[900],
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  daysOfWeekHeight: 20,
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getReservsPerDay,
                  locale: 'es_ES',
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    formatButtonTextStyle: const TextStyle().copyWith(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                    formatButtonShowsNext: false,
                    titleTextStyle: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                    titleTextFormatter: (date, _) =>
                        '${DateFormat('MMMM').format(date)}',
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white),
                    weekendStyle: TextStyle(color: Colors.white),
                  ),
                  calendarStyle: const CalendarStyle(
                    defaultTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Colors.white),
                    markerDecoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      color: Colors.white,
                    ),
                    child: FutureBuilder(
                      future: reservacionDB!.getReservacionesByFecha(
                          _selectedDay.toString().split(' ')[0]),
                      builder:
                          (context, AsyncSnapshot<List<ReservacionModel>> snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        } else {
                          if (snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 50, right: 50, top: 40, bottom: 20),
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final reservacion = snapshot.data![index];
                                  //snapshot.data![index];
                                  return FutureBuilder<UsuarioModel?>(
                                    future: usuarioDatabase!.getUsuario(reservacion.id_usuario!),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.hasError) {
                                        return Center(
                                          child: Text(userSnapshot.error.toString()),
                                        );
                                      } else {
                                        if (userSnapshot.hasData) {
                                          return Container(
                                            margin: EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              border:
                                                  Border.all(color: Colors.grey[300]!),
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20),
                                                topLeft: Radius.circular(20),
                                                bottomRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(15),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Reservación de ${userSnapshot.data!.nombre!} ${userSnapshot.data!.apellido!}',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.timer_sharp),
                                                                Text(
                                                                  DateFormat('HH:mm').format(snapshot.data![index].fecha_ini!)
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    PopupMenuButton<String>(
                                                      elevation: 0,
                                                      shadowColor: Colors.black,
                                                      onSelected:
                                                          (String result) async {
                                                        if (result == "Ver") {
                                                          _mostrarModalReservacion(
                                                              snapshot.data![index]);
                                                        }
                                                        if (result == "Editar") {
                                                          modalReservacion(context,
                                                              snapshot.data![index]);
                                                        }
                                                        if (result == "Eliminar") {
                                                          ArtDialogResponse response =
                                                              await ArtSweetAlert.show(
                                                                  barrierDismissible:
                                                                      false,
                                                                  context: context,
                                                                  artDialogArgs: ArtDialogArgs(
                                                                      denyButtonText:
                                                                          "Cancelar",
                                                                      title:
                                                                          "¿Estás seguro?",
                                                                      text:
                                                                          "¡No podrás revertir esta acción!",
                                                                      confirmButtonText:
                                                                          "Si, borrar",
                                                                      type:
                                                                          ArtSweetAlertType
                                                                              .warning));
                                          
                                                          if (response == null) {
                                                            return;
                                                          }
                                                          if (response.isTapConfirmButton) {
                                                            kReservs[snapshot.data![index].fecha_ini!]!.removeWhere(
                                                              (element) => element.title == 'Reservación de ${userSnapshot.data!.nombre} ${userSnapshot.data!.apellido}'
                                                            );
                                                            reservacionDB!
                                                                .deleteReservacion(snapshot
                                                                    .data![index]
                                                                    .id_reservacion!)
                                                                .then((value) {
                                                              if (value > 0) {
                                                                ArtSweetAlert.show(
                                                                    context: context,
                                                                    artDialogArgs: ArtDialogArgs(
                                                                        type:
                                                                            ArtSweetAlertType
                                                                                .success,
                                                                        title:
                                                                            "¡Borrado!"));
                                                              }
                                                              AppNotifier
                                                                      .banEvents.value =
                                                                  !AppNotifier
                                                                      .banEvents.value;
                                                            });
                                                            return;
                                                          }
                                                        }
                                                      },
                                                      itemBuilder:
                                                          (BuildContext context) =>
                                                              <PopupMenuEntry<String>>[
                                                        const PopupMenuItem<String>(
                                                          value: "Ver",
                                                          child: Text("Ver"),
                                                        ),
                                                        const PopupMenuItem<String>(
                                                          value: "Editar",
                                                          child: Text("Editar"),
                                                        ),
                                                        const PopupMenuItem<String>(
                                                          value: "Eliminar",
                                                          child: Text("Eliminar"),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: getRandomColor(),
                                                    borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(20),
                                                      bottomRight: Radius.circular(20),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      }
                                    }
                                  );
                                },
                              ),
                            );
                          } else {
                            return Text('Cargando...');
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn1',
        onPressed: () {
          modalReservacion(context, null);
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[900],
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  void modalReservacion(context, ReservacionModel? reservacion) async {
    final conUsuario = TextEditingController();
    final conAirbnb = TextEditingController();
    final conFechaIni = TextEditingController();
    final conFechaFini = TextEditingController();
    //final conFecha2 = TextEditingController();
    final conHoraIni = TextEditingController();
    final conHoraFini = TextEditingController();
    final _keyForm = GlobalKey<FormState>();
    UsuarioModel? selectedUser;

    conFechaIni.text = _selectedDay.toString().split(' ')[0];

    if (reservacion != null) {
      conUsuario.text = reservacion.id_usuario!.toString();
      conAirbnb.text = reservacion.id_airbnb!.toString();
      conFechaIni.text = DateFormat('yyyy-MM-dd').format(reservacion.fecha_ini!.toLocal());
      conHoraIni.text = DateFormat('h:mm a').format(reservacion.fecha_ini!.toLocal());
      conFechaFini.text = DateFormat('yyyy-MM-dd').format(reservacion.fecha_fini!.toLocal());
      conHoraFini.text = DateFormat('h:mm a').format(reservacion.fecha_fini!.toLocal());
      // conFechaIni.text = reservacion.fecha_evento!.split(' ')[0];
      // conFechaFini.text = reservacion.fecha_evento!;
      // conHora.text = reservacion.fecha_evento!.split(' ')[1];
      // conRenta.text = reservacion.renta_id!.toString();
    }

    UsuarioDatabase usuarioDB = UsuarioDatabase();
    List<UsuarioModel> usuarios = await usuarioDB.getUsuarios();

    final txtUsuario = DropdownButtonFormField<String>(
        validator: (value) {
          if (value == null) {
            return 'Necesitas seleccionar un usuario';
          }
          return null;
        },
        value: (conUsuario.text.isEmpty) ? null : conUsuario.text,
        hint: Text('Seleccione un usuario'),
        items: usuarios.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.id_usuario.toString(),
            child: Text('${value.nombre} ${value.apellido}'),
          );
        }).toList(),
        onChanged: (String? value) {
          conUsuario.text = value!;
          selectedUser = usuarios.firstWhere((usuario) => usuario.id_usuario.toString() == value);
        });

    AirbnbDatabase airbnbDB = AirbnbDatabase();
    List<AirbnbModel> rentas = await airbnbDB.getAirbnbs();

    final txtAirbnb = DropdownButtonFormField<String>(
        validator: (value) {
          if (value == null) {
            return 'Necesitas seleccionar un AirBnB';
          }
          return null;
        },
        value: (conAirbnb.text.isEmpty) ? null : conAirbnb.text,
        hint: Text('Seleccione una AirBnB'),
        items: rentas.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.id_airbnb.toString(),
            child: Text(value.descripcion.toString()),
          );
        }).toList(),
        onChanged: (String? value) {
          conAirbnb.text = value!;
        });

    final txtFechaIni = TextFormField(
        keyboardType: TextInputType.none,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Necesitas ingresar una fecha de inicio';
          }
          return null;
        },
        controller: conFechaIni,
        decoration: const InputDecoration(
          labelText: 'Fecha Inicio',
          prefixIcon: Icon(Icons.date_range_outlined),
          border: UnderlineInputBorder(),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate: DateTime(
                  2000), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2101));

          if (pickedDate != null) {
            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
            setState(() {
              conFechaIni.text = formattedDate;
            });
          } else {}
        });

    final txtHoraIni = TextFormField(
      keyboardType: TextInputType.none,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Necesitas ingresar una hora de inicio';
        }
        return null;
      },
      controller: conHoraIni,
      decoration: const InputDecoration(
        labelText: 'Hora Inicio',
        prefixIcon: Icon(Icons.timer_outlined),
        border: UnderlineInputBorder(),
      ),
      onTap: () async {
        TimeOfDay selectedTime = TimeOfDay.now();
        final pickedTime = await showSpinnerTimePicker(
          context,
          initTime: selectedTime,
        );

        if (pickedTime != null) {
          setState(() {
            selectedTime = pickedTime;
            conHoraIni.text = pickedTime.format(context);
          });
        }
      }
    );

    final txtFechaFini = TextFormField(
        keyboardType: TextInputType.none,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Necesitas ingresar una fecha final';
          }
          return null;
        },
        controller: conFechaIni,
        decoration: const InputDecoration(
          labelText: 'Fecha Fin',
          prefixIcon: Icon(Icons.date_range_outlined),
          border: UnderlineInputBorder(),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate: DateTime(
                  2000), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2101));

          if (pickedDate != null) {
            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
            setState(() {
              conFechaFini.text = formattedDate;
            });
          } else {}
        });

    final txtHoraFini = TextFormField(
      keyboardType: TextInputType.none,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Necesitas ingresar una hora final';
        }
        return null;
      },
      controller: conHoraFini,
      decoration: const InputDecoration(
        labelText: 'Hora Fin',
        prefixIcon: Icon(Icons.timer_outlined),
        border: UnderlineInputBorder(),
      ),
      onTap: () async {
        TimeOfDay selectedTime = TimeOfDay.now();
        final pickedTime = await showSpinnerTimePicker(
          context,
          initTime: selectedTime,
        );

        if (pickedTime != null) {
          setState(() {
            selectedTime = pickedTime;
            conHoraFini.text = pickedTime.format(context);
          });
        }
      }
    );

    final space = SizedBox(
      height: 10,
    );

    final btnAgregar = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
        onPressed: () {
          selectedUser ??= usuarios.firstWhere((usuario) => usuario.id_usuario.toString() == conUsuario.text);
          if (_keyForm.currentState!.validate()) {
            final DateTime date = DateFormat('yyyy-MM-dd').parse(conFechaIni.text);
            final DateTime time = DateFormat('hh:mm a').parse(conHoraIni.text);
            // Combinar la fecha y la hora
            final DateTime scheduledDate = DateTime(
              date.year,
              date.month,
              date.day - 2,  // Ajuste de días
              time.hour,
              time.minute,
            );
          print(scheduledDate);
          if(DateTime.now().isBefore(scheduledDate)){
            NotificationService().scheduleNotification(
            title: 'Evento próximo',
            body: 'Faltan 2 días para que se consuma la reservacion de ${selectedUser!.nombre} ${selectedUser!.apellido}',
            scheduledNotificationDateTime: scheduledDate);
          }
          final horaIni24hrs = DateFormat('HH:mm:ss').format(DateFormat('hh:mm a').parse(conHoraIni.text));
          final horaFini24hrs = DateFormat('HH:mm:ss').format(DateFormat('hh:mm a').parse(conHoraFini.text));
            if (reservacion == null) {
              ReservacionModel reserv = ReservacionModel(
                  fecha_ini: DateTime.parse(conFechaIni.text + ' ' + horaIni24hrs),
                  fecha_fini: DateTime.parse(conFechaFini.text + ' ' + horaFini24hrs),
                  estatus: 'Confirmada',
                  habitaciones: 1,
                  id_usuario: int.parse(conUsuario.text),
                  id_airbnb: int.parse(conAirbnb.text),
              );
              if (kReservs[DateTime.parse(conFechaIni.text)] == null) {
                kReservs[DateTime.parse(conFechaIni.text)] = [];
              }
              kReservs[DateTime.parse(conFechaIni.text)]!
                  .add(Reservation('Reservación de ${selectedUser!.nombre} ${selectedUser!.apellido}'));

              reservacionDB!.insertReservacion(reserv).then((value) {
                Navigator.pop(context);
                String msj = "";
                var snackbar;
                if (value > 0) {
                  AppNotifier.banEvents.value =
                      !AppNotifier.banEvents.value;
                  msj = "Reservación insertada";
                  snackbar = SnackBar(
                    content: Text(msj),
                    backgroundColor: Colors.green,
                  );
                } else {
                  msj = "Ocurrió un error";
                  snackbar = SnackBar(
                    content: Text(msj),
                    backgroundColor: Colors.red,
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              });
            } else { // EDIT
              ReservacionModel reserv = ReservacionModel(
                  id_reservacion: reservacion.id_reservacion,
                  fecha_ini: DateTime.parse(conFechaIni.text + ' ' + horaIni24hrs),
                  fecha_fini: DateTime.parse(conFechaFini.text + ' ' + horaFini24hrs),
                  estatus: 'Confirmada',
                  habitaciones: 1,
                  id_usuario: int.parse(conUsuario.text),
                  id_airbnb: int.parse(conAirbnb.text),
              );
              kReservs[DateTime.parse(conFechaIni.text)]!
                  .removeWhere((element) => element.title == 'Reservación de ${selectedUser!.nombre} ${selectedUser!.apellido}');
              if (kReservs[DateTime.parse(conFechaIni.text)] == null) {
                kReservs[DateTime.parse(conFechaIni.text)] = [];
              }
              kReservs[DateTime.parse(conFechaIni.text)]!
                  .add(Reservation('Reservación de ${selectedUser!.nombre} ${selectedUser!.apellido}'));
              reservacionDB!.updateReservacion(reserv).then((value) {
                Navigator.pop(context);
                String msj = "";
                var snackbar;
                if (value > 0) {
                  AppNotifier.banEvents.value =
                      !AppNotifier.banEvents.value;
                  msj = "Reservación actualizada";
                  snackbar = SnackBar(
                    content: Text(msj),
                    backgroundColor: Colors.green,
                  );
                } else {
                  msj = "Ocurrió un error";
                  snackbar = SnackBar(
                    content: Text(msj),
                    backgroundColor: Colors.red,
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              });
            }
          }
        },
        icon: const Icon(Icons.save),
        label: const Text('Guardar'));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Colors.white,
          content: Form(
            key: _keyForm,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuario',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtUsuario,
                ),
                space,
                space,
                Text(
                  'AirBnB',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtAirbnb,
                ),
                space,
                space,
                Text(
                  'Fecha y hora de Inicio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        //padding: EdgeInsets.all(5),
                        child: txtFechaIni,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        //padding: EdgeInsets.all(5),
                        child: txtHoraIni,
                      ),
                    ),
                  ],
                ),
                space,
                Text(
                  'Fecha y hora de Finalización',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        //padding: EdgeInsets.all(5),
                        child: txtFechaFini,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        //padding: EdgeInsets.all(5),
                        child: txtHoraFini,
                      ),
                    ),
                  ],
                ),
                space,
                Row(
                  children: [
                    Expanded(
                      child: btnAgregar,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarModalReservacion(ReservacionModel reservacion) async {
    // Obtener la fecha dos días antes del reservacion
    DateTime fechaInicio = reservacion.fecha_ini!;
    DateTime twoDaysBeforeEvent = fechaInicio.subtract(Duration(days: 2));

    // Almacenar una referencia al contexto
    BuildContext modalContext = context;

    // Obtener detalles del usuario y airbnb de la reservación
    UsuarioModel? usuarioReserv = await usuarioDatabase!.getUsuario(reservacion.id_usuario!);
    AirbnbModel? airbnbReserv = await airbnbDatabase!.getAirbnb(reservacion.id_airbnb!);

    // Enviar notificación instantánea

    showModalBottomSheet(
      context: modalContext,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          // SingleChildScrollView para permitir scroll
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {
                        _enviarNotificacionInstantanea(twoDaysBeforeEvent);
                      },
                    ),
                  ],
                ),
                Text(
                  'Reservación de ${usuarioReserv!.nombre} ${usuarioReserv!.apellido}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Fecha de Inicio: ${DateFormat('yyyy-MM-dd').format(reservacion.fecha_ini!.toLocal())}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Fecha de Finalización: ${DateFormat('yyyy-MM-dd').format(reservacion.fecha_fini!.toLocal())}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Descripción del AirBnB: ${airbnbReserv!.descripcion}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  'Detalles de la reservación:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    Text(
                      'Dirección: ${airbnbReserv.direccion}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Habitaciones reservadas: ${reservacion.habitaciones} de ${airbnbReserv.habitaciones}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Baños: ${airbnbReserv.banos}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(),
                  ],
                ),
                // Mostrar detalles de la renta
                // ListView.builder(
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   itemCount: detallesRenta.length,
                //   itemBuilder: (context, index) {
                //     int? mobiliarioId = detallesRenta[index].mobiliario_id;
                //     return FutureBuilder(
                //       future: MobiliarioDatabase().getMobiliario(mobiliarioId!),
                //       builder:
                //           (context, AsyncSnapshot<MobiliarioModel?> snapshot) {
                //         if (snapshot.hasData && snapshot.data != null) {
                //           return Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Divider(),
                //               Text(
                //                 'Mobiliario ID: $mobiliarioId',
                //                 style: TextStyle(fontSize: 16),
                //               ),
                //               Text(
                //                 'Cantidad: ${detallesRenta[index].cantidad}',
                //                 style: TextStyle(fontSize: 16),
                //               ),
                //               Text(
                //                 'Nombre: ${snapshot.data!.nombre_mobiliario}',
                //                 style: TextStyle(fontSize: 16),
                //               ),
                //               Divider(),
                //             ],
                //           );
                //         } else if (snapshot.hasError) {
                //           return Text("Error: ${snapshot.error}");
                //         } else {
                //           return CircularProgressIndicator();
                //         }
                //       },
                //     );
                //   },
                // ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(modalContext).pop();
                  },
                  child: Text('Regresar a la lista de eventos'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _enviarNotificacionInstantanea(
      DateTime fechaNotificacion) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'instant_notification_channel_id',
      'Instant Notification',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notificación Instantánea',
      'Notificación programada para el día: ${DateFormat('dd-MM-yyyy').format(fechaNotificacion)}',
      platformChannelSpecifics,
    );
  }
}
