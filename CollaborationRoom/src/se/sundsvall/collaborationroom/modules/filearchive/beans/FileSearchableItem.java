package se.sundsvall.collaborationroom.modules.filearchive.beans;

import java.io.FileInputStream;
import java.io.InputStream;
import java.io.Serializable;
import java.util.List;

import se.dosf.communitybase.interfaces.CBSearchableItem;
import se.unlogic.standardutils.io.BinarySizeFormater;
import se.unlogic.standardutils.io.FileUtils;
import se.unlogic.standardutils.mime.MimeUtils;


public class FileSearchableItem implements CBSearchableItem, Serializable{

	private static final long serialVersionUID = 8995181196593630997L;
	
	private final File file;
	private final Category category;
	private final String alias;
	private final java.io.File fileSystemFile;

	public FileSearchableItem(File file, Category category, String alias, java.io.File fileSystemFile) {

		super();
		this.file = file;
		this.category = category;
		this.alias = alias;
		this.fileSystemFile = fileSystemFile;
	}

	@Override
	public String getID() {

		return file.getFileID().toString();
	}

	@Override
	public String getAlias() {

		return alias;
	}

	@Override
	public String getTitle() {

		return file.getFilename();
	}

	@Override
	public String getInfoLine() {

		StringBuilder stringBuilder = new StringBuilder();
		
		stringBuilder.append(FileUtils.getFileExtension(file.getFilename()).toUpperCase());
		
		stringBuilder.append(" · ");
		
		stringBuilder.append(BinarySizeFormater.getFormatedSize(fileSystemFile.length()));
		
		stringBuilder.append(" · ");
		
		stringBuilder.append(category.getName());
		
		return stringBuilder.toString();
	}

	@Override
	public String getContentType() {

		return MimeUtils.getMimeType(file.getFilename());
	}

	@Override
	public InputStream getData() throws Exception {
		
		return new FileInputStream(fileSystemFile);
	}

	@Override
	public String getType() {

		return "file";
	}

	@Override
	public List<String> getTags() {

		return file.getTags();
	}

	@Override
	public String toString() {

		return file.toString();
	}

}
