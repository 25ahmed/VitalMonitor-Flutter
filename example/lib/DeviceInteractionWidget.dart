import 'package:flutter/material.dart';
import 'package:mdsflutter_example/DeviceModel.dart';
import 'package:provider/provider.dart';

import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

import 'package:mdsflutter_example/Device.dart';

import 'AppModel.dart';

class DeviceInteractionWidget extends StatefulWidget {
  final Device device;
  const DeviceInteractionWidget(this.device);

  @override
  State<StatefulWidget> createState() {
    return _DeviceInteractionWidgetState();
  }
}

class _DeviceInteractionWidgetState extends State<DeviceInteractionWidget> {
  late AppModel _appModel;

  List<double> _heartRateHistory = [];
  List<int> _timeHistory = [];
  bool _showChart = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _appModel = Provider.of<AppModel>(context, listen: false);
    _appModel.onDeviceMdsDisconnected((device) => Navigator.pop(context));
  }



  void _onAccelerometerButtonPressed(DeviceModel deviceModel) {
    if (deviceModel.accelerometerSubscribed) {
      deviceModel.unsubscribeFromAccelerometer();
    } else {
      deviceModel.subscribeToAccelerometer();

    }
  }

  void _onHrButtonPressed(DeviceModel deviceModel) {
    if (deviceModel.hrSubscribed) {
      deviceModel.unsubscribeFromHr();
      _stopUpdatingHeartRate();
    } else {
      deviceModel.subscribeToHr();
      _startUpdatingHeartRate(deviceModel);
    }
  }

  void _startUpdatingHeartRate(DeviceModel deviceModel) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      String hrData = deviceModel.hrData;

      // Remove " bpm" from the end of the string
      String hrValueString = hrData.replaceAll(" bpm", "");

      // Convert the remaining string to double
      double hrValue = double.tryParse(hrValueString) ?? 0.0;

      setState(() {
        _heartRateHistory.add(hrValue);
        _timeHistory.add(timer.tick);

        if (_heartRateHistory.length > 30) {
          _heartRateHistory.removeAt(0); // Remove the oldest entry
          _timeHistory.removeAt(0);
        }
        //_showChart = true; // Ensure the chart is visible
      });

      print("Heart rate value: $hrValue");
      print('HR history: $_heartRateHistory');
    });
  }

  void _stopUpdatingHeartRate() {
    _timer?.cancel();
  }


  @override
  void dispose() {
    _appModel.disconnectFromDevice(widget.device);
    _stopUpdatingHeartRate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Device device = widget.device;
    return ChangeNotifierProvider(
      create: (context) => DeviceModel(device.name, device.serial),
      child: Consumer<DeviceModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(device.name!),
            ),
            body: SingleChildScrollView(
          //    padding: EdgeInsets.fromLTRB(10, 6, 5, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _accelerometerItem(model),
                  _hrItem(model),
                  _ledItem(model),
                  _temperatureItem(model),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showChart = true;
                      });
                    },
                    child: Text("Heart Rate Chart"),
                  ),
                  if (_showChart) _buildChart(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _accelerometerItem(DeviceModel deviceModel) {
    return Card(
      child: ListTile(
        title: Text("Accelerometer"),
        subtitle: Text(deviceModel.accelerometerData),
        trailing: ElevatedButton(
          child: Text(deviceModel.accelerometerSubscribed
              ? "Unsubscribe"
              : "Accelerometer"),
          onPressed: () => _onAccelerometerButtonPressed(deviceModel),
        ),
      ),
    );
  }

  Widget _hrItem(DeviceModel deviceModel) {
    return Card(
      child: ListTile(
        title: Text("Heart rate"),
        subtitle: Text(deviceModel.hrData),
        trailing: ElevatedButton(
          child: Text(deviceModel.hrSubscribed ? "Unsubscribe" : "Heart Rate"),
          onPressed: () {
            _onHrButtonPressed(deviceModel);
          },
        ),
      ),
    );
  }

  Widget _ledItem(DeviceModel deviceModel) {
    return Card(
      child: ListTile(
        title: Text("Led"),
        trailing: Switch(
          value: deviceModel.ledStatus,
          onChanged: (b) => {deviceModel.switchLed()},
        ),
      ),
    );
  }

  Widget _temperatureItem(DeviceModel deviceModel) {
    return Card(
      child: ListTile(
        title: Text("Temperature"),
        subtitle: Text(deviceModel.temperature),
        trailing: ElevatedButton(
          child: Text("Get Temp"),
          onPressed: () => deviceModel.getTemperature(),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              minY: 40,
              maxY: 200,
              lineBarsData: [
                LineChartBarData(
                  spots: _heartRateHistory.asMap().entries.map((e) {
                    return FlSpot(_timeHistory[e.key].toDouble(), e.value);
                  }).toList(),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withOpacity(0.08),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                  axisNameWidget: Text(
                    'Heart Rate (bpm)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false, getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString(), style: TextStyle(fontSize: 10),);
                  }),
                  axisNameWidget: Text(
                    'Time (seconds)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black, width: 1),
              ),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      );
  }
}
