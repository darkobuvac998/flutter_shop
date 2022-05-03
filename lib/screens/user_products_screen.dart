import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import '../screens/edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  const UserProductsScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext ctx) async {
    Provider.of<ProductsProvider>(ctx, listen: false).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<ProductsProvider>(context);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                EditProductScreen.routeName,
                arguments: '',
              );
            },
            icon: const Icon(
              Icons.add,
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Waiting...',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refreshProducts(context),
            child: Consumer<ProductsProvider>(
              builder: (ctx, productsData, _) => Padding(
                padding: const EdgeInsets.all(
                  8,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (_, index) => Column(
                    children: [
                      UserProductItem(
                        id: productsData.items[index].id,
                        title: productsData.items[index].title,
                        imageUrl: productsData.items[index].imageUrl,
                      ),
                      const Divider(
                        height: 5,
                        thickness: 1.2,
                      ),
                    ],
                  ),
                  itemCount: productsData.items.length,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
