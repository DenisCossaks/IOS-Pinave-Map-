package com.montre.ui.router;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;
import com.google.android.maps.Projection;
import com.montre.data.CustomLocation;
import com.montre.data.PinInfo;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserLoginInfo;
import com.montre.data.Utils;
import com.montre.lib.Const;
import com.montre.navigation.RouterViewGroup;
import com.montre.pinave.R;
import com.montre.pindetail.PinDetailActivity;
import com.montre.ui.basic.BasicMapUI;
import com.montre.ui.basic.BasicUI;
import com.montre.ui.explore.SearchActivity;
import com.montre.util.JsonParser;

import android.content.Context;
import android.content.Intent;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Point;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.View.OnKeyListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.SeekBar.OnSeekBarChangeListener;


public class RouterActivity extends BasicMapUI {

	private MapView mapView;
	private MapController mapController;
	private View popView;
	private OverlayItem localItem;
	private Projection projection;
	
	
	private TextView	tvLocation = null;
	private TextView	tvDistance = null;
	private TextView	tvSetting = null;
	
	private Button		btnEdit = null;
	
	private LinearLayout layoutController = null;
	private EditText	 editStart = null;
	private EditText	 editEnd = null;
	private ImageView	 imgCar = null;
	private ImageView	 imgBus = null;
	private ImageView	 imgWalk = null;
	
	
	final public int 	MODE_CAR	= 0;
	final public int	MODE_BUS 	= 1;
	final public int	MODE_WALK	= 2;
	
	final public String CURRENT_LOCATION = "Current Location";
	
	
	private ArrayList<PinInfo> 			arrPins = new ArrayList<PinInfo>();
	private PinInfo		startPin = null;
	private PinInfo		endPin = null;
	

	private Map<Integer, String> overlayMarkerMap;
	public String m_strSelPinId = "";
	
	private boolean m_bShowMapControl = false;
	private int		m_nRouteMode = MODE_CAR;
	
	
    public CustomLocation startPoint = null;
    public CustomLocation endPoint = null;
    public String 	m_strDuration = "";
    public String 	m_strDistance = "";
    ArrayList<CustomLocation> m_geoLines = new ArrayList<CustomLocation>();
    
    
    private boolean m_bShowUserLocation = true;
    
    
	
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		this.setContentView(R.layout.router);
		
		this.initViews();
	}
	
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();
		
		this.initData();

	}
	
	public void onBackPressed() {
		if (m_bShowMapControl) {
			showMapController(false);
		}
		else {
			finish();
		}
			
	}

	@Override
	public void initViews() {
		// TODO Auto-generated method stub
		
		mapView = (MapView) findViewById(R.id.mapView);
		
		ImageView imgLocation = (ImageView) findViewById(R.id.iv_location);
		imgLocation.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				m_bShowUserLocation = true;
				initMap();
				
//				if (Share.my_location != null) {
//					mapController.animateTo(new GeoPoint((int)(Share.my_location.getLatitude() * 1E6), (int)(Share.my_location.getLongitude() * 1E6)));
//				} else {
//					mapController.setCenter(new GeoPoint((int)(37.5569 * 1E6), (int)(-122.3006 * 1E6)));
//				}
			}
		});
		
		
		tvLocation = (TextView) findViewById(R.id.tv_location);
		tvLocation.setText(Share.getStandardUserLocationAddress());
		tvDistance = (TextView) findViewById(R.id.tv_distance);
		tvDistance.setVisibility(View.GONE);
		tvSetting = (TextView) findViewById(R.id.tv_setting);
		tvSetting.setVisibility(View.GONE);
		
		btnEdit = (Button) findViewById(R.id.btn_right);
		btnEdit.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				onEdit();
			}
		});
		
		
		layoutController = (LinearLayout) findViewById(R.id.layout_controller);
		if (!m_bShowMapControl) {
			layoutController.setVisibility(View.GONE);
		} else {
			layoutController.setVisibility(View.VISIBLE);
		}
		
		editStart = (EditText) findViewById(R.id.et_start);
		editStart.setText(CURRENT_LOCATION);
		editStart.setTextColor(Color.BLUE);
		editStart.addTextChangedListener(new TextWatcher() {
			
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				// TODO Auto-generated method stub
				
				String str = s.toString();
				System.out.println(str + " before : " + start + " count : " + count);
				if (str.equals(CURRENT_LOCATION)) {
					editStart.setTextColor(Color.BLUE);
				} else {
					editStart.setTextColor(Color.BLACK);
				}
			}
			
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void afterTextChanged(Editable s) {
				// TODO Auto-generated method stub
				startPoint = null;
			}
		});
		
		editEnd = (EditText) findViewById(R.id.et_end);
		editEnd.addTextChangedListener(new TextWatcher() {
			
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				// TODO Auto-generated method stub
				if (s.toString().equals(CURRENT_LOCATION)) {
					editEnd.setTextColor(Color.BLUE);
				} else {
					editEnd.setTextColor(Color.BLACK);
				}

			}
			
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void afterTextChanged(Editable s) {
				// TODO Auto-generated method stub
				endPoint = null;
			}
		});
		
		ImageView ivReverse = (ImageView) findViewById(R.id.iv_reverse);
		ivReverse.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				convertDirecter();
			}
		});
		
		
		imgCar = (ImageView) findViewById(R.id.item_car);
		imgCar.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				imgCar.setBackgroundResource(R.drawable.item_1_sel);
				imgBus.setBackgroundResource(R.drawable.item_2);
				imgWalk.setBackgroundResource(R.drawable.item_3);
				
				m_nRouteMode = MODE_CAR;
			}
		});
		
		imgBus = (ImageView) findViewById(R.id.item_bus);
		imgBus.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				imgCar.setBackgroundResource(R.drawable.item_1);
				imgBus.setBackgroundResource(R.drawable.item_2_sel);
				imgWalk.setBackgroundResource(R.drawable.item_3);
				
				m_nRouteMode = MODE_BUS;
			}
		});
		imgWalk = (ImageView) findViewById(R.id.item_walking);
		imgWalk.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				imgCar.setBackgroundResource(R.drawable.item_1);
				imgBus.setBackgroundResource(R.drawable.item_2);
				imgWalk.setBackgroundResource(R.drawable.item_3_sel);
				
				m_nRouteMode = MODE_WALK;
			}
		});
		
		imgCar.setBackgroundResource(R.drawable.item_1);
		imgBus.setBackgroundResource(R.drawable.item_2);
		imgWalk.setBackgroundResource(R.drawable.item_3);
		if (m_nRouteMode == MODE_CAR) {
			imgCar.setBackgroundResource(R.drawable.item_1_sel);
		} else if (m_nRouteMode == MODE_BUS) {
			imgBus.setBackgroundResource(R.drawable.item_2_sel);
		} else if (m_nRouteMode == MODE_WALK) {
			imgWalk.setBackgroundResource(R.drawable.item_3_sel);
		}
		
		Button btnRoute = (Button) findViewById(R.id.btn_route);
		btnRoute.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onRoute();
			}
		});
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub
		
		String startName = getIntent().getStringExtra("start_name");
		if (startName != null && !startName.equals("")) {
			editStart.setText(startName);
			editStart.setTextColor(Color.BLACK);
			
			startPoint = (CustomLocation) getIntent().getSerializableExtra("start_location");
			
			editStart.setText(CURRENT_LOCATION);
			editStart.setTextColor(Color.BLUE);
			endPoint = null;
			
			showMapController(true);
		} else {
			startPoint = null;
			editStart.setText(CURRENT_LOCATION);
			editStart.setTextColor(Color.BLUE);
		}

		String endName = getIntent().getStringExtra("end_name");
		if (endName != null && !endName.equals("")) {
			editEnd.setText(endName);
			editEnd.setTextColor(Color.BLACK);

			endPoint = new CustomLocation();
			endPoint = (CustomLocation) getIntent().getSerializableExtra("end_location");
			
			showMapController(true);
		} else {
			endPoint = null;
			editEnd.setText("");
		}
		
		initMap();
	}

	@Override
	public void setListener() {
		// TODO Auto-generated method stub
		
	}
	
	public boolean onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);
		
		System.out.println("menu access=================");
		
		menu.add(1, 100, 1, "Directions");
		menu.add(1, 101, 2, "My Location");
		
		return true;
	}

/*	
	public boolean onOptionsItemSelected(MenuItem item) {
		super.onOptionsItemSelected(item);
		
		switch (item.getItemId()) {
		case 100: // direction
//			markSample = true;
//			mapView.invalidate();
			if (m_bShowMapControl) {
				showMapController(true);
			}
			else {
				convertDirecter();
			}
			
			
			break;
		case 101:
			if (Share.my_location != null) {
				mapController.animateTo(new GeoPoint((int)(Share.my_location.getLatitude() * 1E6), (int)(Share.my_location.getLongitude() * 1E6)));
			} else {
				mapController.setCenter(new GeoPoint((int)(37.5569 * 1E6), (int)(-122.3006 * 1E6)));
			}
			break;
				
		}
		return true;
	}
*/	
	public void showMapController(boolean bShow) {
		layoutController.setVisibility(bShow ? View.VISIBLE : View.GONE);
		
		m_bShowMapControl = bShow;
	}
	
	public void convertDirecter() {
		String strStart = editStart.getText().toString();
		String strEnd = editEnd.getText().toString();
		editStart.setText(strEnd);
		editEnd.setText(strStart);
		
		CustomLocation temp = startPoint;
		startPoint = endPoint;
		endPoint = temp;
		
		if (editStart.getText().toString().equals(CURRENT_LOCATION)) {
			editStart.setTextColor(Color.BLUE);
		} else {
			editStart.setTextColor(Color.BLACK);
		}
		
		if (editEnd.getText().toString().equals(CURRENT_LOCATION)) {
			editEnd.setTextColor(Color.BLUE);
		} else {
			editEnd.setTextColor(Color.BLACK);
		}

	}
	

	
	public void onEdit() {
		if (m_bShowMapControl) {
			showMapController(false);
		} else {
			showMapController(true);
		}
	}
	
	
	public void onRoute() {
		
		if (editStart.getText().toString().length() < 1) {
			Const.showToastMessage("Please input start address", this);
			return;
		}
		if (editEnd.getText().toString().length() < 1) {
			Const.showToastMessage("Please input end address", this);
			return;
		}
		
		hideKeybord(editEnd);

		showMapController(false);
		
		
		if (editStart.getText().toString().equalsIgnoreCase(CURRENT_LOCATION)) {
			if (Const.TEST_LOCATION) {
				startPoint = new CustomLocation(Share.defaultLat, Share.defaultLng);
			}
			else if (Share.my_location != null) { 
				startPoint = new CustomLocation(Share.my_location.getLatitude(),
						 Share.my_location.getLongitude());
			}
			else {
				startPoint = null;
			}
		} else {
			if (startPoint == null) {
				String address = editStart.getText().toString();
				startPoint = Share.getCoordinateByAddress(address);
			}
		}
		
		if (startPoint == null) {
			Const.showToastMessage("start address parse error", this);
			return;
		}
		
		
		if (editEnd.getText().toString().equalsIgnoreCase(CURRENT_LOCATION)) {
			if (Const.TEST_LOCATION) {
				endPoint = new CustomLocation(Share.defaultLat, Share.defaultLng);
			}
			else if (Share.my_location != null) {
				endPoint = new CustomLocation( Share.my_location.getLatitude(),  Share.my_location.getLongitude());
			} else {
				endPoint = null;
			}
		} else {
			if (endPoint == null) {
				String address = editEnd.getText().toString();
				endPoint = Share.getCoordinateByAddress(address);
			}
		}
		
		if (endPoint == null) {
			Const.showToastMessage("end address parse error", this);
			return;
		}
		
		
		Hashtable<String, Object> result = JsonParser.getGoogleRoute(startPoint, endPoint, m_nRouteMode);
		if (result == null) {
			Const.showToastMessage("There is no route", this);
			return;
		}
		
		m_geoLines.clear();
		m_geoLines = (ArrayList<CustomLocation>) result.get("lines");
		
		// pins around route
		getPins();
		
		
		m_strDuration = (String) result.get("duration");
		
		String sDistance = (String) result.get("distance");
		int distance = 0;
		try {
			distance = Integer.parseInt(sDistance);
		} catch (Exception e) {
			distance = 0;
		}
		
		if (Setting.getUnit() == Setting.UNIT_KM) {
			m_strDistance = String.format("%d KM", (int) (distance / 1000));
		} else {
			m_strDistance = String.format("%d Mile", (int) (distance / 1.6 / 1000));
		}
		
		startPin = (PinInfo) result.get("start_point");
		endPin = (PinInfo) result.get("end_point");
		
		m_bShowUserLocation = false;
		initMap();
		

	}
	public void hideKeybord(View view) {
			InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
			mgr.hideSoftInputFromWindow(view.getWindowToken(), 0);
	}
	
	private void getPins(){

		 arrPins.clear();
		
		 HttpClient httpclient = new DefaultHttpClient();
		 String url = Utils.postGetPinsRouterUrl();
		 HttpPost httppost = new HttpPost(url);

		 try {
		 // Add your data
		 List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
		 
		 nameValuePairs.add(new BasicNameValuePair("search", 	""));
		 
		 for (int i = 0 ; i < Share.g_arrCategory.size() ; i ++) {
			 String key = String.format("category[%d]", i);
			 String id = Share.g_arrCategory.get(i).strId;
			 
			 nameValuePairs.add(new BasicNameValuePair(key, id));
		 }
		 
		 for (int i = 0 ; i < m_geoLines.size(); i ++) {
			 String key = String.format("latlng[%d]", i);
			 String val = m_geoLines.get(i).getLatitude() + "," + m_geoLines.get(i).getLongitude();
			 
			 nameValuePairs.add(new BasicNameValuePair(key, val));
		 }
		 
		 int radius = 1;
		 nameValuePairs.add(new BasicNameValuePair("radius", "" + radius));
		 
		 
		 
		 httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

		 // Execute HTTP Post Request
		 HttpResponse response = httpclient.execute(httppost);
		 String responseBody = EntityUtils.toString(response.getEntity());
		 
		 System.out.println("Router = " + responseBody);
		 
		 arrPins = JsonParser.getPinAroundRoute(responseBody);
		 
		 } catch (Exception e) {
			 e.printStackTrace();
			 
		 }
	}
	//////////////////////////////////////
	
	public void gotoDetail(PinInfo info) {
		Intent intent = new Intent(RouterActivity.this, PinDetailActivity.class);

		intent.putExtra("pininfo", info);
				
		startActivity(intent);
//		goNextHistory("PinDetailActivity", intent);
		
	}
	
	OnClickListener viewClickListener = new OnClickListener() {
		@Override
		public void onClick(View v) {
				
			if (arrPins == null)
				return;
			
			for (int i = 0; i < arrPins.size(); i++) {
				PinInfo info = arrPins.get(i);
				
				if (m_strSelPinId.equals(info.str_id)) {
					gotoDetail(info);
					break;
				}
			}
		}
    };
    
    public void drawroute() {

		projection = mapView.getProjection();
		mapView.getOverlays().clear();
		mapView.getOverlays().add(new MyOverlay());
	}
    
	@Override
	public void initMap() {
		
		overlayMarkerMap = new HashMap<Integer, String>();
		
		LayoutInflater inflate = this.getLayoutInflater();
		popView = inflate.inflate(R.layout.map_pop_view, null);
		popView.setOnClickListener(viewClickListener);
		mapView.setBuiltInZoomControls(true);
		mapController = mapView.getController();
		
		mapView.getOverlays().clear();
	    mapView.removeAllViews();
	    
	    drawroute();
	    
	    double maxLat = 0, maxLng = 0, minLat = 0, minLng = 0;
	    
		double lat = 0;
		double lng = 0;

		boolean bfirst = false;
		
		{ //start point
			if (startPin != null) {
				lat = Double.parseDouble(startPin.str_lat);
				lng = Double.parseDouble(startPin.str_lng);
				
				if (!bfirst) {
					minLat = maxLat = lat;
					minLng = maxLng = lng;
					bfirst = true;
				}
				
				if(maxLat < lat) maxLat = lat;
				if(minLat > lat) minLat = lat;
				if(maxLng < lng) maxLng = lng;
				if(minLng > lng) minLng = lng;
				
				GeoPoint geoPoint = new GeoPoint((int) (lat * 1E6), (int) (lng * 1E6));
				localItem = new OverlayItem(geoPoint, "Start point", startPin.str_full_address);
				Drawable drawable = this.getResources().getDrawable(R.drawable.pin_route);
				CustomItemizedOverlay citem = new CustomItemizedOverlay(drawable);
				citem.setOnFocusChangeListener(onFocusChangeListener);
				localItem.setMarker(drawable);
				citem.addOverlay(localItem);
			
				mapView.getOverlays().add(citem);

				overlayMarkerMap.put(localItem.hashCode(), "-1");
			}
			
			if (endPin != null) {
				lat = Double.parseDouble(endPin.str_lat);
				lng = Double.parseDouble(endPin.str_lng);
				
				if (!bfirst) {
					minLat = maxLat = lat;
					minLng = maxLng = lng;
					bfirst = true;
				}

				if(maxLat < lat) maxLat = lat;
				if(minLat > lat) minLat = lat;
				if(maxLng < lng) maxLng = lng;
				if(minLng > lng) minLng = lng;
				
				GeoPoint geoPoint = new GeoPoint((int) (lat * 1E6), (int) (lng * 1E6));
				localItem = new OverlayItem(geoPoint, "End point", endPin.str_full_address);
				Drawable drawable = this.getResources().getDrawable(R.drawable.pin_route);
				CustomItemizedOverlay citem = new CustomItemizedOverlay(drawable);
				citem.setOnFocusChangeListener(onFocusChangeListener);
				localItem.setMarker(drawable);
				citem.addOverlay(localItem);
			
				mapView.getOverlays().add(citem);

				overlayMarkerMap.put(localItem.hashCode(), "-1");
			}
			
		}
		
		Drawable d = this.getResources().getDrawable(R.drawable.gps);

		CustomItemizedOverlay citem = new CustomItemizedOverlay(d);
		citem.setOnFocusChangeListener(onFocusChangeListener);
		
		if (arrPins != null) {
			for (int i = 0; i < arrPins.size(); i++) {

				PinInfo info = arrPins.get(i);
				
				lat = Double.parseDouble(info.str_lat);
				lng = Double.parseDouble(info.str_lng);

				if (!bfirst) {
					minLat = maxLat = lat;
					minLng = maxLng = lng;
					bfirst = true;
				}
				if(maxLat < lat) maxLat = lat;
				if(minLat > lat) minLat = lat;
				if(maxLng < lng) maxLng = lng;
				if(minLng > lng) minLng = lng;
				
				GeoPoint t = new GeoPoint((int) (lat * 1E6), (int) (lng * 1E6));
				OverlayItem item_ = new OverlayItem(t, info.str_title, info.str_full_address);
				
				item_.hashCode();
				item_.setMarker(d);
				citem.addOverlay(item_);
				
				overlayMarkerMap.put(item_.hashCode(), info.str_id);
			}
			if (arrPins.size() > 0)
				mapView.getOverlays().add(citem);
		}
		
		
		// userLocation
		if (Share.my_location != null || Const.TEST_LOCATION) {
		    lat = Const.TEST_LOCATION ? Share.defaultLat : Share.my_location.getLatitude();
		    lng = Const.TEST_LOCATION ? Share.defaultLng : Share.my_location.getLongitude();

		    if (m_bShowUserLocation) {
			    maxLat = minLat = lat;
			    maxLng = minLng = lng;
			    
			    m_bShowUserLocation = false;
		    }
		    
		    
			GeoPoint geoPoint = new GeoPoint((int) (lat * 1E6),
					(int) (lng * 1E6));
			localItem = new OverlayItem(geoPoint, "Current Location", "");
			Drawable drawable = this.getResources().getDrawable(
					R.drawable.mylocation);
			citem = new CustomItemizedOverlay(drawable);
			citem.setOnFocusChangeListener(onFocusChangeListener);
			localItem.setMarker(drawable);
			citem.addOverlay(localItem);
		
			mapView.getOverlays().add(citem);

			overlayMarkerMap.put(localItem.hashCode(), "-1");
		}
		
		
		mapController.zoomToSpan((int)((maxLat - minLat) * 1E6), (int)((maxLng - minLng) * 1E6));
		mapController.setCenter(new GeoPoint((int)((maxLat + minLat) * 1E6) / 2, (int)((maxLng + minLng) * 1E6) / 2));

		
		mapView.addView(popView, new MapView.LayoutParams(
				MapView.LayoutParams.WRAP_CONTENT,
				MapView.LayoutParams.WRAP_CONTENT, null,
				MapView.LayoutParams.BOTTOM_CENTER));
		popView.setVisibility(View.GONE);

		mapView.invalidate();

	}
 	
	
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
	
	class MyOverlay extends Overlay {

		public MyOverlay() {

		}

		public void draw(Canvas canvas, MapView mapv, boolean shadow) {
			super.draw(canvas, mapv, shadow);

			Paint mPaint = new Paint();
			mPaint.setDither(true);
			mPaint.setColor(Color.argb(200, 110, 160, 255));
			mPaint.setStyle(Paint.Style.FILL_AND_STROKE);
			mPaint.setStrokeJoin(Paint.Join.ROUND);
			mPaint.setStrokeCap(Paint.Cap.ROUND);
			mPaint.setStrokeWidth(4);
			Point p1 = new Point();
			Point p2 = new Point();

			Path path = new Path();
			for (int i = 0; i < m_geoLines.size() - 1; i++) {
				CustomLocation gP1 = m_geoLines.get(i);
				CustomLocation gP2 = m_geoLines.get(i + 1);
				
				projection.toPixels(new GeoPoint((int)(gP1.getLatitude() * 1E6), (int)(gP1.getLongitude() * 1E6)), p1);
				projection.toPixels(new GeoPoint((int)(gP2.getLatitude() * 1E6), (int)(gP2.getLongitude() * 1E6)), p2);
				
//				System.out.println("x = " + p1.x + " y = " + p2.y);
				
				path.moveTo(p2.x, p2.y);
				path.lineTo(p1.x, p1.y);
				canvas.drawPath(path, mPaint);
			}

		}
	}

}
