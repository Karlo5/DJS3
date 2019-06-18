/**
 * Pograma de analisis de PICKET_FENCE. Genera el archivo (fecha).csv con informacion relativa al posicionamiento de las
 * multilaminas centrales segun configuracion del setup elegido en la carpeta lib/epid(ns)g(n)m(m).txt
 * Valido para cualquier imagen de PICKET_FENCE previo programado de los valores nominales en el setup
 */
requires("1.34m");
title = "Picket Fence MultiAnalizer";
fecha="01/01/1900"; 
fisico="Carlos Pino León";
rutalib = getDirectory("plugins")+"\\DJS3\\EPID_Process\\Lib\\Setups\\";
rutout = getDirectory("plugins")+"\\DJS3\\EPID_Process\\Output\\";
mysetups = getFileList(rutalib);
delimiter = "\\";
hsp = "&nbsp;";
nsepid = "nonumber";

//====Dialogo
	
Dialog.create(title);
Dialog.addString("Fisico:", fisico );
Dialog.addChoice("Setup:", mysetups);
Dialog.addCheckbox("Eliminar preproceso:", false);
Dialog.addCheckbox("Suavizar previamente:", false);

	
Dialog.show();

fisico = Dialog.getString();  //fisico que realiza en analisis
setup = Dialog.getChoice();  //setup de picketfence elegido
norot = Dialog.getCheckbox();  //booleano que indica si se ignora la correccion por rotacion y desplazamiento del EPID
suav = Dialog.getCheckbox();  //booleano para suavizar

//====Carga de las caracteristicas de analisis del picket_fence seleccionado

sinput = split(File.openAsString(rutalib+setup),"\n"); //fichero a String[] por lineas
sgapfc = split(sinput[0],"	"); //primera linea gaps esperados en string
smlc = split(sinput[1],"	"); //segunda linea posiciones esperadas del mlc en string
ssignx = split(sinput[2],"	"); //signo x en string
signx = parseFloat(ssignx[1]); //signo x en Float
ssigny = split(sinput[3],"	"); //signo y en string
signy = parseFloat(ssigny[1]); //signo y en Float
spixorix = split(sinput[4],"	"); //origen esperado x en pixeles del escaneo de gaps en string
spixoriy = split(sinput[5],"	"); //origen esperado y en pixeles del escaneo de gaps en string
stolerance = split(sinput[6],"	"); //tolerancia en las diferencias en mm en string
mode = split(sinput[7],"	"); //modo de busqueda predefinido (maximos/minimos)
ranges = split(sinput[8],"	");  //control de minimo/maximo global. Busca a una distancia x range[0] una difenencia en PV mayor que range[1]

Ngaps = lengthOf(sgapfc)-2; //Numero de gaps esperado segun setup

	//conversion a Float de las caracteristicas esperadas del picketFence a partir de los string capturados del setup.conf
	//origen y final x/y de los perfiles de analisis que se tiraran en busca de máximos mínimos
posy = newArray(lengthOf(smlc)-2);
posy[0] = parseFloat(spixoriy[1]); //pix
posx = newArray(2); //pix
posx[0] = parseFloat(spixorix[1]); //pix
	//conversion de la tolerancia

tol = parseFloat(stolerance[1]);

//====carga de los dicom_tags de la imagen significativos para su analisis

fecha = getInfo("0008,0022"); //aaaammdd (FECHA)
nsepid = getInfo("0018,1000"); //numero de serie de EPID (administrativo)
sPIXY = getInfo("0028,0010"); //pix Tamaño de la imagen en PIX en el eje Y
PIXY = parseFloat(sPIXY);
sPIXX = getInfo("0028,0011"); //pix Tamaño de la imagen en PIX en el eje X
PIXX = parseFloat(sPIXX);
sscale = getInfo("3002,0011"); //mm/pix escala de mm a pixeles
vscale = split(sscale,delimiter)
scalex = parseFloat(vscale[0]);  //escala x en mm/pix
scaley = parseFloat(vscale[1]);  //escala y en mm/pix

soriepid = getInfo("3002,000D"); //mm origen x/y/z de la imagen en mm en string
voriepid = split(soriepid,delimiter);
despx = parseFloat(voriepid[0]); //origen x de la imagen en mm Float
despy = parseFloat(voriepid[1]); //origen y de la imagen en mm Float
despz = parseFloat(voriepid[2]); //origen z de la imagen en mm Float
sangepid = getInfo("3002,000E"); //ºcent rotacion de la imagen en º cent

//ruta de salida

stringoutx = "diferencias en X:\n" + fecha +"\n"+fisico+"\n"+setup+"\n"+nsepid+"\n";
//stringouty = "diferencias en Y:\n" + fecha +"\n"+fisico+"\n"+setup+"\n"+nsepid+"\n";
htmlout ="<html><p><b>DIFERENCIAS EN X:</b><br><b>Fecha: </b>"+fecha+"<br><b>Autor: </b>"+fisico+"<br><b>Configuracion: </b>"+setup+"<br><b>NS EPID: </b>"+nsepid+"<br>";

//correccion de la escala por la DFI del EPID. Supone que la SAD es 1000 mm 
scalex = scalex*1000/(1000-despz); 
scaley = scaley*1000/(1000-despz);
htmlout = htmlout + "<b>Escala: </b>"+scalex+","+scaley+"<br>";

//suavizado previo al analisis
if(suav){
	for(i=0;i<3;i++) run("Smooth");
}

//====Preestudio de la imagen de EPID, centrado y rotación relativa a la estructura MLC
//busqueda de la rotacion en segun las mordazas exteriores
makeLine(PIXX/4,0,PIXX/4,PIXY);
profys = getProfile();
makeLine(3*PIXX/4,0,3*PIXX/4,PIXY);
profyi = getProfile();

makeLine(0,PIXY/4,PIXX,PIXY/4);
profxs = getProfile();
makeLine(0,3*PIXY/4,PIXX,3*PIXY/4);
profxi = getProfile();

ays = newArray(2);
axs = newArray(2);
ays = bor(profys);
axs = bor(profxs);
ayi = newArray(2);
axi = newArray(2);
ayi = bor(profyi);
axi = bor(profxi);

y0 = ays[0]-ayi[0];  //pix
y1 = ays[1]-ayi[1];
x0 = axs[0]-axi[0];  //pix
x1 = axs[1]-axi[1];

//angulo de rotacion
ang = 1/2*(atan(-(x0+x1)/PIXY)+atan((y0+y1)/PIXX))*180/3.1415926535;
difang = 1/2*abs(atan(-(x0+x1)/PIXY)-atan((y0+y1)/PIXX))*180/3.1415926535;
porcang = (abs(ang)-difang)/ang*100;
print("Rotacion encontrada: "+ang+"+/-"+difang+", ("+porcang+" %)	Rotacion EPID: "+sangepid);
//rotacion de la imagen 
if(porcang<10.0){
	print("Incertidumbre en el angulo encontrado grande, rotacion anulada");
	ang = 0;
}
if(norot){
	print("Se fuerza angulo de rotacion = 0");
	ang = 0;
}
run("Rotate... ", "angle="+ang+" grid=1 interpolation=Bilinear slice");

//centro de la imagen segun las mordazas dadas
y0 = (ays[0]+ayi[0])/2-PIXY/2;  //pix
y1 = (ays[1]+ayi[1])/2-PIXY/2;
x0 = (axs[0]+axi[0])/2-PIXX/2;  //pix
x1 = (axs[1]+axi[1])/2-PIXX/2;
dy = (y0 + y1)*scaley; //mm
dx = (x0 + x1)*scalex; //mm 
print("Desplazamiento encontrado: "+dx+" ,"+dy+",	Desplazamineto EPID: "+despx+", "+despy);

//posicion final del perfil en funcion de los gaps esperados
posx[1] = posx[0]+(parseFloat(sgapfc[lengthOf(sgapfc)-1])-parseFloat(sgapfc[1]))/scalex;

//====Busqueda perfil por perfil y escritura en Buffer de salida
for (i = 0; i < lengthOf(smlc)-2; i++) {
	if(i>0) posy[i] = (parseFloat(smlc[i+1])-parseFloat(smlc[i]))/scaley+posy[i-1];
	else{
		stringoutx = stringoutx +"MLC(mm)/GAP(mm);";
		htmlout = htmlout+"<table class=\"egt\">"+"<tr><th>MLC/GAP</th>";
		//stringouty = stringouty +"MLC(mm)/GAP(mm);";
		for(j=0;j<lengthOf(sgapfc)-1;j++){
			stringoutx = stringoutx + sgapfc[j+1]+";";
			//stringouty = stringouty + sgapfc[j+1]+";";
			htmlout = htmlout + "<th>"+sgapfc[j+1];
		}
		stringoutx = stringoutx +"\n";
		//stringouty = stringouty +"\n";
		htmlout = htmlout +"</tr>";
	}
	makeLine(posx[0],posy[i],posx[1],posy[i],1);
	vec = getProfile();
	crit = critics(vec, mode[1]);
	//añadido que asegura que se han encontrado la cantidad de puntos criticos esperados
	if(!(lengthOf(crit)==Ngaps)){
		print("No se ha encontrado punto critico en lámina "+smlc[i]+"Ngaps: "+Ngaps+" Crit: "+lengthOf(crit));
		print("Se aplicará corrección suponiendo que la distancia entre gaps es constante");
		crit = criterror(crit, (Ngaps-lengthOf(crit)));
	}
		
	for(j =0;j<lengthOf(crit);j++){
		if(j==0) {
			stringoutx = stringoutx + smlc[i+1]+";";
			//stringouty = stringouty + smlc[i+1];
			htmlout = htmlout + "<tr><td><b>"+smlc[i+1]+"</b></td>";
		}
		difx = ((crit[j]+posx[0])-PIXX/2)*scalex + signx*parseFloat(sgapfc[j+1]);
		dify = (posy[i]-PIXY/2)*scaley - signy*parseFloat(smlc[i+1]);
		stringoutx = stringoutx + difx+";";
		//stringouty = stringouty + dify+";";
		if(abs(difx)>tol) htmlout = htmlout + "<td><font color=\"red\">"+hsp+hsp+difx+hsp+hsp+"</font></td>";
		else htmlout = htmlout + "<td><font color=\"green\">"+hsp+hsp+difx+hsp+hsp+"</font></td>";
	}
	stringoutx = stringoutx+"\n";
	//stringouty = stringouty+"\n";
	htmlout = htmlout +"<tr>";
}

htmlout = htmlout +"</table>";

File.saveString(stringoutx, rutout+"x"+fecha+nsepid+".csv");
File.saveString(htmlout, rutout+"x"+fecha+nsepid+".html");
//File.saveString(stringouty, rutout+"y"+fecha+nsepid+".csv");

print("Fin del analisis "+fecha+nsepid);
print("Ahora grabar la imagen dicom eliminando los slices innecesarios");
print("deseleccionar todos los checklist de remove y poner la fecha en el nombre del archivo");


run("Save DICOM");


//=======FUNCIONES==========

//busca los puntos criticos (maximos mínimos segun smode) de un vector dado de valores vec
function critics(vec, smode){

	rangertz = parseFloat(ranges[1]);
	valertz = parseFloat(ranges[2]);
	
	inim = newArray(100);
	j = 0;
	for(i=rangertz;i<lengthOf(vec)-rangertz;i++){
		if(startsWith(smode, "Mi")){
			if((vec[i]<vec[i+1])&&(vec[i]<vec[i-1])&&(vec[i]<vec[i+2])&&(vec[i]<vec[i-2])&&
			((vec[i]+valertz)<vec[i+rangertz])&&((vec[i]+valertz)<vec[i-rangertz])){
				inim[j] = i;
				j++;
			}
		}else{
			if((vec[i]>vec[i+1])&(vec[i]>vec[i-1])&(vec[i]>vec[i+2])&(vec[i]>vec[i-2])&
			((vec[i]-valertz)>vec[i+rangertz])&((vec[i]-valertz)>vec[i-rangertz])){
				inim[j] = i;
				j++;
			}
		}
	}	
	result = newArray(j);
	for(j=0;j<lengthOf(result);j++){
		result[j] = inim[j];
	}
	return result;
}

//busca los bordes de campos segun orden del vec. borv0 borde creciente, borv1 borde decreciente
function bor(vec){

	maxv = max(vec);  //devuelve el valor máximo del vector
	minv = minnoz(vec); //devuelve el valor mínimo del vector diferente de 0

	borv = newArray(2);
	cre = 0;
	decre = 0;
	med = (maxv+minv)/2;
	
	for(i=0; i< lengthOf(vec)-1;i++){
		if((vec[i]<med)&&(vec[i+1]>med)){
			cre = (med-vec[i])/(vec[i+1]-vec[i])+i;
		}
		if((vec[i]>med)&&(vec[i+1]<med)){
			decre = (med-vec[i])/(vec[i+1]-vec[i])+i;
		}
	}
	borv[0] = cre;
	borv[1] = decre;

	return borv;
}

function max(vec){

	value = 0;
	//se restan dos pixeles para evitar efectos de borde
	for(i=2; i<lengthOf(vec)-2;i++){
		if(vec[i]>value){
			value = vec[i];
		}
	}
	return value;
}

function minnoz(vec){

	value = max(vec);
	//se restan dos pixeles para evitar efectos de borde
	for(i=2; i<lengthOf(vec)-2;i++){
		if((vec[i]<value)&&(vec[i]!=0)){
			value = vec[i];
		}
	}
	return value;
}

//corrije la cantidad de puntos criticos suponiendo que se haya escapado UNO y asumiendo 
//la cantidad de puntos criticos esperados
function criterror(ivec, N){

	rangerror = ranges[1]; //asume que si la diferencia en pixeles entre el valor esperado y el hayado
						  //es mayor que esta cantidad se ha saltado un punto

	inewvec = newArray(lengthOf(ivec)+N);

	inewvec[0] = ivec[0];
	p = 1;
	for(i=1;i<lengthOf(ivec);i++){

		gap = (parseFloat(sgapfc[i])-parseFloat(sgapfc[i-1]))/scalex;
		
		if(abs(ivec[i]-ivec[i-1])>(abs(gap)+rangerror*2)){
			
			inewvec[p] = 1/0;
			p++;
		}else{
			inewvec[p] = ivec[i];
		}
		p++;
	}

	return inewvec;
	
}

