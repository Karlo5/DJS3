
  requires("1.34m");

//=======INICIALIZACION DE VARIABLES=====================================
//inicializacion de variables

  title = "Generacion de imagen de Kernel (PSF) con base 3 gaussianas";
  rutalib = "C:\\WormHole\\Fiji\\plugins\\DJS3\\EPID_DPI\\Lib";
  nameout = "kernel_zero.tif";
  PIXX = 1024;
  PIXY = 1024;
  scale = 0.4; //mm/pix
  m1 = 0.5; //cm-2
  k1 = 0.00001; //cm
  m2 = 0.1;
  k2 = 4.0;
  m3 = 0.002;
  k3 = 11.4;
  
//========================FIN DE INICIALIZACION VARIABLES ===========

//===============INTERFACE===USER data INPUT====================================
//inicio de la interface de recogida de datos NH, Calibracion, cortes y placas
  Dialog.create(title);
  Dialog.addMessage("Generador de imagenes de kernel");
  //DCMfile = File.openDialog("Archivo DCM a convertir en dosis");
  Dialog.addString("Output:", nameout);  
  Dialog.addNumber("Tamaño X:", PIXX);
  Dialog.addNumber("Tamaño Y:", PIXY);
  Dialog.addNumber("Escala (mm/pix):", scale);
  Dialog.addMessage("===================================");
  Dialog.addNumber("M1 (cm-2)", m1);
  Dialog.addNumber("k1(cm)", k1);
  Dialog.addNumber("M2 (cm-2)", m2);
  Dialog.addNumber("k2(cm)", k2);
  Dialog.addNumber("M3 (cm-2)", m3);
  Dialog.addNumber("k3(cm)", k3);
  nameout = Dialog.getString();
  PIXX = Dialog.getNumber();
  PIXY = Dialog.getNumber();
  scale = Dialog.getNumber();
  m1 = Dialog.getNumber();
  k1 = Dialog.getNumber();
  m2 = Dialog.getNumber();
  k2 = Dialog.getNumber();
  m3 = Dialog.getNumber();
  k3 = Dialog.getNumber();
  
  Dialog.show();

//====GENERACION DEL KERNEL DE CONVOLUCION DE LA DOSIS

	newImage("KerGaus.tif","32-bit white",PIXX,PIXY,1);
	saveAs("tiff",rutalib+"\\"+nameout);
	norm = 0;
	kern = 0;
	for(i=0;i<PIXX;i++){
		for(j=0;j<PIXY;j++){
	  		r2 = (i-PIXX/2)*(i-PIXX/2)+(j-PIXY/2)*(j-PIXY/2);
	  		kern = m1*exp(-r2/k1/k1);
	  		kern = kern +m2*exp(-r2/k2/k2);
	  		kern = kern +m3*exp(-r2/k3/k3);
	  		setPixel(i, j, kern);
	  		norm = norm + kern;
		}
	}			
	updateDisplay();
	saveAs("tiff",rutalib+"\\"+nameout);
	print("Kernel generado en "+rutalib+"\\"+nameout); 
	print("Normalizado: "+ norm);

