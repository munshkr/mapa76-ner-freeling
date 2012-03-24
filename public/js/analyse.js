Array.prototype.max = function(callback) {
  return Math.max.apply(this, this.map(callback));
};

Array.prototype.min = function(callback) {
  return Math.min.apply(this, this.map(callback));
};


$(function() {
  var start = null;
  var selecting = false;
  var available_targets = null;
  var selected_targets = null;

  var start_selection_on = function(target) {
    selected_targets = [];
    select(target);
    start = target;

    available_targets = [];
    available_targets.push(target);

    $(target).prevUntil(".ne").each(function(i, e) {
      if ($.inArray(e, available_targets) < 0) available_targets.push(e);
    });
    $(target).nextUntil(".ne").each(function(i, e) {
      if ($.inArray(e, available_targets) < 0) available_targets.push(e);
    });
    console.log("available: " + available_targets.length);

    selecting = true;
  };

  var select = function(target) {
    if ($.inArray(target, selected_targets) < 0) {
      console.log("select: " + $(target).text());
      selected_targets.push(target)
      $(target).addClass("active");
    }
  };

  var deselect = function(target) {
    var pos = $.inArray(target, selected_targets)
    if (pos >= 0) {
      console.log("deselect: " + $(target).text());
      selected_targets.splice(pos, 1);
      $(target).removeClass("active");
    }
  };

  var select_upto = function(target) {
    $.each(available_targets, function(i, e) {
      deselect(e);
    });
    select(target);
    select(start);

    var target_sel = '.tk[data-pos="' + $(target).data("pos") + '"]';
    if ($(start).data("pos") > $(target).data("pos")) {
      $(start).prevUntil(target_sel).filter(".tk").each(function(i, e) {
        select(e);
      });
    } else if ($(start).data("pos") < $(target).data("pos")) {
      $(start).nextUntil(target_sel).filter(".tk").each(function(i, e) {
        select(e);
      });
    }
  };


  $(document)
    .mouseup(function(event) {
      console.log("up");

      selecting = false;
      $.each(selected_targets, function(i, e) {
        $(e).removeClass("active");
        $(e).addClass("dropped");
        console.log("selected: " + $(e).data("pos"));
      });
    });

  $(".tk")
    .mousedown(function(event) {
      if (event.button === 0) {
        console.log("down");
        start_selection_on(this);
      }
    })
    .mouseenter(function(event) {
      if (selecting) {
        if ($.inArray(this, available_targets) >= 0) {
          select_upto(this);
        }
      }
    })
    .mouseleave(function(event) {
      if (selecting) {
        deselect(this);
      }
    })

});
