import serial
import math
from time import sleep
from matplotlib import pyplot as plt
import pandas as pd
import numpy as np

# FOR LINUX, RASPBERRY PI, ...
port = 'COM5'
# FOR WINDOWS
# port = 'COM1'

usbacc = serial.Serial(port)

# CHANGE RANGE TO +- 4
RANGE = 2
serialcmd = 'RANGE ' + str(RANGE)
usbacc.write(serialcmd.encode())

# CHANGE FREQUENCY
# YOU DON'T NEED TO WAIT OR SLEEP
# IT IS ONLY FOR VISUAL EFFECT
sample_rate = 200
serialcmd = 'FREQ ' + str(sample_rate)
usbacc.write(serialcmd.encode())
sleep(0.5)


# STOP AND START FOR FUN
serialcmd = 'STOP'
usbacc.write(serialcmd.encode())
serialcmd = 'START'
usbacc.write(serialcmd.encode())


# READ N SAMPLES
sample_duration = 10
n_samples = sample_rate * sample_duration

input_csv = []

for _ in range(n_samples):
    input_csv.append(usbacc.readline())

def csv_to_2D_list(csv_list):
    # YOU CAN USE acc_sample.strip() OR acc_sample[0:-2]
    # TO GET RID OFF TWO LAST CHARACTERS: '\r\n'
    # '40,-100,127\r\n' --[0:-2] OR STRIP--> '40,-100,127' --
    # SPLIT--> ['40','-100','127'] --LIST AND MAP--> [4.0,-100.0,127.0]
    return [list(map(float, acc_sample[0:-2].split(','))) for acc_sample in csv_list]

acc = csv_to_2D_list(input_csv)

# PRINT COLLECTED DATA AND
# CALCULATE AVERAGE ACCELERETION IN m/s^2
accx_avg = 0.0
accy_avg = 0.0
accz_avg = 0.0

for sample in acc:
    print(sample)
    accx_avg = accx_avg + sample[0]
    accy_avg = accy_avg + sample[1]
    accz_avg = accz_avg + sample[2]

accx_avg = accx_avg / float(n_samples)
accy_avg = accy_avg / float(n_samples)
accz_avg = accz_avg / float(n_samples)

# CALCULATE TOTAL AVERAGE ACCELERATION
g = 9.81 # VELUE OF G IN METERS PER SECOND SQUARE
a = g * math.sqrt(accx_avg**2 + accy_avg**2 + accz_avg**2) * (RANGE / 512.0)

# CLOSE USB CONNECTION
usbacc.close()

# convert to numpy array
A = np.array(acc)
A_ms = A * RANGE * g / 512.0

print(A_ms)
print('\nTotal average acceleration is equal ' + str(a) + ' m/s^2')

xOut = A_ms[:, 0]
yOut = A_ms[:, 1]
zOut = A_ms[:, 2]

# dictionary of lists
dict = {'x [m/s]': xOut, 'y [m/s]': yOut, 'z [m/s]': zOut}
df = pd.DataFrame(dict)
df.to_csv('D:\\OneDrive - Newcastle University\\Personal Work\\GFG.csv')

plt.plot(A_ms)
plt.legend(['x axis', 'y-axis', 'z-axis'])
plt.show()
