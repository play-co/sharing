package com.tealeaf.plugin.plugins;
import java.util.Map;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import com.tealeaf.EventQueue;
import com.tealeaf.TeaLeaf;
import com.tealeaf.logger;
import android.content.pm.PackageManager;
import android.content.pm.ApplicationInfo;
import android.os.Bundle;

import android.location.Location;
import android.net.Uri;
import android.os.Environment;
import java.io.File;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import java.io.FileOutputStream;
import java.io.IOException;
import android.util.Base64;

import com.tealeaf.plugin.IPlugin;
import com.tealeaf.plugin.PluginManager;
import android.app.Activity;

import android.content.Intent;
import android.content.Context;
import android.util.Log;

import com.tealeaf.EventQueue;
import com.tealeaf.event.*;

public class SharingPlugin implements IPlugin {
	public class ShareCompletedEvent extends com.tealeaf.event.Event {
		boolean completed;

		public ShareCompletedEvent(boolean completed) {
			super("completed");
			this.completed = completed;
		}
	}

	private Activity _activity;
	private Context _ctx;
	private String _sharedImagePath = null;
	private Integer _shareActivityResultId = 999;
	private Integer _requestId = null;
	private String _tempFilename = "devkit-share-tmp.png";

	public SharingPlugin() {
	}

	public void onCreateApplication(Context applicationContext) {
		_ctx = applicationContext;
	}

	public void onCreate(Activity activity, Bundle savedInstanceState) {
		_activity = activity;
	}

	public void onResume() {
	}

	public void onStart() {
	}

	public void onPause() {
	}

	public void onStop() {
	}

	public void onDestroy() {
	}

	public void onNewIntent(Intent intent) {
	}

	public void setInstallReferrer(String referrer) {
	}

	public void onActivityResult(Integer request, Integer result, Intent data) {
		// share is finished
		if (request.equals(_shareActivityResultId)) {
			logger.log("{sharing} Activity Result", result);
			// tell javascript the share completed
			PluginManager.sendResponse(
					new ShareCompletedEvent(true),
					null,
					_requestId
				);

			// clean up local image
			// commented out for now because this can happen before the share
			// actually finishes, in which case this removes the image before
			// the sharing activity is finished with it
			// if (_sharedImagePath != null) {
			// 	try {
			// 		logger.log("{sharing} Deleting local temp share file");
			// 		File imageFileToShare = new File(_sharedImagePath);
			// 		imageFileToShare.delete();
			// 	} catch (Exception e) {
			// 		logger.log("{sharing} Exception deleting image share file:", e);
			// 		e.printStackTrace();
			// 	}
			// }
		}
	}

	public boolean consumeOnBackPressed() {
		return true;
	}

	public void onBackPressed() {
	}

	// from http://stackoverflow.com/a/17506538/1279574
	public Bitmap bitmapFromBase64(String input) {
		// TODO: check mime type
		// assume png for now -- "data:image\/png;base64,....."
		Integer commaIndex = input.indexOf(",");
		String imageDataBytes = input;
		if (commaIndex > 0) {
			imageDataBytes = input.substring(commaIndex + 1);
		}

		byte[] decodedByte = Base64.decode(imageDataBytes, 0);
		return BitmapFactory.decodeByteArray(decodedByte, 0, decodedByte.length);
	}

	// from http://stackoverflow.com/a/21590345/1279574
	private Uri saveImageLocally(Bitmap bitmap) {
		File outputDir = Environment.getExternalStoragePublicDirectory(
				Environment.DIRECTORY_DOWNLOADS
			);
		// File outputFile = null;
		// try {
			// this will create a new file every time, and potentially
			// flood the user's storage
			// outputFile = File.createTempFile(
			// 		"devkit-share-tmp", ".png", outputDir
			// 	);
		// } catch (IOException e) {
			// logger.log("{sharing} exception creating temporary file: ", e);
			// return null;
		// }

		// create the same file over and over (and for every app)
		// TODO: allow app to specify filename? (safely?)
		File outputFile = new File(outputDir, _tempFilename);

		Uri uri = null;
		try {
			FileOutputStream out = new FileOutputStream(outputFile);
			bitmap.compress(Bitmap.CompressFormat.PNG, 90, out);
			out.close();

			// save file path and create uri for sharing
			_sharedImagePath = outputFile.getAbsolutePath();
			uri = Uri.parse(outputFile.toURI().toString());
		} catch (Exception e) {
			logger.log("{sharing} exception writing bitmap: ", e);
			return null;
		}

		logger.log("{sharing} -- saved bitmap in sharable location", uri);
		return uri;
	}

	public void share(String jsonData, final Integer requestId) {
		logger.log("{sharing} - share requested");
		_requestId = requestId;

		String image = "";
		String url = "";
		String title = "Share"; // TODO: i18n default
		String instructions = "";
		Bitmap bitmap;
		Uri uri = null;
		boolean failed = true;

		try {
			JSONObject jsonObject = new JSONObject(jsonData);
			String message = "";
			if (jsonObject.has("message")) {
				message = jsonObject.getString("message");
			}

			if (jsonObject.has("title")) {
				title = jsonObject.getString("title");
			}

			if (jsonObject.has("instructions")) {
				instructions = jsonObject.getString("instructions");
			}

			if (jsonObject.has("url")) {
				url = jsonObject.getString("url");
				message += " "+ url;
			}

			if (jsonObject.has("image")) {
				image = jsonObject.getString("image");
			}

			if (jsonObject.has("filename")) {
				_tempFilename = jsonObject.getString("filename");
			}

			Intent sendIntent = new Intent();
			sendIntent.setAction(Intent.ACTION_SEND);
			sendIntent.putExtra(Intent.EXTRA_TEXT, message);
			sendIntent.setType("text/plain");

			// add title as EXTRA_SUBJECT
			if (title != "") {
				sendIntent.putExtra(Intent.EXTRA_SUBJECT, title);
			}

			// write image to shareable path
			if (image != "") {
				_sharedImagePath = null;
				uri = null;
				logger.log("{sharing} - creating bitmap from base 64 content");
				bitmap = bitmapFromBase64(image);
				if (bitmap != null) {
					uri = saveImageLocally(bitmap);
					logger.log("{sharing} - saving image in shared location:", uri);
				} else {
					logger.log("{sharing} - failed to create bitmap");
				}

				if (uri != null) {
					logger.log("{sharing} - adding image to share", uri);
					// add path to sharable image
					sendIntent.putExtra(Intent.EXTRA_STREAM, uri);
					sendIntent.setType("image/png");
				}
			}

			// user instructions if available, else fallback to title
			String chooserTitle;
			if (instructions != "") {
				chooserTitle = instructions;
			} else {
				chooserTitle = title;
			}

			// open share chooser
			logger.log("{sharing} - starting share intent");
			this._activity.startActivityForResult(
					Intent.createChooser(
						sendIntent,
						chooserTitle
					),
					_shareActivityResultId
				);
			// TODO: what constitues failing?
			failed = false;

		} catch (Exception e) {
			logger.log("{sharing} Exception while sharing", e);
			e.printStackTrace();
		}

		// notify of failures now
		if (failed) {
			PluginManager.sendResponse(
					new ShareCompletedEvent(!failed),
					null,
					requestId
				);
		}
	}
}

