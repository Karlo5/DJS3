
  requires("1.34m");

//=======INICIALIZACION DE VARIABLES==CHECKSUM=====================================
//inicializacion de variables

  title = "Selector de targets";
  rutavol = "C:\\JDon\\ROIs\\";
  rutamacro = "C:\\Program Files\\ImageJ\\plugins\\DonostiaJavaSuite\\DICOM RTs\\kbin\\";
  arxvol = "Struxtxt.txt";

  arroi = newArray(50);
  arroidef = newArray(50);
  mota = newArray(50);
  tempi = newArray(3);
   
  k = 0;  
  
  print("Macro Dosis EzinHobe previo");
  arROIs = rutavol + arxvol;
  landugabe = split(File.openAsString(arROIs), "\n");
  for(j=0;j<lengthOf(landugabe);j++){
	tempi = split(landugabe[j], ", ");
            arroi[j] = tempi[0];
	mota[j] = tempi[1];
	arroidef[j] = d2s(0, tempi[2]);
            if(arroidef[j]=="0"){
		k++;
	}
  } 

//===============INTERFACE===USER data INPUT====================================
//inicio de la interface de recogida de datos NH, Calibracion, cortes y placas
  Dialog.create(title);
  Dialog.addMessage("Selector de targets (3 m�ximo)");
  Dialog.addCheckboxGroup(k/3+1,3,arroi, arroidef);

  Dialog.show();

  t1 = "";
  t2 = "";
  t3 = "";

  for(j=0;j<k;j++){
	arroidef[j] = Dialog.getCheckbox();
	if(arroidef[j]!=0){
		t1 = arroi[j];
		if(t2==""){
			t2=t1;	
		}
		if(t3==""){
			t3=t1;
			t2="";	
		}
	}
  }

  print("Volumenes seleccionados: ");
  print(t1+", "+ t2+", "+ t3);

  arxiu =  File.open(rutavol+"struxtar.txt");

  for(j=0;j<k;j++){

	if(arroi[j]==t1){
		print(arxiu, arroi[j]+", "+mota[j]+", t1");
	}
	if(arroi[j]==t2){
		print(arxiu, arroi[j]+", "+mota[j]+", t2");
	}
	if(arroi[j]==t3){
		print(arxiu, arroi[j]+", "+mota[j]+", t3");
	}
	if((arroi[j]!=t1)&&(arroi[j]!=t2)&&(arroi[j]!=t3)){
		print(arxiu, arroi[j]+", "+mota[j]+", "+arroidef[j]);
	}

  }

  File.close(arxiu);

  runMacro(rutamacro+"RT_Dosis_EzinHobe.txt");
