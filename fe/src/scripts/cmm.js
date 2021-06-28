const codeVersion = "v1.13";

function addVersionLogEntries() {
  $("#versionlog_body").empty();
  html = `
	  <h6>v1.13 - 27 Jun, 2021</h6>
	  <ul class="small"> 
		<li>Added local docker support</li>
	  </ul>
	  <hr>

	  <h6>v1.12.03 - 24 May, 2021</h6>
	  <ul class="small"> 
		<li>Remove the future play list due the social distancing decree (W.H.O. approved) AGAIN!</li>
	  </ul>
	  <hr>

	  <h6>v1.12.01 - 26 November, 2020</h6>
	  <ul class="small"> 
		<li>Change the alert when players proposed more than <strong>n</strong> games. Change <strong>n</strong> from 5 to 3.</li>
	  </ul>
	  <hr>

	  <h6>v1.11.666 - 7 November, 2020</h6>
	  <ul class="small"> 
		<li>Back to normal de future play list (W.H.O. approved)</li>
	  </ul>
	  <hr>

	  <h6>v1.11.333 - 26 March, 2020</h6>
	  <ul class="small"> 
		<li>Remove the future play list due the social distancing decree (W.H.O. approved)</li>
	  </ul>
	  <hr>

	  <h6>v1.11 - 18 Sep, 2019</h6>
	  <ul class="small"> 
		<li>New tag: <strong>@allSessionLong</strong>. Inform players the game could take all the game session to play it.</li>
		<li>New personal stats: <i>Never Won</i> and <i>Most Victorious</i>. Scroll to know them.</li>
		<li>Back to status balls in future playlist:
		  <ul>
		  <li><i class="fas fa-check-circle fa-fx text-success"></i> means all selected players agreed to know the game. It is considered as <strong>played</strong>.</li>
		  <li><i class="fas fa-circle fa-fx text-black-25"></i> means the game is new to the selected players.</li>
		  <li><i class="fas fa-pause-circle fa-fx text-info"></i> means there is a players count restriction not followed for the selected players.</li>
		  <li><i class="fas fa-question-circle fa-fx text-danger"></i> means selected players played something similar. It is considered as <strong>not played</strong> by default unless selected players agreed they know it.</li>
		  <li><i class="fas fa-question-circle fa-fx text-black-25"></i> means not all the selected players played the game. It is considered as <strong>not played</strong> by default unless selected players agreed they know it.</li>
		  </ul>		  
		</li>
	  </ul>
	  <hr>

	  <h6>v1.10 - 7 Aug, 2019</h6>
	  <ul class="small"> 
		<li>Support green games list. Games in this list are treated like played, they supersede any session history. These games aren't considered for the <strong>unplayed</strong> header counter.</li>
		<li>Add different color backgrounds in the games list to identify several cases as follows:
		  <ul>
		  <li>Add a green background for games that all selected players has been played the game at least once.</li>
		  <li>Add a red background for games without plays but a parent game has plays recorded.</li>
		  <li>Add a blue background for games the selected player count isn't the adequate.</li>
		  </ul>
		</li>
		<li>Move tooltip from the removed checkmarks to the game's title.</li>
		<li>Add an icon at the end of game's title line to identify Wizard's choice.</li>
		<li>Change ratio in donut charts.</li>
		<li>Support <i>tags</i> in <strong>The Musketeers Future Playlist</strong> geeklist. Tags supersede session history and green games list.</li>
		<li>Add icon at the end of game's title line to support <strong>Asterisk behaviour isn't allowed</strong> tag.</li>
	  </ul>
	  <hr>

	  <h6>v1.9 - 26 Jul, 2019</h6>
	  <ul class="small"> 
		<li>Wording fixes.</li>
		<li>Change the type of <i>Games Grouped by BGG Ranking Ranges</i> chart to <strong>bar</strong>.</li>
		<li>Sort the labels in <i>Games Grouped by BGG Ranking Ranges</i> chart.</li>
		<li>Fix <strong>last victory</strong> when a player won more than one game in the same day.</li>
		<li>Add a chart showing games grouped by BGG weight ranges.</li>
		<li>Add a chart showing games grouped by BGG categories.</li>
		<li>Remove obnoxious checkmarks in future games list.</li>
	  </ul>
	  <hr>

	  <h6>v1.8 - 3 Jul, 2019</h6>
	  <ul class="small"> 
		<li>Change <strong>ageing</strong> the total of votes to 0.5 every 7 days.</li>
		<li>Add a fancy fav icon.</li>
		<li>Rework on control header. Make it collapsible and rearrange the objects in it.</li>
	  </ul>
	  <hr>

	  <h6>v1.7 - 27 Jun, 2019</h6>
	  <ul class="small"> 
		<li>Add Charts & Stats page:
		  <ul>
		  <li>Add a navigable tabbed cards with some stats for each musketeer.</li>
		  <li>Add a chart showing games grouped by number of plays.</li>
		  <li>Add a chart showing games grouped by BGG ranking ranges.</li>
		  <li>Add links to-from future playlist page to charts & stats page.</li>
		  </ul>
		</li>
		<li>Add in the yellow checkmark's tooltip the names of the persons who don't played the game.</li>
		<li>Add checkbox to allow turn list sorting using <strong>aged</strong> total to false.</li>
		<li>Add wizard who picks the <strong>better</strong> game to play.</li>
	  </ul>
	  <hr>

	  <h6>v1.6 - 18 Jun, 2019</h6>
	  <ul class="small"> 
		<li>Add a yellow checkmark to sign not all players had played the game.</li>
		<li>Add a red checkmark to sign there's no recorded plays for the expansion/collection, but there are for the base game.</li>
	  </ul>
	  <hr>

	  <h6>v1.5 - 1 May, 2019</h6>
	  <ul class="small"> 
		<li>Add the amount of unplayed games in the main header (after the total number of items).</li>
		<li>Add the amount of games proposed by the players in the control header (after the name of the player).</li>
		<li>Add what player proposed the game to the list below the name of the game.</li>
		<li>Tooltips works in mobile with some limitations (not in links), because uses tap instead of hoover.</li>
		<li>Add an alert if players proposed more than 5 games, also the text in the control header turns red.</li>
	  </ul>
	  <hr>

	  <h6>v1.4 - 25 Apr, 2019</h6>
	  <ul class="small"> 
		<li>Add second criteria (post's original date) to sort the list.</li>
		<li>Add a green checkmark to sign the game was played before.</li>
		<li>Add tooltips to the checkmark and game's links.</li>
	  </ul>
	  <hr>

	  <h6>v1.3 - 19 Apr, 2019</h6>
	  <ul class="small"> 
		<li>Use spinner provided by Bootstrap 4, instead of a third party spinner.</li>
		<li>Information button in the header to access this version log.</li>
		<li>Move total votes number to the right and change format to subscript.</li>
		<li>Remove parentheses in aged total votes.</li>
	  </ul>
	  <hr>

	  <h6>v1.2 - 17 Apr, 2019</h6>
	  <ul class="small"> 
		<li>New link to the BGG's geeklist item.</li>
		<li>Game's link moved to the right of game's name.</li>
		<li>Show an alert for those who are missing to vote some games.</li>
	  </ul>
	  <hr>

	  <h6>v1.1 - 14 Apr, 2019</h6>
	  <ul class="small"> 
		<li>New user interface.</li>
		<li>Support for <strong>ageing</strong> the total of votes (0.5 every 14 days).</li>
		<li>Support for exclude some of the players' votes.</li>
	  </ul>
  `;	  
  $("#versionlog_body").append(html);
}