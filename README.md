<p align="center"> 
  <img src="images/livox_mid40.jpg" alt="Livox-mid-40" width="200px">
</p>
<h1 align="center"> Livox mid-40 </h1>
<h3 align="center"> Data acquisiiton and processing </h3>  

</br>

<!-- TABLE OF CONTENTS -->
<h2 id="table-of-contents"> :book: Table of Contents</h2>

<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project"> ➤ About The Project</a></li>
    <li><a href="#prerequisites"> ➤ Prerequisites</a></li>
    <li><a href="#Repository Structure"> ➤ Repository Structure</a></li>
</details>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/aqua.png)

<!-- ABOUT THE PROJECT -->
<h2 id="about-the-project"> :pencil: About The Project</h2>

<p align="justify"> 
This project seeks to develop a workflow for ingesting data acquired by Livox mid-40 LiDAR systems for automated, and autonomous acquisition of 3D topographic data which can be used to determine environmental change.
</p>

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/aqua.png)

<!-- PREREQUISITES -->
<h2 id="prerequisites"> :fork_and_knife: Prerequisites</h2>

Interfacing with the livox sensors is currently acheived using a livox hub connected to a x64-based Windows 10 PC. Scripts required for this are found in the "interfacing" folder. This has the following dependencies:
* Python 3.10.*
* pyserial (if using accelerometer): python -m pip install pyserial
* pandas: pip install pandas
* livox sdk: https://github.com/Livox-SDK/Livox-SDK - this needs to be compiled (see Stu D for Ale's approach)

Post-processing of the acquired data is currently undertaken in a Linux docker container where scripts within the "processing" folder are executed.
* MATLAB 2019a onwards required

![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/aqua.png)

<!-- Repository Structure -->
<h2 id="Repository Structure"> :cactus: Repository Structure</h2>
<p align="justify"> 
  
Below is the an outline of the folder structure within repository with descriptions provided:
</p>
    .
    ├── code                    # folder containing scripts to work with the livox mid-40 scanners
    │   ├── interfacing         # scripts required to interface with mid-40
    │   ├── processing          # scripts for data processing
    ├── images                  # folder containing graphics 
 
  
![-----------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/aqua.png)
