import 'package:finalproject/models/auth.dart';
import 'package:finalproject/providers/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/product_details_screen.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: product.id,
            );
          },
          child: FadeInImage(
            placeholder: AssetImage('assets/images/dealPlaceHolder.jpg'),
            image: NetworkImage(product.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              product.dealPrice.toString() + ' NIS',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'muli',
                backgroundColor: Colors.black,
              ),
            ),
            Text(
              product.originalPrice.toString() + ' NIS',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.lineThrough,
                fontFamily: 'muli',
                backgroundColor: Colors.black54,
              ),
            ),
          ],
        ),
        footer: GridTileBar(
          leading: IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              product.toggleFavoriteStatus(authData.token, authData.userId);
            },
            color: Theme.of(context).accentColor,
          ),
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              if (product.creatorId != authData.userId) {
                cart.addItem(product.id, product.dealPrice, product.title,
                    product.creatorId);
                // ignore: deprecated_member_use
                Scaffold.of(context).hideCurrentSnackBar();
                // ignore: deprecated_member_use
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Item added to cart'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        cart.removeItem(product.id);
                      },
                    ),
                  ),
                );
              } else {
                Widget okButton = FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                );
                AlertDialog alert = AlertDialog(
                  title: Text("Error"),
                  content: Text("You cannot add your own product to the cart."),
                  actions: [
                    okButton,
                  ],
                );
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              }
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
