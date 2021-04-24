import 'package:flutter/cupertino.dart';
import 'package:food_delivery_app/src/models/offer.dart';
import 'package:food_delivery_app/src/models/slide_banner.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/vendor_category.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../models/slide.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/slider_repository.dart';

class HomeController extends ControllerMVC {
  List<VendorCategory> categories = <VendorCategory>[];
  List<SlideBanner> slides = <SlideBanner>[];
  List<Restaurant> topRestaurants = <Restaurant>[];
  List<Restaurant> popularRestaurants = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  List<Food> trendingFoods = <Food>[];
  List<Offer> offers = <Offer>[];

  HomeController() {
    listenForTopRestaurants();
    listenForOffer();
    listenForSlides();
    listenForTrendingFoods();
    listenForCategories();
    listenForPopularRestaurants();
    listenForRecentReviews();
  }

  Future<void> listenForSlides() async {
    final Stream<SlideBanner> stream = await getSlides();
    stream.listen((SlideBanner _slide) {
     /* print('slider response..');
      print(_slide.image);*/
      setState(() => slides.add(_slide));
    /*  print(_slide.image);*/
    }, onError: (a) {
      // print('error here..');
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories() async {
    // print('lisen1');
    final Stream<VendorCategory> stream = await getCategories();
    stream.listen((VendorCategory _category) {
      // print('out'+_category.toString());
      setState(() => categories.add(_category));
      // print('ary'+categories.length.toString());
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForTopRestaurants() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.getString('category');
    final Stream<Restaurant> stream = await getNearRestaurants(prefs.getString('category'));
    stream.listen((Restaurant _restaurant) {
      setState(() => topRestaurants.add(_restaurant));
    }, onError: (a) {}, onDone: () {});
  }
   Future<void> listenForOffer() async {
 
    final Stream<Offer> stream = await getOffers();
    stream.listen((Offer _offer) {
      setState(() => offers.add(_offer));
      
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForPopularRestaurants() async {
    final Stream<Restaurant> stream = await getPopularRestaurants(deliveryAddress.value);
    stream.listen((Restaurant _restaurant) {
      setState(() => popularRestaurants.add(_restaurant));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForTrendingFoods() async {
    final Stream<Food> stream = await getTrendingFoods(deliveryAddress.value);
    stream.listen((Food _food) {
      /*print('getTrendingFoods input..');
      print(_food.name);*/
      setState(() => trendingFoods.add(_food));
    }, onError: (a) {
      print('getTrendingFoods error...');
      print(a);
    }, onDone: () {});
  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      deliveryAddress.value = _address;
      await refreshHome();
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }

  Future<void> refreshHome() async {
    setState(() {
      slides = <SlideBanner>[];
      categories = <VendorCategory>[];
      topRestaurants = <Restaurant>[];
      popularRestaurants = <Restaurant>[];
      recentReviews = <Review>[];
      trendingFoods = <Food>[];
    });
    await listenForSlides();
    await listenForTopRestaurants();
    await listenForTrendingFoods();
    await listenForCategories();
    await listenForPopularRestaurants();
    await listenForRecentReviews();
  }
}
