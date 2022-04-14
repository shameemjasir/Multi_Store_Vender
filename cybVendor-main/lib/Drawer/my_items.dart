import 'package:flutter/material.dart';
import 'package:vendor/Components/drawer.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Pages/Other/adminproductpage.dart';
import 'package:vendor/Pages/Other/storeproductpage.dart';
import 'package:vendor/Routes/routes.dart';

class MyItemsPage extends StatefulWidget {
  @override
  _MyItemsPageState createState() => _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> with SingleTickerProviderStateMixin {
  TabController tabController;
  int lastIndex = -1;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      drawer: buildDrawer(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            locale.myItems.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
            ),
          ),
          centerTitle: true,
          // actions: [
          //   IconButton(
          //     icon: Icon(Icons.search),
          //     onPressed: () {},
          //   )
          // ],
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            TabBar(
              tabs: [
                Card(
                  color: Colors.grey[200],
                  elevation: 3,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Text(
                      locale.storepheading,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Card(
                  color: Colors.grey[200],
                  elevation: 3,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Text(
                      locale.adminpheading,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              ],
              isScrollable: false,
              controller: tabController,
              indicatorWeight: 1,
              indicatorColor: Colors.transparent,
              labelPadding: EdgeInsets.all(0),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  MyStoreProduct(),
                  MyAdminProduct(),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Theme.of(context).scaffoldBackgroundColor,
          size: 32,
        ),
        onPressed: () {
          setState(() {
            lastIndex = tabController.index;
            tabController.index = (lastIndex==0)?1:0;
          });
          Navigator.pushNamed(context, PageRoutes.addItem).then((value) {
            setState(() {
tabController.index = lastIndex;
            });
          }).catchError((e) {
            print(e);
          });
        },
      ),
    );
  }
}
