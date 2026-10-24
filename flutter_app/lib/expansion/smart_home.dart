class SmartHomeDevice {
  final String id;
  final String name;
  bool isOn;
  final String type;

  SmartHomeDevice({
    required this.id,
    required this.name,
    this.isOn = false,
    this.type = 'light',
  });
}

class SmartHomeModule {
  final List<SmartHomeDevice> devices = [
    SmartHomeDevice(id: 'light-1', name: "Gowrob's Room Light", isOn: true, type: 'light'),
    SmartHomeDevice(id: 'fan-1', name: 'Ambient Fan', isOn: false, type: 'fan'),
    SmartHomeDevice(id: 'robot-1', name: 'ESP32 CAM Companion', isOn: true, type: 'robot'),
  ];

  void toggleDevice(String id) {
    final dev = devices.firstWhere((d) => d.id == id, orElse: () => devices.first);
    dev.isOn = !dev.isOn;
  }
}
