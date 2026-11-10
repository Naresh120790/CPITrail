<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:fx="http://www.sap.com/xslt/functions" xmlns:cpi="http://sap.com/it/"
    exclude-result-prefixes="fx xsd xsl" version="2.0">
    <xsl:output method="xml" encoding="UTF-8" byte-order-mark="no" indent="yes"/>
    <xsl:preserve-space elements="*"/>
    <xsl:param name="exchange"/>
    <xsl:param name="SAP_TPA_SND_TimeZone"/>
    <!-- ============================================================================================= -->
    <!-- Match Template: Call templates for populate headers  
                         into camel exchange headers and copy payload -->
    <!-- ============================================================================================= -->
    <xsl:template match="/">
        <xsl:call-template name="populateHeaders"/>
        <xsl:call-template name="copy"/>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- Match Template: Produce payload -->
    <!-- ============================================================================================= -->
    <xsl:template name="copy" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- Match Template: Write header values into camel exchange headers -->
    <!-- ============================================================================================= -->
    <xsl:template name="populateHeaders">
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Message_Type', local-name(/node()[1]))"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Message_Version', '1905')"/>
        <!-- xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Message_Namespace', namespace-uri(/node()))"/ -->
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Interchange_Control_Number', //*:MessageHeader[1]/*:ID[1])"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Message_Number', //*:MessageHeader[1]/*:ID[1])"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Interchange_DateTime', fx:setInterchangeCreationDateTime(//*:MessageHeader[1]/*:CreationDateTime[1], $SAP_TPA_SND_TimeZone))"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Usage_Indicator', fx:setUsage(//*:MessageHeader[1]/*:TestDataIndicator[1]))"/>
        <!-- xsl:value-of select="fx:setExchangeHeader('SAP_EDI_GS_Sender_ID', //*:MessageHeader[1]/*:SenderBusinessSystemID[1])"/ -->
        <!-- xsl:value-of select="fx:setExchangeHeader('SAP_EDI_GS_Receiver_ID', //*:MessageHeader[1]/*:RecipientBusinessSystemID[1])"/ -->
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Sender_ID', //*:MessageHeader[1]/*:SenderParty[1]/*:InternalID[1])"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Sender_ID_Qualifier', //*:MessageHeader[1]/*:SenderParty[1]/*:InternalID[1]/@schemeID)"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Sender_ID_Agency_ID', //*:MessageHeader[1]/*:SenderParty[1]/*:InternalID[1]/@schemeAgencyID)"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Receiver_ID', //*:MessageHeader[1]/*:RecipientParty[1]/*:InternalID[1])"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Receiver_ID_Qualifier', //*:MessageHeader[1]/*:RecipientParty[1]/*:InternalID[1]/@schemeID)"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Receiver_ID_Agency_ID', //*:MessageHeader[1]/*:RecipientParty[1]/*:InternalID[1]/@schemeAgencyID)"/>
    </xsl:template>    
    
    <xsl:function name="fx:setExchangeHeader">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="xsd:string($value) != ''">
            <xsl:value-of select="cpi:setHeader($exchange, $name, xsd:string($value))"/>
        </xsl:if>
    </xsl:function>

    <!-- xsl:function name="fx:setHeader">
        <xsl:param name="exchange"/>
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:element name="parameter">
            <xsl:attribute name="exchange" select="$exchange"/>
            <xsl:attribute name="name" select="$name"/>
            <xsl:attribute name="value" select="$value"/>
        </xsl:element>
    </xsl:function -->

    <!-- ============================================================================================= -->
    <!-- Function: Set, if the usage is productive, test or for information -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setUsage" as="xsd:string">
        <xsl:param name="arg"/>
        <xsl:sequence select="
            if ($arg = 'true') then 'test' 
            else 'productive'"/>
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set interchange creation date and time -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setInterchangeCreationDateTime" as="xsd:string">
        <xsl:param name="dateTime" as="xsd:string"/>
        <xsl:param name="timeZone" as="xsd:string?"/>
        <xsl:variable name="vDateTime" select="xsd:dateTime($dateTime)"/>
        <xsl:sequence select="if ($timeZone != '' and not(compare($dateTime, '-[0-9]{2}:[0-9]{2}$'))) then
            adjust-dateTime-to-timezone($vDateTime, xsd:dayTimeDuration($timeZone))
            else $dateTime
            "/>
    </xsl:function>
    
</xsl:stylesheet>
