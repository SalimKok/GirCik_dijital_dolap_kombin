import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/data/models/travel_plan.dart';
import 'package:gircik/core/network/api_client.dart';

class TravelRepository {
  final ApiClient _apiClient;

  TravelRepository(this._apiClient);

  Future<TravelPlan> generateTravelPlan({
    required String destination,
    required String startDate,
    required String endDate,
    required String purpose,
    bool isHijab = false,
  }) async {
    try {
      final response = await _apiClient.client.post('/travel/generate?is_hijab=$isHijab', data: {
        'destination': destination,
        'start_date': startDate,
        'end_date': endDate,
        'purpose': purpose,
      });
      return TravelPlan.fromJson(response.data);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<TravelPlan>> getTravelPlans() async {
    try {
      final response = await _apiClient.client.get('/travel/');
      return (response.data as List).map((json) => TravelPlan.fromJson(json)).toList();
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> deleteTravelPlan(String id) async {
    try {
      await _apiClient.client.delete('/travel/$id');
    } catch (e) {
      throw Exception(_handleError(e));
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

final travelRepositoryProvider = Provider((ref) {
  return TravelRepository(ref.watch(apiClientProvider));
});
