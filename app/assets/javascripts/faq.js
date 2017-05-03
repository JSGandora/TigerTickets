$.get("/shows", function(response){
	netid = response["netid"];
		console.log(netid)
	var text = "<a id='logout' href='javascript:void(0)'> Logout ("+netid+") </a>"
	if(netid == null){
		text = "<a href='login'> Login </a>"
	}
	$("#logoutLink").html(text);

	$("#logout").click(function(){
	$.post('logout');
	});
})