<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:fx="http://www.sap.com/xslt/functions"
    xmlns:cpi="http://sap.com/it/" exclude-result-prefixes="fx xsd xsl" version="2.0">
    <xsl:output method="xml" encoding="UTF-8" byte-order-mark="no" indent="yes"/>
    <xsl:preserve-space elements="*"/>
    <xsl:param name="exchange"/>
    <xsl:param name="SAP_TPA_SND_TimeZone"/>
    <xsl:param name="SAP_TPM_IDOC_Fixed_Version"/>
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
    <xsl:template name="copy" match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- ============================================================================================= -->
    <!-- Match Template: Write header values into camel exchange headers -->
    <!-- ============================================================================================= -->
    <xsl:template name="populateHeaders">
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Client', //*:IDOC[1]/*:EDI_DC40/*:MANDT)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Interchange_Control_Number', //*:IDOC[1]/*:EDI_DC40/*:DOCNUM)"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Message_Number', //*:IDOC[1]/*:EDI_DC40/*:DOCNUM)"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Message_Version', fx:setVersion(//*:IDOC[1]/*:EDI_DC40/*:DOCREL))"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Status', //*:IDOC[1]/*:EDI_DC40/*:STATUS)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Direction', fx:setDirection(//*:IDOC[1]/*:EDI_DC40/*:DIRECT))"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Output_Mode', //*:IDOC[1]/*:EDI_DC40/*:OUTMOD)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Processing_Priority_Code', fx:setPriority(//*:IDOC[1]/*:EDI_DC40/*:EXPRSS))"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Usage_Indicator', fx:setUsage(//*:IDOC[1]/*:EDI_DC40/*:TEST))"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Customer_Extension', //*:IDOC[1]/*:EDI_DC40/*:CIMTYP)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Message_Type', fx:setMessageType(//*:IDOC[1]/*:EDI_DC40/*:MESTYP, //*:IDOC[1]/*:EDI_DC40/*:IDOCTYP, //*:IDOC[1]/*:EDI_DC40/*:CIMTYP))"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Message_Code', //*:IDOC[1]/*:EDI_DC40/*:MESCOD)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Message_Function', //*:IDOC[1]/*:EDI_DC40/*:MESFCT)"/>
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Standard_Flag', //*:IDOC[1]/*:EDI_DC40/*:STD)"/>
        <!-- xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Standard_Version', //*:IDOC[1]/*:EDI_DC40/*:STDVRS)"/ -->
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Standard_Message_Type', //*:IDOC[1]/*:EDI_DC40/STDMES)"/>
        <!-- xsl:value-of select="fx:setExchangeHeader('SAP_EDI_GS_Sender_ID', //*:IDOC[1]/*:EDI_DC40/*:SNDPOR)"/ -->
        <!-- xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Sender_Partner_Type', fx:setPartnerType(//*:IDOC[1]/*:EDI_DC40/*:SNDPRT))"/ -->
        <!-- xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Sender_Partner_Function', //*:IDOC[1]/*:EDI_DC40/*:SNDPFC)"/ -->
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Sender_ID', //*:IDOC[1]/*:EDI_DC40/*:SNDPRN)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Sender_Routing_Address', //*:IDOC[1]/*:EDI_DC40/*:SNDSAD)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Sender_Logical_Addess', //*:IDOC[1]/*:EDI_DC40/*:SNDLAD)"/>
        <!-- xsl:value-of select="fx:setExchangeHeader('SAP_EDI_GS_Receiver_ID', //*:IDOC[1]/*:EDI_DC40/*:RCVPOR)"/ -->
        <!-- xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Receiver_Partner_Type', fx:setPartnerType(//*:IDOC[1]/*:EDI_DC40/*:RCVPRT))"/ -->
        <!-- xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Receiver_Partner_Function', //*:IDOC[1]/*:EDI_DC40/*:RCVPFC)"/ -->
        <xsl:value-of select="fx:setExchangeHeader('SAP_EDI_Receiver_ID', //*:IDOC[1]/*:EDI_DC40/*:RCVPRN)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Receiver_Routing_Address', //*:IDOC[1]/*:EDI_DC40/*:RCVSAD)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Receiver_Logical_Address', //*:IDOC[1]/*:EDI_DC40/*:RCVLAD)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Interchange_DateTime', fx:setInterchangeCreationDateTime(//*:IDOC[1]/*:EDI_DC40/*:CREDAT, //*:IDOC[1]/*:EDI_DC40/*:CRETIM, $SAP_TPA_SND_TimeZone))"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Transmission_File', //*:IDOC[1]/*:EDI_DC40/*:REFINT)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Sender_Group_Reference_Number', //*:IDOC[1]/*:EDI_DC40/*:REFGRP)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Sender_Message_Reference_Number', //*:IDOC[1]/*:EDI_DC40/REFMES)"/>
        <xsl:value-of
            select="fx:setExchangeHeader('SAP_EDI_Archiving_Indicator', //*:IDOC[1]/*:EDI_DC40/*:ARCKEY)"/>
    </xsl:template>

    <!-- ============================================================================================= -->
    <!-- Function: Calling the setHeader function for creating a camel exchange header parameter -->
    <!-- ============================================================================================= -->

    <!-- xsl:function name="fx:setExchangeHeader">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="xsd:string($value) != ''">
            <parameter><xsl:value-of select="concat('&#xA;', $name, ' - ', xsd:string($value))"/></parameter>
        </xsl:if>
    </xsl:function -->

    <xsl:function name="fx:setExchangeHeader">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="xsd:string($value) != ''">
            <xsl:value-of select="cpi:setHeader($exchange, $name, xsd:string($value))"/>
        </xsl:if>
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set the direction of the interchange -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setDirection" as="xsd:string">
        <xsl:param name="arg"/>
        <xsl:sequence
            select="
                if ($arg = '1') then
                    'Outbound'
                else
                    if ($arg = '2') then
                        'Inbound'
                    else
                        ''"
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set the message version -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setVersion" as="xsd:string">
        <xsl:param name="version"/>
        <xsl:sequence select="
            if ($SAP_TPM_IDOC_Fixed_Version != '') then
                $SAP_TPM_IDOC_Fixed_Version
            else
                if (not(exists($version)) or $version = '') then
                    '1809_FPS02'
                else
                    $version"
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set the output mode of the interchange -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setOutputMode" as="xsd:string">
        <xsl:param name="arg" as="xsd:string?"/>

        <xsl:sequence
            select="
                if ($arg = '4') then
                    'collect'
                else
                    if ($arg = '3') then
                        'collectAndSubsystem'
                    else
                        if ($arg = '1') then
                            'passSubsystem'
                        else
                            'pass'"
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set partner type -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setPartnerType" as="xsd:string">
        <xsl:param name="arg"/>
        <xsl:sequence
            select="
                if ($arg = 'B') then
                    'Bank'
                else
                    if ($arg = 'EM') then
                        'Employer'
                    else
                        if ($arg = 'BP') then
                            'Business Partner'
                        else
                            if ($arg = 'KU') then
                                'Buyer'
                            else
                                if ($arg = 'BY') then
                                    'Buyer'
                                else
                                    if ($arg = 'LI') then
                                        'Supplier'
                                    else
                                        if ($arg = 'SE') then
                                            'Seller'
                                        else
                                            if ($arg = 'LS') then
                                                'Logical System'
                                            else
                                                if ($arg = 'US') then
                                                    'User'
                                                else
                                                    ''"
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set, if the usage is productive, test or for information -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setUsage" as="xsd:string">
        <xsl:param name="arg"/>
        <xsl:sequence
            select="
                if ($arg = 'X') then
                    'test'
                else
                    'productive'"
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set the interchange processing priority -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setPriority" as="xsd:string">
        <xsl:param name="arg" as="xsd:string?"/>

        <xsl:sequence
            select="
                if ($arg = 'X') then
                    'true'
                else
                    'false'"
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set interchange creation date and time -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setInterchangeCreationDateTime" as="xsd:dateTime?">
        <xsl:param name="date" as="xsd:string?"/>
        <xsl:param name="time" as="xsd:string?"/>
        <xsl:param name="timeZone" as="xsd:string?"/>
        <xsl:choose>
            <xsl:when test="string-length($date)&gt;0 and string-length($time)&gt;0">
                <xsl:variable name="dateTime"
                              select="
                              xsd:dateTime(replace(concat($date, $time),
                              '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$',
                              '$1-$2-$3T$4:$5:$6'))"/>
                <xsl:sequence
                        select="
                        if ($timeZone != '') then
                            adjust-dateTime-to-timezone($dateTime, xsd:dayTimeDuration($timeZone))
                        else
                            $dateTime
                        "
                />
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set message type -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setMessageType" as="xsd:string">
        <xsl:param name="type" as="xsd:string?"/>
        <xsl:param name="baseType" as="xsd:string?"/>
        <xsl:param name="extType" as="xsd:string?"/>
        <xsl:choose>
            <xsl:when test="$type != '' and $baseType != '' and $extType != ''">
                <xsl:sequence
                    select="
                    concat($type, '.', $baseType, '.', $extType)
                    "
                />
            </xsl:when>
            <xsl:when test="$type != '' and $baseType != ''">
                <xsl:sequence
                    select="
                        concat($type, '.', $baseType)
                        "
                />
            </xsl:when>
            <xsl:when test="$type != ''">
                <xsl:sequence select="
                        $type
                        "/>
            </xsl:when>
            <xsl:when test="$baseType != ''">
                <xsl:sequence select="
                        $baseType
                        "/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence
                    select="
                        error((), 'Message type and base type not available!')
                        "
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
