//Get the netid of the user and renders the Login/Logout butto accordingly.
$.get("/shows", function(response){
	netid = response["netid"];
	var text = "<a id='logout' href='javascript:void(0)'> Logout ("+netid+") </a>"
	if(netid == null){
		text = "<a href='login'> Login </a>"
	}
	$("#logoutLink").html(text);

	$("#logout").click(function(){
	$.post('logout');
	});
})