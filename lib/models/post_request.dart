class PostRequest {
  final int userId;
  final int id;
  final String title;
  final String body;

  PostRequest(
      {required this.userId,
      required this.id,
      required this.title,
      required this.body});

  factory PostRequest.fromJson(Map<String, dynamic> json) {
    return PostRequest(
        userId: json['userId'] as int,
        id: json['id'] as int,
        title: json['title'] as String,
        body: json['body'] as String);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['id'] = this.id;
    data['title'] = this.title;
    data['body'] = this.body;
    return data;
  }
}
