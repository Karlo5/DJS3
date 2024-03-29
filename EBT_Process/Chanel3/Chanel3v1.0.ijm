
  requires("1.34m");

//=======INICIALIZACION DE VARIABLES==CHECKSUM=====================================
//inicializacion de variables
  title = "Conversion a Dosis EBT3 Multicanal";
  nh="999999"; 
  lot="CN";
  rutacal = getDirectory("plugins")+"\\DJS3\\EBT_Process\\Lib\\EBT_Mch\\";
  rutapac = "Z:\\";		

//variables de escala para 72 dpi
  amplada = "334";
  alsada = "227";

//valores de recorte de la imagen, centrado en la placa
  margex = 480;
  margey = 320;
  origenx = 68;
  origeny = 170;
  chksum = amplada + alsada + margex + margey+ origenx+ origeny;
 
//valores por defecto para cuando se fuerza el ajuste geométrico

	alfadef = -90;
	p1ydef = 142;
	p2xdef = 513;
 
//valores para buscar los puntos para rotar la placa
  p1idef1 = 880;
  p1jdef1 = 115;
  p2idef1 = 945;
  p2jdef1 = 314;
  p3idef1 = 880;
  p3jdef1 = 641;
  costatdef1 = 25;
  chksum = p1idef1 + p1jdef1 + p2idef1 + p2jdef1 + p3idef1 + p3jdef1 + costatdef1 + chksum;

//valores para buscar los puntos para posicionar el origen

  p1idef2 = 275;
  p1jdef2 = 130;
  p2idef2 = 473;
  p2jdef2 = 67;
  p3idef2 = 799;
  p3jdef2 = 136;
  costatdef2 =25;
  chksum = p1idef2 + p1jdef2 + p2idef2 + p2jdef2 + p3idef2 + p3jdef2 + costatdef2 + chksum;


//valores del fondo por sectores para evaluar su constancia
//1 pl�stico, 2 placa, 3 fondo desnudo del escaner

  vmitjana1 = 65502;
  vmitjana2 = 45000;
  vmitjana3 = 61555.2;
  vdesv1 = 100;
  vdesv2 = 3000;
  vdesv3 = 380;

//Verificacion CHeckSum de constantes
  chksum = chksum + vmitjana1 + vmitjana2 +2000 + vmitjana3 + vdesv1 + vdesv2 + vdesv3;
  print (d2s(chksum,10));
  if (chksum == 3.3424542802E9) {print ("chksum OK");}
  else{ print("chksum error");Dialog.create("Error CHKSUM");
Dialog.addMessage("Error CHKSUM: "+ chksum);
Dialog.show();}

//Valors de margenes de la placa para calibrar en dosis

  topx = 30;
  topy = 15;
  botomx = 300;
  botomy = 215;

//Nombre de los modelos utilizados;

smodel = newArray(2);
smodel[0] = "Pesos predefinidos";
smodel[1] = "Pesos correlacionados";

defmodel = smodel[0];

// Si geom = 1 se aplicara el procesado geometrico si geom != 1 no

geom = 1;

// Si veri = 1 se comprueba la constancia del escaner

veri = 1;

//Denegar siembre correccion por uniformidad, cunif = 0

cunif = 0;

 
//========================FIN DE INICIALIZACION VARIABLES, FIN CHECKSUM===========

//===============INTERFACE===USER data INPUT====================================
//inicio de la interface de recogida de datos NH, Calibracion, cortes y placas
  Dialog.create(title);
  Dialog.addMessage("Macro la conversion a dosis de EBT2 multicanal");
  Dialog.addString("NH:", nh);  
  Dialog.addString("Lote:", lot);
  Dialog.addCheckbox("Interrumpir ante errores de fondo", false);
  Dialog.addCheckbox("Limpiar marcas de posicionamiento", true);
  Dialog.addCheckbox("Forzar busqueda geométrica", false);
  Dialog.addChoice("Ponderacion Canales:", smodel, defmodel);
  Dialog.addCheckbox("placa1", true);
  Dialog.addString("placa:", "1" );
  Dialog.addString("Y :","1");
  Dialog.addCheckbox("placa2", false);
  Dialog.addString("placa:", "2" );
  Dialog.addString("Y :","2");
  Dialog.addCheckbox("placa3", false);
  Dialog.addString("placa:", "3" );
  Dialog.addString("Y :","3");
  
  Dialog.show();
  nh = Dialog.getString();
  lot = Dialog.getString();
  stoper = Dialog.getCheckbox();
  puntnet = Dialog.getCheckbox();
  geotop = Dialog.getCheckbox();
  selmodel = Dialog.getChoice();

  if(selmodel == smodel[0]){
	Model = 1;
  } else {
  	if(selmodel == smodel[1]){
		Model = 2;
  	} else {
   	print(" Aplicado modelo por defecto "+defmodel);
   	Model = 1;
  	}
  }

//CARGA DE LOS PARAMETROS DE AJUSTE DE LA CALIBRACION
//archivo de calibraci�n real

  dadescalibracio = split(File.openAsString(rutacal+"cal3ch"+lot+".txt"), "\n");
  calpamred = split(dadescalibracio[0],"	");
  calpamgreen = split(dadescalibracio[1],"	");
  calpamblue = split(dadescalibracio[2],"	");
  
  Ar = calpamred[0];
  Br = calpamred[1];
  Cr = calpamred[2];
  Wr = calpamred[3];
  Ag = calpamgreen[0];
  Bg = calpamgreen[1];
  Cg = calpamgreen[2];
  Wg =calpamgreen[3];
  Ab = calpamblue[0];
  Bb = calpamblue[1];
  Cb = calpamblue[2];
  Wb = calpamblue[3];
 
 //desocultar para habilitar log de control del input de calibraci�n
 //print("ROJO: A="+Ar+",  B="+Br+",  C="+Cr+",  W="+Wr+" ");
 //print("VERDE: A="+Ag+", B="+Bg+",  C="+Cg+", W="+Wg+" ");
 //print("BLUE: A="+Ab+", B="+Bb+",  C="+Cb+",  W="+Wb+" ");


//FLUJO DEL PROGRAMA PRINCIPAL

//Se crean los directorios de Sum -Summary- (resumen) : destinado a ser guardado es la media de las imagenes iniciales 
//y por lo tanto contiene toda la informacion relevante de las placas escaneadas -puede servir como unico registro de las
//medidas en placa si se guarda correctamente
//Rest (Resto) : Resultados intermedios borrables. Se puede eliminar en cualquier momento sin mas problema
//Raw (bruto) : Imagenes originales sin procesar, se debe guardar por comodidad si se quiere relanzar el procesado desde el inicio

//Cuando se almacenen los pacientes en se deben borrar los directorios Rest y Raw para simplificar y guardar todo lo dem�s

	File.makeDirectory(rutapac+nh+"_FILM\\Sum");
	File.makeDirectory(rutapac+nh+"_FILM\\Rest");
	File.makeDirectory(rutapac+nh+"_FILM\\Raw");


for (Mk = 0; Mk <= 2; Mk++) {

print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> placa "+Mk+1);
//<<<<
//===========abrir fondos y placas irradiadas, realizar la media de cuatro placas
//===========extraer los tres canales canales de las medias
//===========substraccion del fondo a las placas irradiadas y division por el fondo
//<<<<

///========PROCESADO INICIAL: MEDIA, SEPARACION POR COLORES, SUBSTRACCION DEL FONDO=========

 
//anemi, variable de stop segun stoper

anemi = Dialog.getCheckbox();
if (anemi==true){
  
	placa = Dialog.getString();
  	yaxis = Dialog.getString();
  
//media de las placas irradiadas

	open(rutapac+nh+"_FILM\\y"+yaxis+"A.tif");
	open(rutapac+nh+"_FILM\\y"+yaxis+"B.tif");
	open(rutapac+nh+"_FILM\\y"+yaxis+"C.tif");
	open(rutapac+nh+"_FILM\\y"+yaxis+"D.tif");

//Analizador de distribucion de dosis inicial para decidir si se corrige por uniformidad o no
//Si la placa presenta mayor nivel de dosis en los margenes que en el centro se aplicara
//una sobre correccion de uniformidad, si no la division y resta por el fondo se considerara
//suficiente. Se utiliza la placa "a" para la deficios la media por sectores. (EN LA ACTUALIDAD NO SE USA)

	selectWindow("y"+yaxis+"A.tif");
	makeRectangle(390, 340, 430, 280);
	getStatistics(n, mean, min, max, std, histogram);
	centrecu = mean;
	makeRectangle(400, 620, 430, 160);
	getStatistics(n, mean, min, max, std, histogram);
	costat1cu = mean;
	makeRectangle(390, 150, 430, 160);
	getStatistics(n, mean, min, max, std, histogram);
	costat2cu = mean;
	if(costat1cu > costat2cu){
	costatcu = costat2cu;
	}else{
	costatcu = costat1cu;
	}	

	if(cunif == 1){
		if( costatcu/centrecu < 1){
			cuni = 1;
		}else{
			cuni = 0;
		}
	}else{
	cuni = 0;
	}

	run("Select None");

//======================================
//Media de las placas irradiadas

	imageCalculator("Average create stack", "y"+yaxis+"A.tif","y"+yaxis+"B.tif");
	imageCalculator("Average create stack", "y"+yaxis+"C.tif","y"+yaxis+"D.tif");
	imageCalculator("Average create stack", "Result of y"+yaxis+"A.tif","Result of y"+yaxis+"C.tif");
	selectWindow("Result of y"+yaxis+"C.tif");
	close();
	selectWindow("Result of y"+yaxis+"A.tif");
	close();
	selectWindow("y"+yaxis+"D.tif");
	close();
	selectWindow("y"+yaxis+"C.tif");
	close();
	selectWindow("y"+yaxis+"B.tif");
	close();
	selectWindow("y"+yaxis+"A.tif");
	close();
	selectWindow("Result of Result of y"+yaxis+"A.tif");
	saveAs("Tiff", rutapac+nh+"_FILM\\Sum\\y"+yaxis+"m.tif");

//CU Placa irradiada (NO)
	
	if (cuni ==1 ){
		cuniform("Irradiada");
	}
	


//multi-canal r g b placas irradiadas

	run("Split Channels");
	selectWindow("C1-y"+yaxis+"m.tif");
	saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"r.tif");
	selectWindow("C2-y"+yaxis+"m.tif");
	saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"g.tif");
	selectWindow("C3-y"+yaxis+"m.tif");
	saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"b.tif");



//media de los fondos

	open(rutapac+nh+"_FILM\\F"+placa+"A.tif");
	open(rutapac+nh+"_FILM\\F"+placa+"B.tif");
	open(rutapac+nh+"_FILM\\F"+placa+"C.tif");
	open(rutapac+nh+"_FILM\\F"+placa+"D.tif");
	imageCalculator("Average create stack", "F"+placa+"A.tif","F"+placa+"B.tif");
	imageCalculator("Average create stack", "F"+placa+"C.tif","F"+placa+"D.tif");
	imageCalculator("Average create stack", "Result of F"+placa+"A.tif","Result of F"+placa+"C.tif");

	selectWindow("Result of F"+placa+"C.tif");
	close();
	selectWindow("Result of F"+placa+"A.tif");
	close();
	selectWindow("F"+placa+"D.tif");
	close();
	selectWindow("F"+placa+"C.tif");
	close();
	selectWindow("F"+placa+"B.tif");
	close();
	selectWindow("F"+placa+"A.tif");
	close();
	selectWindow("Result of Result of F"+placa+"A.tif");
	saveAs("Tiff", rutapac+nh+"_FILM\\Sum\\F"+placa+"m.tif");

//CU fondo de la placa
 
	if (cuni ==1 ){
		cuniform("Fondo");
	}


//multi-canal r g b del fondo

	run("Split Channels");

	//rojo	
	selectWindow("C1-F"+placa+"m.tif");
	saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\f"+placa+"r.tif");
	//verde
	selectWindow("C2-F"+placa+"m.tif");
	saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\f"+placa+"g.tif");
	//azul
	selectWindow("C3-F"+placa+"m.tif");
	saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\f"+placa+"b.tif");
	selectWindow("f"+placa+"r.tif");

// <<<Verificacion constancia escaneo canal rojo
	//PARENTESIS DE VERIFICACION DE CONSTANCIA
if (veri == 1){
		makeRectangle(49, 366, 155, 152);
		getStatistics(n, mean, min, max, std, histogram);
		if ((mean < vmitjana1+vdesv1) && (mean > vmitjana1-vdesv1)) { 
			print("sector 1 escaner constante OK");}
		else { if(stoper == true){
			Dialog.create("Error sector1");
			Dialog.addMessage("Error en el fondo de cristal");
			Dialog.show();}}
		makeRectangle(529, 418, 161, 156);
		getStatistics(n, mean, min, max, std, histogram);
		if ((mean < vmitjana2+vdesv2) && (mean > vmitjana2-vdesv2)) { 
			print("sector 2 escaner constante OK");}
		else { if(stoper == true){ 
			Dialog.create("Error sector2");
			Dialog.addMessage("Error en el fondo de placa");
			Dialog.show();}}
		makeRectangle(972, 442, 138, 127);
		getStatistics(n, mean, min, max, std, histogram);
		if ((mean < vmitjana3+vdesv3) && (mean > vmitjana3-vdesv3)) { 
			print("sector 3 escaner constante OK");}
		else { if(stoper == true){
			Dialog.create("Error sector3");
			Dialog.addMessage("Error en el fondo de plastico");
			Dialog.show();}}

	run("Select None");
	//FIN DE PARENTESIS
}
//====fondo menos imagen dividido por fondo canal por canal

//variable de color

	quark = newArray("r","g","b");	

for ( k = 0 ; k <=2; k++){

	imageCalculator("Substract create", "f"+placa+quark[k]+".tif","y"+yaxis+quark[k]+".tif");
	imageCalculator("Divide create 32-bit", "Result of f"+placa+quark[k]+".tif","f"+placa+quark[k]+".tif");
	selectWindow("y"+yaxis+quark[k]+".tif");
	close();
	selectWindow("f"+placa+quark[k]+".tif");
	close();
	selectWindow("Result of Result of f"+placa+quark[k]+".tif");	
	saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"f"+quark[k]+".tif");
	selectWindow("Result of f"+placa+quark[k]+".tif");
	close();	
}

//========FIN PROCESADO INICIAL PLACAS

//========PROCESADO GEOMETRICO DE LAS PLACAS


if(geom == 1){

	for(k=0;k<=2;k++){

	//=========>>>>>>>>>situacion del origen de la placa y recorte de la imagen alrededor de la misma
	//==================>>>>>>  (el programa situa el origen de la imagen en el centro de la misma, por lo que el origen se situa recortando un margen simetrico
	//  a partir del mismo)
	//===============reescalado de la placa
	//===============rotacion de la placa
		
		selectWindow("y"+yaxis+"f"+quark[k]+".tif");
	
	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>ROTACION (Se coje el canal rojo como referencia)
		
		if(k==0){
	
			pn = newArray(2);
			
			pn = minimum (p1idef1, p1jdef1, costatdef1);
			p1x = pn[0];
			p1y = pn[1];

			pn = minimum (p2idef1, p2jdef1, costatdef1);
			p2x = pn[0];
			p2y = pn[1];

			pn = minimum (p3idef1, p3jdef1, costatdef1);
			p3x = pn[0];
			p3y = pn[1];

			tanval = (p3x-p1x)/(p3y-p1y);
			alfa = atan(tanval)*360/2/3.1415926535-90.0;
		}		

		if(geotop) alfa = alfadef;

		run("Rotate... ", "angle=alfa grid=1 interpolation=Bilinear");

		
	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ORIGEN, Referencia canal rojo
	
		if(k==0){
		
			pn = minimum (p1idef2, p1jdef2, costatdef2);
			p1x = pn[0];
			p1y = pn[1];

			pn = minimum (p2idef2, p2jdef2, costatdef2);
			p2x = pn[0];
			p2y = pn[1];

			pn = minimum (p3idef2, p3jdef2, costatdef2);
			p3x = pn[0];
			p3y = pn[1];
    
			if(geotop){
				p2x = p2xdef;
				p1y = p1ydef;
			}
    
			p0x = origenx + p2x;
			p0y = origeny + p1y;
			print("placa rotada ", alfa, " grados :: origen de la placa ", p0x,p0y);
			makePoint(p2x,p2y);
		}
		
	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>RECORTE
	
		makeRectangle(p0x-margex, p0y-margey, 2*margex, 2*margey);
		run("Copy");
		run("Internal Clipboard");
		saveAs("Tiff", "temp.tif");

	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ESCALADO y LIMPIEZA

		configuracio = "x=- y=- width="+amplada+" height="+alsada+" interpolation=Bicubic create title=temp.tif";
		run("Scale...", configuracio);
		//Limpieza
		if(puntnet){
			run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
		}
		saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"f"+quark[k]+"g.tif");
		selectWindow("temp.tif");
		close();
		selectWindow("y"+yaxis+"f"+quark[k]+".tif");
		close();
	}

} else {
	
	for(k=0;k<=2;k++){
		
		selectWindow("y"+yaxis+"f"+quark[k]+".tif");
		saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"f"+quark[k]+"g.tif");

	}
}
	///////==========FIN PROCESADO GEOMETRICO PLACAS====================================================


/////================================================================================================

/////============================CALIBRACION=========================================================

//calibracion de la placa segun lote

	for(k=0;k<=2;k++){
		
		if (k==0){
		Ax = parseFloat(Ar);
		Bx = parseFloat(Br);
		Cx = parseFloat(Cr);
		} else if (k == 1) {
		Ax = parseFloat(Ag);
		Bx = parseFloat(Bg);
		Cx =parseFloat(Cg);
		} else if ( k == 2) {
		Ax = parseFloat(Ab);
		Bx = parseFloat(Bb);
		Cx =parseFloat(Cb);
		} else {
		print("fallo calibracion, pasado de canal");
		}		
		
		selectWindow("y"+yaxis+"f"+quark[k]+"g.tif");
		saveAs("Tiff", "temp.tif");
		run("Multiply...", "value="+Cx);
		run("Subtract...", "value="+Ax);
		open(rutapac+nh+"_FILM\\Rest\\y"+yaxis+"f"+quark[k]+"g.tif");
		run("Conversions...", " ");
		run("32-bit");		
		run("Subtract...", "value="+Bx);
		run("Abs");
		imageCalculator("Divide create 32-bit", "temp.tif", "y"+yaxis+"f"+quark[k]+"g.tif");
		selectWindow("Result of temp.tif");
		//resolucion en decimales, conversion a 0.1 mGy
		run("Multiply...", "value=10000");
		run("16-bit");
		saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"f"+quark[k]+"gd.tif");
		selectWindow("temp.tif");
		close();
		selectWindow("y"+yaxis+"f"+quark[k]+"g.tif");
		close();
		
	}

//Suma de las dosis por canales, media ponderada segun peso del canal	

//==================Modelo de ponderacion
// Model = 1 ; Captura de los pesos segun archivo de calibracion
// Model = 2 ; Estimacion de los pesos por coherencia entre canales

		if (Model == 1){

		Wtot = parseFloat(Wr) + parseFloat(Wg) + parseFloat(Wb) ;
		fracr = parseFloat(Wr) / Wtot * 100.0 ;
		fracg =parseFloat(Wg) / Wtot * 100.0 ;
		fracb =parseFloat(Wb) / Wtot * 100.0 ;
		print("pesos por canales, Capturado Archivo cal: ", d2s(fracr,1), " %", d2s(fracg, 1), " %", d2s(fracb, 1), " %");
		selectWindow("y"+yaxis+"frgd.tif");
		saveAs("Text Image", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"frgd.txt");
		run("Multiply...", "value="+Wr);
		selectWindow("y"+yaxis+"fggd.tif");
		saveAs("Text Image", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"fggd.txt");
		run("Multiply...", "value="+Wg);
		selectWindow("y"+yaxis+"fbgd.tif");
		saveAs("Text Image", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"fbgd.txt");
		run("Multiply...", "value="+Wb);
		imageCalculator("Add create 32-bit", "y"+yaxis+"frgd.tif","y"+yaxis+"fggd.tif");
		imageCalculator("Add create 32-bit", "Result of y"+yaxis+"frgd.tif","y"+yaxis+"fbgd.tif");
		selectWindow("Result of Result of y"+yaxis+"frgd.tif");
		run("Divide...", "value="+Wtot);
		run("Conversions...", " ");
		run("16-bit");
		if(puntnet){
			run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
			run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
		}
		saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"wd.tif");
	//escalado entre 10000
		configuracio = "function=[Straight Line] unit=[Gy] text1=[0  60000] text2=[0   6 ]";
		run("Calibrate...", configuracio);
		
	//texto

	// Limpieza de ruido Despeckle

		run("Despeckle");
		run("Despeckle");

	//===Fin limpieza ruido		

		saveAs("Text Image", rutapac+nh+"_FILM\\y"+yaxis+"wd.tif");
		selectWindow("Result of y"+yaxis+"frgd.tif");
		close();
		selectWindow("y"+yaxis+"frgd.tif");
		close();
		selectWindow("y"+yaxis+"fggd.tif");
		close();
		selectWindow("y"+yaxis+"fbgd.tif");
		close();

		print ("Aplicado el modelo 1 de ponderacion");
		}

		if (Model == 2) {

		//Correccion de los pesos por defecto
		//Introduccion de sesgo para eliminar el peso del canal azul
		segr = 10;
		segg = 4;
		segb = 1;

		selectWindow("y"+yaxis+"frgd.tif");
		saveAs("Text Image", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"frgd.txt");
		selectWindow("y"+yaxis+"fggd.tif");
		saveAs("Text Image", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"fggd.txt");
		selectWindow("y"+yaxis+"fbgd.tif");
		saveAs("Text Image", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"fbgd.txt");
		imageCalculator("Subtract create 32-bit", "y"+yaxis+"frgd.tif","y"+yaxis+"fggd.tif");
		imageCalculator("Subtract create 32-bit", "y"+yaxis+"fggd.tif","y"+yaxis+"fbgd.tif");
		imageCalculator("Subtract create 32-bit", "y"+yaxis+"fbgd.tif","y"+yaxis+"frgd.tif");
		
		selectWindow("Result of y"+yaxis+"frgd.tif");
		run("Abs");		
		makeRectangle(88, 39, 150, 150);
		getStatistics(n, mean, min, max, std, histogram);
		Wrg = mean;
		run("Select None");
		selectWindow("Result of y"+yaxis+"fggd.tif");
		run("Abs");		
		makeRectangle(88, 39, 150, 150);
		getStatistics(n, mean, min, max, std, histogram);
		Wgb = mean;
		run("Select None");
		selectWindow("Result of y"+yaxis+"fbgd.tif");		
		makeRectangle(88, 39, 150, 150);
		run("Abs");
		getStatistics(n, mean, min, max, std, histogram);
		Wbr = mean;
		run("Select None");

		selectWindow("Result of y"+yaxis+"frgd.tif");
		close();	
		selectWindow("Result of y"+yaxis+"fggd.tif");
		close();
		selectWindow("Result of y"+yaxis+"fbgd.tif");
		close();		
		
		Wr = 1/Wrg + 1/Wbr;
		Wg = 1/Wgb + 1/Wrg;
		Wb = 1/Wbr + 1/Wgb;
		Wtot = segr*Wr + segg*Wg + segb*Wb;
		Wr = segr*Wr / Wtot;
		Wg = segg*Wg / Wtot;
		Wb = segb*Wb / Wtot;

		fracr =  Wr* 100.0 ;
		fracg = Wg* 100.0 ;
		fracb = Wb* 100.0 ;

		print("pesos por canales, Correlated Weight ", d2s(fracr,1), " %", d2s(fracg, 1), " %", d2s(fracb, 1), " %");
		selectWindow("y"+yaxis+"frgd.tif");
		run("Multiply...", "value="+Wr);
		selectWindow("y"+yaxis+"fggd.tif");
		run("Multiply...", "value="+Wg);
		selectWindow("y"+yaxis+"fbgd.tif");
		run("Multiply...", "value="+Wb);

		imageCalculator("Add create 32-bit", "y"+yaxis+"frgd.tif","y"+yaxis+"fggd.tif");
		imageCalculator("Add create 32-bit", "Result of y"+yaxis+"frgd.tif","y"+yaxis+"fbgd.tif");
		selectWindow("Result of y"+yaxis+"frgd.tif");
		close();		
		selectWindow("Result of Result of y"+yaxis+"frgd.tif");

		run("Conversions...", " ");
		run("16-bit");
		if(puntnet){
			run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
			run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
		}
		saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"wd.tif");
	//escalado entre 10000
		nig1e4 = "10000 \n60000 "; 
		nig1 = "1 \n 6 ";
		configuracio = "function=[4th Degree Polynomial] unit=[Gy] text1=["+nig1e4+"] text2=["+nig1+"]";
		run("Calibrate...", configuracio);
	//===escalado
			
	// Limpieza de ruido Despeckle

		run("Despeckle");
		run("Despeckle");

	//===Fin limpieza ruido

		saveAs("Text Image", rutapac+nh+"_FILM\\y"+yaxis+"wd.tif");

		selectWindow("y"+yaxis+"frgd.tif");
		close();
		selectWindow("y"+yaxis+"fggd.tif");
		close();
		selectWindow("y"+yaxis+"fbgd.tif");
		close();
		
		print ("Aplicado el modelo 2 de ponderacion");
		
		}

print("fin del procesado de la placa "+Mk+1);

//Reordenacion de las placas Raw

temp = File.rename("Z:\\"+nh+"_FILM\\y"+yaxis+"a.tif", "Z:\\"+nh+"_FILM\\Raw\\y"+yaxis+"a.tif");
temp = File.rename("Z:\\"+nh+"_FILM\\y"+yaxis+"b.tif", "Z:\\"+nh+"_FILM\\Raw\\y"+yaxis+"b.tif");
temp = File.rename("Z:\\"+nh+"_FILM\\y"+yaxis+"c.tif", "Z:\\"+nh+"_FILM\\Raw\\y"+yaxis+"c.tif");
temp = File.rename("Z:\\"+nh+"_FILM\\y"+yaxis+"d.tif", "Z:\\"+nh+"_FILM\\Raw\\y"+yaxis+"d.tif");

temp = File.rename("Z:\\"+nh+"_FILM\\f"+placa+"a.tif", "Z:\\"+nh+"_FILM\\Raw\\f"+placa+"a.tif");
temp = File.rename("Z:\\"+nh+"_FILM\\f"+placa+"b.tif", "Z:\\"+nh+"_FILM\\Raw\\f"+placa+"b.tif");
temp = File.rename("Z:\\"+nh+"_FILM\\f"+placa+"c.tif", "Z:\\"+nh+"_FILM\\Raw\\f"+placa+"c.tif");
temp = File.rename("Z:\\"+nh+"_FILM\\f"+placa+"d.tif", "Z:\\"+nh+"_FILM\\Raw\\f"+placa+"d.tif");



}
}

print("\n FIN DEL PROCESADO TOTAL");

//======================================================================================================================
//DEFINICION DE FUNCIONES=========C. UNIFORMIDAD
//======================================================================================================================

function cuniform(placa){

	//Correccion por ajuste lineal cuadr�tico de las medidas empiricas. 

	//Constante "M�gica"
	Bpar = -1.77948;
	Apar = 8.6988;
	scat = 50;	
		
	//Margenes de correccion

	conmarx = 300;
	conmar2x = 1000;
	conmary = 90;
	conmar2y = 860;
	conori = 440;

	print("correccion por uniformidad de "+placa);
	print ("Inicio de la correcci�n por uniformidad");
	for(i=conmarx; i<=conmar2x; i++){
		for(j=conmary; j<= conmar2y; j++){
			varpx = (j-conori);
			Xd = getPixel(i, j);
		
		//FUNCION DEL MODELO

			if(Xd<48884){
				renfactor = (Bpar*Xd/10000+Apar)*varpx*varpx/100000+100;
				renfactor = renfactor/100;
			}else {
				renfactor = 1.0;
			}

		//====
			Xd = Xd / renfactor;
			setPixel(i, j, Xd);
			percent = (i-conmarx)/(conmar2x-conmarx)*100;
			print("\\Update: C.U :", d2s(percent,2), " %", renfactor);
			
		}
	}
}

//==========================================================================================
//BUSQUEDA DE MINIMOS, (para las coordenadas de los picos)

function minimum (pni, pnj, lloc) {

	min = 65000;
	marge = 0.1;

	pno = newArray(2);

	for (i=pni; i<pni+lloc; i++) {
		for (j=pnj; j<pnj+lloc; j++) {
			mint = getPixel(i,j);
			if ((mint < min)&&(mint<getPixel(i+1,j))&&(mint<getPixel(i-1,j))) {
				min = mint;
				pno[0] = i;
				pno[1] = j;
			}
		}	
	}
	return pno;	
}
