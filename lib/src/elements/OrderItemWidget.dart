import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/pages/bill_image.dart';
import 'package:food_delivery_app/src/pages/live_tracking.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';
import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import 'FoodOrderItemWidget.dart';
import '../chat/chat.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItemWidget extends StatefulWidget {
  // final bool expanded;
  // final Order order;
  // final ValueChanged<void> onCanceled;
  final String orderid;
  final String status;
  final String total;
  final String paymenttype;
  final String ordertime;
  final String deliveryboyid;
  final Function cancel;
  final String deliveryFee;
  final String tax;
  final String appcharge;
  final String dmobile;

  OrderItemWidget(
      {Key key,
      this.orderid,
      this.status,
      this.total,
      this.paymenttype,
      this.ordertime,
      this.cancel,
      this.deliveryFee,
      this.tax,
      this.deliveryboyid,
      this.appcharge,
      this.dmobile})
      : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  Future<void> _showMyDialog(String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Text('This is a demo alert dialog.'),
                Text('Do you want to cancel the order?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                widget.cancel();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showContactDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your order is confirmed...'),
                Text('Please contact delivery boy to cancel the order'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 14),
                padding: EdgeInsets.only(top: 20, bottom: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Theme(
                  data: theme,
                  child: ExpansionTile(
                    // initiallyExpanded: widget.expanded,
                    title: Column(
                      children: <Widget>[
                        Text(S.of(context).order_id + " " + widget.orderid),
                        Text(
                          (widget.ordertime),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Helper.getPrice(Helper.getTotalOrdersPrice(widget.order), context, style: Theme.of(context).textTheme.headline4),
                        Text(
                          S.of(context).payment_mode + " " + widget.paymenttype,
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
                    children: <Widget>[
                      Column(),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Visibility(
                                    child: Text(
                                      S.of(context).delivery_fee +
                                          " " +
                                          (int.parse(widget.deliveryFee) +
                                                  (int.parse(widget.appcharge)))
                                              .toString(),
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    visible: false,
                                  ),
                                ),
                                // Helper.getPrice(widget.order.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1)
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        S.of(context).total + ": ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      Text(
                                        widget.total == '0'
                                            ? 'Price Not Estimated'
                                            : widget.total,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                ),
                                // Helper.getPrice(Helper.getTotalOrdersPrice(widget.order), context, style: Theme.of(context).textTheme.headline4)
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              widget.status != 'Cancelled' && widget.status != 'Delivered' && widget.status != 'Rejected'
                  ? Container(
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              // Navigator.of(context).pushNamed('/Tracking', arguments: RouteArgument(id: widget.order.id));
                              widget.status == 'Pending' ||
                                      widget.status == 'OpendOrderPending'
                                  ? _showMyDialog(widget.orderid)
                                  : _showContactDialog();
                            },
                            textColor: Theme.of(context).hintColor,
                            child: Wrap(
                              children: <Widget>[Text(S.of(context).cancel)],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 0),
                          ),
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(start: 20),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 28,
          width: MediaQuery.of(context).size.width*0.50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              color: widget.status == "On Way" || widget.status == 'Confirmed'
                  ? Colors.green
                  : Theme.of(context).accentColor),
          alignment: AlignmentDirectional.center,
          child: Row(
            children: [
              if (widget.status == 'Pending' ||
                  widget.status == 'OpendOrderPending')
                Text(
                  S.of(context).pending,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.caption.merge(TextStyle(
                      height: 1, color: Theme.of(context).primaryColor)),
                ),
              if (widget.status == 'Cancelled')
                Text(
                  S.of(context).cancelled,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.caption.merge(TextStyle(
                      height: 1, color: Theme.of(context).primaryColor)),
                ),
              if (widget.status == 'Delivered')
                Text(
                  S.of(context).delivered,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.caption.merge(TextStyle(
                      height: 1, color: Theme.of(context).primaryColor)),
                ),
              if (widget.status == 'On Way')
                Text(
                  S.of(context).onway,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.caption.merge(TextStyle(
                      height: 1, color: Theme.of(context).primaryColor)),
                ),
              if (widget.status == 'Rejected')
                Text(
                  S.of(context).rejected,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.caption.merge(TextStyle(
                      height: 1, color: Theme.of(context).primaryColor)),
                ),
              if (widget.status == 'Confirmed')
                Text(
                  S.of(context).confirmed,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.caption.merge(TextStyle(
                      height: 1, color: Theme.of(context).primaryColor)),
                ),
              SizedBox(
                width: 5,
              ),
              widget.status == "On Way" || widget.status == 'Confirmed'
                  ? Row(
                      children: [
                        GestureDetector(
                          child: Icon(
                            Icons.chat,
                            color: Colors.white,
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Chat(
                                          peerId: widget.deliveryboyid,
                                          orderId: widget.orderid,
                                        )));
                          },
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.description,
                            color: Colors.white,
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BillImage(
                                          orderId: widget.orderid,
                                        )));
                            // Navigator.of(context).popAndPushNamed('/map');
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.call,
                            color: Colors.white,
                          ),
                          onTap: () {
                            launch("tel:${widget.dmobile}");
                          },
                        )
                      ],
                    )
                  : Container()
            ],
          ),
        ),
      ],
    );
  }
}
