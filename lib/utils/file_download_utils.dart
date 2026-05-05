import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'snackbar_utils.dart';

/// Menyimpan PDF ke folder Download publik (/storage/emulated/0/Download/)
/// yang bisa dilihat langsung di Files app Android.
class FileDownloadUtils {
  static Future<void> saveAndOpen({
    required ScaffoldMessengerState messenger,
    required List<int> bytes,
    required String filename,
  }) async {
    String? savedPath;

    try {
      if (Platform.isAndroid) {
        // Strategi 1: Public Downloads folder — visible di Files app
        // Path: /storage/emulated/0/Download/
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists() ||
            await _tryCreate(publicDownload)) {
          savedPath = '${publicDownload.path}/$filename';
        }

        // Strategi 2: External storage app-specific (Android/data/...)
        if (savedPath == null) {
          final ext = await getExternalStorageDirectory();
          if (ext != null) {
            savedPath = '${ext.path}/$filename';
          }
        }
      }

      // Strategi 3: App documents (private, sebagai last resort)
      savedPath ??= '${(await getApplicationDocumentsDirectory()).path}/$filename';

      // Tulis file
      await File(savedPath).writeAsBytes(bytes, flush: true);

      // Trigger media scanner agar muncul di file manager
      await _tryMediaScan(savedPath);

      final sizeKb = (bytes.length / 1024).toStringAsFixed(1);
      SnackbarUtils.showModernSnackBarOnMessenger(
        messenger,
        'PDF tersimpan ($sizeKb KB)\n$savedPath',
      );
    } catch (e) {
      // Fallback ke temp cache
      try {
        final tmp = await getTemporaryDirectory();
        final tmpPath = '${tmp.path}/$filename';
        await File(tmpPath).writeAsBytes(bytes, flush: true);
        final sizeKb = (bytes.length / 1024).toStringAsFixed(1);
        SnackbarUtils.showModernSnackBarOnMessenger(
          messenger,
          'PDF tersimpan cache ($sizeKb KB)\n$tmpPath',
        );
      } catch (e2) {
        SnackbarUtils.showModernSnackBarOnMessenger(
          messenger,
          'Gagal simpan PDF: ${_short(e2)}',
          isError: true,
        );
      }
    }
  }

  static Future<bool> _tryCreate(Directory dir) async {
    try {
      await dir.create(recursive: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _tryMediaScan(String path) async {
    try {
      const ch = MethodChannel('flutter/media_scanner');
      await ch.invokeMethod('scanFile', path);
    } catch (_) {}
  }

  static String _short(Object e) {
    final s = e.toString();
    return s.length > 80 ? '${s.substring(0, 80)}...' : s;
  }
}
