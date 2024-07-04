import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:evento_c6_app/src/config/ConfigApi.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EventoController {
  static const _scopes = [SheetsApi.spreadsheetsScope];
  final _sheetName = 'Eventos 2';
  String? _spreadsheetId;

  Future<AutoRefreshingAuthClient> _getAuthClient() async {
    final credentialsJson = await rootBundle.loadString('assets/credencial_sheet.json');
    final accountCredentials = ServiceAccountCredentials.fromJson(json.decode(credentialsJson));
    return clientViaServiceAccount(accountCredentials, _scopes);
  }

  Future<void> _initializeSpreadsheet() async {
    if (_spreadsheetId == null) {
      final authClient = await _getAuthClient();
      final sheetsApi = SheetsApi(authClient);

      Spreadsheet spreadsheet = Spreadsheet.fromJson({
        'properties': {'title': 'Eventos 2'},
        'sheets': [
          {
            'properties': {'title': _sheetName}
          }
        ]
      });

      Spreadsheet response = await sheetsApi.spreadsheets.create(spreadsheet);
      _spreadsheetId = response.spreadsheetId;

      print('Spreadsheet ID: $_spreadsheetId');
    }
  }

  Future<void> listarEventos() async {
    final authClient = await _getAuthClient();
    final sheetsApi = SheetsApi(authClient);

    await _initializeSpreadsheet();

    final range = '$_sheetName!A1:G'; // Asumiendo que hay 7 columnas A a G

    try {
      ValueRange response = await sheetsApi.spreadsheets.values.get(_spreadsheetId!, range);

      List<List<dynamic>> values = response.values!;

      if (values.isEmpty) {
        print('No hay eventos registrados.');
      } else {
        print('Eventos Registrados:');
        values.forEach((row) {
          print(' - ${row.join(', ')}');
        });
      }
    } catch (e) {
      print('Error al obtener eventos desde Google Sheets: $e');
    }
  }

  Future<void> _addRow(List<String> row) async {
    await _initializeSpreadsheet();

    final authClient = await _getAuthClient();
    final sheetsApi = SheetsApi(authClient);
    final range = '$_sheetName!A1';

    ValueRange vr = ValueRange.fromJson({
      'values': [row]
    });

    await sheetsApi.spreadsheets.values.append(vr, _spreadsheetId!, range, valueInputOption: 'RAW');
  }

  Future<void> _updateRow(int rowIndex, List<String> row) async {
    await _initializeSpreadsheet();

    final authClient = await _getAuthClient();
    final sheetsApi = SheetsApi(authClient);
    final range = '$_sheetName!A${rowIndex + 1}';

    ValueRange vr = ValueRange.fromJson({
      'values': [row]
    });

    await sheetsApi.spreadsheets.values.update(vr, _spreadsheetId!, range, valueInputOption: 'RAW');
  }

  Future<void> _deleteRow(int rowIndex) async {
    await _initializeSpreadsheet();

    final authClient = await _getAuthClient();
    final sheetsApi = SheetsApi(authClient);

    try {
      // Obtener la hoja de cálculo
      Spreadsheet spreadsheet = await sheetsApi.spreadsheets.get(_spreadsheetId!);
      // Asumiendo que la hoja de cálculo tiene al menos una hoja
      Sheet sheet = spreadsheet.sheets![0]; // Obtener la primera hoja

      BatchUpdateSpreadsheetRequest batchUpdateRequest = BatchUpdateSpreadsheetRequest.fromJson({
        'requests': [
          {
            'deleteDimension': {
              'range': {
                'sheetId': sheet.properties!.sheetId!,
                'dimension': 'ROWS',
                'startIndex': rowIndex,
                'endIndex': rowIndex + 1
              }
            }
          }
        ]
      });

      await sheetsApi.spreadsheets.batchUpdate(batchUpdateRequest, _spreadsheetId!);
    } catch (e) {
      print('Error al eliminar fila desde Google Sheets: $e');
      // Manejar el error de manera apropiada
    }
  }

  Future<List<dynamic>> getDataEvento({String tipo = '', String seccion = ''}) async {
    final response = await http.get(Uri.parse(ConfigApi.buildUrl('/evento')));
    if (response.statusCode == 200) {
      final List<dynamic> eventos = json.decode(response.body);

      if (tipo.isNotEmpty) {
        eventos.retainWhere((evento) => evento['tipo'] == tipo);
      }

      if (seccion.isNotEmpty) {
        eventos.retainWhere((evento) => evento['seccion'] == seccion);
      }

      await listarEventos(); // Llamar a listarEventos después de obtener datos

      return eventos;
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<http.Response> crearEvento(
    String userId,
    String nombre,
    String seccion,
    String tipo,
    String fecha_inicio,
    String fecha_fin,
    String foto,
  ) async {
    Map<String, dynamic> data = {
      'userId': userId,
      'nombre': nombre,
      'seccion': seccion,
      'tipo': tipo,
      'fecha_inicio': fecha_inicio,
      'fecha_fin': fecha_fin,
      'foto': foto,
    };

    var body = json.encode(data);
    var response = await http.post(
      Uri.parse(ConfigApi.buildUrl('/evento')),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("${response.statusCode}");
    print("${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      await _addRow([userId, nombre, seccion, tipo, fecha_inicio, fecha_fin, foto]);
    }

    return response;
  }

  Future<http.Response> editarEvento({
    required String id,
    required String userId,
    required String nombre,
    required String seccion,
    required String tipo,
    required String fecha_inicio,
    required String fecha_fin,
    required String foto,
  }) async {
    int a = int.parse(id);
    print(a);

    Map<String, dynamic> data = {
      'id': '$a',
      'userId': userId,
      'nombre': nombre,
      'seccion': seccion,
      'tipo': tipo,
      'fecha_inicio': fecha_inicio,
      'fecha_fin': fecha_fin,
      'foto': foto,
    };

    var body = json.encode(data);
    var response = await http.put(
      Uri.parse(ConfigApi.buildUrl('/evento')),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("${response.statusCode}");
    print("${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      await _updateRow(a, [userId, nombre, seccion, tipo, fecha_inicio, fecha_fin, foto]);
    }

    return response;
  }

  Future<http.Response> removerEvento(String id, String fotoURL) async {
    int a = int.parse(id);
    print(a);

    var url = ConfigApi.buildUrl('/evento/$a');

    if (fotoURL != null && fotoURL.isNotEmpty) {
      await FirebaseStorage.instance.refFromURL(fotoURL).delete();
    }

    var response = await http.delete(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );

    print("${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 204) {
      await _deleteRow(a);
    }

    return response;
  }
}
