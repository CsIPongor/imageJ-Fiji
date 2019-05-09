
////////////////////////////////////////////////////////////////////////////////
//This script is used to remove the first  and last N slice in a hyperstack.All/
//images are processed from the directory of the current active image.////////// 
//Extensions are stored in the "extensions" array (currently only tested for//// 
//ics, tiff files and nd2, however should work with bio-formats compatible//////
//multichannel files). Stack order should also be set. CAUTION: Filenames and //
//path chould not contain space (otherwise macro  might not function properly)//
////////////////////////////////////////////////////////////////////////////////


//Accepted extensions
extensions = newArray("tif", "tiff", "nd2", "ics");
//Stack order
stackOrder="XYCZT"
//Number of slices to be removed
firstN=1
lastN=1

//Get image properties
imageSourceID = getImageID;
name=getTitle;
directorySource = getDirectory("image");

//Reopen with bio-formats. Some images are not properly open by imageJ. This step
//is to make sure most images will pe processed properly
selectWindow(name);
run("Close");
run("Bio-Formats Importer", "open="+directorySource+name+" color_mode=Default view=Hyperstack stack_order="+stackOrder);

//Get Image properties
imageSourceID = getImageID;
name=getTitle;
Stack.getDimensions(widthSource, heightSource, channelsSource, slicesSource, framesSource);

//Create output directory
outputPath=directorySource+"\\Output";

//if (!File.exists(outputPath)) File.makeDirectory(outputPath);
		
//Generate ImageList with images that have an extension that is accepted
imageList = newArray(0);	
list = getFileList(directorySource);
imageString="";

//Close non image windows
close("\\Others"); 

//Get image list with accepted extensions
print("Processing the following directory: "+directorySource);
for (i = 0; i < list.length; i++) {
	
	filename=list[i];
	imageFlag=isImage(filename, extensions);
	if (imageFlag==true) {
		imageList= Array.concat(imageList,filename);
	}
}


//Process images
for (n = 0; n < imageList.length; n++) {
	
	print("Processing: "+imageList[n]);
	
	//Show progress in progressbar 
	showProgress(n, imageList.length);

	//Open Image to be processed
	path = directorySource+imageList[n];
	run("Bio-Formats Importer", "open="+path+" color_mode=Default view=Hyperstack stack_order="+stackOrder);
	selectWindow(imageList[n]);
	imageSourceID = getImageID;
	nameSource=getTitle;
			
	//Remove extension from namSource to put in the filename when saving
	nameSourceWithoutExtension=removeFileExtension(nameSource, extensions);

	
	//get Image Parameters
	Stack.getDimensions(widthSource, heightSource, channelsSource, slicesSource, framesSource);
	//Use duplicate to crop first and last slice
	if (Stack.isHyperstack==false){
		run("Duplicate...", "duplicate range="+1+firstN+"-"+slicesSource-lastN);
	 }
	else{
		run("Duplicate...", "duplicate slices="+1+firstN+"-"+slicesSource-lastN);
	}
	title =nameSourceWithoutExtension+"_crop";
	outputID = getImageID;
	rename(title);

	//Save and close cropped image
	saveImage(outputID,outputPath);
	run("Close");

	//Close original image
	selectImage(imageSourceID);
	run("Close");
}
print("Finished");

function isImage(filename, extensions) {
	//Checks if file has an extension in the list named "extensions" (lsit of extensions without point)
 	result = false;
 	for (i=0; i<extensions.length; i++) {
 	if (endsWith(toLowerCase(filename), "." + extensions[i]))
		result = true;
 	}
 	return result;
}



function saveImage(imageID,dir){
//Saves image with ID imageID to directory dir with filename containing the title. If  dir is not a directory but a filename 
//it removes the extension and saves to the source directory with the title appendded to the filename.
	selectImage(imageID);   
	title=getTitle;	
	path=dir+"\\"+title;
	saveAs("Tiff", path+".tif");
}




function removeFileExtension(filename, extensions) {
	for (i=0; i<extensions.length; i++) {
	if (endsWith(toLowerCase(filename), "." + extensions[i]))
    	nameSourceWithoutExtension=replace(nameSource, "."+extensions[i], ""); 
 	}
 	return nameSourceWithoutExtension;
}
