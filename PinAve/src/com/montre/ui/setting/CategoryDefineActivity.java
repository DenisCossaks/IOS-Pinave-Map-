package com.montre.ui.setting;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.xmlpull.v1.XmlPullParserException;

import com.montre.data.CategoryInfo;
import com.montre.data.Setting;
import com.montre.data.Share;
import com.montre.data.UserInfo;
import com.montre.data.UserLoginInfo;
import com.montre.data.Utils;
import com.montre.lib.Const;
import com.montre.pinave.R;
import com.montre.pindetail.ReviewActivity;
import com.montre.ui.basic.BasicUI;

import android.app.DatePickerDialog;
import android.app.Dialog;
import android.app.TimePickerDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.ExpandableListView.OnChildClickListener;

public class CategoryDefineActivity extends BasicUI {

	private ListView lvList = null;
	private ResultListAdapter adapter = null;

	String[][] arrDefinition = new String[][] {
			{
					"Accommodation",
					"The Accommodation pin represents properties for rental, sharing or sale.   For example Units, apartments, houses, hostel, backpackers, hotels, villas, etc." },
			{
					"Cars & Bikes",
					"Cars and Bikes pins represents registered automotive vehicles or bicycles for sale, sharing or rental.      For example cars, 4WDs, vans, utes, motorcycles, scooter bicycles, etc." },
			{
					"Events & Parties",
					"Events and Parties pin represents Event or Party at the listed paces. These pins are posted by your local community or an event organiser. For example Shows, Fairs, Musicals, Broadways, concerts, Sporting events, Fund raising, Parties, Clubbing, etc." },
			{
					"Food & Drinks",
					"Food & Drinks pins represents a promotion or specials from restaurant, bistro, eatery, pubs, or specialist cuisine such as Korean, Chinese, Filipino, French, European or other International cuisines offering promotions." },
			{
					"Garage Sales",
					"The Garage Sale pins are placed by locals and residents who are moving out and would like to reduce the household items as 'Going Home' sale; or simply by residents who might have bought excessive items and would like to sell some items for some cash." },
			{
					"Health & Beauty",
					"Health and Beauty pins are placed by local Salons, beauty therapists, massage parlour, hair stylists, makeup artists, hairdressers etc. who are currently promoting a special." },
			{
					"Homely Made",
					"Homely Made pins are placed by highly skilled residents in making, creating or preparing state of the art items or produce. Sometimes they might make, create or produce enough to share with the local community." },
			{
					"Jobs",
					"Jobs pin represents a job vacancy. Local restaurants or businesses that are after immediate assistance would opt for this avenue. Watch this pin!" },
			{
					"Leisure",
					"Leisure pins represents social events, gatherings and casual chats. Share, discover and meet people with the same hobbies and interests." },
			{
					"Parking",
					"The Parking Pin represents the availability of seasonal, permanent, temporary, short term, long-term parking at a particular address." },
			{
					"On Sale!",
					"On Sale pins are placed by local businesses to promote item(s) on sale. It could be your favourite nearby store, or an item you have been eyeing on at the nearby corner shop. These pins indicate current sales." },
			{
					"Wanted",
					"Locals who are after a specific item would place the Wanted pins. For example, if you require a replacement for a 286 Motherboard to play your favourite game, you may post a Wanted pin. Who knows, your next-door neighbour might dig up their dusty cabinet." },
			{
					"Daily Deals",
					"Daily Deals pins represents group buying deals from your local businesses. Group buying deals are promotions that become effective when a certain number of people commit to purchase the goods or services. The group cooperation sometimes yield discount of up to 80% off the retail prices." },
			{
					"I'll Pay for",
					"The I'll Pay For pins are placed by people who require a service and willing to pay someone to assist. For example, if you require someone to mow your lawn or wash your car for $50, you can post this pin and wait for someone to contact you; while you proceed with your busy schedules." }, };

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.setting_category_define);

		this.initViews();
		this.initData();
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
    	
		lvList = (ListView) findViewById(R.id.lv_list);

		boundAdapter();
	}

	@Override
	public void initData() {
		// TODO Auto-generated method stub

	}

	public void boundAdapter() {

		adapter = new ResultListAdapter(CategoryDefineActivity.this, lvList);
		lvList.setAdapter(adapter);
		adapter.notifyDataSetChanged();
	}

	public class ResultListAdapter extends BaseAdapter {
		private Context mContext = null;
		private ListView listView1;

		public ResultListAdapter(Context mContext,
				ListView listView1) {
			this.mContext = mContext;
			this.listView1 = listView1;
		}

		@Override
		public int getCount() {
			return arrDefinition.length;
		}

		@Override
		public String[] getItem(int position) {
			return arrDefinition[position];
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView,
				ViewGroup parent) {
			View view = convertView;
			ViewCache cache;

			if (view == null) {
				LayoutInflater inflater = LayoutInflater.from(mContext);
				view = inflater.inflate(R.layout.list_content_category_define, null);
				cache = new ViewCache(view);
				view.setTag(cache);
			} else {
				cache = (ViewCache) view.getTag();
			}

			final String[] item = arrDefinition[position];

			if (item == null)
				return view;

			ImageView ivCategory = (ImageView) view
					.findViewById(R.id.cell_image);
			TextView title = (TextView) view.findViewById(R.id.cell_title);
			TextView content = (TextView) view.findViewById(R.id.cell_address);
			
			int resId = Const.getResouceId(item[0]);
			if (resId != 0) {
				ivCategory.setBackgroundResource(resId);
				ivCategory.setVisibility(View.VISIBLE);
			} else {
				ivCategory.setVisibility(View.INVISIBLE);
			}

			String name = item[0];
			title.setText(name);
			
			content.setText(item[1]);			
			

			return view;

		}

	}

	class ViewCache {
		private View view;

		// private WebView iconWebView = null;

		public ViewCache(View view) {
			this.view = view;
		}

		// public WebView getWebView() {
		// if (iconWebView == null) {
		// iconWebView = (WebView) view
		// .findViewById(R.id.iconWebView);
		// }
		// return iconWebView;
		// }
	}

	
}
