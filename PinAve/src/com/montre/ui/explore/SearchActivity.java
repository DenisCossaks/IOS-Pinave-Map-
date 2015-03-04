package com.montre.ui.explore;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.xmlpull.v1.XmlPullParserException;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Canvas;
import android.graphics.Point;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.inputmethod.InputMethodManager;
import android.webkit.WebView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.OverlayItem;
import com.montre.data.CategoryInfo;
import com.montre.data.Items;
import com.montre.data.PinInfo;
import com.montre.data.SearchOption;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserLoginInfo;
import com.montre.etc.SearchOptionActivity;
import com.montre.httpclient.AsyncImageLoader_Async;
import com.montre.lib.ComputeDistance;
import com.montre.lib.Const;
import com.montre.pinave.R;
import com.montre.pindetail.PinDetailActivity;
import com.montre.ui.basic.BasicMapUI;
import com.montre.util.JsonParser;

public class SearchActivity extends BasicMapUI {
	
	public static ArrayList<CategoryInfo> 	arrSelected = new ArrayList<CategoryInfo>();
	private ArrayList<PinInfo> 			arrPins = new ArrayList<PinInfo>();
	
	public boolean m_bSearchList = false; 
	
	final int	PIN_SEARCH	= 0;
	final int	PIN_CATEGORY = 1;
	final int   PIN_MYPIN = 2;
	
	private int m_nType = PIN_CATEGORY;
	
	// variable
	private boolean m_bList = true;
	
	// List view
	private LinearLayout layoutList = null;
	private TextView	 tvLocationList = null;
	private ListView	 pinlistview = null;
	private ResultListAdapter 			adapter = null;
	
	private boolean m_bUserLocation = false;
	
	
	// Map view
	private FrameLayout	 layoutMap	= null;
	private MapView mapView;
	private MapController mapController;
	private View popView;
	private OverlayItem localItem;

	private LinearLayout layout_search = null;
	private EditText  editSearch = null;
	private TextView	 tvLocationMap = null;
	private TextView	 tvLocationSet = null;
	
	public String m_strSelPinId = "";
	
	public int		m_nCurPage = 0;
	public int 		limit 	= 15;
	public boolean 	m_bIsLoading = false;
	
	public int		m_nMaxPins = 0;
	
	public String 	m_strSearchText = "";
	
	
	final int	PROGRESS_DIALOG = 0;
	final int 	LOADING_OK	= 1;
	final int	LOADING_FAIL = 2;
	
	private Map<Integer, String> overlayMarkerMap;
	
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().addFlags( WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
						| WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
						| WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
						| WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
		
        setContentView(R.layout.search);
        
        initView();
        initData();
        
    }
    @Override
	protected boolean isRouteDisplayed() {
		// TODO Auto-generated method stub
		return false;
	}
  
    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
    	// TODO Auto-generated method stub
    	
    	if (hasFocus == true) { // open
    		
    		if (m_bSearchList) {
    			m_bSearchList = false;
    			
    			m_nType = PIN_CATEGORY;
    			
    			refresh();
    		}
    	}
    	super.onWindowFocusChanged(hasFocus);
    }
    public void initView()
    {
    	
    	// top
    	ImageView logo = (ImageView) findViewById(R.id.iv_search_top);
    	logo.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				// TODO Auto-generated method stub
				
				m_bSearchList = true;
				
				startActivity(new Intent(SearchActivity.this, SearchListActivity.class));
				
				return true;
			}
		});
    	
    	Button btnBack = (Button) findViewById(R.id.btn_left);
    	btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onBackPressed();
			}
		});
    	
    	final Button btnFliping = (Button) findViewById(R.id.btn_fliping);
    	btnFliping.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				m_bList = !m_bList;
				
				if (m_bList) {
					btnFliping.setBackgroundResource(R.drawable.btnmap);
					setListView();
				} else {
					btnFliping.setBackgroundResource(R.drawable.btnlist);
					setMapView();
				}
				
				
			}
		});
    	
    	//  List view
    	layoutList 		= (LinearLayout) findViewById(R.id.search_board_list);
    	tvLocationList 	= (TextView) findViewById(R.id.tv_search_location);
    	pinlistview 	= (ListView) findViewById(R.id.lv_search_pin);
    	
    	// map view
    	layoutMap = (FrameLayout) findViewById(R.id.search_board_map);
    	mapView = (MapView) findViewById(R.id.mapView);
    	
    	// search for map
    	layout_search = (LinearLayout) findViewById(R.id.map_search_bar);
    	layout_search.setVisibility(View.GONE);
    	
    	
    	Button btnSearchOpt = (Button) findViewById(R.id.btn_search_opt);
    	btnSearchOpt.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				startActivity(new Intent(SearchActivity.this, SearchOptionActivity.class));
			}
		});
    	
    	editSearch = (EditText) findViewById(R.id.edit_search);
    	
    	Button btnSearchCancel = (Button) findViewById(R.id.btn_search);
    	btnSearchCancel.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
				String searchText = editSearch.getText().toString();
				if (searchText.length() < 1) {
					Const.showToastMessage("Please input text for search pin.", SearchActivity.this);
					return;
				}
				
				if (SearchOption.getCategory().size() == 0) {
					Const.showToastMessage("Please select pin categories for search pin.", SearchActivity.this);
					return;
				}

				InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
				mgr.hideSoftInputFromWindow(editSearch.getWindowToken(), 0);

				m_nType = PIN_SEARCH;
				m_strSearchText = searchText;
				arrSelected = SearchOption.getCategory();
		
				refresh();
			}
		});
    	
    	
    	// location for map
    	Button btnLocation = (Button) findViewById(R.id.btn_search_location);
    	btnLocation.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
				showUserLocationPin();
				
			}
		});
    	
    	tvLocationMap = (TextView) findViewById(R.id.tv_search_location);
    	
    	
    	
    	// for bottome
    	Button btnSearch = (Button) findViewById(R.id.btn_search_search);
    	btnSearch.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				
				layout_search.setVisibility(View.VISIBLE);
				
			}
		});
    	
    	tvLocationSet = (TextView) findViewById(R.id.tv_location_set);

    }
    
    public void initData()
    {
    	
    	arrSelected.clear();
    	
    	Intent intent = getIntent();
		String type = intent.getStringExtra("OPTION");
		m_nMaxPins = intent.getIntExtra("pin_count", 0);
				
		if (type.equals("my_pins")) {
			m_nType = PIN_MYPIN;
			
		} else if (type.equals("all_category")) {
			m_nType = PIN_CATEGORY;
			
			for (int i = 0; i < Share.g_arrCategory.size(); i++) {
				CategoryInfo category = Share.g_arrCategory.get(i);
				category.setSelect(true);
				
				arrSelected.add(category);
			}
			
		} else if (type.equals("some_category")) {
			m_nType = PIN_CATEGORY;
			String categoryID = intent.getStringExtra("categoryID");
			
			for (int i = 0; i < Share.g_arrCategory.size(); i++) {
				CategoryInfo category = Share.g_arrCategory.get(i);
				
				if (categoryID.equals(category.getId())) {
					category.setSelect(true);
				} else {
					category.setSelect(false);
				}
				
				arrSelected.add(category);
			}
			
		} else if (type.equals("search")){
			m_nType = PIN_SEARCH;
			
			m_strSearchText = intent.getStringExtra("search_text");
			
			arrSelected = SearchOption.getCategory();
		}
		
		refresh();
    }
    
    public void refresh() {

    	m_bIsLoading = true;
    	
    	removeDialog(PROGRESS_DIALOG);
    	showDialog(PROGRESS_DIALOG);
    	
    }

	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case PROGRESS_DIALOG:
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
		if (m_nType == PIN_MYPIN) {
			arrPins = JsonParser.getUserPins(UserLoginInfo.getLoginId());
		} else if (m_nType == PIN_CATEGORY) {
			
			if (arrSelected.size() == 0) {
				arrPins.clear();
				return;
			}
			
			int page = m_nCurPage ++;

			
			ArrayList<PinInfo> pins = JsonParser.getPinsAroundUser(arrSelected, page, limit);
			if (pins != null) {
				for (int i = 0; i < pins.size(); i++) {
					arrPins.add(pins.get(i));
				}
			}
			
		} else {
			
			arrPins = JsonParser.getSearchPins(arrSelected, m_strSearchText);
		}
		
		} catch (Exception e) {
			// TODO: handle exception
			mHandler.sendEmptyMessage(LOADING_FAIL);
		}
		
		mHandler.sendEmptyMessage(LOADING_OK);
		
	}
	
	   Handler mHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				super.handleMessage(msg);

				dismissDialog(PROGRESS_DIALOG);
				m_bIsLoading = false;
				
				
				switch (msg.what) {
				case LOADING_OK:
					
					if (m_bList) {
						setListView();	
					} else {
						setMapView();
					}
					
					
					break;
				case LOADING_FAIL:
					Const.showMessage("Error", "Json parse error", SearchActivity.this);
					
					break;
				default:
					break;
				}
			}

		};
		
	public void setListView () {
		layoutList.setVisibility(View.VISIBLE);
		layoutMap.setVisibility(View.GONE);
		
		tvLocationList.setText(Share.getStandardUserLocationAddress());
		boundAdapter();
		
	}
	public void setMapView() {
		layoutList.setVisibility(View.GONE);
		layoutMap.setVisibility(View.VISIBLE);
		
		tvLocationMap.setText(Share.getStandardUserLocationAddress());
		initMap();
	}
	
	public void showUserLocationPin() {
	
//		if (Share.my_location != null) {
//			mapController.animateTo(new GeoPoint((int)(Share.my_location.getLatitude() * 1E6), (int)(Share.my_location.getLongitude() * 1E6)));
//		} else {
//			mapController.setCenter(new GeoPoint((int)(Share.defaultLat * 1E6), (int)(Share.defaultLng * 1E6)));
//		}
		
		m_bUserLocation = true;
		
		initMap();
		
	}
    public void boundAdapter() {
		adapter = new ResultListAdapter(SearchActivity.this, arrPins, pinlistview);
		pinlistview.setAdapter(adapter);
		adapter.notifyDataSetChanged();

		int pos = pinlistview.getSelectedItemPosition();
		System.out.println("pos = " + pos);
		pinlistview.setSelection(0 + (m_nCurPage-1) * limit);
	}
    
	
    
	public class ResultListAdapter extends BaseAdapter {
		private Context mContext = null;
		private ArrayList<PinInfo> itemList = null;
		
		private AsyncImageLoader_Async asyncImageLoader_Async = null;

		/**
		 * 
		 * @param mcontent
		 * @param itemList
		 */
		public ResultListAdapter(Context mContext, ArrayList<PinInfo> itemList,
				ListView listview) {
			this.mContext = mContext;
			this.itemList = itemList;
			asyncImageLoader_Async = new AsyncImageLoader_Async(mContext);
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
				view = inflater.inflate(R.layout.list_content_pin, null);
				cache = new ViewCache(view);
				view.setTag(cache);
			}
			cache = (ViewCache) view.getTag();

			final PinInfo item = itemList.get(index);
			if (item == null) 
				return view;
			
			
			String imageUrl = item.str_image;
//			System.out.println("image url = " + imageUrl);
			
			ImageView imageView = cache.getImageView();
			
			asyncImageLoader_Async.loadDrawable(imageUrl,imageView,80,60, item.str_id);
			
		
			TextView tvTitle = (TextView) view.findViewById(R.id.cell_title);
			tvTitle.setText(item.str_title);
			
			TextView tvAddress = (TextView) view.findViewById(R.id.cell_address);
			tvAddress.setText(item.str_address);
			
			TextView tvDistance = (TextView) view.findViewById(R.id.cell_distance);
			String latStr = item.str_lat;
			String lngStr = item.str_lng;
			
			try {
			    double my_lat = Const.TEST_LOCATION ? Share.defaultLat   : Share.my_location.getLatitude();
			    double my_lng = Const.TEST_LOCATION ? Share.defaultLng : Share.my_location.getLongitude();

				double miles = ComputeDistance.GetDistance(my_lat, my_lng,
						Double.parseDouble(latStr), Double
								.parseDouble(lngStr));
				
				if (Setting.getUnit() == Setting.UNIT_MILE) {
					tvDistance.setText("Distance: " + String.format("%.2f", miles) + " Mile");
				} else {
					tvDistance.setText("Distance: " + String.format("%.2f", miles/1.68) + " KM");
				}
			} catch (Exception e) {
				tvDistance.setText("Distance: ");
			}

			
			view.setOnClickListener(new OnClickListener() {

				@Override
				public void onClick(View v) {
					gotoDetail(item);
				}
			});
			
						
			if (m_nType != PIN_SEARCH) {
				if (!m_bIsLoading && index >= arrPins.size() - 1 && arrPins.size() < m_nMaxPins) {
					refresh();
				}
			}
			
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
						.findViewById(R.id.cell_image);
			}
			return imageView;
		}
	}
	
	public void gotoDetail(PinInfo info) {
		Intent intent = new Intent(SearchActivity.this, PinDetailActivity.class);

		intent.putExtra("pininfo", info);
				
		startActivity(intent);
//		goNextHistory("PinDetailActivity", intent);
	}
	
	OnClickListener viewClickListener = new OnClickListener() {
		@Override
		public void onClick(View v) {
				
			for (int i = 0; i < arrPins.size(); i++) {
				PinInfo info = arrPins.get(i);
				
				if (m_strSelPinId.equals(info.str_id)) {
					gotoDetail(info);
					break;
				}
			}
		}
    };
	
	 	public void initMap() {
	 		
	 		overlayMarkerMap = new HashMap<Integer, String>();
	 		
			LayoutInflater inflate = this.getLayoutInflater();
			popView = inflate.inflate(R.layout.map_pop_view, null);
			popView.setOnClickListener(viewClickListener);
			mapView.setBuiltInZoomControls(true);
			mapController = mapView.getController();
			
			mapView.getOverlays().clear();
		    mapView.removeAllViews();
		    
		    
		    double maxLat = 0, maxLng = 0, minLat = 0, minLng = 0;
		    
			if (Share.my_location != null || Const.TEST_LOCATION) {
			    double lat = Const.TEST_LOCATION ? Share.defaultLat : Share.my_location.getLatitude();
			    double lng = Const.TEST_LOCATION ? Share.defaultLng : Share.my_location.getLongitude();

				GeoPoint geoPoint = new GeoPoint((int) (lat * 1E6),
						(int) (lng * 1E6));
				localItem = new OverlayItem(geoPoint, "Current Location", "");
				Drawable drawable = this.getResources().getDrawable(
						R.drawable.mylocation);
				CustomItemizedOverlay citem = new CustomItemizedOverlay(drawable);
				citem.setOnFocusChangeListener(onFocusChangeListener);
				localItem.setMarker(drawable);
				citem.addOverlay(localItem);
			
				mapView.getOverlays().add(citem);

				overlayMarkerMap.put(citem.hashCode(), "-1");
				
				maxLat = minLat = lat;
				maxLng = minLng = lng;
			}
			
			
			double lat = 0;
			double lng = 0;


			for (int i = 0; i < arrPins.size(); i++) {

				PinInfo info = arrPins.get(i);
				
				lat = Double.parseDouble(info.str_lat);
				lng = Double.parseDouble(info.str_lng);

//				if (i == 0) {
//					minLat = maxLat = lat;
//					minLng = maxLng = lng;
//				}
				if (!m_bUserLocation) {
					if(maxLat < lat) maxLat = lat;
					if(minLat > lat) minLat = lat;
					if(maxLng < lng) maxLng = lng;
					if(minLng > lng) minLng = lng;
				}
				
				
				Drawable d = this.getResources().getDrawable(Const.getResouceId( Const.getCagegoryName(info.str_category_id)));

				CustomItemizedOverlay citem = new CustomItemizedOverlay(d);
				citem.setOnFocusChangeListener(onFocusChangeListener);
				
				
				GeoPoint t = new GeoPoint((int) (lat * 1E6), (int) (lng * 1E6));
				OverlayItem item_ = new OverlayItem(t, info.str_title, info.str_full_address);
				
				item_.hashCode();
				item_.setMarker(d);
				citem.addOverlay(item_);
				
				overlayMarkerMap.put(item_.hashCode(), info.str_id);
				
				mapView.getOverlays().add(citem);
			}
				
			
			
			mapController.zoomToSpan((int)((maxLat - minLat) * 1E6), (int)((maxLng - minLng) * 1E6));
			mapController.setCenter(new GeoPoint((int)((maxLat + minLat) * 1E6) / 2, (int)((maxLng + minLng) * 1E6) / 2));

			
			mapView.addView(popView, new MapView.LayoutParams(
					MapView.LayoutParams.WRAP_CONTENT,
					MapView.LayoutParams.WRAP_CONTENT, null,
					MapView.LayoutParams.BOTTOM_CENTER));
			popView.setVisibility(View.GONE);

			mapView.invalidate();

			m_bUserLocation = false;
		}
	 	
/*	 	
		public void showpop()
	 	{
			MapView.LayoutParams mapLayoutParams = (MapView.LayoutParams) popView.getLayoutParams();
			
	 		double lat1 = Double.parseDouble(m_SelPin.str_lat);
			double lng1 = Double.parseDouble(m_SelPin.str_lng);
			
			GeoPoint point = new GeoPoint((int) (lat1 * 1E6),(int) (lng1 * 1E6));
			
			mapLayoutParams.point = point;
			mapLayoutParams.y = -Const.offsety;
			mapLayoutParams.x = -Const.offsetx;
			
			TextView title = (TextView) popView.findViewById(R.id.map_bubbleTitle);
			title.setText(m_SelPin.str_title);
			
			TextView desc = (TextView) popView.findViewById(R.id.map_bubbleText);
			desc.setText(m_SelPin.str_full_address);
			
			mapView.updateViewLayout(popView, mapLayoutParams);
			
			popView.setVisibility(View.VISIBLE);
			
	 	}
*/		
		private final ItemizedOverlay.OnFocusChangeListener onFocusChangeListener = new ItemizedOverlay.OnFocusChangeListener() {
			@Override
			public void onFocusChanged(ItemizedOverlay overlay, OverlayItem newFocus) {
				if (popView != null) {
					popView.setVisibility(View.GONE);
				}
				if (newFocus != null) {
					newFocus.setMarker(null);
					
					MapView.LayoutParams mapLayoutParams = (MapView.LayoutParams) popView
							.getLayoutParams();
					
					mapLayoutParams.point = newFocus.getPoint();
					mapLayoutParams.y = -Const.offsety;
					mapLayoutParams.x = -Const.offsetx;
					
					TextView title = (TextView) popView
							.findViewById(R.id.map_bubbleTitle);
					title.setText(newFocus.getTitle());
					TextView desc = (TextView) popView
							.findViewById(R.id.map_bubbleText);
					if (newFocus.getSnippet() == null
							|| newFocus.getSnippet().length() == 0) {
						desc.setVisibility(View.GONE);
					} else {
						desc.setVisibility(View.VISIBLE);
						desc.setText(newFocus.getSnippet());
					}
					mapView.updateViewLayout(popView, mapLayoutParams);
					popView.setVisibility(View.VISIBLE);
					mapController.animateTo(newFocus.getPoint());
					
					
					if (overlayMarkerMap.containsKey(newFocus.hashCode())) {
						m_strSelPinId = overlayMarkerMap.get(newFocus.hashCode());
					}
					
				}

			}
		};

		class CustomItemizedOverlay extends ItemizedOverlay<OverlayItem> {
			private ArrayList<OverlayItem> items = new ArrayList<OverlayItem>();

			public ArrayList<OverlayItem> getItems() {
				return items;
			}

			public void setItems(ArrayList<OverlayItem> items) {
				this.items = items;
			}

			private Drawable marker = null;

			public CustomItemizedOverlay(Drawable defaultMarker) {
				super(defaultMarker);
				this.marker = defaultMarker;
			}

			public void addOverlay(OverlayItem item) {
				items.add(item);
				populate();
			}

			@Override
			protected OverlayItem createItem(int i) {
				return items.get(i);
			}
			@Override
			public int size() {
				return items.size();
			}

			@Override
			public void draw(Canvas canvas, MapView mapView, boolean shadow) {
				super.draw(canvas, mapView, shadow);
				boundCenterBottom(marker);
			}
		
		}

		@Override
		public void initViews() {
			// TODO Auto-generated method stub
			
		}
		@Override
		public void setListener() {
			// TODO Auto-generated method stub
			
		}
		
}