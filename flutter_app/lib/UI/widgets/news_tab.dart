import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/Data/DAO/articles_dao.dart';
import 'package:flutter_app/Data/DAO/articles_runtime_dao.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'article_widget.dart';

class NewsTab extends StatefulWidget {
  final String url;

  const NewsTab({
    super.key,
    required this.url,
  });

  @override
  NewsTabState createState() => NewsTabState();
}

class NewsTabState extends State<NewsTab> {
  ArticlesDao articlesData = ArticlesRuntimeDao();
  bool loaded = true;
  int currentlyLoaded = 5;

  Future<void> fetchArticles(url, ArticlesDao dao) async {
    setState(() {
      loaded = false;
    });
    await dao.fetchArticlesByUrl(url);
    setState(() {
      loaded = true;
    });
  }

  void loadMore(maximal) {
    setState(() {
      currentlyLoaded = min(currentlyLoaded + 5, maximal);
    });
  }

  @override
  void initState() {
    loaded = false;
    super.initState();
    fetchArticles(widget.url, articlesData);
  }

  @override
  Widget build(BuildContext context) {
    return loaded
        ? RefreshIndicator.adaptive(
            onRefresh: () => fetchArticles(widget.url, articlesData),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter == 0) {
                  loadMore(articlesData.getArticles().length);
                }
                return false;
              },
              child: Center(
                child: ListView.builder(
                  itemCount: currentlyLoaded + 1,
                  itemBuilder: (context, index) {
                    if (index < currentlyLoaded) {
                      return ArticleWidget(
                          article: articlesData.getArticles()[index],
                          height: 300,
                          width: 900);
                    } else if (index < articlesData.getArticles().length) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          )
        : const Center(
            child: LoadingIndicator(
              indicatorType: Indicator.pacman,
              colors: [Colors.blueAccent, Colors.red],
              strokeWidth: 1,
            ),
          );
  }
}
