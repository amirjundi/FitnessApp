import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../models/workout_plan.dart';
import '../models/plan_day.dart';
import '../models/day_exercise.dart';
import '../models/player.dart';

class PdfService {
  static pw.Font? _cachedFont;
  static pw.Font? _cachedBoldFont;
  static bool _fontLoadAttempted = false;

  /// Pre-load fonts once for the app session
  static Future<void> ensureFontsLoaded() async {
    if (_fontLoadAttempted) return;
    _fontLoadAttempted = true;
    
    try {
      // Try downloading Cairo font directly from Google Fonts CDN
      final regularResponse = await http.get(Uri.parse(
        'https://fonts.gstatic.com/s/cairo/v28/SLXgc1nY6HkvangtZmpQdkhzfH5lkSs2SgRjCAGMQ1z0hOA-a1PiLQ.ttf'
      )).timeout(const Duration(seconds: 10));
      
      if (regularResponse.statusCode == 200) {
        _cachedFont = pw.Font.ttf(regularResponse.bodyBytes.buffer.asByteData());
      }
      
      final boldResponse = await http.get(Uri.parse(
        'https://fonts.gstatic.com/s/cairo/v28/SLXgc1nY6HkvangtZmpQdkhzfH5lkSs2SgRjCAGMQ1z0hL4-a1PiLQ.ttf'
      )).timeout(const Duration(seconds: 10));
      
      if (boldResponse.statusCode == 200) {
        _cachedBoldFont = pw.Font.ttf(boldResponse.bodyBytes.buffer.asByteData());
      }
    } catch (e) {
      print('Failed to load fonts from CDN: $e');
    }
    
    // Fallback to PdfGoogleFonts if direct download failed
    if (_cachedFont == null) {
      try {
        _cachedFont = await PdfGoogleFonts.cairoRegular();
        _cachedBoldFont = await PdfGoogleFonts.cairoBold();
      } catch (e) {
        print('Failed to load PdfGoogleFonts: $e');
      }
    }
    
    // Ultimate fallback - use Helvetica (won't support Arabic but won't crash)
    _cachedFont ??= pw.Font.helvetica();
    _cachedBoldFont ??= pw.Font.helveticaBold();
  }

  Future<Uint8List> generatePlanPdf(WorkoutPlan plan, List<PlanDay> days, {Player? player}) async {
    await ensureFontsLoaded();
    
    final pdf = pw.Document();
    
    final theme = pw.ThemeData.withFont(
      base: _cachedFont!,
      bold: _cachedBoldFont!,
    );

    // Create header page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: theme,
        build: (pw.Context context) {
          return _buildHeader(plan, player, days.length);
        },
      ),
    );

    // Create separate page for each day
    for (final day in days) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: theme,
          build: (pw.Context context) {
            return _buildDayPage(day, plan.name);
          },
        ),
      );
    }

    return pdf.save();
  }

  pw.Widget _buildHeader(WorkoutPlan plan, Player? player, int totalDays) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.SizedBox(height: 100),
        pw.Text(
          plan.name,
          style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 30),
        if (player != null) ...[
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  player.name,
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    if (player.weight != null)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue50,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'Weight: ${player.weight} kg',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ),
                    if (player.weight != null && player.height != null)
                      pw.SizedBox(width: 20),
                    if (player.height != null)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green50,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'Height: ${player.height} cm',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
        pw.SizedBox(height: 30),
        if (plan.description != null && plan.description!.isNotEmpty) ...[
          pw.Text(
            plan.description!,
            style: const pw.TextStyle(fontSize: 14),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 20),
        ],
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: pw.BoxDecoration(
            color: PdfColors.teal50,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            'Total Days: $totalDays',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          plan.difficultyLevel,
          style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _buildDayPage(PlanDay day, String planName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Day Header
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: day.isRestDay ? PdfColors.orange100 : PdfColors.blue100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Day ${day.sequenceOrder}',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
              if (day.isRestDay)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'Rest Day',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                )
              else if (day.focusArea != null && day.focusArea!.isNotEmpty)
                pw.Text(
                  day.focusArea!,
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // Exercises Table
        if (!day.isRestDay && day.exercises.isNotEmpty)
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(3), // Exercise Name
              1: const pw.FlexColumnWidth(2), // Sets/Reps
              2: const pw.FlexColumnWidth(2), // Notes
              3: const pw.FlexColumnWidth(1.5), // Video
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Exercise', isHeader: true),
                  _buildTableCell('Sets', isHeader: true),
                  _buildTableCell('Notes', isHeader: true),
                  _buildTableCell('Video', isHeader: true),
                ],
              ),
              // Exercise Rows
              ...day.exercises.map((ex) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(ex.exerciseName ?? 'Exercise'),
                    _buildSetDetails(ex),
                    _buildTableCell(ex.notes ?? '-'),
                    _buildVideoLink(ex.youtubeUrl),
                  ],
                );
              }),
            ],
          )
        else if (!day.isRestDay)
          pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Text(
                'No exercises added for this day',
                style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
              ),
            ),
          )
        else
          pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(60),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Rest and recover for the next day',
                    style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  /// Convenience wrapper specifically for player workout exports
  Future<Uint8List> generatePlayerPlanPdf(Player player, WorkoutPlan plan, List<PlanDay> days) async {
    return generatePlanPdf(plan, days, player: player);
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildSetDetails(DayExercise ex) {
    if (ex.sets.isEmpty) {
      return _buildTableCell('-');
    }
    
    final setsText = ex.sets.asMap().entries.map((entry) {
      final idx = entry.key + 1;
      final s = entry.value;
      return 'Set $idx: ${s.reps} reps';
    }).join('\n');
    
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        setsText,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  pw.Widget _buildVideoLink(String? url) {
    if (url == null || url.isEmpty) {
      return _buildTableCell('-');
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.UrlLink(
        destination: url,
        child: pw.Text(
          'Watch',
          style: const pw.TextStyle(
            fontSize: 11,
            color: PdfColors.blue700,
            decoration: pw.TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
