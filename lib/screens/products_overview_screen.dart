import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/cart_screen.dart';
import '../providers/cart_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/products_provider.dart';

enum FilterOptions { favorites, all }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of<ProductsProvider>(context).fetchAndSetProducts(); // WON'T WORK! of(context) things doesn't work in initState becase not all things for widget are wired up
    // Future.delayed(Duration.zero).then(
    //     (_) => Provider.of<ProductsProvider>(context).fetchAndSetProducts());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productsContainer =
    //     Provider.of<ProductsProvider>(context, listen: false);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'MyShop',
        ),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favorites) {
                  // productsContainer.showFavoriteOnly();
                  _showOnlyFavorites = true;
                } else {
                  // productsContainer.showAll();
                  _showOnlyFavorites = false;
                }
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text(
                  'Only Favorites',
                ),
                value: FilterOptions.favorites,
              ),
              const PopupMenuItem(
                child: Text(
                  'Show All',
                ),
                value: FilterOptions.all,
              ),
            ],
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
          Consumer<CartProvider>(
            builder: (_, value, ch) => Badge(
              child: ch as Widget,
              value: value.itemCount.toString(),
            ),
            child: IconButton(
              //doesn't rebuild when cart changes
              icon: const Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  CartScreen.routeName,
                );
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(showFavs: _showOnlyFavorites),
    );
  }
}
