import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iblaze/Models/conductorOffers.dart';
import 'package:iblaze/data/globals.dart';
import 'package:iblaze/pages/Conductor/LoginAs.dart';
import 'package:iblaze/pages/Conductor/VanConductor/conductorPage.dart';

import '../../../Models/userOffers.dart';
import '../../../Widgets/search_widget.dart';
import '../../../services/conductorServices/conductorOffreAPI.dart';
import '../../../services/conductorServices/truckAPI.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  late TextEditingController PriceController;
  var Price;
  String Description = "There is no description";
  String? TruckModel;
  String? dropdownvalue;
  var indexValue = null;
  String query = "";

  List<AllOffers> offers = [];

  List<AllOffers> searchingList = [];
  List<String> ChosenTruck = [];
  List<String> ChosenTruckId = [];
  late Timer timer;

  @override
  void initState() {
    super.initState();

    PriceController = TextEditingController();
    //timer = Timer.periodic(Duration(seconds: 10), (Timer t) => init());
    init();
    initial();
    initialize();
  }

  // @override
  // void dispose() {
  //   timer.cancel();
  //   super.dispose();
  // }

  void init() async {
    offers = await APIOffreConductor.getAllOffers(
        "${currentUser?.id}", "${currentConductor?.conductorId}");

    setState(() {
      searchingList = offers;
    });
  }

  void initial() async {
    final trucks =
        await APITruckServices.getTrucksName(currentConductor?.conductorId);
    if (trucks != null) {
      setState(() {
        this.ChosenTruck = trucks;
      });
    }
  }

  void initialize() async {
    final trucks =
        await APITruckServices.getTrucksID(currentConductor?.conductorId);
    if (trucks != null) {
      setState(() {
        this.ChosenTruckId = trucks;
      });
    }
  }

  Future ShowInformationDialog(BuildContext context, int index) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: EdgeInsets.only(top: 10.0),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  width: 300.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Form(
                          key: loginFormKey,
                          child: TextFormField(
                            controller: PriceController,
                            decoration: InputDecoration(
                              icon: Icon(
                                FontAwesomeIcons.moneyCheckDollar,
                                color: Color(0xFF005b71),
                              ),
                              hintText: "Name Your Price",
                              border: InputBorder.none,
                            ),
                            maxLines: 1,
                            onChanged: (value) {
                              Price = value;
                            },
                            onSaved: (value) {
                              Price = value!;
                            },
                            validator: (value) {
                              return validatePrice(value!);
                            },
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: "Add Description",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            Description = value.trim();
                          },
                          maxLines: 8,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, right: 10.0, left: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                  color: Color(0xFF005b71), width: 2)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              isExpanded: true,
                              hint: Center(
                                child: Text(
                                  "Select Your Vehcile",
                                  style: TextStyle(
                                    color: Color(0xFF005b71),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(20),
                              value: dropdownvalue,
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: Color(0xFF005b71), size: 30),
                              items: ChosenTruck.map((
                                String items,
                              ) {
                                return DropdownMenuItem(
                                    value: items,
                                    child: Container(
                                      width: double.infinity,
                                      child: Text(
                                        items,
                                        style: TextStyle(
                                          color: Color(0xFF005b71),
                                          fontSize: 17.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ));
                              }).toList(),
                              onTap: () {},
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownvalue = newValue;
                                  TruckModel = newValue;
                                  indexValue = ChosenTruck.indexOf(newValue!);
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          child: GestureDetector(
                            onTap: () async {
                              var x = check();
                              if (Description == null || Description == "") {
                                Description = "There is no description";
                              }
                              if (x && indexValue != null) {
                                await APIOffreConductor.RegisterOffre(
                                    offers[index].getOffreId,
                                    currentConductor?.conductorId,
                                    ChosenTruckId[indexValue],
                                    Price,
                                    Description);
                                if (ConductorRegisteringOffre) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            VanConductor(index: 1)),
                                    (Route<dynamic> route) => false,
                                  );
                                  Fluttertoast.showToast(
                                      msg:
                                          "Your proposition has been submitted successfully",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 20.0);
                                }
                              } else if (x && !ConductorRegisteringOffre) {
                                Get.defaultDialog(
                                    title: "Error",
                                    titleStyle: TextStyle(
                                        fontSize: 30,
                                        color: Color(0xFFE40613),
                                        fontWeight: FontWeight.bold),
                                    middleText:
                                        "Your proposition can't be submitted !",
                                    middleTextStyle: TextStyle(
                                        color: Color(0xFF005b71),
                                        fontSize: 20));
                              }
                            },
                          child: Container(
                            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            decoration: BoxDecoration(
                                color: Color(0xFF005b71),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32.0))),
                            
                              child: Text(
                                "Sumbit",
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }));
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => LoginAs());
        return true;
      },
      child: RefreshIndicator(
        color: Color(0xFF005b71),
        onRefresh: () async {
          initialize();
          initial();
          init();
          // setState(() {
          //   searchingList = offers;
          // });
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(62, 0, 90, 113),
                    Color.fromARGB(62, 255, 255, 255),
                  ]),
            ),
            child: Column(
              children: [
                buildSearch(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ListView.builder(
                        itemCount: searchingList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 30.0, right: 30),
                            child: Container(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: ExpansionTile(
                                  title: new RichText(
                                      text: new TextSpan(
                                    children: <TextSpan>[
                                      // new TextSpan(
                                      //     style: new TextStyle(
                                      //       color: Colors.black,
                                      //     ),
                                      //     text: 'From '),
                                      new TextSpan(
                                          text: searchingList[index].getDepart,
                                          style: GoogleFonts.roboto(
                                            fontSize: 18,
                                            color: Color(0xFF005b71),
                                            //fontWeight: FontWeight.bold
                                          )),
                                      new TextSpan(
                                          style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          text: '    To     '),
                                      new TextSpan(
                                          text: searchingList[index].getArrivee,
                                          style: GoogleFonts.roboto(
                                            fontSize: 18,
                                            color: Color(0xFF005b71),
                                            //fontWeight: FontWeight.bold
                                          )),
                                    ],
                                  )),
                                  children: [
                                    Container(
                                      // height: 20,
                                      child: ListTile(
                                        title: Text("Departure Location : " +
                                            searchingList[index].getDepart),
                                      ),
                                    ),
                                    Container(
                                      // height: 20,
                                      child: ListTile(
                                        title: Text("Arrival Location : " +
                                            searchingList[index].getArrivee),
                                      ),
                                    ),
                                    Container(
                                      //  height: 20,
                                      child: ListTile(
                                        title: Text("Freight Type : " +
                                            searchingList[index]
                                                .getFreightType),
                                      ),
                                    ),
                                    Container(
                                      //  height: 20,
                                      child: ListTile(
                                        title: Text("Client description : " +
                                            searchingList[index]
                                                .getUserDescription),
                                      ),
                                    ),
                                    Container(
                                      //  height: 20,
                                      child: ListTile(
                                        title: Text("Quantity : " +
                                            searchingList[index].getQuantity),
                                      ),
                                    ),
                                    Container(
                                      // height: 20,
                                      child: ListTile(
                                        title: Text("delivery time : " +
                                            "${searchingList[index].getDeliveryTime}"),
                                      ),
                                    ),
                                    Container(
                                      // height: 20,
                                      child: ListTile(
                                        title: Text(
                                            searchingList[index].getResponse),
                                      ),
                                    ),
                                    Container(
                                      child: ListTile(
                                        title: Text("Client Name : "
                                            "${searchingList[index].getUsername}"),
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () async {
                                        await ShowInformationDialog(
                                            context, index);
                                        // Get.to(() => updateOffre(index: index));
                                        // print(index);
                                      },
                                      title: Text("Take this offer",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 33, 125, 56),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      trailing: Icon(
                                        FontAwesomeIcons.handPointUp,
                                        color: Color.fromARGB(255, 33, 125, 56),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool check() {
    final isValid = loginFormKey.currentState!.validate();
    if (!isValid) {
      return false;
    } else {
      loginFormKey.currentState!.save();
      return true;
    }
  }

  String? validatePrice(String value) {
    if (value == null || value.isEmpty) {
      return "This Field can't be empty";
    }

    return null;
  }

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Search by Location',
        onChanged: searchOffre,
      );
  void searchOffre(String query) async {
    searchingList = await offers.where((offers) {
      final depart = offers.getDepart.toLowerCase();
      final arrive = offers.getArrivee.toLowerCase();
      final search = query.toLowerCase().trim();

      return depart.contains(search) || arrive.contains(search);
    }).toList();

    setState(() {
      //init();
      //this.query = query;
      // this.offers = searchingList;
    });
  }
}
