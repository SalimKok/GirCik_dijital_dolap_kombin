import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/network/api_client.dart';
import 'package:gircik/data/models/calendar_event.dart';

class CalendarRepository {
  final ApiClient _apiClient;

  CalendarRepository(this._apiClient);

  Future<List<CalendarEvent>> getEvents() async {
    try {
      final response = await _apiClient.client.get('/calendar/');
      final data = response.data as List;
      return data.map((item) => CalendarEvent.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Etkinlikler getirilemedi: \${_handleError(e)}');
    }
  }

  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    try {
      final response = await _apiClient.client.post(
        '/calendar/',
        data: event.toJson(),
      );
      return CalendarEvent.fromJson(response.data);
    } catch (e) {
      throw Exception('Etkinlik oluşturulamadı: \${_handleError(e)}');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _apiClient.client.delete('/calendar/$id');
    } catch (e) {
      throw Exception('Etkinlik silinemedi: \${_handleError(e)}');
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data['detail'] != null) {
        return error.response!.data['detail'].toString();
      }
      return error.message ?? 'Bilinmeyen bir hata oluştu';
    }
    return error.toString();
  }
}

final calendarRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CalendarRepository(apiClient);
});
