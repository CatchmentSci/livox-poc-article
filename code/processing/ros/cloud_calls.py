import os
import sys
import subprocess
import time
from datetime import datetime
import threading
from threading import Timer
import glob
import shutil
import re

#Need to list all of the bucketPrefix  available in the S3 cloud for this to work correctly
bucketPrefix = ["livox-data"]  # needs to be in alphabetical order
destFolder = "/aws_lvx_files/"


# Iterate over the list of filepaths & remove each file.
fileList = glob.glob(destFolder + "*")
for filePath in fileList:
    try:
        os.remove(filePath)
    except:
        print("Error while deleting file : ", filePath)


fileList = glob.glob("/aws_bag_files/*")
for filePath in fileList:
    try:
        os.remove(filePath)
    except:
        print("Error while deleting file : ", filePath)


fileList = glob.glob("/aws_pcd_files/*")
for filePath in fileList:
    try:
        os.remove(filePath)
    except:
        print("Error while deleting file : ", filePath)


p = subprocess.Popen("s3cmd ls s3://livox-data", shell=True, stdout=subprocess.PIPE) # list the bucket names

bucketList = []
res = []
for line in iter(p.stdout.readline,''):
    try:
        x = line.split()
        x = str(x[3],'utf-8')
        #print (x)
        bucketList.append(x)
        y = x.split('/')
        y = y[3]
        res.append(y)
    except:
        break

#print (bucketList)
nlines = len(bucketList)
#print (nlines)
#print (res)

for t in range(0,nlines):

    for i in range(0,nlines):
        # Generate the list of files already in the bag_data bucket
        fname = os.path.basename(res[i])
        tname = fname[:-3] + "bag"
        pathCall = "sudo s3cmd ls s3://rosbag-data"
        process = subprocess.Popen(pathCall,shell=True, stdout=subprocess.PIPE)
        output = str(process.communicate())
        #print (output)

        if tname in output: # if the item in Data already exists in s3
            print ("skipping over this file")
        else:
            # download the i'th file on s3 and store locally
            command = "get --skip-existing --no-check-md5 --recursive " + bucketList[i] + " " + destFolder
            commandFull = "s3cmd " + command
            #print (commandFull)
            r = subprocess.Popen(commandFull, shell=True, stdout=subprocess.PIPE)
            output = str(r.communicate())
            #print (output)

            # provide the necessary link
            t = subprocess.Popen('source ./devel/setup.bash', shell=True, cwd='/ws_livox')
            output = str(t.communicate())
            #print (output)

            # Generate the list of files already in the bag_data bucket
            fname = os.path.basename(res[i])
            tname = fname[:-3] + "bag"
            pathCall = "sudo s3cmd ls s3://rosbag-data"
            process = subprocess.Popen(pathCall,shell=True, stdout=subprocess.PIPE)
            output = str(process.communicate())
            print (output)

            # convert to rosbag and copy the file to new folder
            #s = subprocess.Popen(command, shell=True, cwd='/ws_livox') # works without timeout option
            for ii in range(0,1):
                if ii == 0:
                    command = 'roslaunch livox_ros_driver lvx_to_rosbag.launch lvx_file_path:="/aws_lvx_files/' + fname + '"'
                else:
                    command = 'roscore'
                print (command)

                try:
                    s = subprocess.call(command, shell=True, cwd='/ws_livox', timeout=25) #works with timeout option - but also throws an error so needs catch
                except:
                    print("forced break")

                time.sleep(25)
                command = "/aws_lvx_files/" + tname
                print (command)
                shutil.move(command, "/aws_bag_files/")
                time.sleep(25)

        # Generate the list of files already in the pcd_data bucket
        tname2 = fname[:-3] + "pcd"
        pathCall = "sudo s3cmd ls s3://pcd-livox-data"
        process = subprocess.Popen(pathCall,shell=True, stdout=subprocess.PIPE)
        output = str(process.communicate())
        #print (output)
        if fname[:-3] + "zip" in output: # if the item in Data already exists in s3
                print ("skipping over this file")
        else:
            # convert to pcd files
            for ii in range(0,1):
                if ii == 0:
                    command = "rosrun pcl_ros bag_to_pcd /aws_bag_files/" + tname + " /livox/lidar /aws_pcd_files/" + fname[:-4] + "/"
                else:
                    command = 'roscore'
                print (command)

                try:
                    s = subprocess.call(command, shell=True, cwd='/ws_livox', timeout=25) #works with timeout option - but also throws an error so needs catch
                except:
                    print("forced break")

                time.sleep(25)

            # zip the files
            command = "zip -r /aws_pcd_files/" + fname[:-4] + ".zip /aws_pcd_files/" + fname[:-4]
            print (command)
            try:
                s = subprocess.call(command, shell=True) #works with timeout option - but also throws an error so needs catch
                print ("zip completed")
            except:
                print("forced break")

            # remove the individual pcd files
            shutil.rmtree("/aws_pcd_files/" + fname[:-4] + "/")


            # upload the i'th bagfile to s3
            itemsToRemove = os.listdir("/aws_bag_files/") # Specify the files being uploaded/deleted
            iter1 = len(itemsToRemove) # Number of files in the directory
            print ("---------- Uploading rosbag data to AWS ----------")
            savePathAll = "s3cmd sync " + "/aws_bag_files/" + " s3://rosbag-data" # Upload the newly generated files to the AWS
            process = subprocess.Popen(savePathAll,shell=True, stdout=subprocess.PIPE)
            output = str(process.communicate())
            print (output)
            print ("---------- New rosbag data uploaded to AWS ----------")

            # Generate the list of files already in the bucket
            pathCall = "sudo s3cmd ls s3://rosbag-data"
            process = subprocess.Popen(pathCall,shell=True, stdout=subprocess.PIPE)
            output = str(process.communicate())
            #print (output)
            if iter1 > 0: # if there are files in the Data directory
                for x in range(0,iter1): # Run this for the number of files in the directory
                    if itemsToRemove[x] in output: # if the item in Data already exists in s3
                        os.remove("/aws_bag_files/" + itemsToRemove[x][:-3] + "bag") # Remove them one-by-one
            print ("---------- Locally stored rosbag files removed after upload ----------")

            # upload the i'th pcd file to s3
            itemsToRemove = os.listdir("/aws_pcd_files/") # Specify the files being uploaded/deleted
            iter1 = len(itemsToRemove) # Number of files in the directory
            print ("---------- Uploading pcd data to AWS ----------")
            savePathAll = "s3cmd sync " + "/aws_pcd_files/" + " s3://pcd-livox-data" # Upload the newly generated files to the AWS
            process = subprocess.Popen(savePathAll,shell=True, stdout=subprocess.PIPE)
            output = str(process.communicate())
            #print (output)
            print ("---------- New pcd data uploaded to AWS ----------")

            # Generate the list of files already in the bucket
            pathCall = "sudo s3cmd ls s3://pcd-livox-data"
            process = subprocess.Popen(pathCall,shell=True, stdout=subprocess.PIPE)
            output = str(process.communicate())
            #print (output)
            if iter1 > 0: # if there are files in the Data directory
                for x in range(0,iter1): # Run this for the number of files in the directory
                    if itemsToRemove[x] in output: # if the item in Data already exists in s3
                        os.remove("/aws_pcd_files/" + itemsToRemove[x]) # Remove them one-by-one
            print ("---------- Individual pcd files removed ----------")





