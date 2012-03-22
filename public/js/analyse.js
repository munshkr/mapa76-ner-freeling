$(function() {


  /*
  $(".tokens").selectable({
    filter: ".tk",
    selected: function(event, ui) {
      //console.log("selected: ui = " + $.map(ui, function(e) { return $(e).data("pos") }));
    },
  });

  var start_tk = null, last_tk = null;

  $(".tokens").selectable({
    filter: ".tk",
    selected: function(event, ui) {
      //console.log("selected: ui = " + $.map(ui, function(e) { return $(e).data("pos") }));
    },
    start: function(event, ui) {
    },
    selecting: function(event, ui) {
      if (!start_tk) {
        start_tk = ui.selecting;
      }
      last_tk = ui.selecting;
      if (start_tk != last_tk) {
        var filter = 'span[data-pos="' + $(last_tk).data("pos") + '"]';
        if ($(start_tk).data("pos") < $(last_tk).data("pos")) {
          $(start_tk).nextUntil(filter).filter(".tk").addClass("ui-selecting");
        } else {
          $(start_tk).prevUntil(filter).filter(".tk").addClass("ui-selecting");
        }
      }
      console.log("start_tk.pos = " + $(start_tk).data("pos") + ", last_tk.pos = " + $(last_tk).data("pos"));
    },
    unselecting: function(event, ui) {
      console.log("unselected " + $(ui.unselecting).data("pos"));
    },
    stop: function(event, ui) {
      start_tk = last_tk = null;
    }
  });
  */





  /*
  window.Document = Backbone.Model.extend({

  });

  window.NamedEntitySet = Backbone.Model.extend({

  });

  window.NamedEntity = Backbone.Model.extend({

  });

  */

});

/*
Array.prototype.max = function(callback) {
  return Math.max.apply(this, this.map(callback));
};

Array.prototype.min = function(callback) {
  return Math.min.apply(this, this.map(callback));
};
*/
