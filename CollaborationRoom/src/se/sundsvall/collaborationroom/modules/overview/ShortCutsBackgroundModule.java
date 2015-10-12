package se.sundsvall.collaborationroom.modules.overview;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import se.dosf.communitybase.interfaces.CBInterface;
import se.sundsvall.collaborationroom.modules.overview.beans.ShortCut;
import se.sundsvall.collaborationroom.modules.overview.interfaces.ShortCutProvider;
import se.unlogic.hierarchy.backgroundmodules.AnnotatedBackgroundModule;
import se.unlogic.hierarchy.core.annotations.InstanceManagerDependency;
import se.unlogic.hierarchy.core.beans.SimpleBackgroundModuleResponse;
import se.unlogic.hierarchy.core.beans.User;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleDescriptor;
import se.unlogic.hierarchy.core.interfaces.BackgroundModuleResponse;
import se.unlogic.hierarchy.core.interfaces.SectionInterface;
import se.unlogic.hierarchy.core.utils.MultiForegroundModuleTracker;
import se.unlogic.standardutils.xml.XMLUtils;
import se.unlogic.webutils.http.URIParser;

public class ShortCutsBackgroundModule extends AnnotatedBackgroundModule {

	private MultiForegroundModuleTracker<ShortCutProvider> shortCutProviderTracker;

	@InstanceManagerDependency(required = true)
	private CBInterface cbInterface;

	@Override
	public void init(BackgroundModuleDescriptor descriptor, SectionInterface sectionInterface, DataSource dataSource) throws Exception {

		super.init(descriptor, sectionInterface, dataSource);

		shortCutProviderTracker = new MultiForegroundModuleTracker<ShortCutProvider>(ShortCutProvider.class, systemInterface, sectionInterface, false, true);

	}

	@Override
	public void unload() throws Exception {

		shortCutProviderTracker.shutdown();

		super.unload();
	}

	@Override
	protected BackgroundModuleResponse processBackgroundRequest(HttpServletRequest req, User user, URIParser uriParser) throws Exception {

		Document doc = XMLUtils.createDomDocument();
		Element documentElement = doc.createElement("Document");
		doc.appendChild(documentElement);

		XMLUtils.appendNewElement(doc, documentElement, "ContextPath", req.getContextPath());

		Collection<ShortCutProvider> shortCutProviders = shortCutProviderTracker.getInstances();

		if (shortCutProviders != null) {

			List<ShortCut> shortCuts = new ArrayList<ShortCut>(shortCutProviders.size());

			for (ShortCutProvider provider : shortCutProviders) {

				List<ShortCut> providerShortCuts = provider.getShortCuts(user);

				if (providerShortCuts != null) {

					shortCuts.addAll(providerShortCuts);

				}

			}

			if (shortCuts.isEmpty()) {

				return null;
			}

			Collections.sort(shortCuts);

			XMLUtils.append(doc, documentElement, shortCuts);

		}

		return new SimpleBackgroundModuleResponse(doc);

	}

}
