import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CartScreen(),
  ));
}

// Model class para sa usa ka item sa cart.
class CartItem {
  String name;
  double price;
  int quantity;
  bool gotIt;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });
}

// Stateful parent: diri gitipigan ang changing data.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Sample items nga makita pag-open sa app.
    _items.addAll([
      CartItem(
        name: 'Rice',
        price: 60.00,
        quantity: 2,
      ),
      CartItem(
        name: 'Eggs',
        price: 8.00,
        quantity: 12,
      ),
      CartItem(
        name: 'Milk',
        price: 95.00,
        quantity: 1,
      ),
    ]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _increaseQuantity(CartItem item) {
    if (item.quantity < 99) {
      setState(() {
        item.quantity++;
      });
    }
  }

  void _decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      setState(() {
        item.quantity--;
      });
    }
  }

  void _toggleGotIt(CartItem item, bool value) {
    setState(() {
      item.gotIt = value;
    });
  }

  double get _total {
    return _items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  int get _gotItCount {
    return _items.where((item) => item.gotIt).length;
  }

  void _addItem() {
    final String name = _nameController.text.trim();
    final double? price = double.tryParse(_priceController.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an item name.'),
        ),
      );
      return;
    }

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price greater than 0.'),
        ),
      );
      return;
    }

    setState(() {
      _items.add(
        CartItem(
          name: name,
          price: price,
        ),
      );

      _nameController.clear();
      _priceController.clear();
    });
  }

  void _clearChecked() {
    setState(() {
      _items.removeWhere((item) => item.gotIt);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Shopping Cart'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: _items.isEmpty
                    ? const Center(
                        child: Text(
                          'No items in the cart.',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];

                          return CartItemTile(
                            item: item,
                            onIncrease: () => _increaseQuantity(item),
                            onDecrease: () => _decreaseQuantity(item),
                            onToggle: (value) {
                              _toggleGotIt(item, value);
                            },
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              // Summary bar.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Items: ${_items.length}'),
                    Text('Got it: $_gotItCount'),
                    Text(
                      'Total: PHP ${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Add item form.
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearChecked,
                      child: const Text('Clear checked'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stateless child: makadawat lang og data ug callbacks.
// Dili kini mogamit og setState().
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<bool> onToggle;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: Row(
          children: [
            Checkbox(
              value: item.gotIt,
              onChanged: (value) {
                onToggle(value ?? false);
              },
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: item.gotIt
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  Text(
                    'PHP ${item.price.toStringAsFixed(2)} each',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: item.quantity > 1 ? onDecrease : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.teal,
            ),

            Text(
              '${item.quantity}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            IconButton(
              onPressed: item.quantity < 99 ? onIncrease : null,
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
