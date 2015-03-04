package com.montre.ui.explore;

import java.io.File;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;

import com.montre.data.CategoryInfo;
import com.montre.data.CustomLocation;
import com.montre.data.Items;
import com.montre.data.SearchOption;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.etc.SearchOptionActivity;
import com.montre.lib.Const;
import com.montre.lib.UserDefault;
import com.montre.pinave.R;
import com.montre.pinave.login.HomeActivity;
import com.montre.ui.basic.BasicUI;
import com.montre.util.JsonParser;


import android.app.Activity;
import android.app.AlarmManager;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Typeface;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.InputType;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;


public class ExploreActivity extends BasicUI {
    /** Called when the activity is first created. */
	
	
	final int PROGRESS_DIALOG_LOGIN  = 1;
	final int LOADING_OK			 = 0;
	final int NETWORK_FAIL			 = 1;
	
	
	private TextView tvLocation = null;
	private ListView lvCategory = null;
	private ResultListAdapter 	adapter = null;
	
	private EditText editSearch = null;
	private Button	 btnSearch = null;
	
//	public ProgressBar progress = null;
	public ProgressDialog progress = null;
	
	
	public ArrayList<CategoryInfo>  listCategory = new ArrayList<CategoryInfo>();
	
	public static int m_nAllPins = 0;
	public static int m_nMyPins = 0;
	
	public LocationManager locationManager;
		
	public static boolean m_bRefresh = false;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
		
		
        setContentView(R.layout.explore);
        
        getLocation();
        
        
        initViews();
        
    	m_bRefresh = true;
 
    }
    
    
    public void onBackPressed() {
/*    	
		if ( locationManager != null ) {
			//locationManager.removeGpsStatusListener(this);
			locationManager.removeUpdates(netLocationListener);
			locationManager.removeUpdates(gpsLocationListener);
			netLocationListener = null;
			gpsLocationListener = null;
			locationManager = null;
		}
*/		
		super.onBackPressed();
	}
    
    
    @Override
    protected void onResume() {
    	// TODO Auto-generated method stub
    	super.onResume();
    	
		refresh();
    	hideKeyboard();
    }
    
    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
    	// TODO Auto-generated method stub
    	
    	if (hasFocus == true) { // open
    	       
    		
    		

    	}
    	super.onWindowFocusChanged(hasFocus);
    }
    
	@Override
	public void initViews() {
		// TODO Auto-generated method stub
		Button btnNotify = (Button) findViewById(R.id.btn_explore_notification);
    	btnNotify.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				Intent intent = new Intent(ExploreActivity.this, NotificationActivity.class);
				
				startActivity(intent);
//				goNextHistory("NotificationActivity", intent);
				
			}
		});
    	
    	
    	Button btnLocation = (Button) findViewById(R.id.btn_explore_location);
    	btnLocation.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
				startActivity(new Intent(ExploreActivity.this, AddLocationActivity.class));
			}
		});
    	
    	tvLocation = (TextView) findViewById(R.id.tv_explore_location);
    	
    	Button btnSearchOpt = (Button) findViewById(R.id.btn_search_opt);
    	btnSearchOpt.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
				startActivity(new Intent(ExploreActivity.this, SearchOptionActivity.class));
				
			}
		});
    	
    	
    	editSearch = (EditText) findViewById(R.id.edit_search);
    	editSearch.setInputType(InputType.TYPE_NULL);
//    	editSearch.clearFocus();
//    	editSearch.setFocusable(false);
    	editSearch.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				mKeyboardHandler.sendEmptyMessage(0);
			}
		});
    	
    	
    	btnSearch = (Button) findViewById(R.id.btn_search);
    	btnSearch.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
				InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		    	mgr.hideSoftInputFromWindow(editSearch.getWindowToken(), InputMethodManager.HIDE_IMPLICIT_ONLY);

				
				if (SearchOption.getCategory().size() == 0) {
					Const.showToastMessage("Please select pin categories for search pin.", ExploreActivity.this);
					return;
				}
				
				String searchText = editSearch.getText().toString();
				if (searchText.length() == 0) {
					Const.showToastMessage("Please input text for search", ExploreActivity.this);
					return;
				}
				
				Intent intent = new Intent(ExploreActivity.this, SearchActivity.class);
				
				intent.putExtra("OPTION", "search");
				intent.putExtra("search_text", searchText);
						
//				startActivity(intent);
				goNextHistory("SearchActivity", intent);
				
			}
		});
    	
    	lvCategory = (ListView) findViewById(R.id.lv_explore_category);
	}

	private void hideKeyboard() {
/*
		InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
    	mgr.hideSoftInputFromWindow(editSearch.getWindowToken(), InputMethodManager.HIDE_IMPLICIT_ONLY);
//    	editSearch.setInputType(InputType.TYPE_NULL);
//    	editSearch.setFocusable(true);
    	editSearch.setInputType(InputType.TYPE_CLASS_TEXT);
*/
		
//    	 InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
//    	 imm.hideSoftInputFromWindow(editSearch.getWindowToken(), 0);
		
	}
	
	
	@Override
	public void initData() {
		// TODO Auto-generated method stub
//		progress = (ProgressBar) findViewById(R.id.progressBar1);
//    	progress.setVisibility(View.VISIBLE);
//    	
//    	Mythread myThread = new Mythread();
//		Thread thread = new Thread(myThread);
//		thread.start();
		
	}
	
	public void refresh(){
		
		System.out.println("refresh = " + m_bRefresh);
		
		if (m_bRefresh) {
			removeDialog(PROGRESS_DIALOG_LOGIN);
			showDialog(PROGRESS_DIALOG_LOGIN);
		} 
		else {
			m_bRefresh = true;
		}
	}
	
	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case PROGRESS_DIALOG_LOGIN:
			ProgressDialog dialog = new ProgressDialog(getParent());
			dialog.setCancelable(false);
			dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
			dialog.setMessage("Loading...");
			
			new Thread(new Runnable() {
				
				public void run() {
					loadingProcess();
				}
			}).start();
			return dialog;
		}
		return super.onCreateDialog(id);
	}
    
	private void loadingProcess() {
		try {
			getCategoryList();
			
			if(listCategory== null || listCategory.size() == 0)
			{
				mHandler.sendEmptyMessage(NETWORK_FAIL);
				return;
			}
			
			mHandler.sendEmptyMessage(LOADING_OK);
			
		} catch (Exception e) {	
			mHandler.sendEmptyMessage(NETWORK_FAIL);
		} 
	}
	
    public void boundAdapter(ArrayList<CategoryInfo> list) {
		
    	tvLocation.setText(Share.getCustomUserLocationAddress());
    	
    	adapter = new ResultListAdapter(ExploreActivity.this, list, lvCategory);
		lvCategory.setAdapter(adapter);
		adapter.notifyDataSetChanged();
    }
    
    
    public class Mythread implements Runnable {

		@Override
		public void run() {
			try {
				getCategoryList();
				
				if(listCategory== null || listCategory.size() == 0)
				{
					mHandler.sendEmptyMessage(NETWORK_FAIL);
					return;
				}
				
				mHandler.sendEmptyMessage(LOADING_OK);
				
			} catch (Exception e) {	
				mHandler.sendEmptyMessage(NETWORK_FAIL);
			} 
		}
	}
    
    
    Handler mHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			
//			progress.setVisibility(View.GONE);
			dismissDialog(PROGRESS_DIALOG_LOGIN);
			
			switch (msg.what) {
			case LOADING_OK:
				
				boundAdapter(listCategory);
				
				break;
			case NETWORK_FAIL:
				Const.showMessage(getParent());
			
				break;
				
			default:
				break;
			}
		}

	};
	
	
	Handler mKeyboardHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			
			if (editSearch == null)
				return;
		 
			editSearch.setInputType(InputType.TYPE_CLASS_TEXT);
			
			InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
			imm.hideSoftInputFromWindow(editSearch.getWindowToken(), 0);
			imm.toggleSoftInputFromWindow(editSearch.getApplicationWindowToken(), InputMethodManager.SHOW_FORCED, 0);
			
		}

	};
	
	private void getCategoryList() {
		
		if (Share.g_arrCategory == null) {
			Share.g_arrCategory = new ArrayList<CategoryInfo>();
			
			Share.g_arrCategory = JsonParser.getCategories();
			
//		    Comparator comparator = Collections.reverseOrder();
//		    Collections.sort(newArray, comparator);
			Collections.sort(Share.g_arrCategory, new Comparator<CategoryInfo>() {

				@Override
				public int compare(CategoryInfo lhs, CategoryInfo rhs) {
					
					return (lhs.strName.compareTo(rhs.strName));
				}
				
			});
		}

		
//		if (Share.g_arrCategory != null) {
			listCategory.clear();
			
//			boundAdapter(listCategory);
			
			
			for (int i = 0 ; i < Share.g_arrCategory.size() ; i ++) {
				CategoryInfo _category = Share.g_arrCategory.get(i);
				_category.pinNumber = 0;
				listCategory.add(_category);
			}
//			listCategory = Share.g_arrCategory;
			
			CategoryInfo category = new CategoryInfo();
			category.strName = "All Category";
			listCategory.add(0, category);
			
			category = new CategoryInfo();
			category.strName = "My Pins";
			listCategory.add(listCategory.size(), category);
//		}
		
		ArrayList<CategoryInfo> arryCount = JsonParser.getPinCount();
		m_nAllPins = 0;
		if (arryCount != null && arryCount.size() > 0) {
			for (int i = 0; i < arryCount.size(); i++) {
				CategoryInfo one = arryCount.get(i);
				
				String name = one.getName();
				int 	count = one.getPinCount();
				m_nAllPins += count;
				
				for (int j = 0; j < listCategory.size(); j++) {
					
					if (name.equals(listCategory.get(j).getName())) {
						listCategory.get(j).pinNumber = count;
						break;
					}
				}
				
			}
		}
		
		// users info 
		if (Share.g_arrUsers == null) {
			Share.g_arrUsers = JsonParser.getUsers();
			for (int i = 0 ; i < Share.g_arrUsers.size() ; i ++) {
				UserInfo info = Share.g_arrUsers.get(i);
				if (info.str_id.equals(UserLoginInfo.getLoginId())){
					Share.g_userInfo = new UserInfo();
					Share.g_userInfo = info;
					break;
				}
			}
		}

		
		m_nMyPins = 0;
		String sPinCount = JsonParser.getMyPinCount();
		if (sPinCount != null) {
			try {
				m_nMyPins = Integer.parseInt(sPinCount);
			} catch (Exception e) {
				m_nMyPins = 0;
			}
		}
		
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
			
			ivCategory.setBackgroundResource(item.getResouceId());
			
			String name = item.getName();
			String text = "";
			if (name.equalsIgnoreCase(CategoryInfo.All_Category)) {
				text = CategoryInfo.All_Category + " (" + m_nAllPins + ")";
			} else if (name.equalsIgnoreCase(CategoryInfo.My_Pins)) {
				text = CategoryInfo.My_Pins + " (" + m_nMyPins + ")";
			} else {
				text = item.getName() + " (" + item.getPinCount() + ")";	
			}
			title.setText(text);
			
			
			view.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					gotoMap(item);
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

	
	private void gotoMap(CategoryInfo selCategory)
	{
		String nameCategory = selCategory.getName();
		
/*		
		ArrayList<CategoryInfo> arrSelectedCategory = new ArrayList<CategoryInfo>();
		arrSelectedCategory.clear();
		
		
		if (nameCategory.equals(CategoryInfo.All_Category)) {
			for (int i = 0; i < Share.g_arrCategory.size(); i++) {
				CategoryInfo category = Share.g_arrCategory.get(i);
				category.setSelect(true);
				
				arrSelectedCategory.add(category);
			}
		} else if (nameCategory.equals(CategoryInfo.My_Pins)) {
			
		} else {
			for (int i = 0; i < Share.g_arrCategory.size(); i++) {
				CategoryInfo category = Share.g_arrCategory.get(i);
				
				if (selCategory.getId().equals(category.getId())) {
					category.setSelect(true);
				} else {
					category.setSelect(false);
				}
				
				arrSelectedCategory.add(category);
			}
		}
*/
		
		Intent intent = new Intent(ExploreActivity.this, SearchActivity.class);
		if (nameCategory.equals(CategoryInfo.My_Pins)) {
			intent.putExtra("OPTION", "my_pins");
			intent.putExtra("pin_count", m_nMyPins);
		} else if (nameCategory.equals(CategoryInfo.All_Category)) {
			intent.putExtra("OPTION", "all_category");
			intent.putExtra("pin_count", m_nAllPins);
		} else {
			intent.putExtra("OPTION", "some_category");
			intent.putExtra("categoryID", selCategory.getId());
			intent.putExtra("pin_count", selCategory.getPinCount());
		}
				
//		startActivity(intent);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_SINGLE_TOP);
		ExploreActivity.this.goNextHistory("SearchActivity", intent);
	}
	
	
	private void getLocation() {
//		Share.my_location.setLatitude(37.785834);
//		Share.my_location.setLongitude(-122.406417);
		
		LocationManager lmg = (LocationManager) getSystemService(LOCATION_SERVICE);
		
		Location loc = lmg.getLastKnownLocation(LocationManager.GPS_PROVIDER);
		if (loc != null) {
			Share.my_location = new CustomLocation(loc.getLatitude(), loc.getLongitude());
		} else {
			Share.my_location = null;
		}

		if (Share.my_location == null) {
			Location _loc = lmg
					.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
			lmg.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 10,
					10, locationListener);
			
			if (_loc != null) 
				Share.my_location = new CustomLocation(_loc.getLatitude(), _loc.getLongitude());
			
		} else {
			lmg.requestLocationUpdates(LocationManager.GPS_PROVIDER, 10,
					10, locationListener);
			
		}

	}
	private final LocationListener locationListener = new LocationListener() {

		@Override
		public void onStatusChanged(String provider, int status, Bundle extras) {
		}
		@Override
		public void onProviderEnabled(String provider) {
		}
		@Override
		public void onProviderDisabled(String provider) {
		}
		@Override
		public void onLocationChanged(Location location) {
			Share.my_location = new CustomLocation(location.getLatitude(), location.getLongitude());
		}
	};
	/*
	private LocationListener netLocationListener = new LocationListener() {

		
		public void onStatusChanged(String provider, int status, Bundle extras) {
			
			Log.e("LOCATION", "onStatusChanged");
		}

		
		public void onProviderEnabled(String provider) {
			
			Log.e("LOCATION", "onProviderEnabled");
		}

		
		public void onProviderDisabled(String provider) {
			
			Log.e("LOCATION", "onProviderDisabled");
		}

		
		public void onLocationChanged(Location location) {
			Log.e("LOCATION", "onLocationChanged");
			Share.my_location.set(location);
			
		}
	};
	
	private LocationListener gpsLocationListener = new LocationListener() {

		
		public void onStatusChanged(String provider, int status, Bundle extras) {
			
			Log.e("LOCATION", "onStatusChanged");
		}

		
		public void onProviderEnabled(String provider) {
			
			Log.e("LOCATION", "onProviderEnabled");
		}

		
		public void onProviderDisabled(String provider) {
			
			Log.e("LOCATION", "onProviderDisabled");
		}

		
		public void onLocationChanged(Location location) {
			Log.e("LOCATION", "onLocationChanged");
			Share.my_location.set(location);
			
		}
	};
	
	
	private boolean chkGpsService() {
		String gs = android.provider.Settings.Secure.getString(getContentResolver(), 
				android.provider.Settings.Secure.LOCATION_PROVIDERS_ALLOWED);
		
		Log.i("chkGpsService", "get GPS Service");
		
		if ( gs.indexOf("gps", 0) < 0 ) {
			AlertDialog.Builder gsDialog = new AlertDialog.Builder(this);
			gsDialog.setTitle("GPS Status Off");
			gsDialog.setMessage("Turn on GPS");
			gsDialog.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
				
				
				public void onClick(DialogInterface dialog, int which) {
					Intent intent = new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS);
					intent.addCategory(Intent.CATEGORY_DEFAULT);
					startActivity(intent);
				}
			}).create().show();
			return false;
		}
		else {
			return true;
		}
	}
	*/
}