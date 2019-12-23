import AnimatedNode from './AnimatedNode';
import AnimatedClock from './AnimatedClock';
import { AnimatedParam } from './AnimatedParam';
import invariant from 'fbjs/lib/invariant';

class AnimatedStopClock extends AnimatedNode {
  _clockNode;

  constructor(clockNode) {
    super({ type: 'clockStop', clock: clockNode.__nodeID });
    invariant(
      clockNode instanceof AnimatedClock || clockNode instanceof AnimatedParam,
      `Reanimated: Animated.stopClock argument should be of type AnimatedClock but got ${clockNode}`
    );
    this._clockNode = clockNode;
  }

  __onEvaluate() {
    this._clockNode.stop();
    return 0;
  }
}

export function createAnimatedStopClock(clock) {
  return new AnimatedStopClock(clock);
}
