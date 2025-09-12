import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/bloc/jangdan/jangdan_bloc.dart';
import 'package:hanbae/model/jangdan.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/presentation/metronome/hanbae_board.dart';
import 'package:hanbae/presentation/metronome/metronome_control.dart';
import 'package:hanbae/presentation/metronome/metronome_options.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:hanbae/utils/dialog.dart';
import 'package:hanbae/utils/local_storage.dart';

enum AppBarMode { builtin, custom, create }

class MetronomeScreen extends StatefulWidget {
  final Jangdan jangdan;
  final AppBarMode appBarMode;

  const MetronomeScreen({
    super.key,
    required this.jangdan,
    this.appBarMode = AppBarMode.builtin,
  });

  @override
  _MetronomeScreenState createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  bool _showFlashOverlay = false;
  bool _awaitingSave = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstUserDialog();
    });
  }

  @override
  void deactivate() {
    if (context.read<MetronomeBloc>().state.minimum)
      context.read<MetronomeBloc>().add(const ToggleMinimum());
    super.deactivate();
  }

  void firstUserDialog() async {
    final bool result = await Storage().getFirstUserCheck();
    if (!result) {
      CommonDialog().firstShowDialog(context);
    }
  }

  String get appBarTitle {
    final selected = context.watch<MetronomeBloc>().state.selectedJangdan;
    switch (widget.appBarMode) {
      case AppBarMode.builtin:
        return selected.name;
      case AppBarMode.custom:
        return '${selected.jangdanType.label} | ${selected.name}';
      case AppBarMode.create:
        return '${selected.jangdanType.label} 장단 만들기';
    }
  }

  List<Widget> get appBarActions {
    switch (widget.appBarMode) {
      case AppBarMode.builtin:
        return [
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: () {
              context.read<MetronomeBloc>().add(const ResetMetronome());
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              final controller = TextEditingController(text: '');
              final result = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColors.backgroundElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      '나만의 장단 저장',
                      style: TextStyle(color: AppColors.labelPrimary),
                    ),
                    content: TextField(
                      controller: controller,
                      maxLength: 10,
                      autofocus: true,
                      cursorColor: AppColors.brandNormal,
                      decoration: InputDecoration(
                        hintText: '장단 이름을 입력하세요',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.brandNormal),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '취소',
                          style: TextStyle(color: AppColors.labelSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pop(context, controller.text),
                        child: Text(
                          '저장',
                          style: TextStyle(color: AppColors.brandNormal),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (result != null && result.trim().isNotEmpty) {
                final selectedJangdan =
                    context.read<MetronomeBloc>().state.selectedJangdan;
                final updatedJangdan = selectedJangdan.copyWith(
                  name: result.trim(),
                );
                context.read<JangdanBloc>().add(AddJangdan(updatedJangdan));
              }
            },
          ),
        ];
      case AppBarMode.custom:
        return [
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: () {
              context.read<MetronomeBloc>().add(const ResetMetronome());
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.pending_outlined),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.backgroundElevated,
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'update',
                    child: Text('변경사항 저장하기', style: AppTextStyles.bodyR),
                  ),
                  PopupMenuItem(
                    value: 'save',
                    child: Text('다른 이름으로 저장', style: AppTextStyles.bodyR),
                  ),
                  PopupMenuItem(
                    value: 'rename',
                    child: Text('장단 이름 변경하기', style: AppTextStyles.bodyR),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('장단 삭제하기', style: AppTextStyles.bodyR),
                  ),
                ],
            onSelected: (value) async {
              switch (value) {
                case 'update':
                  final updatedJangdan =
                      context.read<MetronomeBloc>().state.selectedJangdan;
                  context.read<JangdanBloc>().add(
                    UpdateJangdan(updatedJangdan.name, updatedJangdan),
                  );
                  break;
                case 'save':
                  final current =
                      context.read<MetronomeBloc>().state.selectedJangdan;
                  final controller = TextEditingController(text: '');
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: AppColors.backgroundElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          '다른 이름으로 저장',
                          style: TextStyle(color: AppColors.labelPrimary),
                        ),
                        content: TextField(
                          controller: controller,
                          maxLength: 10,
                          autofocus: true,
                          cursorColor: AppColors.brandNormal,
                          decoration: InputDecoration(
                            hintText: '장단 이름을 입력하세요',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.brandNormal),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              '취소',
                              style: TextStyle(color: AppColors.labelSecondary),
                            ),
                          ),
                          TextButton(
                            onPressed:
                                () => Navigator.pop(context, controller.text),
                            child: Text(
                              '저장',
                              style: TextStyle(color: AppColors.brandNormal),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (result != null && result.trim().isNotEmpty) {
                    final duplicated = current.copyWith(name: result.trim());
                    context.read<JangdanBloc>().add(AddJangdan(duplicated));
                  }
                  break;
                case 'rename':
                  final current =
                      context.read<MetronomeBloc>().state.selectedJangdan;
                  final controller = TextEditingController(text: current.name);
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: AppColors.backgroundElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          '장단 이름 변경',
                          style: TextStyle(color: AppColors.labelPrimary),
                        ),
                        content: TextField(
                          controller: controller,
                          maxLength: 10,
                          autofocus: true,
                          cursorColor: AppColors.brandNormal,
                          decoration: InputDecoration(
                            hintText: '새 장단 이름을 입력하세요',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.brandNormal),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              '취소',
                              style: TextStyle(color: AppColors.labelSecondary),
                            ),
                          ),
                          TextButton(
                            onPressed:
                                () => Navigator.pop(context, controller.text),
                            child: Text(
                              '변경',
                              style: TextStyle(color: AppColors.brandNormal),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (result != null &&
                      result.trim().isNotEmpty &&
                      result.trim() != current.name) {
                    final updated = current.copyWith(name: result.trim());
                    context.read<JangdanBloc>().add(AddJangdan(updated));
                    context.read<MetronomeBloc>().add(SelectJangdan(updated));
                    context.read<JangdanBloc>().add(
                      DeleteJangdan(current.name),
                    );
                  }
                  break;
                case 'delete':
                  final selectedJangdan =
                      context.read<MetronomeBloc>().state.selectedJangdan;
                  context.read<JangdanBloc>().add(
                    DeleteJangdan(selectedJangdan.name),
                  );
                  Navigator.pop(context);
                  break;
              }
            },
          ),
        ];
      case AppBarMode.create:
        return [
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: () {
              context.read<MetronomeBloc>().add(const ResetMetronome());
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              minimumSize: Size(40, 40),
            ),
            onPressed: () async {
              final controller = TextEditingController(text: '');

              final result = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColors.backgroundElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      '나만의 장단 저장',
                      style: TextStyle(color: AppColors.labelPrimary),
                    ),
                    content: TextField(
                      controller: controller,
                      maxLength: 10,
                      autofocus: true,
                      cursorColor: AppColors.brandNormal,
                      decoration: InputDecoration(
                        hintText: '장단 이름을 입력하세요',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.brandNormal),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '취소',
                          style: TextStyle(color: AppColors.labelSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pop(context, controller.text),
                        child: Text(
                          '저장',
                          style: TextStyle(color: AppColors.brandNormal),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (result != null && result.trim().isNotEmpty) {
                final selectedJangdan =
                    context.read<MetronomeBloc>().state.selectedJangdan;
                final updatedJangdan = selectedJangdan.copyWith(
                  name: result.trim(),
                );
                setState(() {
                  _awaitingSave = true;
                });
                context.read<JangdanBloc>().add(AddJangdan(updatedJangdan));
              }
            },
            child: Text(
              '저장',
              style: AppTextStyles.bodyR.copyWith(color: AppColors.labelPrimary),
            ),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // 화면 반짝임 기능
    return MultiBlocListener(
      listeners: [
        BlocListener<MetronomeBloc, MetronomeState>(
          listener: (context, state) {
            if (state.isFlashOn &&
                state.isPlaying &&
                state.currentRowIndex == 0 &&
                state.currentDaebakIndex == 0 &&
                state.currentSobakIndex == 0) {
              setState(() => _showFlashOverlay = true);
              Future.delayed(const Duration(milliseconds: 100), () {
                setState(() => _showFlashOverlay = false);
              });
            }
          },
        ),
        BlocListener<JangdanBloc, JangdanState>(
          listener: (context, state) {
            if (state is JangdanError) {
              setState(() {
                _awaitingSave = false;
              });
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      backgroundColor: AppColors.backgroundElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        '저장 실패',
                        style: TextStyle(color: AppColors.labelPrimary),
                      ),
                      content: Text(
                        '이미 등록된 장단 이름입니다.\n다른 이름으로 다시 시도해주세요.',
                        style: TextStyle(color: AppColors.labelSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            '확인',
                            style: TextStyle(color: AppColors.labelPrimary),
                          ),
                        ),
                      ],
                    ),
              );
              context.read<JangdanBloc>().add(LoadJangdan());
            } else if (state is JangdanLoaded && _awaitingSave) {
              setState(() {
                _awaitingSave = false;
              });
              Navigator.pop(context);
              Navigator.pop(context);
            }
          },
        ),
      ],
      child: Stack(
        children: [
          PopScope(
            canPop: true,
            onPopInvokedWithResult: (bool didPop, result) async {
              if (didPop == true) {
                context.read<MetronomeBloc>().add(Stop());
              }
            },

            // 메트로놈 스크린 시작
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                toolbarHeight: 44.0,
                title: Text(
                  appBarTitle,
                  style: AppTextStyles.bodyR.copyWith(
                    color: AppColors.labelDefault,
                  ),
                ),
                centerTitle: true,
                actions: appBarActions,
              ),
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              BlocBuilder<MetronomeBloc, MetronomeState>(
                                builder: (context, state) => HanbaeBoard(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: MetronomeOptions(),
                              ),
                              BlocBuilder<MetronomeBloc, MetronomeState>(
                                builder: (context, state) {
                                  double iconSize =
                                      context
                                              .read<MetronomeBloc>()
                                              .state
                                              .minimum
                                          ? 16
                                          : 32;
                                  return MetronomeControl(iconSize: iconSize);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // 화면반짝임 기능 컬러박스
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_showFlashOverlay,
              child: AnimatedOpacity(
                opacity: _showFlashOverlay ? 1.0 : 0.0,
                duration:
                    _showFlashOverlay
                        ? Duration.zero
                        : const Duration(milliseconds: 300),
                curve: Curves.linear,
                child: Container(color: AppColors.blink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
