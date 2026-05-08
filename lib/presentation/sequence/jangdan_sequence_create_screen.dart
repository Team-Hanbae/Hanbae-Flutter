import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hanbae/bloc/jangdan/jangdan_bloc.dart';
import 'package:hanbae/model/jangdan.dart';
import 'package:hanbae/model/jangdan_sequence.dart';
import 'package:hanbae/model/jangdan_type.dart';
import 'package:hanbae/presentation/home/metronome_jangdan_list_screen.dart';
import 'package:hanbae/theme/colors.dart';
import 'package:hanbae/theme/text_styles.dart';

class JangdanSequenceCreateScreen extends StatefulWidget {
  const JangdanSequenceCreateScreen({super.key});

  @override
  State<JangdanSequenceCreateScreen> createState() =>
      _JangdanSequenceCreateScreenState();
}

class _JangdanSequenceCreateScreenState
    extends State<JangdanSequenceCreateScreen> {
  final _nameController = TextEditingController();
  int _step = 0;
  final List<Jangdan> _selectedJangdans = [];
  final List<int> _repeatCounts = [];
  bool _awaitingSave = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _reset() {
    _nameController.clear();
    _step = 0;
    _selectedJangdans.clear();
    _repeatCounts.clear();
    _awaitingSave = false;
  }

  Future<void> _openPicker(List<Jangdan> jangdans) async {
    final picked = await showModalBottomSheet<List<Jangdan>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundMute,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _JangdanMultiPicker(jangdans: jangdans),
    );
    if (picked == null || picked.isEmpty) return;
    setState(() {
      _selectedJangdans.addAll(picked);
      _repeatCounts.addAll(List.filled(picked.length, 1));
    });
  }

  void _move(int from, int to) {
    if (to < 0 || to >= _selectedJangdans.length) return;
    setState(() {
      final jangdan = _selectedJangdans.removeAt(from);
      final repeat = _repeatCounts.removeAt(from);
      _selectedJangdans.insert(to, jangdan);
      _repeatCounts.insert(to, repeat);
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedJangdans.length < 2) return;
    final items = List.generate(
      _selectedJangdans.length,
      (index) => JangdanSequenceItem(
        order: index,
        repeatCount: _repeatCounts[index],
        jangdan: _selectedJangdans[index],
      ),
    );
    setState(() => _awaitingSave = true);
    context.read<JangdanBloc>().add(
      AddJangdanSequence(
        JangdanSequence(name: name, createdAt: DateTime.now(), items: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jangdanState = context.watch<JangdanBloc>().state;
    final jangdans =
        jangdanState is JangdanLoaded ? jangdanState.jangdans : <Jangdan>[];

    return BlocListener<JangdanBloc, JangdanState>(
      listener: (context, state) {
        if (!_awaitingSave) return;
        if (state is JangdanError) {
          setState(() => _awaitingSave = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.replaceFirst('Exception: ', '')),
            ),
          );
        } else if (state is JangdanLoaded) {
          _reset();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (_) => const MetronomeJangdanListScreen(initialTabIndex: 1),
            ),
            (route) => route.isFirst,
          );
        }
      },
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) _reset();
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundDefault,
          appBar: AppBar(
            toolbarHeight: 44,
            backgroundColor: AppColors.backgroundDefault,
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () {
                  _reset();
                  Navigator.pop(context);
                },
                child: Text(
                  '닫기',
                  style: AppTextStyles.bodyR.copyWith(
                    color: AppColors.labelPrimary,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProgressBar(step: _step),
                  const SizedBox(height: 32),
                  Expanded(child: _buildStep(jangdans)),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 60),
              child: _BottomActionButton(
                label: _step == 2 ? '저장하기' : '다음',
                enabled: _primaryEnabled,
                onPressed: _primaryAction,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _primaryEnabled {
    if (_step == 0) return _selectedJangdans.length >= 2;
    if (_step == 2) {
      return _nameController.text.trim().isNotEmpty &&
          _selectedJangdans.length >= 2 &&
          !_awaitingSave;
    }
    return true;
  }

  void _primaryAction() {
    if (_step < 2) {
      setState(() => _step += 1);
    } else {
      _save();
    }
  }

  Widget _buildStep(List<Jangdan> jangdans) {
    switch (_step) {
      case 0:
        return _SelectionStep(
          jangdans: jangdans,
          selectedJangdans: _selectedJangdans,
          onAdd: () => _openPicker(jangdans),
          onDelete: (index) {
            setState(() {
              _selectedJangdans.removeAt(index);
              _repeatCounts.removeAt(index);
            });
          },
          onReorder: _reorder,
        );
      case 1:
        return _RepeatStep(
          selectedJangdans: _selectedJangdans,
          repeatCounts: _repeatCounts,
          onChanged: (index, value) {
            setState(() => _repeatCounts[index] = value.clamp(1, 999));
          },
        );
      default:
        return _PreviewStep(
          nameController: _nameController,
          selectedJangdans: _selectedJangdans,
          repeatCounts: _repeatCounts,
          onNameChanged: () => setState(() {}),
        );
    }
  }

  void _reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    _move(oldIndex, newIndex);
  }
}

class _SelectionStep extends StatelessWidget {
  final List<Jangdan> jangdans;
  final List<Jangdan> selectedJangdans;
  final VoidCallback onAdd;
  final ValueChanged<int> onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _SelectionStep({
    required this.jangdans,
    required this.selectedJangdans,
    required this.onAdd,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(
          title: '연습할 장단을 선택하세요',
          description: '최소 2개 이상의 장단을 선택해주세요.\n장단은 ‘내가 저장한 장단’에서만 선택할 수 있습니다.',
        ),
        const SizedBox(height: 28),
        if (selectedJangdans.isEmpty)
          _AddJangdanButton(
            label: '장단 선택하기',
            emphasized: true,
            enabled: jangdans.isNotEmpty,
            onPressed: onAdd,
          )
        else ...[
          _ReorderableJangdanList(
            selectedJangdans: selectedJangdans,
            onDelete: onDelete,
            onReorder: onReorder,
          ),
          const SizedBox(height: 28),
          _AddJangdanButton(
            label: '장단 추가하기',
            enabled: jangdans.isNotEmpty,
            onPressed: onAdd,
          ),
        ],
      ],
    );
  }
}

class _RepeatStep extends StatelessWidget {
  final List<Jangdan> selectedJangdans;
  final List<int> repeatCounts;
  final void Function(int index, int value) onChanged;

  const _RepeatStep({
    required this.selectedJangdans,
    required this.repeatCounts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(title: '장단 반복 횟수를 정하세요'),
        const SizedBox(height: 28),
        _JangdanListFrame(
          children: List.generate(selectedJangdans.length, (index) {
            final count = repeatCounts[index];
            return _SequenceJangdanRow(
              jangdan: selectedJangdans[index],
              trailing: _RepeatStepper(
                value: count,
                onDecrease:
                    count <= 1 ? null : () => onChanged(index, count - 1),
                onIncrease: () => onChanged(index, count + 1),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PreviewStep extends StatelessWidget {
  final TextEditingController nameController;
  final List<Jangdan> selectedJangdans;
  final List<int> repeatCounts;
  final VoidCallback onNameChanged;

  const _PreviewStep({
    required this.nameController,
    required this.selectedJangdans,
    required this.repeatCounts,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeading(title: '설정한 순서와 횟수대로 재생돼요'),
        const SizedBox(height: 20),
        TextField(
          controller: nameController,
          maxLength: 10,
          onChanged: (_) => onNameChanged(),
          cursorColor: AppColors.brandNormal,
          style: AppTextStyles.bodyR.copyWith(color: AppColors.labelDefault),
          decoration: InputDecoration(
            counterText: '',
            hintText: '장단 모음집 이름',
            hintStyle: AppTextStyles.bodyR.copyWith(
              color: AppColors.labelTertiary,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.neutral11),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.brandHeavy),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _JangdanListFrame(
          children: List.generate(selectedJangdans.length, (index) {
            return _SequenceJangdanRow(
              jangdan: selectedJangdans[index],
              trailing: Text(
                '${repeatCounts[index]}회',
                style: AppTextStyles.bodyR.copyWith(
                  color: AppColors.labelDefault,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int step;
  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 2),
            decoration: BoxDecoration(
              color: index <= step ? AppColors.brandHeavy : AppColors.neutral9,
              borderRadius: BorderRadius.circular(500),
            ),
          ),
        );
      }),
    );
  }
}

class _StepHeading extends StatelessWidget {
  final String title;
  final String? description;

  const _StepHeading({required this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title2R.copyWith(
              color: const Color(0xFFF2F2F2),
              fontSize: 22,
              height: 28 / 22,
              letterSpacing: -0.4,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: AppTextStyles.calloutR.copyWith(
                color: AppColors.labelSecondary,
                fontSize: 16,
                height: 21 / 16,
                letterSpacing: -0.31,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddJangdanButton extends StatelessWidget {
  final String label;
  final bool emphasized;
  final bool enabled;
  final VoidCallback onPressed;

  const _AddJangdanButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? onPressed : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: emphasized ? AppColors.orange13 : AppColors.neutral11,
          borderRadius: BorderRadius.circular(12),
          border:
              emphasized
                  ? Border.all(color: AppColors.brandHeavy, width: 1)
                  : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySb.copyWith(
            color: enabled ? AppColors.labelPrimary : AppColors.labelTertiary,
            fontSize: 17,
            height: 22 / 17,
            letterSpacing: -0.43,
          ),
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _BottomActionButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 57,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor:
              enabled ? AppColors.brandHeavy : AppColors.buttonMute,
          disabledBackgroundColor: AppColors.buttonMute,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(
          label,
          style: AppTextStyles.title3Sb.copyWith(
            color: enabled ? AppColors.labelPrimary : AppColors.labelTertiary,
            fontSize: enabled ? 20 : 17,
            height: enabled ? 25 / 20 : 22 / 17,
            letterSpacing: enabled ? -0.4 : -0.43,
          ),
        ),
      ),
    );
  }
}

class _JangdanListFrame extends StatelessWidget {
  final List<Widget> children;

  const _JangdanListFrame({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.neutral11, width: 1)),
      ),
      child: Column(children: children),
    );
  }
}

class _ReorderableJangdanList extends StatelessWidget {
  final List<Jangdan> selectedJangdans;
  final ValueChanged<int> onDelete;
  final ReorderCallback onReorder;

  const _ReorderableJangdanList({
    required this.selectedJangdans,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.neutral11, width: 1)),
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        proxyDecorator: (child, index, animation) {
          return Material(
            color: AppColors.backgroundMute,
            elevation: 6,
            child: child,
          );
        },
        itemCount: selectedJangdans.length,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final jangdan = selectedJangdans[index];
          return _SequenceJangdanRow(
            key: ValueKey(
              '${jangdan.name}-${jangdan.createdAt.microsecondsSinceEpoch}-$index',
            ),
            jangdan: jangdan,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.labelSecondary,
                  iconSize: 24,
                  onPressed: () => onDelete(index),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.drag_handle,
                      color: AppColors.labelSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SequenceJangdanRow extends StatelessWidget {
  final Jangdan jangdan;
  final Widget trailing;

  const _SequenceJangdanRow({
    super.key,
    required this.jangdan,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.neutral11, width: 1),
        ),
      ),
      child: Row(
        children: [
          _JangdanSymbol(jangdanType: jangdan.jangdanType),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jangdan.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySb.copyWith(
                    color: AppColors.labelDefault,
                    fontSize: 17,
                    height: 22 / 17,
                    letterSpacing: -0.43,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  jangdan.jangdanType.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subheadlineR.copyWith(
                    color: AppColors.labelTertiary,
                    fontSize: 15,
                    height: 20 / 15,
                    letterSpacing: -0.23,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _JangdanSymbol extends StatelessWidget {
  final JangdanType jangdanType;

  const _JangdanSymbol({required this.jangdanType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.orange13,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: SvgPicture.asset(
            'assets/${jangdanType.logoAssetPath}',
            colorFilter: const ColorFilter.mode(
              AppColors.orange8,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _RepeatStepper extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  const _RepeatStepper({
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          color:
              onDecrease == null
                  ? AppColors.labelDisable
                  : AppColors.labelSecondary,
          onPressed: onDecrease,
        ),
        GestureDetector(
          onTap: onIncrease,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.labelTertiary, width: 1.5),
              ),
            ),
            child: Text(
              '$value회',
              style: AppTextStyles.bodyR.copyWith(
                color: AppColors.labelDefault,
                fontSize: 17,
                height: 22 / 17,
                letterSpacing: -0.43,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          color: AppColors.labelSecondary,
          onPressed: onIncrease,
        ),
      ],
    );
  }
}

class _JangdanMultiPicker extends StatefulWidget {
  final List<Jangdan> jangdans;
  const _JangdanMultiPicker({required this.jangdans});

  @override
  State<_JangdanMultiPicker> createState() => _JangdanMultiPickerState();
}

class _JangdanMultiPickerState extends State<_JangdanMultiPicker> {
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.82;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '내가 저장한 장단',
                      style: AppTextStyles.bodySb.copyWith(
                        color: AppColors.labelDefault,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '취소',
                      style: AppTextStyles.bodyR.copyWith(
                        color: AppColors.labelSecondary,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed:
                        _selected.isEmpty
                            ? null
                            : () {
                              Navigator.pop(
                                context,
                                _selected
                                    .map((index) => widget.jangdans[index])
                                    .toList(),
                              );
                            },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandHeavy,
                      disabledBackgroundColor: AppColors.buttonMute,
                      foregroundColor: AppColors.labelPrimary,
                      disabledForegroundColor: AppColors.labelTertiary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('완료'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.neutral11),
            Expanded(
              child: ListView.separated(
                itemCount: widget.jangdans.length,
                separatorBuilder:
                    (context, index) =>
                        const Divider(height: 1, color: AppColors.neutral11),
                itemBuilder: (context, index) {
                  final jangdan = widget.jangdans[index];
                  final selected = _selected.contains(index);
                  return CheckboxListTile(
                    value: selected,
                    activeColor: AppColors.brandHeavy,
                    checkColor: AppColors.labelPrimary,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    secondary: _JangdanSymbol(jangdanType: jangdan.jangdanType),
                    title: Text(
                      jangdan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySb.copyWith(
                        color: AppColors.labelDefault,
                      ),
                    ),
                    subtitle: Text(
                      jangdan.jangdanType.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subheadlineR.copyWith(
                        color: AppColors.labelTertiary,
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {
                        selected
                            ? _selected.remove(index)
                            : _selected.add(index);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
