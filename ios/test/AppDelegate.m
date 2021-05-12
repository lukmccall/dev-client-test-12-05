#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTLinkingManager.h>

#if defined(EX_DEV_MENU_ENABLED)
@import EXDevMenu;
#endif
 
#if defined(EX_DEV_LAUNCHER_ENABLED)
#include <EXDevLauncher/EXDevLauncherController.h>
#endif

#ifdef FB_SONARKIT_ENABLED
#import <FlipperKit/FlipperClient.h>
#import <FlipperKitLayoutPlugin/FlipperKitLayoutPlugin.h>
#import <FlipperKitUserDefaultsPlugin/FKUserDefaultsPlugin.h>
#import <FlipperKitNetworkPlugin/FlipperKitNetworkPlugin.h>
#import <SKIOSNetworkPlugin/SKIOSNetworkAdapter.h>
#import <FlipperKitReactPlugin/FlipperKitReactPlugin.h>

static void InitializeFlipper(UIApplication *application) {
  FlipperClient *client = [FlipperClient sharedClient];
  SKDescriptorMapper *layoutDescriptorMapper = [[SKDescriptorMapper alloc] initWithDefaults];
  [client addPlugin:[[FlipperKitLayoutPlugin alloc] initWithRootNode:application withDescriptorMapper:layoutDescriptorMapper]];
  [client addPlugin:[[FKUserDefaultsPlugin alloc] initWithSuiteName:nil]];
  [client addPlugin:[FlipperKitReactPlugin new]];
  [client addPlugin:[[FlipperKitNetworkPlugin alloc] initWithNetworkAdapter:[SKIOSNetworkAdapter new]]];
  [client start];
}
#endif

@interface AppDelegate ()

@property (nonatomic, strong) NSDictionary *launchOptions;
@property (nonatomic, strong) UIViewController *rootViewController;


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef FB_SONARKIT_ENABLED
  InitializeFlipper(application);
#endif

  self.launchOptions = launchOptions;
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  
  #if defined(DEBUG) && defined(EX_DEV_LAUNCHER_ENABLED)
    EXDevLauncherController *contoller = [EXDevLauncherController sharedInstance];
    [contoller startWithWindow:self.window delegate:(id<EXDevLauncherControllerDelegate>)self launchOptions:launchOptions];
  #else
    [self initializeReactNativeApp];
  #endif
  
  return YES;
}

- (RCTBridge *)initializeReactNativeApp
{
#if defined(EX_DEV_LAUNCHER_ENABLED)
  NSDictionary *launchOptions = [EXDevLauncherController.sharedInstance getLaunchOptions];
#else
  NSDictionary *launchOptions = self.launchOptions;
#endif
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"test" initialProperties:nil];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  
  if (@available(iOS 13.0, *)) {
      rootView.backgroundColor = [UIColor systemBackgroundColor];
  } else {
      rootView.backgroundColor = [UIColor whiteColor];
  }
  
  self.rootViewController = [UIViewController new];
  self.rootViewController.view = rootView;
  self.window.rootViewController = self.rootViewController;
  [self.window makeKeyAndVisible];
 
  return bridge;
 }

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
#ifdef DEBUG
  #if defined(EX_DEV_LAUNCHER_ENABLED)
    return [[EXDevLauncherController sharedInstance] sourceUrl];
  #else
    return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
  #endif
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (BOOL)application:(UIApplication *)application
   openURL:(NSURL *)url
   options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
#if defined(EX_DEV_LAUNCHER_ENABLED)
  if ([EXDevLauncherController.sharedInstance onDeepLink:url options:options]) {
    return true;
  }
#endif
  return [RCTLinkingManager application:application openURL:url options:options];
}

@end

#if defined(EX_DEV_LAUNCHER_ENABLED)
@implementation AppDelegate (EXDevLauncherControllerDelegate)

- (void)devLauncherController:(EXDevLauncherController *)devLauncherController
          didStartWithSuccess:(BOOL)success
{
  devLauncherController.appBridge = [self initializeReactNativeApp];
}

@end
#endif
