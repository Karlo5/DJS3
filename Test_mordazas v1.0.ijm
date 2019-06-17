
  requires("1.34m");

//=======INICIALIZACION DE VARIABLES==CHECKSUM=====================================
//inicializacion de variables
  title = ".        Test Mordazas         .";
  nh="imagenes test mordazas"; 
  lot="CD";
  rutacal = "C:\\Documents and Settings\\Administrador\\Escritorio\\Proyectos\\IMRT\\EBT2_Cal\\Mch\\";
  rutapac = "Z:\\";		

//variables de escala para 72 dpi
  amplada = "334";
  alsada = "227";

//valores de recorte de la imagen, centrado en la placa
  margex = 480;
  margey = 320;
  origenx = 68;
  origeny = 170;


//valores para buscar los puntos para posicionar el origen

  p1idef2 = 685;
  p1jdef2 = 360;
  costatdef2 =70;


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

 //==================Valores de desplazamientos geometrico de an�lisis de las placas
 
 despinix=54;
 despiniy=39;
 despx=60;
 despy=101;
 
 
 
 //===================================Valores decalibraci�n del programa.
 // Se obtienen con medidas previas y relacionan la dosis que hay en el gap de las mordazas
 // con la posici�n de las mismas.
 //los guardaremos como un vector de la siguiete forma:
 // Valcalibra= X1E6,X2E6,Y1E6,Y2E6,X1E15,X2E15,Y1E15,Y2E15
 
 
 valcalibra = newArray(8);
 valcalibra[0] =3.69;
 valcalibra[1] =4.24;
 valcalibra[2] =4.15;
 valcalibra[3] =4.17;
 valcalibra[4] =4.65;
 valcalibra[5] =4.87;
 valcalibra[6] =5.26;
 valcalibra[7] =5.64;
 
 
 //matriz para almacenar los valores obtenidos en la prueba.
 valgap=newArray(8);
  
 
 
//========================FIN DE INICIALIZACION VARIABLES, FIN CHECKSUM===========

//===============INTERFACE===USER data INPUT====================================
//inicio de la interface de recogida de datos NH, Calibracion, cortes y placas
  Dialog.create(title);
  Dialog.addMessage(".        Test Mordazas         .");
  Dialog.addMessage("NH:"+nh);  
  Dialog.addString("Lote:", lot);
  Dialog.addCheckbox("placa1", true);
  Dialog.addString("placa:", "13" );
  Dialog.addString("Y :","13");

  
  Dialog.show();
  lot = Dialog.getString();
  selmodel = defmodel;
  Model = 1;

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


for (Mk = 0; Mk <= 0; Mk++) {

//print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> placa "+Mk+1);
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
			
// Obtengo el centro decordenadas actual y  despues del giro.
			pn = minimum (p1idef2, p1jdef2, costatdef2);
			p1x = pn[0];
			p1y = pn[1];
//			p1x = 724;
//			p1y = 392;
	anchura = getWidth();
	altura = getHeight();
			p0x = ((anchura-altura)/2)+p1y;
			p0y = ((anchura+altura)/2)-p1x;
//...........
	open(rutapac+nh+"_FILM\\y"+yaxis+"B.tif");
	open(rutapac+nh+"_FILM\\y"+yaxis+"C.tif");
	open(rutapac+nh+"_FILM\\y"+yaxis+"D.tif");



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
		
	
			alfa = -90.0;
			
		run("Rotate... ", "angle=alfa grid=1 interpolation=Bilinear");

		
	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ORIGEN, Referencia canal rojo
	
		if(k==0){
			print("placa rotada ", alfa, " grados :: origen de la placa ", p0x,p0y);
			makePoint(p0x,p0y);
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

//		print ("Aplicado el modelo 1 de ponderacion");
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

//=========================================================
// Obtenci�n de los valores de calibraci�n

run("In [+]");
run("In [+]");

valgap[3]= valorgapY (despinix+(0*despx),despiniy+(0*despy));
//valgap[3]= valorgapX (despinix+(0*despx),despiniy+(0*despy));

valgap[2] = valorgapY (despinix+(1*despx),despiniy+(0*despy));
//valgap[2] = valorgapX (despinix+(1*despx),despiniy+(0*despy));

valgap[1] = valorgapX (despinix+(2*despx),despiniy+(0*despy));

valgap[0] = valorgapX (despinix+(3*despx),despiniy+(0*despy));

valgap[7] = valorgapY (despinix+(0*despx),despiniy+(1*despy));

valgap[6] = valorgapY (despinix+(1*despx),despiniy+(1*despy));

valgap[5] = valorgapX (despinix+(2*despx),despiniy+(1*despy));
//valgap[5] = valorgapY (despinix+(2*despx),despiniy+(1*despy));

valgap[4] = valorgapX (despinix+(3*despx),despiniy+(1*despy));
//valgap[4] = valorgapY (despinix+(3*despx),despiniy+(1*despy));

//Presentaci�n de resultados......................................
print("La correci�n de las mordazas, seg�n el orden, ");
print("X1E6,X2E6,Y1E6,Y2E6,X1E15,X2E15,Y1E15,Y2E15,  es (en mm):");

for(i=0;i<=7;i++){
print(valgap[i]*valcalibra[i]);
//print(valgap[i]);
}



//======================================================================================================================
//DEFINICION DE FUNCIONES=========
//======================================================================================================================

//==========================================================================================
//BUSQUEDA DE Maximos, (para las coordenadas de los picos)

function maximum (pni, pnj, lloc) {

makeRectangle (pni, pnj, lloc, lloc);
getStatistics(a,b,c,max,d,e);

max=max*0.95;
	pno = newArray(2);

	for (i=pni; i<pni+lloc; i++) {
		for (j=pnj; j<pnj+lloc; j++) {
			maxt = getPixel(i,j);
			if (maxt > max) {
				max = maxt;
				pno[0] = i;
				pno[1] = j;
			}  
		}	
	}
	return pno;	
	
}
//BUSQUEDA DE minimos, (para las coordenadas de los picos)
function minimum (pni, pnj, lloc) {

	min = 65000;

	pno = newArray(2);

	for (i=pni; i<pni+lloc; i++) {
		for (j=pnj; j<pnj+lloc; j++) {
			mint = getPixel(i,j);
			if (mint < min) {
				min = mint;
				pno[0] = i;
				pno[1] = j;
			}  
		}	
	}
	return pno;	
}


function valorgapX (rx0, ry0) {

	vgap=0;
	makeRectangle(rx0+6,ry0+14,10,20);
	getStatistics(a,media1);
	wait(1000);
	makeRectangle(rx0+30,ry0+14,10,20);
	getStatistics(a,media2);
	wait(1000);
	makeRectangle(rx0+10,ry0+24,30,4);
	getStatistics(a,a,mina,maxa);
	wait(1000);
	
	media=(media1+media2)/2;
	minr=mina-media;
	maxr=maxa-media;
	
	if(maxr>-minr){
	vgap=maxr;}
	else{
	vgap=minr;}
	return vgap;	
}

//...........................

function valorgapY (rx0, ry0) {

	vgap=0;
	makeRectangle(rx0+14,ry0+6,20,10);
	getStatistics(a,media1);
	wait(1000);
	makeRectangle(rx0+14,ry0+30,20,10);
	getStatistics(a,media2);
	wait(1000);
	makeRectangle(rx0+24,ry0+10,4,30);
	getStatistics(a,a,mina,maxa);
	wait(1000);
	media=(media1+media2)/2;
	minr=mina-media;
	maxr=maxa-media;
	
	if(maxr>-minr){
	vgap=maxr;}
	else{
	vgap=minr;}
	return vgap;	
}

