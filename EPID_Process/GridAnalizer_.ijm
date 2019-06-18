//Script de an�lisis de la rejilla de tratamiento de la mesa
//Analiza la imagen para buscar deformidades geom�tricas de la imagen en el epid
//recoge dos matrices X, Y con el lado medio de los cuadrados visibles en la imagen

//declaracion variables
xini = 90;
yini = 30;
interx = 69;
intery = 69; 
imax = 13;
jmax = 15;
nsmooth = 70;

vec =newArray(1024);
dernul = newArray(100);

for(n=0;n<nsmooth;n++){
	run("Smooth");
}

for(i=0;i<imax;i++){

	makeLine(xini+i*interx,yini, xini+i*interx,yini+(jmax-1)*intery);
	vec = getProfile();
	dernul = critic(vec);
	for(k=0;k<dernul.length;k++){
		if(dernul[k]!=0) print(dernul[k]);
	}
	
}




//=======FUNCIONES==========

function critic(vec){

	der = newArray(1024);
	dernul = newArray(100);	

	for(i=0;i<955;i++){
		der[i] = vec[i]-vec[i+1];
	}
	
	j=0;	
	for(i=0;i<955;i++){
		if((der[i]>0)&&(der[i+1]<=0)){
			if((vec[i+10]>vec[i])&&(vec[i-10]>vec[i])){
				dernul[j] =i+yini;
				j++;
			}	
		}
	}	

	return dernul;	
	
}
