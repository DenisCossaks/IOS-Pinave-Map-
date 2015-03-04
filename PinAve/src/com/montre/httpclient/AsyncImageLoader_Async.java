package com.montre.httpclient;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FilterInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.ref.WeakReference;
import java.net.MalformedURLException;
import java.net.URL;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import com.montre.lib.Const;
import com.montre.pinave.R;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.widget.ImageView;


public class AsyncImageLoader_Async{
	public static Context context;
	public float  width;
	public float  height;
	
	
	public AsyncImageLoader_Async(Context mcontext){
		context = mcontext;
	}
	
	public void loadDrawable(String imageUrl, ImageView imageView,float w,float h) {
		width = w;
		height = h;
		 if (cancelPotentialDownload(imageUrl, imageView)) {
			 BitmapDownloaderTask task = new BitmapDownloaderTask(imageView);
	         DownloadedDrawable downloadedDrawable = new DownloadedDrawable(task);
        	 imageView.setImageDrawable(downloadedDrawable);
	         task.execute(imageUrl);
	     }
	}
	
	public void loadDrawable(String imageUrl, ImageView imageView,float w,float h, String _filename) {
		
		File file = new File(Const.FILE_PATH + _filename + ".png");
		if(file.exists() == true) {
			imageView.setImageDrawable(Drawable.createFromPath(Const.FILE_PATH + _filename + ".png"));
			return;
		}
		
		width = w;
		height = h;
		
		 if (cancelPotentialDownload(imageUrl, imageView)) {
			 BitmapDownloaderTask task = new BitmapDownloaderTask(imageView);
	         DownloadedDrawable downloadedDrawable = new DownloadedDrawable(task);
        	 imageView.setImageDrawable(downloadedDrawable);
	         task.execute(imageUrl, _filename);
	     }
	}

	private static boolean cancelPotentialDownload(String url, ImageView imageView) {
	    BitmapDownloaderTask bitmapDownloaderTask = getBitmapDownloaderTask(imageView);
	    if (bitmapDownloaderTask != null) {

	        String bitmapUrl = bitmapDownloaderTask.url;
	        if ((bitmapUrl == null) || (!bitmapUrl.equals(url))) {
	            bitmapDownloaderTask.cancel(true);
	        } else {
	            // The same URL is already being downloaded.
	            return false;
	        }
	    }
	    return true;
	}
	private static BitmapDownloaderTask getBitmapDownloaderTask(ImageView imageView) {
	    if (imageView != null) {
	        Drawable drawable = imageView.getDrawable();
	        if (drawable instanceof DownloadedDrawable) {
	            DownloadedDrawable downloadedDrawable = (DownloadedDrawable)drawable;
	            return downloadedDrawable.getBitmapDownloaderTask();
	        }
	    }
	    return null;
	}
	
	
	static class DownloadedDrawable extends BitmapDrawable {
	    private final WeakReference<BitmapDownloaderTask> bitmapDownloaderTaskReference;
	    public DownloadedDrawable(BitmapDownloaderTask bitmapDownloaderTask) {
	        super(((BitmapDrawable)((Activity)context).getResources().getDrawable(R.drawable.empty)).getBitmap());
	        bitmapDownloaderTaskReference =
	            new WeakReference<BitmapDownloaderTask>(bitmapDownloaderTask);
	    }
//	static class DownloadedDrawable extends ColorDrawable {
//	    private final WeakReference<BitmapDownloaderTask> bitmapDownloaderTaskReference;
//	    public DownloadedDrawable(BitmapDownloaderTask bitmapDownloaderTask) {
//	        super(Color.TRANSPARENT);
//	        bitmapDownloaderTaskReference =
//	            new WeakReference<BitmapDownloaderTask>(bitmapDownloaderTask);
//	    }
     public BitmapDownloaderTask getBitmapDownloaderTask() {
	        return bitmapDownloaderTaskReference.get();
	    }
	}
	static Bitmap downloadBitmap(String url, String _filename) {
		if(url == null || url.equals(""))
		{
			Bitmap bmp = ((BitmapDrawable)((Activity)context).getResources().getDrawable(R.drawable.empty)).getBitmap();
			return bmp;
		}
		url = url.replaceAll(" ", "%20");
	    final HttpClient client = new DefaultHttpClient();
	    final HttpGet getRequest = new HttpGet(url);
	    try {
	        HttpResponse response = client.execute(getRequest);
	        final int statusCode = response.getStatusLine().getStatusCode();
	        if (statusCode != HttpStatus.SC_OK) { 
	            Log.w("ImageDownloader", "Error " + statusCode + " while retrieving bitmap from " + url); 
	            return null;
	        }
	        final HttpEntity entity = response.getEntity();
	        if (entity != null) {
	            InputStream inputStream = null;
	            FlushedInputStream in = null;
	            try {
	                inputStream = entity.getContent(); 
	        		if(inputStream == null)
	        			return null;
	        		
	        		
	        		Bitmap bitmap = null;
	        		bitmap=BitmapFactory.decodeStream(inputStream);
	        		return bitmap;
                   
	            } finally {
	                if (inputStream != null) {
	                    inputStream.close();  
	                }
	               	if(in!=null)
	               		in.close();
	                entity.consumeContent();
	            }
	        }
	    } catch (Exception e) {
	   
	    } finally {
	        /*if (client != null) {
	            client.close();
	        }*/
	    }
	    return null;
	}
	class BitmapDownloaderTask extends AsyncTask<String, Void, Bitmap> {
		private String url;
		private String filename;
		private final WeakReference<ImageView> imageViewReference;
	    public BitmapDownloaderTask(ImageView imageView) {
	    	 imageViewReference = new WeakReference<ImageView>(imageView);
	    }
	    @Override
	    protected Bitmap doInBackground(String... params) {
	    	url = params[0];
	    	
	    	try {
	    	filename = params[1];
	    	} catch (Exception e) {
				filename = null;
			} 
	    	
	    	/*if(url != null && !url.equals("") && Constants.imageCache.containsKey(url)) {
				SoftReference<Bitmap> softReference = Constants.imageCache.get(url);
				Bitmap bmp = null;
				bmp = softReference.get();
				if(bmp==null || bmp.getWidth() <= 0 || bmp.getHeight() <= 0)
				{
					Constants.imageCache.remove(url);
				}
				return bmp;
			}*/
	    	String url1 = url;
	    	
	    	Bitmap	bitmap = downloadBitmap(url1, filename);
	    	
	    	
	    	/*if(bitmap!=null && bitmap.getWidth()>0 && bitmap.getHeight()>0 && url != null && !url.equals(""))
	    		Constants.imageCache.put(url, new SoftReference<Bitmap>(bitmap));*/
	         return bitmap;
	    }
	    @Override
	    protected void onPostExecute(Bitmap bitmap) {
	        if (isCancelled()) {
	            bitmap = null;
	        }
	        
	        if (imageViewReference != null) {

	            ImageView imageView = imageViewReference.get();

	            BitmapDownloaderTask bitmapDownloaderTask = getBitmapDownloaderTask(imageView);

	            if (bitmap!=null) {

	            	Drawable drawable = new BitmapDrawable(bitmap);
	            	Bitmap bmp = changeImageSize(drawable, width, height,0);
	            	if(this == bitmapDownloaderTask)
	            	{
	            		imageView.setImageBitmap(bmp);
	            		
	            		// save file
	            		try {
	            			OutputStream fOut = null;
	            			File file = new File(Const.FILE_PATH, filename+".png");
	                        fOut = new FileOutputStream(file);

	                         bmp.compress(Bitmap.CompressFormat.PNG, 85, fOut);
	                         fOut.flush();
	                         fOut.close();

	                         System.out.println("path = " + file.getAbsolutePath() + " : " + file.getName());
	                         
	                         MediaStore.Images.Media.insertImage(context.getContentResolver(),file.getAbsolutePath(),file.getName(),file.getName());
	            		} catch (Exception e) {
	            			e.printStackTrace();
	            		}
	            	}
	            		
	            		

	            }
	        }
	    }
	}
	
	
	public static Bitmap loadImageFromUrl(String url) {
		
		URL m;
		InputStream i = null;
		try {
			m = new URL(url);
			i = (InputStream)m.getContent();
		
		} catch (MalformedURLException e1) {
			e1.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		if(i==null)
			return null;
		BitmapFactory.Options options=new BitmapFactory.Options();
		options.inSampleSize = 2;
		Bitmap preview_bitmap = null;
		preview_bitmap=BitmapFactory.decodeStream(i);
		try{
			i.close();
			
		}catch(IOException e){}
		
		return preview_bitmap;
	}
	static class FlushedInputStream extends FilterInputStream {
        public FlushedInputStream(InputStream inputStream) {
            super(inputStream);
        }

        @Override
        public long skip(long n) throws IOException {
            long totalBytesSkipped = 0L;
            while (totalBytesSkipped < n) {
                long bytesSkipped = in.skip(n - totalBytesSkipped);
                if (bytesSkipped == 0L) {
                    int b = read();
                    if (b < 0) {
                        break;  // we reached EOF
                    } else {
                        bytesSkipped = 1; // we read one byte
                    }
                }
                totalBytesSkipped += bytesSkipped;
            }
            return totalBytesSkipped;
        }
    }

	
	public interface ImageCallback {
		public void imageLoaded(Drawable imageDrawable, String imageUrl);
	}

	public static Bitmap changeImageSize(Drawable d, float scaleX, float scaleY) {
		Bitmap bmp = null;
		BitmapDrawable bd = (BitmapDrawable) d;
		bmp = bd.getBitmap();
		
		if (bmp != null )
			bmp = Bitmap.createScaledBitmap(bmp, 120, 90, true);
		
		return bmp;
	}
	public static Bitmap changeImageSize(Drawable bmp, float width, float height,int option) {
		
		Bitmap bitmap = Bitmap.createBitmap((int)width, (int)height,Bitmap.Config.ARGB_8888);
		Canvas canvas = new Canvas(bitmap);
		bmp.setBounds(0, 0, (int)width, (int)height);
		bmp.draw(canvas);
		return bitmap;
		
	}

}