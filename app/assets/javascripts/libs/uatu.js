(function() {
  var Uatu = {

    events : {},

    on : function (event_name, fn, once) {
      if (once == undefined) {
        once = false;
      }

      if (!(event_name in this.events)) {
        this.events[event_name] = [];
      }

      if (once) {
        this.events[event_name] = [fn];
      }
      else {
        this.events[event_name].push(fn);
      }
    },

    off : function(event_name, all) {
      if (all == undefined) {
        all = false;
      }

      if (all) {
        this.events[event_name] = [];
      }
      else {
        this.events[event_name].pop();
      }
    },

    fire : function(event_name, scope) {
      var scope = scope || window,
      fn_arguments = Array.prototype.slice.apply(arguments).slice(2),
      fns = this.events[event_name],
      length = fns.length,
      i = 0;

      for (i; i < length; i++) {
        fn = fns[i];

        fn.apply(scope, fn_arguments);
      }
    },

    clear : function() {
      this.events = {};
    }

  };

  window.Uatu = Uatu;
})();