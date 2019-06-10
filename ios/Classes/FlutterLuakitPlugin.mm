#import "FlutterLuakitPlugin.h"
#import <LuakitPod/oc_helpers.h>
#import <LuakitPod/scoped_ptr.h>
#import <LuakitPod/NotificationProxyObserver.h>
@interface FlutterLuakitPlugin ()<FlutterStreamHandler,NotificationProxyObserverDelegate> {
    scoped_ptr<NotificationProxyObserver> _notification_observer;
}
@property(strong, nonatomic) FlutterEventSink sink;
@end

@implementation FlutterLuakitPlugin

- (void)onNotification:(int)type data:(id)data
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@(type) forKey:@"type"];
    if (data) {
        [dict setObject:data forKey:@"data"];
    }
    if (self.sink) {
        self.sink(dict);
    }
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_luakit_plugin"
            binaryMessenger:[registrar messenger]];
  FlutterLuakitPlugin* instance = [[FlutterLuakitPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:@"com.luakit.eventchannel" binaryMessenger:[registrar messenger]];
  [eventChannel setStreamHandler:instance];
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events
{
     _notification_observer.reset(new NotificationProxyObserver(self));
     _notification_observer->AddObserver(0);
     self.sink = events;
     return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments
{
    self.sink = nil;
    return nil;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *callMethod = call.method;
    if ([callMethod isEqualToString:@"callLuaFunction"]) {
        id params = [call.arguments objectForKey:@"params"];
        @try{
            if (params) {
                call_lua_function([call.arguments objectForKey:@"moduleName"], [call.arguments objectForKey:@"methodName"], params, ^(NSString *s){
                    result(s);
                });
            } else {
                call_lua_function([call.arguments objectForKey:@"moduleName"], [call.arguments objectForKey:@"methodName"], ^(NSString *s){
                    result(s);
                });
            }
        }
        @catch(NSException * ex){
            result(nil);
        }
    } else if([callMethod isEqualToString:@"postNotification"]){
        NSDictionary *d = (NSDictionary *)call.arguments;
        NSInteger type = [[d objectForKey:@"type"] integerValue];
        id params = [d objectForKey:@"params"];
        post_notification((int)type, params);
        result(nil);
    } else {
        result(nil);
    }
   
}
@end
