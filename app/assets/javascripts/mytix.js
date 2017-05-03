
    

<!-- Generate Buy Data -->
    var allData = {"requests" : [] }
    var data = {"requests" : [] }
    var netid = ""
    $.get('my-tix-data', function(response) { 
        allData = response
        netid = response["netid"]
        formatLogoutButton()
        if ($.isReady) {
          updateRequests()
        } else {
          $(function() { updateRequests() })
        }
    })

    function addZero(i) {
        if (i < 10) {
            i = "0" + i;
        }
        return i;
    }
    var weekday = new Array(7);
      weekday[0] =  "Sunday";
      weekday[1] = "Monday";
      weekday[2] = "Tuesday";
      weekday[3] = "Wednesday";
      weekday[4] = "Thursday";
      weekday[5] = "Friday";
      weekday[6] = "Saturday";
      var monthNames = ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];

      function addDateDataToShows(originalShows) {
    // This code makes the function slower but keeps it pure so it doesn't tamper with originalData.
    // Because of how it will be called, purity doesn't matter.
    //var result = originalData.slice(0)
    return originalShows.map(function(request) {
        console.log(request)
        show = request.show;
      console.log("this is the show")
      console.log(show)
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
      show['btime'] = time + " " + weekDay
      show['date'] = month + " " + dayOfMonth + ", " + year
      request.show = show
      return request
    })
  }
  
  function callbackRequests(response, textStatus, xhr) {
    allData['buyrequests'] = addDateDataToShows(response['buyrequests'])
    data['buyrequests'] = allData['buyrequests'].slice(0)
    allData['sellrequests'] = addDateDataToShows(response['sellrequests'])
    data['sellrequests'] = allData['sellrequests'].slice(0)
    if ($.isReady) {
      updateRequests()
    } else {
      $(function() { updateRequests() })
      }
  }

  $.get('my-tix-data', callbackRequests)

    var buyRequests_html = ""
    var sellRequests_html = ""

    function formatLogoutButton() {
        var text = "<a id='logout' href='javascript:void(0)'> Logout ("+netid+") </a>"
        $("#logoutLink").html(text);
        $("#logout").click(function(){
            $.post('logout');
        });
    }

    function updateRequests() {
        buyRequests_html = ""
        sellRequests_html = ""
        for (i = data["buyrequests"].length-1; i >= 0; i--) {
            var buyRequestStatus = data["buyrequests"][i]["status"]
            var show = data["buyrequests"][i]["show"]
            var bloc = show["location"]
            var bgroup = show["group"]
            if(bgroup.search("SOLD OUT") >= 0){
                bgroup = "";
            }
            
            var grayurl = "https://cdn.evbuc.com/eventlogos/298207/1478813947tickets.png"
            var imghtml = "<img class = 'center-block' src="+grayurl+" alt='' style='height:150px'>"
            if(!(show["image"] === ""))
                imghtml = "<img class = 'center-block' src="+show["image"]+" alt='' style='height:150px'>"

            var deletehtml = "<div class='col-md-2' style='color:green'>Completed</div>"
            
            if(!(buyRequestStatus === "completed")){
                deletehtml = "<div class='col-md-2'>"+
                        "<button class='btn btn-danger' data-target='#confirm-buy-delete' data-toggle='modal' id = 'deleteBuying"+i+"'>Delete<span class='glyphicon'></span></button><br><br><br><br>"+
                        "<button class='btn btn-primary' data-target='#confirm-buy-confirm' data-toggle='modal' id = 'confirmBuying"+i+"'>Complete<span class='glyphicon'></span></button>"+
                    "</div>"

            }

            buyRequests_html += "<div class='row' id='buying"+i+"'>"+
                    "<div class='col-md-2'>"+
                        "<a href='#'>" +
                            imghtml +
                        "</a>"+
                    "</div>"+
                    "<div class='col-md-3'>"+
                        "<h3>"+show["name"]+"</h3>"+
                    "</div>"+
                    "<div class='col-md-5'>"+
                        "<h4>"+show["btime"]+"<br>"+show["date"]+"</h4>"+
                        "<h4>"+bloc+"</h4>"+
                        "<h4>"+bgroup+"</h4>"+
                    "</div>"+
                    deletehtml+
                "</div>"+
            "<hr>"
            
        }
        if (data["buyrequests"].length == 0) {
            buyRequests_html = "<p>No current buy requests.</p>"
        }
        $("#buy-requests-html-span").html(buyRequests_html)

        for (i = data["sellrequests"].length-1; i >= 0; i--) {
            var sellRequestStatus = data["sellrequests"][i]["status"]
            show = data["sellrequests"][i]["show"]
            var sbloc = show["location"]
            var sgroup = show["group"]
            if(sgroup.search("SOLD OUT") >= 0){
                sgroup = "";
            }

            var grayurl = "https://cdn.evbuc.com/eventlogos/298207/1478813947tickets.png"
            var imghtml = "<img class = 'center-block' src="+grayurl+" alt='' style='height:150px'>"
            if(!(show["image"] === ""))
                imghtml = "<img class = 'center-block' src="+show["image"]+" alt='' style='height:150px'>"

            var deletehtml = "<div class='col-md-2' style = 'color:green;'>Completed</div>"

            if(!(sellRequestStatus === "completed")){
                deletehtml = "<div class='col-md-2'>"+
                "<button class='btn btn-primary btn-danger' data-target='#confirm-sell-delete' data-toggle='modal' id = 'deleteSelling"+i+"'>Delete <span class='glyphicon'></span></button><br><br><br><br>"+
                "<button class='btn btn-primary' data-target='#confirm-sell-confirm' data-toggle='modal' id = 'confirmSelling"+i+"'>Complete<span class='glyphicon'></span></button>"+
                "</div>"
            }

            sellRequests_html += "<div class='row' id='selling"+i+"'>"+
                    "<div class='col-md-2'>"+
                        "<a href='#'>" +
                            imghtml+
                        "</a>"+
                    "</div>"+
                    "<div class='col-md-3'>"+
                        "<h3>"+show["name"]+"</h3>"+
                    "</div>"+
                    "<div class='col-md-5'>"+
                        "<h4>"+show["btime"]+"<br>"+show["date"]+"</h4>"+
                        "<h4>"+sbloc+"</h4>"+
                        "<h4>"+sgroup+"</h4>"+
                    "</div>"+
                    deletehtml+
                "</div>"+
            "<hr>"
        }
        if (data["sellrequests"].length == 0) {
            sellRequests_html = "<p>No current sell requests.</p>"
        }
        $("#sell-requests-html-span").html(sellRequests_html)

        profile = "<div class='row text-left'>"+
                "<div class='col-lg-12'>"+
                    "<img class='fit' src='http://i.imgur.com/d8b5JRU.png' style='height:30px;''>"+
                "</div>"+
            "</div>"+
            "<hr>"+
            "<span id='buy-requests-html-span'>" +
            buyRequests_html +
            "</span>" +
            "<div class='row text-left'>"+
                "<div class='col-lg-12'>"+
                    "<img class='fit' src='http://i.imgur.com/XhUTIFs.png' style='height:32px;''>"+
                "</div>"+
            "</div>"+
            "<hr>"+
            "<span id='sell-requests-html-span'>" +
            sellRequests_html +
            "</span>"
        deletionId = 0

            
        $(document).ready(function(){
            $("#profile-page").html(profile)

            
            for (i = 0; i < data["sellrequests"].length; i++) {
                // Delete a selling request
                (function(index) {$("#deleteSelling" + i).click(function(){
                    deleteSellId = "selling" + index
                    show = data["sellrequests"][index]["show"]
                    message = "<p><strong>" + show["name"] + "<br />" + show["btime"]+"<br>"+show["date"] + "<br />" + show["location"] + "</strong>.</p>";
                    $("#deletionSellBody").html(message);
                    $("#deleteSellButton").attr("show-id", data["sellrequests"][index]["id"]);
                    });
                })(i);
                // Confirm a selling request
                (function(index) {$("#confirmSelling" + i).click(function(){
                    confirmSellId = "selling" + index
                    show = data["sellrequests"][index]["show"]
                    message = "<p><strong>" + show["name"] + "<br />" + show["btime"]+"<br>"+show["date"] + "<br />" + show["location"] + "</strong>.</p>";
                    $("#confirmSellBody").html(message);
                    $("#confirmSellButton").attr("show-id", data["sellrequests"][index]["id"]);
                    });
                })(i);
            }

            
            for (i = 0; i < data["buyrequests"].length; i++) {
                // Delete a buying request
                (function(index) {$("#deleteBuying" + i).click(function(){
                    deleteBuyId = "buying" + index
                    show = data["buyrequests"][index]["show"]
                    message = "<p><strong>" + show["name"] + "<br />" + show["btime"]+"<br>"+show["date"] + "<br />" + show["location"] + "</strong>.</p>";
                    $("#deletionBuyBody").html(message)
                    $("#deleteBuyButton").attr("show-id", data["buyrequests"][index]["id"]);
                    });
                })(i);
                // Confirm a buying request
                (function(index) {$("#confirmBuying" + i).click(function(){
                    confirmBuyId = "buying" + index
                    show = data["buyrequests"][index]["show"]
                    message = "<p><strong>" + show["name"] + "<br />" + show["btime"]+"<br>"+show["date"] + "<br />" + show["location"] + "</strong>.</p>";
                    $("#confirmBuyBody").html(message) 
                    $("#confirmBuyButton").attr("show-id", data["buyrequests"][index]["id"]);
                    });
                })(i);
            }
        });
    }

    function deleteSellRequest(element) {
        console.log("you are cancelling a sell request")
        $.ajax({
            url : "/cancel-sell",
            type: "POST",
            data: JSON.stringify({sell_request_id: element.getAttribute('show-id')}),
            contentType: "application/json; charset=utf-8",
            dataType   : "json",
            success    : function(data){
                if (data['status']=="ok") {
                    window.location = '/my-tix'
                }
                else {
                    window.alert("There was an error cancelling your sell request: " + data['reason'])
                }
            }
        })
        $("#" + deleteSellId).replaceWith("<p>Request deleted.</p>")
    }

    function deleteBuyRequest(element) {
        console.log("you are cancelling a buy request")
        $.ajax({
            url : "/cancel-buy",
            type: "POST",
            data: JSON.stringify({buy_request_id: element.getAttribute('show-id')}),
            contentType: "application/json; charset=utf-8",
            dataType   : "json",
            success    : function(data){
                if (data['status']=="ok") {
                    window.location = '/my-tix'
                }
                else {
                    window.alert("There was an error cancelling your buy request: " + data['reason'])
                }
            }
        })
        $("#" + deleteBuyId).replaceWith("<p>Request deleted.</p>")
    }

    function confirmSellRequest(element) {
        console.log("you are completing a sell transaction")
        $.ajax({
            url : "/complete-sell",
            type: "POST",
            data: JSON.stringify({sell_request_id: element.getAttribute('show-id')}),
            contentType: "application/json; charset=utf-8",
            dataType   : "json",
            success    : function(data){
                if (data['status']=="ok") {
                    window.location = '/my-tix'
                }
                else {
                    window.alert("There was an error completing your sell transaction: " + data['reason'])
                }
            }
        })
        $("#" + confirmSellId).replaceWith("<p>Request confirmed.</p>")
    }

    function confirmBuyRequest(element) {
        console.log("you are completing a buy transaction")
        $.ajax({
            url : "/complete-buy",
            type: "POST",
            data: JSON.stringify({buy_request_id: element.getAttribute('show-id')}),
            contentType: "application/json; charset=utf-8",
            dataType   : "json",
            success    : function(data){
                if (data['status']=="ok") {
                    window.location = '/my-tix'
                }
                else {
                    window.alert("There was an error completing your buy transaction: " + data['reason'])
                }
            }
        })
        $("#" + confirmBuyId).replaceWith("<p>Request confirmed.</p>")
    }

    $(document).ready(function(){
    });
    
    