import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:p4pmsn/database/airbnb_database.dart';
import 'package:p4pmsn/database/reservacion_database.dart';
import 'package:p4pmsn/database/usuario_database.dart';
import 'package:p4pmsn/model/airbnb_model.dart';
import 'package:p4pmsn/model/reservacion_model.dart';
import 'package:p4pmsn/model/usuario_model.dart';

class DetalleReservacionScreen extends StatefulWidget {
  const DetalleReservacionScreen({Key? key});

  @override
  State<DetalleReservacionScreen> createState() => _DetalleReservacionScreenState();
}

class _DetalleReservacionScreenState extends State<DetalleReservacionScreen> {
  int? id_reservacion;
  ReservacionModel? _reservacion;
  UsuarioModel? _usuario;
  AirbnbModel? _airbnb;
  UsuarioDatabase? usuarioDB;
  bool _isLoading = true;
  int diasTotales = 0;

  @override
  void initState() {
    super.initState();
    _showLoading();
    usuarioDB = UsuarioDatabase();
  }

  void _showLoading() async {
    await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    id_reservacion = ModalRoute.of(context)?.settings.arguments as int?;
    if (id_reservacion != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    _reservacion = await ReservacionDatabase().getReservacion(id_reservacion!);
    // _usuario =
    //     await DetalleReservacionDatabase().getDetallesRentaByid_reservacion(id_reservacion!);
    _airbnb = await AirbnbDatabase().getAirbnb(_reservacion!.id_airbnb!);
    _usuario = await usuarioDB!.getUsuario(_reservacion!.id_usuario!);
    //diasTotales = _reservacion!.fecha_fini!.difference(_reservacion!.fecha_ini!).inDays;
    diasTotales = daysBetween(_reservacion!.fecha_ini!, _reservacion!.fecha_fini!);
    // for (var reserv in _reservacion!) {
    //   var mobiliario =
    //       await MobiliarioDatabase().getMobiliario(detalle.mobiliario_id!);
    //   if (mobiliario != null) {
    //     _airbnb!.add(mobiliario);
    //   }
    // }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final space = SizedBox(
      height: 15,
    );
    if (id_reservacion != null) {
      if (_reservacion == null || _usuario == null) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Detalle de Reservación'),
          ),
          body: Center(
            child: _isLoading
                ? CircularProgressIndicator()
                : Text("No se encontraron detalles"),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            title: Text(
              'Detalle de Reservación',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue[900],
          ),
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height, // Define la altura
                  color: Colors.blue[900],
                ),
                Positioned(
                  top: 100,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(70),
                          topRight: Radius.circular(70)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Center(
                            child: Text(
                              'Información de la Reservación',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Colors
                                      .black), // Tamaño y color de la fuente
                            ),
                          ),
                          space,
                          _buildTagStatus(_reservacion!.estatus!),
                          space,
                          Row(
                            children: [
                              Icon(Icons.timer_outlined),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Fecha inicio: ',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                  '${_reservacion!.fecha_ini.toString().split(' ')[0]}'),
                            ],
                          ),
                          space,
                          Row(
                            children: [
                              Icon(Icons.timer_outlined),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Fecha fin: ',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                  '${_reservacion!.fecha_fini.toString().split(' ')[0]}'),
                            ],
                          ),
                          space,
                          Row(
                            children: [
                              Icon(Icons.calendar_month),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Días totales: ',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                  '${diasTotales}'),
                            ],
                          ),
                          space,
                          Row(
                            children: [
                              Icon(Icons.money),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Precio final: ',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                  '${diasTotales * _airbnb!.precio_dia!}'),
                            ],
                          ),
                          space,
                          FutureBuilder(
                              future: usuarioDB!.getUsuario(_reservacion!.id_usuario!),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Row(
                                    children: [
                                      Icon(Icons.person),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Usuario: ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Text('${snapshot.data!.nombre} ${snapshot.data!.apellido}'),
                                    ],
                                  );
                                } else {
                                  return Text('');
                                }
                              }),
                          SizedBox(height: 20),
                          Text(
                            'Detalle del AirBnB',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600]),
                          ),
                          space,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                littleTags('Dirección: ', _airbnb!.direccion!),
                                SizedBox(height: 8,),
                                littleTags('Habitaciones rentadas: ', '${_reservacion!.habitaciones!} de ${_airbnb!.habitaciones!}'),
                                SizedBox(height: 8,),
                                littleTags('Baños: ', _airbnb!.banos!),
                                SizedBox(height: 8,),
                                littleTags('Descripción: ', _airbnb!.descripcion!),
                                SizedBox(height: 8,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 1),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: _buildLottieAnimation(_reservacion!.estatus!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1, // índice seleccionado en el BottomNavigationBar
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Eventos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Historial',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/nav');
              }
            },
          ),
        );
      }
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalle de Renta'),
        ),
        body: Center(
          child: Text(
            'ID de renta no válido',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    }
  }

  Widget _buildLottieAnimation(String status) {
    String animationAsset;
    switch (status) {
      case 'Confirmada':
        animationAsset = 
            'https://lottie.host/ee8bcbc9-760d-4489-9436-3fe966260889/6jL7WIf7St.json';
        break;
      case 'Finalizada':
        animationAsset =
            'https://lottie.host/fed494d7-a6c9-4cbe-9ad5-9b1ea45ea035/TlzyFQpBUU.json';
        break;
      case 'Iniciada':
        animationAsset =
            'https://lottie.host/19e8ddbc-31af-4a98-8295-b0ec81f1c1e3/eI7PSPfuCF.json';
        break;
      case 'Cancelada':
        animationAsset =
            'https://lottie.host/3d83dfa8-37b0-4b90-81c1-933546b3ed80/xLM87KOQ5V.json';
        break;
      default:
        animationAsset =
            ''; // Definir una animación predeterminada o un mensaje de error
    }

    if (animationAsset.isNotEmpty) {
      return Transform.scale(
        scale: 1,
        child: Lottie.network(animationAsset),
      );
    } else {
      return Text('No se encontró la animación correspondiente');
    }
  }

  Widget _buildTagStatus(String status) {
    late final Color _statusColor;
    late final Color _backgroundcolorStatus;
    switch (status) {
      case 'Confirmada':
        _statusColor = Colors.blue[700]!;
        _backgroundcolorStatus = Colors.green[50]!;
        break;
      case 'Iniciada':
        _statusColor = Colors.orange[600]!;
        _backgroundcolorStatus = Colors.orange[50]!;
        break;
      case 'Finalizada':
        _statusColor = Colors.green[700]!;
        _backgroundcolorStatus = Colors.red[50]!;
        break;
      case 'Cancelada':
        _statusColor = Colors.red[700]!;
        _backgroundcolorStatus = Colors.red[50]!;
        break;
      default:
        _statusColor = Colors.grey[700]!;
        _backgroundcolorStatus = Colors.grey[50]!;
    }

    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: _backgroundcolorStatus,
            borderRadius: BorderRadius.circular(50)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
          child: Text(
            status,
            style: TextStyle(color: _statusColor),
          ),
        ),
      ),
    );
  }

  Widget littleTags(tag, value){
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: tag.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value.toString(),
          ),
        ],
      ),
      textAlign: TextAlign.left,
    );
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}
