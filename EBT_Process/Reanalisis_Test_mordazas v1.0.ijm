
  requires("1.34m");

//=======INICIALIZACION DE VARIABLES==CHECKSUM=====================================
//inicializacion de variables
  title = ". Reanalisis del Test Mordazas .";
  ni="y9wd"; 
  rutapac = "C:\\Documents and Settings\\Administrador\\Escritorio\\CC_Artiste\\CS_8_9_10 Luz rayos\\Test Mordazas\\BU_imagenes_test mordaza\\";		

 //==================Valores de desplazamientos geometrico de an�lisis de las placas
 
 despinix=54;
 despiniy=39;
 despx=60;
 despy=101;
 
 




 //==========================Valores decalibraci�n del programa.
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
  Dialog.addMessage(" . Reanalisis del Test Mordazas .");
  Dialog.addMessage(" abre la imagen");
  
  Dialog.show();

  
run("Text Image... ", rutapac+ni+".txt");





/////================================================================================================

/////============================CALIBRACION=========================================================



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
print("X1E6,X2E6,Y1E6,Y2E6,X1E15,X2E15,Y1E15,Y2E15,  es:");

for(i=0;i<=7;i++){
print(valgap[i]*valcalibra[i]);
//print(valgap[i]);
}



//======================================================================================================================
//DEFINICION DE FUNCIONES=========
//======================================================================================================================

//==========================================================================================
//BUSQUEDA DE Maximos, (para las coordenadas del origen)

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
//BUSQUEDA DE minimos, (para las coordenadas del origen)
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

