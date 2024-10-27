from pal_plots import *

sensor_file = "..\..\Python\Data Files\pal_test\pal_fsl_test_dat.csv"
gps_file = "..\..\Python\Data Files\pal_test\pal_fsl_test_gps.csv"
se_file = "..\..\Python\Data Files\pal_test\pal_fsl_test_fsl.csv"
tm_file = "..\..\Python\Data Files\pal_test\2024-02-26-serial-8183-flight-0004.csv"

data = load_sensor_data(sensor_file)
plot_pressure(data)

df2 = trim_data(data, 0, 32101)
# plot_pressure(df2)
plot_accel(df2, name="Pal test")

gd = load_gps_data(gps_file)
gps_trim = trim_data(gd, df2['time'][0],df2['time'][0]+400)

plot_gps_state(gps_trim)
plt.show()
plt.pause(.1)
