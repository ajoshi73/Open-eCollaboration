package se.samarbetsrum.gislaved.modules;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import se.unlogic.hierarchy.core.annotations.ModuleSetting;
import se.unlogic.hierarchy.core.annotations.TextFieldSettingDescriptor;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.FilterChain;
import se.unlogic.hierarchy.filtermodules.AnnotatedFilterModule;
import se.unlogic.webutils.http.URIParser;

public class SwitchDesignFilterModule extends AnnotatedFilterModule {

	@ModuleSetting
	@TextFieldSettingDescriptor(name = "Design", description = "The design to switch to for this filter", required = true)
	protected String design;

	@Override
	public void doFilter(HttpServletRequest req, HttpServletResponse res, User user, URIParser uriParser, FilterChain filterChain) throws Exception {

		if (design != null) {
			req.setAttribute("preferedDesign", design);
		}

		filterChain.doFilter(req, res, user, uriParser);

	}

}
