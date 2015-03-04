package com.montre.pindetail;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.ArrayList;

import org.xmlpull.v1.XmlPullParserException;

import twitter4j.Twitter;
import twitter4j.http.AccessToken;
import twitter4j.http.RequestToken;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.preference.PreferenceManager;
import android.provider.Contacts;
import android.text.Editable;
import android.text.Html;
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
import android.webkit.WebView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RatingBar;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.ItemizedOverlay;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.OverlayItem;
import com.montre.data.CategoryInfo;
import com.montre.data.CustomLocation;
import com.montre.data.Items;
import com.montre.data.PinInfo;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.httpclient.AsyncImageLoader_Async;
import com.montre.lib.ComputeDistance;
import com.montre.lib.Const;
import com.montre.pinave.R;
import com.montre.ui.basic.BasicUI;
import com.montre.ui.placepin.ActivePinActivity;
import com.montre.ui.router.RouterActivity;
import com.montre.util.JsonParser;
import com.montre.util.WebServiceUrl;
import com.recipe.ifoodtv.facebook.DialogError;
import com.recipe.ifoodtv.facebook.Facebook;
import com.recipe.ifoodtv.facebook.FacebookError;
import com.recipe.ifoodtv.facebook.Facebook.DialogListener;
import com.recipe.ifoodtv.twitter.PostOnTwitterActivity;

public class PinDetailActivity extends BasicUI {
	
	private PinInfo pinInfo = new PinInfo();
	
	private TextView	tvHeadeer = null;
	private Button		btnReview = null;
	private TextView	tvLocation = null;
	
	private ImageView	ivImage = null;
	private RatingBar	rbRating = null;
	private TextView	tvRatingNum = null;
	private TextView	tvTitle = null;
	
	private TextView	tvBy = null;
	private TextView	tvExpire = null;
	
	private WebView		wvDescription = null;
	
	private Button 		btnAvenue = null;
	private Button		btnMessage = null;
	
	final int 	PIN_USER 	= 0;
	final int 	PIN_SYSTEM	= 1;
	final int   PIN_OTHER	= 2;
	private int		m_nPinStatue = PIN_SYSTEM;
	    
	public static int 	m_nRatingNum = 0;
	private int 	m_nVoit		 = 0;
	
	private boolean m_bIsAddUser = false;
	private boolean m_bIsAddPin  = false;
	
	    
	private final int	PROGRESS_FIRST_LOADING = 0;
	private final int	PROGRESS_DELETE_PIN = 1;
	private final int 	DIALOG_MYAVENUE = 2;
    private final int	DIALOG_SHARE = 3;
//    private final int 	PROGRESS_FACEBOOK = 4;
    
    
	final int 	LOADING_OK	= 1;
	final int	LOADING_FAIL = 2;
	final int 	DELETE_OK	= 3;
	final int 	DELETE_FAIL	= 4;
	
	
	
    
    
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
		
        setContentView(R.layout.pindetail);
        
        initView();
        initData();
        
    }

    @Override
    public void onBackPressed() {
    	// TODO Auto-generated method stub
//    	super.onBackPressed();
    	finish();
    }
    public boolean onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);
		
		menu.add(1, 100, 1, "Give rating");
		
		return true;
	}

	public boolean onOptionsItemSelected(MenuItem item) {
		super.onOptionsItemSelected(item);
		
		switch (item.getItemId()) {
		case 100:
			Intent intent = new Intent(PinDetailActivity.this, GiveRatingActivity.class);
			
			intent.putExtra("pin_id", pinInfo.str_id);
			
			startActivityForResult(intent, 1);
//			goNextHistory("GiveRatingActivity", intent);
			break;
		}
		return true;
	}
	
/*	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// super.onActivityResult(requestCode, resultCode, data);

		if (resultCode != RESULT_OK) {
			finish();
			return;
		}

		if (requestCode == 1) {
			refresh();
		} 
	}
*/
	
    public void initView()
    {
    	
    	tvHeadeer = (TextView) findViewById(R.id.detail_header);
    	btnReview = (Button) findViewById(R.id.detail_review);
    	btnReview.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (m_nPinStatue == PIN_USER) {
					onPinDelete();
				} else {
					onPinReview();
				}
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
    	
    	
    	tvLocation = (TextView) findViewById(R.id.detail_location);
    	
    	ivImage = (ImageView) findViewById(R.id.detail_image);
    	ivImage.setOnTouchListener(new OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				// TODO Auto-generated method stub
				onFullImage();
				return false;
			}
		});

    	rbRating = (RatingBar) findViewById(R.id.detail_rating);
		rbRating.setFocusableInTouchMode(false);
		rbRating.setClickable(false);
		rbRating.setFocusable(false);
		rbRating.setEnabled(false);
		
		
    	tvRatingNum = (TextView) findViewById(R.id.detail_rating_number);
    	
    	tvTitle = (TextView) findViewById(R.id.detail_title);
    	
    	tvBy = (TextView) findViewById(R.id.detail_by);
    	tvExpire = (TextView) findViewById(R.id.detail_expire);
    	
    	wvDescription = (WebView) findViewById(R.id.detail_descript);
    	
    	Button btnToHere = (Button) findViewById(R.id.detail_btn_to);
    	btnToHere.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onDirectionToHere();
			}
		});
    	Button btnFromHere = (Button) findViewById(R.id.detail_btn_from);
    	btnFromHere.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onDirectionFromHere();
			}
		});
    	
    	btnAvenue = (Button) findViewById(R.id.detail_btn_avenue);
    	btnAvenue.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (m_nPinStatue == PIN_USER) {
					v.setEnabled(false);
				} else {
					onMyAvenue();
				}
			}
		});

    	Button btnShare = (Button) findViewById(R.id.detail_btn_share);
    	btnShare.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				onShare();
			}
		});

    	btnMessage = (Button) findViewById(R.id.detail_btn_mess);
    	btnMessage.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (m_nPinStatue == PIN_SYSTEM) {
					onGetIt();
				} else if (m_nPinStatue == PIN_USER) {
					btnMessage.setEnabled(false);
				} else {
					onSendMessage();
				}
			}
		});

    	
    	//////////////
    	facebook = new Facebook(WebServiceUrl.FACEBOOK_KEY);
    	
    }
    
    
    public void initData()
    {
    	
    	pinInfo = (PinInfo) getIntent().getSerializableExtra("pininfo");
    	if (pinInfo == null) {
    		return;
    	}
    	
    	tvHeadeer.setText(getCategoryName(pinInfo.str_category_id));
    	tvLocation.setText(Share.getStandardUserLocationAddress());
    	
    	String imageUrl = pinInfo.str_image;
		System.out.println("image url = " + imageUrl);
		
		
		AsyncImageLoader_Async asyncImageLoader_Async = new AsyncImageLoader_Async(this);
		asyncImageLoader_Async.loadDrawable(imageUrl,ivImage,80,60, pinInfo.str_id);
		
		
    	if (pinInfo.str_user_id.equals(UserLoginInfo.getLoginId())) {
    		m_nPinStatue = PIN_USER;
    	} else if (pinInfo.str_user_id.equals("13")) {
    		m_nPinStatue = PIN_SYSTEM;
    	} else {
    		m_nPinStatue = PIN_OTHER;
    	}
    	
    	if (m_nPinStatue == PIN_USER) {
    		btnReview.setText("Delete");
    		
    		btnAvenue.setEnabled(false);
    		btnAvenue.setEnabled(false);
    	} else if (m_nPinStatue == PIN_SYSTEM) {
    		btnMessage.setBackgroundResource(R.drawable.btn_get_click_xml);
    	}
		
    	tvTitle.setText(pinInfo.str_title);
    	tvBy.setText(getCustomPinnedBy(pinInfo.str_user_id));
    	
    	 int expire = 0;
    	 try {
    		 expire = Integer.parseInt(pinInfo.str_expire_in);
    	 } catch (Exception e) {
    		 expire = 0;
		 }
    	 int hour = expire/(60*60);
    	 int min = (expire - hour * (60*60)) / 60;
    	 tvExpire.setText("Pin expires in " + hour + "h : " + min + "m");
    	 
    	wvDescription.loadData("<html>" + pinInfo.str_description + "</html>", "text/html","utf-8");
    	
    	
//    	refresh();
    }

    @Override
    protected void onResume() {
    	// TODO Auto-generated method stub
    	super.onResume();
    	
    	refresh();
    	
    }
    
    public void refresh() {
    	removeDialog(PROGRESS_FIRST_LOADING);
		showDialog(PROGRESS_FIRST_LOADING);
    }

	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case PROGRESS_FIRST_LOADING:{
			ProgressDialog dialog = new ProgressDialog(this);
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
		case PROGRESS_DELETE_PIN:{
			ProgressDialog dialog = new ProgressDialog(this);
			dialog.setCancelable(false);
			dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
			dialog.setMessage("Loading...");
			
			new Thread(new Runnable() {
				
				public void run() {
					deletePinProcess();
				}
			}).start();
			return dialog;
		}
		
		case DIALOG_MYAVENUE:
        {
        	String[] items = new String[2];
        	for (int i = 0 ; i < items.length ; i ++) {
        		if (i == 0) {
        			if (m_bIsAddUser) {
        				items[i] = "Add User to My Avenue";
        			} else {
        				items[i] = "Remove User to My Avenue";
        			}
        		}
        		
        		if (i == 1) {
        			if(m_bIsAddPin) {
        				items[i] = "Remove Pin to My Avenue";
        			} else {
        				items[i] = "Add Pin to My Avenue";
        			}
        		}
        	}
        	
            return new AlertDialog.Builder(PinDetailActivity.this)
                .setTitle("My Avenue")
                .setItems(items, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                    	if (which == 0) {
                    		userToAvenue();
                    	}
                    	if (which == 1) {
                    		pinToAvenue();
                    	}
                    }
                })
                .create();
        }
        case DIALOG_SHARE:
        {
        	String[] items = {"Invite By Email", "Invite From Facebook", "Invite From Twitter"};
        	
            return new AlertDialog.Builder(PinDetailActivity.this)
                .setTitle("Sharing")
                .setItems(items, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                    	if (which == 0) {
                    		shareEmail();
                    	}
                    	if (which == 1) {
                    		shareFacebook();
                    	}
                    	if (which == 2) {
                    		shareTwitter();
                    	}
                    }
                })
                .create();
        }
	/*	
        case PROGRESS_FACEBOOK:{
			ProgressDialog dialog = new ProgressDialog(this);
			dialog.setCancelable(false);
			dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
			dialog.setMessage("Loading...");
			
			new Thread(new Runnable() {
				
				public void run() {
					String message = "Welcome to PinAve. I found there many useful and interesting stuff: http://pinave.com/user/create?refer=TEdY89CwGtUDTJF0hr";
					loadingFacebook(message, "", "", "", "");
				}
			}).start();
			return dialog;
		}*/
		}
		
		
			
		return super.onCreateDialog(id);
	}
	
	private void loadingProcess() {
		
		try {
		
			ArrayList<String> resultRating = JsonParser.getRating(pinInfo.str_id);
			if (resultRating != null) {
				if (resultRating.get(0).equalsIgnoreCase("OK")) {
					try {
						m_nRatingNum = Integer.parseInt(resultRating.get(1));
					} catch (Exception e) {
						m_nRatingNum = 0;
					}
					try {
						m_nVoit = Integer.parseInt(resultRating.get(2));
					} catch (Exception e) {
						m_nVoit = 0;
					}
				} else {
					mHandler.sendEmptyMessage(LOADING_FAIL);
					return;
				}
			} else {
				mHandler.sendEmptyMessage(LOADING_FAIL);
				return;
			}
			
			String resultPin = JsonParser.isAvenuePin(UserLoginInfo.getLoginCode(), pinInfo.str_id);
			if (resultPin.length() > 0) {
				if (resultPin.equalsIgnoreCase("true")) {
					m_bIsAddPin = true;
				} else {
					m_bIsAddPin = false;
				}
			}
			
			String resultUser = JsonParser.isAvenueUser(UserLoginInfo.getLoginCode(), pinInfo.str_id);
			if (resultUser.length() > 0) {
				if (resultUser.equalsIgnoreCase("true")) {
					m_bIsAddUser = true;
				} else {
					m_bIsAddUser = false;
				}
			}
			
		} catch (Exception e) {
			// TODO: handle exception
			mHandler.sendEmptyMessage(LOADING_FAIL);
		}
		
		mHandler.sendEmptyMessage(LOADING_OK);
		
	}
	
	private void deletePinProcess() {
		
		try {
		
			String result = JsonParser.getDeleteUserPin(UserLoginInfo.getLoginCode(), pinInfo.str_id);
			if (result != null && result.length() > 0) {
				if (result.equalsIgnoreCase("OK")) {
					mHandler.sendEmptyMessage(DELETE_OK);
					return;
				}
			} 
			
		} catch (Exception e) {
			mHandler.sendEmptyMessage(DELETE_FAIL);
		}
		
		mHandler.sendEmptyMessage(DELETE_FAIL);
		
	}
	
	   Handler mHandler = new Handler() {

			@Override
			public void handleMessage(Message msg) {
				super.handleMessage(msg);

				switch (msg.what) {
				case LOADING_OK:
					dismissDialog(PROGRESS_FIRST_LOADING);
					
					loadingDone();
					
					break;
				case LOADING_FAIL:
					dismissDialog(PROGRESS_FIRST_LOADING);
					
					Const.showMessage("Error", "Json parse error", PinDetailActivity.this);
					
					break;
					
				case DELETE_OK:
					dismissDialog(PROGRESS_DELETE_PIN);
					
					Const.showMessage("OK", "Delete OK", PinDetailActivity.this);
					break;
					
				case DELETE_FAIL:
					dismissDialog(PROGRESS_DELETE_PIN);
					
					Const.showMessage("Error", "Delete error", PinDetailActivity.this);
					
					break;
				default:
					break;
				}
			}

		};
		

		private String getCategoryName(String _categoryId) {
			for (int i = 0; i < Share.g_arrCategory.size() ; i++) {
				if (Share.g_arrCategory.get(i).getId().equals(_categoryId) ){
					return Share.g_arrCategory.get(i).getName();
				}
			}
			return "";
		}
		private String getCustomPinnedBy(String user_id){
			if (Share.g_arrUsers == null) 
				return "";
			
			for (int i = 0; i < Share.g_arrUsers.size(); i++) {
				UserInfo user = Share.g_arrUsers.get(i);
				
				if (user_id.equals(user.str_id)) {
					String str = "Pinned by:";
					
					String firstName = user.str_firstname;
					if (firstName != null && firstName.indexOf("null") < 0) {
						str += " " + firstName; 
					}
					
					String lastName = user.str_lastname;
					if (lastName != null && lastName.indexOf("null") < 0) {
						str += " " + lastName;
					}
					
					String city = user.str_detail_city;
					if (city != null && city.indexOf("null") < 0) {
						str += ", " + city;
					}
					String state = user.str_detail_state;
					if (state != null && state.indexOf("null") < 0 && state.length() > 0) {
						str += ", " + state;
					}
					String country = user.str_detail_country;
					if (country != null && country.indexOf("null") < 0) {
						str += ", " + country;
					}
					
					return str;
				}
				
			}
			return "";
		}
		
		private void loadingDone() {
			// rating bar set
			rbRating.setRating(m_nRatingNum);
			if (m_nRatingNum != 0) { 
				rbRating.setFocusableInTouchMode(false);
				rbRating.setClickable(false);
			}
			
			tvRatingNum.setText("(" + m_nVoit + ")");
		}
				
		public void onPinDelete() {
			
			showDialog(PROGRESS_DELETE_PIN);
	    }
		
	    public void onPinReview() {
	    	Intent intent = new Intent(PinDetailActivity.this, ReviewActivity.class);

			intent.putExtra("pinId", pinInfo.str_id);
					
			startActivity(intent);
//			goNextHistory("ReviewActivity", intent);
	    }
	    public void onFullImage() {
	    	
	    	String image_url = pinInfo.str_image;
	    	
	    	Intent intent = new Intent(PinDetailActivity.this, FullImageActivity.class);
	    	
	    	intent.putExtra("image_url", image_url);
	    	
	    	startActivity(intent);
	    	overridePendingTransition(R.anim.fade, 0);
	    }
	    
	    public void onDirectionToHere() {
	    	
	    	Intent intent = new Intent(PinDetailActivity.this, RouterActivity.class);

	    	System.out.println("full address = " + pinInfo.str_full_address);
	    	intent.putExtra("end_name", pinInfo.str_full_address);
	    	
	    	CustomLocation location = new CustomLocation(Const.toFloat(pinInfo.str_lat),
	    			Const.toFloat(pinInfo.str_lng));
	    	intent.putExtra("end_location", location);

	    	startActivity(intent);
	    }
	    public void onDirectionFromHere() {
	    	Intent intent = new Intent(PinDetailActivity.this, RouterActivity.class);
	    	
	    	intent.putExtra("start_name", pinInfo.str_full_address);
	    	
	    	intent.putExtra("start_location", new CustomLocation(Const.toFloat(pinInfo.str_lat),
	    			Const.toFloat(pinInfo.str_lng)));
	    	
	    	startActivity(intent);
	    	
	    }
	    public void onMyAvenue() {
	    	removeDialog(DIALOG_MYAVENUE);
	    	showDialog(DIALOG_MYAVENUE);
	    }
	    public void onShare() {
	    	showDialog(DIALOG_SHARE);
	    }
	    public void onGetIt() {
	    	String uriString = pinInfo.str_url;
	    	Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(uriString));
	    	startActivity(intent);
	    }
	    public void onSendMessage() {
	    	Intent intent = new Intent(PinDetailActivity.this, SendMessageActivity.class);
	    	
	    	intent.putExtra("pin_info", pinInfo);
	    	
	    	startActivity(intent);
//	    	goNextHistory("SendMessageActivity", intent);
	    }
	    
	    public void userToAvenue() {
	    	String result = "";
	    	if (m_bIsAddUser) {
	    		result = JsonParser.delUserMyAvenue(UserLoginInfo.getLoginCode(), pinInfo.str_user_id);
	    	} else {
	    		result = JsonParser.addUserMyAvenue(UserLoginInfo.getLoginCode(), pinInfo.str_user_id);
	    	}
	    	
	    	if (result.equalsIgnoreCase("OK")) {
	    		String message = "";
	    		if (m_bIsAddUser) {
	    			message = "The user has been removed into MyAvenue";
	    		} else {
	    			message = "The user has been added into MyAvenue";
	    		}
	    		
	    		Const.showMessage("", message, this);
	    		m_bIsAddUser = !m_bIsAddUser;
	    	} else {
	    		Const.showMessage("Fail", "Network is fail", this);
	    	}
	    }
	    
	    public void pinToAvenue() {
	    	String result = "";
	    	result = JsonParser.postAdd_RemovePinUrl(UserLoginInfo.getLoginCode(), pinInfo.str_id);
	    	
	    	if (result.equalsIgnoreCase("Pin was added")) {
	    		String message = "The pin has been added into MyAvenue";

	    		Const.showMessage("", message, this);
	    		m_bIsAddPin = true;
	    	}
	    	else if (result.equalsIgnoreCase("Pin was removed")) {
	    		String message = "The pin has been removed into MyAvenue";

	    		Const.showMessage("", message, this);
	    		m_bIsAddPin = false;
	    	} else {
	    		Const.showMessage("Fail", "Network is fail", this);
	    	}
	    }
	    
	    public void shareEmail() {
	    	String mailId = "";
			// or can work with pre-filled-in To: field
			// String mailId="yourmail@gmail.com";
			Intent emailIntent = new Intent(Intent.ACTION_SENDTO, Uri
					.fromParts("mailto", mailId, null));
			emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT,
					"Invite Friend");
			// you can use simple text like this
			// emailIntent.putExtra(android.content.Intent.EXTRA_TEXT,"Body text here");
			// or get fancy with HTML like this
			
			String firstName = Share.g_userInfo.str_firstname;
			String lastName  = Share.g_userInfo.str_lastname;
			
			String str1 = "<p>" + firstName + " " + lastName + " would like to share this virtual pin with you on PinAve.com</p>";
			String str2 = "<p>http://pinave.com/pin/" + pinInfo.str_id + "</p>";
			String str3 = "<a href=\"http://pinave.com/user/create?refer=TEdY89CwGtUDTJF0hr\">PinAve.com</a> is a Location-Based pinboard, which allows you to Search Engage eXperience your local neighbourhood.";
			
			emailIntent.putExtra(
					Intent.EXTRA_TEXT,
					Html.fromHtml(new StringBuilder()
							.append(str1)
							.append(str2)
							.append(str3)
							.append("\n")
							.append("\n")
							.append("<p>Support : <a href=\"http://pinave.com\">http://pinave.com</a></p>")
							.toString()));
			
			startActivity(Intent
					.createChooser(emailIntent, "Send email..."));
	    }
	    public void shareFacebook() {
	    	postToFacebook();
	    }
	    public void shareTwitter() {
	    	String message = "Welcome to PinAve. I found there many useful and interesting stuff: http://pinave.com/user/create?refer=TEdY89CwGtUDTJF0hr";
	    	String picture = "icon_pinave";
	    	postToTwitter(message, picture);
	    }


		@Override
		public void initViews() {
			// TODO Auto-generated method stub
			
		}
		
		
		/*
		 *  Facebook
		 */

		public Facebook facebook = null;
		public Twitter mTwitter = null;
		public RequestToken mRqToken;
		public AccessToken mAccessToken;
		private SharedPreferences sharedPrefs;
		
		////////////////////////// facebook
	    public void setSession(String token, long token_expires, Context context) {
	    	Log.d("ifoodtv", token);
	        sharedPrefs = PreferenceManager
			                .getDefaultSharedPreferences(context);
			sharedPrefs.edit().putLong("access_expires", token_expires).commit();
			sharedPrefs.edit().putString("access_token", token).commit();
	    }
	    
		   public boolean isSession(Context context) {
		        sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
		        String access_token = sharedPrefs.getString("access_token", "x");
		        Long expires = sharedPrefs.getLong("access_expires", -1);
		        Log.d("ifoodtv", access_token);

		        if (access_token != null && expires != -1) {
		        	facebook.setAccessToken(access_token);
		        	facebook.setAccessExpires(expires);
		        }
		        return facebook.isSessionValid();
		    }

		    public void postRecipeToFacebook(
		    		Context context,
		    		String message,
		    		String name,
		    		String link,
		    		String description,
		    		String picture)
		    {
				Bundle params = new Bundle();
				params.putString(Facebook.TOKEN, facebook.getAccessToken());
				if (message.length() > 0)
					params.putString("message", message);
				params.putString("name", name);
				params.putString("link", link);
				params.putString("description", description);
				params.putString("picture", picture);
				try {
					facebook.request("me/feed", params, "POST");
					Toast.makeText(this, "Posted Successfully!", Toast.LENGTH_LONG).show();
					/*AlertDialog.Builder dialog = new AlertDialog.Builder(context);
					dialog.setMessage("This has been posted to Facebook.  Thanks!");
					dialog.setPositiveButton("Ok",
						new DialogInterface.OnClickListener() {
						public void onClick(DialogInterface dialog, int id) {
							dialog.cancel();
						}
					});
					dialog.show();*/
				} catch (FileNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (MalformedURLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}	
		    }
		
		    
		    private void postToFacebook()
		    {
				String message = "Welcome to PinAve. I found there many useful and interesting stuff: http://pinave.com/user/create?refer=TEdY89CwGtUDTJF0hr";
				loadingFacebook(message, "", "", "", "");

//				removeDialog(PROGRESS_FACEBOOK);
//				showDialog(PROGRESS_FACEBOOK);
		    }
		    
		    
		    private void loadingFacebook (final String message,
		    		final String name,
		    		final String link,
		    		final String description,
		    		final String picture) {
		    
		    	if (isSession(this)) {
		    		postRecipeToFacebook(this, message, name, link, description, picture);
		    		
//		    		dismissDialog(PROGRESS_FACEBOOK);

		    	} else {
		    		try {
		    			facebook.authorize(getParent(), new String[]{"publish_stream", "read_stream", "offline_access"}, new DialogListener() {

		    				@Override
		    				public void onCancel() {
//		    					dismissDialog(PROGRESS_FACEBOOK);

		    				}

		    				@Override
		    				public void onComplete(Bundle values) {
		    					// TODO Auto-generated method stub
		    					
		                        String token = facebook.getAccessToken();
		                        long token_expires = facebook.getAccessExpires();

		                        setSession(token, token_expires, PinDetailActivity.this);
		                        
		                        postRecipeToFacebook(PinDetailActivity.this, message, name, link, description, picture);
								
//		                        dismissDialog(PROGRESS_FACEBOOK);
		    				}

		    				@Override
		    				public void onError(DialogError e) {
		    					// TODO Auto-generated method stub
//		    					dismissDialog(PROGRESS_FACEBOOK);
		    					
		    					AlertDialog.Builder dialog = new AlertDialog.Builder(PinDetailActivity.this);
		    					dialog.setMessage("Dialog Initation Error occurred.");
		    					dialog.setPositiveButton("Ok",
		    						new DialogInterface.OnClickListener() {
		    						public void onClick(DialogInterface dialog, int id) {
		    							dialog.cancel();
		    						}
		    					});
		    					dialog.show();
		    				}

		    				@Override
		    				public void onFacebookError(FacebookError e) {
		    					// TODO Auto-generated method stub
//		    					dismissDialog(PROGRESS_FACEBOOK);
		    					
		    					AlertDialog.Builder dialog = new AlertDialog.Builder(PinDetailActivity.this);
		    					dialog.setMessage("Facebook Error occurred.");
		    					dialog.setPositiveButton("Ok",
		    						new DialogInterface.OnClickListener() {
		    						public void onClick(DialogInterface dialog, int id) {
		    							dialog.cancel();
		    						}
		    					});
		    					dialog.show();
		    				}

		    			});
		    		} catch(Exception e) {
		    			e.printStackTrace();
		    			
//		    			dismissDialog(PROGRESS_FACEBOOK);
		    			
		    			AlertDialog.Builder dialog = new AlertDialog.Builder(PinDetailActivity.this);
		    			dialog.setMessage("Other Error occurred.");
		    			dialog.setPositiveButton("Ok",
		    				new DialogInterface.OnClickListener() {
		    				public void onClick(DialogInterface dialog, int id) {
		    					dialog.cancel();
		    				}
		    			});
		    			dialog.show();
		    		}
		    	}
		    }
		

		    private void postToTwitter(String message, String picture) {
		    	Intent intent = new Intent(PinDetailActivity.this, PostOnTwitterActivity.class);
		    	
				intent.putExtra("path", picture);
				
				intent.putExtra("msg", message);
				
				startActivity(intent);
				overridePendingTransition(R.anim.bottom_slide_in, 0);
		    }
}