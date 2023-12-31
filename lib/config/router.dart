import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:otaku_world/bloc/auth/auth_cubit.dart';
import 'package:otaku_world/bloc/routes/redirect_route_cubit.dart';
import 'package:otaku_world/core/routes/slide_transition_route.dart';
import 'package:otaku_world/features/anime_lists/recommended_anime_screen.dart';
import 'package:otaku_world/features/auth/screens/login_screen.dart';
import 'package:otaku_world/features/home/screens/home_screen.dart';
import 'package:otaku_world/features/reviews/screens/review_detail_screen.dart';
import 'package:otaku_world/features/reviews/screens/review_screen.dart';
import 'package:otaku_world/features/splash/screens/splash_screen.dart';
import 'package:otaku_world/observers/go_route_observer.dart';
import '../core/ui/app_scaffold.dart';
import '../features/anime_lists/recommended_manga_screen.dart';
import '../features/anime_lists/trending_anime_screen.dart';
import '../features/anime_lists/trending_manga_screen.dart';
import '../features/discover/screens/discover_screen.dart';
import '../features/my_list/screens/my_list_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/social/screens/social_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  observers: [CustomRouteObserver()],
  routes: [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          parentNavigatorKey: _shellNavigatorKey,
          path: '/home',

          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: HomeScreen(),
            );
          },
          routes: [
            SlideTransitionRoute(
              path: 'reviews',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (state) => const ReviewScreen(),
              directionTween: SlideTransitionRoute.leftToRightTween,
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'trending_anime',
              builder: (context, state) => const TrendingAnimeScreen(),
            ),GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'recommended_anime',
              builder: (context, state) => const RecommendedAnimeScreen(),
            ),GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'trending_manga',
              builder: (context, state) => const TrendingMangaScreen(),
            ),GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'recommended_manga',
              builder: (context, state) => const RecommendedMangaScreen(),
            ),
          ]
        ),
        GoRoute(
          parentNavigatorKey: _shellNavigatorKey,
          path: '/discover',
          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: DiscoverScreen(),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: _shellNavigatorKey,
          path: '/social',
          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: SocialScreen(),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: _shellNavigatorKey,
          path: '/my-list',
          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: MyListScreen(),
            );
          },
        ),
      ],
    ),
    SlideTransitionRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/review-detail',
      builder: (state) {
        return ReviewDetailScreen(
          reviewId: int.parse(
            state.queryParameters['id']!,
          ),
        );
      },
      directionTween: SlideTransitionRoute.leftToRightTween,
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/on-boarding',
      builder: (context, state) => const OnBoardingScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
  redirect: (context, state) {
    dev.log('Matched location: ${state.matchedLocation}',
        name: 'RouterRedirect');
    if (state.matchedLocation == '/') return null;

    final authState = context.read<AuthCubit>().state;
    final routeCubit = context.read<RedirectRouteCubit>();

    if (authState is UnAuthenticated) {
      if ((!routeCubit.isDesiredRouteSet() &&
              state.matchedLocation != '/login') ||
          (state.matchedLocation != '/home' &&
              state.matchedLocation != '/login')) {
        routeCubit.setDesiredRoute(
          state.matchedLocation,
          state.queryParameters,
        );
      }
      return '/login';
    } else {
      if (state.matchedLocation == '/home' && routeCubit.isDesiredRouteSet()) {
        final route = routeCubit.getDesiredRoute();
        routeCubit.resetDesiredRoute();
        dev.log('Going to desired route: $route', name: 'RouterRedirect');
        return route;
      } else {
        return null;
      }
    }
  },
);
