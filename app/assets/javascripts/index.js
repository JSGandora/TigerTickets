// Initialize netid and ticketing data structures
var netid = "" // netid of the current user
var data = { "shows" : [] } // shows data structure retrieved from the GET api call
var fullData = { "shows" : [] } // full data structure of shows after processing from the GET api call

// Function to filter the shows according to a search term
function genFilteringPredicate(searchTerm) {
	search = searchTerm.toLowerCase()
	keywords = search.split(' ')
	  return function(show) {
	    return keywords.every(function(keyword) {
	      return show['group'].toLowerCase().includes(keyword)
	       || show['location'].toLowerCase().includes(keyword)
	       || show['name'].toLowerCase().includes(keyword)
	       || show['weekDay'].toLowerCase().includes(keyword)
	       || show['month'].toLowerCase().includes(keyword)
	       || show['dayOfMonth'].toString().toLowerCase().includes(keyword)
	       || show['hour'].toString().toLowerCase().includes(keyword)
	       || show['ampm'].toLowerCase().includes(keyword)
	       || show['min'].toString().toLowerCase().includes(keyword)
	       || show['time'].toLowerCase().includes(keyword)

	    })
	}
}

// Render search bar appearance and functionality
$('#show-search-bar').on('input', function(event) {
	var searchTerm = $('#show-search-bar').val()

	// Show all the shows if there is no text in search bar
	if (searchTerm === "") {
	  data['shows'] = fullData['shows']
	  updateShows()
	  return
	}
	data['shows'] = fullData['shows'].filter(genFilteringPredicate(searchTerm))
	updateShows()
})

// List of days of the week abbreviations
var weekday = new Array(7);
weekday[0] =  "SUN";
weekday[1] = "MON";
weekday[2] = "TUE";
weekday[3] = "WED";
weekday[4] = "THU";
weekday[5] = "FRI";
weekday[6] = "SAT";

// List of abbreviations for month names
var monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
"JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
];

// Append a zero character before i
function addZero(i) {
	if (i < 10) {
	    i = "0" + i;
	}
	return i;
}

// Add date fields to the shows data structure
function addDateDataToShows(originalShows) {
	// This code makes the function slower but keeps it pure so it doesn't tamper with originalData.
	// Because of how it will be called, purity doesn't matter.
	// var result = originalData.slice(0)
	return originalShows.map(function(show) {
	  var date = new Date(0)
	  date.setUTCSeconds(show['time'])
	  var weekDay = weekday[date.getDay()]
	  var month = monthNames[date.getMonth()]
	  var dayOfMonth = date.getDate()
	  var year = date.getFullYear()
	  var hour = date.getHours() % 12 // Convert from the 24h format.
	  var ampm = Math.floor(date.getHours() / 12) == 0 ? 'AM' : 'PM'
	  var min = addZero(date.getMinutes());
	  var time = hour+":"+min+" "+ampm;
	  show['weekDay'] = weekDay
	  show['month'] = month
	  show['year'] = year
	  show['dayOfMonth'] = dayOfMonth
	  show['hour'] = hour
	  show['ampm'] = ampm
	  show['min'] = min
	  show['time'] = time
	  return show
	})
}

// Function to process the shows data structure returned from the GET call
function callbackShows(response, textStatus, xhr) {
	// Update the data variable
	showResponseData = response['shows']
	if (showResponseData !== null) {
		fullData['shows'] = addDateDataToShows(showResponseData)
		data['shows'] = fullData['shows'].slice(0)
	}
	
	netid = response['netid']

	// Render the Logout/Login button according to the presence of a netid
	var text = "<a id='logout' href='javascript:void(0)'> Logout ("+netid+") </a>"
	if(netid == null){
	text = "<a href='login'> Login </a>"
	}

	$("#logoutLink").html(text);

	$("#logout").click(function(){
	$.post('logout');
	});

	// Update the shows on the page
	if ($.isReady) {
	  updateShows()
	} else {
	  $(function() { updateShows() })
	  }
}


$.get('shows', callbackShows)


var show_html = "" // The html for rendering all the shows
var hot_html = "" // The html for rendering all the popular shows

// Update the shows on the page
function updateShows() {
	show_html = ""
	hot_html = ""
	popularShowCount = 0
	length = 0
	
	// Get total number of shows
	if (data["shows"] !== null) {
		length = data["shows"].length
	}

	// Generate the html for all shows and popular shows
	for (i = 0; i < length; i++) {
		var show = data["shows"][i]

		// Remove descriptions of group names that contain the string "SOLD OUT" or "ticket"
		// because the group names are not present in those strings 
		var group = show["group"];
		if(group.search("SOLD OUT") >= 0 || group.search("ticket") >= 0){
			group = "";
		}
		var timing = show.weekDay+" · "+show.month+" "+show.dayOfMonth+" "+show.year+" · "+show.hour+":"+show.min+" "+show.ampm

		// Generate buy button html
		var buy_text = "Buy"
		if (show["sellreq"] == 1)
			buy_text += " <b>("+show["sellreq"]+" Seller!)</b>"
		else if(show["sellreq"] > 1)
			buy_text += " <b>("+show["sellreq"]+" Sellers!)</b>"

		// Generate sell button html
		var sell_text = "Sell"
		if(show["buyreq"] == 1)
			sell_text += " <b>("+show["buyreq"]+" Buyer!)</b>"
		if(show["buyreq"] > 1)
			sell_text += " <b>("+show["buyreq"]+" Buyers!)</b>"

		// Generate buy and sell buttons
		var buysellbuttons = "<button class='btn btn-primary showBuy"+i+"' data-target='#confirmBuyModal' data-toggle='modal'>"+buy_text+"</button> <button class='btn btn-default showSell"+i+"' data-target='#confirmSellModal' data-toggle='modal'>"+sell_text+"</button>"
		if(netid === "")
		{
			buysellbuttons = "<a href='login'><button class='btn btn-primary showBuy"+i+"' data-target='#confirmBuyModal'>"+buy_text+"</button></a> <a href='login'><button class='btn btn-default showSell"+i+"' data-target='#confirmSellModal'>"+sell_text+"</button></a>";
		}

		// Generate the entire ticket html
		var grayurl = "https://cdn.evbuc.com/eventlogos/298207/1478813947tickets.png" // Default ticket image
		var imghtml = "<img src="+grayurl+" alt='' style = 'height:100px'>"
		if(!(show["image"] === ""))
			imghtml = "<img src="+show["image"]+" alt='' style = 'height:100px'>"

		// Generate ticket html depending on whether there is a gropu name or not
		if (group == "") {
			html = "<div class='col-md-3 col-sm-6 hero-feature' id = 'ticketPanel'>"+
			"<div class='panel' style='height:400px'>"+
			"<br><br>"+
			"<h3><strong>"+show["name"]+"</strong></h3>"+
			imghtml+
			"<div class='caption'>"+
			"<h5>"+timing+"</h5>"+
			"<h5><strong>"+show["location"]+"</strong></h5>"+
			"<p>"+buysellbuttons+"</p>"+
			"</div>"+
			"</div>"+
			"</div>"
		}
		else {
			html = "<div class='col-md-3 col-sm-6 hero-feature' id = 'ticketPanel'>"+
			"<div class='panel' style='height:400px'>"+
			"<h4><i>"+group+"</i></h4>"+
			"<p><i>presents</i></p>"+
			"<h3><strong>"+show["name"]+"</strong></h3>"+
			imghtml+
			"<div class='caption'>"+
			"<h5>"+timing+"</h5>"+
			"<h5><strong>"+show["location"]+"</strong></h5>"+
			"<p>"+buysellbuttons+
			"</p>"+
			"</div>"+
			"</div>"+
			"</div>"
		}

		// Update show_html
		show_html += html

		// If a show has sell or buy requests and there is no search currently, add them to popular shows.
		// To add a cap to popular shows append this to the if statement: && popularShowCount < 4
		if((show["soldout"] || show["buyreq"] > 0 || show["sellreq"] > 0) && $('#show-search-bar').val() == "") {
			popularShowCount += 1
		hot_html += html
		}
	}

	// Add the header only if there are some popular shows.
	if (hot_html != "") {
	  hot_html = "<center><img class='title' src='http://i.imgur.com/1fGzTGO.png'></center><br>" + hot_html
	}

	show_html = "<center><img class='title' src='http://i.imgur.com/BDeLYNh.png'></center><br>" + show_html

	$("#ticket-listing").html(show_html)
	$("#hot-tickets").html(hot_html)



	for (i = 0; i < data["shows"].length; i++) {
	    (function(index) {$(".showBuy" + i).click(function(){
	      console.log("lol");
	      message = "";
	      if (data["shows"][index]['soldout'] === true || data["shows"][index]['sellreq'] !== 0){
	      	message = "<h2>Confirm Ticket Buy Request?</h2><h5> You are about to confirm your buy request for:</h5>";
	      }
	      else{
	      	message = "<h2> Attention! </h2><h4> Tickets are still available to purchase at the <a href='" + data["shows"][index]["buy_link"] 
	      	message += "'target='_blank'>" + data["shows"][index]["office_from"] + " Ticket Office</a></h4>"
	      	message += "<h3> Or you can continue with your buy request for: </h3>"
	      }
	      var btime = data["shows"][index]['weekDay']+" · "+data["shows"][index]['month']+" "+data["shows"][index]['dayOfMonth']+" "+data["shows"][index]['year']+" · "+data["shows"][index]['time']
	      message += "<h5><strong>" + data["shows"][index]["name"] + "<br />" + btime + "<br />" + data["shows"][index]["location"] + "</strong>.</h5>";
	      $("#confirmBuyBody").html(message)
	      $("#deleteButtonBuyModal").attr("show-id", data["shows"][index]['id'])
	      });
	    })(i);
	}
	for (i = 0; i < data["shows"].length; i++) {
	    (function(index) {$(".showSell" + i).click(function(){
	      var btime = data["shows"][index]['weekDay']+" · "+data["shows"][index]['month']+" "+data["shows"][index]['dayOfMonth']+" "+data["shows"][index]['year']+" · "+data["shows"][index]['time']
	      message = "<h5><strong>" + data["shows"][index]["name"] + "<br />" + btime + "<br />" + data["shows"][index]["location"] + "</strong>.</h5>";
	      $("#confirmSellBody").html(message)
	      $("#deleteButtonSellModal").attr("show-id", data["shows"][index]['id'])
	      });
	    })(i);   
	}
}


function putInBuyRequest(element) {
	console.log("you are selling")
	$.ajax({
	url : "/buy",
	type: "POST",
	data: JSON.stringify({show_id: element.getAttribute('show-id')}),
	contentType: "application/json; charset=utf-8",
	dataType   : "json",
	success    : function(data){
	  if (data['status'] == "ok") {
	    window.location = '/my-tix'
	  } else {
	    window.alert("There was an error submitting your buy request: " + data['reason'])
	  }
	}})
}

function putInSellRequest(element) {

	console.log("you are buying")
	$.ajax({
	url : "/sell",
	type: "POST",
	data: JSON.stringify({show_id: element.getAttribute('show-id')}),
	contentType: "application/json; charset=utf-8",
	dataType   : "json",
	success    : function(data){
	  if (data['status'] == "ok") {
	    window.location = '/my-tix'
	  } else {
	    window.alert("There was an error submitting your sell request: " + data['reason'])
	  }
	}})
}

function feedbackSubmitted() {
	// Put the code for sucessful feedback submission here.
	console.log("feedback function called.")
}

function submitFeedback(element) {
	$.ajax({
	url : "/feedback",
	type: "POST",
	data: JSON.stringify({"name": $("#feedback-name").val(), "email": $("#feedback-email").val(), "comment": $("#feedback-comment").val()}),
	contentType: "application/json; charset=utf-8",
	dataType   : "json",
	success    : function(data){
	  if (data['status'] == "ok") {
	    feedbackSubmitted()
	  } else {
	    window.alert("There was an error submitting your feedback: " + data['reason'])
	  }
	}})
}

var count = 0;
function toggle_visibility() {
   var e = document.getElementById('feedback-main');
   if(e.style.display == 'block')
   {
      e.style.display = 'none';
      count = 0;
   }
   else
   {
      e.style.display = 'block';
      count = 1;
   }
}

// $(function() {
//     var f = document.getElementById('feedback-main');
//     $("body").click(function(e) {
//     	console.log(count)
//     	console.log(f.style.display)
//         if (e.target.id  == "feedback-div" || $(e.target).parents("#feedback-div").size()) { 
//         } else { 
//         	if(count == 1){
//         		count = 2;
//         		f.style.display = 'block'
//         		console.log("Now we are displaying the modal")
//         	}
//         	else if(count == 2){
//         		count = 0;
//         		f.style.display = 'none'
//         		console.log("Now we are closing the modal")
//         	}
//         }
//     });
// })


$(document).ready(function(){
});