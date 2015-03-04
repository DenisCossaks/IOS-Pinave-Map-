package com.montre.httpclient;

import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.SoftReference;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Message;

public class AsyncImageLoader {
	public static Context context;

	private HashMap<String, SoftReference<Drawable>> imageCache;

	public AsyncImageLoader() {
		imageCache = new HashMap<String, SoftReference<Drawable>>();
	}

	public Drawable loadDrawable(final String imageUrl,
			final ImageCallback imageCallback) {
		if (imageCache.containsKey(imageUrl)) {
			SoftReference<Drawable> softReference = imageCache.get(imageUrl);
			Drawable drawable = softReference.get();
			if (drawable != null) {
				return drawable;
			}
		}
		final Handler handler = new Handler() {
			public void handleMessage(Message message) {
				imageCallback.imageLoaded((Drawable) message.obj, imageUrl);
			}
		};

		new Thread() {
			@Override
			public void run() {
				Drawable drawable = loadImageFromUrl(imageUrl);
				imageCache.put(imageUrl, new SoftReference<Drawable>(drawable));
				Message message = handler.obtainMessage(0, drawable);
				handler.sendMessage(message);
			}
		}.start();
		return null;
	}

	/**
	 * this method won't check the url
	 * 
	 * @param url
	 * @return
	 */
	public static Drawable loadImageFromUrl(String url) {
		Drawable d = null;
		URL m;
		InputStream i = null;
		try {
			m = new URL(url);
			i = (InputStream) m.getContent();
		} catch (MalformedURLException e1) {
			e1.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		BitmapFactory.Options options=new BitmapFactory.Options();
		options.inSampleSize = 1;
		Bitmap preview_bitmap=BitmapFactory.decodeStream(i,null,options);
		
		d = new BitmapDrawable(preview_bitmap);
		//d = Drawable.createFromStream(i, "src");
		return d;
	}

	/**
	 * this method will check the url
	 * 
	 * @author qukers
	 * 
	 */
	// public static Drawable loadImageFromUrl(String url) {
	// boolean urlCorrect = HttpConnectionUtil.checkUriExist(context, url);
	// Drawable d = null;
	// if(urlCorrect){
	// URL m;
	// InputStream i = null;
	// try {
	// m = new URL(url);
	// i = (InputStream) m.getContent();
	// } catch (MalformedURLException e1) {
	// e1.printStackTrace();
	// } catch (IOException e) {
	// e.printStackTrace();
	// }
	// d = Drawable.createFromStream(i, "src");
	// }else{
	// d = context.getResources().getDrawable(R.drawable.image_error);
	// }
	// return d;
	// }

	public interface ImageCallback {
		public void imageLoaded(Drawable imageDrawable, String imageUrl);
	}

	/**
	 * to change the image size ,from drawable to bitmap
	 * 
	 * @param d
	 * @param scaleX
	 * @param scaleY
	 * @return
	 */
	public static Bitmap changeImageSize(Drawable d, float scaleX, float scaleY) {
		Bitmap bmp = null;
		BitmapDrawable bd = (BitmapDrawable) d;
		bmp = bd.getBitmap();
		Matrix m = new Matrix();
		m.postScale(scaleX, scaleY);
		/*bmp = Bitmap.createBitmap(bmp, 0, 0, bmp.getWidth(), bmp.getHeight(),
				m, true);*/
		if (bmp != null )
			bmp = Bitmap.createScaledBitmap(bmp, 120, 90, true);
		return bmp;
	}

}