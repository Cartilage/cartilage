(function($) {

  $.fn.centerPoint = function()
  {
    return {
      x: this.position().left + (this.outerWidth(true) / 2),
      y: this.position().top + (this.outerHeight(true) / 2)
    };
  };

  $.fn.containsPoint = function(point)
  {
    var position = this.position(),
        left     = position.left,
        top      = position.top,
        width    = this.outerWidth(true),
        height   = this.outerHeight(true);

    return (point.x >= left &&
      point.x <= (left + width) &&
      point.y >= top &&
      point.y <= (top + height));
  };

  $.fn.overlapped = function(x, y, width, height)
  {
    var left   = $(this).position().left,
        top    = $(this).position().top,
        right  = left + $(this).outerWidth(),
        bottom = top + $(this).outerHeight();

    return (((x >= left && x <= right) ||
      (x + width >= left && x + width <= right) ||
      (left >= x && left <= x + width)) &&
      ((y >= top && y <= bottom) ||
      (y + height >= top && y + height <= bottom) ||
      (top >= y && top <= y + height)));
  };

})(jQuery);
