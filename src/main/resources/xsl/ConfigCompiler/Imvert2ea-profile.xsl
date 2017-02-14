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
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
        Create EA profile from the configuration
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:variable name="profile-name" select="imf:get-config-string('cli','createeaprofile','UNSPECIFIED-profile')"/>
    
    <xsl:template match="/config">
        
        <xsl:variable name="tagged-values" select="tagset/tagged-values"/>
        
        <xsl:variable name="profile-id" select="imf:extract(upper-case($profile-name),'[A-Z0-9]+')"/>
        <xsl:variable name="profile-name" select="$profile-name"/>
        <xsl:variable name="profile-version" select="''"/>
        <xsl:variable name="profile-notes" select="''"/>
        
        <UMLProfile profiletype="uml2">
            <Documentation id="{$profile-id}" name="{$profile-name}" version="{$profile-version}" notes="{$profile-notes}"/>
            <Content>
                <Stereotypes>
                    <xsl:for-each select="metamodel/stereotypes/stereo">
                        <xsl:variable name="stereotype-norm-name" select="name"/>
                        <xsl:comment select="$stereotype-norm-name"/>
                        <Stereotype name="{name/@original}" notes="{desc}" cx="100" cy="80" bgcolor="16777164" fontcolor="0" bordercolor="0" borderwidth="1" hideicon="0">
                            <AppliesTo>
                                <xsl:for-each select="construct">
                                    <Apply type="{imf:get-apply(.)}"/>
                                </xsl:for-each>
                            </AppliesTo>
                            <TaggedValues>
                                <xsl:for-each select="$tagged-values/tv[stereotypes/stereo = $stereotype-norm-name]">
                                    <xsl:variable name="tv-name" select="name/@original"/>
                                    <xsl:variable name="tv-values" select="string-join(declared-values/value/@original,',')"/>
                                    <xsl:variable name="tv-type" select="if (exists(declared-values/value)) then 'enumeration' else ()"/>
                                    <xsl:variable name="tv-note" select="normalize-space(desc)"/>
                                    <xsl:variable name="tv-unit" select="''"/>
                                    <xsl:variable name="tv-default" select="declared-values/value[@default='yes']/@original"/>
                                    <Tag name="{$tv-name}" type="{$tv-type}" description="{$tv-note}" unit="{$tv-unit}" values="{$tv-values}" default="{$tv-default}"/>

                                </xsl:for-each>
                            </TaggedValues>
                        </Stereotype>
                    </xsl:for-each>        
                </Stereotypes>
                <TaggedValueTypes/>
            </Content>
        </UMLProfile>
    </xsl:template>
   
    <xsl:function name="imf:get-apply">
        <xsl:param name="construct"/>
        <xsl:choose>
            <xsl:when test="$construct = 'attribute'">Attribute</xsl:when>
            <xsl:when test="$construct = 'package'">Package</xsl:when>
            <xsl:when test="$construct = 'class'">Class</xsl:when>
            <xsl:when test="$construct = 'datatype'">DataType</xsl:when>
            <xsl:when test="$construct = 'association'">Association</xsl:when>
            <xsl:when test="$construct = 'enumeration'">Enumeration</xsl:when>
            <xsl:when test="$construct = 'associationend'">AssociationEnd</xsl:when>
            <xsl:when test="$construct = 'generalization'">Generalization</xsl:when>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
