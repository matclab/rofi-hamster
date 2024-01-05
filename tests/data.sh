#!/usr/bin/env bash
function hamster_xsv_export() {
   cat <<EOT
end time,activity,category,description,tags
gestion projet,c845,planning desc,"tag1, tag2"
gestion projet,c936,orga desc,"tag2, tag3"
mail,dt,,
gestion projet,c936,,tag1
support,dt,kicks sysdoc,com
support,dt,"kicks, sysdoc",com
EOT
}

function expected_activities() {
   cat <<EOT
gestion projet@c845, planning desc, #tag1 #tag2
gestion projet@c936, #tag1
gestion projet@c936, orga desc, #tag2 #tag3
mail@dt
support@dt, kicks sysdoc, #com
support@dt, kicks, sysdoc, #com
EOT
}

