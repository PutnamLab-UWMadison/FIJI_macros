// FIJI Macro: 4-Channel Chromatic Aberration Correction

// 1. User selects ROI
setTool("rectangle");
waitForUser("Selection Required", "Draw a box around a punctate object or cell border, then click OK.");

if (selectionType() == -1) exit("No ROI detected.");

origID = getImageID();
getDimensions(origW, origH, channels, slices, frames);
if (channels < 4) exit("This macro requires at least 4 channels.");
getSelectionBounds(roiX, roiY, roiW, roiH);

// --- Store Original Scale ---
getVoxelSize(vW, vH, vD, unit); 
run("Set Scale...", "distance=0 known=0 unit=pixel");

run("Set Measurements...", "center redirect=None decimal=3");
setBatchMode(true);

// --- Process Reference (Channel 1) ---
selectImage(origID);
run("Duplicate...", "title=Ref_Temp duplicate channels=1");
run("Gaussian Blur...", "sigma=1");
setAutoThreshold("Otsu dark"); 
run("Convert to Mask");
makeRectangle(roiX, roiY, roiW, roiH)
run("Measure");
refX = getResult("XM", nResults-1);
refY = getResult("YM", nResults-1);
close("Ref_Temp");

// --- Process Target 1 (Channel 2) ---
selectImage(origID);
run("Duplicate...", "title=T1_Temp duplicate channels=2");
run("Gaussian Blur...", "sigma=1");
setAutoThreshold("Otsu dark");
run("Convert to Mask");
makeRectangle(roiX, roiY, roiW, roiH)
run("Measure");
tar2X = getResult("XM", nResults-1);
tar2Y = getResult("YM", nResults-1);
close("T1_Temp");

// --- Process Target 2 (Channel 3) ---
selectImage(origID);
run("Duplicate...", "title=T2_Temp duplicate channels=3");
run("Gaussian Blur...", "sigma=1");
setAutoThreshold("Otsu dark");
run("Convert to Mask");
makeRectangle(roiX, roiY, roiW, roiH)
run("Measure");
tar3X = getResult("XM", nResults-1);
tar3Y = getResult("YM", nResults-1);
close("T2_Temp");

// --- Process Target 3 (Channel 4) ---
selectImage(origID);
run("Duplicate...", "title=T3_Temp duplicate channels=4");
run("Gaussian Blur...", "sigma=1");
setAutoThreshold("Otsu dark");
run("Convert to Mask");
makeRectangle(roiX, roiY, roiW, roiH)
run("Measure");
tar4X = getResult("XM", nResults-1);
tar4Y = getResult("YM", nResults-1);
close("T3_Temp");

// --- Calculate Integer Offsets ---
dx2 = Math.round(refX - tar2X);
dy2 = Math.round(refY - tar2Y);
dx3 = Math.round(refX - tar3X);
dy3 = Math.round(refY - tar3Y);
dx4 = Math.round(refX - tar4X);
dy4 = Math.round(refY - tar4Y);

// --- Apply Correction ---
selectImage(origID);
run("Select None");

// Duplicate and Translate channels
run("Duplicate...", "title=Corrected_C1 duplicate channels=1");

selectImage(origID);
run("Duplicate...", "title=Corrected_C2 duplicate channels=2");
run("Translate...", "x=" + dx2 + " y=" + dy2 + " interpolation=None stack");

selectImage(origID);
run("Duplicate...", "title=Corrected_C3 duplicate channels=3");
run("Translate...", "x=" + dx3 + " y=" + dy3 + " interpolation=None stack");

selectImage(origID);
run("Duplicate...", "title=Corrected_C4 duplicate channels=4");
run("Translate...", "x=" + dx4 + " y=" + dy4 + " interpolation=None stack");

// Merge the four corrected channels
run("Merge Channels...", "c1=Corrected_C1 c2=Corrected_C2 c3=Corrected_C3 c4=Corrected_C4 create");
rename("Aligned_4Ch_Composite");

// --- Advanced Auto-Crop ---
// Find the absolute maximum shift across all channels to prevent black borders
maxDx = Math.max(abs(dx2), Math.max(abs(dx3), abs(dx4)));
maxDy = Math.max(abs(dy2), Math.max(abs(dy3), abs(dy4)));

newW = origW - (2 * maxDx);
newH = origH - (2 * maxDy);

if (newW > 0 && newH > 0) {
    makeRectangle(maxDx, maxDy, newW, newH);
    run("Crop");
}

run("Select None");
run("Set Scale...", "distance=1 known=" + vW + " unit=" + unit);
setBatchMode(false);

print("C2 Shift: " + dx2 + "," + dy2);
print("C3 Shift: " + dx3 + "," + dy3);
print("C4 Shift: " + dx4 + "," + dy4);