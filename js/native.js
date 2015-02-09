import .util;

var rDataURI = /^data:image\/png;base64,/;

// Wrapper for the SharingPlugin
var SharePlugin = util.getNativeInterface('SharingPlugin');

/**
 * Methods in the SharingPlugin
 */
var nativeImpl = {

  /**
   * share
   */

  share: function nativeShare (opts, cb) {
    opts = JSON.parse(JSON.stringify(opts));

    if (!opts.image && typeof opts.image !== 'undefined') {
      // if it's an empty string or some falsey value other than undefined,
      // make a copy as to not mutate caller's object and delete the image
      // field.
      delete opts.image;
    } else if (rDataURI.test(opts.image)) {
      opts.image = opts.image.replace(rDataURI, '');
    }

    SharePlugin.request('share', opts, function (err, res) {
      cb && cb(!!res.completed);
    });
  }

};

/**
 * Sharing properties
 */

Object.defineProperties(nativeImpl, {

});

exports = nativeImpl;
