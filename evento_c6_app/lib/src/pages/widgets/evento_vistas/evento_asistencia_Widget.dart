import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_c6_app/src/config/theme.dart';
import 'package:evento_c6_app/src/controller/AsistenciaController.dart';
import 'package:evento_c6_app/src/pages/widgets/evento_vistas/evento_asistencia_detalle_Widget.dart';
import 'package:evento_c6_app/src/pages/widgets/evento_vistas/evento_detalle_Widget.dart';
import 'package:evento_c6_app/src/service/authService/ShareApiTokenService.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class AsistenciaAlumno extends StatefulWidget {
  final dynamic evento;
  const AsistenciaAlumno({super.key, required this.evento});

  @override
  State<AsistenciaAlumno> createState() => _AsistenciaAlumnoState();
}

class _AsistenciaAlumnoState extends State<AsistenciaAlumno> {
  bool mostrarBoton = false;

  late ThemeProvider themeProvider;
  late List<Color> themeColors;
  DateTime? selectedDate;
  //traendo ususario
  String accountId = "";
  String accountName = "";
  String accountEmail = "";
  String accountApellido_P = "";
  String accountApellido_M = "";
  String accountCodigo = "";
  dynamic evento;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(Duration(days: 365)), // Limitar a 1 año en el futuro
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; // Actualizar la fecha seleccionada
      });
    }
  }

  Future<void> loadUserProfile() async {
    final loginDetails = await ShareApiTokenService.loginDetails();

    if (loginDetails != null) {
      setState(() {
        accountId = (loginDetails.user?.id ?? "ID no encontrado").toString();
        accountEmail = loginDetails.user?.email ?? "email no encontrado";
        accountName = loginDetails.user?.name ?? "name no encontrado";
        accountApellido_P =
            loginDetails.user?.apellidoP ?? "apellidoP no encontrado";
        accountApellido_M =
            loginDetails.user?.apellidoM ?? "apellidoM no encontrado";
        accountCodigo = loginDetails.user?.codigo ?? "codigo no encontrado";
      });
    }
  }

  //end traendo ususario
  @override
  void initState() {
    super.initState();
    loadUserProfile();
    evento = widget.evento;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Accede a los valores de Provider en didChangeDependencies
    themeProvider = Provider.of<ThemeProvider>(context);
    themeColors = themeProvider.getThemeColors();
  }

  Future<void> _realizarAsistencia(String nombre, String correo) async {
    final userIdController =
        accountId; // Reemplaza con la lógica para obtener el ID de usuario

    final fechaController =
        selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String();

    final dynamic evento = widget.evento;
    final estadoController = 'Presente';

    try {
      // Verificar si el ID de usuario es válido
      if (userIdController.isNotEmpty) {
        // Construir el cuerpo de la reserva con la información del formulario
        Map data = {
          'userId': '$userIdController',
          'fecha': '$fechaController',
          'evento': {
            'id': (evento is Map) ? evento['id'] : evento.toString(),
          },
          'estado': '$estadoController',
        };
        final response = await AsistenciaController().crearAsistencia(
          userIdController,
          fechaController,
          evento,
          estadoController,
        );

        if (response.statusCode == 201) {
          print("Asistencia exitosa");
          setState(() {
            mostrarBoton = estadoController == 'Presente';
          });
        } else {
          print(
              "Error al realizar la asistencia. Código de estado: ${response.statusCode}");
        }
      } else {
        print("ID de usuario no válido");
      }
    } catch (e) {
      print("Error al realizar la asistencia: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic evento = widget.evento;
    final id = '$accountId';
    final email = '$accountEmail';
    final name = '$accountName';
    final apellido_m = '$accountApellido_M';
    final apellido_p = '$accountApellido_P';
    final codigo = '$accountCodigo';

    return Scaffold(
      body: Stack(
        children: [
          if (!themeProvider
              .isDiurno) // Condición para mostrar la imagen y el color encima
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/fondonegro1.jfif'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (!themeProvider
              .isDiurno) // Condición para mostrar el color encima de la imagen
            Positioned.fill(
              child: Container(
                color:
                    Colors.black.withOpacity(0.5), // Color encima de la imagen
              ),
            ),
          ListView(
            children: [
              Container(
                height: 370,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: themeProvider.isDiurno
                        ? AssetImage('assets/sideral2.jpg')
                        : AssetImage('assets/fondonegro1.jfif'),
                    // image: AssetImage('assets/lib2.jfif'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: themeProvider.isDiurno
                            ? HexColor("#0e1b4d").withOpacity(0.8)
                            : Colors.black.withOpacity(0.5),
                        // color: HexColor("#0e1b4d").withOpacity(0.8),
                        //  color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(23),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EventoDetalleWidget(
                                              evento: evento,
                                            )),
                                  );
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: themeProvider.isDiurno
                                      ? HexColor('#F82249')
                                      : Colors.white,
                                  size: 30,
                                ),
                              ),
                              Spacer(),
                              PopupMenuButton<int>(
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<int>(
                                    value: 1,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, "/favoritos");
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.bookmark,
                                            color: themeProvider.isDiurno
                                                ? HexColor('#F82249')
                                                : Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text('Mis Asistencias'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Puedes agregar más elementos del menú aquí si es necesario
                                ],
                                child: Icon(
                                  Icons.more_vert,
                                  size: 25,
                                  color: themeProvider.isDiurno
                                      ? HexColor('#F82249')
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 25),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              Text(
                                'Asistencia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 25),
                          alignment: Alignment.centerLeft,
                          width: 170,
                          child: Column(
                            children: [
                              Text(
                                ' ${evento['nombre']} ${evento['id']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(40)),
                        child: Container(
                          padding: EdgeInsets.only(top: 15),
                          color: themeProvider.isDiurno
                              ? Colors.white
                              : Colors.white10,
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              _nota(),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(230, 70),
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2,
                              0.004) // Establecer un valor para la perspectiva
                          ..rotateY(0.3), // Girar en el eje Y
                        alignment: FractionalOffset.center,
                        child: Container(
                          width: 130,
                          height: 180,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 2,
                                offset: Offset(5, 5),
                              ),
                            ],
                          ),
                          child: CachedNetworkImage(
                            imageUrl: evento.containsKey('foto')
                                ? evento['foto'].toString()
                                : 'assets/nofoto.jpg',
                            placeholder: (context, url) => Container(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/nofoto.jpg',
                              height: 200,
                              width: 138,
                              fit: BoxFit.cover,
                            ),
                            fit: BoxFit.cover,
                            height: 200,
                            width: 138,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    color:
                        themeProvider.isDiurno ? Colors.white : Colors.white10,
                    //formulario
                    child: _formulario(),
                  ),
                  // Container(
                  //   color:
                  //       themeProvider.isDiurno ? Colors.white : Colors.white10,
                  //   //formulario
                  //   child: _crudAsistencia(),
                  // ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _textCenter({required String nombre}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            nombre,
            style: TextStyle(
              color:
                  themeProvider.isDiurno ? HexColor("#0e1b4d") : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              wordSpacing: 2,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            width: 70.0,
            color: themeProvider.isDiurno ? HexColor('#F82249') : Colors.white,
            height: 3.0,
          ),
        ],
      ),
    );
  }

  Widget _formulario() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textCenter(
            nombre:
                'formulario', // Utiliza ':' para asignar el valor a 'titulo'
          ),
          SizedBox(height: 20),
          Text(
            'Evento: ${evento['nombre']} (ID: ${evento['id']})',
            style: TextStyle(
              color: themeProvider.isDiurno ? Colors.black : Colors.white,
            ),
          ),
          Text(
            'Id usuario:$accountId',
            style: TextStyle(
              color: themeProvider.isDiurno ? Colors.black : Colors.white,
            ),
          ),
          Text(
            'email :$accountEmail',
            style: TextStyle(
              color: themeProvider.isDiurno ? Colors.black : Colors.white,
            ),
          ),
          Text(
            'nombre :$accountName',
            style: TextStyle(
              color: themeProvider.isDiurno ? Colors.black : Colors.white,
            ),
          ),
          Text(
            'codigo :$accountCodigo',
            style: TextStyle(
              color: themeProvider.isDiurno ? Colors.black : Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Fecha de reserva:',
                style: TextStyle(
                  color: themeProvider.isDiurno ? Colors.black : Colors.white,
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () => _selectDate(context),
                child: Text(
                  selectedDate == null
                      ? 'Seleccionar fecha'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!),
                  style: TextStyle(
                    color: themeProvider.isDiurno ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              _realizarAsistencia(accountName, accountEmail);

              // Agrega la navegación a la otra página aquí
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AsistenciaAlumno(
                          evento: evento,
                        )),
              );
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.resolveWith(
                (states) => RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              backgroundColor: MaterialStateProperty.resolveWith(
                (states) => themeProvider.isDiurno
                    ? HexColor("#F82249")
                    : themeColors[0],
              ),
            ),
            child: Text('Asistir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Widget _crudAsistencia() {
  //   return Container(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         _textCenter(
  //           nombre: 'asistencias',
  //         ),
  //         SizedBox(
  //           height: 20,
  //         ),
  //         Container(
  //             padding: EdgeInsets.only(left: 5, right: 5, bottom: 15),
  //             child: EventoAsistenciaDetalleWidget(
  //               id: '',
  //             )),
  //       ],
  //     ),
  //   );
  // }

  Widget _nota() {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDiurno ? HexColor("#F82249") : themeColors[0],
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(left: 20, right: 20),
      height: 85,
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Recuerda!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 300,
                child: Text(
                  'Recuerda que las asistencias son personales',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
