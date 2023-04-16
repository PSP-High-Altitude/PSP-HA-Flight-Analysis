file_in = readtable("dm2_data.csv");
Ax_in = file_in.('Ax');
Ay_in = file_in.('Ay');
Az_in = file_in.('Az');
A = [Ax_in Ay_in Az_in];

A_mag = (A(:,1) .^ 2 + A(:,2) .^ 2 + A(:,3) .^ 2) .^ .5;

t = file_in.('Timestamp');

plot(t, A_mag)