import ui.TextView as TextView;
import ui.ImageView as ImageView;
import ui.View as View;
import device;
import Sharing;
import animate;

var Canvas = device.get('Canvas');

var IS_NATIVE = !device.isSimulator &&
  !device.isMobileBrowser;

var boundsWidth = 576;
var boundsHeight = 1024;
var baseWidth = device.screen.width * (boundsHeight / device.screen.height);
var baseHeight = boundsHeight;
var scale = device.screen.height / baseHeight;

var viewOpts = {
  backgroundColor: 'white',
  color: 'black',
  width: 200,
  height: 60,
};

exports = Class(GC.Application, function () {

  this.initUI = function () {
    var self = this;
    this.view.style.scale = scale;
    this.view.style.width = baseWidth;
    this.view.style.height = baseHeight;
    this.tTitle = new TextView({
      superview: this.view,
      text: 'Sharing Test App',
      color: 'white',
      x: 0,
      y: 0,
      width: this.view.style.width,
      backgroundColor: '#333',
      height: 100,
      horizontalAlign: 'center'
    });

    this.bShare = new TextView(merge({
      x: 20,
      y: 120,
      text: 'Share',
      superview: this.view
    }, viewOpts));

    this.bShare.onInputSelect = function () {
      var opts = {
        title: 'Sharing Title',
        message: 'This message brought to you by devkit sharing.',
        image: this.toBase64()
      };

      Sharing.share(opts, function (completed) {
        if (completed) {
          logger.log('share completed');
        } else {
          logger.log('share cancelled');
        }
      });
    }.bind(this);

    // Create area with spinning squares
    this.animated = new View({
      width: 400,
      height: 400,
      backgroundColor: '#333333',
      y: 400,
      x: 100,
      superview: this.view
    });

    var red = this.red = new ImageView({
      width: 100,
      height: 100,
      image: 'resources/images/icon120.png',
      y: 150,
      x: 150,
      anchorX: 50,
      anchorY: 50,
      superview: this.animated
    });

    var blue = this.blue = new View({
      width: 100,
      height: 100,
      backgroundColor: '#0000ff',
      y: 0,
      x: 0,
      superview: this.animated
    });

    var green = this.green = new View({
      width: 100,
      height: 100,
      backgroundColor: '#00ff00',
      y: 0,
      x: 300,
      superview: this.animated
    });

    var yellow = this.yellow = new View({
      width: 100,
      height: 100,
      backgroundColor: '#ffff00',
      y: 300,
      x: 300,
      superview: this.animated
    });

    var purple = this.purple = new View({
      width: 100,
      height: 100,
      backgroundColor: '#ff00ff',
      y: 300,
      x: 0,
      superview: this.animated
    });

    var runAnimations = function () {
      animate(red)
        .now({r: 0}, 0)
        .then({r: 2 * Math.PI}, 1000, animate.linear);
      animate(blue)
        .now({ x: 0, y: 0 }, 0)
        .then({ x: 300, y: 0}, 250, animate.linear)
        .then({ x: 300, y: 300}, 250, animate.linear)
        .then({ x: 0, y: 300}, 250, animate.linear)
        .then({ x: 0, y: 0}, 250, animate.linear);
      animate(green)
        .now({ x: 300, y: 0}, 0)
        .then({ x: 300, y: 300}, 250, animate.linear)
        .then({ x: 0, y: 300}, 250, animate.linear)
        .then({ x: 0, y: 0}, 250, animate.linear)
        .then({ x: 300, y: 0}, 250, animate.linear);
      animate(yellow)
        .now({ x: 300, y: 300}, 0)
        .then({ x: 0, y: 300}, 250, animate.linear)
        .then({ x: 0, y: 0}, 250, animate.linear)
        .then({ x: 300, y: 0}, 250, animate.linear)
        .then({ x: 300, y: 300}, 250, animate.linear);
      animate(purple)
        .now({ x: 0, y: 300}, 0)
        .then({ x: 0, y: 0}, 250, animate.linear)
        .then({ x: 300, y: 0}, 250, animate.linear)
        .then({ x: 300, y: 300}, 250, animate.linear)
        .then({ x: 0, y: 300}, 250, animate.linear);
    };

    runAnimations();
    setInterval(runAnimations, 1000);

  };

  this.toBase64 = function toBase64 () {
    var canvas = new Canvas({
      width: 400,
      height: 400
    });

    var ctx = canvas.getContext('2D');

    // Save position of animated view and restore after render.
    var as = this.animated.style;
    var x = as.x;
    var y = as.y;
    as.x = 0;
    as.y = 0;

    this.animated.__view.wrapRender(ctx, {});

    as.x = x;
    as.y = y;

    var url = canvas.toDataURL('image/png');
    if (IS_NATIVE) {
      return 'data:image/png;base64,' + url;
    }

    return url;
  };


  this.launchUI = function () {};
});
