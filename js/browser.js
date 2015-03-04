/**
 * The browser implementation of this doesn't really do anything. The methods
 * all exist so the code still runs. Maybe we can use DOM APIs to at least show
 * something is happening.
 */

exports = {
  share: function (opts, cb) {
    window.open(opts.image, '_blank');
    setTimeout(function () {
      cb && cb(true);
    });
  }
};
