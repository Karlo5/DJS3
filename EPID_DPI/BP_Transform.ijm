
  requires("1.34m");

//VARIABLES

 rutalib = "C:\\Documents and Settings\\Administrador\\Escritorio\\IMRT\\EPIDLib";


// ===CARGA DE IMAGENES Y FORMULA PARA LA CONVERSION EN DOSIS

  open(rutalib+"\\BPdef.tif");
  
  for (i=0;i<1024;i++){
	for (j = 0; j < 1024; j++){
		temp = getPixel(i, j);
		temp = funcionmod(i, j, temp);
		setPixel(i, j, temp);

	}
  }

  saveAs("tiff", rutalib+"\\BPdefBerria.tif");

//FUNCION A APLICAR SOBRE LOS PIXELES

function funcionmod ( ai, aj, atemp) {

	factor = abs(aj-512)/512;
	factor = 1.0+factor/20;
	atemp = atemp / factor;
	return atemp;

}
