from time import perf_counter_ns
import argparse

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

TIMESTAMP_UNIT_SCALE = 1e6
TIMESTAMP_LABEL = "timestamp"
ACC_X_LABEL = "acc_i_x"
ACC_Y_LABEL = "acc_i_y"
ACC_Z_LABEL = "acc_i_z"

def detect_launch(
        acc_g: np.ndarray,
        dat_interval_s: float,
        launch_threshold_g: float,
        launch_boost_period_s: float,
    ) -> int:
    """Detect a launch event in the given acceleration time series.

    parameters:
        acc_g - array of the magnitude of the acceleration experienced (in g)

    returns:
        Integer that is the index of the start of a sustained acceleration
        greater than launch_threshold_g for a period of at least
        LAUNCH_BOOST_PERIOD_S
    """
    # Find the indices in the original array that are above the threshold
    above_threshold_indices = np.nonzero(acc_g > launch_threshold_g)[0]

    # Find the difference of each element from the previous one, so that values
    # of 1 indicate that a run is ongoing and larger values indicate that a new
    # run is about to start
    run_starting = np.diff(above_threshold_indices) != 1

    # Find the indices of the starts of the runs and split the original indices
    # into individual runs using them
    runs = np.split(
        above_threshold_indices,
        np.nonzero(run_starting)[0] + 1,
    )

    # Return the index of the first run that is above the required run length
    for run in runs:
        if len(run) >= launch_boost_period_s//dat_interval_s:
            return run[0]

    raise ValueError("Unable to detect launch with given parameters")


def extract_launch(
        data: pd.DataFrame,
        extra_range_s: float,
        dat_interval_s: float,
        stationary_tol_g: float,
        launch_threshold_g: float,
        launch_boost_period_s: float,
    ) -> pd.DataFrame:
    """Extract the part of the given dataframe corresponding to launch.

    parameters:
        data - pandas dataframe containing the Timestamp and x, y, and z acc

    returns:
        Trimmed dataframe with only the rows that extend from extra_range_s
        seconds before the launch event to extra_range_s seconds after the
        landing event with the timestamp zeroed to launch
    """
    acc_mag = np.sqrt(
        data[ACC_X_LABEL]**2 + data[ACC_Y_LABEL]**2 + data[ACC_Z_LABEL]**2
    )

    launch_idx = detect_launch(
        acc_mag.to_numpy(),
        dat_interval_s,
        launch_threshold_g,
        launch_boost_period_s,
    )

    start_idx = launch_idx - int(extra_range_s/dat_interval_s)

    pl_data = data[start_idx:]
    pl_acc_mag = acc_mag[start_idx:]

    within_tolerance = 0
    end_idx = pl_data.shape[0] - 1
    for i, datapoint in enumerate(pl_acc_mag):
        if abs(datapoint - 1) < stationary_tol_g:
            within_tolerance += 1
        else:
            within_tolerance = 0
        if within_tolerance > extra_range_s/dat_interval_s:
            end_idx = i
            break

    pd.options.mode.chained_assignment = None  # default='warn'

    l_data = pl_data[:end_idx]

    start_time = l_data.iloc[0][TIMESTAMP_LABEL]
    end_time = l_data.iloc[-1][TIMESTAMP_LABEL]
    
    print(f"Detected launch from {start_time} to {end_time}")

    launch_timestamp = data[TIMESTAMP_LABEL][launch_idx]
    l_data[TIMESTAMP_LABEL] -= launch_timestamp

    pd.options.mode.chained_assignment = "warn"  # default='warn'

    return l_data


def parse_args():
    parser = argparse.ArgumentParser(description='Extract the data relating to launch from a sensor data dump')
    
    parser.add_argument('dat_filename', type=str,
                        help='Path to the sensor CSV file')
    parser.add_argument('tgt_filename', type=str,
                        help='Output path of trimmed CSV file')
    parser.add_argument('--launch_threshold_g', type=int, default=4,
                        help='Launch threshold in G')
    parser.add_argument('--launch_boost_period_s', type=int, default=2,
                        help='Launch boost period in seconds')
    parser.add_argument('--extra_range_s', type=int, default=10,
                        help='Extra range in seconds')
    parser.add_argument('--stationary_tol_g', type=float, default=0.05,
                        help='Stationary tolerance in G')
    
    return parser.parse_args()


def main():
    args = parse_args()
    
    data = pd.read_csv(args.dat_filename)
    data[TIMESTAMP_LABEL] /= TIMESTAMP_UNIT_SCALE

    dat_interval_s = data[TIMESTAMP_LABEL].diff().mean()

    extract_start = perf_counter_ns()

    launch_data = extract_launch(
        data,
        args.extra_range_s,
        dat_interval_s,
        args.stationary_tol_g,
        args.launch_threshold_g,
        args.launch_boost_period_s,
    )

    print(
        f"Extracted {launch_data.shape[0]} rows from {data.shape[0]} "
        f"total rows in {(perf_counter_ns() - extract_start)/1e6} ms"
    )

    plt.plot(
        launch_data[TIMESTAMP_LABEL], launch_data[ACC_X_LABEL],
        launch_data[TIMESTAMP_LABEL], launch_data[ACC_Y_LABEL],
        launch_data[TIMESTAMP_LABEL], launch_data[ACC_Z_LABEL],
    )
    plt.legend([ACC_X_LABEL, ACC_Y_LABEL, ACC_Z_LABEL])
    plt.grid()
    plt.show()

    launch_data.to_csv(args.tgt_filename, index=False)
    print(f"Wrote launch data to {args.tgt_filename}")


if __name__ == "__main__":
    main()
