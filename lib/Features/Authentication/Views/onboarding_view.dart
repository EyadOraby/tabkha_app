import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tabkha_app/Features/Home/Views/app_shell.dart';
import 'package:tabkha_app/Localization/app_localization_context.dart';
import 'package:tabkha_app/Services/navigation_services.dart';
import 'package:tabkha_app/constants/app_colors.dart';

class OnboardingView extends StatefulWidget {
  static const routeName = '/onboarding';

  @override
  _OnboardingViewState createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: size.height * 0.065),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(right: size.width * 0.03),
              child: IconButton(
                onPressed: () {
                  NavigationsServices.pushReplacementNamed(
                      context, HomeView.routeName);
                },
                icon: Icon(
                  Icons.close,
                  color: AppColors.black,
                  size: size.width * 0.085,
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildOnboardingPage(
                    'assets/images/onboarding_1.png',
                    "Discover Home-Cooked Flavors, Anytime, Anywhere!",
                    "Explore a world of freshly made, home-cooked meals and locally sourced products from trusted chefs and vendors. Whether you're craving comfort food or something new, we've got you covered!"),
                _buildOnboardingPage(
                    'assets/images/onboarding_2.png',
                    "F Empower Local Communities, One Meal at a Time",
                    "By ordering on Tabkha, you’re supporting small food businesses and local chefs. Plus, help reduce food waste through our donation feature—giving back has never been easier!"),
                _buildOnboardingPage(
                    'assets/images/onboarding_3.jpg',
                    "Quick, Easy, Personalized—Made for You",
                    "Browse, order, and enjoy personalized recommendations based on your taste. Our smart features ensure a seamless and delightful experience every time."),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.065),
          SizedBox(
            width: size.width * 0.7,
            height: size.height * 0.06,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.greenBackground,
                foregroundColor: AppColors.white,
              ),
              onPressed: () {
                if (_currentPage < 2) {
                  _controller.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeView()),
                  );
                }
              },
              child: Text(
                _currentPage < 2 ? context.loc.next : context.loc.getStarted,
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.065),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(String imagePath, String text, String text2) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size.width * 0.6,
          height: size.width * 0.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.onboardingCircleColor,
              width: 4,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.03),
        SmoothPageIndicator(
          controller: _controller,
          count: 3,
          effect: ExpandingDotsEffect(
            spacing: 4,
            dotColor: AppColors.greenBackground,
            activeDotColor: AppColors.onboardingCircleColor,
            dotWidth: 10,
            dotHeight: 10,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        SizedBox(
          width: size.width * 0.8,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
              color: AppColors.greenBackground,
              fontFamily: "TT Hoves",
            ),
          ),
        ),
        SizedBox(height: size.height * 0.03),
        SizedBox(
          width: size.width * 0.8,
          child: Text(
            text2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.03,
              color: AppColors.black,
              fontFamily: "TT Hoves",
            ),
          ),
        ),
      ],
    );
  }
}
