import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../providers/auth.dart';
import '../providers/cart_provider.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  const ProductItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    var scaffold = Scaffold.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        20,
      ),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            // slicno provider.of, uvijele listen true,
            // usefull when majority of widget tree is not a listener, then you make small part of widget to bee a listener
            builder: (ctx, item, child) => IconButton(
              // child referenca na child widget
              icon: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                // ignore: deprecated_member_use
                color: Theme.of(context).accentColor,
              ),
              onPressed: () async {
                try {
                  await item.toggleFavoriteStatus(
                    auth.token,
                    auth.userId,
                  );
                } catch (error) {
                  var tempErr = error as HttpException;
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                        tempErr.message,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
            ),
            // child: const Text(
            //   'Never changes',
            // ),
          ),
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              // ignore: deprecated_member_use
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              cart.addItem(
                product.id,
                product.price,
                product.title,
              );
              // ignore: deprecated_member_use
              Scaffold.of(context).hideCurrentSnackBar();
              // ignore: deprecated_member_use
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Added item to cart!',
                    textAlign: TextAlign.center,
                  ),
                  duration: const Duration(
                    seconds: 2,
                  ),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeItem(
                        product.id,
                      );
                    },
                  ),
                ),
              );
              // we establish connection to the nearest scaffold widget
            },
          ),
        ),
      ),
    );
  }
}
