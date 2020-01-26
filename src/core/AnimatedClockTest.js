import AnimatedNode from './AnimatedNode';
import AnimatedClock from './AnimatedClock';
import invariant from 'fbjs/lib/invariant';

class AnimatedClockTest extends AnimatedNode {
  _clockNode;

  constructor(clockNode) {
    super({ type: 'clockTest', clock: clockNode.__nodeID });
    this._clockNode = clockNode;
  }

  __onEvaluate() {
    return this._clockNode.isStarted() ? 1 : 0;
  }
}

export function createAnimatedClockTest(clock) {
  return new AnimatedClockTest(clock);
}
