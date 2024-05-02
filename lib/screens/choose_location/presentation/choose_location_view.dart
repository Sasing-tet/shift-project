import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:shift_project/constants/constants.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController textEditingController = TextEditingController();
  late PickerMapController controller = PickerMapController(
    initMapWithUserPosition: const UserTrackingOption(),
  );

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(textOnChanged);
  }

  void textOnChanged() {
    controller.setSearchableText(textEditingController.text);
  }

  @override
  void dispose() {
    textEditingController.removeListener(textOnChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPickerLocation(
      controller: controller,
      topWidgetPicker: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      PointerInterceptor(
                        child: TextButton(
                          style: TextButton.styleFrom(),
                          onPressed: () =>  Navigator.pop(context,GeoPoint(latitude: 0.0, longitude: 0.0)),
                          child: const Icon(
                            color: Colors.black,
                            Icons.arrow_back_ios,
                          ),
                        ),
                      ),
                      Expanded(
                        child: PointerInterceptor(
                          child: TextField(
                            controller: textEditingController,
                            onEditingComplete: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              suffix: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: textEditingController,
                                builder: (ctx, text, child) {
                                  if (text.text.isNotEmpty) {
                                    return child!;
                                  }
                                  return const SizedBox.shrink();
                                },
                                child: InkWell(
                                  focusNode: FocusNode(),
                                  onTap: () {
                                    textEditingController.clear();
                                    controller.setSearchableText("");
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              focusColor: Colors.black,
                              filled: true,
                              hintText: "search",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              fillColor: Colors.grey[300],
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const TopSearchWidget()
        ],
      ),
      bottomWidgetPicker: Positioned(
        bottom: 12,
        right: 8,
        child: PointerInterceptor(
          child: FloatingActionButton.extended(
            foregroundColor: Colors.white,
            backgroundColor: shiftBlue,
            onPressed: () async {
              GeoPoint p = await controller.selectAdvancedPositionPicker();
              // ignore: use_build_context_synchronously
              Navigator.pop(context, p);
            },
            label: Text(
              'GO',
              style: constTextTheme().headlineMedium,
            ),
            icon: const Icon(Icons.arrow_forward),
          ),
        ),
      ),
      pickerConfig: const CustomPickerLocationConfig(
        initZoom: 15,
      ),
    );
  }
}

class TopSearchWidget extends StatefulWidget {
  const TopSearchWidget({super.key});

  @override
  State<StatefulWidget> createState() => _TopSearchWidgetState();
}

class _TopSearchWidgetState extends State<TopSearchWidget> {
  late PickerMapController controller;
  ValueNotifier<GeoPoint?> notifierGeoPoint = ValueNotifier(null);
  ValueNotifier<bool> notifierAutoCompletion = ValueNotifier(false);

  late StreamController<List<SearchInfo>> streamSuggestion = StreamController();
  late Future<List<SearchInfo>> _futureSuggestionAddress;
  String oldText = "";
  Timer? _timerToStartSuggestionReq;
  final Key streamKey = const Key("streamAddressSug");

  @override
  void initState() {
    super.initState();
    controller = CustomPickerLocation.of(context);
    controller.searchableText.addListener(onSearchableTextChanged);
  }

  void onSearchableTextChanged() async {
    final v = controller.searchableText.value;
    if (v.length > 3 && oldText != v) {
      oldText = v;
      if (_timerToStartSuggestionReq != null &&
          _timerToStartSuggestionReq!.isActive) {
        _timerToStartSuggestionReq!.cancel();
      }
      _timerToStartSuggestionReq =
          Timer.periodic(const Duration(seconds: 3), (timer) async {
        await suggestionProcessing(v);
        timer.cancel();
      });
    }
    if (v.isEmpty) {
      await reInitStream();
    }
  }

  Future reInitStream() async {
    notifierAutoCompletion.value = false;
    await streamSuggestion.close();
    setState(() {
      streamSuggestion = StreamController();
    });
  }

  Future<void> suggestionProcessing(String addr) async {
    notifierAutoCompletion.value = true;
    _futureSuggestionAddress = addressSuggestion(
      addr,
      limitInformation: 5,
    );
    _futureSuggestionAddress.then((value) {
      streamSuggestion.sink.add(value);
    });
  }

  @override
  void dispose() {
    controller.searchableText.removeListener(onSearchableTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ValueListenableBuilder<bool>(
        valueListenable: notifierAutoCompletion,
        builder: (ctx, isVisible, child) {
          return AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            height: isVisible ? MediaQuery.of(context).size.height / 4 : 0,
            child: Card(
              color: Colors.white,
              child: child!,
            ),
          );
        },
        child: StreamBuilder<List<SearchInfo>>(
          stream: streamSuggestion.stream,
          key: streamKey,
          builder: (ctx, snap) {
            if (snap.hasData) {
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemExtent: 50.0,
                itemBuilder: (ctx, index) {
                  return PointerInterceptor(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: ListTile(
                          title: Text(
                            snap.data![index].address.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () async {
                            /// go to location selected by address
                            controller.goToLocation(
                              snap.data![index].point!,
                            );

                            /// hide suggestion card
                            notifierAutoCompletion.value = false;
                            await reInitStream();
                            // ignore: use_build_context_synchronously
                            FocusScope.of(context).requestFocus(
                              FocusNode(),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                itemCount: snap.data!.length,
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Card(
                color: Colors.white,
                elevation: 0,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
