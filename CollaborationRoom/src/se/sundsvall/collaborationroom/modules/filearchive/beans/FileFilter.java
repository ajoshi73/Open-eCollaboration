package se.sundsvall.collaborationroom.modules.filearchive.beans;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.fileupload.FileItem;

import se.unlogic.standardutils.io.FileUtils;

public class FileFilter implements java.io.FileFilter {

	private List<String> allowedFileTypes;

	public FileFilter(List<String> allowedFileTypes) {

		if (allowedFileTypes != null) {

			this.allowedFileTypes = new ArrayList<String>(allowedFileTypes.size());

			for (String fileType : allowedFileTypes) {

				this.allowedFileTypes.add(fileType.toLowerCase());
			}

		}

	}

	@Override
	public boolean accept(File file) {

		return isValidFilename(file.getName());
	}

	public boolean accept(FileItem fileItem) {

		return isValidFilename(fileItem.getName());
	}

	public boolean isValidFilename(String filename) {

		if (allowedFileTypes == null) {

			return true;
		}
		
		filename = filename.toLowerCase();

		String fileExtension = FileUtils.getFileExtension(filename);

		if (allowedFileTypes.contains(fileExtension)) {

			return true;

		} else {

			return false;
		}
	}
	
	public List<String> getAllowedFileTypes() {
		
		return allowedFileTypes;
	}

}
