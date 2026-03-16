import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gircik/core/network/api_client.dart';
import 'package:gircik/data/models/subscription.dart';

class SubscriptionRepository {
  final ApiClient _apiClient;

  SubscriptionRepository(this._apiClient);

  Future<Subscription> getStatus() async {
    try {
      final response = await _apiClient.client.get('/subscription/');
      return Subscription.fromJson(response.data);
    } catch (e) {
      throw Exception('Abonelik bilgisi alınamadı: \${_handleError(e)}');
    }
  }

  Future<Subscription> purchase(String plan) async {
    try {
      final response = await _apiClient.client.post(
        '/subscription/purchase',
        queryParameters: {'plan': plan},
      );
      return Subscription.fromJson(response.data);
    } catch (e) {
      throw Exception('Satın alma işlemi başarısız: \${_handleError(e)}');
    }
  }

  Future<Subscription> cancel() async {
    try {
      final response = await _apiClient.client.post('/subscription/cancel');
      return Subscription.fromJson(response.data);
    } catch (e) {
      throw Exception('İptal işlemi başarısız: \${_handleError(e)}');
    }
  }

  Future<Subscription> incrementUsage(String metric) async {
    try {
      final response = await _apiClient.client.post(
        '/subscription/usage',
        queryParameters: {'metric': metric},
      );
      return Subscription.fromJson(response.data);
    } catch (e) {
      throw Exception('Kullanım artırırken hata: \${_handleError(e)}');
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

final subscriptionRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SubscriptionRepository(apiClient);
});
