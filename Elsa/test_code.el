var checkUntil:number = 100;
var result:array;

var k:number = 0;

result[k++] = 34;

for( i in 2...checkUntil ){
	var flag:number = 1;
	
	for( j in 2...i - 1){		
		if((i % j) == 0){			
			flag = 0;
			break;
		}
	}
	
	if(flag){
		print(i as string);
		result[k++] = i;
	}
}