import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart' show CartProvider;

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  const CartItem(
      {Key? key,
      required this.id,
      required this.productId,
      required this.price,
      required this.quantity,
      required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 20,
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('No'),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                )
              ],
              title: const Text(
                'Are you sure?',
              ),
              content: const Text(
                'Dou you want to remove item from the cart?',
              ),
            );
          },
        );
      },
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<CartProvider>(context, listen: false).removeItem(productId);
      },
      background: Container(
        color: Theme.of(context).errorColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(
              height: 4.0,
            ),
            Text(
              'REMOVE',
              style: TextStyle(
                color: Theme.of(context).primaryTextTheme.headline6?.color,
              ),
            )
          ],
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 20,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      child: Card(
        elevation: 6.0,
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            8,
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 40,
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '\$$price',
                  ),
                ),
              ),
            ),
            title: Text(
              title,
            ),
            subtitle: Text(
              'Total \$${{quantity * price}}',
            ),
            trailing: Text(
              '$quantity x',
            ),
          ),
        ),
      ),
    );
  }
}
