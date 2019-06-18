
  requires("1.34m");

//=======INICIALIZACION DE VARIABLES=======================================
//inicializacion de variables

  title = "Calculador de Histogramas Dosis Volumen";

  //rutas de archivos por defecto

  rutavol = "C:\\JDon\\ROIs\\";
  arxdosdef = "C:\\JDon\\Dosis\\dosis.tiff";
  rutadvh = "C:\\JDon\\DVH\\";
  arxdvh = "dvh.txt";

  //variables generales

  coord = newArray(10000);
  contx =newArray(600);
  conty =newArray(600);
  tempxyz = newArray(3);
  zaharxyz = newArray(3);
  landugabe=newArray(50);
  arroi =newArray(50);
  arroival =newArray(50);
  coordz=newArray(300);
  Array.fill(coordz, 1000);
  tempi =newArray(3);
  jcol = 0;
  

  print("Macro Histogramer");

  arxvol = "Struxtxt.txt";

  // abrir archivo, directorio de estructuras
  arROIs = rutavol + arxvol;
  landugabe = split(File.openAsString(arROIs), "\n");
  for(j=0;j<lengthOf(landugabe);j++){
	tempi = split(landugabe[j], ", ");
            arroi[j] = tempi[0];
	arroival[j] = 1;
  }  
  
  cuad = lengthOf(landugabe)/3+1;

 arxdosauk = arxdosdef;
 arxdosauk = File.openDialog("Archivo de dosis");
 
//===============INTERFACE===USER data INPUT====================================
//inicio de la interface de recogida de datos 
  Dialog.create(title);
  Dialog.addMessage("Calculador de histogramas");
  Dialog.addMessage("");
  Dialog.addString("Archivo de Dosis:", arxdosauk); 
  Dialog.addMessage("");
  Dialog.addString("Archivo de Vois: ", "Struxtxt.txt"); 
  Dialog.addCheckboxGroup(cuad, 3, arroi, arroival);
  Dialog.show;
  

  arxdos = Dialog.getString();
  arxvol = Dialog.getString();

   for(j=0;j<lengthOf(landugabe);j++){
   	arroival[j] = Dialog.getCheckbox();
   }

//abrir archivo de dosis

open(arxdos);

//===matraca de conversion dosis-tiff color dosis-tiff gris


if(!is("grayscale")){
	run("Conversions...", "  weighted");
	setRGBWeights(0.99609381, 0.00389099, 0.00001520);
	run("32-bit");
	run("Multiply...", "value=65280 stack");
	run("Conversions...", " ");
	run("16-bit");
}

Stack.getStatistics(rtvox, rtmean, rtmin, rtmax, rtdev);

dvh = newArray(rtmax*1.02);
dvht = newArray(rtmax*1.02);
grayp = newArray(rtmax*1.02);

//abrir archivo de salida texto
  
for(j=0;j<lengthOf(arroi);j++){

	Array.fill(grayp,0);
	Array.fill(dvh, 0);

	arvol = arroi[j];
	vol = 0;

	//body s� o s�
	arroival[0]=1;

	if(arroival[j]==1){	
		if(arvol!=0){

			coord = split(File.openAsString(rutavol+arvol+".txt"), "\n");

	//CAPTURADOR DE COORDENADAS DE DE IMAGEN BODY========

			if(arvol=="BODY"){

				zk = 0;

 				for (i=0; i<lengthOf(coord) ;i++){
	
					tempxyz = split(coord[i],", ");
					if(i>0){
						zaharxyz = split(coord[i-1],", ");
					}else{
						zaharxyz = split(coord[i],", ");
					}

					if(i==0){
						coordz[zk]=parseFloat(tempxyz[2]);
					}
					if(zaharxyz[2]==-1000){
						stoy = 0;
						for(jj = 0; jj<lengthOf(coordz);jj++){
							if(coordz[jj]==tempxyz[2]){stoy = 1;}
						}
						if(stoy==0){
							zk++;
							coordz[zk]=parseFloat(tempxyz[2]);
						}
					}
				}
				
				Array.sort(coordz);	

				//debugger coordz//for(i=0;i<lengthOf(coordz);i++){print(coordz[i]);}	
 			}
	
		//=====FIN CAPTURADOR
	
		//===CALCULADOR DE HISTOGRAMAS
	
			if((arvol!="ORI")){


	 			for (i=0; i<lengthOf(coord) ;i++){
	
					tempxyz = split(coord[i],", ");
					if(i>0){
						zaharxyz = split(coord[i-1],", ");
					}else{
						zaharxyz = split(coord[i],", ");
					}

				//SUB MODULO BUSCADOR SLICE====

					if((i==0)||(zaharxyz[2]==-1000)){
								
						acum = i;
						
						for(ak=0;ak<lengthOf(coordz);ak++){
							if(coordz[ak]==tempxyz[2]){
								slicen=ak;
							}
						}

						//MOTOR HISTOGRAMER
						if(i!=0){

							makeSelection("polygon", contx, conty);
							getRawStatistics(area, mitjana, min, max,std, dvhdif);
							vol = vol + area;
							//waitForUser(vol, mitjana);
															
							//conversion del histograma diferencia a acumulado
							for(p=0;p<lengthOf(dvhdif);p++){
								dvh[p] = dvh[p] + dvhdif[p];
							}

						}

						//====FIN MOTOR
						Stack.setSlice(slicen);
					}

				//====FIN BUSCADOR SLICE
		
					k = i-acum;
					if(tempxyz[2]!=-1000){
						contx[k]=parseFloat(tempxyz[0])+256.0;
						conty[k]=parseFloat(tempxyz[1])+256.0;
					}
					if(k==0){
						Array.fill(contx, contx[0]);
						Array.fill(conty, conty[0]);
					}
	
				}
	
				

			//Integracion inversa del histograma diferencial

				dvht[rtmax*1.01+1]=0;
				for(p2=rtmax*1.01;p2>=0;p2--){	
					dvht[p2]=dvht[p2+1]+dvh[p2];
				}	


			//Normalizacion representacion numerica
								
				for(p=0;p<lengthOf(dvht);p++){
					dvht[p] = dvht[p]/vol*100;
					grayp[p] = p;
					setResult(arvol, p, dvht[p]);
				}	
				updateResults();

				//Representacion grafica
				jcol++;
				if(j==14){jcol = 0;}
				if(arvol=="BODY"){
					jcol = 0;
					Plot.create("HDV", "Dosis (cGy)", "Volumen(%)", grayp, dvht);
					Plot.setLimits(0, rtmax*1.1, 0, 110);
					Plot.setFrameSize(1000,750);
				}
				Plot.setColor(colore(jcol));
				Plot.addText(arvol, 0.8, 0+0.02*j);
				Plot.add("line", grayp, dvht);
				
				
			}//exclusor del ori
		}//volumen nulo
	}//volumen seleccionado

}//volumen general

//======FUNCIONES=========================================

function colore(val){
	varcol = "black";
	if(val==1){ varcol = "black";}
	if(val==2){ varcol = "blue";}
	if(val==3){ varcol = "cyan";}
	if(val==4){ varcol = "darkGray";}
	if(val==5){ varcol = "gray";}
	if(val==6){ varcol = "green";}
	if(val==7){ varcol = "lightGray";}
	if(val==8){ varcol = "magenta";}
	if(val==9){ varcol = "orange";}
	if(val==10){ varcol = "pink";}
	if(val==11){ varcol = "red";}
	if(val==12){ varcol = "white";}
	if(val==13){ varcol = "yellow";}
	return varcol;
}

