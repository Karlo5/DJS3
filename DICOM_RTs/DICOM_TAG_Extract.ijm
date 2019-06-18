

tag1 = "0010,0020";
tag2 = "0008,1030";
tag3 = "0020,0062";
tag4 = "0010,1010";
tag5 = "0018,5101";
tag6 = "0018,0060";
tag7 = "0018,1152";
tag8 = "0018,7050";
tag9 = "0018,1191";
tag10 = "0018,11A0";
tag11 = "0040,0316";
tag12 = "0040,8302";



directorinput = "D:\\DICOMDIX\\PA";

for(k=0;k<30;k++){
arxius = getFileList(directorinput+k+"\\ST0\\SE0");

	for (i=0;i<arxius.length;i++){
		
		open(directorinput+k+"\\ST0\\SE0\\"+arxius[i]);
		
		a1 = getInfo(tag1);	
		a2 = getInfo(tag2);	
		a3 = getInfo(tag3);			
		a4 = getInfo(tag4);	
		a5 = getInfo(tag5);	
		a6 = getInfo(tag6);	
		a7 = getInfo(tag7);			
		a8 = getInfo(tag8);	
		a9 = getInfo(tag9);	
		a10 = getInfo(tag10);	
		a11 = getInfo(tag11);			
		a12 = getInfo(tag12);	

		print(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12);
		
		close(arxius[i]);
	}
}
