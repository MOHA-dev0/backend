class SliderAd {
  final int id;
  final String? title;
  final String imageUrl;
  final String? link;

  SliderAd({required this.id, this.title, required this.imageUrl, this.link});

  factory SliderAd.fromJson(Map<String, dynamic> json) {
    return SliderAd(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      link: json['link'],
    );
  }
}
