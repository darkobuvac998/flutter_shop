import 'package:flutter/material.dart';
import 'package:my_shop/screens/orders_screen.dart';

import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/user_products_screen.dart';
import './screens/auth_screen.dart';
import './screens/edit_product_screen.dart';
import './providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders.dart';
import 'screens/cart_screen.dart';
import 'providers/auth.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          create: (ctx) => ProductsProvider([]),
          update: (ctx, auth, previousProducts) => ProductsProvider(
            previousProducts!.items,
            authToken: auth.token,
            userId: auth.userId,
          ), // provides a instance to all child widgets which are interested
          // this approcach becasue you instantiate a class, using create if you creating a new instance is recomendet
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders([]),
          update: (ctx, auth, prevOrders) => Orders(prevOrders!.orders,
              authToken: auth.token, userId: auth.userId),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen()
          },
        ),
      ),
    );
  }
}
