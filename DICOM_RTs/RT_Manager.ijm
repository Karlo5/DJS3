
  requires("1.34m");

//=======INICIALIZACION DE VARIABLES==CHECKSUM=====================================
//inicializacion de variables

  title = "RT DICOM Manager. H. DONOSTIA";
  mesu = "Gestor de archivos RT_DICOM y calculador de Histogramas";
  rutamacro = "C:\\Program Files\\ImageJ\\plugins\\DonostiaJavaSuite\\DICOM RTs\\kbin\\";
  arxdefault = "C:\\JDon\\RTStruct.dcm";
  botoiak = newArray("Estructuras", "Dosis perfecta", "Histograma", "RTDose tiff");  


 //===============INTERFACE===USER data INPUT====================================

  arxvol = File.openDialog(title);
  File.copy(arxvol,arxdefault);
  print(arxvol);
  print(arxdefault);
 
  print("lanzando clase RTStruct_2_cvs");
  run("RTStruct 2 cvs");

  Dialog.create(title);
  Dialog.addMessage(mesu);
  Dialog.addString("Archivo de estructuras: ", arxvol);
  Dialog.addRadioButtonGroup("Calcular", botoiak, 1, 4, "Dibujar estructuras");
  Dialog.getRadioButton();
  Dialog.show;

  aukera = Dialog.getRadioButton();

  if(aukera=="Estructuras"){
	runMacro(rutamacro+"RT_Struct_Margotu.txt");	
  }
   if(aukera=="Dosis perfecta"){
	runMacro(rutamacro+"RT_Dosis_EzinHobe_Abiarazi.txt");	
  }

  if(aukera=="Histograma"){
	runMacro(rutamacro+"RT_Histogramer.txt");	
  }

  if(aukera=="RTDose tiff"){
	runMacro(rutamacro+"RT_Dose.txt");	
  }
