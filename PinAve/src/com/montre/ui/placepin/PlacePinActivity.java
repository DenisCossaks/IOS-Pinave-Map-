package com.montre.ui.placepin;

import java.util.ArrayList;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.OverlayItem;
import com.montre.data.PinInfo;
import com.montre.data.Share;
import com.montre.lib.Const;
import com.montre.lib.PinLocation;
import com.montre.pinave.R;
import com.montre.ui.basic.BasicMapUI;
import com.montre.ui.basic.BasicUI;

import android.content.Context;
import android.content.Intent;
import android.graphics.Canvas;
import android.graphics.Point;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnLongClickListener;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;


public class PlacePinActivity extends BasicMapUI {

	private MapView mapView;
	private MapController mapController;
	private View popView;
	private OverlayItem localItem;

	private PinInfo dropPinInfo = new PinInfo();
	
	public double dropPinLat = 0.0, dropPinLng = 0.0;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		this.setContentView(R.layout.placepin);
		
		this.initViews();

//		this.setListener();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

		if (Const.TEST_LOCATION) {
			dropPinLat = Share.defaultLat;
			dropPinLng = Share.defaultLng;
		}
		else {
			if (Share.my_location == null) {
				dropPinLat = dropPinLng = 0.0;
			} else {
				dropPinLat = Share.my_location.getLatitude();
				dropPinLng = Share.my_location.getLongitude();
			}
		}

		this.initData();
	}
	
	@Override
	public void initViews() {
		// TODO Auto-generated method stub
		
		mapView = (MapView) findViewById(R.id.mapView);
		
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub
		initMap();	
	}

	OnClickListener viewClickListener = new OnClickListener() {
		@Override
		public void onClick(View v) {
			if (dropPinInfo == null) 
				return;
			
			Intent intent = new Intent(PlacePinActivity.this, ActivePinActivity.class);
			intent.putExtra("pininfo", dropPinInfo);
			startActivity(intent);
//			goNextHistory("ActivePinActivity", intent);
		}
    };
	
	 	public void initMap() {
	 		
			LayoutInflater inflate = this.getLayoutInflater();
			popView = inflate.inflate(R.layout.map_pop_view, null);
			popView.setOnClickListener(viewClickListener);
			mapView.setBuiltInZoomControls(true);
			mapController = mapView.getController();
			
			mapView.getOverlays().clear();
		    mapView.removeAllViews();
		    
	    	dropPinInfo = PinLocation.GetAddress(dropPinLat, dropPinLng);

		    double maxLat = 0, maxLng = 0, minLat = 0, minLng = 0;
		    
/*		    
			if (Share.my_location != null || Const.TEST_LOCATION) {
			    double lat = Const.TEST_LOCATION ? 37.785834 : Share.my_location.getLatitude();
			    double lng = Const.TEST_LOCATION ? -122.406417 : Share.my_location.getLongitude();

			    minLat = maxLat = lat;
				minLng = maxLng = lng;
				
				
				GeoPoint geoPoint = new GeoPoint((int) (lat * 1E6),
						(int) (lng * 1E6));
				localItem = new OverlayItem(geoPoint, "Current Location", "");
				Drawable drawable = this.getResources().getDrawable(
						R.drawable.gps);
				CustomItemizedOverlay citem = new CustomItemizedOverlay(drawable);
				citem.setOnFocusChangeListener(onFocusChangeListener);
				localItem.setMarker(drawable);
				citem.addOverlay(localItem);
			
				mapView.getOverlays().add(citem);
			}
*/			
			if (dropPinInfo != null) {
			    double lat = 0.0, lng = 0.0;
			    try {
			    	lat = Double.parseDouble(dropPinInfo.str_lat);
			    } catch (Exception e) {
			    	lat = 0.0;
				}
			    try {
			    	lng = Double.parseDouble(dropPinInfo.str_lng);
			    } catch (Exception e) {
			    	lng = 0.0;
				}

			    minLat = maxLat = lat;
				minLng = maxLng = lng;
				
				GeoPoint geoPoint = new GeoPoint((int) (lat * 1E6),
						(int) (lng * 1E6));
				localItem = new OverlayItem(geoPoint, "Customise you new pin", dropPinInfo.str_full_address);
				
				Drawable drawable = this.getResources().getDrawable(
						R.drawable.gps);
				CustomItemizedOverlay citem = new CustomItemizedOverlay(drawable);
				citem.setOnFocusChangeListener(onFocusChangeListener);
				localItem.setMarker(drawable);
				citem.addOverlay(localItem);
			
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

			private OverlayItem inDrag = null;
			private ImageView dragImage = null;
			private int xDragImageOffset = 0;
			private int yDragImageOffset = 0;
			private int xDragTouchOffset = 0;
			private int yDragTouchOffset = 0;
			private boolean bLongPress = false;
			
			
			public CustomItemizedOverlay(Drawable defaultMarker) {
				super(defaultMarker);
				this.marker = defaultMarker;
				
				dragImage = (ImageView) findViewById(R.id.drag);
				xDragImageOffset = dragImage.getDrawable().getIntrinsicWidth() / 2;
				yDragImageOffset = dragImage.getDrawable().getIntrinsicHeight();

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
			
//			final GestureDetector gestureDetector = new GestureDetector(new GestureDetector.SimpleOnGestureListener() {
//			    public void onLongPress(MotionEvent e) {
//			        Log.e("", "Longpress detected");
//			    }
//			});
			final Handler handler = new Handler(); 
			Runnable mLongPressed = new Runnable() { 
			    public void run() { 
			        System.out.println("Long press!");
			        
			        bLongPress = true;
			    }   
			};
			
			@Override
			public boolean onTouchEvent(MotionEvent event, MapView mapView) {
				final int action = event.getAction();
				final int x = (int) event.getX();
				final int y = (int) event.getY();
				boolean result = false;

				if (action == MotionEvent.ACTION_DOWN) {
					
					handler.postDelayed(mLongPressed, 1000);
					
					if (bLongPress == true) {
						for (OverlayItem item : items) {
							Point p = new Point(0, 0);

							mapView.getProjection().toPixels(item.getPoint(), p);

							if (hitTest(item, marker, x - p.x, y - p.y)) {
								result = true;
								inDrag = item;
								items.remove(inDrag);
								populate();

								xDragTouchOffset = 0;
								yDragTouchOffset = 0;

								setDragImagePosition(p.x, p.y);
								dragImage.setVisibility(View.VISIBLE);

								xDragTouchOffset = x - p.x;
								yDragTouchOffset = y - p.y;

								break;
							}
						}
					}
				} else if (action == MotionEvent.ACTION_MOVE && inDrag != null) {
					setDragImagePosition(x, y);
					result = true;
				} else if (action == MotionEvent.ACTION_UP && inDrag != null) {
					bLongPress = false;
					
					dragImage.setVisibility(View.GONE);

					GeoPoint pt = mapView.getProjection().fromPixels(
							x - xDragTouchOffset, y - yDragTouchOffset);

					String title = inDrag.getTitle();
					OverlayItem toDrop = new OverlayItem(pt, title,
							inDrag.getSnippet());

					items.add(toDrop);
					populate();

					dropPinLat = pt.getLatitudeE6() / 1E6;
					dropPinLng = pt.getLongitudeE6() / 1E6;

					initMap();
					
//					ArrayList<Double> passing = new ArrayList<Double>();
//					passing.add(lat);
//					passing.add(lon);
//
//					Context context = getApplicationContext();
//					ReverseGeocodeLookupTask task = new ReverseGeocodeLookupTask();
//					task.applicationContext = context;
//					task.activityContext = rescue.this;
//					task.execute(passing);

					// CenterLocatio(pt);

					inDrag = null;
					result = true;
				}

				return (result || super.onTouchEvent(event, mapView));
			}
			
			private void setDragImagePosition(int x, int y) {
				RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams) dragImage
						.getLayoutParams();

				lp.setMargins(x - xDragImageOffset - xDragTouchOffset, y
						- yDragImageOffset - yDragTouchOffset, 0, 0);
				dragImage.setLayoutParams(lp);
			}
		}

		@Override
		public void setListener() {
			// TODO Auto-generated method stub
			
		}
	

}
