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

requires("1.48a");
#@ boolean (label ="Split Channels", style="checkbox") Split
#@ String (choices={"None","ZMAX", "ZAVG", "ZSTD"}, style="listBox") Zpro
#@ boolean (label ="Flip vertically", style="checkbox") Flip

// Macro Initialization
run("Colors...", "foreground=white background=black selection=yellow");
call("java.lang.System.gc"); // java system garbage collector
run("Close All");

run("Bio-Formats Macro Extensions"); 
path = File.openDialog("Select a File");
Ext.setId(path); 
Ext.getSeriesCount(seriesCount); 
if (File.exists(path + File.separator + "Results") != 1) {
	rootPath = File.getParent(path);
	File.makeDirectory(rootPath + File.separator + "Results");
}

for (s=1; s<=seriesCount; s++) {
	// Bio-Formats Importer uses an argument that can be built by concatenate a set of strings
	run("Bio-Formats Importer", "open=&path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+s);

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
			ID="MAX";
			selectWindow(filename);
			close();
		}
		if (Zpro =="ZAVG"){
			run("Z Project...", "projection=[Average Intensity]");
			ID="AVG";
			selectWindow(filename);
			close();
		}
		if (Zpro =="ZSTD"){
			run("Z Project...", "projection=[Standard Deviation]");
			ID="STD";
			selectWindow(filename);
			close();
		}
	}else {
		Zpro="";
	}
	if (Flip) {
		run("Flip Vertically", "stack");
	}
	if (channels > 1 && Split) {
		run("Split Channels");
		for (j = 1; j <= channels; j++) {
			selectWindow("C" + j + "-" + ID + "_" + filename);
			// Save Results 
			saveAs("TIFF", rootPath + File.separator + "Results" + File.separator + filename + "_c" + j + ".tif");
		}
	} else {
		saveAs("TIFF", rootPath + File.separator + "Results" + File.separator + filename + ".tif");
	}


	run("Close All");
	call("java.lang.System.gc"); // java system garbage collector
}

Ext.close();
showMessage("Program finished");
