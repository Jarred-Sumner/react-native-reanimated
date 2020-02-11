import { NativeModules } from 'react-native';

const AnimatedHandler = {
  get: function(obj, prop) {
    if (global.ReanimatedJSI !== 'undefined' && global.ReanimatedJSI[prop]) {
      return global.ReanimatedJSI[prop];
    } else {
      return obj[prop];
    }
  },
};

const { ReanimatedModule } = NativeModules;

let AnimatedProxy = new Proxy(ReanimatedModule, AnimatedHandler);

export default AnimatedProxy;
