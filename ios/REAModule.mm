#import "REAModule.h"

#import "REANodesManager.h"
#import "Transitioning/REATransitionManager.h"
#import "REAJSIModule.h"
#import <React/RCTBridge+Private.h>

typedef void (^AnimatedOperation)(REANodesManager *nodesManager);

@implementation REAModule
{
  REANodesManager *_nodesManager;
  NSMutableArray<AnimatedOperation> *_operations;
  NSMutableArray<AnimatedOperation> *_layoutOperations;
  REATransitionManager *_transitionManager;
}

RCT_EXPORT_MODULE(ReanimatedModule);

- (void)invalidate
{
  _transitionManager = nil;
  [_nodesManager invalidate];
  [self.bridge.eventDispatcher removeDispatchObserver:self];
  [self.bridge.uiManager.observerCoordinator removeObserver:self];
}

- (dispatch_queue_t)methodQueue
{
  // This module needs to be on the same queue as the UIManager to avoid
  // having to lock `_operations` and `_layoutOperations` since `uiManagerWillPerformMounting`
  // will be called from that queue.
  return RCTGetUIManagerQueue();
}

- (void)setBridge:(RCTBridge *)bridge
{
  [super setBridge:bridge];

  _nodesManager = [[REANodesManager alloc] initWithModule:self
                                                uiManager:self.bridge.uiManager];
  _operations = [NSMutableArray new];
  _layoutOperations = [NSMutableArray new];

  _transitionManager = [[REATransitionManager alloc] initWithUIManager:self.bridge.uiManager];

  [bridge.eventDispatcher addDispatchObserver:self];
  [bridge.uiManager.observerCoordinator addObserver:self];

  __block REAModule *this = self;
  [bridge dispatchBlock:^{
    REAJSIModule::install(this);
  } queue:RCTJSThread]
}

#pragma mark -- Transitioning API

RCT_EXPORT_METHOD(animateNextTransition:(nonnull NSNumber *)rootTag config:(NSDictionary *)config)
{
  [_transitionManager animateNextTransitionInRoot:rootTag withConfig:config];
}

#pragma mark -- API

RCT_EXPORT_METHOD(createNode:(nonnull NSNumber *)nodeID
                  config:(NSDictionary<NSString *, id> *)config)
{
  [self addLayoutOperationBlock:^(REANodesManager *nodesManager) {
    [nodesManager createNode:nodeID config:config];
  }];
}

RCT_EXPORT_METHOD(dropNode:(nonnull NSNumber *)nodeID)
{
  [self addOperationBlock:^(REANodesManager *nodesManager) {
    [nodesManager dropNode:nodeID];
  }];
}

RCT_EXPORT_METHOD(getValue:(nonnull NSNumber *)nodeID
                  callback:(RCTResponseSenderBlock)callback) {
  [self addOperationBlock:^(REANodesManager *nodesManager) {
    [nodesManager getValue:nodeID callback:(RCTResponseSenderBlock)callback];
  }];
}

RCT_EXPORT_METHOD(connectNodes:(nonnull NSNumber *)parentID
                  childTag:(nonnull NSNumber *)childID)
{
  [self addOperationBlock:^(REANodesManager *nodesManager) {
    [nodesManager connectNodes:parentID childID:childID];
  }];
}

RCT_EXPORT_METHOD(disconnectNodes:(nonnull NSNumber *)parentID
                  childTag:(nonnull NSNumber *)childID)
{
  [self addOperationBlock:^(REANodesManager *nodesManager) {
    [nodesManager disconnectNodes:parentID childID:childID];
  }];
}

RCT_EXPORT_METHOD(connectNodeToView:(nonnull NSNumber *)nodeID
                  viewTag:(nonnull NSNumber *)viewTag)
{
  NSString *viewName = [self.bridge.uiManager viewNameForReactTag:viewTag];
  [self addOperationBlock:^(REANodesManager *nodesManager) {
    [nodesManager connectNodeToView:nodeID viewTag:viewTag viewName:viewName];
  }];
}

RCT_EXPORT_METHOD(disconnectNodeFromView:(nonnull NSNumber *)nodeID
                  viewTag:(nonnull NSNumber *)viewTag)
{
  [self addOperationBlock:^(REANodesManager *nodesManager) {
    [nodesManager disconnectNodeFromView:nodeID viewTag:viewTag];
  }];
}

RCT_EXPORT_METHOD(attachEvent:(nonnull NSNumber *)viewTag
                  eventName:(nonnull NSString *)eventName
                  eventNodeID:(nonnull NSNumber *)eventNodeID)
{
  [self addLayoutOperationBlock:^(REANodesManager *nodesManager) {
    [nodesManager attachEvent:viewTag eventName:eventName eventNodeID:eventNodeID];
  }];
}

RCT_EXPORT_METHOD(detachEvent:(nonnull NSNumber *)viewTag
                  eventName:(nonnull NSString *)eventName
                  eventNodeID:(nonnull NSNumber *)eventNodeID)
{
  [self addLayoutOperationBlock:^(REANodesManager *nodesManager) {
    [nodesManager detachEvent:viewTag eventName:eventName eventNodeID:eventNodeID];
  }];
}

RCT_EXPORT_METHOD(configureProps:(nonnull NSArray<NSString *> *)nativeProps
                         uiProps:(nonnull NSArray<NSString *> *)uiProps)
{
  [self addOperationBlock:^(REANodesManager *nodesManager) {
    [nodesManager configureProps:[NSSet setWithArray:nativeProps] uiProps:[NSSet setWithArray:uiProps]];
  }];
}


#pragma mark -- Batch handling

- (void)addOperationBlock:(AnimatedOperation)operation
{
  [_operations addObject:operation];
}

- (void)addLayoutOperationBlock:(AnimatedOperation)operation
{
  [_layoutOperations addObject:operation];
}

#pragma mark - RCTUIManagerObserver

- (void)uiManagerWillPerformMounting:(RCTUIManager *)uiManager
{
  if (_operations.count == 0) {
    return;
  }

  NSArray<AnimatedOperation> *operations = _operations;
  _operations = [NSMutableArray new];

  REANodesManager *nodesManager = _nodesManager;

  [uiManager addUIBlock:^(__unused RCTUIManager *manager, __unused NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    for (AnimatedOperation operation in operations) {
      operation(nodesManager);
    }
    [nodesManager operationsBatchDidComplete];
  }];
}

- (void)uiManagerWillPerformLayout:(RCTUIManager *)uiManager
{
  if (_layoutOperations.count == 0) {
    return;
  }

  __block NSArray<AnimatedOperation> *operations = _layoutOperations;
  _layoutOperations = [NSMutableArray new];

  REANodesManager *nodesManager = _nodesManager;

  // Not sending operationsBatchDidComplete.
  // We just want to register and connect things here, we don't want to send updates to the views until after layout.
  RCTExecuteOnMainQueue(^{
    for (AnimatedOperation operation in operations) {
     operation(nodesManager);
   }
  });
}

#pragma mark -- Events

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"onReanimatedCall", @"onReanimatedPropsChange"];
}

- (void)eventDispatcherWillDispatchEvent:(id<RCTEvent>)event
{
  // Events can be dispatched from any queue
  [_nodesManager dispatchEvent:event];
}

@end
