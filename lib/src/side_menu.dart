import 'package:easy_sidemenu/src/global/global.dart';
import 'package:easy_sidemenu/src/side_menu_display_mode.dart';
import 'package:easy_sidemenu/src/side_menu_item.dart';
import 'package:easy_sidemenu/src/side_menu_style.dart';
import 'package:easy_sidemenu/src/side_menu_toggle.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  /// Page controller to control [PageView] widget
  final PageController controller;

  /// List of [SideMenuItem] to show them on [SideMenu]
  final List<SideMenuItem> items;

  /// Title widget will shows on top of all items,
  /// it can be a logo or a Title text
  final Widget? title;

  /// Footer widget will show on bottom of [SideMenu]
  /// when [displayMode] was SideMenuDisplayMode.open
  final Widget? footer;

  /// [SideMenu] can be configured by this
  final SideMenuStyle? style;

  /// Show toggle button to switch between open and compact display mode
  /// If the display mode is auto, this button will not be displayed
  final bool? showToggle;

  /// Notify when [SideMenuDisplayMode] changed
  final ValueChanged<SideMenuDisplayMode>? onDisplayModeChanged;

  /// ### Easy Sidemenu widget
  ///
  /// Sidemenu is a menu that is usually located
  /// on the left or right of the page and can used for navigation
  const SideMenu({
    Key? key,
    required this.items,
    required this.controller,
    this.title,
    this.footer,
    this.style,
    this.showToggle,
    this.onDisplayModeChanged,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  double _currentWidth = 220;
  late bool showToggle;

  @override
  void initState() {
    super.initState();
    showToggle = widget.showToggle ?? false;
  }

  void _notifyParent() {
    if (widget.onDisplayModeChanged != null) {
      widget.onDisplayModeChanged!(Global.displayModeState.value);
    }
  }

  /// Set [SideMenu] width according to displayMode and notify parent widget
  double _widthSize(SideMenuDisplayMode mode, BuildContext context) {
    if (mode == SideMenuDisplayMode.auto) {
      if (MediaQuery
          .of(context)
          .size
          .width > 600 &&
          Global.displayModeState.value != SideMenuDisplayMode.open) {
        Global.displayModeState.change(SideMenuDisplayMode.open);
        _notifyParent();
        return Global.style.openSideMenuWidth ?? 300;
      }
      if (MediaQuery
          .of(context)
          .size
          .width <= 600 &&
          Global.displayModeState.value != SideMenuDisplayMode.compact) {
        Global.displayModeState.change(SideMenuDisplayMode.compact);
        _notifyParent();
        return Global.style.compactSideMenuWidth ?? 50;
      }
      return _currentWidth;
    } else if (mode == SideMenuDisplayMode.open &&
        Global.displayModeState.value != SideMenuDisplayMode.open) {
      Global.displayModeState.change(SideMenuDisplayMode.open);
      _notifyParent();
      return Global.style.openSideMenuWidth ?? 300;
    }
    if (mode == SideMenuDisplayMode.compact &&
        Global.displayModeState.value != SideMenuDisplayMode.compact) {
      Global.displayModeState.change(SideMenuDisplayMode.compact);
      _notifyParent();
      return Global.style.compactSideMenuWidth ?? 50;
    }
    return _currentWidth;
  }

  Decoration _decoration(SideMenuStyle? menuStyle) {
    if (menuStyle == null || menuStyle.decoration == null) {
      return BoxDecoration(
        color: Global.style.backgroundColor,
      );
    } else {
      if (menuStyle.backgroundColor != null) {
        menuStyle.decoration =
            menuStyle.decoration!.copyWith(color: menuStyle.backgroundColor);
      }
      return menuStyle.decoration!;
    }
  }

  @override
  Widget build(BuildContext context) {
    Global.controller = widget.controller;
    widget.items.sort((a, b) => a.priority.compareTo(b.priority));
    Global.style = widget.style ?? SideMenuStyle();
    _currentWidth = _widthSize(
        Global.style.displayMode ?? SideMenuDisplayMode.auto, context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: _currentWidth,
      height: MediaQuery
          .of(context)
          .size
          .height,
      decoration: _decoration(widget.style),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // if (Global.style.displayMode == SideMenuDisplayMode.compact &&
                //     showToggle)
                (widget.title != null && Global.displayModeState.value ==
                    SideMenuDisplayMode.open) ? SizedBox(
                  height: 13.5,
                ) : SizedBox(
                  height: 18.5,
                ),
                Row(
                  children: [
                    if (widget.title != null && Global.displayModeState.value ==
                        SideMenuDisplayMode.open)
                      Expanded(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                                padding: EdgeInsets.only(left: 15),
                                child: widget.title!)
                        ),
                      ),
                    Expanded(
                      child: Align(alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                Global.displayModeState.value ==
                                    SideMenuDisplayMode.open
                                    ? 0
                                    : 4,
                                vertical: 0),
                            child: SideMenuToggle(
                              onTap: () {
                                if (showToggle) {
                                  if (Global.displayModeState.value ==
                                      SideMenuDisplayMode.compact) {
                                    setState(() {
                                      Global.style.displayMode =
                                          SideMenuDisplayMode.open;
                                    });
                                  } else if (Global.displayModeState.value ==
                                      SideMenuDisplayMode.open) {
                                    setState(() {
                                      Global.style.displayMode =
                                          SideMenuDisplayMode.compact;
                                    });
                                  }
                                }
                              },
                            ),
                          )),
                    )
                  ],
                ),
                (widget.title != null && Global.displayModeState.value ==
                    SideMenuDisplayMode.open) ? SizedBox(
                  height: 13.5,
                ) : SizedBox(
                  height: 18.5,
                ),
                Divider(height: 1,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.5)),
                const SizedBox(
                  height: 16,
                ),
                ...widget.items,
              ],
            ),
          ),
          if (widget.footer != null &&
              Global.displayModeState.value != SideMenuDisplayMode.compact)
            Align(alignment: Alignment.bottomCenter, child: widget.footer!),
          // if (Global.style.displayMode != SideMenuDisplayMode.auto &&
          //     showToggle)

        ],
      ),
    );
  }
}
