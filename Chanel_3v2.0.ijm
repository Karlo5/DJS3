
requires("1.47m");

//=======INICIALIZACION DE VARIABLES==CHECKSUM=====================================
//inicializacion de variables
title = "Conversion a Dosis EBT3 Multicanal";
nh="999999"; 
lot="CP";
rutacal = getDirectory("plugins")+"\\DJS3\\EBT_Process\\Lib\\EBT_Mch\\";
rutapac = "Z:\\";		

//Raw. Variable para debug, booleano que se ser cierto guarda las placas originales en 
//la carpeta Raw
raw = true;

//variable que si (true) detiene el programa cuando captura los puntos del centraje de la placa
veurepunts = true;

//variable que si (true) autoriza la realizacion de dos operaciones de despeckle sobre el resultado final
despeckle = true;

//variables de escala para 72 dpi
amplada = "339"; //se corresponde a 2*margex/72*2.54
alsada = "226"; //se corresponde a 2*margey/72*2.54

//valores de recorte de la imagen, centrado en la placa
margex = 480;
margey = 320;
origenx = 65; //en px. Medido directamente sobre maniquí iba (2.3 cm pasado a px para 72 d.p.i)
origeny = 167; //en px. Medido directamente sobre maniquí iba (5.9 cm pasado a px para 72 d.p.i)
chksum = amplada + alsada + margex + margey+ origenx+ origeny;
 
//valores por defecto para cuando se fuerza el ajuste geométrico

alfadef = 0;
p1ydef = 270;
p2xdef = 600;

//valores para buscar los puntos para rotar y posicionar la placa
p1idef1 = 250;
p1jdef1 = 263;
p2idef1 = 400;
p2jdef1 = 198;
p3idef1 = 600;
p3jdef1 = 263;
costatdef1 = 300;
costatdef2 = 20;
inv = false; //varible booleana que detecta si la placa esta invertida y necesita transf por paridad
chksum = p1idef1 + p1jdef1 + p2idef1 + p2jdef1 + p3idef1 + p3jdef1 + costatdef1 + chksum;


//valores del fondo por sectores para evaluar su constancia
//1 pl�stico, 2 placa, 3 fondo desnudo del escaner

v1xc = 1100;
v1yc = 400;
l1 = 45;
vmitjana1 = 65526;
vdesv1 = 300;
v2xc = 575;
v2yc = 400;
l2 = 45;	
vmitjana2 = 42415;
vdesv2 = 2000;
v3xc = 75;
v3yc = 400;
l3 = 45;
vmitjana3 = 62430;
vdesv3 = 300;


//Verificacion CHeckSum de constantes
chksum = chksum + vmitjana1 + vmitjana2 + vmitjana3 + vdesv1 + vdesv2 + vdesv3;
print (d2s(chksum,10));
if (chksum == 3.392436277E9) {print ("chksum OK");}
else{ print("chksum error");
	Dialog.create("Error CHKSUM");
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
Dialog.addCheckbox("Interrumpir ante errores de fondo", true);
Dialog.addCheckbox("Limpiar marcas de posicionamiento", true);
Dialog.addCheckbox("Forzar busqueda geométrica", false);
Dialog.addCheckbox("Suavizar al final", true);
Dialog.addCheckbox("Mostrar captura de markers", true);
Dialog.addCheckbox("Guardar las placas", true);
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
despeckle = Dialog.getCheckbox();
veurepunts = Dialog.getCheckbox();
raw = Dialog.getCheckbox();
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
//archivo de calibracion real

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
  
	//Media de las placas irradiadas

		open(rutapac+nh+"_FILM\\y"+yaxis+"A.tif");
		open(rutapac+nh+"_FILM\\y"+yaxis+"B.tif");
		open(rutapac+nh+"_FILM\\y"+yaxis+"C.tif");
		open(rutapac+nh+"_FILM\\y"+yaxis+"D.tif");

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

		//se selecciona el rojo para trabajar sobre él
		selectWindow("f"+placa+"r.tif");

// <<<Verificacion constancia escaneo canal rojo
	//PARENTESIS DE VERIFICACION DE CONSTANCIA
		if (veri == 1){
			makeRectangle(v1xc, v1yc, l1, l1);
			getStatistics(n, mean, min, max, std, histogram);
			if ((mean < vmitjana1+vdesv1) && (mean > vmitjana1-vdesv1)) { 
				print("sector 1 escaner constante OK");}
			else { if(stoper == true){
				Dialog.create("Error sector1");
				Dialog.addMessage("Error en el fondo de cristal");
				Dialog.show();
				}
			}
			makeRectangle(v2xc, v2yc, l2, l2);
			getStatistics(n, mean, min, max, std, histogram);
			if ((mean < vmitjana2+vdesv2) && (mean > vmitjana2-vdesv2)) { 
				print("sector 2 escaner constante OK");}
			else { if(stoper == true){ 
				Dialog.create("Error sector2");
				Dialog.addMessage("Error en el fondo de placa");
				Dialog.show();
				}
			}
			makeRectangle(v3xc, v3yc, l3, l3);
			getStatistics(n, mean, min, max, std, histogram);
			if ((mean < vmitjana3+vdesv3) && (mean > vmitjana3-vdesv3)) { 
				print("sector 3 escaner constante OK");}
			else { if(stoper == true){
				Dialog.create("Error sector3");
				Dialog.addMessage("Error en el fondo de plastico");
				Dialog.show();
				}
			}

			run("Select None");
		}
	//FIN DE PARENTESIS
		
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
					pn = minimum (p1idef1, p1jdef1, costatdef1, costatdef2);
					p1x = pn[0];
					p1y = pn[1];
					if(veurepunts){
						makePoint(p1x,p1y);
						msg();
					}
					selectWindow("y"+yaxis+"fr.tif");
					pn = minimum (p2idef1, p2jdef1, costatdef1, costatdef2);
					p2x = pn[0];
					p2y = pn[1];
					if(veurepunts){
						makePoint(p2x,p2y);
						msg();
					}
					selectWindow("y"+yaxis+"fr.tif");
					pn = minimum (p3idef1, p3jdef1, costatdef1, costatdef2);
					p3x = pn[0];
					p3y = pn[1];
					if(veurepunts){
						makePoint(p3x,p3y);
						msg();
					}
					selectWindow("y"+yaxis+"fr.tif");

					if(((p2x-p1x)>200)||((p2x-p1x)<190)){
						print("placa invertida y"+yaxis);
						inv = true;			
					}else{
						inv = false;
					}

					if(p3x!=p1x){
						tanval = (p1y-p3y)/(p3x-p1x);
						alfa = atan(tanval)*360/2/3.1415926535;
					}else{
						print("error no especifico en la captura de los puntos 1 y 3. Se fuerza geom");
						geotop = true;
					}
				}		
				//forzado geométrico
				if(geotop) alfa = alfadef;

				run("Rotate... ", "angle=alfa grid=1 interpolation=Bilinear");

		
	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ORIGEN, Referencia canal rojo
	
				if(k==0){
					selectWindow("y"+yaxis+"fr.tif");
					pn = minimum (p1idef1, p1jdef1, costatdef1, costatdef2);
					p1x = pn[0];
					p1y = pn[1];
					if(veurepunts){
						makePoint(p1x,p1y);
						msg();
					}
					selectWindow("y"+yaxis+"fr.tif");
					pn = minimum (p2idef1, p2jdef1, costatdef1, costatdef2);
					p2x = pn[0];
					p2y = pn[1];
					if(veurepunts){
						makePoint(p2x,p2y);
						msg();
					}
					selectWindow("y"+yaxis+"fr.tif");
					pn = minimum (p3idef1, p3jdef1, costatdef1, costatdef2);
					p3x = pn[0];
					p3y = pn[1];
					if(veurepunts){
						makePoint(p3x,p3y);
						msg();
					}
    			//forzado geométrico
					if(geotop){
						p0x = p2xdef+origenx;
						p0y = p1ydef+origeny;
					}else{			
						p0x = (origenx + p2x)/2+(p1x+p3x)/4;
						p0y = origeny + p1y;
					}
					d0x = ((origenx + p2x)-(p1x+p3x)/2)/72*25.4;

					print("Discrepancias en el desplazamiento lateral (mm): "+d0x);
					if(inv){
						p0x = (p1x+p3x)/2;
						print("Placa invertida, origen corregido por la media del marker 1 y 3");
					}
					print("placa rotada ", alfa, " grados :: origen de la placa ", p0x,p0y);
				}	
		
	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>RECORTE
	
				makeRectangle(p0x-margex, p0y-margey, 2*margex, 2*margey);
				run("Copy");
				run("Internal Clipboard");
				saveAs("Tiff", "temp.tif");

	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Inversion si placa invertida

				if(inv)	run("Flip Horizontally");

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
		
					
			selectWindow("y"+yaxis+"f"+quark[k]+"g.tif");
			saveAs("Tiff", "temp"+quark[k]+".tif");
			run("Multiply...", "value=C"+quark[k]);
			run("Subtract...", "value=A"+quark[k]);
			open(rutapac+nh+"_FILM\\Rest\\y"+yaxis+"f"+quark[k]+"g.tif");
			run("Conversions...", " ");
			run("32-bit");		
			run("Subtract...", "value=B"+quark[k]);
			run("Abs");
			imageCalculator("Divide create 32-bit", "temp"+quark[k]+".tif", "y"+yaxis+"f"+quark[k]+"g.tif");
			selectWindow("Result of temp"+quark[k]+".tif");
		//resolucion en decimales, conversion a 0.1 mGy
			run("Multiply...", "value=1000");
			run("16-bit");
			saveAs("Tiff", rutapac+nh+"_FILM\\Rest\\y"+yaxis+"f"+quark[k]+"gd.tif");
			selectWindow("temp"+quark[k]+".tif");
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
			print("Lote de calibracion: "+lot);
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
	//escalado entre 1000
			configuracio = "function=[Straight Line] unit=[Gy] text1=[0  6000] text2=[0   6 ]";
			run("Calibrate...", configuracio);
		
	// Limpieza de ruido Despeckle
			if(despeckle){
				run("Despeckle");
				run("Despeckle");
			}
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
		//escalado entre 1000
			nig1e4 = "1000 \n6000 "; 
			nig1 = "1 \n 6 ";
			configuracio = "function=[4th Degree Polynomial] unit=[Gy] text1=["+nig1e4+"] text2=["+nig1+"]";
			run("Calibrate...", configuracio);
			
	// Limpieza de ruido Despeckle
			if(despeckle){
				run("Despeckle");
				run("Despeckle");
			}
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

		if(raw){
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
}

if(puntnet) print("Markers limpiados");
if(geotop) print("Procesado geométrico forzado");
if(despeckle) print("Suavizado final aplicado");

print("\n FIN DEL PROCESADO TOTAL OK");
selectWindow("Log");
saveAs("Text", "Z:\\"+nh+"_FILM\\LogProcess.txt");

//======================================================================================================================
//DEFINICION DE FUNCIONES
//==========================================================================================
//BUSQUEDA DE MAXIMOS, (para las coordenadas de los picos)

function maximum (pni, pnj, lloc1, lloc2) {
	
	max = 0;
	pno = newArray(2);

	for (j=pnj; j<pnj+lloc2; j++) {
		for (i=pni; i<pni+lloc1; i++) {
			maxt = getPixel(i,j);
			if ((maxt > max)) {
				max = maxt;
				pno[0] = i;
				pno[1] = j;
			}
		}	
	}
	return pno;	
}

//BUSQUEDA DE MINIMOS, (para las coordenadas de los picos)

function minimum (pni, pnj, lloc1, lloc2) {
	
	min = 1000;
	pno = newArray(2);

	for (j=pnj; j<pnj+lloc2; j++) {
		for (i=pni; i<pni+lloc1; i++) {
			mint = getPixel(i,j);
			if((mint < (getPixel(i+3,j)-0.2))&&(mint < (getPixel(i-3,j)-0.2))&&(mint < (getPixel(i,j+3)-0.2))&&(mint < (getPixel(i,j-3)-0.2))){
				if (mint < min) {
					min = mint;
					pno[0] = i;
					pno[1] = j;
				}
			}
		}	
	}
	return pno;	
}


//funcion de mensaje para comprobación de errores en el código
function msg(){
	Dialog.create("sector");
	Dialog.addMessage("Correcto?");
	Dialog.show();
}
