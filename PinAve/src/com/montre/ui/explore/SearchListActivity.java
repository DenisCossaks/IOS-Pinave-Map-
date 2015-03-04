package com.montre.ui.explore;


import java.io.File;
import java.util.ArrayList;
import java.util.Hashtable;

import com.montre.data.CategoryInfo;
import com.montre.data.Notification;
import com.montre.data.PinInfo;
import com.montre.data.SearchOption;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.httpclient.AsyncImageLoader_Async;
import com.montre.lib.ComputeDistance;
import com.montre.lib.Const;
import com.montre.lib.UserDefault;
import com.montre.pinave.MainActivity.Mythread;
import com.montre.pinave.R;
import com.montre.pindetail.PinDetailActivity;
import com.montre.ui.basic.BasicUI;
import com.montre.util.JsonParser;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;


public class SearchListActivity extends Activity {

	private ListView lvList = null;
	private ResultListAdapter 	adapter = null;

	ArrayList<CategoryInfo> arrCategories = new ArrayList<CategoryInfo>();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		this.setContentView(R.layout.search_list);
		
		this.initViews();
//		this.initData();
				
	}

	@Override
	protected void onResume() {
		super.onResume();
		
		this.initData();
	}

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
//		super.onBackPressed();
		finish();
	}
	
	public void initViews() {
		// TODO Auto-generated method stub
		
		lvList = (ListView) findViewById(R.id.lv_list);
		
		Button btnSelect = (Button) findViewById(R.id.btn_center);
		btnSelect.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
				arrCategories.remove(1);
				arrCategories.remove(0);
				
				SearchActivity.arrSelected = arrCategories;
				
				finish();
				
			}
		});
		
	}

	public void initData() {
		// TODO Auto-generated method stub

		arrCategories.clear();
		
		CategoryInfo selectAll = new CategoryInfo();
		selectAll.strName = "Select All";
		arrCategories.add(selectAll);
		
		CategoryInfo removeAll = new CategoryInfo();
		removeAll.strName = "Remove All";
		arrCategories.add(removeAll);
		
		
		for (int i = 0; i < Share.g_arrCategory.size(); i++) {
			CategoryInfo category = Share.g_arrCategory.get(i);
		
			category.setSelect(true);
			
			arrCategories.add(category);
		}
		
		refresh();
	}

	
	public void refresh () {
		
		boundAdapter(arrCategories);
		
	}
	
		
	public void checkCategory(CategoryInfo info) {
		if (info.strName.equals("Select All")) {
			for (int i = 0; i < arrCategories.size(); i++) {
				arrCategories.get(i).setSelect(true);
			}
		}
		else if (info.strName.equals("Remove All")) {
			for (int i = 0; i < arrCategories.size(); i++) {
				arrCategories.get(i).setSelect(false);
			}
		}
		else {
		
			boolean bChecked = info.getSelect();
			bChecked = !bChecked;
			
			info.setSelect(bChecked);
			
			int replaceIndex = -1;
			for (int i = 0; i < arrCategories.size(); i++) {
				CategoryInfo _category = arrCategories.get(i);
				
				if (_category.getId().equals(info.getId())) {
					replaceIndex = i;
					break;
				}
			}
			
			if (replaceIndex != -1) {
				arrCategories.remove(replaceIndex);
				arrCategories.add(replaceIndex, info);
			}
		}
		refresh();
	}
		
    public void boundAdapter(ArrayList<CategoryInfo> list) {
		if (list == null)
			return;
		
    	adapter = new ResultListAdapter(SearchListActivity.this, list, lvList);
    	lvList.setAdapter(adapter);
		adapter.notifyDataSetChanged();
    }

    
    public class ResultListAdapter extends BaseAdapter {
		private Context mContext = null;
		private ArrayList<CategoryInfo> itemList = null;
		private ListView listView1;
		
		
		public ResultListAdapter(Context mContext, ArrayList<CategoryInfo> itemList,
				ListView listView1) {
			this.mContext = mContext;
			this.listView1 = listView1;
			this.itemList = itemList;
		}

		@Override
		public int getCount() {
			return itemList.size();
		}

		@Override
		public Object getItem(int position) {
			return itemList.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView, ViewGroup parent) {
			View view = convertView;
			ViewCache cache;
			
			if (view == null) {
				LayoutInflater inflater = LayoutInflater.from(mContext);
				view = inflater.inflate(R.layout.list_content_category, null);
				cache = new ViewCache(view);
				view.setTag(cache);
			} else {
				cache = (ViewCache) view.getTag();
			}
			
			if(itemList == null || itemList.size()==0)
				return view;
							
			final CategoryInfo item = itemList.get(position);
			
			if(item == null)
				return view;
			
			ImageView ivCategory = (ImageView)view.findViewById(R.id.cell_category);
			TextView title = (TextView) view.findViewById(R.id.cell_title);
			ImageView ivArrow = (ImageView)view.findViewById(R.id.cell_arrow);
			ivArrow.setBackgroundResource(R.drawable.cell_check);
			
			
			int resId = item.getResouceId();
			if (resId != 0) { 
				ivCategory.setBackgroundResource(resId);
				ivCategory.setVisibility(View.VISIBLE);
			} else {
				ivCategory.setVisibility(View.INVISIBLE);
			}
			
			
			String name = item.getName();
			title.setText(name);
			
			boolean bChecked = item.getSelect();
			if (!bChecked || item.strName.equals("Select All") || item.strName.equals("Remove All")) {
				ivArrow.setVisibility(View.INVISIBLE);
			} else {
				ivArrow.setVisibility(View.VISIBLE);
			}
		
			view.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					
					checkCategory(item);
				}
			});
			
			return view;
			
		}


	}
    
    class ViewCache {
		private View view;
//		private WebView iconWebView = null;

		public ViewCache(View view) {
			this.view = view;
		}

//		public WebView getWebView() {
//			if (iconWebView == null) {
//				iconWebView = (WebView) view
//						.findViewById(R.id.iconWebView);
//			}
//			return iconWebView;
//		}
	}
	

}
