import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanbae/bloc/jangdan/jangdan_bloc.dart';
import 'package:hanbae/data/jangdan_sequence_repository.dart';
import 'package:hanbae/model/jangdan.dart';
import 'package:hanbae/model/jangdan_sequence.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/presentation/metronome/hanbae_board.dart';
import 'package:hanbae/presentation/metronome/metronome_control.dart';
import 'package:hanbae/presentation/metronome/metronome_options.dart';
import 'package:hanbae/bloc/metronome/metronome_bloc.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';
import 'package:hanbae/utils/local_storage.dart';
import 'package:hanbae/presentation/metronome/metronome_onboarding_overlay.dart';

enum AppBarMode { builtin, custom, create, sequence }

class MetronomeScreen extends StatefulWidget {
  final Jangdan jangdan;
  final JangdanSequence? sequence;
  final AppBarMode appBarMode;
  final bool forceShowOnboarding;

  const MetronomeScreen({
    super.key,
    required this.jangdan,
    this.sequence,
    this.appBarMode = AppBarMode.builtin,
    this.forceShowOnboarding = false,
  });

  @override
  _MetronomeScreenState createState() => _MetronomeScreenState();
}

class _MetronomeScreenState extends State<MetronomeScreen> {
  bool _showFlashOverlay = false;
  bool _awaitingSave = false;
  bool _showOnboarding = false;
  int _onboardingStep = 0;

  @override
  void initState() {
    super.initState();
    if (widget.sequence != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MetronomeBloc>().add(SelectSequence(widget.sequence!));
        }
      });
    }
    if (widget.forceShowOnboarding) {
      _showOnboarding = true;
      _onboardingStep = 0;
    } else {
      _maybeShowOnboarding();
    }
  }

  Future<void> _maybeShowOnboarding() async {
    final seen = await Storage().getMetronomeOnboardingSeen();
    if (!seen && mounted) {
      setState(() {
        _showOnboarding = true;
        _onboardingStep = 0;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    await Storage().setMetronomeOnboardingSeen();
    if (!mounted) return;
    setState(() {
      _showOnboarding = false;
    });
  }

  void _nextOnboardingStep() {
    if (_onboardingStep >= 3) {
      _completeOnboarding();
      return;
    }
    setState(() {
      _onboardingStep += 1;
    });
  }

  @override
  void deactivate() {
    if (context.read<MetronomeBloc>().state.minimum) {
      context.read<MetronomeBloc>().add(const ToggleMinimum());
    }
    super.deactivate();
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
      case AppBarMode.sequence:
        return context.watch<MetronomeBloc>().state.currentSequence?.name ??
            widget.sequence?.name ??
            selected.name;
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
                              borderSide: BorderSide(
                                color: AppColors.brandNormal,
                              ),
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
                              borderSide: BorderSide(
                                color: AppColors.brandNormal,
                              ),
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
              style: AppTextStyles.bodyR.copyWith(
                color: AppColors.labelPrimary,
              ),
            ),
          ),
        ];
      case AppBarMode.sequence:
        return [
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: () {
              final current =
                  context.read<MetronomeBloc>().state.currentSequence ??
                  widget.sequence;
              if (current == null) return;
              final sequence =
                  JangdanSequenceRepository().get(current.name) ?? current;
              context.read<MetronomeBloc>().add(Stop());
              context.read<MetronomeBloc>().add(
                ReplaceCurrentSequence(sequence),
              );
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
                    child: Text('장단이름 변경하기', style: AppTextStyles.bodyR),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('장단 삭제하기', style: AppTextStyles.bodyR),
                  ),
                ],
            onSelected: _handleSequenceMenu,
          ),
        ];
    }
  }

  Future<void> _handleSequenceMenu(String value) async {
    final bloc = context.read<MetronomeBloc>();
    final current = bloc.state.currentSequence ?? widget.sequence;
    if (current == null) return;

    switch (value) {
      case 'update':
        context.read<JangdanBloc>().add(
          UpdateJangdanSequence(current.name, current),
        );
        break;
      case 'save':
      case 'rename':
        final controller = TextEditingController(
          text: value == 'rename' ? current.name : '',
        );
        final result = await showDialog<String>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: AppColors.backgroundElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  value == 'rename' ? '장단이름 변경하기' : '다른 이름으로 저장',
                  style: TextStyle(color: AppColors.labelPrimary),
                ),
                content: TextField(
                  controller: controller,
                  maxLength: 10,
                  autofocus: true,
                  cursorColor: AppColors.brandNormal,
                  decoration: const InputDecoration(hintText: '장단 이름을 입력하세요'),
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
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: Text(
                      value == 'rename' ? '변경' : '저장',
                      style: TextStyle(color: AppColors.brandNormal),
                    ),
                  ),
                ],
              ),
        );
        if (result == null || result.trim().isEmpty) return;
        final renamed = current.copyWith(name: result.trim());
        if (value == 'rename') {
          context.read<JangdanBloc>().add(
            UpdateJangdanSequence(current.name, renamed),
          );
        } else {
          context.read<JangdanBloc>().add(
            AddJangdanSequence(renamed.copyWith(createdAt: DateTime.now())),
          );
        }
        bloc.add(ReplaceCurrentSequence(renamed));
        break;
      case 'delete':
        context.read<JangdanBloc>().add(DeleteJangdanSequence(current.name));
        bloc.add(Stop());
        Navigator.pop(context);
        break;
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
                context.read<JangdanBloc>().add(LoadJangdan());
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
                                builder:
                                    (context, state) => HanbaeBoard(
                                      header:
                                          widget.appBarMode ==
                                                  AppBarMode.sequence
                                              ? _SequenceStateBar()
                                              : null,
                                    ),
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
                                  return MetronomeControl(
                                    iconSize: iconSize,
                                    appBarMode: widget.appBarMode,
                                  );
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
          if (_showOnboarding)
            MetronomeOnboardingOverlay(
              step: _onboardingStep,
              onNext: _nextOnboardingStep,
              onSkip: _completeOnboarding,
            ),
        ],
      ),
    );
  }
}

class _SequenceStateBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<MetronomeBloc>().state;
    final sequence = state.currentSequence;
    if (sequence == null || sequence.items.isEmpty) {
      return const SizedBox.shrink();
    }
    final item = sequence.items[state.currentSequenceIndex];
    final repeatLabel =
        state.isPlaying ? state.currentSequenceRepeat.toString() : '0';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _showSequenceSheet(context, sequence),
        child: Container(
          width: double.infinity,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.playlist_play_rounded,
                color: AppColors.labelDefault,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.jangdan.jangdanType.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subheadlineR.copyWith(
                    color: AppColors.labelDefault,
                    fontSize: 15,
                    height: 20 / 15,
                    letterSpacing: -0.23,
                  ),
                ),
              ),
              Text(
                '$repeatLabel/${item.repeatCount}',
                style: AppTextStyles.subheadlineR.copyWith(
                  color: AppColors.labelDefault,
                  fontSize: 15,
                  height: 20 / 15,
                  letterSpacing: -0.23,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSequenceSheet(BuildContext context, JangdanSequence sequence) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sequence.items.length,
            itemBuilder: (context, index) {
              final item = sequence.items[index];
              return ListTile(
                title: Text(item.jangdan.name, style: AppTextStyles.bodySb),
                subtitle: Text(
                  '${item.jangdan.jangdanType.label} · ${item.repeatCount}회',
                ),
                onTap: () {
                  sheetContext.read<MetronomeBloc>().add(
                    JumpToSequenceItem(index),
                  );
                  Navigator.pop(sheetContext);
                },
              );
            },
          ),
        );
      },
    );
  }
}
