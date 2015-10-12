<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" version="4.0" encoding="ISO-8859-1" />

	<xsl:template match="Document">
		
		<div id="FirstLoginBackgroundModule" data-of-modal="welcome" class="of-modal">
		
			<a data-of-open-modal="welcome" class="of-hidden" />
			
			<a class="of-close of-icon of-icon-only" data-of-close-modal="welcome" href="#">
				<i><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512"><use xlink:href="#close"></use></svg></i>
				<span><xsl:value-of select="$i18n.Close" /></span>
			</a>

			<div>
				<xsl:value-of select="welcomeMessage" disable-output-escaping="yes" />			
			</div>

			<footer class="of-text-right">
				<a class="of-btn of-btn-inline of-btn-gronsta" data-of-close-modal="welcome" href="#"><xsl:value-of select="$i18n.OK" /></a>
			</footer>

			<script type="text/javascript">
				$(document).ready(function() {
					$("a[data-of-open-modal='welcome']").trigger("click");
				});
			</script>

		</div>
		
	</xsl:template>
	
</xsl:stylesheet>