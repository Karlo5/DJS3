//MACRO PARA LA DIGITALIZACION DE PLACAS CON INSERTOS PARA PEGAR EN ONCENTRA

      leftButton=16;
      rightButton=4;
      shift=1;
      ctrl=2; 
      alt=8;
      leftButtonpshift = 17;
      rightButtonpshift = 5;
      rightButtonpcrt = 18;
      k=-1;
      ax = newArray(30);
      ay = newArray(30);
      axp = newArray(30);
      ayp = newArray(30);
      infosplit = newArray(20);
      resol = newArray(7);	     

	mrx = 1;
	mry = 1;
	mpx = 1;
	mpy = 1;	
           
      stop = 0;
      
//Inicializacion de la variable cord que da el mensaje tras la adquisicion

	cord = newArray(3);
	cord[0] ="ORIGEN";
	cord[1] ="EJE X positivo";
        cord[2] ="EJE X negativo";
              

//INTERFACE DE BIENVENIDA PARA INTRODUCIR EL FACTOR DE ESCALA

  Dialog.create("DIGI PLACA PRO");
  Dialog.addMessage("DIGITALIZADOR DE PLACA DE INSERTO DE ELECTRONES");  
  Dialog.addString("Medida horizontal real X:", mrx);
  Dialog.addString("Medida vertical real Y:", mry);
  Dialog.addString("Medida en placa X", mpx);
  Dialog.addString("Medida en placa Y", mpy);
 
  Dialog.show();
  mrx = parseFloat(Dialog.getString());
  mry = parseFloat(Dialog.getString());
  mpx = parseFloat(Dialog.getString());
  mpy = parseFloat(Dialog.getString());

  fx = mpx/mrx;
  fy = mpy/mry;

  infogen = getInfo();
  infosplit = split(infogen, "\n");
	for(i=0;i<lengthOf(infosplit);i++){
//verbose:	 print("mensaje:"+i+" "+infosplit[i]);
	 if(startsWith(infosplit[i], "Resol")){
		chop = infosplit[i];
	 }
	}
  
  resol = split(chop, " ");

//resolucion en cm/pixel. Supone que el escanner da la resolucion en el info en dpi

  fr = 2.54 / parseFloat(resol[1]); 

  print ("Factor de escala X: "+fx);
  print ("Factor de escala Y: "+fy);
  print ("Tama�o de pixel: " +resol[1]);

//Inicio del Loop de captura
     
      x2=-1; y2=-1; z2=-1; flags2=-1;
      logOpened = false;
      if (getVersion>="1.37r")
          setOption("DisablePopupMenu", true);
      
      print("Esperando a punto "+cord[0]+" ... ");
 
      while ((!logOpened || isOpen("Log"))&&(stop==0)) {
          getCursorLoc(x, y, z, flags);
          
          if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
	  
	  if (flags&leftButtonpshift==leftButtonpshift) {
	  beep();
	  print(" OK");
	  k++;
              	if(k<30){
			if(k<2){
				print("Alineacion: "+cord[k+1]+" ... "); 
		        } else {
				print("Esperando al punto "+(k-1));
			}

	 	ax[k] = 2*fr/(fx+fy)*x;
	  	ay[k] = 2*fr/(fx+fy)*y;
					
		}
		if(k==31){
		stop = 1;
		FinK = k;
		print("Maxima cantidad de puntos alcanzada");
		}
		 
	  }
	  if (flags&rightButtonpshift==rightButtonpshift) {
	  ax[k] = 2*fr/(fx+fy)*x;
	  ay[k] = 2*fr/(fx+fy)*y;
	  print("Recapturando punto"+k+" OK");
	  }
	  if (flags&rightButton==rightButton) {
		stop = 1;
		FinK = k;	  
	  } 		  

              logOpened = true;
              startTime = getTime();
          }
          x2=x; y2=y; z2=z; flags2=flags;
          wait(10);
      }

//Rotacion por los puntos de alineacion

	alfa = atan((ay[2]-ay[1])/(ax[1]-ax[2]));
	for(k=1;k<FinK+1;k++){
		ax[k]=ax[k]-ax[0];
        	ay[k]=ay[k]-ay[0];
		axp[k]=cos(alfa)*ax[k]+sin(alfa)*ay[k];
		ayp[k]=cos(alfa)*ay[k]-sin(alfa)*ax[k];
	}


     print(" colimador en placa (deg): " +alfa/3.14159265358979*180);

     print("RESULTADOS ");
     beep();
     wait(200);
     beep();
     wait(200);
     beep();
     print("");

     print("\\Clear");
     for(k=1;k<FinK+1;k++){
     print(axp[k],"; ",ayp[k]);
     }      
 
      if (getVersion>="1.37r")
          setOption("DisablePopupMenu", false);



