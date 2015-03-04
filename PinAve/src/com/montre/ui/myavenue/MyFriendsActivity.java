package com.montre.ui.myavenue;


import java.io.File;
import java.util.ArrayList;
import java.util.Hashtable;

import com.montre.data.CategoryInfo;
import com.montre.data.PinInfo;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.httpclient.AsyncImageLoader_Async;
import com.montre.lib.ComputeDistance;
import com.montre.lib.Const;
import com.montre.pinave.R;
import com.montre.pindetail.PinDetailActivity;
import com.montre.ui.basic.BasicUI;
import com.montre.ui.explore.ExploreActivity;
import com.montre.ui.explore.SearchActivity;
import com.montre.ui.explore.ExploreActivity.ResultListAdapter;
import com.montre.util.JsonParser;

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
import android.widget.TextView;


public class MyFriendsActivity extends BasicUI {

	private ListView lvList = null;
	private ResultListAdapter 	adapter = null;
	
	public ArrayList<UserInfo> arrUsers = new ArrayList<UserInfo>();

	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		this.setContentView(R.layout.friends_list);
		
		this.initViews();
		this.initData();
				
	}

	@Override
	public void initViews() {
		// TODO Auto-generated method stub
		
		lvList = (ListView) findViewById(R.id.lv_list);
		
		Button btnBack = (Button) findViewById(R.id.btn_left);
    	btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onBackPressed();
			}
		});
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub
		arrUsers = MyAvenueActivity.arrUsers;
		
		boundAdapter(arrUsers);
	}

		
	public void gotoDetail(UserInfo info) {
		Intent intent = new Intent(MyFriendsActivity.this, MyAvenueUserActivity.class);

		intent.putExtra("userId", info.str_id);
					
//		startActivity(intent);
		goNextHistory("MyAvenueUserActivity", intent);
	}
		
    public void boundAdapter(ArrayList<UserInfo> list) {
		
    	adapter = new ResultListAdapter(MyFriendsActivity.this, list, lvList);
    	lvList.setAdapter(adapter);
		adapter.notifyDataSetChanged();
    }

    
    public class ResultListAdapter extends BaseAdapter {
    	
		private Context mContext = null;
		private ArrayList<UserInfo> itemList = null;
		

		/**
		 * 
		 * @param mcontent
		 * @param itemList
		 */
		public ResultListAdapter(Context mContext, ArrayList<UserInfo> itemList,
				ListView listview) {
			this.mContext = mContext;
			this.itemList = itemList;
		}

		@Override
		public int getCount() {
			int index = itemList.size();
			return index;
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
		public View getView(int position, View convertView, ViewGroup parent) {
			int index = position;
			
			View view = convertView;
			ViewCache cache;
			{
				LayoutInflater inflater = LayoutInflater.from(mContext);
				view = inflater.inflate(R.layout.list_content_category, null);
				cache = new ViewCache(view);
				view.setTag(cache);
			}
			cache = (ViewCache) view.getTag();

			final UserInfo item = itemList.get(index);
			if (item == null) 
				return view;
			
			ImageView imageView = cache.getImageView();
			imageView.setVisibility(View.GONE);
			
			TextView tvTitle = (TextView) view.findViewById(R.id.cell_title);
			tvTitle.setText(item.str_firstname + " " + item.str_lastname);
			
			view.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					gotoDetail(item);
				}
			});
			
			
			return view;
		}

	}

	class ViewCache {
		private View view;
		private ImageView imageView = null;

		public ViewCache(View view) {
			this.view = view;
		}

		public ImageView getImageView() {
			if (imageView == null) {
				imageView = (ImageView) view
						.findViewById(R.id.cell_category);
			}
			return imageView;
		}
	}
	
}
