/*-----------------------------------------------------------------------------
Script to find and store individual microtubule images with molecular motor 
profile.

This script requires the plugin "Ridge Detection": 
(https://imagej.net/Ridge_Detection)  

Maurits Kok 2019
version 1.0

-----------------------------------------------------------------------------
 ToDo list
 - Enable single and multiple channel stacks to be analysed
 
-----------------------------------------------------------------------------
 USER INSTRUCTIONS AND SETTINGS
1) Load a dual channel image with:
	#1) Microtubule channel
	#2) Dynein channel
*/

// 2) Set the width and max length of the microtubule exported view (in pixels)
ExportWidth = 17;
ExportLength = 200;

// 3) Microtubule length to be taken as straight
L_thres = 20;

// 4) Microtubule length restrictions
L_min = 6;

// 5) Set width of the excluded border of the FOV
border = 15;

// 6) Set microtubule elongation length (in pixels)
dz = 12;

// 7) Set the exclusion boundary to evaluate overlapping microtubules
Boundary = 12;

// 8) Number of points at the microtubule end to be ignored (these are often poorly fitted)
skip = 3;

// 9) Debugging on/off
Debug = 0;

//-----------------------------------------------------------------------------

// Empty ROI manager
if(roiManager("Count")>0){
	roiManager("Deselect");
	roiManager("Delete");
}

// Get filename
FileName = getTitle();

// Select an output directory
dir = getDirectory("Choose a Save Directory");
SaveDir = dir + "Output" + File.separator;
File.makeDirectory(SaveDir);

// Create output subdirectories
SaveDir_Tif = SaveDir + "Microtubules" + File.separator;
File.makeDirectory(SaveDir_Tif);

//if (Debug == 1){
//	SaveDir_XY = SaveDir + "XY" + File.separator;
//	File.makeDirectory(SaveDir_XY);
//}

// Create duplicate stack of the microtubule channel that is 8-bit
run("Duplicate...", "title=MTs_8bit duplicate channels=1");
run("8-bit");
run("Grays");

// Run "Ridge Detection" plugin to locate the seed positions
setLineWidth(1);
run("Ridge Detection");

// Dimensions of the image stack
getDimensions(width, height, channels, slices, frames);

// Split the stack before processing
selectWindow("MTs_8bit");
close();
selectWindow(FileName);
	
// Split channel into "C1-Name" and "C2-Name"
run("Split Channels");
CH1 = "C1-" + FileName;
CH2 = "C2-" + FileName;

// Initialize slice counter
s_counter = -1;

// Delete junction points from ROI manager
del = newArray(0);
for (i=0; i < roiManager("count"); i++){
	roiManager("select", i);
	if (Roi.getType == "point"){
		del = Array.concat(del, i);
	}
}
if (del.length > 0){
	roiManager("select", del);
	roiManager("delete");	
}

// Find the indeces of all overlapping microtubules (for function, see below)
// If Debug = 1, then a stack of all overlapping microtubules will be generated
overlap = seedOverlap(slices, Boundary, Debug);

// Save binary file with overlaps if applicable
if(findImage("Overlaps.tif")){
	saveAs("Tiff", SaveDir + "/Overlaps.tif");
//	close();
}

// Array for all ignord microtubule traces
removed = newArray(0);

// Loop over all traced microtubules
for (i=0; i < roiManager("count"); i++) {

	selectWindow(CH1);
 	roiManager("select", i);
 	roiManager("Set Line Width", 1);
	
	// Microtubule name
	Seed = Roi.getName;

	// Get slice number
	Stack.getPosition(channel, slice, frame);
	if (slices < 2){
		slice = 0;
	}
	
 	// Obtain coordinates of the microtubule
    getSelectionCoordinates(x, y); 
    
    // Obtain properties of the microtubule coordinates
	Array.getStatistics(x, x_min, x_max, x_mean, x_std);
	Array.getStatistics(y, y_min, y_max, y_mean, y_std);

	// Find out whether current selection is an overlapping microtubule
	ignore = 0;
	for (k=0; k < overlap.length; k++){
		if (i == overlap[k]){
			ignore = 1;
		}
	}

	// Ignore faulty fits
	dx = abs(x[0] - x[x.length-1]);
	dy = abs(y[0] - y[y.length-1]); 
	if (dx == 0 || dy == 0){
		ignore = 1;
	}
	
	// Skip the following:
	// - microtubule too close to the border 
	// - microtubule too short
	// - microtubule that overlap [NOTE, this operation (currently) does not use the elongated microtubule coordinates]
	
	if(x_min>border && x_max<width-border && y_min>border && y_max<height-border && x.length> L_min && ignore == 0){

		// Coordinates of microtubule ends
		End_1 = Array.concat(x[skip], y[skip]);
		End_2 = Array.concat(x[x.length-skip-1], y[y.length-skip-1]);
	
		// If the length of the microtubule is shorter than L_thresh
		if(x.length <= 2*L_thres){
			
			// Fit the coordinates with a linear function (y=a+b*x)
			x_temp = selectionArray(skip, x.length-skip-1, x);
			y_temp = selectionArray(skip, y.length-skip-1, y);

			// Find line extensions
			x_1 = extendLine(dz, x_temp, y_temp, End_1, 1);
			y_1 = extendLine(dz, x_temp, y_temp, End_1, 2);		

			// Find line extensions
			x_2 = extendLine(dz, x_temp, y_temp, End_2, 1);
			y_2 = extendLine(dz, x_temp, y_temp, End_2, 2);
			x_2 = Array.reverse(x_2); y_2 = Array.reverse(y_2);
					
			// Ignore original located microtubule end points as they can be poorly fitted
			x = selectionArray(skip, x.length-skip-1, x);
			y = selectionArray(skip, y.length-skip-1, y);

			x_new = Array.concat(x_1, x); x_new = Array.concat(x_new, x_2);
			y_new = Array.concat(y_1, y); y_new = Array.concat(y_new, y_2);

			// Generate new line profile
			makeSelection("polyline", x_new, y_new);

			// Update the ROI selection with the new coodinates
			roiManager("update");
			
		// If the microtubule is long and therefore possibly not straight, 
		// only the end structures will be used for fitting
		} else if (x.length > 2*L_thres) {

			// Split the trace into two separate traces for fitting
			x_split_1 = selectionArray(skip, L_thres, x);
			y_split_1 = selectionArray(skip, L_thres, y);
			x_split_2 = selectionArray(x.length-L_thres, x.length-skip-1, x);
			y_split_2 = selectionArray(y.length-L_thres, y.length-skip-1, y);

			// Calculate position of the 1st extended line trace
			x_1 = extendLine(dz, x_split_1, y_split_1, End_1, 1);
			y_1 = extendLine(dz, x_split_1, y_split_1, End_1, 2);

			// Calculate position of the 2nd extended line trace
			x_2 = extendLine(dz, x_split_2, y_split_2, End_2, 1);
			y_2 = extendLine(dz, x_split_2, y_split_2, End_2, 2);
			x_2 = Array.reverse(x_2); y_2 = Array.reverse(y_2);

			// Ignore original located microtubule end points as they can be poorly fitted
			x = selectionArray(skip, x.length-skip-1, x);
			y = selectionArray(skip, y.length-skip-1, y);

			// Merge line trace with extensions
			x_new = Array.concat(x_1, x); x_new = Array.concat(x_new, x_2);
			y_new = Array.concat(y_1, y); y_new = Array.concat(y_new, y_2);			

			// Generate line profile
			makeSelection("polyline", x_new, y_new);

			// Update the ROI selection with the new coodinates
			roiManager("update");
		}

		// Remove corrupt long traces
		roiManager("select",i);
		getRawStatistics(nPixels);
		
		if (nPixels <= ExportLength){
	    	
			// Create single image of straightend microtubule with the new coordinates
			selectWindow(CH1);		
			Stack.setPosition(1, slice, frame);
			makeSelection("line", x_new, y_new);
			run("Straighten...", "line=ExportWidth");	
			CH1_zoom = getTitle();	
		
			// Create the dynein profile
			selectWindow(CH2);
			Stack.setPosition(1, slice, frame);
			makeSelection("line", x_new, y_new); 
			run("Straighten...", "line=ExportWidth");	
			CH2_zoom = getTitle();	
					
			// Save the images in two separate stacks
			if (findImage("Profiles_1.tif") == 0){
				selectWindow(CH1_zoom);
				rename("Profiles_1.tif");
			} else if(findImage("Profiles_1.tif") == 1){		
					run("Concatenate...", "title=Profiles_1.tif open image1=Profiles_1.tif image2="+CH1_zoom+" image3=[-- None --]");
			}
			if (findImage("Profiles_2.tif") == 0){
				selectWindow(CH2_zoom);
				rename("Profiles_2.tif");
			} else if(findImage("Profiles_2.tif") == 1){		
					run("Concatenate...", "title=Profiles_2.tif open image1=Profiles_2.tif image2="+CH2_zoom+" image3=[-- None --]");
			}
		} else {
			removed = Array.concat(removed, i);
		}

		
	} else {
		// Store the index of the ignored microtubule traces
		removed = Array.concat(removed, i);
	}
}

// Save the output stacks
if (findImage("Profiles_1.tif")==1) {	
	selectWindow("Profiles_1.tif");
	SaveName_Tif = SaveDir_Tif + "Microtubules";
	saveAs("Tiff", SaveName_Tif+".tif");
	close();
	selectWindow("Profiles_2.tif");
	SaveName_Tif = SaveDir_Tif + "Dynein";
	saveAs("Tiff", SaveName_Tif+".tif");
	close();
}

// After processing, merge the orginal files to obtain the initial setup
run("Merge Channels...", "c1="+CH1+" c2="+CH2+" create");

// Print all ignored microtubule traces from the ROI manager
if (Debug == 1) {
	for (j=0; j<removed.length; j++) {
		print(removed[j]);
	}
}

// Remove all ignored microtubule traces from the ROI manager
if (lengthOf(removed) > 0) {
	roiManager("select", removed);
	roiManager("delete");	
}

// Save the filenames in a separate text file 
print("\\Clear");
for (i=0; i<roiManager("count"); i++){
	roiManager("select", i);
	Seed = Roi.getName;
	Stack.getPosition(channel, slice, frame);
		
	// Create unique SaveName for XY-coordinate text file	
	if (slice < 10) {
//		SaveName_XY = SaveDir_XY + "F000" + slice + "_" +Seed; 	
		print("F000" + slice + "_" +Seed);
	} else if (slice < 100){
//		SaveName_XY = SaveDir_XY + "F00" + slice + "_" +Seed;
		print("F00" + slice + "_" +Seed);
	} else if(slice < 1000){
//		SaveName_XY = SaveDir_XY + "F0" + slice + "_" +Seed;  
		print("F0" + slice + "_" +Seed);
	}	else {
//		SaveName_XY = SaveDir_XY + "F" + slice + "_" +Seed;  
		print("F" + slice + "_" +Seed);
	}	
	
	// Save the coordinates for debugging
//	if (Debug == 1){   	
//		saveAs("XY Coordinates", SaveName_XY+".txt");
//   	}
}

// Save the seed information
selectWindow("Log");
SaveName_info = SaveDir + "Microtubules.txt";
saveAs("Text", SaveName_info); 
run("Close");

// Save the content in the ROI manager
roiManager("Deselect");
roiManager("Save", SaveDir + "RoiSet.zip");


///////////////  Set of additional functions  /////////////// 

// Function that selects a range of values in an array and returns the modified array
function selectionArray(pos1, pos2, array) {
	temparray=newArray(pos2 - pos1 + 1);
	for (i=0; i<lengthOf(temparray); i++) {
        temparray[i]=array[pos1 + i];
    }
	array=temparray;   
    return array;
}

// Function to find whether image exists
function findImage(string) {
	result = 0;
	list = getList("image.titles");
	for(i=0; i<list.length; i++){
		if(list[i] == string){
			result = 1;
		}
	} 
	return result;
}

// Function to return all unique values in an array
function ArrayUnique(array) {
	array 	= Array.sort(array);
	array 	= Array.concat(array, 999999);
	uniqueA = newArray();
	i = 0;	
   	while (i<(array.length)-1) {
		if (array[i] == array[(i)+1]) {
			//print("found: "+array[i]);			
		} else {
			uniqueA = Array.concat(uniqueA, array[i]);
		}
   		i++;
   	}
	return uniqueA;
}

// Function to find overlapping microtubules in each slice
function seedOverlap(slices, Boundary, Debug) {	
	
	// Initialize data arrays
	ind = newArray(1);
	pos = newArray(1);
	if (slices == 1){
		s = 0;
	} else{
		s = 1;
	}
	pos[0] = s;

	// Collect the index number and slice number for each selection in the ROI manager
	for (i=0; i < roiManager("count"); i++){
	roiManager("select",i);
	if (getSliceNumber() > s){
		ind = Array.concat(ind, i);
		pos = Array.concat(pos, getSliceNumber());		
		s = s + 1;
		}
	}	

	// Add the total size of the roiManager to the list
	ind = Array.concat(ind, roiManager("count"));
	
	// Create new stack for the overlapping microtubules
	if (Debug == 1){
		newImage("Overlaps", "8-bit black", 512, 512, pos.length);
	}
	// Create output array
	overlap = newArray(0);

	// loop over each slice
	for (i=0; i < pos.length; i++){ 
		
		// Find number of ROI's in manager
		ROI_start = roiManager("count");
		
		// Generate boundaries around the microtubules of width=Boundary 
		for(j=ind[i]; j < ind[i+1]; j++){
			roiManager("select", j);
			getSelectionCoordinates(x, y); 
			makeSelection( "polyline", x, y);
			Roi.setStrokeWidth(Boundary);
			run("Line to Area");
			roiManager("Add");	
		}
	
		// Find all overlapping microtubules
		for (m=ROI_start; m<roiManager('count'); m++){
	  		for (n=ROI_start; n<roiManager('count'); n++){
	   	 		roiManager('select',newArray(m,n));
	   			roiManager("AND");
	    		if ((m!=n)&&(selectionType>-1)) {
	    			out = ind[i]+m-ROI_start;
	      			overlap = Array.concat(overlap, out);	
	      			if (Debug == 1){
	      				roiManager("draw");
	      			}
	    		}
	  		}
		}
		
		// Delete the (temporarily) added ROI's
		del = newArray(0);
		for (j=ROI_start; j < roiManager("count"); j++){
			del = Array.concat(del, j);
		}
		if (lengthOf(del) >0){
			roiManager("select", del);
			roiManager("delete");
		}
	}

	// Create a unique list of all overlapping microtubules
	overlap = ArrayUnique(overlap);
	
	roiManager("deselect");
	run("Enhance Contrast", "saturated=0.35");
		
	return overlap;
}

// Function to calculate the extensions of the microtubule trace
function extendLine(dz, array_x, array_y, End, dim) {

	// Initialize output arrays
	x = newArray(0); y = newArray(0);
	
	// Make sure the microtubule trace is correctly oriented 
	dx = abs(array_x[0] - array_x[array_x.length-1]);
	dy = abs(array_y[0] - array_y[array_y.length-1]);
	
	// Correctly orient the microtubule position
	if (End[0] != array_x[0] && dx >= dy){
		array_x = Array.reverse(array_x);
		array_y = Array.reverse(array_y);
	} else if (End[1] != array_y[0] && dy > dx){
		array_x = Array.reverse(array_x);
		array_y = Array.reverse(array_y);
	}
	
	// Fit the coordinates with a linear function (y=a+b*x)
	Fit.doFit("Straight Line", array_x, array_y);
	
	// Retrieve fitting parameters
	a = Fit.p(0); b = Fit.p(1);
	
	// Calculate position of extended line position left
	angle = atan(b);
	
	for (j=1; j < dz+1; j++){
			if (dx >= dy){
				dd = abs(cos(angle)) * j;
				if (array_x[0] >= array_x[array_x.length -1]) {
					x = Array.concat(array_x[0] + dd, x);
					y = Array.concat(a+(b*x[0]), y);
				} else if (array_x[0] < array_x[array_x.length -1]) {
					x = Array.concat(array_x[0] - dd, x);
					y = Array.concat(a+(b*x[0]), y);
				}
			} else if (dy > dx) {
				dd = abs(sin(angle)) * j;
				if (array_y[0] >= array_y[array_y.length -1]) {
					y = Array.concat(array_y[0] + dd, y);
					x = Array.concat((y[0]-a)/b, x);
				} else if (array_y[0] < array_y[array_y.length -1]) {
					y = Array.concat(array_y[0] - dd, y);
					x = Array.concat((y[0]-a)/b, x);
				}			
			}
		}
	if (dim == 1) {
		return x;
	} else if (dim == 2){
		return y;
	}
}