import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'add_view_model.dart';
import 'package:postgres/postgres.dart';

// Import your screens
import 'home_screen.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'add_screen.dart';
import 'explore_screen.dart';
import 'location_details.dart';
import 'property_details_screen.dart';
import 'material_details.dart';
import 'register_screen.dart';
import 'skill_worker_details.dart';
import 'map_view.dart';
import 'chat_screen.dart';
import 'new_message_page.dart';
import 'inbox_screen.dart';
import 'my_listings_screen.dart';
import 'my_bids_screen.dart';
import 'get_coordinate_screen.dart';
import 'settings_screen.dart';
import 'investment_vendor_form.dart';
import 'forgot_password_screen.dart';
import 'invest_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AddViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

final connection = PostgreSQLConnection(
  'host-from-render',
  5432,
  'database-name',
  username: 'username',
  password: 'password',
);

// Custom page transition builder with zero animation for bottom nav transitions
class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Return the child directly without any animation
    return child;
  }
}

// Custom page route with zero animation
class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mipripity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF000080),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF000080),
          primary: const Color(0xFF000080),
          secondary: const Color(0xFFF39322),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Poppins',
        // Configure page transitions for bottom navigation routes to have zero animation
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
          },
        ),
      ),
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // If user is logged in, go to dashboard, otherwise go to home
          return userProvider.isLoggedIn ? const DashboardScreen() : const HomePage();
        },
      ),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/invest': (context) => const InvestInRealEstate(),
        '/add': (context) => AddScreen(
          onNavigateBack: () => Navigator.of(context).pop(),
        ),
        '/explore': (context) => const ExplorePage(),
        '/chat': (context) => const ChatPage(),
        '/new-message': (context) => const NewMessagePage(),
        '/inbox': (context) => const InboxScreen(),
        '/my-listings': (context) => const MyListingsScreen(),
        '/my-bids': (context) => const MyBidsScreen(),
        '/get-coordinate': (context) => const GetCoordinateScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/investment-vendor-form': (context) => const InvestmentVendorForm(),
        '/map-view': (context) => const MapView(
          propertyId: 'default',
          propertyTitle: 'Property Location',
          propertyAddress: 'Lagos, Nigeria',
          latitude: 6.559668,
          longitude: 3.337714,
        ),
      },
      // For routes with parameters, we need to use onGenerateRoute
      onGenerateRoute: (settings) {
        // Handle dynamic routes
        if (settings.name?.startsWith('/explore/') ?? false) {
          // Extract the location ID from the route
          final locationId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => LocationDetails(locationId: locationId),
          );
        } 
        else if (settings.name?.startsWith('/property-details/') ?? false) {
          // Extract the property ID from the route
          final propertyId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => PropertyDetails(propertyId: propertyId),
          );
        }
        else if (settings.name?.startsWith('/material/') ?? false) {
          // Extract the material ID from the route
          final materialId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => MaterialDetails(materialId: materialId),
          );
        }
        else if (settings.name?.startsWith('/skill-workers/') ?? false) {
          // Extract the worker ID from the route
          final workerId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => SkillWorkerDetails(workerId: workerId),
          );
        }
        // If no match, return null and let the routes table handle it
        return null;
      },
    );
  }
}
