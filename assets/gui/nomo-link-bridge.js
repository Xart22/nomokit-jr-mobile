(function () {
  if (window.__nomoLinkBridgeInstalled) return;
  window.__nomoLinkBridgeInstalled = true;

  function isLinkUrl(url) {
    return /^ws:\/\/127\.0\.0\.1:20111\/openblock\/(ble|bt|serialport)$/.test(
      url || ''
    );
  }

  var NativeWebSocket = window.WebSocket;
  console.log('NOMO_BRIDGE_INSTALLED');

  function NomoLinkSocket(url, protocols) {
    var self = this;
    var type = 'unknown';
    var m = /\/openblock\/(ble|bt|serialport)$/.exec(url || '');
    if (m) type = m[1].toUpperCase();
    self.__nomoType = type;
    self.__nomoId = 'link-' + Math.random().toString(36).slice(2);
    console.log('NOMO_SOCKET', type);

    self.readyState = 0; // CONNECTING
    self.CONNECTING = 0;
    self.OPEN = 1;
    self.CLOSING = 2;
    self.CLOSED = 3;

    var onopen = null;
    var onclose = null;
    var onerror = null;
    var onmessage = null;
    var messageHandler = null;

    Object.defineProperty(self, 'onopen', {
      get: function () { return onopen; },
      set: function (fn) { onopen = fn; }
    });
    Object.defineProperty(self, 'onclose', {
      get: function () { return onclose; },
      set: function (fn) { onclose = fn; }
    });
    Object.defineProperty(self, 'onerror', {
      get: function () { return onerror; },
      set: function (fn) { onerror = fn; }
    });
    Object.defineProperty(self, 'onmessage', {
      get: function () { return onmessage; },
      set: function (fn) { onmessage = fn; }
    });

    self.setOnOpen = function (fn) {
      onopen = fn;
    };
    self.setOnClose = function (fn) {
      onclose = fn;
    };
    self.setOnError = function (fn) {
      onerror = fn;
    };
    self.setHandleMessage = function (fn) {
      messageHandler = fn;
    };

    self.sendMessage = function (msg) {
      var text = typeof msg === 'string' ? msg : JSON.stringify(msg);
      console.log('NOMO_SEND', type, text);
      window.flutter_inappwebview.callHandler(
        'nomoLinkSend',
        { socketId: self.__nomoId, type: type, msg: text }
      );
    };

    self.send = function (msg) {
      self.sendMessage(msg);
    };

    self.open = function () {
      self.readyState = self.OPEN;
      console.log('NOMO_OPEN', type);
      if (onopen) onopen({ type: 'open', target: self });
    };

    self.close = function () {
      if (self.readyState === self.CLOSED) return;
      self.readyState = self.CLOSED;
      window.flutter_inappwebview.callHandler(
        'nomoLinkClose',
        { socketId: self.__nomoId, type: type }
      );
      if (onclose) onclose({ type: 'close', target: self });
    };

    self.isOpen = function () {
      return self.readyState === self.OPEN;
    };

    self._deliver = function (json) {
      if (onmessage) {
        var data = { data: JSON.stringify(json), target: self };
        onmessage(data);
      } else if (messageHandler) {
        messageHandler(json);
      }
    };

    if (!window.__nomoLinkSockets) window.__nomoLinkSockets = {};
    window.__nomoLinkSockets[self.__nomoId] = self;

    // ScratchLinkWebSocket assigns onopen/onmessage AFTER construction, then
    // expects the browser WebSocket constructor to auto-connect and fire onopen.
    // Defer open so handlers are attached first.
    setTimeout(function () {
      self.open();
    }, 0);
  }

  function handleFlutterMessage(event) {
    var data = event && event.data;
    if (typeof data !== 'string') return;
    try {
      var envelope = JSON.parse(data);
    } catch (e) {
      return;
    }
    if (!envelope || envelope.nomoLink !== true) return;
    var socket = window.__nomoLinkSockets && window.__nomoLinkSockets[envelope.id];
    if (!socket) return;
    try {
      socket._deliver(JSON.parse(envelope.response));
    } catch (e) {}
  }

  window.addEventListener('message', handleFlutterMessage);

  window.WebSocket = function (url, protocols) {
    if (isLinkUrl(url)) return new NomoLinkSocket(url, protocols);
    return new NativeWebSocket(url, protocols);
  };
  window.WebSocket.prototype = NativeWebSocket.prototype;
  window.WebSocket.CONNECTING = 0;
  window.WebSocket.OPEN = 1;
  window.WebSocket.CLOSING = 2;
  window.WebSocket.CLOSED = 3;
})();
