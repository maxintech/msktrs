// CTS.JS

// ID: toc_modal
function loadModalTable(title, username, data, usePlays) {
  $("#toc_modal_title").text(title);

  $("#toc_modal_body").empty();
  html1 = `
		  <h5 class="text-center">${username}</h5>
          <table class="table table-striped" id="tblGrid">
            <thead id="tblHead">
              <tr>
                <th>Game</th>
                <th>Plays</th>
              </tr>
            </thead>
            <tbody>
  `;   
  html2 = "";
  $.each(data, function(idx, play) {
    x = (usePlays) ? play.plays : play.victories;
    aux = `<tr><td>${play.gameName}</td><td class="text-center">${x}</td></tr>`;
    html2 = html2 + aux;
  });
  html3 = `</tbody></table>`;

  $("#toc_modal_body").append(html1+html2+html3);
}

function createCharts(sdata) {
  var colors = ['#007bff','#28a745','#333333','#c3e6cb','#dc3545','#6c757d', '#00b3ff', '#d3e0bf', '#b99fbf', '#d11c0f'];
  var ctx;
  var labels, dataset, dataSize;

  part1 = `
      <div class="container my-3 p-3 bg-white rounded shadow-sm">
        <div class="h5">Group stats</div>
        <div class="row py-2">
          <div class="col-md-6 py-1">
            <div class="card">
              <div class="card-body">
                  <canvas id="gamesByPlaysChart"></canvas>
              </div>
            </div>
          </div>

          <div class="col-md-6 py-1">
            <div class="card">
              <div class="card-body">
                  <canvas id="bggRankingGroupedChart"></canvas>
              </div>
            </div>
          </div>
        </div>
        <div class="row py-2">
          <div class="col-md-6 py-1">
            <div class="card">
              <div class="card-body">
                  <canvas id="bggWeightGroupedChart"></canvas>
              </div>
            </div>
          </div>

          <div class="col-md-6 py-1">
            <div class="card">
              <div class="card-body">
                  <canvas id="bggCategoriesGroupedChart"></canvas>
              </div>
            </div>
          </div>
        </div>
      </div>
  `;
  // Addto "charts" div
  $("#charts").append(part1);

  // gamesByPlays Chart
  labels = [];
  dataset = [];
  dataSize = 0;
  $.each(sdata.stats.gamesByPlays, function(k, v) {
    var plays = (k == 1) ? "play" : "plays";
    labels.push(`${k} ${plays}`);
    dataset.push(v.size); 
    dataSize++;
  });
  data = { 
    "labels" : labels,
    "datasets" : [{
      "data" : dataset,
      "backgroundColor" : colors.slice(0,dataSize),
      "borderWidth" : 0
    }]
  };
  options = {
    "cutoutPercentage" : 35, 
    "legend" : { "position" : 'left', "labels" : { "padding" : 6, "pointStyle" : 'circle', "usePointStyle" : true}},
    "title" : { "display" : true, "text" : "Games by Number of Plays" },
    "tooltips" : { "callbacks" : { "label" : function(tooltipItem, data) { var value = data.datasets[tooltipItem.datasetIndex]["data"][tooltipItem.index]; var label = data.labels[tooltipItem.index]; var times = (value == 1) ? "game" : "games"; return `${label}: ${value} ${times}.`; } } }
  };
  ctx = document.getElementById('gamesByPlaysChart').getContext('2d');
  new Chart(ctx, { "type" : "pie", "data" : data, "options" : options });

  // bggRankingGrouped Chart
  labels = [];
  dataset = [];
  dataSize = 0;
  $.each(sdata.stats.bggRankingGrouped, function(k, v) {
    labels.push(k);
    dataset.push(v.size); 
    dataSize++;
  });

/*  data = { 
    "labels" : labels,
    "datasets" : [{
      "data" : dataset,
      "backgroundColor" : colors.slice(0,dataSize),
      "borderWidth" : 0
    }]
  }; */
/*  options = {
    "cutoutPercentage" : 50, 
    "legend" : { "position" : 'left', "labels" : { "padding" : 6, "pointStyle" : 'circle', "usePointStyle" : true}},
    "title" : { "display" : true, "text" : "Games Grouped by BGG Ranking Ranges" },
    "tooltips" : { "callbacks" : { "label" : function(tooltipItem, data) { var value = data.datasets[tooltipItem.datasetIndex]["data"][tooltipItem.index]; var label = data.labels[tooltipItem.index]; var times = (value == 1) ? "game" : "games"; return `${label}: ${value} ${times}.`; } } }
  }; */
  data = { 
    "labels" : labels,
    "datasets" : [{
      "data" : dataset,
      "backgroundColor" : colors.slice(0,dataSize),
      "borderWidth" : 0
    }]
  };
  options = {
    "legend" : { "display" : false },
    "title" : { "display" : true, "text" : "Games Grouped by BGG Ranking Ranges" },
    "tooltips" : { "callbacks" : { "label" : function(tooltipItem, data) { var value = data.datasets[tooltipItem.datasetIndex]["data"][tooltipItem.index]; var times = (value == 1) ? "game" : "games"; return `${value} ${times}.`; } } },
    "scales": { "yAxes": [ { "ticks": { "beginAtZero": true } }] }
  };
  ctx = document.getElementById('bggRankingGroupedChart').getContext('2d');
/*  new Chart(ctx, { "type" : "pie", "data" : data, "options" : options }); */
  new Chart(ctx, { "type" : "bar", "data" : data, "options" : options });

  // bggWeightGrouped Chart
  labels = [];
  dataset = [];
  dataSize = 0;
  $.each(sdata.stats.bggWeightGrouped, function(k, v) {
    labels.push(k);
    dataset.push(v.size); 
    dataSize++;
  });
  data = { 
    "labels" : labels,
    "datasets" : [{
      "data" : dataset,
      "backgroundColor" : colors.slice(0,dataSize),
      "borderWidth" : 0
    }]
  };
  options = {
    "legend" : { "display" : false },
    "title" : { "display" : true, "text" : "Games Grouped by BGG Weight Ranges" },
    "tooltips" : { "callbacks" : { "label" : function(tooltipItem, data) { var value = data.datasets[tooltipItem.datasetIndex]["data"][tooltipItem.index]; var times = (value == 1) ? "game" : "games"; return `${value} ${times}.`; } } },
    "scales": { "yAxes": [ { "ticks": { "beginAtZero": true } }] }
  };
  ctx = document.getElementById('bggWeightGroupedChart').getContext('2d');
  new Chart(ctx, { "type" : "bar", "data" : data, "options" : options });


  // bggCategoriesGrouped Chart
  labels = [];
  dataset = [];
  dataSize = 0;
  $.each(sdata.stats.bggCategoriesGrouped, function(k, v) {
    labels.push(k);
    dataset.push(v.size); 
    dataSize++;
  });
  data = { 
    "labels" : labels,
    "datasets" : [{
      "data" : dataset,
      "backgroundColor" : colors.slice(0,dataSize),
      "borderWidth" : 0
    }]
  };
  options = {
    "cutoutPercentage" : 35, 
    "legend" : { "position" : 'left', "labels" : { "padding" : 6, "pointStyle" : 'circle', "usePointStyle" : true}},
    "title" : { "display" : true, "text" : "Games Grouped by BGG Categories" },
    "tooltips" : { "callbacks" : { "label" : function(tooltipItem, data) { 
      var value = data.datasets[tooltipItem.datasetIndex]["data"][tooltipItem.index]; 
      var label = data.labels[tooltipItem.index]; 
      var times = (value == 1) ? "game" : "games"; 
      if (label == "Others") { return `${label}: more categories.`; } else { 
      return `${label}: ${value} ${times}.`; } } } }
  };
  ctx = document.getElementById('bggCategoriesGroupedChart').getContext('2d');
  new Chart(ctx, { "type" : "pie", "data" : data, "options" : options });
}

function createUsuspects(data) {
  // unusual suspects
  totalPlays = data.totalPlays;
  part1 = `
      <div class="my-3 p-3 bg-white rounded shadow-sm">
        <div class="h5">The usual suspects</div>
          <ul class="nav nav-tabs">
  `;
  part2 = "";
  $.each(data.players, function(idx, player) {
    if (idx == 0) {
       active = "active";
    } else {
       active = "";
    }
    aux = `
            <li class="nav-item">
              <a class="nav-link ${active}" id="tab-${player.username}" href="#${player.username}"data-toggle="tab">
                 <svg class="bd-placeholder-img mr-2 rounded" width="16" height="16" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" focusable="false" role="img"><rect width="100%" height="100%" fill="${player.color}"/></svg>
              </a>
            </li>
    `;
    part2 = part2 + aux;
  });
  part3 = `
          </ul>
          <div class="tab-content container" id="usualSuspectsContent">
  `;
  part4 = "";
  $.each(data.players, function(idx, player) {
    if (idx == 0) {
       active = "show active";
    } else {
       active = "";
    }
    // username, name, color, plays, wins, ties, deadLast, lastVictory{date, gameName}
    if (player.ties == 0) {
      ties = "no ties";
    } else if (player.ties == 1) {
      ties = "1 tie";
    } else {
      ties = `${player.ties} ties`;
    }
    perc1 = (player.wins / player.plays * 100.0).toFixed(2);
    perc2 = (player.deadLast / player.plays * 100.0).toFixed(2);
    perc3 = (player.secondPlace / player.plays * 100.0).toFixed(2);
    if (player.mostVictorious.length >= 1) {
      mv = player.mostVictorious[0].victories;
      mvGameName = player.mostVictorious[0].gameName;
      mvTimes = (mv == 1) ? "time" : "times";
      mvButtonId = `most_victorious_${player.username}`;
      mvDiv = `<div class="mt-1"><span class="text-info">${mv}</span><span> ${mvTimes} </span><span> - ${mvGameName} </span><span>(<span id=${mvButtonId} class="text-primary">more...</span>)</span></div>`;
    } else {
      mvDiv = `<div class="mt-1"><span class="text-info">Never been most victorious at all</span></div>`;
    }
    if (player.neverWon.length >= 1) {
      nw = player.neverWon[0].plays;
      nwGameName = player.neverWon[0].gameName;
      nwTimes = (nw == 1) ? "play" : "plays";
      nwButtonId = `never_won_more_${player.username}`;
      nwDiv = `<div class="mt-1"><span class="text-info">${nw}</span><span> ${nwTimes} </span><span> - ${nwGameName} </span><span>(<span id=${nwButtonId} class="text-primary">more...</span>)</span></div>`;
    } else {
      nwDiv = `<div class="mt-1"><span class="text-info">I always outsmart other players</span></div>`;
    }

    playerImage = `./images/${player.username}_figure.png`;
    if (player.username == 'gus77avo' || player.username == 'RaulMC') {
      playerImage = `./images/${player.username}_figure_awl_1.png`;
    }

    aux = `
            <div class="tab-pane fade ${active}" id="${player.username}" role="tabpanel">
              <div class="h5 mt-2">${player.name}</div>
              <div class="media text-muted">
                <img class="img-thumbnail mr-3" src="${playerImage}" alt="" data-toggle="tooltip" title="${player.motto}">
                <div class="media-body overflow-auto" style="max-height: 250px;">
                  <div class="pb-2 mb-0 small lh-100 border-bottom border-gray"> 
                    <strong class="text-gray-dark">Plays:</strong>
                    <div class="mt-1"><span class="text-info">${player.plays}</span><span> times </span><i>(${totalPlays} total)</i></div>
                  </div>  
                  <div class="pb-2 mt-2 mb-0 small lh-100 border-bottom border-gray"> 
                    <strong class="text-gray-dark">Wins: </strong>
                    <div class="mt-1"><span class="text-info">${player.wins}</span><span> times </span><i>(${perc1}%)</i></div>
                  </div>  
                  <div class="pb-2 mt-2 mb-0 small lh-100 border-bottom border-gray"> 
                    <strong class="text-gray-dark">Ties: </strong>
                    <div class="mt-1"><span>${ties}</span></div>
                  </div>  
                  <div class="pb-2 mt-2 mb-0 small lh-100 border-bottom border-gray"> 
                    <strong class="text-gray-dark" data-toggle="tooltip" title="Inaccurate. Could be higher.">Dead last*: </strong>
                    <div class="mt-1"><span class="text-info">${player.deadLast}</span><span> times </span><i>(${perc2}%)</i></div>
                  </div>  
                  <div class="pb-2 mt-2 mb-0 small lh-100 border-bottom border-gray"> 
                    <strong class="text-gray-dark">Last victory: </strong>
                    <div class="mt-1"><span class="text-info">${player.lastVictory.date}</span><span> - ${player.lastVictory.gameName}</span></div>
                  </div>  
                  <div class="pb-2 mt-2 mb-0 small lh-100 border-bottom border-gray"> 
                    <strong class="text-gray-dark" data-toggle="tooltip" title="Inaccurate. Could be higher.">Second place*: </strong>
                    <div class="mt-1"><span class="text-info">${player.secondPlace}</span><span> times </span><i>(${perc3}%)</i></div>
                  </div>  
                  <div class="pb-2 mt-2 mb-0 small lh-100 border-bottom border-gray"> 
                    <strong class="text-gray-dark">Most Victorious: </strong>
                    ${mvDiv}
                  </div>  
                  <div class="pb-2 mt-2 mb-0 small lh-100 border-bottom border-gray"> 
                    <strong class="text-gray-dark">Never Won: </strong>
                    ${nwDiv}
                  </div>  


                </div>              
              </div>
            </div>
    `;
    part4 = part4 + aux;
  });

  part5 = `
           </div>          
        </div>
      </div>
  `;
  $("#usualSuspects").append(part1+part2+part3+part4+part5);

  // Now the HTML is in place, we can add the on click events
  $.each(data.players, function(idx, player) {
    if (player.mostVictorious.length >= 1) {
      mvButtonId = `most_victorious_${player.username}`;

      $(`#${mvButtonId}`).click(function() {
        loadModalTable(
          "Most Victorious", 
          `${player.name} was the most victorious in these games<br>(Ties are friendly)`, 
          player.mostVictorious,
          false);
        $("#toc_modal").modal('show');
      });
    }

    if (player.neverWon.length >= 1) {
      nwButtonId = `never_won_more_${player.username}`;

      $(`#${nwButtonId}`).click(function() {
        loadModalTable(
          "Never Won", 
          `${player.name} never won a play of these games`, 
          player.neverWon,
          true);
        $("#toc_modal").modal('show');
      });
    }
  });
}

function createItems(data) {
   createUsuspects(data);
   createCharts(data);

  // init tooltips
  $('[data-toggle="tooltip"]').tooltip(); 
}

function loadItems() {
  $("#usualSuspects").empty();
  $("#alert_on_error").fadeOut(0);
  $("#loading_spinner").removeClass("invisible")

  // Call server
  $.getJSON("/_msktrsbe/cts")
    .done(function(data) {
      if ("error_code" in data) {
        $("#alert_on_error").removeClass('hidden');
        $("#alert_on_error").fadeIn(500);
      } else {
        createItems(data);
      }  
    })
    .fail(function(jqxhr, textStatus, error) {
//      var err = textStatus + ", " + error;
//      console.log( "Request Failed: " + err );
      $("#alert_on_error").removeClass('hidden');
      $("#alert_on_error").fadeIn(500);
    })
    .always(function() {
      $("#loading_spinner").addClass("invisible")
    });

}

// ready to go!
$(document)
  .ready(function() {
    $("#header_version").text(codeVersion);
    addVersionLogEntries();

    loadItems();

    // click on information
    $("#info_button").click(function() {
      $("#versionlog_modal").modal('show');
      $("#info_button").tooltip('hide');
    });

  });
