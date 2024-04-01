
import 'package:flutter/foundation.dart';
import '../../../main.dart';

import '../typedef/user_id.dart';

@immutable
class UserInfoStorage {
  const UserInfoStorage();
  Future<bool> saveUserInfo({
    required UserId userId,
    required String displayName,
    required String? email,
  }) async {
    try {
      final userInfo = await supabase.from('driver').select('driver_id').eq('driver_id', userId);

      debugPrint(userInfo.toString());

      if (userInfo != null) {
        return true;
      }

      await supabase
      .from('driver')
      .insert({'driver_id': userId, 'email': email, 'full_name': displayName});
      return true;
    } catch (_) {
      return false;
    }
  }
}