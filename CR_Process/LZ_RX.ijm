//MACRO PARA LA CAPTURA DE PARAMETROS DE LAS PLACAS LUZ RAYOS

      leftButton=16;
      rightButton=4;
      shift=1;
      ctrl=2; 
      alt=8;
      leftButtonpshift = 17;
      rightButtonpshift = 5;
      rightButtonpcrt = 18;
      k=-1;
      ax = newArray(17);
      ay = newArray(17);
      cord = newArray(18);
      fletxaa = newArray(18);
      fletxab = newArray(18);
     
      stop = 0;
      cord[0] ="CENTRO";
      cord[1] ="NO";
      cord[2] ="NE";
      cord[3] ="EN";
      cord[4] ="ES";
      cord[5] ="SE";
      cord[6] ="SO";
      cord[7] ="OS";
      cord[8] ="ON";
      cord[9] ="Rad NO";
      cord[10] ="Rad NE";
      cord[11] ="Rad EN";
      cord[12] ="Rad ES";
      cord[13] = "Rad SE";
      cord[14] = "Rad SO";
      cord[15] = "Rad OS";
      cord[16] = "Rad ON";
      cord[17] = "FINAL"; 

      fletxaa[0] = 934;
      fletxaa[1] = 724;
      fletxaa[2] = 1182;
      fletxaa[3] = 1426;
      fletxaa[4] = 1428;
      fletxaa[5] = 1192;
      fletxaa[6] = 718;
      fletxaa[7] = 534;
      fletxaa[8] = 546;
      fletxaa[9] = 662;
      fletxaa[10] = 1282;
      fletxaa[11] = 1320;
      fletxaa[12] = 1328;
      fletxaa[13] = 1266;
      fletxaa[14] = 688;
      fletxaa[15] = 492;
      fletxaa[16] = 514;
      fletxaa[17] = 0;

      fletxab[0] = 1196;
      fletxab[1] = 858;
      fletxab[2] = 892;
      fletxab[3] = 1196;
      fletxab[4] = 1540;
      fletxab[5] = 1768;
      fletxab[6] = 1744;
      fletxab[7] = 1494;
      fletxab[8] = 1056;
      fletxab[9] = 860;
      fletxab[10] = 858;
      fletxab[11] = 1048;
      fletxab[12] = 1626;
      fletxab[13] = 1698;
      fletxab[14] = 1676;
      fletxab[15] = 1620;
      fletxab[16] = 1000;
      fletxab[17] = 0;

     

     fx = 36.641/2120;
     fy = 43.820/2548;

     
     x2=-1; y2=-1; z2=-1; flags2=-1;
      logOpened = false;
      if (getVersion>="1.37r")
          setOption("DisablePopupMenu", true);
      print("Inicio programa captura");
      print("Esperando a punto "+cord[0]+" ... ");
      //makeRectangle(fletxaa[0], fletxab[0], 150, 150);
      while ((!logOpened || isOpen("Log"))&&(stop==0)) {
          getCursorLoc(x, y, z, flags);
          //makeRectangle(fletxaa[k+1]+1015-ax[0], fletxab[k+1]+1225-ay[0], 150,150);
          if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
	  
	  if (flags&leftButtonpshift==leftButtonpshift) {
	  beep();
	  print(" OK");
	  k++;
              	if(k<17){
		print("Esperando a punto "+cord[k+1]+" ... "); 
		             
	 	ax[k] = x;
	  	ay[k] = y;
	//Control de capturas
		if(k>1){
			if((abs(ax[k]-ax[k-1])<10)&&(abs(ay[k]-ay[k-1])<10)) {
				wait(100);
				beep();
				wait(100);
				beep();
				print(" ERROR DE CAPTURA PROBABLE ");
			}
		}
	//Fin control de capturas				
		}
		if(k==16){
		stop = 1;
		}
		 
	  }
	  if (flags&rightButtonpshift==rightButtonpshift) {
	  ax[k] = x;
	  ay[k] = y;
	  print("Recapturando punto"+k+" OK");
	  }
	  
              logOpened = true;
              startTime = getTime();
          }
          x2=x; y2=y; z2=z; flags2=flags;
          wait(10);
      }
	
     //print("Puntos escogidos");
     //for(k=0;k<17;k++){
     //	print(ax[k], ay[k]);
     //}      

     print(" ");
     lzx1 = abs((ax[7]+ax[8])/2-ax[0])*fx;	
     lzx2 = abs((ax[3]+ax[4])/2-ax[0])*fx;
     lzy1 = abs((ay[5]+ay[6])/2-ay[0])*fy;	
     lzy2 = abs((ay[1]+ay[2])/2-ay[0])*fy;
     rxx1 = abs((ax[15]+ax[16])/2-ax[0])*fx;
     rxx2 = abs((ax[11]+ax[12])/2-ax[0])*fx;
     rxy1 = abs((ay[13]+ay[14])/2-ay[0])*fy;
     rxy2 = abs((ay[9]+ay[10])/2-ay[0])*fy;
     print("RESULTADOS ");
     beep();
     wait(200);
     beep();
     wait(200);
     beep();
     print("");
     //print("LZ x1: "+lzx1+" RX x1: "+rxx1);
     //print("LZ x2: "+lzx2+" RX x2: "+rxx2);
     //print("LZ y1: "+lzy1+" RX y1: "+rxy1);
     //print("LZ y2: "+lzy2+" RX y2: "+rxy2);
     print(lzx1);
     print(lzx2);
     print(lzy1);
     print(lzy2);
     print(rxx1);
     print(rxx2);
     print(rxy1);
     print(rxy2);
     
     

      if (getVersion>="1.37r")
          setOption("DisablePopupMenu", false);



