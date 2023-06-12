<p align="center"> 
  <img src="images/livox_mid40.jpg" alt="Livox-mid-40" width="200px">
</p>
<h1 align="center"> Livox mid-40 </h1>
<h3 align="center"> Data acquisition and processing </h3>  

</br>

<!-- TABLE OF CONTENTS -->
<h2 id="table-of-contents"> :book: Table of Contents</h2>

<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project"> ➤ About The Project</a></li>
    <li><a href="#prerequisites"> ➤ Prerequisites</a></li>
    <li><a href="#Repository Structure"> ➤ Repository Structure</a></li>
    <li><a href="#How to use"> ➤ How to use</a></li>

</details>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/aqua.png)

<!-- ABOUT THE PROJECT -->
<h2 id="about-the-project"> :pencil: About The Project</h2>

<p align="justify"> 
This project seeks to develop a workflow for ingesting data acquired by Livox mid-40 LiDAR systems for automated acquisition of 3D topographic data which can be used to determine environmental change. This repository is split into three sections, namely: i) code used to generate figures present within the research article "An evaluation of low-cost terrestrial LiDAR sensors for assessing geomorphic change"; ii) code used to interface with (drive) the Livox Mid-40 LiDAR sensors using a Latte Panda operating in Windows and; iii) code use to process the raw data acquired by the Livox sensors. 
</p>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/aqua.png)

<!-- PREREQUISITES -->
<h2 id="prerequisites"> :fork_and_knife: Prerequisites</h2>

Interfacing with the livox sensors is currently acheived using a livox hub connected to a x64-based Windows 10 PC. Scripts required for this are found in the "interfacing" folder. This has the following dependencies:
* Python 3.10.*
* pyserial (if using accelerometer): python -m pip install pyserial
* pandas: pip install pandas
* livox sdk: https://github.com/Livox-SDK/Livox-SDK - this needs to be compiled from source

Processing of the acquired data is currently undertaken through two routes:
* Files within the "ros" subfolder are executed in a Linux docker container. This container should be configured to work with the Robotics Operating System (ROS). The "cloud_calls.py" script assumes that data to be converted is stored within an Amazon S3 bucket with the converted data being uploaded once complete. S3cmd is required for this operation. This script is provided as an example and could be modified for your own individual case.
* Files within the "scan" subfolder are executed using MATLAB 2019a onwards.

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/aqua.png)

<!-- Repository Structure -->
<h2 id="Repository Structure"> :cactus: Repository Structure</h2>
<p align="justify"> 
  
Below is the an outline of the folder structure within repository with descriptions provided:
</p>

    .
    ├── code                    # folder containing scripts to work with the livox mid-40 scanners
    │   ├── fig3                # scripts required to generate outputs presented in Figure 3
    │   ├── fig4                # scripts required to generate outputs presented in Figure 3
    │   ├── fig5                # scripts required to generate outputs presented in Figure 5
    │   ├── fig6                # scripts required to generate outputs presented in Figure 6
    │   ├── fig7                # scripts required to generate outputs presented in Figure 7
    │   ├── interfacing         # scripts required to interface with mid-40 using a Latte Panda (on Windows)
    │   ├── processing          # scripts for data processing
    │   ├── processing          # scripts for data processing
    │   │   │── ros             # scripts for data conversion from lvx to pcd
    │   │   │── scan            # scripts for generating outputs from raw (.pcd) data
    ├── images                  # folder containing graphics 
 
  
![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/aqua.png)
  
<!-- How to use -->
<h2 id="How to use"> 👍 How to use</h2>
<p align="justify"> 
  
If you are interested primarily in replicating the outcomes of "An evaluation of low-cost terrestrial LiDAR sensors for assessing geomorphic change" follow these steps:
* Clone or download this repository so that it is accessible on your PC.
* Download the files from "Data for output replication" to your PC.  
* Open MATLAB on your PC.
* To generate Figure 3, esnure all scripts in "fig3" subfolder are accesible in your MATLAB search path, execute "master_fcn_fig3.m", ensuring that you provide the links to the directories containing the relevant datasets (downloaded from Step 2 above).
  
  
