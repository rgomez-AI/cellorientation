//*************************************************************************
// lif2tif - Open a "lif" files and convert to tif.
// Copyright (C) 2018  Raul Gomez Riera, All Rights Reserved
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. All advertising materials mentioning features or use of this software
//    must display the following acknowledgement:
//    This product includes software developed by the <organization>.
// 4. Neither the name of the ImageJ Macro nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY Raul Gomez Riera ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL Raul Gomez Riera BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  Date: 2020/11/04
//  Author: Raul Gomez
//  Contact information:
//  e-mail: raul.gomes@crg.eu
//*************************************************************************

requires("1.50f");
arg = getArgument();
strArray = split(arg, ",");
input = strArray[0];
output = strArray[1];
Split = strArray[2];
Zpro = strArray[3];
Flip = strArray[4];

print(" \n");
print("Running batch analysis with arguments:");
print("input="+input);
print("output="+output);
print("Split="+Split);
print("Zpro="+Zpro);
print("Flip="+Flip);

// Macro Initialization
run("Colors...", "foreground=white background=black selection=yellow");
call("java.lang.System.gc"); // java system garbage collector
run("Close All");

print("Installing Bio-Formats Macro Extensions ....");
wait(1000);
run("Bio-Formats Macro Extensions");
wait(1000);
print("\\Update:Installing Bio-Formats Macro Extensions .... Done!");

processFolder(input, output);
run("Quit");

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input, output) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i], output);
		if(endsWith(list[i], ".lif"))
			processFile(input, output, list[i], Split, Zpro, Flip);
	}
}



function processFile(input, output, file, Split, Zpro, Flip) {
	path = input+ File.separator + file;
	print(path);
	Ext.setId(path); 
	Ext.getSeriesCount(seriesCount); 
	for (s=1; s<=seriesCount; s++) {
		run("Bio-Formats Importer", "open="+path+" autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+s);
		//Ext.openImagePlus(input + File.separator + file);
	// Split channels and save in ".tif" file
		ImageTitle = getTitle();	
		filename = replace(ImageTitle, ".", "_");
		filename = replace(filename, "\\", "_");
		filename = replace(filename, "/", "_");
		filename = replace(filename, "-", "_");
		filename = replace(filename, " ", "_");
		filename = replace(filename, "__", "");
		filename = replace(filename, "___", "");
		rename(filename);
		getDimensions(width, height, channels, slices, frames);
			
		if (slices > 1 && Zpro !="None") {
			if (Zpro =="ZMAX"){
				run("Z Project...", "projection=[Max Intensity]");
				ID="MAX_";
				selectWindow(filename);
				close();
			}
			if (Zpro =="ZAVG"){
				run("Z Project...", "projection=[Average Intensity]");
				ID="AVG_";
				selectWindow(filename);
				close();
			}
			if (Zpro =="ZSTD"){
				run("Z Project...", "projection=[Standard Deviation]");
				ID="STD_";
				selectWindow(filename);
				close();
			}
		}else {
			ID="";
		}
		if (Flip) {
		run("Flip Vertically", "stack");
		}
		if (channels > 1 && Split) {
			run("Split Channels");
			for (j = 1; j <= channels; j++) {
				selectWindow("C" + j + "-" + ID + filename);
				// Save Results 
				saveAs("TIFF", output + File.separator + filename + "_c" + j + ".tif");
			}
		} else {
			saveAs("TIFF", output + File.separator + filename + ".tif");
		}
		run("Close All");
	}
}




