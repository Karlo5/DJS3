
  requires("1.34m");

//=======INICIALIZACION DE VARIABLES=====================
//inicializacion de variables

  //rutas de archivos por defecto

  title = "Generador de Dosis Perfecta";
  rutavol = "C:\\JDon\\ROIs\\";
  arxvol = "struxtar.txt";

  //variables generales

  coordz=newArray(300);
  Array.fill(coordz, 1000);
  gunez = newArray(50000);
  contx =newArray(600);
  conty =newArray(600);
  tempxyz = newArray(3);
  zaharxyz = newArray(3);
  landugabe=newArray(50);
  arroi =newArray(50);
  mota = newArray(50);
  tempi =newArray(3);
  voltar1 = "hutsa";
  voltar2 = "hutsa";  
  voltar3 = "hutsa";

  print("Macro Dosis EzinHobe");

  //carga de los volumenes pintados en Rt-struct, carga del tipo asignado, carga de target

  arROIs = rutavol + arxvol;
  landugabe = split(File.openAsString(arROIs), "\n");
  for(j=0;j<lengthOf(landugabe);j++){
	tempi = split(landugabe[j], ", ");
            arroi[j] = tempi[0];
	mota[j] = tempi[1];

	//targets
	if(tempi[2]=="t1"){
		voltar1 = j;
	}
	if(tempi[2]=="t2"){
		voltar2 = j;
	}
	if(tempi[2]=="t3"){
		voltar3 = j;
	}

  }  

  //reasignacion de targets en funcion de la dosis prescrita
  //ordenacion voltar
		if(voltar1>voltar2){
			buftemp = voltar2;
			voltar2 = voltar1;
			voltar1 = buftemp;
		}
		if(voltar2>voltar3){
			buftemp = voltar3;
			voltar3 = voltar2;
			voltar2 = buftemp;
		}
		if(voltar1>voltar3){
			buftemp = voltar1;
			voltar1 = voltar3;
			voltar3 = buftemp;
		}

		
  //debugger
print("Volumenes target: ", arroi[voltar1], arroi[voltar2], arroi[voltar3]);
print(voltar1, voltar2, voltar3);

//===============INTERFACE===USER data INPUT====================================
//inicio de la interface de recogida de datos NH, Calibracion, cortes y placas
  Dialog.create(title);
  Dialog.addMessage("Generador de Dosis perfecta");
  Dialog.addSlider("Penumbra utilizada (mm): ", 0, 10, 1);
  Dialog.addMessage("");
  Dialog.addSlider("Dosis de fondo (cGy): ", 0, 100, 5);
  Dialog.addMessage("");
  Dialog.addNumber("Dosis presc."+arroi[voltar1]+" (cGy) : ", 0); 
  Dialog.addMessage("");
  Dialog.addNumber("Dosis presc."+arroi[voltar2]+" (cGy) : ", 0); 
  Dialog.addMessage("");
  Dialog.addNumber("Dosis presc."+arroi[voltar3]+" (cGy) : ", 0); 
  Dialog.show();

  pene = Dialog.getNumber();
  fons = Dialog.getNumber();
  dpre1 = Dialog.getNumber();
  dpre2 = Dialog.getNumber();
  dpre3 = Dialog.getNumber();
  
  newImage("Image", "RGB black", 512, 512, 1);

  	
            //Ordenacion de los tarjets para que el de mayor volumen-dosis no chafe al de menor volumen-dosis
	//ordenacion voltar segunda y definitiva
		if(dpre1>dpre2){
			buftemp = dpre2;
			dpre2 = dpre1;
			dpre1 = buftemp;
			bufstring = arroi[voltar2];
			arroi[voltar2] = arroi[voltar1];
			arroi[voltar1] = bufstring;
		}
		if(dpre2>dpre3){
			buftemp = dpre3;
			dpre3 = dpre2;
			dpre2 = buftemp;
			bufstring = arroi[voltar3];
			arroi[voltar3] = arroi[voltar2];
			arroi[voltar2] = bufstring;
		}
		if(dpre1>dpre3){
			buftemp = dpre3;
			dpre3 = dpre1;
			dpre1 = buftemp;
			bufstring = arroi[voltar3];
			arroi[voltar3] = arroi[voltar1];
			arroi[voltar1] = bufstring;
		}
		
		


  
for(j=0;j<lengthOf(arroi);j++){
 
  if(arroi[j]!=0){	
		arvol = arroi[j];
	
	//carga sin depurar de los puntos del volumen ROI del j arroi
		
	
//============MODULO SLICE IMAGEN====== de Creacion del la imagen en funcion del body
	//Asignacion de los valores de z a os cortes de forma creciente

	if(arvol=="BODY"){

		coord = split(File.openAsString(rutavol+arvol+".txt"), "\n");

		for (i=0; i<lengthOf(coord) ;i++){
			tempxyz = split(coord[i],", ");
			gunez[i] = tempxyz[2];
		}
		
			pk = 0;
			coordz[0]=parseFloat(gunez[0]);

		for(i=1;i<lengthOf(coord);i++){
			for(si = 0; si<=pk; si++){
				stoy = 0;
				if(parseFloat(gunez[i])==coordz[si]){
					stoy++;
				}
			}
			if((gunez[i-1]=="-1000")&&(stoy==0)){
				run("Add Slice");
				pk++;
				coordz[pk] = parseFloat(gunez[i]);
			}	
		}

		Array.sort(coordz);
	}

//FIN DE MODULO SLICE IMAGEN==== creacion de imagen Body

	//Dibujo de dosis sobre los volumenes seleccionados
//=================MODULO de VOLUMEN GENERAL ====
		//Busca el corte del contorno de los volumenes target, carga los puntos de contorno

	if((arvol=="BODY")||(j==voltar1)||(j==voltar2)||(j==voltar3)){  	
		
		coord = split(File.openAsString(rutavol+arvol+".txt"), "\n");

		print("Pintando: "+arvol);

		acum = 0; 

		//asignacion dosis prescripcion en targets
		if(j==voltar1){
			fons = dpre1;
		}
		if(j==voltar2){
			fons = dpre2;
		}
		if(j==voltar3){
			fons = dpre3;
		}
		//fin de asignacion

 		for (i=0; i<lengthOf(coord) ;i++){
	
			tempxyz = split(coord[i],", ");
	
			if(i>0){
				zaharxyz = split(coord[i-1],", ");
			}else{
				zaharxyz = split(coord[i],", ");
			}
		
		//SUB=MODULO BUSCA SLICE buscador de slice inicial y tras coordenada -1000
	
			if(i==0){
				for(ak=1;ak<lengthOf(coordz);ak++){
					if(coordz[ak-1]==parseFloat(tempxyz[2])){
						slicen=ak;
					}
				}
				Stack.setSlice(slicen);
			}	
			if(zaharxyz[2]==-1000){
				for(ak=1;ak<lengthOf(coordz);ak++){
					if(coordz[ak-1]==tempxyz[2]){
						slicen=ak;						
					}
				}
				Stack.setSlice(slicen);
			}
	
		//FIN SUB=MODULO BUSCA SLICE
			
			if(tempxyz[2]!=-1000){
		
				k = i-acum;
					
				contx[k]=parseFloat(tempxyz[0])+256.0;
				conty[k]=parseFloat(tempxyz[1])+256.0;
				if(k==0){
					Array.fill(contx, contx[0]);
					Array.fill(conty, conty[0]);
				}
						
			}else{
				//==============MOTOR====================
					//=====MOTOR DOSIS EZIN_HOBE===sub_sub_modulo
	
					makeSelection("polygon", contx, conty);
					//waitForUser("hemen");
					acum = i+1;
			
					//descomponiedo dpres en formato (255,255,255)
							nr = floor(fons/65025);
							ng = floor(fons/255-nr*255);
							nb = floor(fons-nr*65025-ng*255);
					//=========
							
							setForegroundColor(nr, ng, nb);
							roiManager("Add","body");
							roiManager("Fill");
							roiManager("Draw");
							roiManager("Delete");
				//=====================================
			}
		
		}

		//ultima vuelta
		makeSelection("polygon", contx, conty);
		acum = i+1;
			
	//descomponiedo dpres en formato (255,255,255)
		nr = floor(fons/65025);
		ng = floor(fons/255-nr*255);
		nb = floor(fons-nr*65025-ng*255);
	//=========
					
		setForegroundColor(nr, ng, nb);
		roiManager("Add","body");
		roiManager("Fill");
		roiManager("Draw");
		roiManager("Delete");
	//=====================================
		

	}
  }
}
selectWindow("ROI Manager");
run("Close");

for(p=0;p<pene;p++){
	run("Smooth");
}

