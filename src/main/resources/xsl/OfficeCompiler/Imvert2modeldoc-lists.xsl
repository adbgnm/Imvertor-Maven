<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcat="http://www.w3.org/ns/dcat#"
    xmlns:rschema="http://www.w3.org/2000/01/rdf-schema#"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!-- 
          Introduce lists.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="includedoclist" select="imf:boolean(imf:get-config-string('cli','includedoclist'))"/>
    <xsl:variable name="doclist-xml-url" select="imf:get-config-parameter('doclist-xml-url')"/>
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$owner = 'BRO'">
                <!-- TODO aanpassen initialisatie codelists....!
                    
                    dit moet beter. dit is ook al onderdeel van modeldoc zelf. de wijze waarop je bepaalt wat de LOC is van de codelist moet apart worden uitgewerkt voor iedere klant of aanpak. 
                
                -->
                    
                <xsl:variable name="configuration-registration-objects-path" select="concat(imf:get-config-string('system','inp-folder-path'),'/cfg/local/registration-objects.xml')"/>
                <xsl:variable name="configuration-registration-objects-doc" select="imf:document($configuration-registration-objects-path,true())"/>

                <!-- the abbreviation for the registration object must be set here; this is part of the path in GIT where the catalog is uploaded -->
                <xsl:variable name="namespace" select="$imvert-document/imvert:packages/imvert:base-namespace"/>
                <xsl:variable name="abbrev" select="tokenize($namespace,'/')[last()]" as="xs:string?"/>
                <xsl:variable name="object" select="$configuration-registration-objects-doc//registratieobject[abbrev = $abbrev]"/>
                
                <!--check if known. -->
                <xsl:choose>
                    <xsl:when test="empty($object)">
                        <xsl:sequence select="imf:msg($imvert-document,'ERROR','The abbreviation [1] taken from [2] is not valid',($abbrev,$namespace))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:set-config-string('appinfo','registration-object-abbreviation',$abbrev)"/>
                       <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/><!-- TODO: no list handling yet -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist')]">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
             <!-- fetch the code list contents -->
            <xsl:variable name="loc" select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DATALOCATION')"/>
            <xsl:sequence select="imf:set-config-string('temp','latest-list-url',$loc)"/>
            <xsl:sequence select="imf:set-config-string('temp','latest-list-key',tokenize($loc,'/')[last()])"/>
           
            <xsl:variable name="referring-attributes" select="//imvert:attribute[imvert:type-id = current()/imvert:id]"/>
            <xsl:variable name="referring-attributes-loc" select="$referring-attributes[exists(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DATALOCATION'))]"/>
            <xsl:variable name="referring-attributes-noloc" select="$referring-attributes[empty(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DATALOCATION'))]"/>
            
            <xsl:choose>
                <xsl:when test="exists($loc) and exists($referring-attributes-loc)">
                    <xsl:sequence select="imf:msg(.,'ERROR','Codelist contents specified on both attributes and codelist. Attributes are: [1]',imf:string-group(for $a in $referring-attributes-loc return imf:get-display-name($a)))"/>
                </xsl:when>
                <xsl:when test="not($includedoclist)">
                    <!-- skip -->
                </xsl:when>
                <xsl:when test="empty($doclist-xml-url)">
                    <xsl:sequence select="imf:msg(.,'FATAL','Owner parameter doclist-xml-url not defined',())"/>
                </xsl:when>
                <xsl:when test="normalize-space($loc)">
                    <xsl:variable name="url" select="imf:merge-parms($doclist-xml-url)"/>
                    <xsl:sequence select="imf:msg(.,'DEBUG','Reading codelist entries from: [1]',$url)"/>
                    <xsl:variable name="xml" select="if (unparsed-text-available($url)) then document($url) else ()"/>
                    <xsl:choose>
                        <xsl:when test="exists($xml)">
                            <xsl:apply-templates select="$xml" mode="list"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:msg(.,'WARNING','Codelist contents cannot be retrieved from location [1], tried [2]',($loc, $url))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="exists($referring-attributes-noloc)">
                    <xsl:sequence select="imf:msg(.,'WARNING','Codelist content location not specified',())"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- specified at all attributes that reference this codelist -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
   
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>    
    
    <!-- when reading from RDF -->
    
    <xsl:template match="/rdf:RDF" mode="list">
        <xsl:apply-templates select="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/ns/dcat#Dataset']/dcat:theme" mode="#current">
            <xsl:with-param name="rdf" select="."/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="dcat:theme" mode="list">
        <xsl:param name="rdf" as="element(rdf:RDF)"/><!-- the rdf root -->
        <xsl:variable name="resource" select="@rdf:resource"/>
        <imvert:entry uri="{$resource}">
            <xsl:variable name="entry" select="$rdf/rdf:Description[@rdf:about=$resource]"/>
            <xsl:value-of select="$entry/rschema:label"/>
        </imvert:entry>
    </xsl:template>
    
    <!-- when reading from XML listing -->
    <xsl:template match="/domeintabel" mode="list">
        <imvert:attributes>
            <xsl:apply-templates select="*" mode="#current"/>
        </imvert:attributes>
    </xsl:template>
 
    <xsl:template match="/domeintabel/*" mode="list">
        <imvert:attribute>
            <imvert:name original="{Omschrijving}">
                <xsl:value-of select="Omschrijving"/>
            </imvert:name>
            <imvert:id>
                <xsl:value-of select="concat(local-name(.),'_',ID)"/>
            </imvert:id>
            <imvert:visibility>public</imvert:visibility>
            <imvert:stereotype id="stereotype-name-enum">ENUMERATIEWAARDE</imvert:stereotype>
            <imvert:tagged-value id="CFG-TV-CODE">
                <imvert:value>
                    <xsl:value-of select="Code"/>
                </imvert:value>
            </imvert:tagged-value>
            <!-- TODO 
            <imvert:tagged-value id="CFG-TV-DEFINITION">
                <imvert:value>
                    <xsl:value-of select="Omschrijving"/>
                </imvert:value>
            </imvert:tagged-value>
            <imvert:tagged-value id="CFG-TV-DESCRIPTION">
                <imvert:value>
                    <xsl:value-of select="TODO"/>
                </imvert:value>
            </imvert:tagged-value>
            -->
        </imvert:attribute>
      </xsl:template>
    
</xsl:stylesheet>