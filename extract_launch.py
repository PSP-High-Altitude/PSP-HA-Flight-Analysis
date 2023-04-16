from time import perf_counter_ns

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

DAT_FILENAME = r"C:\Users\imomg\Downloads\dm2_dat_04.csv"
GPS_FILENAME = r"C:\Users\imomg\Downloads\dm2_gps_04.csv"
TGT_FILENAME = r"dm2_dat_launch.csv"

DAT_INTERVAL_MS = 30

EXTRA_RANGE_S = 10
LAUNCH_THRESHOLD_G = 5
STATIONARY_TOLERANCE_G = 0.1


def extract_launch(data: pd.DataFrame) -> pd.DataFrame:
    acc_mag = np.sqrt(data["Ax"]**2 + data["Ay"]**2 + data["Az"]**2)

    launch_idx = np.argmax(acc_mag > LAUNCH_THRESHOLD_G)
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

    return pl_data[:end_idx]


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

    plt.plot(launch_data["Timestamp"], acc_mag)
    plt.grid()
    plt.show()

    launch_data.to_csv(TGT_FILENAME, index=False)
    print(f"Wrote launch data to {TGT_FILENAME}")


if __name__ == "__main__":
    main()
