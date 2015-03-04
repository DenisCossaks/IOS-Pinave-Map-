package com.recipe.ifoodtv.twitter;


import com.montre.pinave.R;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class TwitterLogin extends Activity
{
	TwitterLogin mInstance = null;
  // INTENT
  Intent mIntent;
  String mAction = "none";
 
  public void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.twitter_web_login);
    
    mInstance = this;
    WebView webView = (WebView) findViewById(R.id.webView);
    webView.getSettings().setJavaScriptEnabled(true);
    webView.addJavascriptInterface(new JavaScriptInterface(), "PINCODE");

    webView.setWebViewClient(new WebViewClient()
    {
      public void onPageFinished(WebView view, String url)
      {
        super.onPageFinished(view, url);
        Log.v("ifoodtv", ">>>> url = " + url.toString());

        view.loadUrl("javascript:window.PINCODE.getPinCode(document.getElementById('oauth_pin').innerHTML);");

        if (url != null && url.equals("http://mobile.twitter.com/"))
        {
          finish();
        }        
      }
    });

    mIntent = getIntent();
    String url1 = mIntent.getStringExtra("auth_url");
    mAction = mIntent.getStringExtra("action");
    Log.v("ifoodtv", ">>> url1 = " + url1);
    webView.loadUrl(url1);
  }
 
  class JavaScriptInterface
  {
    public void getPinCode(String pin)
    {
      if (pin.length() > 0)
      {
        
        if (mAction!= null && mAction.compareTo("ret") == 0) {
        	mIntent.putExtra("pin_code", pin);
	        setResult(RESULT_OK, mIntent);
	        finish();
        } else {
        	finish();
        //	DiaryActivity.gInstance.loginfromTwitter(pin);
        }
      }
      else
      {
        Log.v("ifoodtv", ">>>> get pin failed...");
      }
    }
  }
}