
package com.recipe.ifoodtv.twitter;


import com.montre.pinave.R;
import com.montre.util.WebServiceUrl;

import twitter4j.Twitter;
import twitter4j.TwitterFactory;
import twitter4j.conf.Configuration;
import twitter4j.conf.ConfigurationBuilder;
import twitter4j.http.AccessToken;
import twitter4j.http.OAuthAuthorization;
import twitter4j.http.RequestToken;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;



public class PostOnTwitterActivity extends Activity {
	private String message = null;
	private String path = null;
	private AccessToken mAccessToken;
	private RequestToken mRqToken;
	private Twitter mTwitter;
	
	/*
		Request token URL
		https://api.twitter.com/oauth/request_token
		
		Access token URL
		https://api.twitter.com/oauth/access_token
		
		Authorize URL
		https://api.twitter.com/oauth/authorize
		
		Registered OAuth Callback URL
		http://someurl.com
	 */
	@Override
	protected void onCreate(Bundle savedInstanceState) {		
		super.onCreate(savedInstanceState);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.twitter_login);
		setRequestedOrientation(1);		
		Intent i = getIntent();
		message = i.getStringExtra("msg");
		path = i.getStringExtra("path");
		post_twitmessage();
	}
	
	public void post_twitmessage(){
		try
	    {
	      String accessToken = Util.getAppPreferences(this, WebServiceUrl.TWITTER_ACCESS_TOKEN);
	      String accessTokenSecret = Util.getAppPreferences(this, WebServiceUrl.TWITTER_ACCESS_TOKEN_SECRET);

	      if (accessToken != null && !"".equals(accessToken) && accessTokenSecret != null && !"".equals(accessTokenSecret))
	      {
	        mAccessToken = new AccessToken(accessToken, accessTokenSecret);
	        sendMessageTwitter();
	        Log.v(WebServiceUrl.LOG_TAG, "accessToken : " + mAccessToken.getToken());
	        Log.v(WebServiceUrl.LOG_TAG, "accessTokenSecret : " + mAccessToken.getTokenSecret());
	      }
	      else
	      {
	        ConfigurationBuilder cb = new ConfigurationBuilder();
	        cb.setDebugEnabled(true);
	        cb.setOAuthConsumerKey(WebServiceUrl.TWITTER_CONSUMER_KEY);
	        cb.setOAuthConsumerSecret(WebServiceUrl.TWITTER_CONSUMER_SECRET);
	        TwitterFactory factory = new TwitterFactory(cb.build());
	        mTwitter = factory.getInstance();
	        mRqToken = mTwitter.getOAuthRequestToken();
	        Log.v(WebServiceUrl.LOG_TAG, "AuthorizationURL >>>>>>>>>>>>>>> " + mRqToken.getAuthorizationURL());
	       
	        Intent intent = new Intent(this, TwitterLogin.class);
	        intent.putExtra("auth_url", mRqToken.getAuthorizationURL());
	        intent.putExtra("request_token", mRqToken.toString());
	        intent.putExtra("action", "ret");
	        startActivityForResult(intent, WebServiceUrl.TWITTER_LOGIN_CODE);
	      }
	    }
	    catch (Exception e)
	    {
	      e.printStackTrace();
	    }
	}
	
	private void sendMessageTwitter() {	   
	    try
	    {
	      ConfigurationBuilder cb = new ConfigurationBuilder();
	      String oAuthAccessToken = mAccessToken.getToken();
	      String oAuthAccessTokenSecret = mAccessToken.getTokenSecret();
	      String oAuthConsumerKey = WebServiceUrl.TWITTER_CONSUMER_KEY;
	      String oAuthConsumerSecret = WebServiceUrl.TWITTER_CONSUMER_SECRET;
	      cb.setOAuthAccessToken(oAuthAccessToken);
	      cb.setOAuthAccessTokenSecret(oAuthAccessTokenSecret);
	      cb.setOAuthConsumerKey(oAuthConsumerKey);
	      cb.setOAuthConsumerSecret(oAuthConsumerSecret);
	      Configuration config = cb.build();
	     
	      TwitterFactory tFactory = new TwitterFactory(config);
	      Twitter twitter = tFactory.getInstance();
	      
	      twitter.updateStatus(message);
	      Toast.makeText(getApplicationContext(), "Posted Successfully!", Toast.LENGTH_LONG).show();
	      finish();
	      
	    }
	    catch (Exception e)
	    {
	      e.printStackTrace();
	    }
	}
	
	@Override
	  protected void onActivityResult(int requestCode, int resultCode, Intent data)
	  {
	    super.onActivityResult(requestCode, resultCode, data); 
	   
	    if(resultCode == RESULT_OK)
	    {
	      if (requestCode == WebServiceUrl.TWITTER_LOGIN_CODE)
	      {
	        try
	        {
	          Log.v(WebServiceUrl.LOG_TAG, "Twitter Pin Code : " + data.getStringExtra("pin_code"));
	          String pin = data.getStringExtra("pin_code");
	          int tagFront = pin.indexOf("<code>") + 6 ;
	          StringBuilder sb = new StringBuilder(pin);
	          sb = sb.delete(0, tagFront);

	          String reminderStr = sb.toString();
	          int tagBack = reminderStr.indexOf("</code>");

	          sb = sb.delete(tagBack, reminderStr.length());

	          Log.w("test", "toss pincode : "+sb.toString());
	          mAccessToken = mTwitter.getOAuthAccessToken(mRqToken, sb.toString());
	         
	          Util.setAppPreferences(this, WebServiceUrl.TWITTER_ACCESS_TOKEN, mAccessToken.getToken());
	          Util.setAppPreferences(this, WebServiceUrl.TWITTER_ACCESS_TOKEN_SECRET, mAccessToken.getTokenSecret());
	        }
	        catch (Exception e)
	        {
	          e.printStackTrace();
	        }
	      }
	      sendMessageTwitter();
	    }
	  }
}
