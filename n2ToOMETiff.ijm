/////////////////////////////////////////////////////////////////////////////////////////////////////
//This Macro converts nd2 files to the OME.Tiff. All nd2 files in the directory of the active image//
//are processed and saved in a new directory, with the same base name.///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////


extensions = newArray("nd2");//extensions that are accepted
stackOrder="XYCZT"

//Get parameters of the selected image
imageSourceID = getImageID;
name=getTitle;
directorySource = getDirectory("image");

//Get image properties
selectWindow(name);
Stack.getDimensions(widthSource, heightSource, channelsSource, slicesSource, framesSource);

//Close non image 
close("\\Others") 

//Create output directory
print("Analysis of images form: "+directorySource)
directoryOutput=directorySource+"\\output\\";
if (!File.exists(directoryOutput)) File.makeDirectory(directoryOutput);

		
//Generate ImageList
imageList = newArray(0);	
list = getFileList(directorySource);
for (i = 0; i < list.length; i++) {
	
	filename=list[i];
	imageFlag=isImage(filename, extensions);
	if (imageFlag==true) {
		imageList= Array.concat(imageList,filename);
	}
}

//Process Images
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
	//Save Image as ome
	run("Bio-Formats Exporter", "save=" + directoryOutput + nameSourceWithoutExtension + ".ome.tif export compression=Uncompressed");

	run("Close");

		

}
print("Finished");

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////Helper Functions////////////////////////////////////////
function isImage(filename, extensions) {
	//Function checks if file has an extension in the extensions list
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
	path=dir+title;
	saveAs("Tiff", path+".tif");
	}




function removeFileExtension(filename, extensions) {
	//Removes extension from file. Extensions are from array "extensions"
	for (i=0; i<extensions.length; i++) {
		if (endsWith(toLowerCase(filename), "." + extensions[i]))
    		nameSourceWithoutExtension=replace(nameSource, "."+extensions[i], ""); 
 	}
 	return nameSourceWithoutExtension;
	}