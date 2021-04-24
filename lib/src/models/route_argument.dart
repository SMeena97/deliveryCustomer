class RouteArgument {
  String id;
  String restaurantId;
  String heroTag;
  dynamic param;

  RouteArgument({this.id, this.heroTag, this.param,this.restaurantId});

  @override
  String toString() {
    return '{id: $id, heroTag:${heroTag.toString()}}';
  }
}
