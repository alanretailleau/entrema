import 'dart:math';

import 'package:entrema/classes/commerce.dart';
import 'package:entrema/classes/course.dart';
import 'package:entrema/classes/user.dart';
import 'package:entrema/color.dart';
import 'package:entrema/functions/function.dart';
import 'package:entrema/widget/bottom_bar.dart';
import 'package:entrema/widget/box.dart';
import 'package:entrema/widget/button.dart';
import 'package:entrema/widget/money.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key, required this.user, required this.commerce});
  final Commerce commerce;
  final User user;
  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  List<Map> settings = [];

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
            body: SafeArea(
                child: StreamBuilder<List<Course>>(
                    stream: Course.streamLatestCourses(widget.commerce.id,
                        DateTime.now().subtract(const Duration(days: 30))),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10),
                                child: Text(
                                  "Tableau de bord",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 0),
                                child: Text(
                                  "État des stocks",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: black(context).withOpacity(.5)),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              KPI(snapshot.hasData ? snapshot.data! : []),
                              evolutionData(
                                  snapshot.hasData ? snapshot.data! : []),
                            ]);
                      } else {
                        return Container();
                      }
                    }))));
  }

  void settingsKPI() {}

  Widget KPI(List<Course> data) {
    return Box(
        const Text("KPI",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Panier moyen : "),
                Money(price: Course.panierMoyen(data))
              ],
            ),
            Text("Nombre de panier : ${data.length} (en 30 jours)"),
          ],
        ),
        null,
        context);
  }

  Widget evolutionData(List<Course> data) {
    return Box(
        const Text("Évolution du panier moyen",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        evolutionStock(data),
        null,
        context);
  }

  bool showAvg = false;

  Widget evolutionStock(List<Course> consommation) {
    List<LightCourse> courses = [];
    for (var i = 0; i < consommation.length; i++) {
      List<Course> docs = consommation
          .where((element) =>
              DateTime(element.date.year, element.date.month, element.date.day)
                  .isAtSameMomentAs(DateTime(consommation[i].date.year,
                      consommation[i].date.month, consommation[i].date.day)))
          .toList();
      courses.add(LightCourse(
          date: DateTime(consommation[i].date.year, consommation[i].date.month,
              consommation[i].date.day),
          price: Course.panierMoyen(docs)));
      i += docs.length - 1;
    }

    List<Color> gradientColors = [
      widget.user.couleur,
      Theme.of(context).brightness == Brightness.dark
          ? darken(widget.user.couleur, 0.3)
          : lighten(widget.user.couleur, 0.3),
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

    LineChartData mainData(List<LightCourse> data) {
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
          border: Border.all(color: widget.user.couleur.withOpacity(.2)),
        ),
        minX: 0,
        maxX: data.last.date.difference(data.first.date).inDays.toDouble(),
        minY: 0,
        maxY: (data.map((e) => e.price).toList()).reduce(max),
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
                    e.price))
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
                    color: widget.user.couleur,
                    strokeColor: widget.user.couleur.withOpacity(.3),
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

    LineChartData avgData(List<LightCourse> data) {
      double average =
          (data.map((e) => e.price).reduce((a, b) => a + b) / data.length)
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
          border: Border.all(color: widget.user.couleur.withOpacity(.2)),
        ),
        minX: 0,
        maxX: data.last.date.difference(data.first.date).inDays.toDouble(),
        minY: 0,
        maxY: (data.map((e) => e.price).toList()).reduce(max),
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

    return Stack(
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
              showAvg ? avgData(courses) : mainData(courses),
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
  }
}
