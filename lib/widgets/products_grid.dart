import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {

  final bool showFavs;

  const ProductsGrid({
    Key? key,
    required this.showFavs
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
        padding: const EdgeInsets.all(
          10,
        ),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemBuilder: (ctx, i) {
          return ChangeNotifierProvider.value( 
            // .value right approach should use when you use provider on someething that is part of the list or the grid
            // there is isue when create method use because recyling of widgets and atached provider
            // .value approach -> use existing provider object
            // create: (_) => products[i],
            value: products[i],
            child: ProductItem(key: ValueKey(products[i].id),),
          );
        });
  }
}
