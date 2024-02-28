// post_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/post_bloc.dart';
import '../models/post_request.dart';

class PostPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Posts'),
          backgroundColor: Colors.black,
        ),
        body: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostInitialState) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<PostBloc>(context).add(FetchPostsEvent());
                  },
                  child: Text('Load posts'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                  ),
                ),
              );
            } else if (state is PostLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is PostSuccessState) {
              final List<PostRequest> posts = state.posts;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(posts[index].title),
                    subtitle: Text(posts[index].body),
                  );
                },
              );
            } else if (state is PostErrorState) {
              return Center(
                child: Text('Error: ${state.errorMessage}'),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
