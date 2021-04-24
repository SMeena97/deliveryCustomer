import 'dart:convert';

import 'package:food_delivery_app/src/models/slide_banner.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/slide.dart';

// Future<Stream<Slide>> getSlides() async {
//   Uri uri = Helper.getBaseUri('api/slides');
//   Map<String, dynamic> _queryParams = {
//     'with': 'food;restaurant',
//     'search': 'enabled:1',
//     'orderBy': 'order',
//     'sortedBy': 'asc',
//   };
//   uri = uri.replace(queryParameters: _queryParams);
//   try {
//     final client = new http.Client();
//     final streamedRest = await client.send(http.Request('get', uri));

//     return streamedRest.stream
//         .transform(utf8.decoder)
//         .transform(json.decoder)
//         .map((data) => Helper.getBaseData(data))
//         .expand((data) => (data as List))
//         .map((data) => Slide.fromJSON(data));
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
//     return new Stream.value(new Slide.fromJSON({}));
//   }
// }



Future<Stream<SlideBanner>> getSlides() async {

  final String url =
      '${GlobalConfiguration().getValue('local_url')}Banner/loadbanners';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    
    return SlideBanner.fromJSON(data);
  });
}
