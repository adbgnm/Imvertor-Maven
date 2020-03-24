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
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:ekf="http://EliotKimber/functions"

    xmlns:xhtml="http://www.w3.org/1999/xhtml"

    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-conceptual-map.xsl"/>
    
    <xsl:variable name="stylesheet-code">SKOS</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <xsl:variable name="str3quot">'''</xsl:variable>
    <xsl:variable name="str2quot">"</xsl:variable>
    <xsl:variable name="str1quot">'</xsl:variable>
    <xsl:variable name="apos">'</xsl:variable>
    
    <xsl:variable name="mn" select="imf:extract(/imvert:packages/imvert:application,'[A-Za-z0-9]+')"/>
    <xsl:variable name="prefixData" select="$mn"/>
    <xsl:variable name="prefixSkos" select="'skos'"/>
    <xsl:variable name="baseurl" select="$configuration-skosrules-file/vocabularies/base"/>
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <xsl:value-of select="imf:ttl-comment(('Generated by Imvertor ', imf:get-config-string('run','version'), ''))"/>
        <xsl:value-of select="imf:ttl-comment(('Generated at', imf:get-config-string('run','start'), ''))"/>
        <xsl:value-of select="imf:ttl-comment(())"/>
        
        <!-- 
            read the configured info 
        -->
        <xsl:apply-templates select="$configuration-skosrules-file/vocabularies/vocabulary" mode="preamble"/>
    
        <!-- introduce this model -->
        <xsl:value-of select="imf:ttl-comment(())"/>
        <xsl:value-of select="imf:ttl(('@prefix', concat($prefixData,':'), concat('&lt;',$baseurl,'skos/def/',$mn,'/&gt;'), '.'))"/>
        <xsl:value-of select="imf:ttl-comment(())"/>
        
        <!-- 
            process the imvertor info 
        -->
        <xsl:apply-templates select="$document-packages"/>
        
    </xsl:template>
   
    <xsl:template match="vocabulary" mode="preamble">
        <xsl:value-of select="imf:ttl(('@prefix', concat(prefix,':'), concat('&lt;', URI ,'&gt;'), '.'))"/>
    </xsl:template>
    
    <xsl:template match="imvert:package">
        <xsl:value-of select="imf:ttl-comment(('## Package',imvert:name/@original))"/>
        <xsl:value-of select="imf:ttl(())"/>
        <xsl:apply-templates select="imvert:class"/>
    </xsl:template>
    
    <!--=============== objects ================== -->
    
    <xsl:template match="imvert:class">
        <xsl:variable name="this" select="."/>
        
        <xsl:value-of select="imf:ttl-debug(.,'mode-data-subject')"/>
        
        <xsl:value-of select="imf:ttl-start($this)"/>

        <xsl:value-of select="for $s in imf:get-superclass($this) return imf:ttl(('skosthes:broaderGeneric',imf:ttl-get-uri-name($s)))"/>
        <xsl:value-of select="for $s in imf:get-subclasses($this) return imf:ttl(('skosthes:narrowerGeneric',imf:ttl-get-uri-name($s)))"/>
        
        <xsl:sequence select="imf:ttl-get-all-tvs($this)"/>
                
        <xsl:value-of select="imf:ttl('.')"/>
        
    </xsl:template>
        
    <xsl:template match="node()" mode="#all">
        <!-- skip -->        
    </xsl:template>
    
    <!-- formatteren van de TTL: 
        als drie of meer items, spatie gescheiden aan elkaar plakken.
        als twee, dan eindigen met ';';
        anders overslaan.
    -->
    <xsl:function name="imf:ttl" as="xs:string?">
        <xsl:param name="parts" as="item()*"/>
        <xsl:choose>
            <xsl:when test="$parts[3]">
                <xsl:value-of select="concat(string-join($parts,' '),'&#10;')"/>
            </xsl:when>
            <xsl:when test="$parts[2]">
                <xsl:value-of select="concat('   ', $parts[1],' ',$parts[2],' ;','&#10;')"/>
            </xsl:when>
            <xsl:when test="$parts[1] = '.'">
                <xsl:value-of select="concat('.','&#10;&#10;')"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- skip -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:ttl-start" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="name" select="$this/imvert:name/@original"/>
        <xsl:value-of select="concat(
            imf:ttl-comment(('Construct:',imf:get-display-name($this), concat('(', string-join($this/imvert:stereotype,', ') ,')'))),
            concat(imf:ttl-get-uri-name($this),'&#10;'),
            imf:ttl(('a',concat($prefixSkos, ':Concept'))),
            imf:ttl((concat($prefixSkos,':prefLabel'),imf:ttl-value($name,'2q','nl'))),
            imf:ttl(('rdfs:label',imf:ttl-value($name,'2q'))))
        "/>
    </xsl:function>
    
    <xsl:function name="imf:ttl-comment" as="xs:string">
        <xsl:param name="parts" as="item()*"/>
        <xsl:value-of select="concat(if ($parts[1]) then '# ' else '', string-join($parts,' '),'&#10;')"/>
    </xsl:function>
    
    <xsl:function name="imf:ttl-debug" as="xs:string?">
        <xsl:param name="this" as="item()*"/>
        <xsl:param name="parts" as="item()*"/>
        <xsl:if test="$debugging">
            <xsl:value-of select="imf:ttl-comment(('DEBUG: ', imf:get-display-name($this), string-join($this/imvert:stereotype,' | '), $parts))"/>
        </xsl:if>
    </xsl:function>
    
    <!-- return (name, type) sequence -->
    <xsl:function name="imf:ttl-map" as="element(map)?">
        <xsl:param name="id"/>
        <xsl:sequence select="$configuration-skosrules-file//node-mapping/map[@id=$id]"/>
    </xsl:function>
    
    <xsl:function name="imf:ttl-value" as="xs:string?">
        <xsl:param name="item" as="item()*"/>
        <xsl:param name="type" as="xs:string?"/>
        <xsl:sequence select="imf:ttl-value($item,$type,())"/>
    </xsl:function>
    
    <xsl:function name="imf:ttl-value" as="xs:string?">
        <xsl:param name="item" as="item()*"/>
        <xsl:param name="type" as="xs:string?"/>
        <xsl:param name="lang" as="xs:string?"/>
        <xsl:variable name="strings" as="xs:string*">
            <xsl:choose>
                <xsl:when test="$item/xhtml:body">
                    <xsl:for-each select="$item/xhtml:body/*">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$item/*">
                    <xsl:for-each select="$item/*">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$item"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string" select="string-join($strings,'\n')"/>
        <xsl:variable name="langstr" select="if ($lang) then concat('@',$lang) else ()"/>
        <xsl:choose>
            <xsl:when test="not(normalize-space($string))">
                <!-- skip -->
            </xsl:when>
            <xsl:when test="$type = '3q'">
                <xsl:value-of select="concat($str3quot,imf:normalize-ttl-string($string),$str3quot,$langstr)"/>
            </xsl:when>
            <xsl:when test="$type = '2q'">
                <xsl:value-of select="concat($str2quot,imf:normalize-ttl-string($string),$str2quot,$langstr)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($str1quot,imf:normalize-ttl-string($string),$str1quot,$langstr)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        Haal alle tagged values op in TTL statement formaat.
        Dit zijn alle relevante tv's, dus ook die waarvan de waarde is afgeleid.
    -->
    <xsl:function name="imf:ttl-get-all-tvs">
        <xsl:param name="this"/>
        <!-- loop door alle tagged values heen -->
        <xsl:for-each select="imf:get-config-applicable-tagged-value-ids($this)">
            <xsl:variable name="tv" select="imf:get-most-relevant-compiled-taggedvalue-element($this,concat('##',.))"/>
            <xsl:variable name="map" select="imf:ttl-map($tv/@id)"/>
            <xsl:if test="exists($tv) and exists($map)">
                <xsl:value-of select="imf:ttl(($map, imf:ttl-value($tv,$map/@type, if (imf:boolean($map/@requires-lang)) then 'nl' else ())))"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <!-- 
        return for passed attribute or assoc the class when this is defined in terms of classes 
    -->
    <xsl:function name="imf:ttl-get-defining-class" as="element()?">
        <xsl:param name="this"/>
        <xsl:variable name="type-id" select="$this/imvert:type-id"/>
        <xsl:if test="exists($type-id)">
            <xsl:sequence select="$document-classes[imvert:id = $type-id]"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:ttl-get-uri-name">
        <xsl:param name="construct"/>
        <!--
        <xsl:variable name="dn" select="subsequence(tokenize(imf:get-display-name($class),'\s\('),1,1)"/>
        <xsl:value-of select="concat('data:', string-join(tokenize($dn,'[^A-Za-z0-9]+'),'_'))"/>
        -->
        <xsl:value-of select="concat($prefixData,':', $construct/@formal-name)"/>
    </xsl:function>
    
    <xsl:function name="imf:normalize-ttl-string">
        <xsl:param name="string"/>
        <xsl:value-of select="replace(replace(replace(replace($string,'\\','\\\\'),'&#10;','\\n'),'&quot;','\\&quot;'),$apos,concat('\\',$apos))"/>
    </xsl:function>
  
    
</xsl:stylesheet>
