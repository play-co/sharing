Devkit Sharing
==============

devkit plugin for accessing native share

**WARNING:** iOS Support Only

![devkit_sharing](https://cloud.githubusercontent.com/assets/4285147/6118630/76cadad8-b074-11e4-9c87-cb76b792e341.png)

## Usage

### Installation

In your devkit app directory, run
`devkit install https://github.com/gameclosure/devkit-sharing`.

### JavaScript

First, import the sharing plugin

```js
// Need to import the plugin
import Sharing;

// Some time later in the application
Sharing.share({
  message: 'This message brought to you by devkit sharing',
  image: '' // optional data uri - see test app for demo
}, function (completed) {
  // Sharing was canceled if completed is false
});
```

## TODO

- Android support
