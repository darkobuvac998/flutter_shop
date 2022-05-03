// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart' show CartProvider;
import '../providers/orders.dart' show Orders;
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-screen';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your cart',
        ),
      ),
      body: Column(children: [
        Card(
          margin: const EdgeInsets.all(
            15,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    '\$${cart.totalAmount.toStringAsFixed(
                      2,
                    )}',
                    style: TextStyle(
                      color:
                          Theme.of(context).primaryTextTheme.headline6?.color,
                    ),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                OrderButton(
                  cart: cart,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: cart.items.isNotEmpty
              ? ListView.builder(
                  itemBuilder: (ctx, index) {
                    return CartItem(
                      id: cart.items.values.toList()[index].id,
                      productId: cart.items.keys.toList()[index],
                      title: cart.items.values.toList()[index].title,
                      quantity: cart.items.values.toList()[index].quantity,
                      price: cart.items.values.toList()[index].price,
                    );
                  },
                  itemCount: cart.items.length,
                )
              : const Text('There is no items in cart!'),
        ),
      ]),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final CartProvider cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(
                context,
                listen: false,
              ).addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              );
              setState(() {
                _isLoading = false;
              });
              widget.cart.clearCart();
            },
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text(
              'ORDER NOW',
            ),
      textColor: Theme.of(context).primaryColor,
    );
  }
}
