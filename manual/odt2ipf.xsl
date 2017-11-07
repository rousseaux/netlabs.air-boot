<?xml version="1.0" encoding="UTF-8"?>
<!--
###############################################################################
# odt2ipf.xsl :: Transform an AOO ODT-document to an OS/2 INF-document        #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# This transformation-sheet takes the 'content.xml' file from an AOO Document #
# and generates an '.ipf' document that can be compiled to an '.inf' document #
# which can then be viewed with OS/2 (New)View.                               #
###############################################################################
-->

<!--
// The basic steps are the following:
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// o Explode the ODT to a directory with UNZIP
// o Transform 'content.xml' to '.ipf' with XSLTPROC
// o Compile the '.ipf' to '.inf' with WIPFC
-->

<!--
// About the ODT Document
// ~~~~~~~~~~~~~~~~~~~~~~
// The ODT-document is the source for both the PDF and the INF versions of the
// AiR-BOOT Manual. It contains custom styles with the prefix 'ipf-' which are
// used to style the document content. The custom 'ipf-*' styles are matched
// by the XSL-templates defined in this transformation-sheet which then
// generate IPF-markup. These custom 'ipf-*' styles exists for both paragraph
// and character styles.
//
// It is mandatory to use the 'ipf-*' styles to have the markup be correctly
// propagated to the IPF-document. So, using the 'bold-button' to make some
// text bold will *not* propagate to the IPF-document. This is because
// OpenOffice Writer uses _automatic_ styles derived from _builtin_ styles,
// and these automatic names are generated on-the-fly.
//
// Using the custom 'ipf-*' styles will put the correct name in the tag, so
// that the XSL-templates can match on them.
//
// For images, the IPF ':artwork' tag is used with the 'runin' modifier. While
// this allows for more control of the spacing, it is sometimes necessary to
// have a blank line in the ODT-document that does not get propagated to the
// IPF-document. This can be done applying the 'Default' paragraph style in the
// ODF-document, which is not an 'ipf-*' style and thus generates nothing.
//
// update.201710171232
// Partially resolved the issue with automatic styles by tracking the parent
// style and calling the corresponding match-template by name.
-->

<!--
// About the XSLT Transformation
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// The transformation is kept relatively simple with the sole purpose of
// creating an INF-document with acceptable presentation and a layout that
// mimics the layout of the PDF version. It is not the purpose of this
// transformation to address the full capabilities of IPF-markup or the meta
// content of an ODT-document.
-->

<!--
// About Indentation
// ~~~~~~~~~~~~~~~~~
// This transformation-sheet does not use elaborate indentation.
// The reason is that the output document is a flat-text document (.ipf) and
// using indentation can propagate undesired white-space to the output document
// depending on what processing is used.
-->

<!--
// Conventions
// ~~~~~~~~~~~
// Match Templates have header-comments using '=='.
// Named Templates have header-comments using '%%'.
// The Main Match Template uses '@@' for its header-comment.
-->

<!--
// IPF Colors
// ~~~~~~~~~~
// o default
// o black
// o blue
// o red
// o pink
// o green
// o cyan
// o yellow
// o neutral
// o brown
// o darkgray
// o darkblue
// o darkred
// o darkpink
// o darkgreen
// o darkcyan
// o palegray
-->

<!--
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Below is the actual start of the transformation-sheet.                    ::
:: The namespaces are required to recognize the various OpenOffice tags.     ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-->
<xsl:transform
version="1.0"
id="53ec6dc0-05e3-4932-911a-d99c295fcf31"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
xmlns:math="http://www.w3.org/1998/Math/MathML"
xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
xmlns:ooo="http://openoffice.org/2004/office"
xmlns:ooow="http://openoffice.org/2004/writer"
xmlns:oooc="http://openoffice.org/2004/calc"
xmlns:dom="http://www.w3.org/2001/xml-events"
xmlns:xforms="http://www.w3.org/2002/xforms"
xmlns:xsd="http://www.w3.org/2001/XMLSchema"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:rpt="http://openoffice.org/2005/report"
xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:grddl="http://www.w3.org/2003/g/data-view#"
xmlns:tableooo="http://openoffice.org/2009/table"
xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0"
xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0"
xmlns:css3t="http://www.w3.org/TR/css3-text/"
>

<!--
// These are the parameters for this transformation-sheet and their default
// values. These values can be overridden by passing parameters to XSLTPROC.
// Example: xsltproc ~~stringparam doctitle "My Document Title"
//          (note: the ~~ above of course need to be two dashes)
-->

<xsl:param name="basename">airboot</xsl:param>
<xsl:param name="doctitle">AiR-BOOT User Manual</xsl:param>
<xsl:param name="toclevels">12</xsl:param>
<xsl:param name="imgdirprefix">AiR-BOOT-Manual.odtx</xsl:param>

<!--
// Define some variables.
-->
<xsl:variable name="default-text-font">WarpSans</xsl:variable>
<xsl:variable name="default-code-font">WarpSans</xsl:variable>
<xsl:variable name="default-commands-font">WarpSans</xsl:variable>

<!--
// Define Output Parameters.
-->
<xsl:output
method="text"
version="1.0"
encoding="utf-8"
omit-xml-declaration="no"
standalone="yes"
indent="no"
media-type="text/xml"
/>


<!--
// This strips white-space between XML elements when processing the input
// document. For ODT we don't want that because the XML content is a mixture
// of nested elements most of which can have content. An example would be
// 'span' tags inside 'p' tags where the 'span' tags are separated by spaces.
// These spaces are actual content of the 'p' tag. Enabling the stripping of
// spaces would remove these spaces and thus alter the textual content of the
// 'p' tag. Stripping white-space has its use in other scenarios, removing
// leading spaces when generating code for instance.
// For ODT to IPF transformation we disable it by commenting out the directive.
-->
<!--
<xsl:strip-space elements="*" />
-->


<!--
===============================================================================
== Handle unmatched tags
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== When no template is found that matches an encountered tag, processing ends
== up here. Nothing is emitted which has the effect that the tag is ignored.
== The 'apply-templates' enables further processing, so that handled tags that
== are children of unhandled tags do get processed. Because we use modes for
== different processing paths, each path needs to have its own 'match-all'
== template.
===============================================================================
-->

<!-- Process default unhandled tags -->
<xsl:template match="*">
<!--
<xsl:value-of select="name()" />
-->
<xsl:apply-templates />
</xsl:template>

<!-- Process unhandled tags for the 'center' processing path -->
<xsl:template match="*" mode="center">
<!--
<xsl:value-of select="name()" />
-->
<xsl:apply-templates mode="center" />
</xsl:template>

<!-- Process unhandled tags for unordered lists -->
<xsl:template match="*" mode="ul">
<!--
<xsl:value-of select="name()" />
-->
<xsl:apply-templates mode="ul" />
</xsl:template>

<!-- Process unhandled tags for ordered lists -->
<xsl:template match="*" mode="ol">
<!--
<xsl:value-of select="name()" />
-->
<xsl:apply-templates mode="ol" />
</xsl:template>



<!--
===============================================================================
== Match Line Breaks
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== This IPF-tag needs to be on a line of its own.
== Because no 'xsl:text' embedding is used, the newlines after the template
== opening and after the '.br' are emitted to the output. An line break is not
== the same as an empty paragraph, which would emit a ':p.' tag resulting in
== a blank line.
===============================================================================
-->
<xsl:template match="text:line-break">
.br
<xsl:apply-templates/>
</xsl:template>





<!--
===============================================================================
== Match Heading
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== This style is used for the first page of the manual.
== Note that contrary to its name, it is not an OOo true heading-style because
== it has no outline level, it is just a paragraph style. It is used to display
== the text on the document title page aligned to the center. Center aligning
== in IPF is not easy because '.ce' only operates on lines and cannot handle
== tags and ':lines.' is broken because it emits trailing blank lines and
== interprets newlines verbatim. A special ODT style in combination with
== special 'mode="center"' templates is used to work around this.
===============================================================================
-->
<xsl:template match="text:p[@text:style-name='Heading']">
<xsl:text>:hp2.:color fc=darkgray.:font facename="Workplace Sans" size=40x40.</xsl:text>
<xsl:apply-templates mode="center" />
<xsl:text>:color fc=default.:font facename=default.:ehp2.</xsl:text>
</xsl:template>



<!--
===============================================================================
== Match Outline Level 1
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== This template matches an ODT heading-style and uses the 'outline-level'
== attribute to generate the corresponding IPF ':h?.' tag. This means it
== accepts *any* ODT style which has an 'outline level' is defined.
== For the ODT-document this style is used for TOC creation and for IPF this
== style defines its place in the tree structure. Note that levels above 1
== depend on the value of the ':docprof' marker, which is by default 'toc=12.'
===============================================================================
-->
<xsl:template match="text:h[@text:outline-level='1']">
<xsl:text>&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>
.*__________________________________________________________________________[<xsl:value-of select="@text:outline-level"/>] |<xsl:value-of select="."/>|
.*
:h<xsl:value-of select="@text:outline-level"/>.<xsl:value-of select="."/>
.*_____________________________________________________________________________
:p.
<!--
:hp2.:color fc=darkblue.:font facename='<xsl:value-of select="$default-text-font"/>' size=17x17.<xsl:value-of select="."/>:font facename=default.:color fc=default.:ehp2.
-->
:color fc=darkblue.:font facename='WarpSans'.<xsl:value-of select="."/>:font facename=default.:color fc=default.
</xsl:template>

<!--
===============================================================================
== Match Outline Level 2 :: See level 1 for comments
===============================================================================
-->
<xsl:template match="text:h[@text:outline-level='2']">
<xsl:text>&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>
.*==========================================================================[<xsl:value-of select="@text:outline-level"/>] |<xsl:value-of select="."/>|
:h<xsl:value-of select="@text:outline-level"/>.<xsl:value-of select="."/>
.*=============================================================================
:p.
<!--
:hp2.:color fc=darkblue.:font facename='<xsl:value-of select="$default-text-font"/>' size=15x15.<xsl:value-of select="."/>:font facename=default.:color fc=default.:ehp2.
-->
:color fc=darkblue.:font facename='Helv' size=15x15.<xsl:value-of select="."/>:font facename=default.:color fc=default.
</xsl:template>

<!--
===============================================================================
== Match Outline Level 3 :: See level 1 for comments
===============================================================================
-->
<xsl:template match="text:h[@text:outline-level='3']">
<xsl:text>&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>
.*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~[<xsl:value-of select="@text:outline-level"/>] |<xsl:value-of select="."/>|
:h<xsl:value-of select="@text:outline-level"/>.<xsl:value-of select="."/>
.*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:p.
:hp2.:color fc=darkgray.:font facename='<xsl:value-of select="$default-text-font"/>' size=14x14.<xsl:value-of select="."/>:font facename=default.:color fc=default.:ehp2.
</xsl:template>

<!--
===============================================================================
== Match Outline Level 4 :: See level 1 for comments
===============================================================================
-->
<xsl:template match="text:h[@text:outline-level='4']">
<xsl:text>&#10;</xsl:text>
<xsl:text>&#10;</xsl:text>
.*--------------------------------------------------------------------------[<xsl:value-of select="@text:outline-level"/>] |<xsl:value-of select="."/>|
:h<xsl:value-of select="@text:outline-level"/>.<xsl:value-of select="."/>
.*-----------------------------------------------------------------------------
:p.
:hp5.:font facename='<xsl:value-of select="$default-text-font"/>' size=14x14.<xsl:value-of select="."/>:font facename=default.:ehp5.
</xsl:template>

<!--
===============================================================================
== Match Outline Level 5 :: See level 1 for comments
===============================================================================
-->
<xsl:template match="text:h[@text:outline-level='5']">
<xsl:text>&#10;</xsl:text>
:h<xsl:value-of select="@text:outline-level"/>.<xsl:value-of select="."/>
.***************************************************************************[<xsl:value-of select="@text:outline-level"/>] |<xsl:value-of select="."/>|
:p.
<!--
:font facename='<xsl:value-of select="$default-text-font"/>' size=14x14.[ <xsl:value-of select="."/> ]:font facename=default.
-->
:color fc=darkblue.:font facename='<xsl:value-of select="$default-text-font"/>' size=14x14.<xsl:value-of select="."/>:font facename=default.:color fc=default.
</xsl:template>

<!--
===============================================================================
== Match Outline Level 6 :: See level 1 for comments
===============================================================================
-->
<xsl:template match="text:h[@text:outline-level='6']">
<xsl:text>&#10;</xsl:text>
:h<xsl:value-of select="@text:outline-level"/>.<xsl:value-of select="."/>
.*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++[<xsl:value-of select="@text:outline-level"/>] |<xsl:value-of select="."/>|
:p.
<!--
:lm margin=5.:font facename='<xsl:value-of select="$default-text-font"/>' size=14x14.| <xsl:value-of select="."/> |:font facename=default.:lm margin=default.
-->
<!--
:lm margin=5.:color fc=darkblue.:font facename='default' size=14x14.:hp1.<xsl:value-of select="."/>:ehp1.:font facename=default.:color fc=default.:lm margin=default.
-->
:lm margin=5.:color fc=darkblue.:font facename='default' size=14x14.<xsl:value-of select="."/>:font facename=default.:color fc=default.:lm margin=default.
</xsl:template>


<!--
===============================================================================
== Match Topic Level 1
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== Sometimes we want the 'level 1' attributes but have IPF not see it as a new
== section. That is what these 'topic' styles are for. They use the same
== attributes as the corresponding 'outline' style but omit the ':h?' marker
== and thus do not start a new section. Additionally, they have a name which is
== used when resolving automatic styles.
===============================================================================
-->
<xsl:template name="topic-level-1" match="text:p[@text:style-name='topic-level-1']">
:p.
<!--
:hp2.:color fc=darkblue.:font facename='<xsl:value-of select="$default-text-font"/>' size=17x17.<xsl:value-of select="."/>:font facename=default.:color fc=default.:ehp2.
-->
:color fc=darkblue.:font facename='WarpSans'.<xsl:value-of select="."/>:font facename=default.:color fc=default.
</xsl:template>

<!--
===============================================================================
== Match Topic Level 2 :: See level 1 for comments
===============================================================================
-->
<xsl:template name="topic-level-2" match="text:p[@text:style-name='topic-level-2']">
:p.
<!--
:hp2.:color fc=darkblue.:font facename='<xsl:value-of select="$default-text-font"/>' size=15x15.<xsl:value-of select="."/>:font facename=default.:color fc=default.:ehp2.
-->
:color fc=darkblue.:font facename='Helv' size=15x15.<xsl:value-of select="."/>:font facename=default.:color fc=default.
</xsl:template>

<!--
===============================================================================
== Match Topic Level 3 :: See level 1 for comments
===============================================================================
-->
<xsl:template name="topic-level-3" match="text:p[@text:style-name='topic-level-3']">
:p.
:hp2.:color fc=darkgray.:font facename='<xsl:value-of select="$default-text-font"/>' size=14x14.<xsl:value-of select="."/>:font facename=default.:color fc=default.:ehp2.
</xsl:template>

<!--
===============================================================================
== Match Topic Level 4 :: See level 1 for comments
===============================================================================
-->
<xsl:template name="topic-level-4" match="text:p[@text:style-name='topic-level-4']">
:p.
:hp5.:font facename='<xsl:value-of select="$default-text-font"/>' size=14x14.<xsl:value-of select="."/>:font facename=default.:ehp5.
</xsl:template>

<!--
===============================================================================
== Match Topic Level 5 :: See level 1 for comments
===============================================================================
-->
<xsl:template name="topic-level-5" match="text:p[@text:style-name='topic-level-5']">
:p.
:color fc=darkblue.:font facename='<xsl:value-of select="$default-text-font"/>' size=14x14.<xsl:value-of select="."/>:font facename=default.:color fc=default.
</xsl:template>

<!--
===============================================================================
== Match Topic Level 6 :: See level 1 for comments
===============================================================================
-->
<xsl:template name="topic-level-6" match="text:p[@text:style-name='topic-level-6']">
:p.
:lm margin=5.:color fc=darkblue.:font facename='default' size=14x14.<xsl:value-of select="."/>:font facename=default.:color fc=default.:lm margin=default.
</xsl:template>






<!--
===============================================================================
== Match 'ipf-text-level-1'
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== The text in the outer most level usually describes what the chapter is
== about. For this we do a slight increase in font size. The other levels
== currently use the standard font, but this can be overridden. For this to
== work, the text-body of the relevant level must have the 'ipf-text-level-?'
== style. This stuff can be used to put more nuances related to levels.
== These templates also have a name which is used to resolve automatic styles.
===============================================================================
-->
<xsl:template name="ipf-text-level-1" match="text:p[@text:style-name='ipf-text-level-1']">
:p.
<xsl:call-template name="warpsans">
<!--
<xsl:call-template name="helv">
-->
<!--
<xsl:with-param name="font-size">14x14</xsl:with-param>
-->
</xsl:call-template>
</xsl:template>

<!--
===============================================================================
== Match 'ipf-text-level-2' :: See 'ipf-text-level-1' for comments
===============================================================================
-->
<xsl:template name="ipf-text-level-2" match="text:p[@text:style-name='ipf-text-level-2']">
:p.
<xsl:call-template name="warpsans"/>
</xsl:template>

<!--
===============================================================================
== Match 'ipf-text-level-3' :: See 'ipf-text-level-1' for comments
===============================================================================
-->
<xsl:template name="ipf-text-level-3" match="text:p[@text:style-name='ipf-text-level-3']">
:p.
<xsl:call-template name="warpsans"/>
</xsl:template>

<!--
===============================================================================
== Match 'ipf-text-level-4' :: See 'ipf-text-level-1' for comments
===============================================================================
-->
<xsl:template name="ipf-text-level-4" match="text:p[@text:style-name='ipf-text-level-4']">
:p.
<xsl:call-template name="warpsans"/>
</xsl:template>

<!--
===============================================================================
== Match 'ipf-text-level-5' :: See 'ipf-text-level-1' for comments
===============================================================================
-->
<xsl:template name="ipf-text-level-5" match="text:p[@text:style-name='ipf-text-level-5']">
.br
<!--
:color fc=neutral.
-->
:color fc=default.
<xsl:call-template name="warpsans"/>
:color fc=default.
</xsl:template>

<!--
===============================================================================
== Match 'ipf-text-level-6' :: See 'ipf-text-level-1' for comments
===============================================================================
-->
<xsl:template name="ipf-text-level-6" match="text:p[@text:style-name='ipf-text-level-6']">
.br
:lm margin=5.
<!--
:color fc=neutral.
-->
:color fc=default.
:hp1.
<xsl:call-template name="ipf-default"/>
:ehp1.
:color fc=default.
:lm margin=default.
</xsl:template>




<!--
===============================================================================
== Match 'ipf-text-body'
===============================================================================
-->
<xsl:template name="ipf-text-body" match="text:p[@text:style-name='ipf-text-body']">
:p.
<xsl:call-template name="warpsans"/>
</xsl:template>

<!--
===============================================================================
== Match 'ipf-start-center'
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== This is a special ODT paragrah style that is used to trigger the ':lines.'
== tag so subsequent text is centered in IPF. This is a workaround for the bug
== where ':lines.' emits trailing blank lines, which would accumulate if the
== ":lines.' tag would be used by every 'center' paragraph. This template has
== a matching 'end' template with emits the ':elines.' tag ending centering.
== In the ODT document these 'trigger' styles are at the beginning and the end
== of the text to be centered.
===============================================================================
-->
<xsl:template match="text:p[@text:style-name='ipf-start-center']">
.*# START FORCING CENTERING
:lines align=center.
</xsl:template>

<!--
===============================================================================
== Match 'ipf-text-body-centered'
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== The IPF ':lines.' tag is kinda broken because it emits spurious new lines.
== IBM 'ipfc' has the problem and Open Watcom 'wipfc' is even worse.
== Spurious new lines are generated after the ':elines.' end-tag, making it
== unsuitable to center paragraphs without generating empty lines.
== This cannot be solved directly by '.ce' because that tag only affects the
== one line after it. And .ce is also broken because it also emits blank lines.
== We'll have to find a workaround for this issue.
==
== Workaround:
== Matching templates can have a user defined 'mode'. This kinda acts as a
== selector when applying templates. To handle the centering, the IPF ':lines.'
== tag is still used, but now it emitted when the special paragraph
== 'ipf-start-center' is encountered. On the style 'ipf-text-centered',
== a special named template 'warpsans-ce' is called which does the further
== applying using the 'mode="center"' selector. A few matching templates,
== like line-breaks and bold emppasis now have a 'mode="center" sibling.
==
== The title page of the ODT-document has an empty 'ipf-start-center' at the
== start and an 'ipf-end-center', which emits ':elines.' near the end.
== While this is fragile stuff, it solves the problem. Sometimes however,
== invisible empty styles my be present, which requires cleaning-up the
== relevant section by resetting styles to default, and then re-applying them.
==
== Anyway, the title page has a strictly tuned layout to make this work.
===============================================================================
-->
<xsl:template match="text:p[@text:style-name='ipf-text-body-centered']">
<!-- Use the special handler that uses 'mode="center" -->
<xsl:call-template name="warpsans-ce" />
</xsl:template>

<!--
===============================================================================
== Match 'ipf-end-center'
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== This matches the special 'end centering' paragraph in the ODT document and
== effectively ends the centering by emitting the ':eclines.' IPF-tag.
===============================================================================
-->
<xsl:template match="text:p[@text:style-name='ipf-end-center']">
<!--
<xsl:text>&#10;</xsl:text>
-->
.*# END FORCING CENTERING
:elines.
</xsl:template>


<!--
===============================================================================
== Match 'ipf-text-body-code'
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== When code-lines are inserted from a foreign source into the ODT-document,
== each separate line usually ends up being a paragraph. When all the pasted
== lines are selected and given 'ipf-text-body-code' as the paragraph-style,
== then instead of the IPF ':p.'paragraph-marker, a regular '.br' is emitted.
== This solves the problem of disproportional line-spacing for pasted code.
== This template also works when the lines are itself not paragraphs but
== separated by a soft line-break.
===============================================================================
-->
<xsl:template match="text:p[@text:style-name='ipf-text-body-code']">
.br
<!--
:font facename="Monotype Sans Duospace WT J" size=11x11.<xsl:apply-templates />:font facename=default.
-->
:font facename="Courier" size=11x11.<xsl:apply-templates />:font facename=default.
</xsl:template>


<!--
===============================================================================
== Match 'ipf-text-body-commands'
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== Like with the 'ipf-text-body-code' style, ':p.' IPF-markup is not generated
== and instead '.br' is emitted.
===============================================================================
-->
<xsl:template match="text:p[@text:style-name='ipf-text-body-commands']">
.br
<!--
:font facename="Monotype Sans Duospace WT J" size=14x14.<xsl:apply-templates />:font facename=default.
-->
:font facename="Courier" size=11x11.<xsl:apply-templates />:font facename=default.
</xsl:template>


<!--
===============================================================================
== Match 'ipf-text-body-red'
===============================================================================
-->
<xsl:template match="text:p[@text:style-name='ipf-text-body-red']">
:p.
<xsl:text>:color fc=red.</xsl:text>
<xsl:call-template name="warpsans"/>
<xsl:text>:color fc=default.</xsl:text>
</xsl:template>






<!--
===============================================================================
== Match 'text:s' which is used for leading (and trailing) spaces by ODT
===============================================================================
-->
<xsl:template match="text:s">
<xsl:apply-templates />
</xsl:template>



<!--
===============================================================================
== Match generic 'text:p' para-style
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== Because paragraph styles can get automatic names in an ODT-document,
== these cannot be used to inject markup properties. To partially solve this
== we track the '@style:parent-style-name' attribute and check if that matches
== any of our 'topic-*' or 'ipf-*' styles. If so, then the corresponding
== template is called. If the parent-style does not match one of our custom
== styles the 'text:p' style is ignored.
==
== This is a dirty hack and will be improved in future versions of this
== transform-sheet. Also note the inability of XSLT-1.0 to call a named
== template using a variable-name. So we have to use 'xsl:choose' to call the
== corresponding template.
==
== A possible solution to this problem might be to use EXSLT functions so that
== it becomes possible to contruct a 'match-expression' by using the
== 'parent-style' attribute directly.
===============================================================================
-->
<xsl:template match="text:p">
<xsl:variable name="csn" select="@text:style-name"/>
<xsl:variable name="psn" select="/office:document-content/office:automatic-styles/style:style[@style:name=$csn]/@style:parent-style-name"/>
<xsl:variable name="sub6" select="substring($psn,1,6)"/>
<xsl:variable name="sub4" select="substring($psn,1,4)"/>
.*# AUTOMATIC STYLE '<xsl:value-of select="@text:style-name"/>' ENCOUNTERED -- TRYING TO RESOLVE TO 'topic-*' or 'ipf-*' STYLE<xsl:text/>
<xsl:choose>
<xsl:when test="$sub6='topic-'">
.*# STYLE '<xsl:value-of select="@text:style-name"/>' RESOLVED TO: '<xsl:value-of select="$psn" />'<xsl:text/>
<xsl:choose>
<xsl:when test="$psn='topic-level-1'"><xsl:call-template name="topic-level-1"/></xsl:when>
<xsl:when test="$psn='topic-level-2'"><xsl:call-template name="topic-level-2"/></xsl:when>
<xsl:when test="$psn='topic-level-3'"><xsl:call-template name="topic-level-3"/></xsl:when>
<xsl:when test="$psn='topic-level-4'"><xsl:call-template name="topic-level-4"/></xsl:when>
<xsl:when test="$psn='topic-level-5'"><xsl:call-template name="topic-level-5"/></xsl:when>
<xsl:when test="$psn='topic-level-6'"><xsl:call-template name="topic-level-6"/></xsl:when>
<xsl:otherwise>
.*# TOPIC-STYLE ?? '<xsl:value-of select="$psn"/>' ??
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:when test="$sub4='ipf-'">
.*# STYLE '<xsl:value-of select="@text:style-name"/>' RESOLVED TO: '<xsl:value-of select="$psn" />'<xsl:text/>
<xsl:choose>
<xsl:when test="$psn='ipf-text-level-1'"><xsl:call-template name="ipf-text-level-1"/></xsl:when>
<xsl:when test="$psn='ipf-text-level-2'"><xsl:call-template name="ipf-text-level-2"/></xsl:when>
<xsl:when test="$psn='ipf-text-level-3'"><xsl:call-template name="ipf-text-level-3"/></xsl:when>
<xsl:when test="$psn='ipf-text-level-4'"><xsl:call-template name="ipf-text-level-4"/></xsl:when>
<xsl:when test="$psn='ipf-text-level-5'"><xsl:call-template name="ipf-text-level-5"/></xsl:when>
<xsl:when test="$psn='ipf-text-level-6'"><xsl:call-template name="ipf-text-level-6"/></xsl:when>
<xsl:otherwise>
.*# IPF-STYLE ?? '<xsl:value-of select="$psn"/>' ??
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
.*# STYLE '<xsl:value-of select="@text:style-name"/>' COULD NOT BE RESOLVED, IGNORING STYLE
<xsl:apply-templates />
</xsl:otherwise>
</xsl:choose>
</xsl:template>



<!--
===============================================================================
== Match generic 'text:span' char-style
===============================================================================
-->
<!-- Standard Span -->
<xsl:template match="text:span">
<xsl:variable name="style-name" select="@text:style-name"/>
<xsl:apply-templates />
<!-- Span in Centered Text -->
</xsl:template>
<xsl:template match="text:span" mode="center">
<xsl:variable name="style-name" select="@text:style-name"/>
<xsl:apply-templates mode="center" />
</xsl:template>







<!--
===============================================================================
== Match generic 'text:tab' style
===============================================================================
-->
<xsl:template match="text:tab">
<xsl:apply-templates/>
</xsl:template>

<!--
===============================================================================
== Match generic 'text:soft-page-break' style
===============================================================================
-->
<xsl:template match="text:soft-page-break">
<xsl:apply-templates/>
</xsl:template>

<!--
===============================================================================
== Match generic 'text:a' style
===============================================================================
-->
<xsl:template match="text:a">
<xsl:apply-templates/>
</xsl:template>





<!--
===============================================================================
== Match generic 'draw:frame' style
===============================================================================
-->
<xsl:template match="draw:frame">
<xsl:apply-templates/>
</xsl:template>

<!--
===============================================================================
== Match generic 'draw:image' style
===============================================================================
-->
<xsl:template match="draw:image">
<xsl:param name="path"/>
<xsl:text>:artwork name='</xsl:text>
<xsl:value-of select="$imgdirprefix"/>
<xsl:text>/</xsl:text>
<xsl:value-of select="@xlink:href" /><xsl:text>.bmp</xsl:text>
<xsl:text>' runin.</xsl:text>
<xsl:apply-templates />
</xsl:template>



<!--
===============================================================================
== Match lists and list-items
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== These templates support IPF two-level list nesting.
== A generic ODT list maps to a compact unordered list.
== The custom 'ipf-?l?' ODT list styles traverse down a path corresponding to
== the list type being ordered or unordered. This is accomplished with the
== 'mode' selector.
===============================================================================
-->

<!-- Match line-breaks -->
<xsl:template match="text:line-break" mode="ul">
.br
</xsl:template>
<xsl:template match="text:line-break" mode="ol">
.br
</xsl:template>

<!-- Match spans -->
<xsl:template match="text:span" mode="ul">
<xsl:apply-templates mode="ul" />
</xsl:template>
<xsl:template match="text:span" mode="ol">
<xsl:apply-templates mode="ol" />
</xsl:template>

<!-- Match paragraphs -->
<xsl:template match="text:p" mode="ul">
:li.<xsl:apply-templates mode="ul" />
</xsl:template>
<xsl:template match="text:p" mode="ol">
:li.<xsl:apply-templates mode="ol" />
</xsl:template>

<!-- Match list items -->
<xsl:template match="text:list-item" mode="ul">
<xsl:apply-templates mode="ul" />
</xsl:template>
<xsl:template match="text:list-item" mode="ol">
<xsl:apply-templates mode="ol" />
</xsl:template>

<!-- Match custom lists -->
<xsl:template match="text:list[@text:style-name='ipf-ul']">
:ul.<xsl:apply-templates mode="ul" />
:eul.
</xsl:template>
<xsl:template match="text:list[@text:style-name='ipf-ulc']">
:ul compact.<xsl:apply-templates mode="ul" />
:eul.
</xsl:template>
<xsl:template match="text:list[@text:style-name='ipf-ol']">
:ol.<xsl:apply-templates mode="ol" />
:eol.
</xsl:template>
<xsl:template match="text:list[@text:style-name='ipf-olc']">
:ol compact.<xsl:apply-templates mode="ol"/>
:eol.
</xsl:template>
<xsl:template match="text:list" mode="ul">
:ul compact.<xsl:apply-templates mode="ul"/>
:eul.
</xsl:template>
<xsl:template match="text:list" mode="ol">
:ol compact.<xsl:apply-templates mode="ol"/>
:eol.
</xsl:template>

<!-- Match a generic list -->
<xsl:template match="text:list">
:ul compact.<xsl:apply-templates mode="ul"/>
:eul.
</xsl:template>


<!--
===============================================================================
== Match the various IPF 'hp?' styles
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== These are meant to be span and thus charcter styles.
== There is a template for each IPF 'hp?' style, an easier named alias, and
== a variant for the "center" mode so they can also be used in text blocks
== with the 'ipf-text-body-centered' paragraph style.
===============================================================================
-->

<!-- Match 'ipf-hp1' ~~ italic -->
<xsl:template match="text:span[@text:style-name='ipf-hp1']">
<xsl:text>:hp1.</xsl:text><xsl:apply-templates/><xsl:text>:ehp1.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-hp1']" mode="center">
<xsl:text>:hp1.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp1.</xsl:text>
</xsl:template>
<!-- 'ipf-italic' alias -->
<xsl:template match="text:span[@text:style-name='ipf-italic']">
<xsl:text>:hp1.</xsl:text><xsl:apply-templates/><xsl:text>:ehp1.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-italic']" mode="center">
<xsl:text>:hp1.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp1.</xsl:text>
</xsl:template>

<!-- Match 'ipf-hp2' ~~ bold -->
<xsl:template match="text:span[@text:style-name='ipf-hp2']">
<xsl:text>:hp2.:color fc=darkgray.</xsl:text><xsl:apply-templates/><xsl:text>:color fc=default.:ehp2.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-hp2']" mode="center">
<xsl:text>:hp2.:color fc=darkgray.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:color fc=default.:ehp2.</xsl:text>
</xsl:template>
<!-- 'ipf-bold' alias -->
<xsl:template match="text:span[@text:style-name='ipf-bold']">
<xsl:text>:hp2.:color fc=darkgray.</xsl:text><xsl:apply-templates/><xsl:text>:color fc=default.:ehp2.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-bold']" mode="center">
<xsl:text>:hp2.:color fc=darkgray.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:color fc=default.:ehp2.</xsl:text>
</xsl:template>

<!-- Match 'ipf-hp3' ~~ bold italic -->
<xsl:template match="text:span[@text:style-name='ipf-hp3']">
<xsl:text>:hp3.:color fc=darkgray.</xsl:text><xsl:apply-templates/><xsl:text>:color fc=default.:ehp3.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-hp3']" mode="center">
<xsl:text>:hp3.:color fc=darkgray.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:color fc=default.:ehp3.</xsl:text>
</xsl:template>
<!-- 'ipf-bold-italic' alias -->
<xsl:template match="text:span[@text:style-name='ipf-bold-italic']">
<xsl:text>:hp3.:color fc=darkgray.</xsl:text><xsl:apply-templates/><xsl:text>:color fc=default.:ehp3.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-bold-italic']" mode="center">
<xsl:text>:hp3.:color fc=darkgray.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:color fc=default.:ehp3.</xsl:text>
</xsl:template>

<!-- Match 'ipf-hp4'~~ blue -->
<xsl:template match="text:span[@text:style-name='ipf-hp4']">
<xsl:text>:hp4.</xsl:text><xsl:apply-templates/><xsl:text>:ehp4.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-hp4']" mode="center">
<xsl:text>:hp4.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp4.</xsl:text>
</xsl:template>
<!-- 'ipf-blue' alias -->
<xsl:template match="text:span[@text:style-name='ipf-blue']">
<xsl:text>:hp4.</xsl:text><xsl:apply-templates/><xsl:text>:ehp4.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-blue']" mode="center">
<xsl:text>:hp4.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp4.</xsl:text>
</xsl:template>

<!-- Match 'ipf-hp5' ~~ underline -->
<xsl:template match="text:span[@text:style-name='ipf-hp5']">
<xsl:text>:hp5.</xsl:text><xsl:apply-templates/><xsl:text>:ehp5.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-hp5']" mode="center">
<xsl:text>:hp5.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp5.</xsl:text>
</xsl:template>
<!-- 'ipf-underline' alias -->
<xsl:template match="text:span[@text:style-name='ipf-underline']">
<xsl:text>:hp5.</xsl:text><xsl:apply-templates/><xsl:text>:ehp5.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-underline']" mode="center">
<xsl:text>:hp5.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp5.</xsl:text>
</xsl:template>

<!-- Match 'ipf-hp6' ~~ underline italic -->
<xsl:template match="text:span[@text:style-name='ipf-hp6']">
<xsl:text>:hp6.</xsl:text><xsl:apply-templates/><xsl:text>:ehp6.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-hp6']" mode="center">
<xsl:text>:hp6.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp6.</xsl:text>
</xsl:template>
<!-- 'ipf-underline-italic alias -->
<xsl:template match="text:span[@text:style-name='ipf-underline-italic']">
<xsl:text>:hp6.</xsl:text><xsl:apply-templates/><xsl:text>:ehp6.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-underline-italic']" mode="center">
<xsl:text>:hp6.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp6.</xsl:text>
</xsl:template>

<!-- Match 'ipf-hp7' ~~ underline bold -->
<xsl:template match="text:span[@text:style-name='ipf-hp7']">
<xsl:text>:hp7.:color fc=darkgray.</xsl:text><xsl:apply-templates/><xsl:text>:color fc=default.:ehp7.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-hp7']" mode="center">
<xsl:text>:hp7.:color fc=darkgray.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:color fc=default.:ehp7.</xsl:text>
</xsl:template>
<!-- 'ipf-underline-bold' alias -->
<xsl:template match="text:span[@text:style-name='ipf-underline-bold']">
<xsl:text>:hp7.:color fc=darkgray.</xsl:text><xsl:apply-templates/><xsl:text>:color fc=default.:ehp7.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-underline-bold']" mode="center">
<xsl:text>:hp7.:color fc=darkgray.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:color fc=default.:ehp7.</xsl:text>
</xsl:template>

<!-- Match 'ipf-hp8' ~~ red -->
<xsl:template match="text:span[@text:style-name='ipf-hp8']">
<xsl:text>:hp8.</xsl:text><xsl:apply-templates/><xsl:text>:ehp8.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-hp8']" mode="center">
<xsl:text>:hp8.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp8.</xsl:text>
</xsl:template>
<!-- 'ipf-red' alias -->
<xsl:template match="text:span[@text:style-name='ipf-red']">
<xsl:text>:hp8.</xsl:text><xsl:apply-templates/><xsl:text>:ehp8.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-red']" mode="center">
<xsl:text>:hp8.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp8.</xsl:text>
</xsl:template>

<!-- Match 'ipf-hp9' ~~ pink -->
<xsl:template match="text:span[@text:style-name='ipf-hp9']">
<xsl:text>:hp9.</xsl:text><xsl:apply-templates/><xsl:text>:ehp9.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-hp9']" mode="center">
<xsl:text>:hp9.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp9.</xsl:text>
</xsl:template>
<!-- 'ipf-pink' alias -->
<xsl:template match="text:span[@text:style-name='ipf-pink']">
<xsl:text>:hp9.</xsl:text><xsl:apply-templates/><xsl:text>:ehp9.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-pink']" mode="center">
<xsl:text>:hp9.</xsl:text><xsl:apply-templates mode="center"/><xsl:text>:ehp9.</xsl:text>
</xsl:template>

<!--
===============================================================================
== Match the various IPF custom styles
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== These are custom ODT character styles that map onto IPF ':color.' tags.
== This allows for some more variations and also 'softer' text by applying
== the 'neutral' color.
===============================================================================
-->
<!-- Match 'ipf-neutral' -->
<xsl:template match="text:span[@text:style-name='ipf-neutral']">
<xsl:text>:color fc=neutral.</xsl:text><xsl:apply-templates /><xsl:text>:color fc=default.</xsl:text>
</xsl:template>
<xsl:template match="text:span[@text:style-name='ipf-neutral']">
<xsl:text>:color fc=neutral.</xsl:text><xsl:apply-templates mode="center" /><xsl:text>:color fc=default.</xsl:text>
</xsl:template>



<!--
===============================================================================
== This matches the textual content the ODT-document
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== Now we are at the place we are interested in.
== Here are the style elements and their content, which are mainly heading
== and paragraph styles. Heading styles are going to be mapped to IPF ':h?.'
== tags and paragraph styles to IPF ':p.' tags. And we also process character
== styles we defined in the ODF to do highlighting and other emphasis.
==
== This is also the correct place to indert the IPF document-header and the
== IPF document-footer. In fact, the processing of this 'office:text' tag
== generated the whole IPF content.
===============================================================================
-->
<xsl:template match="office:text">
<!--
[<xsl:value-of select="name()" />]
-->
<xsl:call-template name="ipf-header"/>
<xsl:call-template name="ipf-initial-h1"/>
<!--
<xsl:call-template name="ipf-test-content"/>
<xsl:call-template name="inject-font-view"/>
-->
<xsl:apply-templates />
<xsl:call-template name="ipf-footer"/>
</xsl:template>


<!--
===============================================================================
== This matches the body the ODT-document
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== This is an encapsulating element and we are only interested in processing
== its child 'office:text' which holds the true content.
===============================================================================
-->
<xsl:template match="office:body">
<!--
[<xsl:value-of select="name()" />]
-->
<xsl:apply-templates select="office:text" />
</xsl:template>


<!--
===============================================================================
== This matches the root-element of the ODT-document
== ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
== An ODT-document contains a whole lot more than just the textual content.
== We match to the root-element here to prepare for possible future extensions.
== For now, we are only interested in processing 'office:body' and its direct
== child 'office:text' which hold the true content.
===============================================================================
-->
<xsl:template match="office:document-content">
<!--
[<xsl:value-of select="name()" />]
-->
<xsl:apply-templates select="office:body" />
</xsl:template>





<!--
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                     MATCHING TEMPLATES ARE DEFINED ABOVE
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Such templates are usually closely related to the document being transformed.
If there is more that one template with the same matching criterium, the last
one processed is the one used. This is why the matching template for the
root-element is just above, so it can be overridden by placing an equal one
below it.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-->


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
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
                       NAMED TEMPLATES ARE DEFINED BELOW
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Unlike matching templates, named templates do not nesseccarily relate to the
document being transformed. Some could perform generic actions, like string
manipulations on element content.
Also unlike matching templates, more that one named template with the same
name is an error, so there is no override concept for named templates.
Thus it is a good idea to use some kind of prefix for the name, to lower the
chance of name clashes.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
-->





<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Proccessing Template
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Here we are still in the context of the document root.
%% While we could already emit the IPF-header here, this is not truly the
%% correct place. The correct place is when the 'office:text' tag is processed,
%% because that tag holds the ODT textual content.
%%
%% What we really do here is applying the specific 'office:document-content'
%% tag, which is the ODT root-element. This specific naming prevents spurious
%% output when a non-ODT document would be fed for transformation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="main">
<xsl:apply-templates select="office:document-content" />
</xsl:template>


<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Header for the generated IPF document
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="ipf-header">.*!! GENERATED DOCUMENT !!
.*#############################################################################
.*# <xsl:value-of select="$basename"/>.ipf :: OS/2 Information Presentation Fascility Source
.*# ---------------------------------------------------------------------------
.*#
.*# This file is generated from the corresponding OpenOffice Document, which
.*# has custom paragraph and character style definitions. The overall document
.*# structure and custom styles are transformed to IPF markup by applying XSLT.
.*#
.*# The following steps are executed to create the final INF document:
.*#
.*# o The ODT is exploded using UNZIP
.*# o PNG images are converted to OS/2 BMP using GBM (gbmconv)
.*# o The file 'content.xml' is transformed to this 'airboot.ipf' by the
.*#   transformation-sheet 'odt2ipf.xsl' using XSLTPROC
.*# o Finally, 'airboot.ipf' is compiled to 'airboot.inf' using WIPFC
.*#
.*#############################################################################


.*# Start the IPF Document
:userdoc.
:title.<xsl:value-of select="$doctitle"/>
:docprof toc=<xsl:value-of select="$toclevels"/>.
</xsl:template>


<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial 'h1' for the generated IPF document
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="ipf-initial-h1">
.*# Initial Header
:h1.<xsl:value-of select="$doctitle"/>
.*# ___________________________________________________________________________
</xsl:template>


<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Some content to test IPF compilation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="ipf-test-content">
.*# Test Content
:p.Test Content
</xsl:template>


<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Footer for the generated IPF document
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="ipf-footer">
.*# End the IPF Document
:euserdoc.
</xsl:template>

<xsl:template match="*" mode="center">
<xsl:text>&#10;</xsl:text>
</xsl:template>

<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IPF Default
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="ipf-default">
<xsl:param name="font-size">14x14</xsl:param>
:font facename='default' size=<xsl:value-of select="$font-size"/>.
<xsl:apply-templates />
:font facename=default.
</xsl:template>

<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% WarpSans
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="warpsans">
<xsl:param name="font-size">14x14</xsl:param>
:font facename='WarpSans' size=<xsl:value-of select="$font-size"/>.
<xsl:apply-templates />
:font facename=default.
</xsl:template>

<xsl:template name="warpsans-ce">
<!--
<xsl:param name="font-size">14x14</xsl:param>
:font facename='WarpSans' size=<xsl:value-of select="$font-size"/>.
-->
<xsl:apply-templates mode="center" />
<!--
:font facename=default.
-->
</xsl:template>

<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Workplace Sans
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="workplace-sans">
<xsl:param name="font-size">15x15</xsl:param>
:font facename='Workplace Sans' size=<xsl:value-of select="$font-size"/>.
<xsl:apply-templates />
:font facename=default.
</xsl:template>

<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Arial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="arial">
<xsl:param name="font-size">14x14</xsl:param>
:font facename='Arial' size=<xsl:value-of select="$font-size"/>.
<xsl:apply-templates />
:font facename=default.
</xsl:template>

<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Helv
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="helv">
<xsl:param name="font-size">14x14</xsl:param>
:font facename='Helv' size=<xsl:value-of select="$font-size"/>.
<xsl:apply-templates />
:font facename=default.
</xsl:template>

<!-- courier -->
<xsl:template name="courier">
:font facename="Monotype Sans Duospace WT J" size=11x11.
<xsl:apply-templates />
:font facename=default.
</xsl:template>


<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inject a bunch of fonts
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% hp1 : italic
%% hp2 : bold
%% hp5 : underline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="inject-fonts">
<xsl:param name="fontname">UNKNOWN FONT NAME</xsl:param>
<xsl:param name="string">This is a rendering test for font:</xsl:param>
.*#############################################################################
.*# Generated by XSLT-template "inject-fonts"
.*#############################################################################
.br
.br
:font facename="<xsl:value-of select="$fontname"/>" size=9x9.9 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=10x10.10 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=11x11.11 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=12x12.12 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=13x13.13 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=14x14.14 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=15x15.15 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=16x16.16 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=17x17.17 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=18x18.18 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=19x19.19 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=20x20.20 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=21x21.21 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=22x22.22 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=23x23.23 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
:font facename="<xsl:value-of select="$fontname"/>" size=24x24.24 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=25x25.25 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=26x26.26 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=27x27.27 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=28x28.28 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=29x29.29 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=30x30.30 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=31x31.31 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=32x32.32 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=33x33.33 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=34x34.34 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=35x35.35 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=36x36.36 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=37x37.37 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
.*#:font facename="<xsl:value-of select="$fontname"/>" size=38x38.38 <xsl:value-of select='$string'/>:hp2.<xsl:value-of select="$fontname"/> !!:ehp2.:font facename=default.
.*#.br
</xsl:template>






<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inject Fonts for Testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="inject-font-view">
.*#############################################################################
.*# Fonts Preview
.*# ---------------------------------------------------------------------------
.*# This section was generated by a named XSLT templates.
.*# Its purpose is to preview OS/2 INF font rendering for Manuals.
.*# It seems INF is a bit limited with regard to the number of fonts that can
.*# be used simultaniously and possibly also sizes. Note that sizes above 25
.# points fall back to the default size, so we'll comment those out.
.*#############################################################################

.*# Heading Level 1
:h1.Fonts
.*#____________________________________________________________________________

:font facename=WarpSans.
:hp2.:color fc=darkgreen.Fonts:color fc=default.:ehp2.
:font facename=default.

<!-- WarpSans :: Looks Good in more sizes -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">WarpSans</xsl:with-param>
</xsl:call-template>
-->

<!-- Workplace Sans :: Looks Good in more sizes -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Workplace Sans</xsl:with-param>
</xsl:call-template>
-->

<!-- Source Code Pro -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Source Code Pro</xsl:with-param>
</xsl:call-template>
-->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Source Code Pro Light</xsl:with-param>
</xsl:call-template>
-->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Source Code Pro Medium</xsl:with-param>
</xsl:call-template>
-->

<!-- Ugly -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Source Sans Pro</xsl:with-param>
</xsl:call-template>
-->
<!-- Some sizes are doable -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Source Sans Pro ExtraLight</xsl:with-param>
</xsl:call-template>
-->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Source Sans Pro Medium</xsl:with-param>
</xsl:call-template>
-->

<!-- Workable -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Droid Sans</xsl:with-param>
</xsl:call-template>
-->

<!-- Ugly -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Droid Serif</xsl:with-param>
</xsl:call-template>
-->

<!-- Not recognized -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">System VIO Bitmap</xsl:with-param>
</xsl:call-template>
-->

<!-- Not recognized -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">System Monospaced Bitmap</xsl:with-param>
</xsl:call-template>
-->

<!-- Some sizes are doable -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Times New Roman</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks Good -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Arial</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks Good, Helv.14 -->
<!--
-->
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Helv</xsl:with-param>
</xsl:call-template>

<!-- Looks Good -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Helvetica</xsl:with-param>
</xsl:call-template>
-->

<!-- Ugly -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">URW Bookman L</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks Good -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Tms Rmn</xsl:with-param>
</xsl:call-template>
-->

<!-- Not recognized -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Tms Rmn Bitmap</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks Good for a few sizes -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">System Proportional</xsl:with-param>
</xsl:call-template>
-->

<!-- Same as ISO version ? -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">System Proportional Non-ISO</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks Good, but Courier looks a little better -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Courier New</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks Good -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Courier</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks Good ~~ PREFERRED -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Monotype Sans Duospace WT J</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks OK ~~ not monospaced -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Monotype Sans WT</xsl:with-param>
</xsl:call-template>
-->

<!-- Some sizes are doable -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">System Monospaced</xsl:with-param>
</xsl:call-template>
-->

<!-- Does not render correctly ~~ lower base gets clipped -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Droid Sans Mono</xsl:with-param>
</xsl:call-template>
-->

<!-- Ugly -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">URW Palladio L</xsl:with-param>
</xsl:call-template>
-->

<!-- Workable -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">URW Chancery L</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks Good -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Helv</xsl:with-param>
</xsl:call-template>
-->

<!-- Some usable -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Helvetica</xsl:with-param>
</xsl:call-template>
-->

<!-- Only 14-points works -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">LEDPanel</xsl:with-param>
</xsl:call-template>
-->

<!-- Not recognized -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">MARKSYM</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks Good -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Heuristica Regular</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks OK for italics -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Heuristica Italic</xsl:with-param>
</xsl:call-template>
-->

<!-- Some sizes are doable ~~ has artifacts -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">URW Gothic L</xsl:with-param>
</xsl:call-template>
-->

<!-- Shows empty squares -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">OpenSymbol</xsl:with-param>
</xsl:call-template>
-->

<!-- Has Artifacts -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Midori Sans</xsl:with-param>
</xsl:call-template>
-->

<!-- Only works for digits ~~ some sizes only -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">MMPMDigital</xsl:with-param>
</xsl:call-template>
-->

<!-- Doable but some sizes have artifacts -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Nimbus Sans L Condensed</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks like Greek -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Symbol</xsl:with-param>
</xsl:call-template>
-->

<!-- Same as Symbol ? -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Symbol Set</xsl:with-param>
</xsl:call-template>
-->

<!-- Looks Good ~~ has map, file, keyboard and mouse glyphs -->
<!--
<xsl:call-template name="inject-fonts">
<xsl:with-param name="fontname">Wingdings</xsl:with-param>
</xsl:call-template>
-->

</xsl:template>



<!--
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get Style Properties :: not used anymore
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-->
<xsl:template name="get-style-properties">
<xsl:param name="style-name">Standard</xsl:param>
<xsl:variable name="alignment">left</xsl:variable>
<xsl:variable name="fgc">default</xsl:variable>
<xsl:variable name="bgc">default</xsl:variable>
<xsl:variable name="font-weight">default</xsl:variable>
<xsl:variable name="font-style">default</xsl:variable>
<xsl:variable name="parent-style-name">default</xsl:variable>
<xsl:variable name="node-ptr" select="/office:document-content/office:automatic-styles/style:style[@style:name=$style-name]" />
<!--xsl:text>BEGIN</xsl:text>
<xsl:value-of select="$style-name"/>
<xsl:text>[</xsl:text>
<xsl:value-of select="$node-ptr/@style:family" />
<xsl:text>]</xsl:text>
<xsl:text>[</xsl:text>
<xsl:value-of select="$node-ptr/style:text-properties/@fo:color" />
<xsl:text>]</xsl:text>
<xsl:text>[</xsl:text>
<xsl:value-of select="$node-ptr/style:text-properties/@fo:background-color" />
<xsl:text>]</xsl:text>
<xsl:text>END</xsl:text-->
</xsl:template>


</xsl:transform>
