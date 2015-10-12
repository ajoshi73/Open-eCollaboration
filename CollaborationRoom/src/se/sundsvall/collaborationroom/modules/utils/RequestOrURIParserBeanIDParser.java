package se.sundsvall.collaborationroom.modules.utils;

import javax.servlet.http.HttpServletRequest;

import se.unlogic.hierarchy.core.utils.crud.BeanIDParser;
import se.unlogic.standardutils.string.StringUtils;
import se.unlogic.webutils.http.URIParser;

public class RequestOrURIParserBeanIDParser implements BeanIDParser<Integer> {

	private String requestParamName;

	public RequestOrURIParserBeanIDParser(String requestParamName) {

		this.requestParamName = requestParamName;
	}

	@Override
	public Integer getBeanID(URIParser uriParser, HttpServletRequest req, String getMode) {

		String param = req.getParameter(requestParamName);

		if (!StringUtils.isEmpty(param)) {

			return Integer.valueOf(req.getParameter(requestParamName));
		}

		return uriParser.getInt(2);
	}

}
