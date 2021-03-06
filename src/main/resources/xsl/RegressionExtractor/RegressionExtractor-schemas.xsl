<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 VNG/KING
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
  
    xmlns:ws="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
         Stylesheet to filter intermediate schemas file.
    -->
    
    <xsl:template match="cw:file/imvert:schemas" mode="mode-intermediate-schemas">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- 
        ignore the following alltogether 
    -->
    <xsl:template match="
        imvert:schema/imvert:exporter |
        imvert:schema/imvert:schema-exported |
        imvert:schema/imvert:latest-svn-revision |
        xs:appinfo |
        imvert:schema/imvert:latest-svn-revision |
        imvert:xsd-path" 
        mode="mode-intermediate-schemas">
        <xsl:call-template name="ignore"/>
    </xsl:template>
    
</xsl:stylesheet>
