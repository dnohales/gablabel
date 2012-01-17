(function(){
    var currentHash = window.location.hash;
    var indexOfSecondSeparator = currentHash.indexOf("|", currentHash.indexOf("|") + 1);
    var newHash = currentHash.substring(0, indexOfSecondSeparator+1) + encodeURIComponent("@SOURCE_TEXT@");
    
    var newLocation = window.location.href.replace(currentHash, "");
    newLocation += newHash;
    window.location.replace(newLocation);
})();
