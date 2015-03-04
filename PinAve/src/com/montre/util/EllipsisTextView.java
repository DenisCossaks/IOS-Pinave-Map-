package com.montre.util;

import android.content.Context;
import android.text.Layout;
import android.util.AttributeSet;
import android.widget.TextView;

public class EllipsisTextView extends TextView {

	private final static String MAX_LINE_ATTR_NAME = "maxLines";

	private final static String LINES_ATTR_NAME = "lines";

	private int maxLines = -1;

	private int lines = -1;

	private String ellipsisText = "...";

	public EllipsisTextView(Context context) {
		super(context);
	}

	public EllipsisTextView(Context context, AttributeSet attrs) {
		super(context, attrs);

		getAttrValue(attrs);
	}

	public EllipsisTextView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);

		getAttrValue(attrs);
	}

	public void setEllipsisText(String ellipsisText) {

		if (ellipsisText != null) {
			this.ellipsisText = ellipsisText;
		}
	}

	private void getAttrValue(AttributeSet attrs) {

		for (int i = 0; i < attrs.getAttributeCount(); i++) {

			if (MAX_LINE_ATTR_NAME.equals(attrs.getAttributeName(i))) {
				maxLines = attrs.getAttributeIntValue(i, -1);
			} else if (LINES_ATTR_NAME.equals(attrs.getAttributeName(i))) {
				lines = attrs.getAttributeIntValue(i, -1);
			}
		}
	}

	/**
	 * @param maxlines
	 * @see android.widget.TextView#setMaxLines(int)
	 */
	@Override
	public void setMaxLines(int maxlines) {
		super.setMaxLines(maxlines);

		this.maxLines = maxlines;
	}

	public int getMaxLines() {
		return maxLines;
	}

	/**
	 * @param lines
	 * @see android.widget.TextView#setLines(int)
	 */
	@Override
	public void setLines(int lines) {
		super.setLines(lines);

		this.lines = lines;
	}

	public int getLines() {
		return lines;
	}

	private void setText(String text) {
		super.setText(text);
	}

	/**
	 * 
	 * @see android.view.View#onFinishInflate()
	 */
	@Override
	protected void onFinishInflate() {
		super.onFinishInflate();

		post(new Runnable() {

			public void run() {
				ellipsis();
			}
		});
	}

	private void ellipsis() {

		String text = getText().toString();

		if (text != null) {

			int maxLines = getMaxLines();

			int lines = getLines();

			int textLength = text.length();

			if (lines != -1) {
				maxLines = lines;
			}

			String tmpTxt = null;

			if (getLineCount() > maxLines && maxLines != -1) {

				Layout layout = getLayout();

				if (layout != null) {

					
					int idx = layout.getLineEnd(maxLines - 1);

					 
					for (int i = idx - ellipsisText.length(); i < textLength; i++) {

						tmpTxt = text.substring(0, i).trim();

						setText(tmpTxt + ellipsisText);

						if (getLineCount() > maxLines) {
							setText(text.substring(0, i - 1).trim() + ellipsisText);
							break;
						}
					}
				}
			}
		}
	}
}
