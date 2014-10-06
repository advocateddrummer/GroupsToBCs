# ============================================================================
# CONVERT GROUPS TO CAE BOUNDARY CONDITIONS
# ============================================================================
# Script converts selected groups to CAE boundary conditions. After groups
# have been converted to BCs, the physical types must be specified by hand.
#
# If a connector (2D) or domain (3D) exists in multiple groups, the entity
# is assigned to one of the BCs and the user is notified of the conflict.
# (See next comment)
#
# If an entity already exists in a CAE boundary condition, the user is
# notified and the entity is not moved. This can happen if the entity has
# already been assigned a boundary condition in the CAE panel, or if the
# entity exists in multiple groups.
#
# If a CAE boundary condition already exists with the supplied group name,
# a new boundary condition is created with the same root name appended
# with an integer value.
#
# Only the groups appended with "-bc" are automatically converted to BCs.
#
#

package require PWI_Glyph

# Get all groups
proc GetGroups {} {

    set caeDim [pw::Application getCAESolverDimension]

    if {$caeDim == 2} {
        set groups [pw::Group getAll -type pw::Connector]
    } else {
        set groups [pw::Group getAll -type pw::Domain]
    }

    return $groups

}

# Get all boundary condition groups (groups appended with "-bc")
proc GetBCGroups {} {

    set groups [GetGroups]
    set bcGroups [list]

    foreach group $groups {

        set groupName [$group getName]
        if {[string equal [string range $groupName end-2 end] "-bc"] && [$group getEntityCount]} {
            lappend bcGroups $group
        }

    }

    return $bcGroups

}

# Return unique boundary condition name for the group (returns new and old name)
proc GetBCNames { name } {

    set bcName [string trimright $name "-bc"]
    set bcNames [pw::BoundaryCondition getNames]

    set cnt 0
    set newBCName $bcName

    while {$cnt < 1000} {

        if {[lsearch -exact $bcNames $newBCName] >= 0} {
            incr cnt
            set newBCName "$bcName-$cnt"
        } else {
            break
        }

    }

    return [list $newBCName $bcName]

}

# Check to see if an entity is already assigned to a boundary condition and apply
proc AssignBC { name ent } {

    set regBcList [$ent getRegisterBoundaryConditions]

    foreach regBc $regBcList {

        lassign $regBc reg bc
        set bcName [$bc getName]

        if {[string equal $bcName "Unspecified"]} {
            SetBC $name $reg
        } else {
            set domName [[lindex $reg 1] getName]
            if { [llength $regBcList] > 1 } {
                append domName " [lindex $reg 2]"
            }
            puts "'$domName' already assigned to the '$bcName' boundary condition...skipping..."
        }

    }

}

# Create a boundary condition with specified name
proc CreateBC { name } {

    set bc [pw::BoundaryCondition create]
        $bc setName $name

}

# Destroy unused boundary conditions and report modified names
proc DestroyBC { names } {

    set newName [lindex $names 0]
    set oldName [lindex $names 1]

    set bc [pw::BoundaryCondition getByName $newName]

    if { 0 == [$bc getEntityCount] } {
        $bc delete
    } else {
        if {![string equal $newName $oldName]} {
            puts ""
            puts "'$oldName' boundary condition already exists..."
            puts "...new boundary condition name will be used: '$newName'"
        }
    }

}

# Apply CAE boundary condition to entity registers
proc SetBC { name reg } {

    set bc [pw::BoundaryCondition getByName $name]
    $bc apply $reg

}

# Main - Convert groups to boundary conditions
set bcGroups [GetBCGroups]
foreach bcGroup $bcGroups {

    set names [GetBCNames [$bcGroup getName]]
    set ents [$bcGroup getEntityList]

    set newBCName [lindex $names 0]
    set oldBCName [lindex $names 1]

    CreateBC $newBCName

    foreach ent $ents {
        AssignBC $newBCName $ent
    }

    DestroyBC $names

}

# END SCRIPT
