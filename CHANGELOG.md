
# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.13] - 2021-06-27
 
### Added
- Local Docker support
### Changed

 - Back to normal de future play list (W.H.O. unapproved)
 
### Fixed

## [1.12.01] - 2020-11-26
 
### Added

### Changed

 - Change the alert when players proposed more than n games. Change n from 5 to 3
 
### Fixed

 - Issues with the new way plays and stats are stored. 
   - Fix "Never Won" and "Most Victorious"
   - Fix detection when a game was played by everyone or not
   - Fix usage of base parents
 

## [1.11.666] - 2020-11-07
 
### Added
   
### Changed

 - Back to normal de future play list (W.H.O. approved)
 - Rework in how the players stats and plays are stored
 
### Fixed


## [1.11.333] - 2020-03-20
 
### Added
   
### Changed

 - Remove the future play list due the social distancing decree (W.H.O. approved

### Fixed


## [1.11.0] - 2019-09-18
 
### Added

 - New tag: @allSessionLong: Inform players the game could take all the game session to play it
 - New personal stats: "Never Won" and "Most Victorious"
   
### Changed

 - Back to status balls in future playlist:
   - Check Circle means all selected players agreed to know the game. It is considered as played
   - Empty Circle means the game is new to the selected players
   - Pause Circle means there is a players count restriction not followed for the selected players
   - Red Question Circle means selected players played something similar. It is considered as not played by default unless selected players agreed they know it
   - Question Circle means not all the selected players played the game. It is considered as not played by default unless selected players agreed they know it
 
### Fixed


## [1.10.0] - 2019-08-07
 
### Added

 - Support green games list. Games in this list are treated like played, they supersede any session history. These games aren't considered for the unplayed header counter
 - Add different color backgrounds in the games list to identify several cases as follows:
   - Add a green background for games that all selected players has been played the game at least once
   - Add a red background for games without plays but a parent game has plays recorded
   - Add a blue background for games the selected player count isn't the adequate
 - Add an icon at the end of game's title line to identify Wizard's choice
 - Add icon at the end of game's title line to support "Asterisk behaviour isn't allowed" tag
  
### Changed

 - Move tooltip from the removed checkmarks to the game's title
 - Change ratio in donut charts
 - Support tags in "The Musketeers Future Playlist" geeklist. Tags supersede session history and green games list
 
### Fixed


## [1.9.0] - 2019-07-26
 
### Added

 - Add a chart showing games grouped by BGG weight ranges
 - Add a chart showing games grouped by BGG categories
   
### Changed

 - Change the type of "Games Grouped by BGG Ranking Ranges" chart to bar
 - Remove obnoxious checkmarks in future games list
 
### Fixed

 - Wording fixes
 - Sort the labels in "Games Grouped by BGG Ranking Ranges" chart
 - Fix "last victory" when a player won more than one game in the same day

 
## [1.8.0] - 2019-07-30
 
### Added

 - Add a fancy fav icon
   
### Changed

 - Change ageing the total of votes to 0.5 every 7 days
 - Rework on control header. Make it collapsible and rearrange the objects in it
 
### Fixed


## [1.7.0] - 2019-06-27
 
### Added

 - Add Charts & Stats page. It contains:
   - Add a navigable tabbed cards with some stats for each musketeer
   - Add a chart showing games grouped by number of plays
   - Add a chart showing games grouped by BGG ranking ranges
   - Add links to-from future playlist page to charts & stats page
 - Add in the yellow checkmark's tooltip the names of the persons who don't played the game
 - Add checkbox to allow turn list sorting using aged total to false
 - Add wizard who picks the better game to play
   
### Changed
 
### Fixed

 
## [1.6.0] - 2019-06-18
 
### Added

 - Add a yellow checkmark to sign not all players had played the game
 - Add a red checkmark to sign there's no recorded plays for the expansion/collection, but there are for the base game
   
### Changed
 
### Fixed

 
## [1.5.0] - 2019-05-01
 
### Added

 - Add the amount of unplayed games in the main header (after the total number of items)
 - Add the amount of games proposed by the players in the control header (after the name of the player)
 - Add what player proposed the game to the list below the name of the game
 - Add an alert if players proposed more than 5 games, also the text in the control header turns red
   
### Changed
 
### Fixed

 - Tooltips works in mobile with some limitations (not in links), because uses tap instead of hoover
 

## [1.4.0] - 2019-04-25
 
### Added

 - Add second criteria (post's original date) to sort the list
 - Add a green checkmark to sign the game was played before
 - Add tooltips to the checkmark and game's links
   
### Changed
 
### Fixed


## [1.3.0] - 2019-04-19
 
### Added

 - Information button in the header to access this version log
   
### Changed

 - Use spinner provided by Bootstrap 4, instead of a third party spinner
 - Move total votes number to the right and change format to subscript
 - Remove parentheses in aged total votes
 
### Fixed
 

## [1.2.0] - 2019-04-17
 
### Added

 - New link to the BGG's geeklist item
 - Show an alert for those who are missing to vote some games
   
### Changed

 - Game's link moved to the right of game's name
 
### Fixed
 

## [1.1.0] - 2019-04-14
 
### Added

 - Support for ageing the total of votes (0.5 every 14 days)
 - Support for exclude some of the players' votes
   
### Changed

 - New user interface
 
### Fixed



