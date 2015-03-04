package com.custom.gallery;


import com.montre.pinave.R;

import android.content.Context;
import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

class MyGalleryAdapter extends BaseAdapter {

	int[] nIntroImage = {R.drawable.intro_1, R.drawable.intro_2, R.drawable.intro_3, R.drawable.intro_4, R.drawable.intro_5};
	
	Context m_context;
	
	public MyGalleryAdapter(Context context){
		m_context = context;
	}

	public int getCount() {
		// TODO Auto-generated method stub
		return nIntroImage.length;
	}

	public Object getItem(int arg0) {
		// TODO Auto-generated method stub
		return arg0;
	}

	public long getItemId(int arg0) {
		// TODO Auto-generated method stub
		return arg0;
	}

	public View getView(int arg0, View view, ViewGroup arg2) {
		View v = view;

		int page = arg0;
		
		ImageView imgView = null;
		
		if (v == null) {
			LayoutInflater inflater = LayoutInflater.from(m_context);
			v = inflater.inflate(R.layout.layout_gallery, null);
		}

		imgView = (ImageView) v.findViewById(R.id.cell_image);

		imgView.setImageResource(nIntroImage[page]);
		
		return v;
	}

}