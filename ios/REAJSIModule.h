//
//  REAJSIModule.h
//  yeet
//
//  Created by Jarred WSumner on 2/6/20.
//  Copyright © 2020 Yeet. All rights reserved.
//

#import <jsi/jsi.h>
#import <ReactCommon/BridgeJSCallInvoker.h>
#import "REAModule.h"


using namespace facebook;

@class REAModule;

class JSI_EXPORT REAJSIModule : public jsi::HostObject {
public:
    REAJSIModule(REAModule* module);

    static void install(REAModule *module);

    /*
     * `jsi::HostObject` specific overloads.
     */
    jsi::Value get(jsi::Runtime &runtime, const jsi::PropNameID &name) override;



private:
    REAModule* module_;
    std::shared_ptr<facebook::react::JSCallInvoker> _jsInvoker;
};
