import 'package:flutter/material.dart';

import 'motion_animated_builder.dart';
import 'motion_list_base.dart';

class MotionListImpl<E extends Object> extends MotionListBase<Widget, E> {
  const MotionListImpl({
    super.key,
    required super.items,
    required super.itemBuilder,
    super.enterTransition,
    super.exitTransition,
    super.insertDuration,
    super.removeDuration,
    super.onReorder,
    super.onReorderStart,
    super.onReorderEnd,
    super.proxyDecorator,
    required super.scrollDirection,
    super.insertItemBuilder,
    super.removeItemBuilder,
    super.buildDefaultDragHandles,
    super.useDefaultDragListeners = true,
    super.longPressDraggable,
    super.isSameItem,
  });

  const MotionListImpl.grid({
    super.key,
    required super.items,
    required super.itemBuilder,
    required SliverGridDelegate super.sliverGridDelegate,
    super.enterTransition,
    super.exitTransition,
    super.onReorder,
    super.onReorderStart,
    super.onReorderEnd,
    super.proxyDecorator,
    super.insertDuration,
    super.removeDuration,
    required super.scrollDirection,
    super.insertItemBuilder,
    super.removeItemBuilder,
    super.buildDefaultDragHandles,
    super.useDefaultDragListeners = true,
    super.longPressDraggable,
    super.isSameItem,
  });

  @override
  MotionListImplState<E> createState() => MotionListImplState<E>();
}

class MotionListImplState<E extends Object>
    extends MotionListBaseState<Widget, MotionListImpl<E>, E> {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasOverlay(context));
    return MotionBuilder(
      key: listKey,
      initialCount: oldList.length,
      onReorder: onReorder,
      onReorderStart: onReorderStart,
      onReorderEnd: onReorderEnd,
      proxyDecorator: proxyDecorator,
      insertAnimationBuilder: insertAnimationBuilder,
      removeAnimationBuilder: removeAnimationBuilder,
      itemBuilder: itemBuilder,
      scrollDirection: scrollDirection,
      delegateBuilder: sliverGridDelegate,
      buildDefaultDragHandles: buildDefaultDragHandles,
      longPressDraggable: longPressDraggable,
     useDefaultDragListeners: useDefaultDragListeners,
    );
  }
}
