function removeElementById(id){
    var elem = document.getElementById(id);
    if(elem){
        elem.parentNode.removeChild(elem);
    }
}

function safeElemHandle(id, handler){
	var elem = document.getElementById(id);
	if(elem){
		handler(elem);
	}
}

removeElementById("gb");
removeElementById("gt-logo");
removeElementById("gt-ft-mkt");
removeElementById("select_document");
removeElementById("gt-res-tip");
setTimeout(function(){
	removeElementById("gt-bbar-c");
},1000);

safeElemHandle("gt-res-dict", function(elem){
	elem.style.marginTop = "0em";
});
safeElemHandle("ft-r", function(elem){
	elem.innerHTML = "Powered by Google";
});

