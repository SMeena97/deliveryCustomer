import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';

class CartBottomDetailsWidget extends StatelessWidget {
  const CartBottomDetailsWidget({
    Key key,
    @required CartController con,
  })  : _con = con,
        super(key: key);

  final CartController _con;

  @override
  Widget build(BuildContext context) {
    return _con.carts.isEmpty
        ? SizedBox(height: 0)
        : Container(
            height: 240,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.15),
                      offset: Offset(0, -2),
                      blurRadius: 5.0)
                ]),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).subtotal,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(_con.subTotal, context,
                          style: Theme.of(context).textTheme.subtitle1,
                          zeroPlaceholder: '0')
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).delivery_fee,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      // if (Helper.canDelivery(_con.carts[0].food.restaurant, carts: _con.carts))
                      // Helper.getPrice(_con.carts[0].food.restaurant.deliveryFee, context,
                      //     style: Theme.of(context).textTheme.subtitle1, zeroPlaceholder: 'Free')
                      // else
                      Text(_con.subtotal_delivery_charge.toString(),
                          style: TextStyle(fontSize: 18))
                      // Helper.getPrice(0, context, style: Theme.of(context).textTheme.subtitle1, zeroPlaceholder: 'Free')
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).tax,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Text(_con.tax.toString(), style: TextStyle(fontSize: 18))
                      // Helper.getPrice(_con.taxAmount, context, style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (bool value) {
                          // setState(() {
                          //   this.showvalue = value;
                          // });
                        },
                      ),
                      Text(
                        S.of(context).cash_on_delivery,
                      )
                    ],
                  ),
                  _con.total.toString() != '0.0'
                      ? Stack(
                          fit: StackFit.loose,
                          alignment: AlignmentDirectional.centerEnd,
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: FlatButton(
                                onPressed: () {
                                  _con.goCheckout(context);
                                },
                                disabledColor: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.5),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                color: Theme.of(context).accentColor,
                                shape: StadiumBorder(),
                                child: Text(
                                  S.of(context).order,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .merge(TextStyle(
                                          color:
                                              Theme.of(context).primaryColor)),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                _con.total.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4
                                    .merge(TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              ),
                            )
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 20),
                            //   child: Helper.getPrice(_con.total, context,
                            //       style: Theme.of(context).textTheme.headline4.merge(TextStyle(color: Theme.of(context).primaryColor)),),
                            // )
                          ],
                        )
                      : Text('loading...'),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
  }
}
