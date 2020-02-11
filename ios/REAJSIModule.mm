//
//  REAJSIModule.m
//  yeet
//
//  Created by Jarred WSumner on 2/10/20.
//  Copyright © 2020 Yeet. All rights reserved.
//

#import "REAJSIModule.h"
#import "REAJSIUTils.h"
#import <React/RCTBridge+Private.h>
#import <RNReanimated/REAModule.h>

@interface REAModule (ext)
- (void) animateNextTransition:(nonnull NSNumber *)rootTag config:(NSDictionary *)config;
- (void) createNode:(nonnull NSNumber *)nodeID
                  config:(NSDictionary<NSString *, id> *)config;

- (void) dropNode:(nonnull NSNumber *)nodeID;


- (void) getValue:(nonnull NSNumber *)nodeID
                  callback:(RCTResponseSenderBlock)callback;


- (void) connectNodes:(nonnull NSNumber *)parentID
                  childTag:(nonnull NSNumber *)childID;

- (void) disconnectNodes:(nonnull NSNumber *)parentID
                  childTag:(nonnull NSNumber *)childID;

- (void) connectNodeToView:(nonnull NSNumber *)nodeID
                  viewTag:(nonnull NSNumber *)viewTag;

- (void) disconnectNodeFromView:(nonnull NSNumber *)nodeID
                  viewTag:(nonnull NSNumber *)viewTag;

- (void) attachEvent:(nonnull NSNumber *)viewTag
                  eventName:(nonnull NSString *)eventName
                  eventNodeID:(nonnull NSNumber *)eventNodeID;

- (void) detachEvent:(nonnull NSNumber *)viewTag
                  eventName:(nonnull NSString *)eventName
                  eventNodeID:(nonnull NSNumber *)eventNodeID;
- (void) configureProps:(nonnull NSArray<NSString *> *)nativeProps
                         uiProps:(nonnull NSArray<NSString *> *)uiProps;
@end

@interface RCTBridge (ext)
- (std::weak_ptr<facebook::react::Instance>)reactInstance;
@end

REAJSIModule::REAJSIModule(REAModule *reaModule)
: module_(reaModule) {
  std::shared_ptr<facebook::react::JSCallInvoker> _jsInvoker = std::make_shared<react::BridgeJSCallInvoker>(reaModule.bridge.reactInstance);
}


void REAJSIModule::install(REAModule *module) {
  RCTCxxBridge *bridge = module.bridge;
  if (bridge.runtime == nullptr) {
    return;
  }

 jsi::Runtime &runtime = *(jsi::Runtime *)bridge.runtime;

 auto reaModuleName = "ReanimatedJSI";
 auto reaJsiModule = std::make_shared<REAJSIModule>(std::move(module));
 auto object = jsi::Object::createFromHostObject(runtime, reaJsiModule);
 runtime.global().setProperty(runtime, reaModuleName, std::move(object));
}

jsi::Value REAJSIModule::get(jsi::Runtime &runtime, const jsi::PropNameID &name) {
  auto methodName = name.utf8(runtime);

  REAModule *module = module_;
  std::shared_ptr<facebook::react::JSCallInvoker> jsInvoker = _jsInvoker;

  if (methodName == "animateNextTransition") {
    return jsi::Function::createFromHostFunction(runtime, name, 2, [module, jsInvoker](
      jsi::Runtime &runtime,
      const jsi::Value &thisValue,
      const jsi::Value *arguments,
      size_t count) -> jsi::Value {

      NSNumber *number = convertJSIValueToObjCObject(runtime, arguments[0].asNumber(), jsInvoker);
      NSDictionary *config = convertJSIObjectToNSDictionary(runtime, arguments[1].asObject(runtime), jsInvoker);

      [module animateNextTransition:number config:config];
      return jsi::Value(true);
    });
  } else if (methodName == "createNode") {
    return jsi::Function::createFromHostFunction(runtime, name, 2, [module, jsInvoker](
      jsi::Runtime &runtime,
      const jsi::Value &thisValue,
      const jsi::Value *arguments,
      size_t count) -> jsi::Value {

      NSNumber *tag = convertJSIValueToObjCObject(runtime, arguments[0].asNumber(), jsInvoker);
      NSDictionary *config = convertJSIObjectToNSDictionary(runtime, arguments[1].asObject(runtime), jsInvoker);

      [module createNode:tag config:config];
      return jsi::Value(true);
    });
  }
  else if (methodName == "dropNode") {
    return jsi::Function::createFromHostFunction(runtime, name, 1, [module, jsInvoker](
      jsi::Runtime &runtime,
      const jsi::Value &thisValue,
      const jsi::Value *arguments,
      size_t count) -> jsi::Value {

      NSNumber *tag = convertJSIValueToObjCObject(runtime, arguments[0].asNumber(), jsInvoker);
      [module dropNode:tag];
      return jsi::Value(true);
    });
  }
  else if (methodName == "getValue") {
    return jsi::Function::createFromHostFunction(runtime, name, 2, [module, jsInvoker](
      jsi::Runtime &runtime,
      const jsi::Value &thisValue,
      const jsi::Value *arguments,
      size_t count) -> jsi::Value {

      NSNumber *tag = convertJSIValueToObjCObject(runtime, arguments[0].asNumber(), jsInvoker);
      RCTResponseSenderBlock block = convertJSIFunctionToCallback(runtime, arguments[1], jsInvoker)
      [module getValue:tag callback:block];
      return jsi::Value(true);
    });
  }
  else if (methodName == "connectNodes") {
    return jsi::Function::createFromHostFunction(runtime, name, 2, [module, jsInvoker](
      jsi::Runtime &runtime,
      const jsi::Value &thisValue,
      const jsi::Value *arguments,
      size_t count) -> jsi::Value {

      NSNumber *parentTag = convertJSIValueToObjCObject(runtime, arguments[0].asNumber(), jsInvoker);
      NSNumber *childTag = convertJSIValueToObjCObject(runtime, arguments[1].asNumber(), jsInvoker);
      [module connectNodes:parentTag childTag:childTag];

      return jsi::Value(true);
    });
  }
  else if (methodName == "disconnectNodes") {
    return jsi::Function::createFromHostFunction(runtime, name, 2, [module, jsInvoker](
      jsi::Runtime &runtime,
      const jsi::Value &thisValue,
      const jsi::Value *arguments,
      size_t count) -> jsi::Value {

      NSNumber *parentTag = convertJSIValueToObjCObject(runtime, arguments[0].asNumber(), jsInvoker);
      NSNumber *childTag = convertJSIValueToObjCObject(runtime, arguments[1].asNumber(), jsInvoker);
      [module disconnectNodes:parentTag childTag:childTag];

      return jsi::Value(true);
    });
  }

  else if (methodName == "connectNodeToView") {
    return jsi::Function::createFromHostFunction(runtime, name, 2, [module, jsInvoker](
      jsi::Runtime &runtime,
      const jsi::Value &thisValue,
      const jsi::Value *arguments,
      size_t count) -> jsi::Value {

      NSNumber *parentTag = convertJSIValueToObjCObject(runtime, arguments[0].asNumber(), jsInvoker);
      NSNumber *childTag = convertJSIValueToObjCObject(runtime, arguments[1].asNumber(), jsInvoker);
      [module connectNodeToView:parentTag viewTag:childTag];

      return jsi::Value(true);
    });
  }
  else if (methodName == "disconnectNodeFromView") {
    return jsi::Function::createFromHostFunction(runtime, name, 2, [module, jsInvoker](
      jsi::Runtime &runtime,
      const jsi::Value &thisValue,
      const jsi::Value *arguments,
      size_t count) -> jsi::Value {

      NSNumber *parentTag = convertJSIValueToObjCObject(runtime, arguments[0].asNumber(), jsInvoker);
      NSNumber *childTag = convertJSIValueToObjCObject(runtime, arguments[1].asNumber(), jsInvoker);
      [module disconnectNodeFromView:parentTag viewTag:childTag];

      return jsi::Value(true);
    });
  }
  else if (methodName == "attachEvent") {
    return jsi::Function::createFromHostFunction(runtime, name, 3, [module, jsInvoker](
         jsi::Runtime &runtime,
         const jsi::Value &thisValue,
         const jsi::Value *arguments,
         size_t count) -> jsi::Value {

         NSNumber *event = convertJSIValueToObjCObject(runtime, arguments[0].asNumber(), jsInvoker);
      NSNumber *eventNode = convertJSIValueToObjCObject(runtime, arguments[2].asNumber(), jsInvoker);
        NSString *eventName = convertJSIStringToNSString(runtime, arguments[1].asString(runtime));

        [module attachEvent:event eventName:eventName eventNodeID:eventNode];

         return jsi::Value(true);
       });
  }
  else if (methodName == "detachEvent") {
    return jsi::Function::createFromHostFunction(runtime, name, 3, [module, jsInvoker](
           jsi::Runtime &runtime,
           const jsi::Value &thisValue,
           const jsi::Value *arguments,
           size_t count) -> jsi::Value {

           NSNumber *event = convertJSIValueToObjCObject(runtime, arguments[0].asNumber(), jsInvoker);
        NSNumber *eventNode = convertJSIValueToObjCObject(runtime, arguments[2].asNumber(), jsInvoker);
          NSString *eventName = convertJSIStringToNSString(runtime, arguments[1].asString(runtime));

          [module detachEvent:event eventName:eventName eventNodeID:eventNode];

           return jsi::Value(true);
         });


  }
  else if (methodName == "configureProps") {
    return jsi::Function::createFromHostFunction(runtime, name, 3, [module, jsInvoker](
           jsi::Runtime &runtime,
           const jsi::Value &thisValue,
           const jsi::Value *arguments,
           size_t count) -> jsi::Value {

           NSArray *props = convertJSIArrayToNSArray(runtime, arguments[0], jsInvoker);
            NSArray *uiProps = convertJSIArrayToNSArray(runtime, arguments[1], jsInvoker);

          [module configureProps:props uiProps:uiProps];

           return jsi::Value(true);
         });
  }

  return jsi::Value::undefined();
}
