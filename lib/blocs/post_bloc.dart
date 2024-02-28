// Events

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:httpcallapi/services/env_service.dart';

import '../models/post_request.dart';

// Events

abstract class PostEvent {}

class FetchPostsEvent extends PostEvent {}

// States

abstract class PostState {}

class PostInitialState extends PostState {}

class PostLoadingState extends PostState {}

class PostSuccessState extends PostState {
  final List<PostRequest> posts;

  PostSuccessState(this.posts);
}

class PostErrorState extends PostState {
  final String errorMessage;

  PostErrorState(this.errorMessage);
}

// Bloc
class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostInitialState()) {
    on<FetchPostsEvent>(_fetchPosts);
  }

  void _fetchPosts(FetchPostsEvent event, Emitter<PostState> emit) async {
    emit(PostLoadingState());
    final url = Uri.parse('${EnvService.postUrl}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<PostRequest> posts =
        jsonData.map((e) => PostRequest.fromJson(e)).toList();
        emit(PostSuccessState(posts));
      } else {
        emit(PostErrorState('Failed to fetch posts'));
      }
    } catch (e) {
      emit(PostErrorState('Error: $e'));
    }
  }
}
