package se.sundsvall.collaborationroom.modules.link.bens;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.utils.crud.BeanFilter;
import se.unlogic.webutils.http.URIParser;
import se.unlogic.webutils.url.URLRewriter;

public class LinkURLRewriteBeanFilter implements BeanFilter<Link> {

	@Override
	public void beanLoaded(Link bean, HttpServletRequest req, URIParser uriParser, User user) {

		bean.setUrl((URLRewriter.setAbsoluteUrls(bean.getUrl(), req)));
	}

	@Override
	public void beansLoaded(List<? extends Link> beans, HttpServletRequest req, URIParser uriParser, User user) {

		for (Link bean : beans) {

			bean.setUrl((URLRewriter.setAbsoluteUrls(bean.getUrl(), req)));
		}
	}

	@Override
	public void addBean(Link bean, HttpServletRequest req, URIParser uriParser, User user) {

		bean.setUrl((URLRewriter.removeAbsoluteUrls(bean.getUrl(), req)));
	}

	@Override
	public void updateBean(Link bean, HttpServletRequest req, URIParser uriParser, User user) {

		bean.setUrl((URLRewriter.removeAbsoluteUrls(bean.getUrl(), req)));
	}

	@Override
	public void beanAdded(Link bean, HttpServletRequest req, URIParser uriParser, User user) {

	}

	@Override
	public void beanUpdated(Link bean, HttpServletRequest req, URIParser uriParser, User user) {

	}

	@Override
	public void deleteBean(Link bean, HttpServletRequest req, URIParser uriParser, User user) {

	}

	@Override
	public void beanDeleted(Link bean, HttpServletRequest req, URIParser uriParser, User user) {

	}

}
