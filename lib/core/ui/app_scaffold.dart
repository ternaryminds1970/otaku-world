
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:otaku_world/bloc/bottom_nav_bar/bottom_nav_bar_cubit.dart';
import 'package:otaku_world/generated/assets.dart';
import 'package:otaku_world/theme/colors.dart';

import 'appbars/main_app_bar.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  var _isBottomBarVisible = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BottomNavBarCubit, BottomNavBarState>(
      listener: (context, state) {
        if (state is BottomNavBarVisible) {
          setState(() {
            _isBottomBarVisible = true;
          });
        } else if (state is BottomNavBarNotVisible) {
          setState(() {
            _isBottomBarVisible = false;
          });
        }
      },
      child: DoubleBack(
        message: 'Press back again to exit!',
        child: Scaffold(
          appBar: const MainAppBar(),
          body: widget.navigationShell,
          bottomNavigationBar: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeIn,
            height: _isBottomBarVisible ? 75 : 0,
            child: Wrap(
              children: [
                SizedBox(
                  height: 75,
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    showUnselectedLabels: true,
                    currentIndex: widget.navigationShell.currentIndex,
                    onTap: _goBranch,
                    items: [
                      _buildBottomNavBarItem(
                        label: 'Home',
                        icon: Assets.iconsHome,
                      ),
                      _buildBottomNavBarItem(
                        label: 'Discover',
                        icon: Assets.iconsSearch,
                      ),
                      _buildBottomNavBarItem(
                        label: 'Social',
                        icon: Assets.iconsUserGroup,
                      ),
                      _buildBottomNavBarItem(
                        label: 'My List',
                        icon: Assets.iconsBulletList,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavBarItem({
    required String label,
    required String icon,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: SvgPicture.asset(
          icon,
          color: AppColors.white,
        ),
      ),
      label: label,
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: SvgPicture.asset(
          icon,
          color: AppColors.sunsetOrange,
        ),
      ),
    );
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
