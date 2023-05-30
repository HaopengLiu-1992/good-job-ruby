function Backfill(json) {
  angular.extend(this, json);
}

angular.extend(Backfill.prototype, {
  information: function() {
    var types = this.children.map(function(c) {
      return c.type;
    });
    var shards = this.children.map(function(c) {
      return c.shard;
    });

    return jQuery.unique(types).join(",") +
           " on shard(s) " +
           jQuery.unique(shards).join(",");
  },
  progress: function() {
    return "" + this.indexed + " of " + this.to_index;
  },
  totalProgress: function() {
    let totalPercent = ((this.indexed / this.to_index) * 100).toFixed(2);
    if (this.children.length > 1) {
      let currentIndex = this.children.filter(index => !index.done)[0];
      let currentPercent = ((currentIndex.indexed / currentIndex.to_index) * 100).toFixed(2);
      return "" + currentIndex.indexed + " of " + currentIndex.to_index + " — " + currentPercent + "%" +
          " (Total: " + this.indexed + " of " + this.to_index + " — " + totalPercent + "%)";
    }
    return "" + this.indexed + " of " + this.to_index + " — " + totalPercent + "%";
  },
  percentComplete: function() {
    if (this.to_index === 0 || isNaN(this.to_index)) {
      return (100).toFixed(2);
    } else {
      return ((this.indexed / this.to_index) * 100).toFixed(2);
    }
  },
  indexStatus: function() {
    let jobs = this.children.length;
    let completedJobs = this.children.filter(index => index.done).length;
    if (jobs > 1) {
      return "" + (completedJobs + 1) + " of " + jobs;
    }
    if (jobs === 1) {
      return this.children[0].collection_number;
    }
    return "";
  },

  complete: function() {
    return percentComplete >= 100;
  }
});

function ReindexCollectionShard(json) {
  angular.extend(this, json);
}

function ReindexCollection(json) {
  angular.extend(this, json);
  this.children = this.children.map(function(shard) {
    return new ReindexCollectionShard(shard);
  });
}

function Reindex(json) {
  angular.extend(this, json);
  this.children = this.children.map(function(col) {
    return new ReindexCollection(col);
  });
}


angular.extend(ReindexCollectionShard.prototype, Backfill.prototype, {
  information: function() {
    //console.log("%O", this);
    return "shard " + this.children[0].shard;
  }
});

angular.extend(ReindexCollection.prototype, Backfill.prototype, {
  information: function() {
    return "collection #" + this.collection_number;
  }
});
angular.extend(Reindex.prototype, Backfill.prototype);
