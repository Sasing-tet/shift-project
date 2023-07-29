
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_state_provider.dart';

part 'isloading_provider.g.dart';

@riverpod
bool isLoading(IsLoadingRef ref) {
  final authState = ref.watch(authStateProvider);
  // final isUploadingImage = ref.watch(uploaderProvider);
  // final isSendingComment = ref.watch(sendCommentProvider);
  // final isDeletingComment = ref.watch(deleteCommentProvider);
  // final isDeletingPost = ref.watch(deletePostProvider);

  return authState.isLoading;
  // ||
  //     isUploadingImage ||
  //     isSendingComment ||
  //     isDeletingComment ||
  //     isDeletingPost;
}
