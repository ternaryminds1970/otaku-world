import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otaku_world/features/anime_lists/recommended_anime_screen.dart';
import 'package:otaku_world/features/auth/screens/login_screen.dart';
import 'package:otaku_world/features/home/screens/home_screen.dart';
import 'package:otaku_world/features/reviews/screens/review_detail_screen.dart';
import 'package:otaku_world/features/reviews/screens/review_screen.dart';
import 'package:otaku_world/features/splash/screens/splash_screen.dart';
import 'package:otaku_world/graphql/__generated/graphql/fragments.graphql.dart';
import 'package:otaku_world/observers/go_route_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  // initialLocation: '/splash',
  navigatorKey: _rootNavigatorKey,
  observers: [CustomRouteObserver()],
  routes: [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/review-detail',
      builder: (context, state) => ReviewDetailScreen(
        review: state.extra! as Fragment$Review,
      ),
    ),
    GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/reviews',
        builder: (context, state) => const ReviewScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/on_boarding',
      builder: (context, state) => const OnBoardingScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      builder: (context, state) => const LoginScreen(),
      redirect: (context, state) async {
        final sharedPref = await SharedPreferences.getInstance();
        final isFirstTime = sharedPref.getBool('is_first_time');

        if (isFirstTime == null) {
          return '/on_boarding';
        } else {
          null;
        }
        return null;
      },
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
          path: '/myList',
          pageBuilder: (context, state) {
            return const NoTransitionPage(
              child: MyListScreen(),
            );
          },
        ),
      ],
    ),
  ],
);
