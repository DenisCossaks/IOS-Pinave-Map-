package com.montre.db;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.database.sqlite.SQLiteDatabase.CursorFactory;

import com.montre.data.UserLoginInfo;


public class Dao {

	private static final String DATABASE_NAME = "pinave.db";

	private static final int DATABASE_VERSION = 1;

	private static final String TABLE_CURRENT_USER = "CURRENT_USER";
	
	private SQLiteDatabase db;

	private DatabaseHelper dbHelper;

	public Dao(Context context) {
		dbHelper = new DatabaseHelper(context, DATABASE_NAME, null,
				DATABASE_VERSION);
	}

	public void open() {
		db = dbHelper.getWritableDatabase();
	}

	public void close() {
		db.close();
		dbHelper.close();
	}
	
	
	public void newCurrentUser(UserLoginInfo user) {
		if ( user == null )
			return;
		
		ContentValues values = new ContentValues();
		values.put("user_name", user.getUserName());
		values.put("user_email", user.getPassword());
		
		db.insert(TABLE_CURRENT_USER, null, values);
		values = null;
	}
	public UserLoginInfo getCurrentUser() {
		Cursor u = null;
		u = db.query(TABLE_CURRENT_USER, null, null, null, null, null, "currentuser_index");
		
		int nCount = u.getCount();
		if ( nCount == 0 ) {
			u.close();
			return null;
		}
		
		UserLoginInfo user = new UserLoginInfo();
		u.moveToFirst();
		
		user.setUserName(u.getString(1));
		user.setPassword(u.getString(2));
		
		u.close();
		return user;
	}
	
	public boolean deleteCurrentUser() {
		boolean success = false;
		int effectRow = db.delete(TABLE_CURRENT_USER, null, null);
		if ( effectRow > 0)
			success = true;
		return success;
	}
	
	
	
	/*public ArrayList<SectionData> getFavorites() {
		Cursor u = null;
		u = db.query(TABLE_FAVORITES, null, null, null, null, null, "favorites_index");
		
		int nCount = u.getCount();
		if ( nCount == 0 ) {
			u.close();
			return null;
		}
		
		ArrayList<SectionData> array = new ArrayList<SectionData>();
		u.moveToFirst();
		for ( int i = 0; i < nCount; ++i ) {
			SectionData data = new SectionData();
			try {
				data.m_strSection = u.getString(1);
				data.m_strX = u.getString(2);
				data.m_strY = u.getString(3);
				data.m_strDescription = u.getString(4);
				array.add(data);
			} catch (Exception e) {e.printStackTrace();}
			
			u.moveToNext();
		}
		u.close();
		return array;
	}
	
	public ArrayList<SectionData> getRecents() {
		Cursor u = null;
		u = db.query(TABLE_RECENT, null, null, null, null, null, "recent_index");
		
		int nCount = u.getCount();
		if ( nCount == 0 ) {
			u.close();
			return null;
		}
		
		ArrayList<SectionData> array = new ArrayList<SectionData>();
		u.moveToFirst();
		for ( int i = 0; i < nCount; ++i ) {
			SectionData data = new SectionData();
			try {
				data.m_strSection = u.getString(1);
				data.m_strX = u.getString(2);
				data.m_strY = u.getString(3);
				data.m_strDescription = u.getString(4);
				array.add(data);
			} catch (Exception e) {e.printStackTrace();}
			
			u.moveToNext();
		}
		u.close();
		return array;
	}*/
	
	
	
	/*public boolean deleteFavorites(String strSection) {
		boolean success = false;
		int effectRow = db.delete(TABLE_FAVORITES, "favorites_section=?", new String[]{strSection});
		if ( effectRow > 0 )
			success = true;
		return success;
	}
	
	public boolean deleteRecent(String strSection) {
		boolean success = false;
		int effectRow = db.delete(TABLE_RECENT, "recent_section=?", new String[]{strSection});
		if ( effectRow > 0 )
			success = true;
		return success;
	}
	
	public boolean deleteAllFavorites() {
		boolean success = false;
		int effectRow = db.delete(TABLE_FAVORITES, null, null);
		if ( effectRow > 0 )
			success = true;
		return success;
	}
	
	public boolean deleteAllRecent() {
		boolean success = false;
		int effectRow = db.delete(TABLE_RECENT, null, null);
		if ( effectRow > 0)
			success = true;
		return success;
	}*/
	
	

	private static class DatabaseHelper extends SQLiteOpenHelper {

		public DatabaseHelper(Context context, String name,
				CursorFactory factory, int version) {
			super(context, name, factory, version);
		}

		@Override
		public void onCreate(SQLiteDatabase db) {
			/* creat table AppInfo */
			StringBuffer sb = new StringBuffer();
			sb.append("CREATE TABLE ");
			sb.append(TABLE_CURRENT_USER);
			sb.append("(");
			sb.append("currentuser_index INTEGER primary key autoincrement,");
			sb.append("currentuser_name TEXT,");
			sb.append("currentuser_password TEXT,");
			//sb.append("currentuser_message TEXT,");
			sb.append("currentuser_code TEXT");
			sb.append(")");
			db.execSQL(sb.toString());
			
			/*sb.append("CREATE TABLE ");
			sb.append(TABLE_RECENT);
			sb.append("(");
			sb.append("recent_index INTEGER primary key autoincrement,");
			sb.append("recent_section TEXT,");
			sb.append("recent_x TEXT,");
			sb.append("recent_y TEXT,");
			sb.append("recent_description TEXT");
			sb.append(")");
			db.execSQL(sb.toString());
			
			sb = new StringBuffer();
			sb.append("CREATE TABLE ");
			sb.append(TABLE_FAVORITES);
			sb.append("(");
			sb.append("favorites_index INTEGER primary key autoincrement,");
			sb.append("favorites_section TEXT,");
			sb.append("favorites_x TEXT,");
			sb.append("favorites_y TEXT,");
			sb.append("favorites_description TEXT");
			sb.append(")");
			db.execSQL(sb.toString());*/
			
		}

		@Override
		public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		}
	}
}
