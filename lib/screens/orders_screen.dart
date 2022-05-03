import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndStoreOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context).orders;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'Your orders',
        ),
      ),
      body: FutureBuilder(
        // recomended approach
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (dataSnapshot.error != null || dataSnapshot.hasError) {
            return const Center(
              child: Text('An error occurred!'),
            );
          } else {
            return Consumer<Orders>(
              builder: (ctx, orderData, _) => ListView.builder(
                itemBuilder: (ctx, index) {
                  return OrderItem(
                    order: orderData.orders[index],
                  );
                },
                itemCount: orderData.orders.length,
              ),
            );
          }
        },
      ),
    );
  }
}



  // insted of Future.delayed we can use listen: false, it will work, it's like a hack

  // Future.delayed(Duration.zero).then((_) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   await Provider.of<Orders>(context, listen: false).fetchAndStoreOrders();
  //   setState(() {
  //     _isLoading = false;
  //   });
  // });
  // super.initState();
