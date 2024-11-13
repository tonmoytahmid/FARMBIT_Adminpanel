import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: use_key_in_widget_constructors
class UploadProduct extends StatefulWidget {
  @override
  _UploadProductState createState() => _UploadProductState();
}

class _UploadProductState extends State<UploadProduct> {
  String? selectedCategory;
  final List<String> categories = [
    'SAAS',
    'Service Based',
    'Client Acquisition',
    'Simple Business Ideas',
    'E-Com',
    'Digital Product'
  ];

  final TextEditingController _pagrurlController = TextEditingController();
  final TextEditingController _imageurlController = TextEditingController();

  // Function to pick an image (mobile & web compatible)

  Future<void> _saveToFirestore() async {
    if (selectedCategory != null) {
      EasyLoading.show(status: 'Please wait');
      await FirebaseFirestore.instance.collection('product_name').add({
        'category': selectedCategory,
        'pageurl_link': _pagrurlController.text,
        'imageurl_link': _imageurlController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully!')),
      );

      setState(() {
        selectedCategory = null;
        _pagrurlController.clear();
        _imageurlController.clear();
      });
      EasyLoading.dismiss();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image and a category.')),
      );
    }

    print(' Category: $selectedCategory'); // Print saved values
  }

  // Function to delete a product from Firestore and its image from Storage
  Future<void> _deleteProduct(String docId) async {
    try {
      EasyLoading.show(status: 'Please wait');

      await FirebaseFirestore.instance
          .collection('product_name')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete the product.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Product'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;

          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: isMobile ? double.infinity : 600,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCategory,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _imageurlController,
                      decoration: const InputDecoration(
                        labelText: 'ImageURL link',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _pagrurlController,
                      decoration: const InputDecoration(
                        labelText: 'PageURL link',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveToFirestore,
                      child: const Text('Post Now'),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const Text(
                      'Uploaded Products',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('product_name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text('Error fetching products');
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No products available');
                        }
                        return ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return ListTile(
                              leading: data['imageurl_link'] != null &&
                                      data['imageurl_link'].isNotEmpty
                                  ? Image.network(
                                      data['imageurl_link'],
                                      height: 50,
                                      width: 50,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.broken_image,
                                            size:
                                                50); // Placeholder for invalid URLs
                                      },
                                    )
                                  : Container(
                                      height: 50,
                                      width: 50,
                                      color: Colors.grey,
                                    ),
                              title: Text(data['category'] ?? 'No Category'),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteProduct(
                                    doc.id,
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const Divider(),
                    const Text(
                      'User List',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // StreamBuilder to display user list
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text('Error fetching users');
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No users available');
                        }
                        return ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(data['profile_image'] ?? ''),
                              ),
                              title: Text(data['Name'] ?? 'No Name'),
                              subtitle: Text(data['Email'] ?? 'No Email'),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
