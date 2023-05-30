function Host(json) {
  angular.extend(this, json);
}

angular.extend(Host.prototype, {
  /* takes the list of shards a host is responsible for and collapses them into runs,
   * ie shards: [1,2,3,4,5,6,9,10] -> ["1-6", "9-10"] */

  formattedShards: function() {
    var i, currArray, lastValue,
      shards = this.shards.sort(),
      res = [[shards[0]]], currArray, lastValue;

    for(i = 1; i < shards.length; i++) {
      currArray = res[res.length - 1];
      lastValue = currArray[currArray.length - 1];

      if ( shards[i] == lastValue + 1 ) {
        currArray.push(shards[i]);
      } else {
        res.push([ shards[i] ]);
      }
    }

    return res.map(function(array) {
      if ( array.length == 1 ) {
        return "" + array[0];
      } else {
        return "" + array[0] + "-" + array[array.length - 1];
      }
    }).join(",");
  },

  formattedBackend: function() {
    if ( this.backend == "es" ) {
      return "Elasticsearch";
    }
  }
});


