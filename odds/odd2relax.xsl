<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
     xmlns:xd="http://www.pnp-software.com/XSLTdoc"
     xmlns:s="http://www.ascc.net/xml/schematron" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:tei="http://www.tei-c.org/ns/1.0"
     xmlns:estr="http://exslt.org/strings"
     xmlns:xs="http://www.w3.org/2001/XMLSchema" 
     xmlns:t="http://www.thaiopensource.com/ns/annotations"
     xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
     xmlns:edate="http://exslt.org/dates-and-times"
     xmlns:exsl="http://exslt.org/common"
     xmlns:rng="http://relaxng.org/ns/structure/1.0"
     extension-element-prefixes="exsl estr edate"
     exclude-result-prefixes="exsl edate estr tei t a rng s xd xs" 
     version="1.0">


<xsl:import href="teiodds.xsl"/>

<xd:doc type="stylesheet">
    <xd:short>
    TEI stylesheet for making Relax NG schema from ODD
      </xd:short>
    <xd:detail>
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

   
   
      </xd:detail>
    <xd:author>Sebastian Rahtz sebastian.rahtz@oucs.ox.ac.uk</xd:author>
    <xd:cvsId>$Id$</xd:cvsId>
    <xd:copyright>2005, TEI Consortium</xd:copyright>
  </xd:doc>

<xsl:output encoding="utf-8" method="xml" indent="yes"/>

<xsl:param name="verbose"></xsl:param>
<xsl:param name="outputDir">Schema</xsl:param>
<xsl:param name="appendixWords"/>
<xsl:variable name="headingNumberSuffix"/>
<xsl:variable name="numberBackHeadings"/>
<xsl:variable name="numberFrontHeadings"/>
<xsl:variable name="numberHeadings"/>
<xsl:variable name="numberHeadingsDepth"/>
<xsl:variable name="prenumberedHeadings"/>
<xsl:template name="italicize"/>
<xsl:template name="makeAnchor"/>
<xsl:template name="makeLink"/>
<xsl:param name="splitLevel">-1</xsl:param>
<xsl:variable name="oddmode">dtd</xsl:variable>       
<xsl:variable name="filesuffix"></xsl:variable>
<!-- get list of output files -->
<xsl:variable name="linkColor"/>



<xsl:template match="tei:moduleSpec[@type='decls']" />

<xsl:template match="/">
<xsl:choose>
  <xsl:when test=".//tei:schemaSpec">
    <xsl:apply-templates select=".//tei:schemaSpec" />
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates select="key('AllModules',1)"/>
  </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="generateOutput">
<xsl:param name="body"/>
<xsl:variable name="processor">
   <xsl:value-of select="system-property('xsl:vendor')"/>
</xsl:variable>

<xsl:choose>
  <xsl:when test="$outputDir='' or $outputDir='-'">
      <xsl:copy-of select="$body"/>
  </xsl:when>
  <xsl:when test="contains($processor,'SAXON')">
      <xsl:copy-of select="$body"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:if test="$verbose='true'">
    <xsl:message>   File [<xsl:value-of select="@ident"/>]      </xsl:message>
    </xsl:if>
    <exsl:document method="xml" indent="yes"
		   href="{$outputDir}/{@ident}.rng">
      <xsl:copy-of select="$body"/>
    </exsl:document>
  </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="tei:schemaSpec" >
    <xsl:variable name="filename" select="@ident"/>
    <xsl:if test="$verbose='true'">
    <xsl:message>   process schemaSpec [<xsl:value-of select="@ident"/>]      </xsl:message>
    </xsl:if>

    <xsl:call-template name="generateOutput">
      <xsl:with-param name="body">
	<rng:grammar
	 xmlns:teix="http://www.tei-c.org/ns/Examples"
	 xmlns:rng="http://relaxng.org/ns/structure/1.0"
	 xmlns:t="http://www.thaiopensource.com/ns/annotations"
	 xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
	 datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes">
	  <xsl:attribute name="ns">
	    <xsl:choose>
	      <xsl:when test="@ns"><xsl:value-of select="@ns"/></xsl:when>
	      <xsl:otherwise>http://www.tei-c.org/ns/1.0</xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>	  
	  <xsl:comment>
	    <xsl:text>Schema generated </xsl:text>
	    <xsl:value-of  select="edate:date-time()"/>
	    <xsl:text>&#010;</xsl:text>
	  </xsl:comment>
	    <xsl:if test="$TEIC='true'">
	      <xsl:comment>
	      <xsl:call-template name="copyright"/>
	      <!--
		  <xsl:text>WARNING! Generated from a pre-release draft of TEI P5
		  from 1st October 2004. This is NOT the final P5</xsl:text>
	      -->
	      </xsl:comment>
	    <xsl:text>&#10;</xsl:text>
	    <xsl:call-template name="predeclarations"/>
	    </xsl:if>
  	  <xsl:apply-templates mode="tangle"
			       select="tei:specGrpRef"/>
  	  <xsl:apply-templates mode="tangle"
			       select="tei:moduleRef"/>
  	  <xsl:apply-templates mode="tangle"
			       select="tei:elementSpec|tei:macroSpec|tei:classSpec"/>
	  <xsl:choose>
	    <xsl:when test="@start and @start=''"/>
	    <xsl:when test="@start and contains(@start,' ')">
	      <rng:start>
		<rng:choice>
		  <xsl:call-template name="startNames">
		    <xsl:with-param name="toks" select="@start"/>
		  </xsl:call-template>
		</rng:choice>
	      </rng:start>
	    </xsl:when>
	    <xsl:when test="@start">
	      <rng:start>
		<rng:ref name="{$patternPrefix}{@start}"/>
	      </rng:start>
	    </xsl:when>
	    <xsl:when test="key('IDENTS','teiCorpus')">
	      <rng:start>
		<rng:choice>
		  <rng:ref name="{$patternPrefix}TEI"/>
		  <rng:ref name="{$patternPrefix}teiCorpus"/>
		</rng:choice>
	      </rng:start>
	    </xsl:when>
	    <xsl:otherwise>
	      <rng:start>
		<rng:ref name="{$patternPrefix}TEI"/>
	      </rng:start>
	    </xsl:otherwise>
	    
	  </xsl:choose>
	</rng:grammar>
      </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<xsl:template name="startNames">
  <xsl:param name="toks"/>
  <xsl:if test="not($toks='')">
    <xsl:choose>
      <xsl:when test="contains($toks,' ')">
	<ref name="{$patternPrefix}{substring-before($toks, ' ')}" xmlns="http://relaxng.org/ns/structure/1.0"/>
	<xsl:call-template name="startNames">
	  <xsl:with-param name="toks" select="substring-after($toks, ' ')"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<ref name="{$patternPrefix}{$patternPrefix}{$toks}" xmlns="http://relaxng.org/ns/structure/1.0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="tei:moduleSpec" >
  <xsl:if test="@ident and not(@mode='change' or @mode='replace' or
		@mode='delete')">
    <xsl:choose>
      <xsl:when test="parent::tei:schemaSpec">
	<xsl:call-template name="moduleSpec-body"/>	  
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="generateOutput">
	  <xsl:with-param name="body">
	    <rng:grammar
		xmlns:rng="http://relaxng.org/ns/structure/1.0"
		xmlns:t="http://www.thaiopensource.com/ns/annotations"
		xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
		datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes">
	      <xsl:text>&#10;</xsl:text> 
	      <xsl:comment>
		<xsl:text>Schema generated </xsl:text>
		<xsl:value-of  select="edate:date-time()"/>
		<xsl:text>&#010;</xsl:text>
		<xsl:call-template name="copyright"/>
	      </xsl:comment>
	      <xsl:text>&#10;</xsl:text>
	      <xsl:call-template name="moduleSpec-body"/>	  
	    </rng:grammar>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template name="moduleSpec-body">	  
  <xsl:variable name="filename" select="@ident"/>
  <xsl:if test="$filename='core'">
    <xsl:call-template name="predeclarations"/>
  </xsl:if>
  <xsl:if test="@type='core'">
    <xsl:call-template name="predeclare-classes"/>
  </xsl:if>
  
  <xsl:variable name="decl">
    <xsl:value-of select="@ident"/>
    <xsl:text>-decl</xsl:text>
  </xsl:variable>
  <xsl:for-each select="key('DeclModules',$decl)">
    <xsl:if test="$verbose='true'">
      <xsl:message>    Include contents of <xsl:value-of select="$decl"/></xsl:message>
    </xsl:if>
    <xsl:comment>Definitions from module <xsl:value-of
    select="$decl"/></xsl:comment>
  <xsl:comment>1. classes</xsl:comment>
  <xsl:apply-templates select="key('ClassModule',$decl)"  mode="tangle"/>
  <xsl:comment>2. elements</xsl:comment>    
    <xsl:apply-templates select="key('ElementModule',$decl)"  mode="tangle">      
      <xsl:sort select="@ident"/>
    </xsl:apply-templates>
    <xsl:comment>3. macros</xsl:comment>
    <xsl:apply-templates select="key('MacroModule',$decl)" mode="tangle"/>

  </xsl:for-each>    

<xsl:comment>Definitions from module <xsl:value-of select="@ident"/></xsl:comment>
  <xsl:comment>1. classes</xsl:comment>
  <xsl:for-each select="key('ClassModule',@ident)">
    <xsl:if test="not(@module='core' and @predeclare='true')">
      <xsl:apply-templates  select="." mode="tangle"/>
    </xsl:if>
  </xsl:for-each>

  <xsl:comment>2. elements</xsl:comment>
  <xsl:apply-templates select="key('ElementModule',@ident)"  mode="tangle">      
    <xsl:sort select="@ident"/>
  </xsl:apply-templates>

  <xsl:comment>3. macros</xsl:comment>
  <xsl:apply-templates select="key('MacroModule',@ident)"  mode="tangle"/>
  
</xsl:template>

<xsl:template name="predeclare-classes">
    <xsl:comment>0. predeclared classes</xsl:comment>
    <xsl:for-each select="key('DefClasses',1)">
      <xsl:choose>
	<xsl:when test="@type='model'">    
	  <xsl:apply-templates select="." mode="processModel">
	    <xsl:with-param name="declare">true</xsl:with-param>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:when test="@type='atts'">    
	  <xsl:apply-templates select="." mode="processDefaultAtts"/>
	</xsl:when>
      </xsl:choose>
    </xsl:for-each>
</xsl:template>

<xsl:template name="predeclarations">
  <rng:define name="IGNORE">
    <rng:notAllowed/>
  </rng:define>
  <rng:define name="INCLUDE">
    <rng:empty/>
  </rng:define>
  <xsl:comment>Weird special cases</xsl:comment>
  <rng:define name="TEI...end">
    <rng:notAllowed/>
  </rng:define>
  <xsl:call-template name="preDefine">
    <xsl:with-param name="name">mix.dictionaries</xsl:with-param>
  </xsl:call-template>
  
  <xsl:call-template name="preDefine">
    <xsl:with-param name="name">mix.drama</xsl:with-param>
  </xsl:call-template>
  
  <xsl:call-template name="preDefine">
    <xsl:with-param name="name">mix.spoken</xsl:with-param>
  </xsl:call-template>
  
  <xsl:call-template name="preDefine">
    <xsl:with-param name="name">mix.verse</xsl:with-param>
  </xsl:call-template>
  
  <xsl:call-template name="preDefine">
    <xsl:with-param name="name">tei.comp.dictionaries</xsl:with-param>
  </xsl:call-template>
  
  <xsl:call-template name="preDefine">
    <xsl:with-param name="name">tei.comp.spoken</xsl:with-param>
  </xsl:call-template>
  
  <xsl:call-template name="preDefine">
    <xsl:with-param name="name">tei.comp.verse</xsl:with-param>
  </xsl:call-template>
  
</xsl:template>

<xsl:template name="preDefine">
 <xsl:param name="name"/>
 <xsl:choose>
   <xsl:when test="$parameterize='true'">
     <rng:define name="{$patternPrefix}{$name}" combine="choice">
       <rng:choice>
	 <rng:notAllowed/>
       </rng:choice>
     </rng:define>
   </xsl:when>
   <xsl:otherwise>
     <xsl:if test="not(key('IDENTS',$name))">
       <rng:define name="{$patternPrefix}{$name}">
	 <rng:choice>
	   <rng:notAllowed/>
	 </rng:choice>
       </rng:define>
     </xsl:if>
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>


<xsl:template match="tei:specGrpRef" mode="tangle">
  <xsl:param name="filename"/>
  <xsl:if test="$verbose='true'">
  <xsl:message>     spec grp ref to <xsl:value-of
    select="@target"/></xsl:message>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="starts-with(@target,'#')">
      <xsl:for-each select="key('IDS',substring-after(@target,'#'))">
	<xsl:apply-templates select="." mode="ok">
	  <xsl:with-param name="filename" select="$filename"/>
	</xsl:apply-templates>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="document(@target)/tei:specGrp">
	<xsl:apply-templates select="." mode="ok">
	  <xsl:with-param name="filename" select="$filename"/>
	</xsl:apply-templates>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="bitOut">
<xsl:param name="grammar"/>
<xsl:param name="TAG"/>
<xsl:param name="content"/>
<xsl:for-each  select="exsl:node-set($content)/Wrapper">
  <xsl:copy-of select="*"/>
</xsl:for-each>
</xsl:template>

<xsl:template name="refdoc"/>

<xsl:template name="typewriter"/>

<xsl:template name="ttembolden"/>

<xsl:template match="processing-instruction()"/>

<xsl:template match="processing-instruction()" mode="tangle"/>

<xsl:template match="s:*"/>


</xsl:stylesheet>


