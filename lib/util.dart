import 'dart:math' as Math;

/** Returns the smallest value in the array. */
min(values) {
  return values.reduce(Math.min);
}

/** Returns the largest value in the array. */
max(Iterable values) {
  return values.reduce(Math.max);
}

/**
 * Returns `true` only if `f(x)` is `true` for all `x` in `xs`. Otherwise
 * returns `false`. This function will return immediately if it finds a
 * case where `f(x)` does not hold.
 */
bool all(xs, f) {
  for (var i = 0; i < xs.length; ++i) {
    if (!f(xs[i])) {
      return false;
    }
  }
  return true;
}

/**
 * Accumulates the sum of elements in the given array using the `+` operator.
 */
num sum(Iterable values) {
  return values.reduce((acc, x) { return acc + x; });//, 0);
}

/*
 * Returns an array of all values in the given object.
 */
/*values(obj) {
  return Object.keys(obj).map((k) { return obj[k]; });
}

createTimer(enabled) {
  var self = {};

  // Default to disabled
  enabled = enabled || false;

  self.enabled = (x) {
    if (!arguments.length) { return enabled; }
    enabled = x;
    return self;
  };

  self.wrap = (name, func) {
    return () {
      var start = enabled ? new Date().getTime() : null;
      try {
        return func.apply(null, arguments);
      } finally {
        if (start) { console.log(name + ' time: ' + (new Date().getTime() - start) + 'ms'); }
      }
    };
  };

  return self;
}

propertyAccessor(self, config, field, setHook) {
  return (x) {
    if (!arguments.length) { return config[field]; }
    config[field] = x;
    if (setHook) { setHook(x); }
    return self;
  };
}*/
