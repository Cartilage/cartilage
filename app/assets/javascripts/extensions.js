
(function() {

  //
  // Iterates over an array of numbers and returns the sum. Example:
  //
  //    _.sum([1, 2, 3]) => 6
  //
  _.sum = function(obj) {
    if (!$.isArray(obj) || obj.length === 0) return 0;
    return _.reduce(obj, function(sum, n) {
      return sum += n;
    });
  };

})();
