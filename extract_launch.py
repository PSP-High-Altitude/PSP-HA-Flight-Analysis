from time import perf_counter_ns

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

DAT_FILENAME = r"C:\Users\imomg\Downloads\dm2_dat_04.csv"
GPS_FILENAME = r"C:\Users\imomg\Downloads\dm2_gps_04.csv"
TGT_FILENAME = r"dm2_dat_launch.csv"

DAT_INTERVAL_MS = 30

LAUNCH_THRESHOLD_G = 4
LAUNCH_BOOST_PERIOD_S = 2

EXTRA_RANGE_S = 10
STATIONARY_TOLERANCE_G = 0.1


def detect_launch(acc_g: pd.Series) -> int:
    """Detect a launch event in the given acceleration time series.

    parameters:
        acc_g - the magnitude of the acceleration experienced (in g)

    returns:
        Integer that is the index of the start of a sustained acceleration
        greater than LAUNCH_THRESHOLD_G for a period of at least
        LAUNCH_BOOST_PERIOD_S
    """
    threshold_exceeded = acc_g > LAUNCH_THRESHOLD_G
    threshold_run_length = 1000*LAUNCH_BOOST_PERIOD_S//DAT_INTERVAL_MS

    run_length = 0
    run_start_idx = 0
    for i, exceeded in enumerate(threshold_exceeded):
        if exceeded:
            if run_length == 0:
                run_start_idx = i
            run_length += 1
        else:
            run_length = 0
        if run_length > threshold_run_length:
            break
    else:  # Did not find a run of sufficient length
        raise ValueError("Unable to detect launch with given parameters")

    return run_start_idx


def extract_launch(data: pd.DataFrame) -> pd.DataFrame:
    """Extract the part of the given dataframe corresponding to launch.

    parameters:
        data - pandas dataframe containing the Timestamp and x, y, and z acc

    returns:
        Trimmed dataframe with only the rows that extend from EXTRA_RANGE_S
        seconds before the launch event to EXTRA_RANGE_S seconds after the
        landing event with the timestamp zeroed to launch
    """
    acc_mag = np.sqrt(data["Ax"]**2 + data["Ay"]**2 + data["Az"]**2)

    launch_idx = detect_launch(acc_mag)
    start_idx = launch_idx - 1000*EXTRA_RANGE_S//DAT_INTERVAL_MS

    pl_data = data[start_idx:]
    pl_acc_mag = acc_mag[start_idx:]

    within_tolerance = 0
    end_idx = pl_data.shape[0] - 1
    for i, datapoint in enumerate(pl_acc_mag):
        if abs(datapoint - 1) < STATIONARY_TOLERANCE_G:
            within_tolerance += 1
        else:
            within_tolerance = 0
        if within_tolerance > 1000*EXTRA_RANGE_S//DAT_INTERVAL_MS:
            end_idx = i
            break

    pd.options.mode.chained_assignment = None  # default='warn'

    l_data = pl_data[:end_idx]

    launch_timestamp = data["Timestamp"][launch_idx]
    l_data["Timestamp"] -= launch_timestamp

    pd.options.mode.chained_assignment = "warn"  # default='warn'

    return l_data


def main():
    data = pd.read_csv(DAT_FILENAME)

    extract_start = perf_counter_ns()
    launch_data = extract_launch(data)
    print(
        f"Extracted {launch_data.shape[0]} rows from {data.shape[0]} "
        f"total rows in {(perf_counter_ns() - extract_start)/1e6} ms"
    )

    acc_mag = np.sqrt(
        launch_data["Ax"]**2 +
        launch_data["Ay"]**2 +
        launch_data["Az"]**2
    )

    plt.plot(launch_data["Timestamp"]/1000, acc_mag)
    plt.grid()
    plt.show()

    launch_data.to_csv(TGT_FILENAME, index=False)
    print(f"Wrote launch data to {TGT_FILENAME}")


if __name__ == "__main__":
    main()
