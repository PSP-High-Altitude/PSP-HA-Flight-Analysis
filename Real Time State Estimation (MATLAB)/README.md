The goal of this project is to make an object-oriented approach to making a state estimation algorithim

# SUMMARY OF CLASSES
## TEST CLASSES
these are classes that were created to assist in creating a functional test environment for making flight ready code

### main
main program used for testing state estimators. Consists of a loop which simulates the flight.
### PALDataSample
Contains a single sample of data from PAL's sensors (except gps). This should be used by all state estimators. 

### state_history
Contains a big table of the states we might care about, along with some functions for plotting and comparing states. 
All state estimation classes should have this as a prent class. 

### readGpsStes
reads in data from the gps file into a state_history object so it can be plotted alongside other estimations. 

## FLIGHT CLASSES
these classes contain code and algorithms that could be used in flight.

### accel_est
very basic estimation made by integrating vertical acceleration. 

### baro_est
estimates state (vertical pos and vel) from pressure data. 
Velocity needs some filtering, in progress

### flightAlg_v1
A prototype of software that could be run on PAL. Combines acceleration and barometric estimations.

# FLIGHT DATA FILES
## Dark Matter 3
dm3_PAL_dat.csv \\
launch: t = 2200e3 ms \\
apogee: t = 2269e3 ms \\
land: t = 2600e3 ms \\

# EXTRA FILES
Copied over from other parts of the repo, mainly used as refernce
- TrapInt.m
- FlightAnalysis_v2.m
