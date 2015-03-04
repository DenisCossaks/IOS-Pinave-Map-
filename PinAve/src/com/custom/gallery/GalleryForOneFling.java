package com.custom.gallery;

import android.content.Context;
import android.graphics.PointF;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.Gallery;

public class GalleryForOneFling extends Gallery {
	public GalleryForOneFling(Context context, AttributeSet attrs) {
		super(context, attrs);
		
	}
	
	
	@Override
	public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
			float velocityY) {

		int position = getSelectedItemPosition();
		
System.out.println("Gallery view touch ==========");

		if (e2.getX() > e1.getX()) {
			if (position > 0){
				setSelection(position , true);
		//		Main.m_nCurPage = position;
			}
		} else {
			if (position < getCount()){
				setSelection(position , true);
		//		Main.m_nCurPage = position;
				
			}
		}
		
//		super.onFling(e1, e2, 53, velocityY);
//		return false;
		
		return true;

	}
	

}
