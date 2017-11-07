<?xml version="1.0" encoding="UTF-8"?>
<!--
###############################################################################
# format.xsl :: Format to human readable style                                #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# o with XML declaration                                                      #
# o attributes and nodes copied                                               #
# o indentation used                                                          #
###############################################################################
-->

<!-- Start of this transform-sheet -->
<xsl:transform
id="a60d6d1f-16bd-4340-87f4-bdaab7695a38"
version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

<!-- Output Parameters -->
<xsl:output
method="xml"
version="1.0"
encoding="UTF-8"
omit-xml-declaration="no"
indent="yes"
cdata-section-elements=""
media-type="text/xml"
/>

<!-- We do want to preserve space when processing ODT-content -->
<xsl:preserve-space elements="*" />

<!-- Process all attributes and nodes -->
<xsl:template match="@*|node()">
<xsl:copy>
<xsl:apply-templates select="@*|node()" />
</xsl:copy>
</xsl:template>


<!--
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@
@@ MATCH THE DOCUMENT ROOT
@@ ____________________________________________________________________________
@@
@@ A match on '/' matches the *document-root* and not the *root-element*.
@@ This means there is no current node yet and everything emitted here would
@@ precede the content emitted by processing the root-element.
@@
@@ To have more control over over the general transformation, the real
@@ processing is delegated to a named template. This allows easy switching to
@@ another named template with different processing rules.
@@
@@ Named templates can be regarded as library templates.
@@ To separate the 'matching' part from the 'library' part, named templates
@@ are located *below* this initial matching of the document root.
@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-->
<xsl:template match="/">
<xsl:call-template name="main" />
</xsl:template>


<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main operations variant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="main">
<xsl:call-template name="header" />
<xsl:call-template name="format" />
</xsl:template>


<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The header for this generated document
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="header">
<xsl:comment>!! GENERATED DOCUMENT !!</xsl:comment>
<xsl:comment>
###############################################################################
# A processed version for human readability ~~ Not used for input !
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# The original 'content.xml' is one long line, which is needed to preserve all
# white space and don't let newlines and indentation interfere. With regard to
# the elements in 'content.xml', there are many which are simply empty because
# they are 'left overs' from previous formatting actions done by the user when
# editing the ODT document with AOO Writer. Also, Writer, in many cases,
# generates a temporary style with a user-defined custom style as its parent.
# Such temporary styles need to be tracked down to their parent to see if this
# is one of the 'ipf-*' custom styles, so the correct IPF markup can be
# generated.
#
# This generated content helps in examining the parts of interest.
#
###############################################################################
</xsl:comment>
</xsl:template>


<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Produce a human readable version of the input-document
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="format">
<xsl:apply-templates select="@*|node()" />
</xsl:template>

</xsl:transform>
