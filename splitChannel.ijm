/////////////////////////////////////////////////////////////////////////////////////////////////////
//This Macro splits channels and saves them. All images are processed from the directory of the///// 
//current active image. Extensions are stored in the "extensions" array (currently only tested for// 
//ics and tiff files, however should work with bio-formats compatible multichannel files). Stack//// 
//order should also be set. CAUTION: Filenames and path chould not contain space (otherwise macro/// 
//might not function properly)//////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

//Input parameters
extensions = newArray("tif", "tiff", "ics");
stackOrder="XYCZT"

//Get parameters of the selected image
imageSourceID = getImageID;
name=getTitle;
directorySource = getDirectory("image");

//Reopen with bio-formats. Some images are not properly open by imageJ. This step
//is to make sure most images will pe processed properly
selectWindow(name);
run("Close");

run("Bio-Formats Importer", "open="+directorySource+name+" color_mode=Default view=Hyperstack stack_order="+stackOrder);
imageSourceID = getImageID;

//Get image properties
Stack.getDimensions(widthSource, heightSource, channelsSource, slicesSource, framesSource);

//Close non image 
close("\\Others") 

//Create output directory
print("Analysis of images form: "+directorySource)
for (i = 1; i <= channelsSource; i++) {
		//Create output directories
		path=directorySource+"\\"+i+"\\";
		if (!File.exists(path)) File.makeDirectory(path);
		}
		
//Generate ImageList
imageList = newArray(0);	
list = getFileList(directorySource);
imageString="";

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
	//open(path); //open using imageJ
	
	selectWindow(imageList[n]);
	imageSourceID = getImageID;
	nameSource=getTitle;
			
	//Remove extension from namSource to put in the filename when saving
	nameSourceWithoutExtension=removeFileExtension(nameSource, extensions);
	//Create destination image and get ID
	  

	//get Image Parameters
	Stack.getDimensions(widthSource, heightSource, channelsSource, slicesSource, framesSource);
	getPixelSize(unitSource, pixelWidthSource, pixelHeightSource);

	//Split channels
	for (i = 1; i <= channelsSource; i++) {
		channelID=fetchChannels(imageSourceID, i, 1);
		//selectImage(channelID);
		path=directorySource+"\\"+i+"\\";
		title =nameSourceWithoutExtension+"_channel_"+d2s(i,0);
		selectImage(channelID);
		rename(title);
		saveImage(channelID,path);
		selectImage(channelID);
		run("Close");
		}
		

}
print("Finished")

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


function fetchChannels(imageSourceID, choice_ch, timeframe) {
 	//Function fetches channel choice_ch at timeframe t from  image with the sourceid imageSourceID. It copies all slices
 	//into destination image and returns with it`s ID imageDestid).

 
		selectImage(imageSourceID);
		
		//Get image type and filename
		//If in verbose mode gets directory so it can save destination image
		//This way we spare one select image step that waste more resources..
		Stack.getDimensions(width, height, channels, slices, frames);
		type = bitDepth;
		nameSource=getTitle; 

		//Create destination image and get ID
		title =nameSource+"_channel_"+d2s(choice_ch,0);    	
      	newImage(title, type, width, height, slices*frames);
        imageDestID = getImageID;
        
		for (z=1; z<=slices; z++) {

    		selectImage(imageSourceID);
        	Stack.setPosition(choice_ch,z,timeframe);
        	run("Copy");
        	selectImage(imageDestID);
        	Stack.setPosition(choice_ch,z,timeframe)
       		run("Paste");
        	}
        selectImage(imageDestID);
        return imageDestID;
 	}

function removeFileExtension(filename, extensions) {
	//Removes extension from file. Extensions are from array "extensions"
	for (i=0; i<extensions.length; i++) {
		if (endsWith(toLowerCase(filename), "." + extensions[i]))
    		nameSourceWithoutExtension=replace(nameSource, "."+extensions[i], ""); 
 	}
 	return nameSourceWithoutExtension;
	}