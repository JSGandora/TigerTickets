This is a outline the API provided by the backend.

GET /shows
response: Sample in shows.sample.json
description: Provides a json feed containing all the current shows that are coming up. A sample of this json data can be found in shows.sample.json

POST /buy
authentication: required
body: json object containing a show_id field whos value is the show_id that this buy request is for.
response: json object containing a buy_request_id field.
description: Makes a buy request.

POST /cancel-buy 
authentication: required 
body: json object containing a buy_request_id for the request to be canceled.
response: json object containing a status field that is set to the string "success".
description: Cancels a buy request.

POST /sell
authentication: required
body: json object containing a show_id field whos value is the show_id that this sell request is for.
response: json object containing a sell_request_id field.
description: Makes a sell request.

POST /cancel-sell
authentication: required
body: json object containing a sell_request_id for the request to be canceled.
response: json object containing a status field that is set to the string "success".
description: Cancels a sell request.

GET /my-tix
authentication: required
response: json object containing a list of all active buy and sell requests and their status in addition to the relavant shows the requests are for. Sample in my-tix.sample.json
description: Gets information about a users current requests.
