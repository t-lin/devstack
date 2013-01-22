#!/bin/bash

# Register new bond for cluster PXE
PXE_BOND_ID=`curl -X POST http://10.10.31.10:8090/v1.0/port_bond/10010010073___NW_ID_PXE__`
PXE_BOND_ID=`echo $PXE_BOND_ID | sed 's/\"//g'`
echo "Cluster PXE bond ID is $PXE_BOND_ID"

# Register ports into bond
curl -X PUT http://10.10.31.10:8090/v1.0/port_bond/$PXE_BOND_ID/30
curl -X PUT http://10.10.31.10:8090/v1.0/port_bond/$PXE_BOND_ID/32
curl -X PUT http://10.10.31.10:8090/v1.0/port_bond/$PXE_BOND_ID/34
curl -X PUT http://10.10.31.10:8090/v1.0/port_bond/$PXE_BOND_ID/36

# Register new bond for cluster data
DATA_BOND_ID=`curl -X POST http://10.10.31.10:8090/v1.0/port_bond/10010010073___NW_ID_EXTERNAL__`
DATA_BOND_ID=`echo $DATA_BOND_ID | sed 's/\"//g'`
echo "Cluster data bond ID is $DATA_BOND_ID"

# Register ports into bond
curl -X PUT http://10.10.31.10:8090/v1.0/port_bond/$DATA_BOND_ID/10010010073_29
#curl -X PUT http://10.10.31.10:8090/v1.0/port_bond/$DATA_BOND_ID/10010010073_31
#curl -X PUT http://10.10.31.10:8090/v1.0/port_bond/$DATA_BOND_ID/10010010073_33
curl -X PUT http://10.10.31.10:8090/v1.0/port_bond/$DATA_BOND_ID/10010010073_35

# Print out existing bonds
echo "Existing bonds:"
curl http://10.10.31.10:8090/v1.0/port_bond

# Print out existing ports in bond
echo "Ports in PXE bond:"
curl http://10.10.31.10:8090/v1.0/port_bond/$PXE_BOND_ID
echo "Ports in Data bond:"
curl http://10.10.31.10:8090/v1.0/port_bond/$DATA_BOND_ID

