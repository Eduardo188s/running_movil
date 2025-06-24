import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  Map<DeviceIdentifier, ScanResult> scanResults = {};
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    startScan();
  }

  Future<void> startScan() async {
    setState(() {
      isScanning = true;
      scanResults.clear();
      devicesList.clear();
    });

    await flutterBlue.startScan(timeout: const Duration(seconds: 5));

    // Escuchar resultados
    flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResults.clear();
        for (var r in results) {
          scanResults[r.device.id] = r;
        }
        devicesList = scanResults.values.map((r) => r.device).toList();
      });
    });

    // Actualizar estado de escaneo
    flutterBlue.isScanning.listen((scanning) {
      setState(() {
        isScanning = scanning;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    flutterBlue.stopScan();
    super.dispose();
  }

  void _showDeviceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Dispositivos Bluetooth Disponibles',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              if (isScanning)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                )
              else if (devicesList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No se encontraron dispositivos',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: devicesList.length,
                    itemBuilder: (context, index) {
                      final device = devicesList[index];
                      return ListTile(
                        leading: const Icon(Icons.watch),
                        title: Text(device.name.isNotEmpty ? device.name : 'Dispositivo desconocido'),
                        subtitle: Text(device.id.id),
                        trailing: ElevatedButton(
                          child: const Text('Conectar'),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Intentando conectar a ${device.name.isNotEmpty ? device.name : device.id.id}...',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                            // Aquí puedes agregar la lógica para conectar al dispositivo
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Buscar de nuevo'),
                onPressed: () {
                  startScan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildConnectedDeviceCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/images/reloj1.png', height: 90),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HUAWEI Band 6',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.battery_full, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('60%', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDeviceGallery() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset('assets/images/reloj1.png', height: 90),
          Image.asset('assets/images/reloj1.png', height: 90),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Dispositivos',
          style: TextStyle(
            fontSize: 26,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            buildConnectedDeviceCard(),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _showDeviceModal(context),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue,
                    border: Border.all(color: Colors.blue, width: 1.2),
                  ),
                  child: const Text(
                    'ADD DEVICES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            buildDeviceGallery(),
          ],
        ),
      ),
    );
  }
}
