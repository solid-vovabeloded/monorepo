import 'dart:math';

import 'package:fcharts/fcharts.dart';
import 'package:flutter/material.dart';

/// The widget with sparkline.
///
/// If no constraints are given by the parent of this widget,
/// it fills all the available space.
class SparklineGraph extends StatelessWidget {
  /// A minimal length of this graph axis.
  static const int _minChartAxisLength = 1;

  /// A default axes [TickGenerator] that generates empty tick list.
  static const _axisTickGenerator = FixedTickGenerator<num>(ticks: []);

  /// A class to present the line of this graph.
  final List<Point> data;

  /// A color of this graph's line.
  final Color strokeColor;

  /// A color this graph is filled with.
  final Color fillColor;

  /// A padding of this graph.
  final EdgeInsets graphPadding;

  /// A [LineCurve] that defines the drawing type for the curve.
  final LineCurve curveType;

  /// A width of this graph's stroke.
  final double strokeWidth;

  /// Creates the [SparklineGraph] widget.
  ///
  /// Throws an [AssertionError] if the given [data] is null.
  /// Throws an [AssertionError] if the given [strokeWidth] is null or negative.
  /// The [curveType] default value is [LineCurves.linear].
  /// The [graphPadding] default value is [EdgeInsets.zero].
  const SparklineGraph({
    Key key,
    @required this.data,
    this.curveType = LineCurves.linear,
    this.strokeColor,
    this.fillColor,
    this.graphPadding = EdgeInsets.zero,
    this.strokeWidth = 4.0,
  })  : assert(strokeWidth != null && strokeWidth >= 0.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final graphData = data?.toList() ?? [];

    return LineChart(
      chartPadding: graphPadding,
      lines: [
        Line<Point, num, num>(
          data: graphData,
          xFn: (point) => point.x,
          yFn: (point) => point.y,
          curve: curveType,
          marker: const MarkerOptions(paint: null),
          stroke: PaintOptions.stroke(
            color: strokeColor,
            strokeWidth: strokeWidth,
          ),
          fill: PaintOptions.fill(
            color: fillColor,
          ),
          xAxis: ChartAxis(
            spanFn: _createAxisSpan,
            tickGenerator: _axisTickGenerator,
            paint: null,
          ),
          yAxis: ChartAxis(
            spanFn: _createStrokeFitAxisSpan,
            tickGenerator: _axisTickGenerator,
            paint: null,
          ),
        ),
      ],
    );
  }

  /// Creates the [DoubleSpan] for axes that represent
  /// the visible range of the axis from minimum value to maximum.
  DoubleSpan _createAxisSpan(List<num> data) {
    if (data == null || data.isEmpty) return null;

    double min = data.first.toDouble();
    double max = data.first.toDouble();

    for (final value in data) {
      if (min > value) min = value.toDouble();
      if (max < value) max = value.toDouble();
    }

    final axisLength = max - min;
    if (axisLength < _minChartAxisLength) {
      max += _minChartAxisLength - axisLength;
    }

    return DoubleSpan(min, max);
  }

  /// Creates the [DoubleSpan] for Y axis.
  ///
  /// Represents the visible range of the axis from min axis value to max axis
  /// value with an additional indent to fit the stroke.
  DoubleSpan _createStrokeFitAxisSpan(List<num> data) {
    final axisSpan = _createAxisSpan(data);

    if (axisSpan == null) return null;

    final relativeStrokeWidth = (axisSpan.max - axisSpan.min) / strokeWidth / 2;

    return DoubleSpan(
      axisSpan.min - relativeStrokeWidth,
      axisSpan.max + relativeStrokeWidth,
    );
  }
}
