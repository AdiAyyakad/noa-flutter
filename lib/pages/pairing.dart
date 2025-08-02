import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:noa/models/app_logic_model.dart' as app;
import 'package:noa/pages/noa.dart';
import 'package:noa/style.dart';
import 'package:noa/util/switch_page.dart';
import 'package:noa/widgets/top_title_bar.dart';

class PairingPage extends ConsumerWidget {
  const PairingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.watch(app.model).state.current == app.State.connected ||
          ref.watch(app.model).state.current == app.State.disconnected) {
        switchPage(context, const NoaPage());
      }
    });

    String statusText = "";
    String buttonText = "";
    bool buttonEnabled = false;
    int updateProgress = ref.watch(app.model).bluetoothUploadProgress.toInt();
    String deviceName = ref.watch(app.model).deviceName;

    switch (ref.watch(app.model).state.current) {
      case app.State.scanning:
        statusText = "Scanning for nearby devices...";
        buttonText = "Searching";
        buttonEnabled = false;
        break;
      case app.State.found:
        statusText = "$deviceName found";
        buttonText = "Connect";
        buttonEnabled = true;
        break;
      case app.State.connect:
      case app.State.stopLuaApp:
      case app.State.checkFirmwareVersion:
      case app.State.triggerUpdate:
        statusText = "Connecting to $deviceName...";
        buttonText = "Connecting";
        buttonEnabled = false;
        break;
      case app.State.updateFirmware:
        statusText = "Updating firmware: $updateProgress%";
        buttonText = "Please wait";
        buttonEnabled = false;
        break;
      case app.State.uploadMainLua:
        statusText = "Setting up device: 50%";
        buttonText = "Please wait";
        buttonEnabled = false;
        break;
      case app.State.uploadGraphicsLua:
        statusText = "Setting up device: 68%";
        buttonText = "Please wait";
        buttonEnabled = false;
        break;
      case app.State.uploadStateLua:
        statusText = "Setting up device: 83%";
        buttonText = "Please wait";
        buttonEnabled = false;
        break;
      case app.State.requiresRepair:
        statusText = "Connection failed - Un-pair device first";
        buttonText = "Try again";
        buttonEnabled = true;
        break;
    }

    return Scaffold(
      backgroundColor: colorWhite,
      appBar: topTitleBar(context, 'DEVICES', false, false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Device status
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: colorLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    ref.watch(app.model).state.current == app.State.found
                        ? Icons.bluetooth
                        : ref.watch(app.model).state.current == app.State.scanning
                            ? Icons.bluetooth_searching
                            : Icons.bluetooth_connected,
                    size: 64,
                    color: buttonEnabled ? colorDark : colorLight,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    statusText,
                    style: textStyleDarkHeading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: buttonEnabled
                          ? () {
                              ref.read(app.model).triggerEvent(app.Event.buttonPressed);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonEnabled ? colorDark : colorLight,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: textStyleWhiteWidget,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Instruction text
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Make sure your smart glasses are turned on and nearby. The app will automatically detect and connect to available devices.",
                style: textStyleLight,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
