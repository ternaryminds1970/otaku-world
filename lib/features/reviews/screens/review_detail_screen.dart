import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:otaku_world/bloc/graphql_client/graphql_client_cubit.dart';
import 'package:otaku_world/bloc/reviews/review_detail/review_detail_bloc.dart';
import 'package:otaku_world/core/ui/error_text.dart';
import 'package:otaku_world/core/ui/markdown/markdown.dart';
import 'package:otaku_world/core/ui/shimmers/review_detail_shimmer.dart';
import 'package:otaku_world/features/reviews/widgets/bottom_sheet_component.dart';
import 'package:otaku_world/features/reviews/widgets/review_by_user.dart';
import 'package:otaku_world/features/reviews/widgets/review_card.dart';
import 'package:otaku_world/features/reviews/widgets/review_profile_photo.dart';
import 'package:otaku_world/features/reviews/widgets/review_rating.dart';
import 'package:otaku_world/generated/assets.dart';
import 'package:otaku_world/graphql/__generated/graphql/fragments.graphql.dart';
import 'package:otaku_world/graphql/__generated/graphql/schema.graphql.dart';
import 'package:otaku_world/utils/ui_utils.dart';
import '../../../core/ui/appbars/simple_app_bar.dart';
import '../../../theme/colors.dart';
import '../../../utils/formatting_utils.dart';

class ReviewDetailScreen extends StatelessWidget {
  const ReviewDetailScreen({super.key, required this.reviewId});

  // final Fragment$Review review;
  final int reviewId;

  @override
  Widget build(BuildContext context) {
    final client =
        (context.read<GraphqlClientCubit>().state as GraphqlClientInitialized)
            .client;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => _onPopInvoked(context),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const SimpleAppBar(
          title: '',
          bgColor: AppColors.transparent,
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<ReviewDetailBloc, ReviewDetailState>(
            builder: (context, state) {
              if (state is ReviewDetailInitial) {
                context
                    .read<ReviewDetailBloc>()
                    .add(LoadReviewDetail(id: reviewId, client: client));
                return const ReviewDetailShimmer();
              } else if (state is ReviewDetailLoading) {
                return const ReviewDetailShimmer();
              } else if (state is ReviewDetailLoaded) {
                final review = state.review;
                if (review.id != reviewId) {
                  context
                      .read<ReviewDetailBloc>()
                      .add(LoadReviewDetail(id: reviewId, client: client));
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // cover image
                    Container(
                      foregroundDecoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.00, -1.00),
                          end: Alignment(0, 1),
                          colors: [Color(0x001F1F1F), Color(0xFF202020)],
                        ),
                      ),
                      height: UIUtils.getWidgetHeight(
                        targetWidgetHeight: 340,
                        screenHeight: height,
                      ),
                      width: width,
                      child: _buildCoverImage(
                        review.media!.coverImage!.extraLarge.toString(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, bottom: 10),
                      child: Text(
                        '${_getMediaType(review.mediaType!)} Review',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontFamily: 'Roboto',
                                ),
                      ),
                    ),
                    _buildTitleSection(width, review, context),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: buildSummaryText(
                        summary: review.summary.toString(),
                        context: context,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: _buildProfileSection(context, review),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        FormattingUtils.formatUnixTimestamp(review.createdAt)
                            .toString(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Roboto',
                                  color: AppColors.white.withOpacity(0.8),
                                ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, bottom: 10),
                      child: Text(
                        "(Last Updated on ${FormattingUtils.formatUnixTimestamp(review.createdAt).toString()})",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Roboto',
                                  color: AppColors.white.withOpacity(0.8),
                                ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15, bottom: 10),
                     child: Markdown(data: review.body.toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 10,
                      ),
                      child: ReviewRating(
                        rating: review.rating.toString(),
                        averageScore: review.score.toString(),
                      ),
                    ),
                  ],
                );
              } else if (state is ReviewDetailError) {
                return ErrorText(
                  message: state.message,
                  onTryAgain: () {
                    context
                        .read<ReviewDetailBloc>()
                        .add(LoadReviewDetail(id: reviewId, client: client));
                  },
                );
              } else {
                return const Text('Unknown State');
              }
            },
          ),
        ),
      ),
    );
  }

  void _onPopInvoked(BuildContext context) {
    dev.log('Pop called!', name: 'ReviewDetail');
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  String _getMediaType(Enum$MediaType type) {
    return type == Enum$MediaType.ANIME ? 'Anime' : 'Manga';
  }

  Widget _buildTitleSection(
      double screenWidth, Fragment$ReviewDetail review, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 15),
          width: UIUtils.getWidgetWidth(
              targetWidgetWidth: 280, screenWidth: screenWidth),
          child: ReviewByUser(
            mediaTitle: review.media!.title!.userPreferred.toString(),
            userName: review.user!.name.toString(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: () {
              showModalBottomsheet(context);
            },
            icon: SvgPicture.asset(Assets.iconsMoreHorizontal),
          ),
        )
      ],
    );
  }

  Widget _buildCoverImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Image.asset('name');
      },
    );
  }

  Widget _buildProfileSection(
      BuildContext context, Fragment$ReviewDetail review) {
    return Row(
      children: [
        ReviewProfilePhoto(
          profilePicUrl: review.user!.avatar!.medium.toString(),
          radius: 25,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          review.user!.name.toString(),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  void showModalBottomsheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.darkCharcoal,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          padding: const EdgeInsets.only(
            top: 33,
            left: 15,
          ),
          height: 180,
          child: const Column(
            children: [
              BottomSheetComponent(
                iconName: Assets.iconsOpenLink2,
                text: 'Open Media Page',
              ),
              SizedBox(
                height: 20,
              ),
              BottomSheetComponent(
                iconName: Assets.iconsLinkSquare,
                text: 'View on AniList',
              ),
              SizedBox(
                height: 20,
              ),
              BottomSheetComponent(
                iconName: Assets.iconsCopyLink,
                text: 'Copy Link',
              ),
            ],
          ),
        );
      },
    );
  }
}
