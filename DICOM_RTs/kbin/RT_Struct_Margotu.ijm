
  requires("1.34m");

//=======INICIALIZACION DE VARIABLES==CHECKSUM=====================================
//inicializacion de variables

  //rutas de archivos por defecto

  title = "Dibujar las estructuras marcadas del RTStruct";
  rutavol = "C:\\JDon\\ROIs\\";
  arxvol = "Struxtxt.txt";

  //variables generales

  coordz = newArray(300);
  Array.fill(coordz, 1000);
  gunez = newArray(50000);
  contx =newArray(600);
  conty =newArray(600);
  tempxyz = newArray(3);
  zaharxyz = newArray(3);
  landugabe=newArray(50);
  arroi =newArray(50);
  arroival = newArray(50);
  mota = newArray(50);
  tempi =newArray(2);

  print("Macro Margotu");


  //carga de los volumenes pintados en el rt struct

  arROIs = rutavol + arxvol;
  landugabe = split(File.openAsString(arROIs), "\n");
  for(j=0;j<lengthOf(landugabe);j++){
	tempi = split(landugabe[j], ", ");
            arroi[j] = tempi[0];
	mota[j] = tempi[1];
	arroival[j] = 1;
  }  


//===============INTERFACE===USER data INPUT====================================
//inicio de la interface de recogida de datos NH, Calibracion, cortes y placas

  Dialog.create(title);
  Dialog.addMessage("Representacion de ROIs================================");
  lmax = 0;
  for(i=0;i<lengthOf(arroi);i++){
  	if(arroi[i]!=0){
  		lmax++;
  	}    
  }
  lmax = lmax / 3 + 1;
  Dialog.addCheckboxGroup(lmax,3,arroi,arroival);
  Dialog.show();

  newImage("Image", "RGB black", 512, 512, 1);
  

  for(j=0;j<lengthOf(arroi);j++){
	
	if(arroi[j]!=0){
	
  		volbai = Dialog.getCheckbox();

	//checkeo para saber si el volumen ha sido seleccionado
 		 if(volbai){
  	
			arvol = arroi[j];
			print("Pintando: "+arvol);	

	//carga sin depurar de los puntos del volumen ROI del j arroi

			coord = split(File.openAsString(rutavol+arvol+".txt"), "\n");

//==========MODULO SLICE IMAGEN===== de Creacion de la imagen en funcion del tama�o del BODY
  	 //Asignacion de los valores de z a los cortes en forma decreciente
			if(arvol=="BODY"){

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

	//Dibujo de todos los volumenes sobre la imagen creada
//=================MODULO de VOLUMEN GENERAL ====
		//Busca el corte del contorno, carga los puntos de contorno

  			acum = 0; 
            		slicen = 0;

 			for (i=0; i<lengthOf(coord) ;i++){

				tempxyz = split(coord[i],", ");

				if(i>0){
					zaharxyz = split(coord[i-1],", ");
				}else{
					zaharxyz = split(coord[i],", ");
				}

			//SUB=MODULO BUSCA SLICE buscador de slice inicial y tras coordenada -1000
	
				if(i==0){
					for(ak=0;ak<lengthOf(coordz);ak++){
						if(coordz[ak]==parseFloat(tempxyz[2])){
							slicen=ak;
						}
					}
					Stack.setSlice(slicen+1);
				}	
				if(zaharxyz[2]==-1000){
					for(ak=0;ak<lengthOf(coordz);ak++){
						if(coordz[ak]==tempxyz[2]){
							slicen=ak;						
						}
					}
					Stack.setSlice(slicen+1);
				}

			//FIN SUB=MODULO BUSCA SLICE

				if(tempxyz[2]!=-1000){
						k = i-acum;
						contx[k]=parseFloat(tempxyz[0])+256.0;
						conty[k]=parseFloat(tempxyz[1])+256.0;
						
					//==========MOTOR================================
						//=====MOTOR MARGOTU===sub_sub_modulo
						colorea = margotu(mota[j]);
						setColor(colorea);
						if(k>1){
							drawLine(contx[k], conty[k],contx[k-1],conty[k-1]);
						}
						//===fin pieza 1 motor margotu	
						//
				}		
				else{		
						//===pieza 2 motor margotu
						acum = i;
						drawLine(contx[k],conty[k],contx[1],conty[1]);
						//==debuger===waitForUser("comprobar");
						//===fin de pieza 2
					//====================================================
				}
						

			//FIN SUB=MODULO

//Fin otros volumenes
	

			}
		}

	}//fin if
}//fin for


//Especificaciones del color de los volumenes segun tipo

function margotu(mot) {

	defcolor = "white";

	if(mot=="EXTERNAL"){
		defcolor = "yellow";
	}
	if(mot=="AVOIDANCE"){
		defcolor = "blue";
	}
	if(mot=="PTV"){
		defcolor = "red";
	}
	if(mot=="GTV"){
		defcolor = "green";
	}
	if(mot=="ISOCENTER"){
		defcolor = "yellow";
	}

	return defcolor;

}
