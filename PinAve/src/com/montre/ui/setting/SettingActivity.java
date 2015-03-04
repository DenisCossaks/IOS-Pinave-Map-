package com.montre.ui.setting;

import java.io.IOException;

import org.xmlpull.v1.XmlPullParserException;

import com.custom.gallery.IntroduceActivity;
import com.montre.data.Share;
import com.montre.data.UserLoginInfo;
import com.montre.lib.UserDefault;
import com.montre.pinave.MainActivity;
import com.montre.pinave.R;
import com.montre.pinave.login.PolicyActivity;
import com.montre.pinave.login.TermsActivity;
import com.montre.ui.basic.BasicUI;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.ExpandableListView.OnChildClickListener;


public class SettingActivity extends BasicUI {

	MenuListAdapter m_menuAdapter;
	ExpandableListView m_listMenu;
	
	public final String[] MENU_STR = new String[] {"Setting", "Help", "Support", "Service", "Info"};
	public final String[][] MENU_CHILD_STR = {{"Profile", "Pin Setting", "Map View", "Unit Setting"}, 
	    		{"Category Definitions", "How to place pins", "About Notifications", "About Messages", "Introduction", "PinAve Video"},
	    		{"Send Feedback"},
	    		{"Terms of Service", "Privacy Policy"},
	    		{"Log Out"},}; 
	    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.setting);

		this.initViews();
		this.initData();
	}

	@Override
	public void initViews() {
		// TODO Auto-generated method stub
		
		Button btnAbout = (Button) findViewById(R.id.btn_right);
		btnAbout.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
			}
		});
		btnAbout.setVisibility(View.GONE);
		
		m_listMenu = (ExpandableListView) findViewById(R.id.list);	
		
	}

	
	@Override
	public void initData() {
		// TODO Auto-generated method stub
		
		initMenu();
	}
	
	
	  public void initMenu() {
	    	m_menuAdapter = new MenuListAdapter(this);
	    	m_listMenu.setAdapter(m_menuAdapter);
	    	m_menuAdapter.notifyDataSetChanged();
	    	for (int i = 0; i < MENU_STR.length; i++) {
				m_listMenu.expandGroup(i);
			}
	    	
	    	m_listMenu.setOnChildClickListener(new OnChildClickListener() {
				
				public boolean onChildClick(ExpandableListView parent, View v,
						int groupPosition, int childPosition, long id) {
					
					if ( groupPosition == 0 ) { // Setting
						switch (childPosition) {
						case 0:{
						
//							startActivity(new Intent(SettingActivity.this, ProfileActivity.class));
							Intent intent = new Intent(SettingActivity.this, ProfileActivity.class);
							goNextHistory("ProfileActivity", intent);
							break;
						}
						case 1:{
							startActivity(new Intent(SettingActivity.this, PinSettingActivity.class));
//							Intent intent = new Intent(SettingActivity.this, PinSettingActivity.class);
//							goNextHistory("PinSettingActivity", intent);
							break;
						}
						case 2:{
//							startActivity(new Intent(SettingActivity.this, MapSettingActivity.class));
							Intent intent = new Intent(SettingActivity.this, MapSettingActivity.class);
							goNextHistory("MapSettingActivity", intent);
							break;
						}
						case 3:{
//							startActivity(new Intent(SettingActivity.this, UnitSettingActivity.class));
							Intent intent = new Intent(SettingActivity.this, UnitSettingActivity.class);
							goNextHistory("UnitSettingActivity", intent);
							break;
						}
						}
					}
					else if ( groupPosition == 1 ) { // help
						switch (childPosition) {
						case 0:{
							Intent intent = new Intent(SettingActivity.this, CategoryDefineActivity.class);
							goNextHistory("CategoryDefineActivity", intent);
							break;
						}
						case 1:{
							Intent intent = new Intent(SettingActivity.this, HowToPlaceActivity.class);
							goNextHistory("HowToPlaceActivity", intent);
							break;
						}
						case 2:{
							Intent intent = new Intent(SettingActivity.this, AboutNotifyActivity.class);
							goNextHistory("AboutNotifyActivity", intent);
							break;
						}
						case 3:{
							Intent intent = new Intent(SettingActivity.this, AboutMessageActivity.class);
							goNextHistory("AboutMessageActivity", intent);
							break;
						}
						case 4:{ // intro
//							startActivity(new Intent(SettingActivity.this, IntroduceActivity.class));
							Intent intent = new Intent(SettingActivity.this, IntroduceActivity.class);
							goNextHistory("IntroduceActivity", intent);
							break;
						}
						case 5:{
							String url = "http://youtu.be/mGLR--JM5HQ";
							Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
							startActivity(browserIntent);
							break;
						}
						}
					}
					else if ( groupPosition == 2) { //support
						sendFeedback();
					}
					else if ( groupPosition == 3 ) { // service
						switch (childPosition) {
						case 0:{ //terms 
							Intent intent = new Intent(SettingActivity.this, TermsActivity.class);
							goNextHistory("TermsActivity", intent);
							break;
						}
						case 1:{ // privacy
							Intent intent = new Intent(SettingActivity.this, PolicyActivity.class);
							goNextHistory("PolicyActivity", intent);
							break;
						}
						}
					}
					else if ( groupPosition == 4) { //info
						switch (childPosition) { // log out
						case 0:{
							logOut();
							break;
						}
						}						
					}

					return true;
				}
			});
	    }
	    
	  public class MenuListAdapter extends BaseExpandableListAdapter {

	    	Context m_context;
	    	public MenuListAdapter(Context context) {
	    		m_context = context;
	    	}
	    	
			
			public Object getChild(int groupPosition, int childPosition) {
				
				return childPosition;
			}

			
			public long getChildId(int groupPosition, int childPosition) {
				return childPosition;
			}

			
			public int getChildrenCount(int groupPosition) {
				int nCount = MENU_CHILD_STR[groupPosition].length;
				return nCount;
			}

			
			public View getChildView(int groupPosition, int childPosition,
					boolean isLastChild, View convertView, ViewGroup parent) {
				View view = convertView;
				if ( view == null ) {
					LayoutInflater inflater = LayoutInflater.from(m_context);
					view = inflater.inflate(R.layout.list_content_category, null);
				}
				
				ImageView icon = (ImageView) view.findViewById(R.id.cell_category);
				TextView txt = (TextView) view.findViewById(R.id.cell_title);

				icon.setBackgroundResource(getSettiingResourceId(groupPosition, childPosition));
				txt.setText(MENU_CHILD_STR[groupPosition][childPosition]);
				
				return view;
			}

			
			public Object getGroup(int groupPosition) {
				
				return MENU_STR[groupPosition];
			}

			
			public int getGroupCount() {
				return MENU_STR.length;
			}

			
			public long getGroupId(int groupPosition) {
				return groupPosition;
			}
			
			public View getGroupView(int groupPosition, boolean isExpanded,
					View convertView, ViewGroup parent) {
				View view = convertView;
				if ( view == null ) {
					LayoutInflater inflater = LayoutInflater.from(m_context);
					view = inflater.inflate(R.layout.menu_list_content, null);
				}
				
				TextView txtMenu = (TextView) view.findViewById(R.id.menu_txt);
				txtMenu.setText(MENU_STR[groupPosition]);
				
				return view;
			}

			
			public boolean hasStableIds() {
				return true;
			}

			
			public boolean isChildSelectable(int groupPosition, int childPosition) {
				return true;
			}
	  }
	  
	  private int getSettiingResourceId(int group, int child) {
		  int[][] MENU_CHILD_IMAGE = {{R.drawable.setting_profile, R.drawable.setting_pin, R.drawable.setting_map, R.drawable.setting_unit}, 
		    		{R.drawable.setting_category, R.drawable.setting_placepin, R.drawable.setting_notification, R.drawable.setting_message, R.drawable.setting_introduce, R.drawable.setting_video},
		    		{0},
		    		{0, 0},
		    		{R.drawable.setting_logout},}; 
		  
		  return MENU_CHILD_IMAGE[group][child];
	  }
	  
	  
	  public void sendFeedback() {
	    	String mailId = "support@pinave.com";

	    	Intent emailIntent = new Intent(Intent.ACTION_SENDTO, Uri
					.fromParts("mailto", mailId, null));
			emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT,
					"Feedback");

			startActivity(Intent
					.createChooser(emailIntent, "Send email..."));
	    }
	  
	  public void logOut() {
//		  	UserDefault.init(MainActivity._main);
		  	
			UserLoginInfo.setUserName("");
			UserLoginInfo.setPassword("");
			UserLoginInfo.setLoginCode("");
			UserLoginInfo.setLoginId("");
			
			MainActivity._main.gotoLoginView();
			finish();
	  }
}
