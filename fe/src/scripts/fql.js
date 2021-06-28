// FQL.JS
	
function updateHeader(data) {
  $("#header_item_count").text(
    data.header.items + 
    " items (" +
    data.header.unplayed +
    " unplayed)"
  );
}

function updateControlHeader(data) {
  tmg = []
  $.each($("small[id^='defaultCheck']"), function(i, v) { 
    ffor = `#defaultCheck${i+1}`;
    key = $(ffor).prop("value");
    if ($(ffor).prop("checked") === true) {
      times = data.players[key]["proposed"];
      games = "games";
      if (times == 0) {
        times = "no";
      } else if (times == 1) {
        games = "game";
      } else if (times > 3) {
        $(v).addClass("text-danger");     
        pname = data.players[key]["name"];
        text = `<strong>${pname}</strong> proposed ${times} games.`;
        tmg.push(text);
      }
      text = `(${times} ${games} proposed)`;
      $(v).text(text);
    }  
  });
  if (tmg.length > 0) {
    $("#too_many_games_container").empty();
	html = tmg.join("<hr>");
	$("#too_many_games_container").append(html);
	$("#alert_on_too_many_games").removeClass('hidden');
	$("#alert_on_too_many_games").fadeIn(500);
  }
}

function getCheckedPlayerCount(data) {
  var count = 0;
  $.each(data.players, function(idx, p) { 
    if (p["excluded"] === false) {
      count = count + 1;
    }  
  });  
  return count;
}

function evaluateAsterisk(entry) {
  if (entry.tags["ana"] === true) {
    return `<i class="fas fa-asterisk text-dark fa-fx" data-toggle="tooltip" title="Asterisk behaviour isn't allowed"></i>`;
  } else {
     return "";
  } 
}

function evaluateWizard(idx, wc) {
  if (idx != wc) {
    return "";
  } else {
    return `<i class="fas fa-hat-wizard text-purple fa-fx" data-toggle="tooltip" title="Wizard's choice"></i>`;
  }  
}

function getPlayersCountIcon(entry) {  
  var tooltip = "";
  var hidden = "hidden";
  if (entry.tags["pc"] === true) {
    hidden = "";
    if (entry.tags["pcf"] == entry.tags["pct"]) {
      tooltip = `It needs ${entry.tags["pct"]} players`;
    } else {
      tooltip = `It needs between ${entry.tags["pcf"]} and ${entry.tags["pct"]} players`;
    }
  }
  return `<i class="fas fa-user-friends fa-fx text-dar ${hidden}" data-toggle="tooltip" title="${tooltip}"></i>`;
}

function getCheckmarkIcon(renderData) {
  return `<i class="${renderData.checkmarkType} ${renderData.checkmarkColor} fa-fx" data-toggle="tooltip" title="${renderData.checkmarkTooltip}"></i>`;
}

function getKnownByAllIcon(renderData) {
  var hidden = (renderData.knownByAllTooltip == "") ? "hidden" : "";
  return `<i class="fas fa-lightbulb fa-fx text-dark ${hidden}" data-toggle="tooltip" title="${renderData.knownByAllTooltip}"></i>`;
}

function getAllSessionLongIcon(entry) {
  var hidden = (entry.tags["asl"] === true) ? "" : "hidden";
  return `<i class="fas fa-hourglass-half fa-fx text-dark ${hidden}" data-toggle="tooltip" title="It's going to be a long session!"></i>`;
}

function getBGGGamePageLink(entry) {
  return `<a href="https://boardgamegeek.com/boardgame/${entry.id}" target="_blank"><i class="fas fa-link fa-fx text-dark" data-toggle="tooltip" title="BGG page"></i></a>`;
}

function getBGGGeekList(entry) {
  return `<a href="https://www.boardgamegeek.com/geeklist/243477/item/${entry.item}#item${entry.item}" target="_blank"><i class="fas fa-list fa-fx text-dark" data-toggle="tooltip" title="Geeklist entry"></i></a>`;
}

function getRenderDataFromEntryInformation(data, entry, count) {
  var checkmarkType = "";
  var checkmarkColor = "";
  var checkmarkTooltip = "";
  var knownByAllTooltip = "";
  
  if (entry.tags["pc"] === true && (count < entry.tags["pcf"] || count > entry.tags["pct"])) {
    //*** Evaluate some tags of player count first
    checkmarkColor = "text-info";
    checkmarkType = 'fas fa-pause-circle';
    checkmarkTooltip = `It seems it can't be played with ${count} players`;
    
  } else if (entry.played > 0 && entry.allPlayed === true) {
    //*** Evaluate then if the game has been played by everyone
    times = "times"; 
    if (entry.played == 1) {
      times = "time"; 
    }
    checkmarkColor = 'text-success';
    checkmarkType = 'fas fa-check-circle';
    checkmarkTooltip = `Played ${entry.played} ${times}`;
  } else if (entry.tags["kbe"] === true || entry.inGreenList === true) {
    //*** Evaluate then if the game is in the green list or it has kbe tag
    checkmarkColor = 'text-success';
    checkmarkType = 'fas fa-check-circle';
    checkmarkTooltip = "It seems we all know it";
    knownByAllTooltip = "It's in the green list";
  } else if (entry.played > 0) {
    //*** Evaluate then if the game has been played but not by everyone
    extras = ". ";
    times = "times"; 
    if (entry.played == 1) {
      times = "time"; 
    }
    $.each(entry.missedPlayers, function(jdx, player) {
      pname = data.players[player]["name"];
      if (jdx == 0) {
        extrasAux = `${pname}`;
      } else {
        extrasAux = `, ${pname}`;
      }
      extras = extras + extrasAux;
    });
    extras = extras + " didn't played the game";

    checkmarkColor = 'text-black-25';
    checkmarkType = 'fas fa-question-circle';
    checkmarkTooltip = `Played ${entry.played} ${times}${extras}`;
  } else if (entry.played == 0 && entry.hasParent === true) {
    //*** Evaluate then if the game hasn't been played but they have parents played already (base games)
    checkmarkColor = 'text-danger';
    checkmarkType = 'fas fa-question-circle';
    checkmarkTooltip = `Haven't played yet, maybe the base game`;
  } else { 
    checkmarkType = 'fas fa-circle';
    checkmarkColor = 'text-black-25';
    checkmarkTooltip = "New game!";
  }
  
  var outcome = {
    checkmarkType: checkmarkType,
    checkmarkColor: checkmarkColor,
    checkmarkTooltip: checkmarkTooltip,
    knownByAllTooltip: knownByAllTooltip
  };
  
  return outcome;
}

function createItems(data) {
  // Header
  updateHeader(data);

  // Control header
  updateControlHeader(data);

  // Missing votes if any
  if ($.isEmptyObject(data.missingVotes) === false) {
    $("#missing_votes_container").empty();
    mvc = []
    $.each(data.missingVotes, function(player, mv) {
      pname = data.players[player]["name"];
      games = []
      head = `<strong>${pname}</strong> needs to vote on: `;
      $.each(mv, function(idx, game) {
        s = `<a href="#item_${game["id"]}" class="alert-link">${game["name"]}</a>`;
        games.push(s);
      });
      x = head+(games.join(",  "));
      mvc.push(x);
    });
    html = mvc.join("<hr>");
    $("#missing_votes_container").append(html);
    $("#alert_on_missing_votes").removeClass('hidden');
    $("#alert_on_missing_votes").fadeIn(500);
  }

  // Wizard Choice 
  var wc = data.wizardChoice;

  // Checked plater count (not excluded)
  var count = getCheckedPlayerCount(data);
  
  // Items! 
  $.each(data.list, function(idx, entry) {
    var renderData = getRenderDataFromEntryInformation(data, entry, count);
    // Render Wizard's choice icon
    var wizardChoiceIcon = evaluateWizard(idx, wc);
    // Render Asterisk aren't allowed tag icon
    var asteriskAllowedIcon = evaluateAsterisk(entry);
    // Render players count icon
    var playersCountIcon = getPlayersCountIcon(entry);
    // Render color circle with different signs depending on state of the item
    var checkmarkIcon = getCheckmarkIcon(renderData);
    // Render "We all know the rules of the game" icon
    var knownByAllIcon = getKnownByAllIcon(renderData);
    // Render icon for longer games
    var allSessionLongIcon = getAllSessionLongIcon(entry);
    // Render BGG game's page
    var bggLinkIcon = getBGGGamePageLink(entry);
    // Render BGG Musketers geek list
    var bggGeekListIcon = getBGGGeekList(entry);
    
    part1 = `
      <div id="item_${entry.id}" class="my-3 p-3 bg-white rounded shadow-sm">
        <div class="border-bottom border-gray pb-2 mb-0">
          <span class="h5">${entry.name}</span> 
          <br><small><i>Proposed by</i> ${data.players[entry.proposedBy]["name"]}</small><br>
          ${checkmarkIcon} ${playersCountIcon} ${knownByAllIcon}
          ${allSessionLongIcon} ${bggLinkIcon} ${bggGeekListIcon}
          ${wizardChoiceIcon} ${asteriskAllowedIcon}
        </div>
        <div class="media text-muted pt-3">
          <img class="img-thumbnail mr-3" src="${entry.thumbnail}" alt="">
          <div class="media-body">
            <div class="mt-0 pb-2 h6">
              <span>Votes: </span>
              <span class="text-info">${entry.agedTotal}</span>
              <span> </span>
              <sub id="total_${idx}" class="text-muted">${entry.total}</sub>
            </div>
    `;

    part2 = "";
    $.each(entry.players, function(jdx, pdata) {
      key = Object.keys(pdata)[0];
      value = pdata[key];
      pname = data.players[key]["name"];
      pcolor = data.players[key]["color"]; 
      aux = ` 		
        <div class="media text-muted mt-2">
          <svg class="bd-placeholder-img mr-2 rounded" width="16" height="16" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" focusable="false" role="img"><rect width="100%" height="100%" fill="${pcolor}"/></svg>
          <span class="media-body pb-2 mb-0 small lh-100 border-bottom border-gray">
            <strong class="text-gray-dark">${pname}: </strong>
            <span>${value}</span>
          </span>
        </div>
      `;
      part2 = part2 + aux;
    });
    part3 = `
          </div>
        </div>
      </div>    
    `;
    $("#items").append(part1+part2+part3);
    if (entry.total === entry.agedTotal) {
      $("#total_" + idx).fadeOut(0);
    }
    // init tooltips
    $('[data-toggle="tooltip"]').tooltip(); 
  }); 
}

function loadItems() {
  // Fade out and clean object values
  $("#items").empty();
  $("#alert_on_error").fadeOut(0);
  $("#alert_on_missing_votes").fadeOut(0);
  $("#alert_on_too_many_games").fadeOut(0);
  $("#loading_spinner").removeClass("invisible")
  $.each($("small[id^='defaultCheck']"), function(i, v) { 
    $(v).text(""); 
    $(v).removeClass("text-danger");     
  });

  // Create exclude list
  list = [];
  $.each($("input[id^='defaultCheck']"), function(i, v) { 
    if (v.checked === false) {
      list.push(v.value);
    }
  });
  excludes=list.join(",")
  
  // Take sort checkbox
  sortByAgedTotal = "true";
  if ($("#sort_by_aged_total").prop("checked") === false) {
     sortByAgedTotal = "false";
  }

  // Call server
  $.getJSON("/_msktrsbe/fql?excludes="+excludes+"&sortByAgedTotal="+sortByAgedTotal)
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

    $("#update_list").click(function() {
      loadItems();
    });

    $("#info_button").click(function() {
      $("#versionlog_modal").modal('show');
      $("#info_button").tooltip('hide');
    });

    $("input[id^='defaultCheck']").click(function() {
      $("#update_list").prop("disabled", true);
      $.each($("input[id^='defaultCheck']"), function(i, v) { 
        if (v.checked === true) {
          $("#update_list").prop("disabled", false)
        }   
      });
    });
  });
