import os
import signal
import subprocess
import glob
import shutil
import datetime as dt
import time
import threading
import serial # need to ensure pyserial installed (python -m pip install pyserial
import math
import pandas as pd # pip install pandas
import numpy as np
from threading import Timer
from datetime import datetime
from distutils.dir_util import copy_tree
from subprocess import check_output
from matplotlib import pyplot as plt #pip install matplotlib

def initial_start():
    # grab the initial datetime info
    d = datetime.now()
    initYear = "%04d" % (d.year)
    initMonth = "%02d" % (d.month)
    initDate = "%02d" % (d.day)
    initHour = "%02d" % (d.hour)
    initMins = "%02d" % (d.minute)
    initSecs = "%02d" % (d.second)

    zz = 5
    a = range(0,60,zz)
    z = int(initMins)
    takeClosest = lambda num, collection:min(collection,key=lambda x:abs(x-num))
    startAt = takeClosest(z,a)+zz
    if startAt == 60:
        startAt = 0
    print (startAt)

    if 1<= startAt <= 55:
        y = d.replace(minute=startAt, second=0, microsecond=0)
    else:
        y = d.replace(hour=d.hour+1, minute=0, second=0, microsecond=0)

    delta_t = y-d
    secs = delta_t.seconds+1
    print(secs)
    time.sleep(secs)

    
def livoxInitiate():

    global marker
    marker = 0

    time.sleep(30)  # give it chance for the livox to boot up
    
    #Specify the path of the exe and cd to that folder
    path ='C:/Users/GPSR/Desktop/LIVOX/Livox-SDK-master/build/sample/hub_lvx_file/Debug'
    os.chdir(path)

    while True:

        # specify the runtime
        runLength = 60

        # define the argument and run in the shell - this is the location of the compiled lvx files
        args = "start C:/Users/GPSR/Desktop/LIVOX/Livox-SDK-master/build/sample/hub_lvx_file/Debug/hub_lvx_sample -t " + str(runLength)

        # set the process commands
        marker = 1
        pro = subprocess.Popen(args, stdout=subprocess.PIPE, shell=True)
        
        # kill the process after the set time to prevent multiple occuring if no power
        try:
            time.sleep(runLength + 10)
            pro.kill()
            args = "taskkill /F /IM hub_lvx_sample.exe"
            pro2 = subprocess.Popen(args, stdout=subprocess.PIPE, shell=False)       
        except:
            print ("no process to kill")

        marker = 0

        # move the file to a new location with the same name
        time.sleep(10) # give it chance to close the written file
        fileList = glob.glob(path + '/*.lvx')
        try:
            latestFile = max(fileList, key=os.path.getctime)
            shutil.move(latestFile, "C:/livox-data/")
            time.sleep(60) # once moved, wait for 50-s
            os.system("shutdown /s /t 1") # shutdown the PC after file moved
        except:
            print ("no file with .lvx extension available")

        time.sleep(10) # 15-mins


def uploadAll():
    path = 'C:/'
    folderToSave = 'livox-data'

    while True:
        existingItems = os.listdir('C:/' + folderToSave + '/')
        iter1 = len(existingItems)
        
        savePathAll = 'python C:/s3cmd-master/s3cmd sync ' + path + folderToSave + '/' + ' s3://' + folderToSave + ' -v'
        pro3 = subprocess.run(savePathAll, shell=True, capture_output=True)
        time.sleep(300) # sleep for 5-mins
   
def accelerometer():

    time.sleep(5)  # wait for the marker var to be assigned from livox fcn

    while True:
        if marker == 0:
            time.sleep(1)
        elif marker == 1:
            saveLocation = "C:/livox-data/"
            port = 'COM8'  # define the active com port
            usbacc = serial.Serial(port)  # create the com port object
            RANGE = 2  # define the range as multiples of g
            serialcmd = 'RANGE ' + str(RANGE)
            usbacc.write(serialcmd.encode())

            sample_rate = 200  # define the sample frequency
            serialcmd = 'FREQ ' + str(sample_rate)
            usbacc.write(serialcmd.encode())
            time.sleep(0.5)

            # initiialise the object
            serialcmd = 'STOP'
            usbacc.write(serialcmd.encode())
            serialcmd = 'START'
            usbacc.write(serialcmd.encode())

            # get the time just before logging begins
            d = datetime.now()
            initYear = "%04d" % (d.year)
            initMonth = "%02d" % (d.month)
            initDate = "%02d" % (d.day)
            initHour = "%02d" % (d.hour)
            initMins = "%02d" % (d.minute)
            initSecs = "%02d" % (d.second)
            filename = str(initYear) + str(initMonth) + str(initDate) + "_" + str(initHour) + str(initMins) + str(initSecs) + ".csv"

            # read the samples
            sample_duration = 100 #seconds
            n_samples = sample_rate * sample_duration
            input_csv = []

            for _ in range(n_samples):
                input_csv.append(usbacc.readline())
            #print (input_csv)
            
            def csv_to_2D_list(csv_list):
                return [list(map(float, acc_sample[0:-2].split(b','))) for acc_sample in csv_list] #needed to add the bytes object


            acc = csv_to_2D_list(input_csv)
            #print (acc)

            # calculate average acceleration
            accx_avg = 0.0
            accy_avg = 0.0
            accz_avg = 0.0

            for sample in acc:
                #print(sample)
                accx_avg = accx_avg + sample[0]
                accy_avg = accy_avg + sample[1]
                accz_avg = accz_avg + sample[2]

            accx_avg = accx_avg / float(n_samples)
            accy_avg = accy_avg / float(n_samples)
            accz_avg = accz_avg / float(n_samples)

            # calculate total average acceleration
            g = 9.81 # define g
            a = g * math.sqrt(accx_avg**2 + accy_avg**2 + accz_avg**2) * (RANGE / 512.0)

            # close usb connection
            usbacc.close()

            # convert to numpy array
            A = np.array(acc)
            A_ms = A * RANGE * g / 512.0

            #print(A_ms)
            #print('\nTotal average acceleration is equal ' + str(a) + ' m/s^2')

            xOut = A_ms[:, 0]
            yOut = A_ms[:, 1]
            zOut = A_ms[:, 2]

            # dictionary of lists
            dict = {'x [m/s]': xOut, 'y [m/s]': yOut, 'z [m/s]': zOut}
            df = pd.DataFrame(dict)
            df.to_csv(saveLocation + filename)

            #plt.plot(A_ms)
            #plt.legend(['x axis', 'y-axis', 'z-axis'])
            #plt.show()

# Create the threads and run them
#thread0 = threading.Thread(name='uploadAll', target=uploadAll)
#thread0.start()
thread1 = threading.Thread(name='livoxInitiate', target=livoxInitiate)
thread1.start()
thread2 = threading.Thread(name='accelerometer', target=accelerometer)
thread2.start()


        





