package com.montre.etc;

import java.util.ArrayList;

import com.montre.data.CategoryInfo;
import com.montre.data.Notification;
import com.montre.data.PinInfo;
import com.montre.pinave.BottomTab;
import com.montre.util.JsonParser;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.os.Handler;
import android.util.Log;

public class NotifyThread {

	UITimer timer = null;
	boolean m_bShowMessage = false;

	private Context parent;
	
	int 	m_nMode = 0;
	
	
	public NotifyThread(Context context, int mode) {
		// TODO Auto-generated constructor stub
		parent = context;
		
		m_nMode = mode;
	}
	
	public void start(int timeoutSeconds) {
		
		timer = new UITimer(uiHandler, runMethod, timeoutSeconds*1000);       
        timer.start();
	}
	
	public void stop() {
		
		if (timer != null) {
			timer.stop();
			timer = null;
		}
	}
	
	
	public Handler uiHandler = new Handler();

	private Runnable runMethod = new Runnable()
	{
		public void run()
		{
	         // do something
			if (m_nMode == 0) {
				ArrayList<CategoryInfo> categoryList = Notification.getCategory();
				
				ArrayList<PinInfo> arrPins = JsonParser.getPinsAroundUser(categoryList);
				
				if (arrPins != null) {
					if (arrPins.size() != 0) {
						m_bShowMessage = true;
						
						String msg = "There are " + arrPins.size() + " pins arround";
						
						AlertDialog.Builder dialog = new AlertDialog.Builder(parent);
//						dialog.setTitle("");
						dialog.setMessage(msg);
						dialog.setIcon(android.R.drawable.ic_dialog_info);
						dialog.setNegativeButton("Ok", new OnClickListener() {
							
							@Override
							public void onClick(DialogInterface dialog, int which) {
								// TODO Auto-generated method stub
								m_bShowMessage = false;
								dialog.dismiss();
							}
						});
						dialog.show();
						
					}
				}
			}
			else if (m_nMode == 1) {
				BottomTab.setNotifyStart(false);
				
				Notification.setNotify(true);
				BottomTab.setNotification();
			}
			
	    }
	};
	    
	
	public class UITimer
	{
	    private Handler handler;
	    private Runnable runMethod;
	    private int intervalMs;
	    private boolean enabled = false;
	    private boolean oneTime = false;

	    public UITimer(Handler handler, Runnable runMethod, int intervalMs)
	    {
	        this.handler = handler;
	        this.runMethod = runMethod;
	        this.intervalMs = intervalMs;
	    }

	    public UITimer(Handler handler, Runnable runMethod, int intervalMs, boolean oneTime)
	    {
	        this(handler, runMethod, intervalMs);
	        this.oneTime = oneTime;
	    }

	    public void start()
	    {
	        if (enabled)
	            return;

	        if (intervalMs < 1)
	        {
	            Log.e("timer start", "Invalid interval:" + intervalMs);
	            return;
	        }

	        enabled = true;
	        handler.postDelayed(timer_tick, intervalMs);        
	    }

	    public void stop()
	    {
	        if (!enabled)
	            return;

	        enabled = false;
	        handler.removeCallbacks(runMethod);
	        handler.removeCallbacks(timer_tick);
	    }

	    public boolean isEnabled()
	    {
	        return enabled;
	    }

	    private Runnable timer_tick = new Runnable()
	    {
	        public void run()
	        {
	            if (!enabled)
	                return;

	            handler.post(runMethod);

	            if (oneTime)
	            {
	                enabled = false;
	                return;
	            }

	            handler.postDelayed(timer_tick, intervalMs);
	        }
	    }; 
	}
}
