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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy" 
    
    exclude-result-prefixes="#all"
    expand-text="yes"
    >
    
    <!-- 
       Canonization of BRO models.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <xsl:template match="imvert:phase">
        <xsl:variable name="original" select="normalize-space(lower-case(.))"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="original" select="$original"/>
            <xsl:choose>
                <xsl:when test="$original='1.0'">1</xsl:when> 
                <xsl:when test="$original='concept'">0</xsl:when> 
                <xsl:when test="$original='draft'">1</xsl:when> 
                <xsl:when test="$original='finaldraft'">2</xsl:when> 
                <xsl:when test="$original='final draft'">2</xsl:when> 
                <xsl:when test="$original='final'">3</xsl:when> 
                <xsl:otherwise>
                    <xsl:value-of select="$original"/>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:copy>
    </xsl:template>   
    
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
   
</xsl:stylesheet>
