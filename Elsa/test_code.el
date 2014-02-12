var checkUntil:number = 100;
var result:array;

var k:number = 0;

for(var i:number = 2 -> checkUntil ){
	var flag:number = 1;
	for(var j:number = 2 -> i - 1){		
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