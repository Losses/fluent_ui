import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowResizeRegion extends StatelessWidget {
  const WindowResizeRegion({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (!Platform.isMacOS) ..._buildNonMacOSResizeHandles(),
      ],
    );
  }

  List<Widget> _buildNonMacOSResizeHandles() {
    return [
      const _ResizeHandle(
        alignment: _ResizeHandleAlignment.topLeft,
        cursor: SystemMouseCursors.resizeUpLeft,
        resizeEdge: ResizeEdge.topLeft,
      ),
      const _ResizeHandle(
        alignment: _ResizeHandleAlignment.topRight,
        cursor: SystemMouseCursors.resizeUpRight,
        resizeEdge: ResizeEdge.topRight,
      ),
      const _ResizeHandle(
        alignment: _ResizeHandleAlignment.bottomLeft,
        cursor: SystemMouseCursors.resizeDownLeft,
        resizeEdge: ResizeEdge.bottomLeft,
      ),
      const _ResizeHandle(
        alignment: _ResizeHandleAlignment.bottomRight,
        cursor: SystemMouseCursors.resizeDownRight,
        resizeEdge: ResizeEdge.bottomRight,
      ),
      const _ResizeHandle(
        alignment: _ResizeHandleAlignment.top,
        cursor: SystemMouseCursors.resizeUp,
        resizeEdge: ResizeEdge.top,
      ),
      const _ResizeHandle(
        alignment: _ResizeHandleAlignment.bottom,
        cursor: SystemMouseCursors.resizeDown,
        resizeEdge: ResizeEdge.bottom,
      ),
      const _ResizeHandle(
        alignment: _ResizeHandleAlignment.left,
        cursor: SystemMouseCursors.resizeLeft,
        resizeEdge: ResizeEdge.left,
      ),
      const _ResizeHandle(
        alignment: _ResizeHandleAlignment.right,
        cursor: SystemMouseCursors.resizeRight,
        resizeEdge: ResizeEdge.right,
      ),
    ];
  }
}

enum _ResizeHandleAlignment {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({
    required this.alignment,
    required this.cursor,
    required this.resizeEdge,
  });

  final _ResizeHandleAlignment alignment;
  final MouseCursor cursor;
  final ResizeEdge resizeEdge;

  static const double _handleSize = 8.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _getLeft(),
      top: _getTop(),
      right: _getRight(),
      bottom: _getBottom(),
      width: _getWidth(),
      height: _getHeight(),
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onPanStart: (_) => windowManager.startResizing(resizeEdge),
        ),
      ),
    );
  }

  double? _getLeft() {
    switch (alignment) {
      case _ResizeHandleAlignment.topLeft:
      case _ResizeHandleAlignment.bottomLeft:
      case _ResizeHandleAlignment.left:
        return 0.0;
      case _ResizeHandleAlignment.top:
      case _ResizeHandleAlignment.bottom:
        return _handleSize;
      case _ResizeHandleAlignment.topRight:
      case _ResizeHandleAlignment.bottomRight:
      case _ResizeHandleAlignment.right:
        return null;
    }
  }

  double? _getTop() {
    switch (alignment) {
      case _ResizeHandleAlignment.topLeft:
      case _ResizeHandleAlignment.topRight:
      case _ResizeHandleAlignment.top:
        return 0.0;
      case _ResizeHandleAlignment.left:
      case _ResizeHandleAlignment.right:
        return _handleSize;
      case _ResizeHandleAlignment.bottomLeft:
      case _ResizeHandleAlignment.bottomRight:
      case _ResizeHandleAlignment.bottom:
        return null;
    }
  }

  double? _getRight() {
    switch (alignment) {
      case _ResizeHandleAlignment.topRight:
      case _ResizeHandleAlignment.bottomRight:
      case _ResizeHandleAlignment.right:
        return 0.0;
      case _ResizeHandleAlignment.top:
      case _ResizeHandleAlignment.bottom:
        return _handleSize;
      case _ResizeHandleAlignment.topLeft:
      case _ResizeHandleAlignment.bottomLeft:
      case _ResizeHandleAlignment.left:
        return null;
    }
  }

  double? _getBottom() {
    switch (alignment) {
      case _ResizeHandleAlignment.bottomLeft:
      case _ResizeHandleAlignment.bottomRight:
      case _ResizeHandleAlignment.bottom:
        return 0.0;
      case _ResizeHandleAlignment.left:
      case _ResizeHandleAlignment.right:
        return _handleSize;
      case _ResizeHandleAlignment.topLeft:
      case _ResizeHandleAlignment.topRight:
      case _ResizeHandleAlignment.top:
        return null;
    }
  }

  double? _getWidth() {
    switch (alignment) {
      case _ResizeHandleAlignment.left:
      case _ResizeHandleAlignment.right:
        return _handleSize;
      case _ResizeHandleAlignment.top:
      case _ResizeHandleAlignment.bottom:
        return null;
      case _ResizeHandleAlignment.topLeft:
      case _ResizeHandleAlignment.topRight:
      case _ResizeHandleAlignment.bottomLeft:
      case _ResizeHandleAlignment.bottomRight:
        return _handleSize;
    }
  }

  double? _getHeight() {
    switch (alignment) {
      case _ResizeHandleAlignment.top:
      case _ResizeHandleAlignment.bottom:
        return _handleSize;
      case _ResizeHandleAlignment.left:
      case _ResizeHandleAlignment.right:
        return null;
      case _ResizeHandleAlignment.topLeft:
      case _ResizeHandleAlignment.topRight:
      case _ResizeHandleAlignment.bottomLeft:
      case _ResizeHandleAlignment.bottomRight:
        return _handleSize;
    }
  }
}
