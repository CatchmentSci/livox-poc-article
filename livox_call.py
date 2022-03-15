import os
import signal
import subprocess
import glob
import shutil
import datetime as dt
import time
import threading
from threading import Timer
from datetime import datetime
from distutils.dir_util import copy_tree
from subprocess import check_output


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

    time.sleep(30) # give it chance for the livox to boot up 
    
    #Specify the path of the exe and cd to that folder
    path ='C:/Users/GPSR/Desktop/LIVOX/Livox-SDK-master/build/sample/hub_lvx_file/Debug'
    os.chdir(path)

    while True:

        # specify the runtime
        runLength = 60

        # define the argument and run in the shell
        args = "start C:/Users/GPSR/Desktop/LIVOX/Livox-SDK-master/build/sample/hub_lvx_file/Debug/hub_lvx_sample -t " + str(runLength)

        # set the process commands
        pro = subprocess.Popen(args, stdout=subprocess.PIPE, shell=True)
        
        # kill the process after the set time to prevent multiple occuring if no power
        try:
            time.sleep(runLength + 10)
            pro.kill()
            args = "taskkill /F /IM hub_lvx_sample.exe"
            pro2 = subprocess.Popen(args, stdout=subprocess.PIPE, shell=False)       
        except:
            print ("no process to kill")

        # move the file to a new location with the same name
        time.sleep(10) # give it chance to close the written file
        fileList = glob.glob(path + '/*.lvx')
        try:
            latestFile = max(fileList, key=os.path.getctime)
            shutil.move(latestFile, "C:/livox-data/")
            time.sleep(20) # once moved, wait for 20-s
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
   


# Create the threads and run them
#thread0 = threading.Thread(name='uploadAll', target=uploadAll)
#thread0.start()

thread1 = threading.Thread(name='livoxInitiate', target=livoxInitiate)
thread1.start()



        





