// 	the following was created for processing of virus cabliration (histology) images
// 	loads all images in a folder
// 	modifies contrast and brightness of channel 2 (transmitted light)
// 	modifies contrast and brightness of channel 1 (flourescence) only for x40 images
// 	changes color of channel 1 to red
// 	merges channels
// 	exports individual slices, stack image, and stack video (.avi)

// 	31 aug 19 LH 


// 	do not open images, just process
setBatchMode(false)

// 	get files
dir = getDirectory("Choose a Directory");
list = getFileList(dir);
print("NO. FILES: " + list.length);
if (startsWith(getInfo("os.name"), "Windows"))
           dir = replace(dir, File.separator, "/");

for (i = 1; i < list.length; i++) {	
	if(endsWith(list[i], ".oif")) {
		list[i] = replace(list[i], File.separator, "/");
		print("WORKING ON: " + dir + list[i]);
		open(dir + list[i]);	
		
		
		// 	change trasmitted channel
		Stack.setChannel(2);
		setMinAndMax(0, 9572);			// brightness and contrast for all images
		if (matches(list[i], ".*x40.*")) {
			setMinAndMax(412, 412);			// brightness and contrast for x40 images
		}	

		//	changes flourescence channel
		Stack.setChannel(1);		
		setMinAndMax(0, 2324);			// brightness and contrast for all images		
		if (matches(list[i], ".*x40.*")) {
			setMinAndMax(0, 2324);		// brightness and contrast for x40 images
		}	
		run("Red");			// LUT to red


		//	merge channels
		if (matches(list[i], ".*x40.*")) {
		} else {			
			run("Make Composite");		// brightness and contrast for x40 images
		}	
				
		//run("Merge Channels...", "c2="+list[i]+" c4="+list[1]+" keep");

		//	export slices to jpeg
		for (j = 1; j <= nSlices; j = j + 2){
			setSlice(j);
			saveAs("jpeg", dir + list[i] + "_" + j);
		}

		// 	for stacks only:
		print(nSlices);
		if (nSlices > 2) {
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