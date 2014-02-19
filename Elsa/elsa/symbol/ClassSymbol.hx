package elsa.symbol;

/**
 * 클래스 심볼
 */
class ClassSymbol extends Symbol {
	
	/**
	 * 클래스 맴버 (함수, 변수)
	 */
	public var members:Array<VariableSymbol>;
	
	public function new(id:String) {
				
		super();
		
		this.id = id;
	}

	/**
	 * 클래스의 맴버를 검색한다.
	 * 
	 * @param id
	 * @return
	 */
	public function findMemberByID(id:String):VariableSymbol {
		for(i in 0...members.length){
			if (members[i].id == id) {
				return members[i];
			}
		}
		return null;
	}
}