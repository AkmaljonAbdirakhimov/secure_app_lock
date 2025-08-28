import 'package:flutter/material.dart';
import 'package:secure_app_lock/secure_app_lock.dart';

enum PinStatus { initial, confirm, authenticate, incorrectAuthenticate, incorrectConfirm }

class PinCodePage extends StatefulWidget {
  final bool isAuthenticate;
  const PinCodePage({super.key, this.isAuthenticate = false});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  final lockController = SecureLock.lockController;
  final pinController = ValueNotifier<String?>(null);
  final pinStatus = ValueNotifier<PinStatus>(PinStatus.initial);
  final code = ValueNotifier<String>("");

  @override
  void initState() {
    super.initState();
    initPin();
  }

  void initPin() async {
    pinController.value = lockController.pin;
    pinStatus.value = widget.isAuthenticate || pinController.value != null ? PinStatus.authenticate : PinStatus.initial;
  }

  void addPin(String pin) {
    String currentCode = code.value;
    currentCode += pin;

    if (currentCode.length > 4) {
      return;
    } else {
      code.value += pin;
    }

    if (code.value.length == 4) {
      checkPin();
    }
  }

  void removePin() {
    if (code.value.isNotEmpty) {
      code.value = code.value.substring(0, code.value.length - 1);

      if (pinStatus.value == PinStatus.incorrectAuthenticate || pinStatus.value == PinStatus.incorrectConfirm) {
        resetPin();
      }
    }
  }

  void checkPin() async {
    // if it is initial status, then we need to set the pin
    if (pinStatus.value == PinStatus.initial) {
      pinController.value = code.value;
      pinStatus.value = PinStatus.confirm;
      code.value = "";
      return;
    }

    // if it is confirm status, then we need to check if the pin is correct
    if (pinStatus.value == PinStatus.confirm) {
      if (code.value == pinController.value) {
        // pint is correct, we need to set the pin
        await lockController.setPin(code.value);
        lockController.enable();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("New pin code set up")));
        }
        return;
      } else {
        pinStatus.value = PinStatus.incorrectConfirm;
        return;
      }
    }

    // if it is authenticate status, then we need to check if the pin is correct
    if (pinStatus.value == PinStatus.authenticate) {
      if (code.value == pinController.value) {
        // authenticated
        if (widget.isAuthenticate) {
          // navigate back
          lockController.unlock();
          Navigator.of(context).pop();
        } else {
          // set up a new pin
          pinStatus.value = PinStatus.initial;
          code.value = "";
        }
        return;
      } else {
        pinStatus.value = PinStatus.incorrectAuthenticate;
        return;
      }
    }

    if (pinStatus.value == PinStatus.incorrectAuthenticate || pinStatus.value == PinStatus.incorrectConfirm) {
      code.value = "";
      resetPin();
    }
  }

  void resetPin() {
    if (pinStatus.value == PinStatus.incorrectAuthenticate) {
      pinStatus.value = PinStatus.authenticate;
    } else if (pinStatus.value == PinStatus.incorrectConfirm) {
      pinStatus.value = PinStatus.confirm;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AppLock',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 32),
              ValueListenableBuilder(
                valueListenable: pinStatus,
                builder: (context, currentPinStatus, child) {
                  String text = "Введите новый код";

                  if (currentPinStatus == PinStatus.confirm) {
                    text = "Повторите код";
                  } else if (currentPinStatus == PinStatus.authenticate) {
                    text = "Введите ПИН-код";
                  } else if (currentPinStatus == PinStatus.incorrectAuthenticate ||
                      currentPinStatus == PinStatus.incorrectConfirm) {
                    text = "Неверный код";
                  }

                  return Text(
                    text,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                  );
                },
              ),
              SizedBox(height: 24),
              Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return ValueListenableBuilder(
                    valueListenable: code,
                    builder: (context, currentCode, child) {
                      final isActive = currentCode.length > index;
                      return ValueListenableBuilder(
                        valueListenable: pinStatus,
                        builder: (context, currentPinStatus, child) {
                          final isIncorrect =
                              currentPinStatus == PinStatus.incorrectAuthenticate ||
                              currentPinStatus == PinStatus.incorrectConfirm;
                          Color color = Colors.transparent;
                          if (isIncorrect) {
                            color = Colors.red;
                          } else if (isActive) {
                            color = Colors.blue;
                          }

                          return Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isActive || isIncorrect ? null : Border.all(color: Colors.grey),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: 24),
              Column(
                spacing: 16,
                children: [
                  ...List.generate(3, (index) {
                    return Row(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (number) {
                        final label = index * 3 + number + 1;
                        return InkWell(
                          onTap: () => addPin(label.toString()),
                          borderRadius: BorderRadius.circular(40),
                          child: Ink(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                label.toString(),
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                  Row(
                    spacing: 16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 80, height: 80),
                      InkWell(
                        onTap: () => addPin("0"),
                        borderRadius: BorderRadius.circular(40),
                        child: Ink(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              "0",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: removePin,
                        borderRadius: BorderRadius.circular(40),
                        child: SizedBox(width: 80, height: 80, child: Center(child: Icon(Icons.backspace, size: 28))),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
