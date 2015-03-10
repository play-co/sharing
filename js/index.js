import device;
import lib.PubSub;
import lib.Callback;

import .native;
import .browser;

/**
 * The devkit Share interface.
 * @constructor Share
 */
function Share () {
}

/**
 * Initialize the game kit plugin
 */

Share.prototype.init = function (opts) {

};

/**
 * Define plugin methods
 */

var methods = [
  'share'
];

// Proxy methods to implementation
methods.forEach(function (method) {
    Share.prototype[method] = function () {
        return this.impl[method].apply(this.impl, arguments);
    };
});

var properties = [
];

propertiesObject = {};
properties.forEach(function (name) {
    propertiesObject[name] = {
        get: function () {
            return this.impl[name];
        }
    };
});

propertiesObject.impl = {
  get: function () {
    if (device.isMobileNative) {
      return native;
    }
    return browser;
  }
};

exports = Object.create(Share.prototype, propertiesObject);
