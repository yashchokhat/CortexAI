import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cortexai_app/main.dart';
import 'package:cortexai_app/auth_page.dart';
import 'package:cortexai_app/home_page.dart';
import 'package:cortexai_app/vertex_ai_page.dart';

void main() {
  testWidgets('App flows through Auth, Home, and Dedicated Vertex Agent Chat Page with clean UI',
      (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // 1. Verify loading page
    expect(find.text('CORTEX AI'), findsOneWidget);

    // 2. Advance past loading delay
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 3. Verify AuthPage is active
    expect(find.byType(AuthPage), findsOneWidget);
    expect(find.textContaining('Sign in to your'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Verify Head banner image asset is rendered
    expect(find.byWidgetPredicate((widget) {
      if (widget is Image && widget.image is AssetImage) {
        final assetName = (widget.image as AssetImage).assetName;
        return assetName.contains('head_banner.png') || assetName.contains('Head.png');
      }
      return false;
    }), findsWidgets);

    // 4. Tap Login to transition to HomePage
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 5. Verify HomePage sections: Vertex Agent Portal & Templates (Card UI)
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Vertex Agent'), findsWidgets);
    expect(find.text('Open Console'), findsOneWidget);
    expect(find.text('Templates'), findsWidgets);

    // 6. Test navigating to Dedicated VertexAIPage
    await tester.tap(find.text('Open Console'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // 7. Verify Dedicated VertexAIPage is rendered with clean ChatGPT style
    expect(find.byType(VertexAIPage), findsOneWidget);
    expect(find.text('Vertex Agent'), findsWidgets);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Message Vertex Agent...'), findsOneWidget);

    // 8. Test back button from VertexAIPage to return to HomePage
    final backFinder = find.byIcon(CupertinoIcons.chevron_back);
    expect(backFinder, findsOneWidget);
    await tester.tap(backFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // 9. Back on HomePage, verify opening Side Drawer via hamburger menu icon
    final hamburgerFinder = find.byIcon(CupertinoIcons.line_horizontal_3);
    expect(hamburgerFinder, findsOneWidget);
    await tester.tap(hamburgerFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 10. Verify Drawer items
    expect(find.text('NAVIGATION'), findsOneWidget);
    expect(find.text('Dashboard Overview'), findsOneWidget);
    expect(find.text('Vertex Agent'), findsWidgets);
    expect(find.text('Templates'), findsWidgets);
    expect(find.text('Connected Devices'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });
}
