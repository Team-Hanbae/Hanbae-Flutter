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

  String get appBarTitle {
    switch (widget.appBarMode) {
      case AppBarMode.builtin:
        return widget.jangdan.name;
      case AppBarMode.custom:
        return '${widget.jangdan.jangdanType.label} | ${widget.jangdan.name}';
      case AppBarMode.create:
        return '${widget.jangdan.jangdanType.label} 장단 만들기';
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
              final controller = TextEditingController(text: widget.jangdan.name);
              final result = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('장단 이름 저장'),
                    content: TextField(
                      controller: controller,
                      maxLength: 13,
                      decoration: InputDecoration(hintText: '장단 이름을 입력하세요'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, controller.text),
                        child: Text('저장'),
                      ),
                    ],
                  );
                },
              );

              if (result != null && result.trim().isNotEmpty) {
                final selectedJangdan = context.read<MetronomeBloc>().state.selectedJangdan;
                final updatedJangdan = selectedJangdan.copyWith(name: result.trim());
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: AppColors.backgroundPopupMenu,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'update',
                child: Text('장단 저장하기', style: AppTextStyles.bodyR),
              ),
              PopupMenuItem(
                value: 'save',
                child: Text('장단 내보내기', style: AppTextStyles.bodyR),
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
                  final updatedJangdan = context.read<MetronomeBloc>().state.selectedJangdan;
                  context.read<JangdanBloc>().add(UpdateJangdan(updatedJangdan.name, updatedJangdan));
                  break;
                case 'save':
                  final current = context.read<MetronomeBloc>().state.selectedJangdan;
                  final controller = TextEditingController(text: current.name);
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('장단 이름 저장'),
                          content: TextField(
                            controller: controller,
                            maxLength: 13,
                            decoration: InputDecoration(hintText: '장단 이름을 입력하세요'),
                          ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, controller.text),
                            child: Text('저장'),
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
                  final current = context.read<MetronomeBloc>().state.selectedJangdan;
                  final controller = TextEditingController(text: current.name);
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('장단 이름 변경'),
                        content: TextField(
                          controller: controller,
                          maxLength: 13,
                          decoration: InputDecoration(hintText: '새 장단 이름을 입력하세요'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, controller.text),
                            child: Text('변경'),
                          ),
                        ],
                      );
                    },
                  );
                  
                  if (result != null && result.trim().isNotEmpty && result.trim() != current.name) {
                    final updated = current.copyWith(name: result.trim());
                    context.read<JangdanBloc>().add(UpdateJangdan(current.name, updated));
                  }
                  break;
                case 'delete':
                  final selectedJangdan = context.read<MetronomeBloc>().state.selectedJangdan;
                  context.read<JangdanBloc>().add(DeleteJangdan(selectedJangdan.name));
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
              String newName = widget.jangdan.name;
              final controller = TextEditingController(text: newName);

              final result = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('장단 이름 저장'),
                    content: TextField(
                      controller: controller,
                      maxLength: 13,
                      decoration: InputDecoration(hintText: '장단 이름을 입력하세요'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, controller.text),
                        child: Text('저장'),
                      ),
                    ],
                  );
                },
              );

              if (result != null && result.trim().isNotEmpty) {
                final selectedJangdan = context.read<MetronomeBloc>().state.selectedJangdan;
                final updatedJangdan = selectedJangdan.copyWith(name: result.trim());
                context.read<JangdanBloc>().add(AddJangdan(updatedJangdan));
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: Text('저장'),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {

    // 화면 반짝임 기능
    return BlocListener<MetronomeBloc, MetronomeState>(
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
              appBar: AppBar(
                toolbarHeight: 44.0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.chevron_left),
                ),
                title: Text(
                  appBarTitle,
                  style: AppTextStyles.bodyR.copyWith(color: AppColors.textSecondary),
                ),
                centerTitle: true,
                actions: appBarActions,
              ),
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            BlocBuilder<MetronomeBloc, MetronomeState>(
                              builder: (context, state) => HanbaeBoard(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: MetronomeOptions(),
                            ),
                            BlocBuilder<MetronomeBloc, MetronomeState>(
                              builder: (context, state) => MetronomeControl(),
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
          // 화면반짝임 기능 컬러박스
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_showFlashOverlay,
              child: AnimatedOpacity(
                opacity: _showFlashOverlay ? 1.0 : 0.0,
                duration: _showFlashOverlay
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