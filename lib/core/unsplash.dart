String unsplashUrl(String photoId, {int w = 400, int h = 300}) {
  return 'https://images.unsplash.com/photo-$photoId?w=$w&h=$h&fit=crop&auto=format&q=80';
}
