function BackfillCtr($scope) {
  $scope.triggerBackfill = function() {
    $scope.statusReport = false;
    $scope.success = undefined;
    $scope.failed = undefined;

    var deferred = $.post('/api/v1/backfills',
      JSON.stringify({
        shard: this.toShard,
        from_shard: this.fromShard || this.toShard,
        name: this.name,
        types: this.types,
        accounts: this.accounts
      }),
      null,
      'json'
    )
    .done(function(data) {
      $scope.statusReport = true;
      $scope.toShard = $scope.fromShard = $scope.types = $scope.name = $scope.accounts = "";
      $scope.success = true;
      $scope.backfillId = data.id;
      $scope.backfillUrl = data.url;
    })
    .error(function(jqxhr) {
      $scope.statusReport = true;
      $scope.failed = true;
      $scope.error = jqxhr.status + ' ' + jqxhr.statusText;
      $scope.errorMessage =jqxhr.responseJSON.message;
    });
  };
}
