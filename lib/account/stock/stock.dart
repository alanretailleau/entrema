import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entrema/account/produit/produit.dart';
import 'package:entrema/classes/adherent.dart';
import 'package:entrema/classes/categorie.dart';
import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/consommationCategorie.dart';
import 'package:entrema/classes/consommationProduit.dart';
import 'package:entrema/classes/product.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/color.dart';
import 'package:entrema/functions/function.dart';
import 'package:entrema/home/home.dart';
import 'package:entrema/home/scan/scanPage.dart';
import 'package:entrema/widget/FieldText.dart';
import 'package:entrema/widget/Loader.dart';
import 'package:entrema/widget/appbar.dart';
import 'package:entrema/widget/bottom_bar.dart';
import 'package:entrema/widget/box.dart';
import 'package:entrema/widget/boxBox.dart';
import 'package:entrema/widget/button.dart';
import 'package:entrema/widget/pdp.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import '../../widget/FieldText2.dart';

class StockPage extends StatefulWidget {
  const StockPage(
      {super.key,
      required this.user,
      required this.commerce,
      this.choice = false});
  final Commerce commerce;
  final User user;
  final bool choice;
  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<Map> settings = [];
  List<bool> expanded = [];

  @override
  void initState() {
    for (var i = 0; i < 1000; i++) {
      expanded.add(false);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).primaryColor,
        child: Scaffold(
            backgroundColor: Colors.blueGrey.withOpacity(0.1),
            body: SizedBox.expand(
              child: Stack(
                children: [
                  SafeArea(
                      child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          const CustomAppBar(
                            title: "Stocks",
                          ),
                          !widget.choice ? Parametres() : Container(),
                          ListeCategories(),
                          const SizedBox(height: 100),
                        ]),
                  )),
                  Positioned(
                      bottom: 0,
                      child: BottomBar(
                        index: 1,
                        user: widget.user,
                        onPressed: (v) {
                          pushPage(context, Home(user: widget.user, index: v));
                        },
                      ))
                ],
              ),
            )));
  }

  void Settings() {}

  Widget Parametres() {
    List<Map> settingsItem = [
      {"nom": "Exporter les données", "icon": "retrait", "onPressed": () {}},
      {
        "nom": "Lancer une simulation",
        "icon": "idea",
        "onPressed": () async {
          if (await editDialog(context, "Annuler", "Lancer la simulation",
              "Attention !\nLa simulation va réinitialiser toutes les données de stocks existantes.")) {
            print("Lancement de la simulation");
            int pourcentConsommationJournaliere = 3;
            int pourcentCommande = 10;
            DateTime dateDebut = DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day)
                .subtract(const Duration(days: 11));
            DateTime dateFin = dateDebut.add(const Duration(days: 10));
            List<Categorie> categories =
                await Categorie.getCategoriesByCommerce(widget.commerce.id);
            List<Map<String, dynamic>> data = [];
            for (var i = 0; i < categories.length; i++) {
              data.add({
                "categorie": categories[i],
                "products":
                    await Product.getProductsByCategorie(categories[i].id)
              });
            }
            List<Adherent> adherents =
                await Adherent.getAdherentsByCommerce(widget.commerce.id);

            List<Map> consommation = [];

            //Lancement de la simulation
            //On reset les anciennes données
            List<ConsommationProduct> consommationProd =
                await ConsommationProduct.getConsoProductByCommerce(
                    widget.commerce.id);
            List<ConsommationCategorie> consommationCategorie =
                await ConsommationCategorie.getConsoCategorieByCommerce(
                    widget.commerce.id);
            for (var i = 0; i < consommationProd.length; i++) {
              consommationProd[i].delete();
            }
            for (var i = 0; i < consommationCategorie.length; i++) {
              consommationCategorie[i].delete();
            }
            sleep(const Duration(seconds: 5));
            print("Reset terminé");

            //Initialisation des stocks
            for (var i = 0; i < data.length; i++) {
              for (var j = 0; j < data[i]["products"].length; j++) {
                consommation.add({
                  "quantite": (200 + Random().nextInt(300)).toDouble(),
                  "id": data[i]["products"][j].id
                });
                ConsommationProductService.addOrUpdateConsommationProduct(
                  widget.commerce,
                  data[i]["categorie"],
                  data[i]["products"][j],
                  dateDebut,
                  ConsoProd(
                      id: FirebaseFirestore.instance
                          .collection("consoProds")
                          .doc()
                          .id,
                      livraison: true,
                      date: dateDebut,
                      idAdherent:
                          adherents[Random().nextInt(adherents.length)].id,
                      quantite: consommation.last["quantite"]),
                );
              }
            }
            sleep(const Duration(seconds: 3));
            print("Initialisation terminé");

            //Création de la consommation virtuelle
            int counter = 0;
            for (var i = 0; i < data.length; i++) {
              for (var j = 0; j < data[i]["products"].length; j++) {
                for (var d = 0;
                    d < dateFin.difference(dateDebut).inDays.abs();
                    d++) {
                  if (Random().nextInt(3) != 1) {
                    for (var h = 0; h < 24; h++) {
                      if (Random().nextInt(6) == 2) {
                        await ConsommationProductService.addOrUpdateConsommationProduct(
                            widget.commerce,
                            data[i]["categorie"],
                            data[i]["products"][j],
                            dateDebut.add(Duration(days: d, hours: h)),
                            ConsoProd(
                                id: FirebaseFirestore.instance
                                    .collection("consoProds")
                                    .doc()
                                    .id,
                                livraison: false,
                                date:
                                    dateDebut.add(Duration(days: d, hours: h)),
                                idAdherent: adherents[
                                        Random().nextInt(adherents.length)]
                                    .id,
                                quantite: (consommation.firstWhere((element) =>
                                            element["id"] ==
                                            data[i]["products"][j]
                                                .id)["quantite"] *
                                        (1 +
                                            Random().nextInt(
                                                pourcentConsommationJournaliere -
                                                    1)) /
                                        100)
                                    .toDouble()));
                        print("again");
                      }
                    }
                  }
                }
              }
            }
            print("finish");
          } else {
            print("nop");
          }
        }
      },
    ];
    Widget body = SizedBox(
        width: double.infinity,
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: settingsItem.length,
            itemBuilder: (context, index) {
              return CustomButton(
                padding: const EdgeInsets.all(10),
                onPressed: settingsItem[index]["onPressed"],
                shape: StadiumBorder(
                    side: BorderSide(color: black(context).withOpacity(.1))),
                child: Row(children: [
                  Image.asset("assets/icon/${settingsItem[index]["icon"]}.png",
                      color: black(context), scale: 10),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(settingsItem[index]["nom"],
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700))
                ]),
              );
            }));
    return Box(
        const Text("Paramètres",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        body,
        null,
        context);
  }

  Widget ListeCategories() {
    Widget body = StreamBuilder<List<Categorie>>(
        stream: Categorie.streamCategories(widget.commerce.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Aucune catégorie trouvée",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ExpansionPanelList(
              elevation: 0,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  expanded[index] = isExpanded;
                });
              },
              children:
                  snapshot.data!.map<ExpansionPanel>((Categorie categorie) {
                return ExpansionPanel(
                  backgroundColor: white(context),
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Row(
                      children: [
                        CustomButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          color: categorie.couleur.withOpacity(.1),
                          shape: const StadiumBorder(),
                          onPressed: () {
                            pushPage(
                                context,
                                StockPageCategorie(
                                    user: widget.user,
                                    commerce: widget.commerce,
                                    categorie: categorie));
                          },
                          child: Row(
                            children: [
                              Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                    color: categorie.couleur,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              const SizedBox(width: 10),
                              Text(categorie.nom)
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  body: StreamBuilder(
                      stream: Product.streamProducts(categorie.id),
                      builder: (context, snapshot2) {
                        if (snapshot2.hasData) {
                          return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: snapshot2.data!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                Product produit = snapshot2.data![index];
                                return CustomButton(
                                  padding: const EdgeInsets.all(5),
                                  color: lighten(
                                      produit.couleur.withOpacity(.05), 0.3),
                                  onPressed: () {
                                    pushPage(
                                        context,
                                        StockPageProduct(
                                            user: widget.user,
                                            commerce: widget.commerce,
                                            produit: produit));
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                  child: Row(
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: produit.couleur
                                                      .withOpacity(.5))),
                                          height: 30,
                                          width: 30,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(produit.url,
                                                  fit: BoxFit.cover))),
                                      const SizedBox(width: 10),
                                      Text(produit.nom)
                                    ],
                                  ),
                                );
                              });
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Loader(
                                color: black(context),
                              ),
                            ),
                          );
                        }
                      }),
                  isExpanded: expanded[snapshot.data!
                      .lastIndexWhere((element) => element.id == categorie.id)],
                );
              }).toList(),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Loader(
                  color: black(context),
                ),
              ),
            );
          }
        });
    return BoxBox(body, context);
  }
}

class StockPageProduct extends StatefulWidget {
  const StockPageProduct(
      {super.key,
      required this.user,
      required this.commerce,
      required this.produit});
  final Commerce commerce;
  final User user;
  final Product produit;
  @override
  State<StockPageProduct> createState() => _StockPageProductState();
}

class _StockPageProductState extends State<StockPageProduct> {
  List<Map> settings = [];
  bool showAvg = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).primaryColor,
        child: Scaffold(
            backgroundColor: Colors.blueGrey.withOpacity(0.1),
            body: SizedBox.expand(
              child: SafeArea(
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: StreamBuilder<List<ConsommationProduct>>(
                          stream:
                              ConsommationProduct.streamConsommationProducts(
                                  widget.produit.id,
                                  DateTime.now()
                                      .subtract(const Duration(days: 31)),
                                  DateTime.now().add(const Duration(days: 31))),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            List<ConsommationProduct> consommation =
                                snapshot.data!;
                            if (consommation.length >= 2) {
                              for (var i = consommation.length - 1;
                                  i < 0;
                                  i--) {
                                consommation[i - 1].date = consommation[i].date;
                              }
                              consommation.removeAt(0);

                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 30),
                                    CustomAppBar(
                                      title: "Stock de ${widget.produit.nom}",
                                    ),
                                    evolutionStock(consommation),
                                    const SizedBox(height: 10),
                                    quantite(snapshot.data!),
                                    const SizedBox(height: 10),
                                    evolutionJournaliere(snapshot.data!),
                                  ]);
                            } else {
                              return Column(
                                children: [
                                  const SizedBox(height: 30),
                                  CustomAppBar(
                                    title: "Stock de ${widget.produit.nom}",
                                  ),
                                  const SizedBox(height: 30),
                                  const Center(
                                      child: Text(
                                          "Pas assez de données de consommation")),
                                ],
                              );
                            }
                          }))),
            )));
  }

  void Settings() {}

  Widget evolutionStock(List<ConsommationProduct> consommation) {
    List<Color> gradientColors = [
      widget.produit.couleur,
      Theme.of(context).brightness == Brightness.dark
          ? darken(widget.produit.couleur, 0.3)
          : lighten(widget.produit.couleur, 0.3),
    ];
    Widget bottomTitleWidgets(DateTime start, double value, TitleMeta meta) {
      const style = TextStyle(
        fontSize: 12,
      );

      return SideTitleWidget(
        angle: -pi / 4,
        axisSide: meta.axisSide,
        child: Text(
          DateFormat("dd/MM").format(start.add(Duration(days: value.toInt()))),
          style: style,
        ),
      );
    }

    Widget leftTitleWidgets(double value, TitleMeta meta) {
      const style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      );
      String text;
      switch (value.toInt()) {
        case 1:
          text = '10K';
          break;
        case 6951:
          text = 'lol';
          break;
        case 5:
          text = '50k';
          break;
        default:
          return Container();
      }

      return Text(text, style: style, textAlign: TextAlign.left);
    }

    LineChartData mainData(List<ConsommationProduct> data) {
      return LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 6.0,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: 2,
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (a, b) {
                return bottomTitleWidgets(data.first.date, a, b);
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 45),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: widget.produit.couleur.withOpacity(.2)),
        ),
        minX: 0,
        maxX: data.last.date.difference(data.first.date).inDays.toDouble(),
        minY: 0,
        maxY: (data.map((e) => e.quantite.toDouble()).toList()).reduce(max),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 10,
            maxContentWidth: 100,
            tooltipBgColor: white(context),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: black(context),
                  fontSize: 14,
                );
                return LineTooltipItem(
                  touchedSpot.y.round().toString(),
                  textStyle,
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchLineStart: (data, index) => 0,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .map((e) => FlSpot(
                    e.date.difference(data.first.date).inDays.abs().toDouble(),
                    e.quantite.toDouble()))
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: gradientColors,
            ),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              getDotPainter: (p0, p1, p2, p3) {
                return FlDotCirclePainter(
                    color: widget.produit.couleur,
                    strokeColor: widget.produit.couleur.withOpacity(.3),
                    strokeWidth: 2);
              },
              show: true,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
              ),
            ),
          ),
        ],
      );
    }

    LineChartData avgData(List<ConsommationProduct> data) {
      double average =
          (data.map((e) => e.quantite).reduce((a, b) => a + b) / data.length)
              .toDouble();
      return LineChartData(
        lineTouchData: const LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (a, b) {
                return bottomTitleWidgets(data.first.date, a, b);
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: widget.produit.couleur.withOpacity(.2)),
        ),
        minX: 0,
        maxX: data.last.date.difference(data.first.date).inDays.toDouble(),
        minY: 0,
        maxY: (data.map((e) => e.quantite.toDouble()).toList()).reduce(max),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .map((e) => FlSpot(
                    e.date.difference(data.first.date).inDays.abs().toDouble(),
                    average))
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!,
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!,
              ],
            ),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  ColorTween(begin: gradientColors[0], end: gradientColors[1])
                      .lerp(0.2)!
                      .withOpacity(0.1),
                  ColorTween(begin: gradientColors[0], end: gradientColors[1])
                      .lerp(0.2)!
                      .withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget body = Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData(consommation) : mainData(consommation),
            ),
          ),
        ),
        SizedBox(
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'moyenne',
              style: TextStyle(
                fontSize: 12,
                color:
                    showAvg ? black(context).withOpacity(0.5) : black(context),
              ),
            ),
          ),
        ),
      ],
    );

    return Box(
        Text("Évolution du stock (en ${widget.produit.unite})",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        body,
        null,
        context);
  }

  Widget quantite(List<ConsommationProduct> consommation) {
    List<Color> gradientColors = [
      widget.produit.couleur,
      Theme.of(context).brightness == Brightness.dark
          ? darken(widget.produit.couleur, 0.3)
          : lighten(widget.produit.couleur, 0.3),
    ];
    Widget bottomTitleWidgets(DateTime start, double value, TitleMeta meta) {
      const style = TextStyle(
        fontSize: 12,
      );

      return SideTitleWidget(
        angle: -pi / 4,
        axisSide: meta.axisSide,
        child: Text(
          DateFormat("dd/MM").format(consommation[value.round()].date),
          style: style,
        ),
      );
    }

    Widget leftTitleWidgets(double value, TitleMeta meta) {
      const style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      );
      String text = "salut";
      switch (value.toInt()) {
        case 1:
          text = '10K';
          break;
        case 1265:
          text = 'lol';
          break;
        case 5:
          text = '50k';
          break;
        default:
          return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(text, style: style, textAlign: TextAlign.left));
      }

      return SideTitleWidget(
          angle: 90,
          axisSide: meta.axisSide,
          child: Text(text, style: style, textAlign: TextAlign.left));
    }

    LineChartData mainData(List<ConsommationProduct> data) {
      return LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 6.0,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (a, b) {
                return bottomTitleWidgets(data.first.date, a, b);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: leftTitleWidgets),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: widget.produit.couleur.withOpacity(.2)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 10,
            maxContentWidth: 100,
            tooltipBgColor: white(context),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: black(context),
                  fontSize: 14,
                );
                return LineTooltipItem(
                  touchedSpot.y.round().toString(),
                  textStyle,
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchLineStart: (data, index) => 0,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .map((e) => FlSpot(
                    e.date.difference(data.first.date).inDays.abs().toDouble(),
                    e.quantite.toDouble()))
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: gradientColors,
            ),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              getDotPainter: (p0, p1, p2, p3) {
                return FlDotCirclePainter(
                    color: widget.produit.couleur,
                    strokeColor: widget.produit.couleur.withOpacity(.3),
                    strokeWidth: 2);
              },
              show: true,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
              ),
            ),
          ),
        ],
      );
    }

    BarChartGroupData makeGroupData(
      int x,
      double y, {
      bool isTouched = false,
      Color? barColor,
      double width = 10,
      List<int> showTooltips = const [],
    }) {
      barColor ??= black(context).withOpacity(.1);
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y + 1,
            color: widget.produit.couleur,
            width: width,
            borderSide: BorderSide(
                color: widget.produit.couleur.withOpacity(.3), width: 3),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 20,
              color: widget.produit.couleur.withOpacity(.1),
            ),
          ),
        ],
        showingTooltipIndicators: showTooltips,
      );
    }

    List<BarChartGroupData> showingGroups() {
      List<BarChartGroupData> data = consommation
          .map((e) => makeGroupData(
              consommation.indexOf(e),
              consommation.indexOf(e) != 0
                  ? (consommation[consommation.indexOf(e) - 1].quantite -
                          e.quantite)
                      .toDouble()
                  : 0.toDouble(),
              isTouched: false))
          .toList();
      data.removeAt(0);
      return data;
    }

    BarChartData mainBarData() {
      return BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: white(context),
            tooltipHorizontalAlignment: FLHorizontalAlignment.right,
            tooltipMargin: -10,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                "Le ${DateFormat("dd MMM").format(consommation[group.x].date)}\n",
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "${(rod.toY - 1).round()}${widget.produit.unite}",
                    style: TextStyle(
                      color: black(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: (a, b) {
                return bottomTitleWidgets(consommation.first.date, a, b);
              },
              showTitles: true,
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: showingGroups(),
        gridData: const FlGridData(show: false),
      );
    }

    Widget body = AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: BarChart(
          mainBarData(),
        ),
      ),
    );

    return Box(
        Text("Quantité consommée (en ${widget.produit.unite})",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        body,
        null,
        context);
  }

  int daysIndex = 0;

  Widget evolutionJournaliere(List<ConsommationProduct> consommation) {
    List<Color> gradientColors = [
      widget.produit.couleur,
      Theme.of(context).brightness == Brightness.dark
          ? darken(widget.produit.couleur, 0.3)
          : lighten(widget.produit.couleur, 0.3),
    ];
    Widget bottomTitleWidgets(DateTime start, double value, TitleMeta meta) {
      const style = TextStyle(
        fontSize: 12,
      );

      return SideTitleWidget(
        angle: -pi / 4,
        axisSide: meta.axisSide,
        child: Text(
          DateFormat("HH:mm")
              .format(start.add(Duration(minutes: value.toInt()))),
          style: style,
        ),
      );
    }

    LineChartData mainData(
        List<ConsoProd> data, List<ConsommationProduct> conso) {
      for (var i = 0; i < data.length; i++) {
        if (i == 0) {
          data[i].quantite += conso[daysIndex].quantite;
        } else {
          data[i].quantite = data[i - 1].quantite +
              data[i].quantite * (data[i].livraison ? 1 : (-1));
        }
      }
      return LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (a, b) {
                return bottomTitleWidgets(data.first.date, a, b);
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 45),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: widget.produit.couleur.withOpacity(.2)),
        ),
        minX: 0,
        maxX: data.last.date.difference(data.first.date).inMinutes.toDouble(),
        minY: (data.map((e) => e.quantite.toDouble()).toList()).reduce(min),
        maxY: (data.map((e) => e.quantite.toDouble()).toList()).reduce(max),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 10,
            maxContentWidth: 100,
            tooltipBgColor: white(context),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: black(context),
                  fontSize: 14,
                );
                return LineTooltipItem(
                  touchedSpot.y.round().toString(),
                  textStyle,
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchLineStart: (data, index) => 0,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .map((e) => FlSpot(
                    e.date
                        .difference(data.first.date)
                        .inMinutes
                        .abs()
                        .toDouble(),
                    e.quantite))
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: gradientColors,
            ),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              getDotPainter: (p0, p1, p2, p3) {
                return FlDotCirclePainter(
                    color: widget.produit.couleur,
                    strokeColor: widget.produit.couleur.withOpacity(.3),
                    strokeWidth: 2);
              },
              show: true,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
              ),
            ),
          ),
        ],
      );
    }

    LineChartData avgData(
        List<ConsoProd> data, List<ConsommationProduct> conso) {
      for (var i = 0; i < data.length; i++) {
        if (i == 0) {
          data[i].quantite += conso[daysIndex].quantite;
        } else {
          data[i].quantite = data[i - 1].quantite +
              data[i].quantite * (data[i].livraison ? 1 : (-1));
        }
      }
      double average =
          (data.map((e) => e.quantite).reduce((a, b) => a + b) / data.length)
              .toDouble();
      return LineChartData(
        lineTouchData: const LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (a, b) {
                return bottomTitleWidgets(data.first.date, a, b);
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: widget.produit.couleur.withOpacity(.2)),
        ),
        minX: 0,
        maxX: data.last.date.difference(data.first.date).inMinutes.toDouble(),
        minY: (data.map((e) => e.quantite.toDouble()).toList()).reduce(min),
        maxY: (data.map((e) => e.quantite.toDouble()).toList()).reduce(max),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .map((e) => FlSpot(
                    e.date
                        .difference(data.first.date)
                        .inMinutes
                        .abs()
                        .toDouble(),
                    average))
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!,
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!,
              ],
            ),
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  ColorTween(begin: gradientColors[0], end: gradientColors[1])
                      .lerp(0.2)!
                      .withOpacity(0.1),
                  ColorTween(begin: gradientColors[0], end: gradientColors[1])
                      .lerp(0.2)!
                      .withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget body = Column(
      children: [
        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    height: 40,
                    width: 40,
                    child: CustomButton(
                        color: black(context).withOpacity(.1),
                        shape: const StadiumBorder(),
                        onPressed: daysIndex > 1
                            ? () {
                                setState(() {
                                  daysIndex--;
                                });
                              }
                            : null,
                        child: Image.asset("assets/icon/back.png",
                            color: black(context), scale: 10))),
                consommation.length > daysIndex
                    ? Text(DateFormat("EEE dd/MM/yyyy")
                        .format(consommation[daysIndex].date))
                    : Container(),
                SizedBox(
                    height: 40,
                    width: 40,
                    child: CustomButton(
                      color: black(context).withOpacity(.1),
                      shape: const StadiumBorder(),
                      onPressed: daysIndex < consommation.length - 1
                          ? () {
                              setState(() {
                                daysIndex++;
                              });
                            }
                          : null,
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: Image.asset("assets/icon/back.png",
                            color: black(context), scale: 10),
                      ),
                    ))
              ],
            )),
        Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                  padding: const EdgeInsets.only(
                    right: 18,
                    left: 12,
                    top: 24,
                    bottom: 12,
                  ),
                  child: consommation.length > daysIndex
                      ? StreamBuilder<List<ConsoProd>>(
                          stream: ConsoProd.streamMultipleConsommationProds(
                              consommation[daysIndex].consommation),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                  child: Loader(color: black(context)));
                            }
                            List<ConsoProd> consoProd = snapshot.data!;
                            consoProd.sort((a, b) => a.date.compareTo(b.date));
                            return LineChart(
                              showAvg
                                  ? avgData(consoProd, consommation)
                                  : mainData(consoProd, consommation),
                            );
                          })
                      : Container()),
            ),
            SizedBox(
              height: 34,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showAvg = !showAvg;
                  });
                },
                child: Text(
                  'moyenne',
                  style: TextStyle(
                    fontSize: 12,
                    color: showAvg
                        ? black(context).withOpacity(0.5)
                        : black(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Box(
        Text("Évolution journalière (en ${widget.produit.unite})",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        body,
        null,
        context);
  }
}

class StockPageCategorie extends StatefulWidget {
  const StockPageCategorie(
      {super.key,
      required this.user,
      required this.commerce,
      required this.categorie});
  final Commerce commerce;
  final User user;
  final Categorie categorie;
  @override
  State<StockPageCategorie> createState() => _StockPageCategorieState();
}

class _StockPageCategorieState extends State<StockPageCategorie> {
  List<Map> settings = [];
  bool showAvg = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Theme.of(context).primaryColor,
        child: Scaffold(
            backgroundColor: Colors.blueGrey.withOpacity(0.1),
            body: SizedBox.expand(
              child: SafeArea(
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: StreamBuilder<List<Product>>(
                          stream: Product.streamProducts(widget.categorie.id),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            List<String> prodIds =
                                snapshot.data!.map((e) => e.id).toList();

                            return StreamBuilder<
                                    List<List<ConsommationProduct>>>(
                                stream: ConsommationProduct
                                    .streamMultipleConsommationProducts(
                                        prodIds,
                                        DateTime.now()
                                            .subtract(const Duration(days: 31)),
                                        DateTime.now()
                                            .add(const Duration(days: 31))),
                                builder: (context, snapshot2) {
                                  if (!snapshot2.hasData) {
                                    return Center(
                                        child: Loader(color: black(context)));
                                  }
                                  List<List<ConsommationProduct>> consommation =
                                      snapshot2.data!;
                                  for (var i = 0;
                                      i < consommation.length;
                                      i++) {
                                    if (consommation[i].length >= 2) {
                                      for (var j = consommation[i].length - 1;
                                          j < 0;
                                          j--) {
                                        consommation[i][j - 1].date =
                                            consommation[i][j].date;
                                      }
                                      consommation[i].removeAt(0);
                                    }
                                  }

                                  return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 30),
                                        CustomAppBar(
                                          title:
                                              "Stock de ${widget.categorie.nom}",
                                        ),
                                        evolutionStock(
                                            consommation, snapshot.data!),
                                        const SizedBox(height: 10),
                                        //quantite(snapshot2.data!),
                                      ]);
                                });
                          }))),
            )));
  }

  void Settings() {}

  Widget evolutionStock(
      List<List<ConsommationProduct>> consommation, List<Product> produits) {
    Widget bottomTitleWidgets(DateTime start, double value, TitleMeta meta) {
      const style = TextStyle(
        fontSize: 12,
      );

      return SideTitleWidget(
        angle: -pi / 4,
        axisSide: meta.axisSide,
        child: Text(
          DateFormat("dd/MM").format(start.add(Duration(days: value.toInt()))),
          style: style,
        ),
      );
    }

    Widget leftTitleWidgets(double value, TitleMeta meta) {
      const style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      );
      String text;
      switch (value.toInt()) {
        case 1:
          text = '10K';
          break;
        case 6951:
          text = 'lol';
          break;
        case 5:
          text = '50k';
          break;
        default:
          return Container();
      }

      return Text(text, style: style, textAlign: TextAlign.left);
    }

    LineChartData mainData(List<List<ConsommationProduct>> data) {
      return LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 10,
            maxContentWidth: 200,
            tooltipBgColor: white(context),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: black(context),
                  fontSize: 14,
                );
                return LineTooltipItem(
                  "${produits[touchedSpot.barIndex].nom}: ${touchedSpot.y.round()}",
                  textStyle,
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchLineStart: (data, index) => 0,
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (a, b) {
                return bottomTitleWidgets(
                    data
                        .reduce((current, next) =>
                            current.first.date.isBefore(next.first.date)
                                ? current
                                : next)
                        .first
                        .date,
                    a,
                    b);
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: widget.categorie.couleur.withOpacity(.2)),
        ),
        minX: 0,
        maxX: data
            .reduce((current, next) =>
                current.first.date.isBefore(next.first.date) ? current : next)
            .first
            .date
            .difference(data
                .reduce((current, next) =>
                    current.last.date.isAfter(next.last.date) ? current : next)
                .last
                .date)
            .inDays
            .abs()
            .toDouble(),
        minY: 0,
        maxY: (data
                .map((e) => (e.map((e) => e.quantite.toDouble()).toList())
                    .reduce(max)
                    .toDouble())
                .toList())
            .reduce(max),
        lineBarsData: data
            .map((e) => LineChartBarData(
                  spots: e
                      .map((f) => FlSpot(
                          f.date
                              .difference(e.first.date)
                              .inDays
                              .abs()
                              .toDouble(),
                          f.quantite))
                      .toList(),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      ColorTween(
                              begin: produits
                                  .firstWhere(
                                      (element) => e.first.idProd == element.id)
                                  .couleur,
                              end: produits
                                  .firstWhere(
                                      (element) => e.first.idProd == element.id)
                                  .couleur
                                  .withOpacity(.5))
                          .lerp(0.2)!,
                      ColorTween(
                              begin: produits
                                  .firstWhere(
                                      (element) => e.first.idProd == element.id)
                                  .couleur,
                              end: produits
                                  .firstWhere(
                                      (element) => e.first.idProd == element.id)
                                  .couleur
                                  .withOpacity(.5))
                          .lerp(0.2)!,
                    ],
                  ),
                  barWidth: 5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    getDotPainter: (p0, p1, p2, p3) {
                      return FlDotCirclePainter(
                          color: produits
                              .firstWhere(
                                  (element) => e.first.idProd == element.id)
                              .couleur,
                          strokeColor: produits
                              .firstWhere(
                                  (element) => e.first.idProd == element.id)
                              .couleur
                              .withOpacity(.3),
                          strokeWidth: 2);
                    },
                    show: true,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        ColorTween(
                                begin: produits
                                    .firstWhere((element) =>
                                        e.first.idProd == element.id)
                                    .couleur,
                                end: produits
                                    .firstWhere((element) =>
                                        e.first.idProd == element.id)
                                    .couleur
                                    .withOpacity(.5))
                            .lerp(0.2)!
                            .withOpacity(0.1),
                        ColorTween(
                                begin: produits
                                    .firstWhere((element) =>
                                        e.first.idProd == element.id)
                                    .couleur,
                                end: produits
                                    .firstWhere((element) =>
                                        e.first.idProd == element.id)
                                    .couleur
                                    .withOpacity(.5))
                            .lerp(0.2)!
                            .withOpacity(0.1),
                      ],
                    ),
                  ),
                ))
            .toList(),
      );
    }

    LineChartData avgData(List<List<ConsommationProduct>> data) {
      List<double> average = data
          .map((e) =>
              (e.map((f) => f.quantite).reduce((a, b) => a + b) / e.length)
                  .toDouble())
          .toList();
      return LineChartData(
        lineTouchData: const LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: black(context).withOpacity(.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (a, b) {
                return bottomTitleWidgets(
                    data
                        .reduce((current, next) =>
                            current.first.date.isBefore(next.first.date)
                                ? current
                                : next)
                        .first
                        .date,
                    a,
                    b);
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: widget.categorie.couleur.withOpacity(.2)),
        ),
        minX: 0,
        maxX: data
            .reduce((current, next) =>
                current.first.date.isBefore(next.first.date) ? current : next)
            .first
            .date
            .difference(data
                .reduce((current, next) =>
                    current.last.date.isAfter(next.last.date) ? current : next)
                .last
                .date)
            .inDays
            .abs()
            .toDouble(),
        minY: 0,
        maxY: (data
                .map((e) => (e.map((e) => e.quantite.toDouble()).toList())
                    .reduce(max)
                    .toDouble())
                .toList())
            .reduce(max),
        lineBarsData: data
            .map((e) => LineChartBarData(
                  spots: e
                      .map((f) => FlSpot(
                          f.date
                              .difference(e.first.date)
                              .inDays
                              .abs()
                              .toDouble(),
                          average[data.indexOf(e)]))
                      .toList(),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      ColorTween(
                              begin: produits
                                  .firstWhere(
                                      (element) => e.first.idProd == element.id)
                                  .couleur,
                              end: produits
                                  .firstWhere(
                                      (element) => e.first.idProd == element.id)
                                  .couleur
                                  .withOpacity(.5))
                          .lerp(0.2)!,
                      ColorTween(
                              begin: produits
                                  .firstWhere(
                                      (element) => e.first.idProd == element.id)
                                  .couleur,
                              end: produits
                                  .firstWhere(
                                      (element) => e.first.idProd == element.id)
                                  .couleur
                                  .withOpacity(.5))
                          .lerp(0.2)!,
                    ],
                  ),
                  barWidth: 5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        ColorTween(
                                begin: produits
                                    .firstWhere((element) =>
                                        e.first.idProd == element.id)
                                    .couleur,
                                end: produits
                                    .firstWhere((element) =>
                                        e.first.idProd == element.id)
                                    .couleur
                                    .withOpacity(.5))
                            .lerp(0.2)!
                            .withOpacity(0.1),
                        ColorTween(
                                begin: produits
                                    .firstWhere((element) =>
                                        e.first.idProd == element.id)
                                    .couleur,
                                end: produits
                                    .firstWhere((element) =>
                                        e.first.idProd == element.id)
                                    .couleur
                                    .withOpacity(.5))
                            .lerp(0.2)!
                            .withOpacity(0.1),
                      ],
                    ),
                  ),
                ))
            .toList(),
      );
    }

    Widget body = Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData(consommation) : mainData(consommation),
            ),
          ),
        ),
        SizedBox(
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'moyenne',
              style: TextStyle(
                fontSize: 12,
                color:
                    showAvg ? black(context).withOpacity(0.5) : black(context),
              ),
            ),
          ),
        ),
      ],
    );

    return Box(
        Text("Évolution du stock (en ${widget.categorie.unite})",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        body,
        null,
        context);
  }
}
