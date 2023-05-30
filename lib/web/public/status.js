function StatusCtrl($scope) {
  $scope.reindexCollapses = $scope.reindexCollapses || {};

  var refresh = function() {
    var deferred = jQuery.getJSON('/api/v1/status');

    deferred.done(function(json) {
      $scope.hosts = json.hosts.map(function(h) {
        return new Host(h);
      });
      $scope.incrementals = json.incrementals;

      $scope.backfills = json.backfills.map(function(b) {
        return new Backfill(b);
      });

      $scope.reindexes = json.reindexers.map(function(r) {
        r.collapseClass = $scope.reindexCollapses[r.key] ? ".in" : "";
        return new Reindex(r);
      });

      $scope.completedReindexes = $scope.reindexes.filter(v => v.done);
      $scope.activeReindexes = $scope.reindexes.filter(v => !v.done);

      $scope.$apply();
    });

    deferred.always(function() {
      setTimeout(refresh, 5000);
    });
  };

  refresh();

  $scope.collapseReindex = function(key) {
    $scope.reindexCollapses[key] = !$scope.reindexCollapses[key];
  };

  $scope.hosts = [];
}
