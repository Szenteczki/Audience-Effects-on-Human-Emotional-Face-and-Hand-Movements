This repository contains the data and scripts needed to reproduce the analyses in our preprint, *Audience Effects on Human Emotional Face and Hand Movements*. We used the software [OpenFace 2.0](https://github.com/TadasBaltrusaitis/OpenFace/wiki) and [Py-Feat](https://py-feat.org); if you wish to use these two software tools in your own research, please don't forget to cite them as well:

- [OpenFace Citations](https://github.com/TadasBaltrusaitis/OpenFace/wiki#citation)
- [Py-Feat preprint](https://arxiv.org/abs/2104.03509)

## Overview

This repo contains four main folders, in addition to the primary R script used to perform our analyses:

### /data/
This folder contains two archives, containing the complete, frame-by-frame results from analyzing our video files with OpenFace 2. These raw CSV files can be used to re-generate the input files used for subsequent analysis using lines 18-48 in `analysis.R`. We encourage others to use our data in their own research as well. 

### /input/
This folder contains the files used for all of our analyses in R. Here, we have merged the averaged AU data generated by OpenFace with all of the anonymized participant metadata that we are permitted to share publicly. 

`social.txt` contains the data for individuals who participated in the social condition (*i.e.* watched video stimuli in the presence of someone else), while `alone.txt` contains the data for individuals who participated in the alone condition (*i.e.* watched video stimuli in isolation). 

### /output/
This folder contains the output files that are generated by running `analysis.R`. We have provided the full outputs of our R script here for reference. The files for reproducing our modeling analyses are also provided here.

### /scripts/
This folder contains small scripts written in bash (.sh) and python (.py) used to carry out parts of our analysis. Our Py-Feat analysis, which was run using the script `heatmap.py` is also provided here, in a separate sub-folder. 

## A brief guide to automating facial action unit analysis

While the Methods section of our paper details the tools and techniques used to produce our results, we will provide further technical details here. We hope this may provide greater insight into how we produced our results, while also giving some guidance to those wishing to replicate our methods with their own data.

### 1 - Prepare your input files

It is important to control variation in your input videos to get the most consistent results possible from OpenFace. For example, OpenFace will generate one measurement per frame of video, so you should ensure an equal framerate across all footage used. We opted to downsample our recordings to 15fps, which reduced the size of the raw output files while still maintaining a high rate of sampling for our purposes.

Additionally, you may want to crop out any faces visible in the video beside your subject of interest. There is an OpenFace binary for analyzing videos with multiple faces present (`FaceLandmarkVidMulti`); however, since we did not seek permission to analyze the facial expression data of the partners in the social condition, we opted to completely crop the partners out and use the single-face binary (`FeatureExtraction`) for both the alone and social condition footage.

The most efficient way we found to crop our footage was by using `mpv` and the [`mpv-webm`](https://github.com/ekisu/mpv-webm) add-on script, which can be installed in Ubuntu 16.04 as follows: 

`sudo apt install mpv`

`mkdir -p ~/.config/mpv/scripts`

`wget -O ~/.config/mpv/scripts/webm.lua https://github.com/ekisu/mpv-webm/releases/download/latest/webm.lua`

Once installed, opening a video with mpv and pressing Shift-W will display an OSD overlay that allows you to crop the video using a simple point and click interface, and use keyboard shortcuts to modify the start/end of the video (optional) and re-encode the final output video. If you need to crop the video frame (as we did to remove the second participant in the social condition), then make sure not to crop in too tight, and leave the body of the participant of interest in the frame as well.

Evenly lit, HD video is ideal, but in practice we found that OpenFace performed well with standard webcam footage and could detect AU intensity and activity without any issues.

### 2 - Install OpenFace and Py-Feat

Installing and running OpenFace and Py-Feat will require some basic knowledge of command-line (*e.g.* Terminal) tools. Both OpenFace and Py-Feat offer one-line installation scripts, but if these fail to run you may need to do some extra work installing dependencies and manually compiling C++ code. We found it easier to install and run OpenFace on [Ubuntu 16.04](https://ubuntu.com/tutorials/install-ubuntu-desktop-1604#1-overview), following the instructions [here](https://github.com/TadasBaltrusaitis/OpenFace/wiki/Unix-Installation). However, MacOS installation instructions are available [here](https://github.com/TadasBaltrusaitis/OpenFace/wiki/Mac-installation) if needed. Whether you proceed via the quick installation or manual compiling, we will use the binaries (i.e. the compiled executable files) produced by the installation process in the next steps.

Py-Feat installation instructions can be found [here](https://py-feat.org/pages/intro.html#installation). As long as you have `pip` installed (see instructions [here](https://pip.pypa.io/en/stable/installation/) if needed), it should install with a single Terminal command in Linux and MacOS: `pip install py-feat`

### 3 - Run OpenFace

We provided a small script to automate the analysis of multiple video files using Openface: `scripts/batch.sh`

To use this, you should copy your video files and the above script into the folder containing your OpenFace binaries. These should be in .../OpenFace/build/bin - alternatively, search for the folder containing `FeatureExtraction` (without any file extension), which is the binary used by this script. Then, run `./batch.sh` from this folder. 

As Openface runs, it should create a new folder named `/processed/`. This contains the processed video files with facial landmark overlays, and output .csv files. You will use these .csv files for the next step of the analysis.

### 4 - Clean up OpenFace output CSVs

Since the OpenFace .csv output files are large tables containing over 700 columns, we opted to remove the unused columns to make it easier to manage all of the data in R. We also provided a small script to automate this: `scripts/cut.sh`

As the instructions in the header of this script indicate, this script should be run from a folder containing two sub-folders, named `/raw/` and `/clean/`. Your OpenFace .csv files should be copied into the `/raw/` folder you made. Then run `./cut.sh` from the folder containing the `/raw/` and `/clean/` folders. The trimmed down CSV files should now be available in the `/clean/` folder.

The AU data in the output tables will be available in two formats: intensity (*i.e.* 0-5, denoted by `_r`) or presence/absence (*i.e.* 0 or 1, denoted by`_c`). Make sure the format you use meets the assumptions of your downstream statistical analyses.

### 5 - Downstream analysis in R

Now that you have cleaned up the OpenFace outputs, you are ready to proceed with further analyses in R. The file `analysis.R`, available in the root of this repository contains all of the analyses and visualizations in our study (except for Py-Feat plots; see next step).

As mentioned above, lines 18-48 in this script also contains a function we wrote for calculating average AU values from the raw .csv files, which generated the main summarized tables for the alone and social conditions used for further analysis. The only part which we have not fully automated in this repo is merging our anonymized metadata for participants with the AU summary tables. This was done using the [VLOOKUP](https://support.microsoft.com/en-us/office/vlookup-function-0bbc8083-26fe-4963-8ab8-93a18ad188a1) function in Excel, using the unique participant ID number to merge the two datasets.

### 6 - Visualizing AU data using Py-Feat

We created additional visualizations of our AU data with Py-Feat. Lines 411-446 in `analysis.R` are used to create the input files for our Py-Feat analysis. As mentioned above, we wrote a python script `/scripts/py-feat/heatmap.py` that takes these input files and generates visualizations for each row in the input table. This script allows you to automate the process of generating AU visualizations, simply by adding additional rows to your input file.

Note: Py-Feat offers a free, open-source package that is an all-in-one solution for facial expression analysis. While we only used it to visualize our summarized OpenFace results, it could also be used to extract facial landmarks and AUs.
