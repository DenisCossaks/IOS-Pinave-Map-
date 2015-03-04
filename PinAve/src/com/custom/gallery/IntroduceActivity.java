package com.custom.gallery;

import com.montre.pinave.R;
import com.montre.pinave.login.HomeActivity;
import com.montre.ui.basic.BasicUI;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;


public class IntroduceActivity extends BasicUI {

	int mode = 0;
//	Button btnFinish = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.intro);

		this.initViews();
		this.initData();
	}

	@Override
	public void initViews() {
		// TODO Auto-generated method stub

/*		
		btnFinish = (Button) findViewById(R.id.btn_right);
		btnFinish.setOnClickListener(new OnClickListener() {
			
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if (mode == 0) {
					
				} else { // first
					startActivity(new Intent(IntroduceActivity.this, HomeActivity.class));
				}
				finish();
			}
		});
*/
		
		GalleryForOneFling m_gallery = (GalleryForOneFling) findViewById(R.id.gallery);
		MyGalleryAdapter m_adapter = new MyGalleryAdapter(this);
		m_gallery.setAdapter(m_adapter);
	
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub

		mode = getIntent().getIntExtra("mode", 0);
		
//		if (mode != 1) { //first
//			btnFinish.setVisibility(View.GONE);
//		}
	}

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		
		if (mode == 0) {
			super.onBackPressed();
		} 
		else {
			startActivity(new Intent(IntroduceActivity.this, HomeActivity.class));
			finish();
		}
		
	}
}
