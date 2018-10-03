# PV-Simulator - MATLAB code that simulated PV output. Based on Sandia Laboratory
PV Toolbox: https://pvpmc.sandia.gov/applications/pv_lib-toolbox/

Add all files and sub-directories to MATLAB working directory.

Calculates PV output for a specified array of rated power,
P at a site with coordinates, latitude, longitude. P is in W. Coordinates
are confined to Scotland and must be within defined ranges of (+55 to +59)
latitude and (-2 to -7) longitude. These models are based on the open source
Sandia Laboratory PV library.  

Basic Usage:

From command Line, call:

[ACPower, Pdc, mSAPMResults] = pvOutputCoords(P, latitude, longitude)

Where P is maximum power rating of the solar array, and latitude and longitude are 
the coordinates of the array. ACPower is the AC output power of inverter while Pdc is 
DC output power of the solar array.
