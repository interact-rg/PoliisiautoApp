/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import '../auth.dart';
import '../common.dart';
import '../data.dart';
import '../api.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

////////////////////////////////////////////////////////////////////////////////
/// Form field sub-builders
////////////////////////////////////////////////////////////////////////////////

/// Description: Text field

/// Bully: Text field with autocomplete
Widget buildBullyField(BuildContext context, List<User> bullyOptions,
        TextEditingController controller, Function(User?) onSelectBully) =>
    Autocomplete<User>(
      displayStringForOption: (option) => option.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<User>.empty();
        }
        return bullyOptions.where((User option) {
          return option.name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) =>
          TextFormField(
        controller: controller,
        keyboardType: TextInputType.name,
        focusNode: focusNode,
        onEditingComplete: () {
          onFieldSubmitted();
          // Unfocus the current focus when editing is complete
          FocusScope.of(context).unfocus();
        },
        maxLength: 100,
        validator: (value) {
          return null;
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.person_outline),
          hintText: 'Kirjoita kiusaajan nimi',
          labelText: AppLocalizations.of(context)!.whoBullied,
          counterText: '',
        ),
        key: const ValueKey("Bully"),
      ),
      onSelected: ((option) {
        onSelectBully(option);
        controller.text = option.id.toString();
      }),
    );

/// Bullied was not me: Checkbox
Widget buildBulliedWasNotMeField(
        BuildContext context, bool state, ValueSetter<bool?> onChanged) =>
    CheckboxListTile(
      title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(AppLocalizations.of(context)!.bulliedPerson)),
      value: state,
      onChanged: onChanged,
      key: const ValueKey("BulliedCheckbox"),
    );

/// Bullied: Text field with autocomplete
Widget buildBulliedField(BuildContext context, List<User> bulliedOptions,
        TextEditingController controller, bool enabled) =>
    Autocomplete<User>(
        displayStringForOption: (option) => option.name,
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<User>.empty();
          }
          return bulliedOptions.where((User option) {
            return option.name
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase());
          });
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) =>
            TextFormField(
              controller: controller,
              enabled: enabled,
              focusNode: focusNode,
              onEditingComplete: onFieldSubmitted,
              maxLength: 100,
              validator: (value) {
                return null;
              },
              decoration: InputDecoration(
                icon: const Icon(Icons.person_outline),
                hintText: 'Kirjoita kiusatun nimi',
                labelText: AppLocalizations.of(context)!.whoWasBullied,
                counterText: '',
              ),
              key: const ValueKey("Bullied"),
            ),
        onSelected: ((option) => controller.text = option.id.toString()));

Widget buildHandlerField(BuildContext context, List<User> handlerOptions,
        ValueSetter<User?> onChanged) =>
    DropdownButtonFormField<User>(
      onChanged: onChanged,
      items: handlerOptions.map<DropdownMenuItem<User>>((User option) {
        return DropdownMenuItem<User>(
          value: option,
          child: Text(option.name),
        );
      }).toList(),
      decoration: InputDecoration(
        icon: const Icon(Icons.person_outline),
        hintText: 'Valitse opettaja',
        labelText: AppLocalizations.of(context)!.sendNotificationWho,
        counterText: '',
      ),
      key: const ValueKey("SendTo"),
    );

/// Anonymous: Checkbox
Widget buildAnonymousField(
        BuildContext context, bool state, ValueSetter<bool?> onChanged) =>
    CheckboxListTile(
      title: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(AppLocalizations.of(context)!.noName)),
      value: state,
      onChanged: onChanged,
      key: const ValueKey("AnonCheckbox"),
    );

////////////////////////////////////////////////////////////////////////////////

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Form fields
  TextEditingController _descriptionController = TextEditingController();
  final _bullyController = TextEditingController();
  final _bulliedController = TextEditingController();

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  User? _selectedHandler;
  bool _bulliedWasNotMe = false;
  bool _isAnonymous = true;
  User? _selectedBully;

  late Future<Map<String, List<User>>> _options;

  @override
  void initState() {
    super.initState();
    _selectedHandler = null;
    _bulliedWasNotMe = false;
    _isAnonymous = false;
    _initSpeech();

    _options = Future.delayed(Duration.zero, () => _fetchOptions());
  }

  Future<Map<String, List<User>>> _fetchOptions() async {
    Map<String, List<User>> temp = {};
    temp['teachers'] = await api.fetchTeachers();
    temp['students'] = await api.fetchStudents();

    temp['teachers']!.insert(0, dummyTeacher);
    return temp;
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (_speechEnabled) {
      // Speech-to-text initialized successfully
      setState(() {});
    } else {
      // Speech-to-text initialization failed
      print('Speech-to-text initialization failed.');
    }
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _descriptionController.text =
          _lastWords; // Set recognized words to the controller
    });
  }

  int currentStep = 0;
  continueStep() {
    if (currentStep < 4) {
      if (currentStep == 1 && _descriptionController.text.isEmpty) {
        // Prevent moving to the next step if description field is empty
        !_formKey.currentState!.validate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cantLeaveEmpty),
          ),
        );
        return;
      }

      setState(() {
        currentStep = currentStep + 1;
      });
    }
  }

  cancelStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep = currentStep - 1; //currentStep-=1;
      });
    }
  }

  onStepTapped(int value) {
    setState(() {
      currentStep = value;
    });
  }

  Widget buildDescriptionField(
          BuildContext context, TextEditingController controller) =>
      Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.name,
            controller: controller,
            autofocus: false,
            maxLength: 1000,
            minLines: 3,
            maxLines: 10,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.cantLeaveEmpty;
              }
              return null;
            },
            decoration: InputDecoration(
              icon: const Icon(Icons.speaker_notes_outlined),
              hintText: AppLocalizations.of(context)!.tellWhatHappened,
              labelText: AppLocalizations.of(context)!.whatHappened,
            ),
            key: ValueKey(AppLocalizations.of(context)!.description),
            onEditingComplete: () {
              // This function will be called when the user presses "Enter" on the keyboard
              FocusScope.of(context).unfocus(); // Close the keyboard
            },
          ),
          FloatingActionButton(
            onPressed:
                // If not yet listening for speech start, otherwise stop
                _speechToText.isNotListening ? _startListening : _stopListening,
            tooltip: 'Listen',
            child:
                Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
          ),
        ],
      );

  Widget controlBuilders(context, details) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          if (currentStep > 0)
            OutlinedButton(
              onPressed: () {
                FocusScope.of(context).unfocus(); // Close the keyboard
                details.onStepCancel();
              },
              child: Icon(Icons.arrow_back),
            )
          else
            const SizedBox(width: 20),
          const SizedBox(width: 20),
          if (currentStep < 4)
            ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus(); // Close the keyboard
                details.onStepContinue();
              },
              child: Icon(Icons.arrow_forward),
            )
          else
            const SizedBox(width: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.makeReport)),
        resizeToAvoidBottomInset: false,
        body: FutureBuilder<Map<String, List<User>>>(
            future: _options,
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                List<User> teacherOptions = snapshot.data!['teachers']!;
                List<User> studentOptions = snapshot.data!['students']!;

                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Stepper(
                        elevation: 0, //Horizontal Impact
                        controlsBuilder: controlBuilders,
                        type: StepperType.horizontal,
                        physics: const ScrollPhysics(),
                        onStepTapped: onStepTapped,
                        onStepContinue: continueStep,
                        onStepCancel: cancelStep,
                        currentStep: currentStep, //0, 1, 2, 3, 4
                        connectorColor:
                            WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return Colors.grey; // Color when disabled
                          }
                          return Colors.blueAccent; // Color when activated
                        }),
                        steps: [
                          Step(
                              title: const Text(''),
                              content: Column(
                                children: [
                                  buildAnonymousField(context, _isAnonymous,
                                      (state) {
                                    setState(
                                        () => _isAnonymous = state ?? false);
                                  }),
                                ],
                              ),
                              isActive: currentStep >= 0,
                              state: currentStep >= 0
                                  ? StepState.complete
                                  : StepState.disabled),
                          Step(
                            title: const Text(''),
                            content: Column(children: [
                              buildDescriptionField(
                                  context, _descriptionController)
                            ]),
                            isActive: currentStep >= 1,
                            state: _descriptionController.text.isNotEmpty
                                ? StepState.complete
                                : StepState.disabled,
                          ),
                          Step(
                            title: const Text(''),
                            content: Column(children: [
                              buildBullyField(
                                context,
                                studentOptions,
                                _bullyController,
                                (User? option) {
                                  setState(() {
                                    _selectedBully = option;
                                  });
                                },
                              ),
                              buildBulliedWasNotMeField(
                                  context, _bulliedWasNotMe, (state) {
                                setState(
                                    () => _bulliedWasNotMe = state ?? false);
                              }),
                              buildBulliedField(context, studentOptions,
                                  _bulliedController, _bulliedWasNotMe),
                            ]),
                            isActive: currentStep >= 2 &&
                                _descriptionController.text.isNotEmpty,
                            state: currentStep >= 2
                                ? StepState.complete
                                : StepState.disabled,
                          ),
                          Step(
                            title: const Text(''),
                            content: Column(children: [
                              buildHandlerField(context, teacherOptions,
                                  (User? option) {
                                setState(() => _selectedHandler = option);
                              }),
                            ]),
                            isActive: currentStep >= 3,
                            state: currentStep >= 3
                                ? StepState.complete
                                : StepState.disabled,
                          ),
                          Step(
                            title: const Text(''),
                            content: Column(children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.shouldWeSend,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    "___________________________",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!.description,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _descriptionController.value.text,
                                  ),
                                  const SizedBox(
                                      height: 8), // Some vertical spacing
                                  Text(
                                    AppLocalizations.of(context)!.receiver,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_selectedHandler?.name ?? AppLocalizations.of(context)?.notReported}',
                                  ),
                                  const SizedBox(
                                      height: 8), // Some vertical spacing
                                  Text(
                                    AppLocalizations.of(context)!.bully,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                      '${_selectedBully?.name ?? AppLocalizations.of(context)?.notReported}'),

                                ],

                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: SizedBox(
                                  height: 40,
                                  width: 120,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Validate will return true if the form is valid, or false if
                                      // the form is invalid.
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      // Process data.
                                      _submitForm();
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.send,
                                    ),
                                  ),
                                ),
                              )
                            ]),
                            isActive: currentStep >= 4,
                            state: currentStep >= 4
                                ? StepState.complete
                                : StepState.disabled,
                          )
                        ],
                      ),
                    ));
              }
              return const Center(child: CircularProgressIndicator());
            })));
  }

  void _submitForm() async {
    // Defaults: if ID is not a positive integer, set it to null
    int authUserId = getAuth(context).user!.id;
    int? bullyId = int.tryParse(_bullyController.value.text) ?? -1;
    int? bulliedId = _selectedBully?.id ?? -1;
    print(_selectedBully?.id);
    int handlerId = _selectedHandler?.id ?? -1;

    // if 'bullied was me', set the current user as bullied
    if (!_bulliedWasNotMe) bulliedId = authUserId;

    await api
        .sendNewReport(Report(
      description: _descriptionController.value.text,
      reporterId: authUserId,
      bullyId: bullyId > 0 ? bullyId : null,
      bulliedId: bulliedId > 0 ? bulliedId : null,
      handlerId: handlerId > 0 ? handlerId : null,
      isAnonymous: _isAnonymous,
    ))
        .then((success) {
      if (success) {
        //RouteStateScope.of(context).go('/reports/sent');
        Navigator.pop(context, 'report_created');
      }
    });
  }

  User get dummyTeacher => User(
        id: -1,
        firstName: 'Kuka tahansa opettaja',
        lastName: '',
        email: '',
        emailVerified: true,
        role: UserRole.teacher,
      );
}
