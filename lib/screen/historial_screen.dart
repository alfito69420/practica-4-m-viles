import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p4pmsn/database/airbnb_database.dart';
import 'package:p4pmsn/database/reservacion_database.dart';
import 'package:p4pmsn/database/usuario_database.dart';
import 'package:p4pmsn/extras/app_notifier.dart';
import 'package:p4pmsn/model/airbnb_model.dart';
import 'package:p4pmsn/model/reservacion_model.dart';
import 'package:p4pmsn/model/usuario_model.dart';

class HistorialScreen extends StatefulWidget {
  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late Future<List<ReservacionModel>> _allReservacionesFuture;
  ReservacionDatabase? reservDB;
  UsuarioDatabase? usuarioDB;
  AirbnbDatabase? airbnbDB;

  @override
  void initState() {
    super.initState();
    _allReservacionesFuture = _getAllReservaciones();
    reservDB = ReservacionDatabase();
    usuarioDB = UsuarioDatabase();
    airbnbDB = AirbnbDatabase();
  }

  Future<List<ReservacionModel>> _getAllReservaciones() async {
    List<ReservacionModel> allReservaciones = [];
    allReservaciones.addAll(await _getReservacionesByStatus('Confirmada'));
    allReservaciones.addAll(await _getReservacionesByStatus('Iniciada'));
    allReservaciones.addAll(await _getReservacionesByStatus('Finalizada'));
    allReservaciones.addAll(await _getReservacionesByStatus('Cancelada'));
    return allReservaciones;
  }

  Future<List<ReservacionModel>> _getReservacionesByStatus(String status) async {
    return await ReservacionDatabase().getReservacionesByStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
              color: Colors.white,
            ),
        title: Text(
          'Historial de Reservaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: ValueListenableBuilder(
        valueListenable: AppNotifier.banRentas,
        builder: (context, value, child) {
          return Container(
            color: Colors.white, // Color de fondo del Container
            child: FutureBuilder<List<ReservacionModel>>(
              future: _getAllReservaciones(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final reservs = snapshot.data!;
                  //Se acomodan aqui
                  reservs.sort((a, b) => a.id_reservacion!.compareTo(b.id_reservacion!));
                  return CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final reserv = reservs[index];
                            final dateFormatter = DateFormat('yyyy-MM-dd');
                            final fechaInicioFormatted =
                                dateFormatter.format(reserv.fecha_ini!);
                            final fechaFinFormatted =
                                dateFormatter.format(reserv.fecha_fini!);
                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/reservacion',
                                  arguments: reserv.id_reservacion,
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                          0.1), // Color y opacidad de la sombra
                                      spreadRadius:
                                          1, // Radio de propagación de la sombra
                                      blurRadius:
                                          3, // Radio de desenfoque de la sombra
                                      offset: Offset(0,
                                          2), // Desplazamiento horizontal y vertical de la sombra
                                    )
                                  ],
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatusIndicator(reserv.estatus!),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Reservación #${reserv.id_reservacion}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 8),
                                        Text(
                                            'Fecha inicio: $fechaInicioFormatted'),
                                        Text(
                                            'Fecha término: $fechaFinFormatted'),
                                      ],
                                    ),
                                    PopupMenuButton<String>(
                                      elevation: 0,
                                      onSelected: (String result) async {
                                        if (result == "Editar") {
                                          modificarReservacion(
                                              context, snapshot.data![index]);
                                        }
                                        if (result == "Eliminar") {
                                          ArtDialogResponse response =
                                              await ArtSweetAlert.show(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  artDialogArgs: ArtDialogArgs(
                                                      denyButtonText:
                                                          "Cancelar",
                                                      title: "¿Estás seguro?",
                                                      text:
                                                          "¡No podrás revertir esta acción!",
                                                      confirmButtonText:
                                                          "Si, borrar",
                                                      type: ArtSweetAlertType
                                                          .warning));

                                          if (response == null) {
                                            return;
                                          }

                                          if (response.isTapConfirmButton) {
                                            reservDB!
                                                .deleteReservacion(snapshot
                                                    .data![index].id_reservacion!)
                                                .then((value) {
                                              // detalleDB!
                                              //     .deleteDetalleRentaByIdRenta(
                                              //         snapshot.data![index]
                                              //             .renta_id!)
                                              //     .then((value) {
                                                if (value > 0) {
                                                  ArtSweetAlert.show(
                                                      context: context,
                                                      artDialogArgs: ArtDialogArgs(
                                                          type:
                                                              ArtSweetAlertType
                                                                  .success,
                                                          title: "¡Borrado!"));
                                                }
                                                AppNotifier
                                                        .banRentas.value =
                                                    !AppNotifier
                                                        .banRentas.value;
                                            });
                                            return;
                                          }
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
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
                              ),
                            );
                          },
                          childCount: reservs.length,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   heroTag: 'btn2',
      //   onPressed: () {
      //     //Navigator.pushNamed(context, '/agregarRenta');
      //   },
      //   child: Icon(
      //     Icons.add,
      //     color: Colors.white,
      //   ),
      //   backgroundColor: Colors.blue[900],
      //   shape: CircleBorder(),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void modificarReservacion(context, ReservacionModel reservacion) async {
    final conFechaInicio = TextEditingController();
    final conFechaFin = TextEditingController();
    final conEstatus = TextEditingController();
    final conHabitaciones = TextEditingController();
    final conUsuario = TextEditingController();
    final conAirbnb = TextEditingController();
    final _keyForm = GlobalKey<FormState>();

    conFechaInicio.text = reservacion.fecha_ini.toString().split(' ')[0];
    conFechaFin.text = reservacion.fecha_fini.toString().split(' ')[0];
    conEstatus.text = reservacion.estatus!;
    conHabitaciones.text = reservacion.habitaciones.toString();
    conUsuario.text = reservacion.id_usuario.toString();
    conAirbnb.text = reservacion.id_airbnb.toString();

    final txtFechaInicio = TextFormField(
      keyboardType: TextInputType.none,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Necesitas ingresar una fecha';
        }
        return null;
      },
      controller: conFechaInicio,
      decoration: const InputDecoration(
        labelText: 'Fecha inicio',
        prefixIcon: Icon(Icons.date_range_outlined),
        border: UnderlineInputBorder(),
      ),
      onTap: () async {
        // Guarda una referencia al contexto actual
        BuildContext currentContext = context;

        DateTime? pickedDate = await showDatePicker(
          context: currentContext, // Utiliza la referencia guardada al contexto
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          // Utiliza la referencia guardada al contexto para llamar a setState
          Scaffold.of(currentContext).setState(() {
            conFechaInicio.text = formattedDate;
          });
        }
      },
    );

    final txtFechaFin = TextFormField(
      keyboardType: TextInputType.none,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Necesitas ingresar una fecha';
        }
        return null;
      },
      controller: conFechaFin,
      decoration: const InputDecoration(
        labelText: 'Fecha fin',
        prefixIcon: Icon(Icons.date_range_outlined),
        border: UnderlineInputBorder(),
      ),
      onTap: () async {
        // Guarda una referencia al contexto actual
        BuildContext currentContext = context;

        DateTime? pickedDate = await showDatePicker(
          context: currentContext, // Utiliza la referencia guardada al contexto
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          // Utiliza la referencia guardada al contexto para llamar a setState
          Scaffold.of(currentContext).setState(() {
            conFechaFin.text = formattedDate;
          });
        }
      },
    );

    final txtEstatus = DropdownButtonFormField<String>(
        value: (conEstatus.text.isEmpty) ? null : conEstatus.text,
        hint: Text('Seleccione el estatus'),
        items: <String>['Confirmada', 'Iniciada', 'Finalizada', 'Cancelada']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value) {
          conEstatus.text = value!;
        });

    UsuarioDatabase usuarioDB = UsuarioDatabase();
    List<UsuarioModel> clientes = await usuarioDB.getUsuarios();

    final txtUsuario = DropdownButtonFormField<String>(
        value: (conUsuario.text.isEmpty) ? null : conUsuario.text,
        hint: Text('Seleccione un usuario'),
        items: clientes.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.id_usuario.toString(),
            child: Text(value.nombre.toString()),
          );
        }).toList(),
        onChanged: (String? value) {
          conUsuario.text = value!;
        });

    AirbnbDatabase airbnbDB = AirbnbDatabase();
    List<AirbnbModel> airs = await airbnbDB.getAirbnbs();

    final txtAirbnb = DropdownButtonFormField<String>(
        validator: (value) {
          if (value == null) {
            return 'Necesitas seleccionar un AirBnB';
          }
          return null;
        },
        value: (conAirbnb.text.isEmpty) ? null : conAirbnb.text,
        hint: Text('Seleccione una AirBnB'),
        items: airs.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.id_airbnb.toString(),
            child: Text(value.descripcion.toString()),
          );
        }).toList(),
        onChanged: (String? value) {
          conAirbnb.text = value!;
        });

    final txtHabitaciones = TextFormField(
      keyboardType: TextInputType.none,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Necesitas ingresar el número de habitaciones a utilizar';
        }
        return null;
      },
      controller: conHabitaciones,
      decoration: const InputDecoration(
        labelText: 'Número de Habitaciones',
        prefixIcon: Icon(Icons.room),
        border: UnderlineInputBorder(),
      ),
    );

    final btnAgregar = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
        onPressed: () {
          if(_keyForm.currentState!.validate()){
            ReservacionModel reserv2 = ReservacionModel(
              id_reservacion: reservacion.id_reservacion,
              fecha_ini: DateTime.parse(conFechaFin.text),
              fecha_fini: DateTime.parse(conFechaInicio.text),
              habitaciones: int.parse(conHabitaciones.text),
              id_usuario: int.parse(conUsuario.text),
              id_airbnb: int.parse(conAirbnb.text),
              estatus: conEstatus.text);
          reservDB!.updateReservacion(reserv2).then((value) {
            Navigator.of(context).pop();
            String msj = "";
            var snackbar;
            if (value > 0) {
              AppNotifier.banRentas.value =
                  !AppNotifier.banRentas.value;
              msj = "Reservación actualizada";
              snackbar = SnackBar(
                content: Text(msj),
                backgroundColor: Colors.green,
              );
            } else {
              msj = "Ocurrió un error";
              snackbar = SnackBar(
                content: Text(
                  msj,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              );
            }
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          });
          }
        },
        icon: const Icon(Icons.save),
        label: const Text('Actualizar'));

    final space = SizedBox(
      height: 10,
    );

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
                  'Fechas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtFechaInicio,
                ),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtFechaFin,
                ),
                space,
                space,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Estatus',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Container(
                            //padding: EdgeInsets.all(5),
                            child: txtEstatus,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Habitaciones',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Container(
                            child: txtHabitaciones,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                space,
                space,
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

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status) {
      case 'Confirmada':
        color = Colors.blue;
        break;
      case 'Iniciada':
        color = Colors.orange;
        break;
      case 'Finalizada':
        color = Colors.green;
        break;
      case 'Cancelada':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return CircleAvatar(
      radius: 30,
      backgroundColor: color,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
      ),
    );
  }
}
