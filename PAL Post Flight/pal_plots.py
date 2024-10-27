import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

#%% DATA FUNCTIONS

""" 
timestamp	temperature	pressure	acc_h_x	acc_h_y	acc_h_z	acc_i_x	acc_i_y	acc_i_z	rot_i_x	rot_i_y	rot_i_z	mag_i_x	mag_i_y	mag_i_z
timestamp	year	month	day	hour	min	sec	valid_flags	num_sats	lon	lat	height	height_msl	accuracy_horiz	accuracy_vertical	vel_north	vel_east	vel_down	ground_speed	hdg	accuracy_speed	accuracy_hdg
"""
# These are default values. They can be changed with optional inputs to most functions. 
SENSOR_COL_NAMES = ["timestamp", "temperature",	"pressure",	"acc_h_x",	"acc_h_y",	"acc_h_z",	"acc_i_x",	"acc_i_y",	"acc_i_z",	"rot_i_x",	"rot_i_y",	"rot_i_z",	"mag_i_x",	"mag_i_y",	"mag_i_z"]
SE_COL_NAMES = ["timestamp",	"flight_phase",	"pos_n",	"pos_e",	"pos_d",	"vel_n",	"vel_e",	"vel_d",	"acc_n",	"acc_e",	"acc_d",	"vel_x",	"vel_y",	"vel_z",	"acc_x",	"acc_y",	"acc_z",	"orient_x",	"orient_y",	"orient_z"]
# GPS_COL_NAMES = ["timestamp", "year", "month",	"day",	"hour",	"min",	"sec",	"valid_flags",	"num_sats",	"lon",	"lat",	'height',	"height_msl",	"accuracy_horiz", "accuracy_vertical", "vel_north", "vel_east",	"vel_down",	"ground_speed",	"hdg", "accuracy_speed", "accuracy_hdg"]
GPS_COL_NAMES = ['timestamp', 'year', 'month', 'day', 'hour', 'min', 'sec',
       'valid_flags', 'num_sats', 'lon', 'lat', 'height', 'height_msl',
       'accuracy_horiz', 'accuracy_vertical', 'vel_north', 'vel_east',
       'vel_down', 'ground_speed', 'hdg', 'accuracy_speed', 'accuracy_hdg',
       'date_valid', 'time_valid', 'time_resolved', 'fix_type', 'fix_valid',
       'diff_used', 'psm_state', 'hdg_veh_valid', 'carrier_phase',
       'invalid_llh']
ACC_BOOST_THRESHOLD = 1
TIME_CONVERSION = 1E6

def load_sensor_data(file, colNames=None, time_conversion=TIME_CONVERSION):
    """_summary_

    Args:
        file (_type_): _description_
        colNames (_type_, optional): If the column headers in the csv are not the default names,
        put the actual names here. Enter them in the order that matches the corresponding default name,
        which does not need to be the order they appear in the file. Defaults to None.
    """
    try:
        df = pd.read_csv(file)
        if colNames is None:
            assert(sorted(df.columns) == sorted(SENSOR_COL_NAMES))
        else:
            df = fix_col_headers(df, SENSOR_COL_NAMES, colNames)
        df['time'] = df['timestamp'] / time_conversion # add converted time
    except (FileNotFoundError, AssertionError) as e:
        print("Error loading {}. Check filepath or colheaders".format(file))
        df = None
    return df
    

def load_se_data(file, colNames=None, time_conversion=TIME_CONVERSION):
    try:
        df = pd.read_csv(file)
        if colNames is None:
            assert(sorted(df.columns) == sorted(SE_COL_NAMES))
        else:
            df = fix_col_headers(df, SE_COL_NAMES, colNames)
        df['time'] = df['timestamp'] / time_conversion # add converted time
    except (FileNotFoundError, AssertionError) as e:
        print("Error loading {}. Check filepath or colheaders".format(file))
        df = None
    return df
  
def load_gps_data(file, colNames=None, time_conversion=TIME_CONVERSION):
    try:
        df = pd.read_csv(file)
        if colNames is None:
            assert(sorted(df.columns) == sorted(GPS_COL_NAMES))
        else:
            df = fix_col_headers(df, GPS_COL_NAMES, colNames)
        if time_conversion is None: time_conversion = TIME_CONVERSION
        df['time'] = df['timestamp'] / time_conversion # add converted time
    except (FileNotFoundError, AssertionError) as e:
        print("Error loading {}. Check filepath or colheaders".format(file))
        df = None
    return df

def load_tm_data(file):
    pass

def find_flight_time():
    pass

def fix_col_headers(df, defaultNames, altNames):
    ## Changes alt col names to their corresponding default names so all the other functions can work.
    new_df = pd.DataFrame()
    for i in range(len(defaultNames)):
        new_df[defaultNames[i]] = df[altNames[i]]
    return new_df


def trim_data(df, tstart, tstop):
    #TODO: conditions for time not in range
    i_min = np.min(df.index[df['time']>=tstart])
    i_max = np.max(df.index[df['time']<=tstop])
    trimmed_df = df.iloc[i_min:i_max]
    trimmed_df = trimmed_df.reset_index()
    t0 = trimmed_df['time'][0]
    trimmed_df['adjusted_time'] = trimmed_df['time'] - t0
    return trimmed_df

#%% PLOTTING FUNCTIONS
def formatPlot(xlabel, ylabel, title):
    plt.grid(True)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.title(title)


def plot_pressure(sensor_df, xlim=None, name=""):
    if 'adjusted_time' in sensor_df: t = sensor_df['adjusted_time']
    else: t = sensor_df['time']

    fig = plt.figure()
    plt.plot(t, sensor_df['pressure'])
    formatPlot("time (s)", "pressure (mBar)", name + " Pressure")
    if xlim is not None: plt.xlim(xlim)
    return fig

def plot_accel(sensor_df, xlim=None, name="", include_H=True, include_I=True):
    if 'adjusted_time' in sensor_df: t = sensor_df['adjusted_time']
    else: t = sensor_df['time']

    fig = plt.figure()
    if include_I:
        plt.plot(t, sensor_df['acc_i_x'], label="IMU a_x")
        plt.plot(t, sensor_df['acc_i_y'], label="IMU a_y")
        plt.plot(t, sensor_df['acc_i_z'], label="IMU a_z")
    if include_H:
        if (include_I): 
            plt.gca().set_prop_cycle(None) # reset colors so the axes have matching colors
            ls = '--'
        else: ls = '-'
        plt.plot(t, sensor_df['acc_h_x'], label="HGA a_x", linestyle=ls)
        plt.plot(t, sensor_df['acc_h_y'], label="HGA a_y", linestyle=ls)
        plt.plot(t, sensor_df['acc_h_z'], label="HGA a_z", linestyle=ls)
    formatPlot("time (s)", "acceleration (G)", name + " Raw Accel")
    plt.legend()
    if xlim is not None: plt.xlim(xlim)
    return fig

def plot_accel_corrected(sensor_df, xlim=None, name="", upaxis=0, include_H=True, include_I=True):
    pass
    
def plot_angular_rate(sensor_df, xlim=None, name=""):
    if 'adjusted_time' in sensor_df: t = sensor_df['adjusted_time']
    else: t = sensor_df['time']

    fig = plt.figure()
    plt.plot(t, sensor_df['rot_i_x'], label="IMU r_x")
    plt.plot(t, sensor_df['rot_i_y'], label="IMU r_y")
    plt.plot(t, sensor_df['rot_i_z'], label="IMU r_z")
    formatPlot("time (s)", "Body Angular Rate (deg/s)", name + " Rotation Rates")
    plt.legend()
    if xlim is not None: plt.xlim(xlim)
    return fig

def plot_pressure_alt(sensor_df, xlim=None, name=""):
    if 'adjusted_time' in sensor_df: t = sensor_df['adjusted_time']
    else: t = sensor_df['time']
    alt = pressureToAlt(sensor_df['pressure'])

    fig = plt.figure()
    plt.plot(t, alt)
    formatPlot("time (s)", "Altitude MSL (km)", name + " Altitude")
    if xlim is not None: plt.xlim(xlim)
    return fig

def plot_gps_state(gps_df, xlim=None, name=""):
    if 'adjusted_time' in gps_df: t = gps_df['adjusted_time']
    else: t = gps_df['time']
    fig = plt.figure()

    plt.subplot(2,1,1)
    y = gps_df['height']
    plt.plot(t, y, label="GPS Height")
    bound = np.array(gps_df.loc[:,'accuracy_vertical'])
    bound[gps_df.index[gps_df.loc[:,'fix_valid'] == 0]] = np.nan
    plt.plot(t, y+bound, ':', t, y-bound, ':', color='#666666', lw=.5)
    plt.fill_between(t, y-bound, y+bound, facecolor='#ffff00', alpha=0.3, label="Accuracy Bound")
    plt.grid(True)
    plt.xlabel("time (s)")
    plt.ylabel("GPS Height (m)")

    plt.subplot(2,1,2)
    y = gps_df['vel_down'] * -1
    plt.plot(t, y, label='GPS Speed')
    bound = np.array(gps_df.loc[:,'accuracy_speed'])
    bound[gps_df.index[gps_df.loc[:,'fix_valid'] == 0]] = np.nan
    plt.plot(t, y+bound, ':', t, y-bound, ':', color='#666666', lw=.5)
    plt.fill_between(t, y-bound, y+bound, facecolor='#ffff00', alpha=0.3, label="Accuracy Bound")
    plt.grid(True)
    plt.xlabel("time (s)")
    plt.ylabel("GPS Speed (m/s)")
    # return fig

def plot_gps_3d():
    pass

def plot_vertical_se(se_df, xlim=None, name=""):
    if 'adjusted_time' in se_df: t = se_df['adjusted_time']
    else: t = se_df['time']
    fig = plt.figure()

    data = [se_df['pos_d']*-1, se_df['vel_d']*-1, se_df['acc_d']*-1]
    labels = ["Height (m)", "Velocity (m/s)", "Acceleration (m/s^2)"]
    for p in range(3):
        plt.subplot(3,1,p+1)
        plt.plot(t, data[p])
        plt.grid(True)
        plt.xlabel("Time (s)")
        plt.ylabel(labels[p])

    #TODO: phase transition lines
    return fig

#%% ANALYSIS FUNCTIONS
def pressureToAlt(pressure):
    SEA_LEVEL_PRESSURE = 1013.25  # Standard sea level pressure in millibars
    LAPSE_RATE = 0.0065           # Standard temperature lapse rate in K/m
    return 44330 * (1 - np.power((pressure / SEA_LEVEL_PRESSURE), 1 / 5.25588))

def altToPressure(alt):
    # assert alt > 0 # if altitude is negative it breaks
    # alt = np.max([alt,[0]]) # it breaks with negative alt. 
    SEA_LEVEL_PRESSURE = 1013.25  # Standard sea level pressure in millibars
    p = ((1 - alt/44330)**5.25588) * SEA_LEVEL_PRESSURE
    assert ~np.isnan(p).any()
    return p