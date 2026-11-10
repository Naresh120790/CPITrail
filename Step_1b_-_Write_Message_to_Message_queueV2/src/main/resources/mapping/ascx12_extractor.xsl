<?xml version="1.0" encoding="UTF-8"?>
<!-- == HISTORY =================================================================
2022.08.05 [GS] - Line 101: Support more delimiters
============================================================================= -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:fx="http://www.sap.com/xslt/functions" xmlns:cpi="http://sap.com/it/"
    exclude-result-prefixes="fx xsd xsl" version="2.0">
    <xsl:output method="text" encoding="UTF-8" byte-order-mark="no" indent="yes"/>
    <xsl:preserve-space elements="*"/>
    <xsl:param name="exchange"/>
    <xsl:param name="SAP_TPA_SND_TimeZone"/>
    <!-- ============================================================================================= -->
    <!-- Match Template: Call templates for populate headers  
                         into camel exchange headers and copy payload -->
    <!-- ============================================================================================= -->
    <xsl:template match="/">
        <xsl:call-template name="populateHeaders">
            <xsl:with-param name="pHeaderSnippet" select="substring(/node(), 1, 300)"></xsl:with-param>
        </xsl:call-template>
        <!-- xsl:call-template name="copy"/ -->
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- Match Template: Produce payload -->
    <!-- ============================================================================================= -->
    <xsl:template name="copy" match="node()">
        <xsl:copy-of select="node()"/>                    
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- Match Template: Write header values into camel exchange headers -->
    <!-- ============================================================================================= -->
    <xsl:template name="populateHeaders">
        <xsl:param name="pHeaderSnippet"/>
        <xsl:variable name="vSegmentSep" select="fx:setDelimiter($pHeaderSnippet, 106)"/> 
        <xsl:variable name="vCompSep" select="fx:setDelimiter($pHeaderSnippet, 105)"/>
        <xsl:variable name="vDataElementSep" select="fx:setDelimiter($pHeaderSnippet, 4)"/>
        <xsl:variable name="vHeaderTokens" select="tokenize($pHeaderSnippet, $vSegmentSep)"/>
        <xsl:call-template name="populateInterchangeHeader">
            <xsl:with-param name="pCompSep" select="$vCompSep"/>
            <xsl:with-param name="pHeader" select="tokenize($vHeaderTokens[1], $vDataElementSep)"/>
        </xsl:call-template>
        <xsl:call-template name="populateGroupHeader">
            <xsl:with-param name="pCompSep" select="$vCompSep"/>
            <xsl:with-param name="pHeader" select="tokenize($vHeaderTokens[2], $vDataElementSep)"/>
        </xsl:call-template>
        <xsl:call-template name="populateMessageHeader">
            <xsl:with-param name="pCompSep" select="$vCompSep"/>
            <xsl:with-param name="pHeader" select="tokenize($vHeaderTokens[3], $vDataElementSep)"/>
        </xsl:call-template>
    </xsl:template>  
    <xsl:template name="populateInterchangeHeader">
        <xsl:param name="pCompSep"/>
        <xsl:param name="pHeader"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_ISA_Auth_Information_Qualifier', $pHeader[2])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Message_Controlling_Agency', $pHeader[3])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_ISA_Security_Information_Qualifier', $pHeader[4])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_ISA_Security_Information', $pHeader[5])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Sender_ID_Qualifier', $pHeader[6])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Sender_ID', $pHeader[7])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Receiver_ID_Qualifier', $pHeader[8])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Receiver_ID', $pHeader[9])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Interchange_DateTime', fx:setInterchangeCreationDateTime($pHeader[10], $pHeader[11], $SAP_TPA_SND_TimeZone))"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_ISA_Control_Standards_Identifier', $pHeader[12])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_ISA_Version_Number', $pHeader[13])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Interchange_Control_Number', $pHeader[14])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Acknowledgement_Request', fx:setFunctAckRequest($pHeader[15]))"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Usage_Indicator', fx:setUsage($pHeader[16]))"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Component_Data_Element_Separator', $pHeader[17])"/>
    </xsl:template>
    <xsl:template name="populateGroupHeader">
        <xsl:param name="pCompSep"/>
        <xsl:param name="pHeader"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_GS_Functional_Id_Code', $pHeader[2])"/>
        <!-- xsl:sequence select="fx:setExchangeHeader('SAP_EDI_GS_Sender_ID', $pHeader[3])"/ -->
        <!-- xsl:sequence select="fx:setExchangeHeader('SAP_EDI_GS_Receiver_ID', $pHeader[4])"/ -->
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Functional_Group_DateTime', fx:setFunctionalGroupCreationDateTime($pHeader[5], $pHeader[6], $SAP_TPA_SND_TimeZone))"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_GS_Control_Number', $pHeader[7])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_GS_Responsible_Agency_Code', $pHeader[8])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Message_Version', $pHeader[9])"/>
    </xsl:template>
    <xsl:template name="populateMessageHeader">
        <xsl:param name="pCompSep"/>
        <xsl:param name="pHeader"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Message_Type', $pHeader[2])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Message_Number', $pHeader[3])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Common_Access_Reference', $pHeader[4])"/>
    </xsl:template>
    
    <xsl:function name="fx:setExchangeHeader">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="xsd:string($value) != ''">
            <xsl:value-of select="cpi:setHeader($exchange, $name, xsd:string($value))"/>
            <!-- property name="{$name}"><xsl:value-of select="$value"/></property -->
        </xsl:if>
    </xsl:function>

    <xsl:function name="fx:setDelimiter" as="xsd:string">
        <xsl:param name="input" as="xsd:string"/>
        <xsl:param name="pos" as="xsd:integer"/>
        <xsl:variable name="vDelimiter" select="substring($input, $pos, 1)"/>
        <xsl:sequence select="replace($vDelimiter,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set interchange creation date and time -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setInterchangeCreationDateTime" as="xsd:dateTime">
        <xsl:param name="date" as="xsd:string"/>
        <xsl:param name="time" as="xsd:string"/>
        <xsl:param name="timeZone" as="xsd:string?"/>
        <xsl:variable name="dateTime" select="xsd:dateTime(replace(concat($date, $time),
            '^(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$',
            '20$1-$2-$3T$4:$5:00'))"/>
        <xsl:sequence select="if ($timeZone != '' ) then
            adjust-dateTime-to-timezone($dateTime, xsd:dayTimeDuration($timeZone))
            else $dateTime
            "/>
    </xsl:function>
    
    <!-- ============================================================================================= -->
    <!-- Function: Set interchange creation date and time -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setFunctionalGroupCreationDateTime" as="xsd:dateTime">
        <xsl:param name="date" as="xsd:string"/>
        <xsl:param name="time" as="xsd:string"/>
        <xsl:param name="timeZone" as="xsd:string?"/>
        <xsl:variable name="dateTime">
            <xsl:choose>
                <xsl:when test="string-length($time) = 4">
                    <xsl:value-of select="xsd:dateTime(replace(concat($date, $time), '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})$','$1-$2-$3T$4:$5:00'))"/>
                </xsl:when>
                <xsl:when test="string-length($time) = 6">
                    <xsl:value-of select="xsd:dateTime(replace(concat($date, $time), '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$','$1-$2-$3T$4:$5:$6'))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="if ($timeZone != '' ) then
            adjust-dateTime-to-timezone($dateTime, xsd:dayTimeDuration($timeZone))
            else $dateTime
            "/>
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set the functional acknowledgement requests -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setFunctAckRequest" as="xsd:string">
        <xsl:param name="arg" as="xsd:string?"/>
        
        <xsl:sequence
            select="
            if ($arg = '1') then 'true'
            else if ($arg = '0') then 'false'
            else error((), concat('Code &quot;', $arg, '&quot; is not a supported functional request code'))
            "/>
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set, if the usage is productive, test or for information -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setUsage" as="xsd:string">
        <xsl:param name="arg"/>
        <xsl:sequence select="
            if ($arg = 'I') then 'information'
            else if ($arg = 'T') then 'test' 
            else if ($arg = 'P') then 'productive'
            else error((), concat('Code &quot;', $arg, '&quot; is not a supported usage code'))
            "/>
    </xsl:function>
</xsl:stylesheet>