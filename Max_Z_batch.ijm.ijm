// Runs Max Z projection on folder of Z stacks

// Build the input dialog
Dialog.create("Batch Max Z projection");
Dialog.addDirectory("Image folder", "");
Dialog.addString("File suffix to segment:", "");
Dialog.show();

// Retrieve values
imageFolder = Dialog.getString();
pullSuffix = Dialog.getString();

// Ensure trailing separator
if (!endsWith(imageFolder, "/") && !endsWith(imageFolder, "\\"))
    imageFolder = imageFolder + "/";

// Debug: confirm what we got
print("Image folder: [" + imageFolder + "]");
print("Suffix: [" + pullSuffix + "]");

// Get list of files
fileList = getFileList(imageFolder);
print("Files found: " + fileList.length);

// Looping through file list
for (i = 0; i < fileList.length; i++) {
    filename = fileList[i];

    if (endsWith(filename, pullSuffix + ".tif") || endsWith(filename, pullSuffix + ".tiff")) {
        print("Processing: " + filename);
	// open file
	open(imageFolder + filename);
	print("opening " + imageFolder + filename);
        // run("Bio-Formats Importer", "open=[" + imageFolder + filename + "] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
    // get info for log window
        getDimensions(width, height, channels, slices, frames);
	print(filename + " -> W:" + width + " H:" + height + " C:" + channels + " Z:" + slices + " T:" + frames);
	originalTitle = getTitle();
    
    // Run max intensity
	run("Z Project...", "projection=[Max Intensity]");
	
	if (endsWith(filename, ".tiff"))
            outputName = replace(filename, ".tiff", "_MaxZ.tiff");
        else
            outputName = replace(filename, ".tif", "_MaxZ.tif");
    
    saveAs("Tiff", imageFolder + outputName);
    print("Saved to: " + outputName);
    close();
    close();
    }
}
print("Batch watershed complete!");