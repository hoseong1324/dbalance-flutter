import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/expense.dart';

class ItemsRepository {
  final DioClient _dioClient = DioClient();

  /// 지출 생성
  Future<Expense> createExpense({
    required int roomId,
    required int roundId,
    required int payerParticipantId,
    required int totalAmount,
    String? currency,
    String? memo,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _dioClient.dio.post('/items/expenses', data: {
        'roomId': roomId,
        'roundId': roundId,
        'payerParticipantId': payerParticipantId,
        'totalAmount': totalAmount,
        if (currency != null) 'currency': currency,
        if (memo != null) 'memo': memo,
        'items': items,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return Expense.fromJson(data['data']);
        } else {
          return Expense.fromJson(data);
        }
      } else {
        throw Exception('지출 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('지출 생성 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleItemError(e);
    }
  }

  /// 지출 조회
  Future<Expense> getExpense(int expenseId) async {
    try {
      final response = await _dioClient.dio.get('/items/expenses/$expenseId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return Expense.fromJson(data['data']);
        } else {
          return Expense.fromJson(data);
        }
      } else {
        throw Exception('지출 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('지출 조회 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleItemError(e);
    }
  }

  /// 라운드별 지출 목록 조회
  Future<List<Expense>> getExpensesByRound(int roomId, int roundId) async {
    try {
      final response = await _dioClient.dio.get('/items/rooms/$roomId/rounds/$roundId/expenses');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final List<dynamic> expenses = data['data'];
          return expenses.map((json) => Expense.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => Expense.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('지출 목록 조회 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('지출 목록 조회 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleItemError(e);
    }
  }

  /// 지출 수정
  Future<Expense> updateExpense(int expenseId, {
    int? totalAmount,
    String? currency,
    String? memo,
  }) async {
    try {
      final response = await _dioClient.dio.patch('/items/expenses/$expenseId', data: {
        if (totalAmount != null) 'totalAmount': totalAmount,
        if (currency != null) 'currency': currency,
        if (memo != null) 'memo': memo,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return Expense.fromJson(data['data']);
        } else {
          return Expense.fromJson(data);
        }
      } else {
        throw Exception('지출 수정 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('지출 수정 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleItemError(e);
    }
  }

  /// 지출 삭제
  Future<int> deleteExpense(int expenseId) async {
    try {
      final response = await _dioClient.dio.delete('/items/expenses/$expenseId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('affected')) {
          return data['affected'] ?? 0;
        } else {
          return 0;
        }
      } else {
        throw Exception('지출 삭제 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('지출 삭제 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleItemError(e);
    }
  }

  /// 지출 아이템 수정
  Future<ExpenseItem> updateExpenseItem(int itemId, {
    String? category,
    int? amount,
  }) async {
    try {
      final response = await _dioClient.dio.patch('/items/expense-items/$itemId', data: {
        if (category != null) 'category': category,
        if (amount != null) 'amount': amount,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return ExpenseItem.fromJson(data['data']);
        } else {
          return ExpenseItem.fromJson(data);
        }
      } else {
        throw Exception('지출 아이템 수정 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('지출 아이템 수정 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleItemError(e);
    }
  }

  /// 지출 아이템 삭제
  Future<int> deleteExpenseItem(int itemId) async {
    try {
      final response = await _dioClient.dio.delete('/items/expense-items/$itemId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('affected')) {
          return data['affected'] ?? 0;
        } else {
          return 0;
        }
      } else {
        throw Exception('지출 아이템 삭제 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('지출 아이템 삭제 오류: ${e.message}');
        if (e.response?.data != null) {
          print('응답: ${e.response?.data}');
        }
      }
      throw _handleItemError(e);
    }
  }

  /// 에러 처리
  Exception _handleItemError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? '지출 관련 오류가 발생했습니다';
        return Exception(message);
      }
    }
    return Exception('네트워크 오류가 발생했습니다');
  }
}