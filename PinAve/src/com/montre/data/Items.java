package com.montre.data;

import java.io.Serializable;
import java.util.ArrayList;

public class Items implements Serializable{
	
	private static final long serialVersionUID = 1L;
	
	
	private ArrayList<CategoryInfo> categoryList ;


	public ArrayList<CategoryInfo> getItemList() {
		if(categoryList == null){
			return new ArrayList<CategoryInfo>();
		}
		return categoryList;
	}

	public void setItemList(ArrayList<CategoryInfo> itemList) {
		this.categoryList = itemList;
	}
	
	
}
