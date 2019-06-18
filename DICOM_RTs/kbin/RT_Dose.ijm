
  requires("1.34m");

//=======INICIALIZACION DE VARIABLES=======================================
//inicializacion de variables

  title = "Calculador de Histogramas Dosis Volumen";

  //rutas de archivos por defecto

  rutavol = "C:\\JDon\\ROIs\\";
  arxdosdef = "C:\\JDon\\Dosis\\dosis.tiff";
  
  //variables generales
    


  print("Macro Conversion de dosis");

  arxori = "ORI.txt";

  // abrir archivo, capturar ORI
  arxorit = rutavol + arxori;
  landugabe = split(File.openAsString(arxorit), "\n");
  ori = split(landugabe[0], ", ");
  
  arxdosauk = arxdosdef;
  arxdosauk = File.openDialog("Archivo de dosis");
 
  //abrir archivo de dosis

  open(arxdosauk);

  pixelspacing = getInfo("0028,0030");
  izkina = getInfo("0020,0032");
  getDimensions(zabalera, altuera, canalanes, cortes, marcos);


  ori[0] = 256 + ori[0];
  ori[1] = 256 + ori[1];

  scalefac = split(pixelspacing, "\\");
  goradose = split(izkina, "\\");
  zabalera = toString(round(zabalera*parseFloat(scalefac[0])));
  altuera = toString(round(altuera*parseFloat(scalefac[1])));
  scalefac[0] =toString(parseFloat(scalefac[0]),1);
  scalefac[1] =toString(parseFloat(scalefac[1]),1);

  transx = toString(parseFloat(ori[0])+parseFloat(goradose[0]));
  transy = toString(parseFloat(ori[1])+parseFloat(goradose[1]));

  print(zabalera, altuera, cortes);

  print(scalefac[0], scalefac[1], goradose[0], goradose[1], goradose[2], ori[0],ori[1]);

  run("Scale...", "x="+scalefac[0]+" y="+scalefac[1]+" z=1.0 width="+zabalera+" height="+altuera+" depth="+cortes+" interpolation=Bilinear process create title=dose.tif");

  run("Canvas Size...", "width=512 height=512 position=Top-Left zero");

  run("Translate...", "x="+transx+" y="+transy+" interpolation=None stack");