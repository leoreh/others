// 	the following was created for processing of virus histology (virus cabliration) images
// 	loads all images in a folder
// 	modifies contrast and brightness of channel 2 (transmitted light)
// 	modifies contrast and brightness of channel 1 (flourescence) only for x40 images
// 	changes color of channel 1 to red
// 	merges channels
// 	exports individual slices, stack image, and stack video (.avi)

// 	31 aug 19 LH. 	updates:
// 	30 jan 20 		auto B&C	
// 	04 apr 20		compatable w/ mdb and export each channel and merge


// 	do not open images, just process
setBatchMode(false)

// 	get files
dir = getDirectory("Choose a Directory");
list = getFileList(dir);
print("NO. FILES: " + list.length);
if (startsWith(getInfo("os.name"), "Windows"))
           dir = replace(dir, File.separator, "/");

for (i = 1; i < list.length; i++) {	
	// if(endsWith(list[i], ".oif")) { 						// images saved w/ Olympus IX81
	if(endsWith(list[i], ".lsm")) { 						// images saved w/ Meta (ZABAM)
		list[i] = replace(list[i], File.separator, "/");
		print("WORKING ON: " + dir + list[i]);
		open(dir + list[i]);	
		basename = substring(list[i], 0, lengthOf(list[i]) - 4);	
		
		// 	change trasmitted channel
		//Stack.setChannel(2);
		getMinAndMax(min, max);
		//setMinAndMax(-1500, 3700);						// manual brightness and contrast for all images
		//run("Enhance Contrast", "saturated=0.15"); 		// auto brightness and contrast
		if (matches(list[i], ".*x40.*")) {
			setMinAndMax(412, 412);							// manual brightness and contrast for x40 images
		}	

		//	change flourescence channel
		//Stack.setChannel(1);		
		getMinAndMax(min, max);
		//setMinAndMax(-30, 3227);
		//run("Enhance Contrast", "saturated=0.05"); 											
		if (matches(list[i], ".*x40.*")) {
			setMinAndMax(0, 2324);		
		}	
		//run("Red");			// LUT
		
		getDimensions(width, height, channels, slices, frames);
		print("No. channels: " + channels);
		print("No. z-frames: " + frames);
		
		//run("Merge Channels...", "c2="+list[i]+" c4="+list[1]+" keep");

		//	export slices to jpeg
		for (k = 1; k <= channels + 1; k++){
			Stack.setChannel(k)				
			for (j = 1; j <= frames; j++){			
				//	merge channels
				if (k == channels + 1) {				
					run("Make Composite");		
					name = dir + basename + "_mrg_" + "fr" + j;
				} else {
					name = dir + basename + "_ch_" + k + "fr" + j;
				}	
				Stack.setFrame(j);
				saveAs("jpeg", name);
			}
		}
		
		// 	for stacks only:
		if (frames > 2) {
			// 	export avi
			run("AVI... ", "compression=JPEG frame=5 save=["+dir+" "+list[i]+".avi]");
	
			//	export z stack
			run("Z Project...", "projection=[Max Intensity]");
			saveAs("jpeg", dir + list[i] + "_" + "z");
		}
	}
}

close("*");

// EOF