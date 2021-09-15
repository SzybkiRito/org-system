**What's this**

This is group system based on ESX Framework which allows you to add some activities which i don't include all any other stuff you want. I'am currently working on this project and it's not finished yet. You can edit this script however you want. This script provides create markers by command so when we will add a lot of markers it could be laggy. Config, translations and other stuff is not finished and I'll work on those thing at the end.

**Commands**

*RANK = 0/1* <br/>
*MarkerType = management/stash*

* /createGroup Group_Name
* /addPlayer ID Group_Name Rank
* /createMarker Group_Name MarkerType

**Dependencies**

*ESX Framework*

**Install**

    * 1. Add to es_extended/server/clases/player.lua *
    	self.getPlayerGroup = function(identifier, callback) 
		    MySQL.Async.fetchAll("SELECT org_name FROM orgmembers WHERE identifier = @identifier", {
			    ['@identifier'] = identifier
		    }, function(result)
				    callback(result[1].org_name)
		    end)
	    end

## TODO 

    * [X] ADD COMMANDS TO SET UP A GROUP
    * [X] ADD PANEL WHERE U CAN MANAGE GROUP
    * [X] ADD EXPORT FUNCTION TO CHECK IF PLAYERS IS IN GROUP

    * [X] ADD COMMAND TO CREATE MARKER BY THE COMMAND
    * [] ADD ACTIVITY TO STEAL VEHICLES AND SAVE THEM IN THE CHOP SHOP
    * [X] CHECK PERFORMANCE OF THE SCRIPT
    * [] ADD SOME FUNCTIONS TO EXPORT