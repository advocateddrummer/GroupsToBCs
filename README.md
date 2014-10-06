# GroupsToBCs
Script converts tagged groups to CAE boundary conditions. 

## Usage
If a connector (2D) or domain (3D) exists in multiple groups, the entity is assigned to one of the BCs and the user is notified of the conflict. (See next comment)

If an entity already exists in a CAE boundary condition, the user is notified and the entity is not moved. This can happen if the entity has already been assigned a boundary condition in the CAE panel, or if the entity exists in multiple groups.

If a CAE boundary condition already exists with the supplied group name, a new boundary condition is created with the same root name appended with an integer value.

Only the groups appended with "-bc" are automatically converted to BCs.

