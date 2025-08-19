import 'package:malacas_advmobprog/models/article_model.dart';
import 'package:malacas_advmobprog/services/article_service.dart';
import 'package:malacas_advmobprog/widgets/custom_text.dart';
import 'package:malacas_advmobprog/screens/article_details_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Future<List<Article>> _futureArticles;
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureArticles = _getAllArticles();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Article>> _getAllArticles() async {
    final response = await ArticleService().getAllArticle();
    final articles = (response).map((e) => Article.fromJson(e)).toList();
    _allArticles = articles;
    _filteredArticles = articles;
    return articles;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredArticles = _allArticles
          .where((article) =>
              article.title.toLowerCase().contains(query) ||
              article.body.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search articles...",
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _futureArticles,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomText(
                        text: 'No articles to display.',
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
                        SizedBox(height: 10.h),
                        CustomText(
                          text: 'Loading articles...',
                          fontSize: 14.sp,
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredArticles.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomText(
                        text: 'No matching articles.',
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: _filteredArticles.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final article = _filteredArticles[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleDetailsScreen(article: article),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Placeholder(
                                fallbackHeight: 100.h,
                                fallbackWidth: 100.w,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: article.title,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6.h),
                                    CustomText(
                                      text: article.body,
                                      fontSize: 13.sp,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}