import 'package:cached_network_image/cached_network_image.dart';
import 'package:eSamudaay/modules/home/models/video_feed_response.dart';
import 'package:eSamudaay/modules/home/views/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:eSamudaay/utilities/size_cpnfig.dart';

class VideosListWidget extends StatefulWidget {
  final VideoFeedResponse videoFeedResponse;
  final Function onRefresh;
  VideosListWidget(this.videoFeedResponse, this.onRefresh);
  @override
  _VideosViewState createState() => _VideosViewState();
}

class _VideosViewState extends State<VideosListWidget> {
  UniqueKey uniqueKey = UniqueKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    if (widget.videoFeedResponse.results.length == 0) {
      return Container();
    }

    return Container(
      key: uniqueKey,
      height: 100.toHeight,
      margin: EdgeInsets.only(top: 20.toHeight),
      child: ListView.builder(
        itemCount: widget.videoFeedResponse.results.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          Results videoData = widget.videoFeedResponse.results[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10.toWidth),
            width: (SizeConfig.screenWidth / 3 - 20.toWidth),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                SizeConfig.screenWidth / 35,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(
                        SizeConfig.screenWidth / 35,
                      ),
                    ),
                    child: CachedNetworkImage(
                      width: (SizeConfig.screenWidth / 3 - 20.toWidth),
                      imageUrl: videoData?.content?.video?.thumbnail ?? '',
                      imageBuilder: (context, imageProvider) => InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              playUrl: videoData?.content?.video?.playUrl ?? '',
                              thumbnailUrl:
                                  videoData?.content?.video?.thumbnail ?? '',
                              title: videoData?.title ?? '',
                              merchantInfo: videoData?.business,
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              SizeConfig.screenWidth / 35,
                            ),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_arrow,
                              size: SizeConfig.screenWidth / 8,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
                SizedBox(height: 10.toHeight),
                Flexible(
                  flex: 1,
                  child: Text(
                    videoData.title ?? '',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 1,
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