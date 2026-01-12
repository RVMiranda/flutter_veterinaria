import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:image/image.dart' as img;
import '../models/protocolo.dart';
import '../models/veterinaria_info.dart';
import '../models/medico.dart';
import '../models/paciente.dart';
import '../models/propietario.dart';

class PdfGenerator {
  static Future<Uint8List> generateProtocolPdf({
    required Protocolo protocolo,
    VeterinariaInfo? vetInfo,
    Medico? medico,
    Paciente? paciente,
    Propietario? propietario,
  }) async {
    final doc = pw.Document();

    final font = await PdfGoogleFonts.latoRegular();
    final fontBold = await PdfGoogleFonts.latoBold();

    // Pre-procesar imágenes para evitar OOM/Crashes
    Uint8List? logoBytes;
    if (vetInfo?.logoPath != null) {
      logoBytes = await _processImage(vetInfo!.logoPath!);
    }

    List<Uint8List> processedImages = [];
    if (protocolo.imagenes != null) {
      for (final path in protocolo.imagenes!) {
        final bytes = await _processImage(path);
        if (bytes != null) {
          processedImages.add(bytes);
        }
      }
    }

    final fecha = DateTime.parse(protocolo.fechaCreacion);
    final fechaFormato =
        '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return [
            _buildHeader(vetInfo, fontBold, logoBytes),
            pw.SizedBox(height: 20),
            _buildSectionTitle(
              'INFORMACIÓN DEL PACIENTE Y PROPIETARIO',
              fontBold,
            ),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (paciente != null) ...[
                    _buildInfoRow('Paciente', paciente.nombre, fontBold),
                    _buildInfoRow(
                      'Especie/Raza',
                      '${paciente.especie ?? '-'} / ${paciente.raza ?? '-'}',
                      fontBold,
                    ),
                    _buildInfoRow('Sexo', paciente.genero ?? '-', fontBold),
                    _buildInfoRow(
                      'Edad',
                      '${paciente.calcularEdad() ?? '-'} años',
                      fontBold,
                    ),
                  ],
                  if (propietario != null) ...[
                    pw.Divider(color: PdfColors.grey300),
                    _buildInfoRow(
                      'Propietario',
                      propietario.nombreCompleto,
                      fontBold,
                    ),
                    if (propietario.telefono != null)
                      _buildInfoRow(
                        'Teléfono',
                        propietario.telefono!,
                        fontBold,
                      ),
                    if (propietario.email != null)
                      _buildInfoRow('Email', propietario.email!, fontBold),
                    if (propietario.direccion != null)
                      _buildInfoRow(
                        'Dirección',
                        propietario.direccion!,
                        fontBold,
                      ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            _buildSectionTitle('INFORMACIÓN DEL PROTOCOLO', fontBold),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Número de Protocolo',
                    protocolo.numeroInterno ?? '-',
                    fontBold,
                  ),
                  _buildInfoRow('Fecha', fechaFormato, fontBold),
                  _buildInfoRow(
                    'Médico Remitente',
                    medico?.nombreCompleto ?? '-',
                    fontBold,
                  ),
                  _buildInfoRow(
                    'Edad al Momento',
                    protocolo.edadAlMomento != null
                        ? '${protocolo.edadAlMomento} años'
                        : '-',
                    fontBold,
                  ),
                  _buildInfoRow(
                    'Peso al Momento',
                    protocolo.pesoAlMomento != null
                        ? '${protocolo.pesoAlMomento} kg'
                        : '-',
                    fontBold,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            _buildSectionTitle('DATOS CLÍNICOS', fontBold),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Anamnesis',
                    protocolo.anamnesis ?? '-',
                    fontBold,
                  ),
                  _buildInfoRow(
                    'Dx. Presuntivo',
                    protocolo.dxPresuntivo ?? '-',
                    fontBold,
                  ),
                  _buildInfoRow(
                    'Tejidos Enviados',
                    protocolo.tejidosEnviados ?? '-',
                    fontBold,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            _buildSectionTitle('MUESTRA', fontBold),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Sitio Anatómico',
                    protocolo.sitioAnatomico ?? '-',
                    fontBold,
                  ),
                  _buildInfoRow(
                    'Método de Obtención',
                    protocolo.metodoObtencion ?? '-',
                    fontBold,
                  ),
                ],
              ),
            ),
            if (processedImages.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              _buildSectionTitle('IMÁGENES', fontBold),
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: processedImages.map((bytes) {
                  return pw.Container(
                    width: 200,
                    height: 200,
                    child: pw.Image(
                      pw.MemoryImage(bytes),
                      fit: pw.BoxFit.contain,
                    ),
                  );
                }).toList(),
              ),
            ],
            pw.SizedBox(height: 20),
            _buildSectionTitle('RESULTADOS', fontBold),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Aspecto Macroscópico',
                    protocolo.aspectoMacroscopico ?? '-',
                    fontBold,
                  ),
                  _buildInfoRow(
                    'Aspecto Microscópico',
                    protocolo.aspectoMicroscopico ?? '-',
                    fontBold,
                  ),
                  _buildInfoRow(
                    'Diagnóstico Citológico',
                    protocolo.diagnosticoCitologico ?? '-',
                    fontBold,
                  ),
                  _buildInfoRow(
                    'Observaciones',
                    protocolo.observaciones ?? '-',
                    fontBold,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 40),
            pw.Divider(),
            pw.Center(
              child: pw.Text(
                'Generado por App Veterinaria',
                style: const pw.TextStyle(
                  color: PdfColors.grey500,
                  fontSize: 10,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  static Future<Uint8List?> _processImage(
    String path, {
    int maxWidth = 800,
  }) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      // Ejecutar decodificación y redimensionamiento en un microtask o simplemente síncrono
      // pero el 'image' package es síncrono.
      // Para evitar bloquear UI, lo ideal es compute, pero por ahora simplifiquemos:
      // Si la imagen es muy grande, decodeImage puede tardar.

      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Redimensionar solo si es necesario para ahorrar memoria
      if (image.width > maxWidth || image.height > maxWidth) {
        final resized = img.copyResize(
          image,
          width: image.width > image.height ? maxWidth : null,
          height: image.height > image.width ? maxWidth : null,
          maintainAspect: true,
        );
        return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
      } else {
        // Re-encoding siempre es bueno para normalizar formato a JPG que PDF soporta bien
        return Uint8List.fromList(img.encodeJpg(image, quality: 70));
      }
    } catch (e) {
      print('Error procesando imagen $path: $e');
      return null;
    }
  }

  static pw.Widget _buildHeader(
    VeterinariaInfo? info,
    pw.Font fontBold,
    Uint8List? logoBytes,
  ) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logoBytes != null)
              pw.Container(
                width: 80,
                height: 80,
                margin: const pw.EdgeInsets.only(right: 20),
                child: pw.Image(
                  pw.MemoryImage(logoBytes),
                  fit: pw.BoxFit.contain,
                ),
              ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    info?.nombreClinica ?? 'PROTOCOLO CITOLÓGICO',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: fontBold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    info?.direccion ?? '',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  if (info?.telefonoPrincipal != null)
                    pw.Text(
                      'Tel: ${info!.telefonoPrincipal}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  if (info?.emailContacto != null)
                    pw.Text(
                      'Email: ${info!.emailContacto}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        pw.Divider(height: 20, thickness: 2, color: PdfColors.blue900),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font fontBold) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          font: fontBold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                font: fontBold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
