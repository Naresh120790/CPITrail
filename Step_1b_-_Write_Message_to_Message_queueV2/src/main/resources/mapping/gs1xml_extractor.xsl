<?xml version="1.0" encoding="UTF-8"?>
<!-- = GENERAL INFORMATION ==================================================================== -->
<!-- This EXTRACT.XSLT extracts from the GS1.XML interchanges in inbound direction 
    the relevant header values and writes it into the corresponding exchange header properties. It 
    also deletes the StandardBusinessDocumentHeader and refers just the message body including
    the exchange header properties to the next stages. -->
<!-- = HISTORY ================================================================================ -->
<!-- [SAP, GS] (2022.03.22) - Initially created -->
<!-- = COPYRIGHT STATEMENT ==================================================================== -->
<!-- (c) 2022 SAP SE or an SAP affiliate company. All rights reserved. No part of this publication 
    may be reproduced or transmitted in any form or for any purpose without the express permission 
    of SAP SE or an SAP affiliate company. SAP and other SAP products and services mentioned herein 
    as well as their respective logos are trademarks or registered trademarks of SAP SE (or an SAP 
    affiliate company) in Germany and other countries. All other product and service names mentioned 
    are the trademarks of their respective companies. Please see https://www.sap.com/trademark for 
    additional trademark information and notices. -->
<!-- ========================================================================================== -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:fx="http://www.sap.com/xslt/functions"
    xmlns:cpi="http://sap.com/it/"
    xmlns:sh="http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader"
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
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Sender_ID', //*:StandardBusinessDocumentHeader[1]/*:Sender[1]/*:Identifier[1])"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Sender_ID_Qualifier', //*:StandardBusinessDocumentHeader[1]/*:Sender[1]/*:Identifier[1]/@Authority)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Sender_Partner_Type', //*:StandardBusinessDocumentHeader[1]/*:Sender[1]/*:ContactInformation[1]/*:ContactTypeIdentifier[1])"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Receiver_ID', //*:StandardBusinessDocumentHeader[1]/*:Receiver[1]/*:Identifier[1])"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Receiver_ID_Qualifier', //*:StandardBusinessDocumentHeader[1]/*:Receiver[1]/*:Identifier[1]/@Authority)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Receiver_Partner_Type', //*:StandardBusinessDocumentHeader[1]/*:Receiver[1]/*:ContactInformation[1]/*:ContactTypeIdentifier[1])"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Message_Type', local-name(/node()[1]))"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Interchange_Control_Number', //*:StandardBusinessDocumentHeader[1]/*:DocumentIdentification[1]/*:InstanceIdentifier[1])"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Header_Version', //*:StandardBusinessDocumentHeader[1]/*:HeaderVersion[1])"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Message_Version', //*:StandardBusinessDocumentHeader[1]/*:DocumentIdentification[1]/*:TypeVersion[1])"/>
<!--        <xsl:value-of-->
<!--            select="fx:setExchangeHeader('SAP_EDI_Document_Standard', //*:StandardBusinessDocumentHeader[1]/*:DocumentIdentification[1]/*:Standard[1])"/>-->
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Interchange_Control_Number', //*:StandardBusinessDocumentHeader[1]/*:DocumentIdentification[1]/*:InstanceIdentifier[1])"
        />
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- Match Template: Write selected values into Camel exchange header -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setExchangeHeader">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="xsd:string($value) != ''">
            <xsl:value-of select="cpi:setHeader($exchange, $name, xsd:string($value))"/>
        </xsl:if>
    </xsl:function>

    <!--    <xsl:function name="fx:setExchangeHeader">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="xsd:string($value) != ''">
            <xsl:value-of select="concat($name, ': ', xsd:string($value)), '&#xa;'"/>
        </xsl:if>
    </xsl:function> -->

    <!-- ============================================================================================= -->
    <!-- Function: Set, if the usage is productive, test or for information -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setUsage" as="xsd:string">
        <xsl:param name="arg"/>
        <xsl:sequence
            select="
                if ($arg = 'test') then
                    'test'
                else
                    'productive'"
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set interchange creation date and time -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setInterchangeCreationDateTime" as="xsd:string">
        <xsl:param name="dateTime" as="xsd:string"/>
        <xsl:param name="timeZone" as="xsd:string?"/>
        <xsl:variable name="vDateTime" select="xsd:dateTime($dateTime)"/>
        <xsl:sequence
            select="
                if ($timeZone != '' and not(compare($dateTime, '-[0-9]{2}:[0-9]{2}$'))) then
                    adjust-dateTime-to-timezone($vDateTime, xsd:dayTimeDuration($timeZone))
                else
                    $dateTime
                "
        />
    </xsl:function>

</xsl:stylesheet>
