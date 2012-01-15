function removeElementById(id){
    var elem = document.getElementById(id);
    if(elem){
        elem.parentNode.removeChild(elem);
    }
}

removeElementById("gb");
removeElementById("gt-logo");
removeElementById("gt-ft-mkt");
removeElementById("select_document");
removeElementById("gt-res-tip");
document.getElementById("ft-r").innerHTML = "Powered by Google";
