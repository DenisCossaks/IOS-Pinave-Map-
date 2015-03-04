package com.montre.ui.placepin;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.ByteArrayBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.OverlayItem;
import com.montre.data.CategoryInfo;
import com.montre.data.PinInfo;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserLoginInfo;
import com.montre.data.Utils;
import com.montre.lib.Const;
import com.montre.lib.PinLocation;
import com.montre.navigation.RouterViewGroup;
import com.montre.pinave.R;
import com.montre.pindetail.ReviewActivity;
import com.montre.ui.basic.BasicMapUI;
import com.montre.ui.basic.BasicUI;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Point;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Parcelable;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnLongClickListener;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

public class ActivePinActivity extends BasicMapUI {

	private MapView mapView;
	private MapController mapController;
	private View popView;
	private OverlayItem localItem;

	private EditText etTitle = null;
	private EditText etDescription = null;

	private ImageView ivPic = null;
	private TextView tvfullAddress = null;
	private TextView tvAddress = null;
	private TextView tvCity = null;
	private TextView tvState = null;
	private TextView tvCountry = null;
	private LinearLayout layout_address = null;

	private ImageView ivCategoryIcon = null;
	private TextView tvCategoryText = null;
	private TextView tvScheduleText = null;

	private PinInfo pinInfo = new PinInfo();

	boolean m_bShowAddress = false;

	public Bitmap 	m_bmp;
	
	
	// structure
	public static int m_nCategoryId = -1;
	public static int m_nSimple = -1;
	public static int m_nDays = 1;
	public static String m_strFrequency = "One-Time Event";
	public static int m_nRepet = 1;
	public static int m_nEvery = 1;

	public static int m_nStartYear, m_nStartMonth, m_nStartDay, m_nStartHour,
			m_nStartMin;
	public static int m_nEndYear, m_nEndMonth, m_nEndDay, m_nEndHour,
			m_nEndMin;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		this.setContentView(R.layout.activepin);

		this.initViews();
		// this.initData();
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		super.onResume();

		this.initData();

	}

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub

		if (m_bShowAddress) {
			layout_address.setVisibility(View.GONE);
			m_bShowAddress = false;
		} else {
			//super.onBackPressed();
			finish();
		}
	}

	@Override
	public void initViews() {
		// TODO Auto-generated method stub

		Button btnBack = (Button) findViewById(R.id.btn_left);
    	btnBack.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onBackPressed();
			}
		});
    	
		Button btnActive = (Button) findViewById(R.id.btn_right);
		btnActive.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onActivePin();
			}
		});

		etTitle = (EditText) findViewById(R.id.edit_title);
		etDescription = (EditText) findViewById(R.id.edit_descript);

		ivPic = (ImageView) findViewById(R.id.img_pic);
		ivPic.setImageResource(R.drawable.upload_back);
		ivPic.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				setImageFromGalery();
			}
		});

		mapView = (MapView) findViewById(R.id.mapView);

		layout_address = (LinearLayout) findViewById(R.id.layout_address);
		tvAddress = (EditText) findViewById(R.id.edit_address);
		tvCity = (EditText) findViewById(R.id.edit_city);
		tvState = (EditText) findViewById(R.id.edit_state);
		tvCountry = (EditText) findViewById(R.id.edit_country);
		tvfullAddress = (TextView) findViewById(R.id.tv_address);
		Button btnDone = (Button) findViewById(R.id.btn_done);
		btnDone.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onAddressDone();
			}
		});

		LinearLayout layoutCategory = (LinearLayout) findViewById(R.id.layout_category);
		layoutCategory.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				gotoCatogory(m_nCategoryId);
			}
		});
		ivCategoryIcon = (ImageView) findViewById(R.id.iv_category_icon);
		tvCategoryText = (TextView) findViewById(R.id.tv_category_text);
		LinearLayout layoutSchedule = (LinearLayout) findViewById(R.id.layout_schedule);
		layoutSchedule.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				gotoSchedule();
			}
		});
		tvScheduleText = (TextView) findViewById(R.id.tv_schedule_text);

		pinInfo = (PinInfo) getIntent().getSerializableExtra("pininfo");

		if (!m_bShowAddress) {
			layout_address.setVisibility(View.GONE);
		}
		tvAddress.setText(pinInfo.str_address);
		tvCity.setText(pinInfo.str_city);
		tvState.setText(pinInfo.str_state);
		tvCountry.setText(pinInfo.str_country);

		tvfullAddress.setText(pinInfo.str_full_address);

		initMap();
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub
		System.out.println("activeppin resume = initdata : " + m_nCategoryId);

		if (m_nCategoryId == -1) {
			ivCategoryIcon.setBackgroundResource(R.drawable.place_1);
			tvCategoryText.setText("Select Category");
		} else {
			for (int i = 0; i < Share.g_arrCategory.size(); i++) {
				CategoryInfo _category = Share.g_arrCategory.get(i);
				if (_category.strId.equals("" + m_nCategoryId)) {
					ivCategoryIcon.setBackgroundResource(_category
							.getResouceId());
					tvCategoryText.setText(_category.strName);
					break;
				}

			}
		}

		if (m_nSimple == -1) {
			tvScheduleText.setText("When?");
		} else {
			String month = "Jan";
			if (m_nStartMonth == 1)
				month = "Jan";
			else if (m_nStartMonth == 2)
				month = "Feb";
			else if (m_nStartMonth == 3)
				month = "Mar";
			else if (m_nStartMonth == 4)
				month = "Apr";
			else if (m_nStartMonth == 5)
				month = "May";
			else if (m_nStartMonth == 6)
				month = "Jun";
			else if (m_nStartMonth == 7)
				month = "Jul";
			else if (m_nStartMonth == 8)
				month = "Aug";
			else if (m_nStartMonth == 9)
				month = "Sep";
			else if (m_nStartMonth == 10)
				month = "Oct";
			else if (m_nStartMonth == 11)
				month = "Nov";
			else if (m_nStartMonth == 12)
				month = "Dec";

			String schedule = m_nStartDay + " " + month + " - ++";
			tvScheduleText.setText(schedule);
		}

	}

	public boolean onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);

		menu.add(1, 100, 1, "Edit Address");

		return true;
	}

	public boolean onOptionsItemSelected(MenuItem item) {
		super.onOptionsItemSelected(item);

		switch (item.getItemId()) {
		case 100:
			if (!m_bShowAddress) {
				layout_address.setVisibility(View.VISIBLE);
				m_bShowAddress = true;
			}
			break;
		}
		return true;
	}

	public void onActivePin() {
		
		if (etTitle.getText().toString().length() < 1) {
			 Const.showToastMessage("Please input title", this);
			 return;
		}
		if (etDescription.getText().toString().length() < 1) {
			 Const.showToastMessage("Please input description", this);
			 return;
		}
		if (tvAddress.getText().toString().length() < 1) {
			 Const.showToastMessage("Please input address", this);
			 return;
		}
		if (tvCity.getText().toString().length() < 1) {
			 Const.showToastMessage("Please input city", this);
			 return;
		}
		if (tvCountry.getText().toString().length() < 1) {
			 Const.showToastMessage("Please input country", this);
			 return;
		}
		if (m_nSimple == -1) {
			 Const.showToastMessage("Please set schedule", this);
			 return;
		}
		if (m_nCategoryId == -1) {
			 Const.showToastMessage("Please choose category", this);
			 return;
		}
		
/*		
		 HttpClient httpclient = new DefaultHttpClient();
		 String url = Utils.postPlacePinUrl();
		 HttpPost httppost = new HttpPost(url);

		 try {
		 // Add your data
		 List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
		 nameValuePairs.add(new BasicNameValuePair("code", 		UserLoginInfo.getLoginCode()));
		 nameValuePairs.add(new BasicNameValuePair("user_id", 	UserLoginInfo.getLoginId()));
		 nameValuePairs.add(new BasicNameValuePair("title", 	etTitle.getText().toString()));
		 nameValuePairs.add(new BasicNameValuePair("description", 	etDescription.getText().toString()));
		 nameValuePairs.add(new BasicNameValuePair("country", 	tvCountry.getText().toString()));
		 nameValuePairs.add(new BasicNameValuePair("state", 	tvState.getText().toString()));
		 nameValuePairs.add(new BasicNameValuePair("city", 		tvCity.getText().toString()));
		 nameValuePairs.add(new BasicNameValuePair("address", 	tvAddress.getText().toString()));
		 
		 nameValuePairs.add(new BasicNameValuePair("lat", 		pinInfo.str_lat));
		 nameValuePairs.add(new BasicNameValuePair("lng", 		pinInfo.str_lng));
		 nameValuePairs.add(new BasicNameValuePair("category_id", 		pinInfo.str_lng));
		 nameValuePairs.add(new BasicNameValuePair("timezone", 	Setting.getTimezone()));
		 
		 if (m_nSimple == 1) { // simple
			 nameValuePairs.add(new BasicNameValuePair("simple", 	"1"));
			 nameValuePairs.add(new BasicNameValuePair("days_from_now",	"" + m_nDays));
			 nameValuePairs.add(new BasicNameValuePair("type", 		"one"));
		 } else { //advance
			 nameValuePairs.add(new BasicNameValuePair("simple", 	"0"));
			 nameValuePairs.add(new BasicNameValuePair("start_date",m_nStartYear + "-" + m_nStartMonth + "-" + m_nStartDay));
			 nameValuePairs.add(new BasicNameValuePair("start_time",m_nStartHour + ":" + m_nStartMin));
			 
			 nameValuePairs.add(new BasicNameValuePair("end_date",	m_nEndYear + "-" + m_nEndMonth + "-" + m_nEndDay));
			 nameValuePairs.add(new BasicNameValuePair("end_time",	m_nEndHour + ":" + m_nEndMin));

			 nameValuePairs.add(new BasicNameValuePair("type", 		m_strFrequency));
			 nameValuePairs.add(new BasicNameValuePair("runs",		"" + m_nRepet));
			 nameValuePairs.add(new BasicNameValuePair("x", 		"" + m_nEvery));
		 }
		 
		 // Image
		 
		 
		 httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

		 // Execute HTTP Post Request
		 HttpResponse response = httpclient.execute(httppost);
		 String responseBody = EntityUtils.toString(response.getEntity());
		 
		 System.out.println("post review = " + responseBody);
		 JSONObject obj = new JSONObject(responseBody);
			
			if (obj != null) {
//				String result = obj.optString("message");
			}
			
		 Const.showToastMessage("You have successfully placed a pin.", this);
		 
		 } catch (Exception e) {
			 e.printStackTrace();
			 
			 Const.showToastMessage("We are currently experiencing issues accessing our server. Please try again later.", this);
		 }
*/
		
		HttpParams myParams = new BasicHttpParams();

		 HttpConnectionParams.setConnectionTimeout(myParams, 30000);
		 HttpConnectionParams.setSoTimeout(myParams, 30000);
		 
		 DefaultHttpClient hc= new DefaultHttpClient(myParams);
		 ResponseHandler <String> res=new BasicResponseHandler();
		
		 String url = Utils.postPlacePinUrl();
		 HttpPost postMethod = new HttpPost(url);
		
		 List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();

		 String responseBody = "";
		 try {
		 MultipartEntity reqEntity = new MultipartEntity(HttpMultipartMode.BROWSER_COMPATIBLE);

		 reqEntity.addPart("code", 			new StringBody(UserLoginInfo.getLoginCode()));
		 reqEntity.addPart("user_id", 		new StringBody(UserLoginInfo.getLoginId()));
		 reqEntity.addPart("title",			new StringBody(etTitle.getText().toString()));
		 reqEntity.addPart("description", 	new StringBody(etDescription.getText().toString()));
		
		 reqEntity.addPart("country", 		new StringBody(tvCountry.getText().toString()));
		 reqEntity.addPart("state", 		new StringBody(tvState.getText().toString()));
		 reqEntity.addPart("city", 			new StringBody(tvCity.getText().toString()));
		 reqEntity.addPart("address", 		new StringBody(tvAddress.getText().toString()));
		
		 reqEntity.addPart("lat", 			new StringBody(pinInfo.str_lat));
		 reqEntity.addPart("lng", 			new StringBody(pinInfo.str_lng));
		 reqEntity.addPart("category_id", 	new StringBody("" + m_nCategoryId));
		 reqEntity.addPart("timezone", 		new StringBody(Setting.getTimezone()));
		 

		 if (m_nSimple == 1) { // simple
			 reqEntity.addPart("simple", 		new StringBody("1"));
			 reqEntity.addPart("days_from_now", new StringBody("" + m_nDays));
			 reqEntity.addPart("type", 			new StringBody("one"));
		 } else { //advance
			 reqEntity.addPart("simple", 		new StringBody("0"));
			 reqEntity.addPart("start_date", 	new StringBody(m_nStartYear + "-" + m_nStartMonth + "-" + m_nStartDay));
			 reqEntity.addPart("start_time", 	new StringBody(m_nStartHour + ":" + m_nStartMin));
			 reqEntity.addPart("end_date", 		new StringBody(m_nEndYear + "-" + m_nEndMonth + "-" + m_nEndDay));
			 reqEntity.addPart("end_time", 		new StringBody(m_nEndHour + ":" + m_nEndMin));
			 
			 reqEntity.addPart("type", 			new StringBody(m_strFrequency));
			 reqEntity.addPart("runs", 			new StringBody("" + m_nRepet));
			 reqEntity.addPart("x", 			new StringBody("" + m_nEvery));
		 }
		 
		 if (m_bmp != null) {
			 ByteArrayOutputStream bos = new ByteArrayOutputStream();
			 m_bmp.compress(CompressFormat.JPEG, 75, bos);
			 byte[] data = bos.toByteArray();
			 
			 ByteArrayBody bab = new ByteArrayBody(data, "temp.jpg");
			 
			 reqEntity.addPart("upload", bab);
		 }
		 
//		 if (filepath != null) {
//		    File file = new File(filepath);
//		    ContentBody cbFile = new FileBody(file, "image/jpeg");
//		    reqEntity.addPart("user_avatar", cbFile);
//		   }
		 
		 
		 postMethod.setEntity(reqEntity);
		 responseBody = hc.execute(postMethod,res);
		 
		 System.out.println("post review = " + responseBody);
		 JSONObject obj = new JSONObject(responseBody);
			if (obj != null) {
				String result = obj.optString("message");
				if (result.indexOf("error") < 0) {
//					Const.showToastMessage("You have successfully placed a pin.", this);
					Const.showMessage("Activated!", "We have broadcasted your pin.", this);
					onBackPressed();
				}
			}
			
		 
		 } catch (UnsupportedEncodingException e) {
			 e.printStackTrace();
		 } catch (ClientProtocolException e) {
			 e.printStackTrace();
		 } catch (IOException e) {
			 e.printStackTrace();
		 } catch (JSONException e) {
		 }
		 
	}

	public void onAddressDone() {
		String full_address = tvAddress.getText().toString() + ","
				+ tvCity.getText().toString() + ","
				+ tvState.getText().toString() + tvCountry.getText().toString();
		tvfullAddress.setText(full_address);
		
		layout_address.setVisibility(View.GONE);
		m_bShowAddress = false;
	}

	public void gotoCatogory(int nCategoryId) {

		startActivity(new Intent(ActivePinActivity.this, SelectCategoryActivity.class));
//		Intent intent = new Intent(ActivePinActivity.this, SelectCategoryActivity.class);
//		goNextHistory("SelectCategoryActivity", intent);
	}

	public void gotoSchedule() {

		startActivity(new Intent(ActivePinActivity.this, SelectScheduleActivity.class));
//		Intent intent = new Intent(ActivePinActivity.this, SelectScheduleActivity.class);
//		goNextHistory("SelectScheduleActivity", intent);
	}

	public void setImageFromGalery() {

		openImageIntent();

	}

	private void openImageIntent() {
		// Camera.
		final List<Intent> cameraIntents = new ArrayList<Intent>();
		final Intent captureIntent = new Intent(
				android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
		final PackageManager packageManager = getPackageManager();
		final List<ResolveInfo> listCam = packageManager.queryIntentActivities(
				captureIntent, 0);
		for (ResolveInfo res : listCam) {
			final String packageName = res.activityInfo.packageName;
			final Intent intent = new Intent(captureIntent);
			intent.setComponent(new ComponentName(res.activityInfo.packageName,
					res.activityInfo.name));
			intent.setPackage(packageName);
			cameraIntents.add(intent);
		}

		// Filesystem.
		final Intent galleryIntent = new Intent();
		galleryIntent.setType("image/*");
		galleryIntent.setAction(Intent.ACTION_GET_CONTENT);

		// Chooser of filesystem options.
		final Intent chooserIntent = Intent.createChooser(galleryIntent,
				"Please Choose");

		// Add the camera options.
		chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS,
				cameraIntents.toArray(new Parcelable[] {}));

		startActivityForResult(chooserIntent, 1);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// super.onActivityResult(requestCode, resultCode, data);

		System.out.println("active Result");
		
		if (resultCode != RESULT_OK) {
			finish();
			return;
		}

		if (requestCode == 1) {

			System.out.println("selected image ============");
			try {
				if (data != null) {

					Uri selPhotoUri = data.getData();
					m_bmp = getThumbnail(selPhotoUri);

					ivPic.setImageBitmap(m_bmp);
				} else {
					m_bmp = null;
				}
			} catch (Exception e) {
				e.printStackTrace();
				m_bmp = null;
			}

		}
	}

	public Bitmap getThumbnail(Uri uri) throws FileNotFoundException,
			IOException {
		final int THUMBNAIL_SIZE = 150;

		InputStream input = getContentResolver().openInputStream(uri);

		BitmapFactory.Options onlyBoundsOptions = new BitmapFactory.Options();
		onlyBoundsOptions.inJustDecodeBounds = true;
		onlyBoundsOptions.inDither = true;// optional
		onlyBoundsOptions.inPreferredConfig = Bitmap.Config.ARGB_8888;// optional
		BitmapFactory.decodeStream(input, null, onlyBoundsOptions);
		input.close();
		if ((onlyBoundsOptions.outWidth == -1)
				|| (onlyBoundsOptions.outHeight == -1))
			return null;

		int originalSize = (onlyBoundsOptions.outHeight > onlyBoundsOptions.outWidth) ? onlyBoundsOptions.outHeight
				: onlyBoundsOptions.outWidth;

		double ratio = (originalSize > THUMBNAIL_SIZE) ? (originalSize / THUMBNAIL_SIZE)
				: 1.0;

		BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
		bitmapOptions.inSampleSize = getPowerOfTwoForSampleRatio(ratio);
		bitmapOptions.inDither = true;// optional
		bitmapOptions.inPreferredConfig = Bitmap.Config.ARGB_8888;// optional
		input = this.getContentResolver().openInputStream(uri);
		Bitmap bitmap = BitmapFactory.decodeStream(input, null, bitmapOptions);
		input.close();
		return bitmap;
	}

	private static int getPowerOfTwoForSampleRatio(double ratio) {
		int k = Integer.highestOneBit((int) Math.floor(ratio));
		if (k == 0)
			return 1;
		else
			return k;
	}

	public void initMap() {

		LayoutInflater inflate = this.getLayoutInflater();
		popView = inflate.inflate(R.layout.map_pop_view, null);
		// mapView.setBuiltInZoomControls(true);
		mapController = mapView.getController();

		mapView.getOverlays().clear();
		mapView.removeAllViews();

		double maxLat = 0, maxLng = 0, minLat = 0, minLng = 0;

		if (pinInfo != null) {
			double lat = 0.0, lng = 0.0;
			try {
				lat = Double.parseDouble(pinInfo.str_lat);
			} catch (Exception e) {
				lat = 0.0;
			}
			try {
				lng = Double.parseDouble(pinInfo.str_lng);
			} catch (Exception e) {
				lng = 0.0;
			}

			minLat = maxLat = lat;
			minLng = maxLng = lng;

			GeoPoint geoPoint = new GeoPoint((int) (lat * 1E6),
					(int) (lng * 1E6));
			localItem = new OverlayItem(geoPoint, "Customise you new pin",
					pinInfo.str_full_address);

			Drawable drawable = this.getResources().getDrawable(R.drawable.gps);
			CustomItemizedOverlay citem = new CustomItemizedOverlay(drawable);
			citem.setOnFocusChangeListener(onFocusChangeListener);
			localItem.setMarker(drawable);
			citem.addOverlay(localItem);

			mapView.getOverlays().add(citem);
		}

		mapController.zoomToSpan((int) ((maxLat - minLat) * 1E6),
				(int) ((maxLng - minLng) * 1E6));
		mapController.setCenter(new GeoPoint(
				(int) ((maxLat + minLat) * 1E6) / 2,
				(int) ((maxLng + minLng) * 1E6) / 2));

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
	public void setListener() {
		// TODO Auto-generated method stub

	}

}
