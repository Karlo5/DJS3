var slicez;
var windowname;
var tags;
var header;
var length; 
var tag;
var target;

//Tag del Dose Grid Scaling.
//Factor por el que se debe multiplicar la matriz de datos 
//Para dar la dosis en Gy
tag = "3004,000E";
exfactor = 1.0/25.0 ;
rutalib = getDirectory("plugins")+"\\DJS3\\DICOM_RTs\\Lib"; //C:\\WormHole\\Fiji\\plugins\\DJS3\\DICOM_RTs\\Lib";
print(rutalib);
defilter = "Default.conf";

Dialog.create("CONVOLUCIONADOR CORONALES FIJI");
Dialog.addString("Numero Historia", 0);
Dialog.show();

nh = Dialog.getString();

directorinput = "Z:\\"+nh;
arxius = getFileList(directorinput);
sortida = "convol";
raw="OMP"

File.makeDirectory("Z:\\"+nh+"\\"+sortida);
File.makeDirectory("Z:\\"+nh+"\\"+raw);
ak = -1;

for (k=0;k<arxius.length;k++){
	
	if((endsWith(arxius[k],".dcm"))&&(parseFloat(File.length(directorinput+"\\"+arxius[k]))>400000)){
		
		open(directorinput+"\\"+arxius[k]);
		ak++;
		header = getImageInfo();
		tags = split (header, "\n");
		length = lengthOf(tags);

		for (i=0;i<length;i++) {
			if(startsWith(tags[i], tag)){
				target = substring(tags[i], 16, 30);
			}
		}

	//Profundidad del plano de 10 cm
		slicez = 46;

	//Convierte Cortes axiales en coronales
		run("Reslice [/]...", "slice=1 start=Top avoid");
	//Separa el TAC ordenador coronal en imagenes sueltas, la 46 equivale a la profundidad de 10 cm
		run("Stack to Images");

		for (i=1; i<10; i++) {
			if (i!=slicez){
				windowname = "Reslice-000"+i;
				selectWindow(windowname);
				close();
			}
		}
		for (i=10; i<90; i++) {
			if (i!=slicez){
				windowname = "Reslice-00"+i;
				selectWindow(windowname);
				close();
			}
		}

		run("32-bit");
		run("Multiply...", "value="+target);
		run("Multiply...", "value="+exfactor);

		run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		setMinAndMax(0.0039, 0.3321);
		run("Flip Vertically");
	//equipara pixeles a mm
		run("Scale...", "x=2.5 y=2.5 width=502 height=317 interpolation=Bilinear create title=Cn");
		run("Canvas Size...", "width=512 height=512 position=Center zero");

		selectWindow("Reslice-00"+slicez);
		close();

		run("Text Image... ", "open=["+rutalib+"\\"+defilter+"]");
		selectWindow("Cn");
		run("FD Math...", "image1=Cn operation=Convolve image2="+defilter+" result=C"+k+".txt do");
		selectWindow(defilter);
		close();
		selectWindow("Cn");
		close();
		selectWindow("C"+k+".txt");
		saveAs("text image", "Z:\\"+nh+"\\convol\\C"+(ak+1)+".txt");
		selectImage(1+ak);
		close();
		temp = File.rename("Z:\\"+nh+"\\"+arxius[k], "Z:\\"+nh+"\\"+raw+"\\"+arxius[k]);		

	}

}

run("Close");



