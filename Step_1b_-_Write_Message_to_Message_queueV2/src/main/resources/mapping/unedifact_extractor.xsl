<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================================================= -->
<!-- History: -->
<!-- 2021-10-96 [GS] - Support of UNA Segment added -->
<!-- 2022-01-24 [GS] - Supoort of 1-2 two segment delimiter characters added, whereby the second character must be a line feed character '&#10;' -->
<!-- 2022-08-05 [GS] - Support more delimiters -->
<!-- ============================================================================================= -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:fx="http://www.sap.com/xslt/functions"
    xmlns:cpi="http://sap.com/it/" exclude-result-prefixes="fx xsd xsl" version="2.0">
    <xsl:output method="text" encoding="UTF-8" byte-order-mark="no" indent="yes"/>
    <xsl:preserve-space elements="*"/>
    <xsl:param name="exchange"/>
    <xsl:param name="SAP_TPA_SND_TimeZone"/>
    <!-- ============================================================================================= -->
    <!-- Match Template: Call templates for populate headers  
                         into camel exchange headers and copy payload -->
    <!-- ============================================================================================= -->
    <xsl:template match="/">
        <xsl:variable name="vFirstSegment" select="substring(/node(), 1, 3)"/>
        <!-- Set default delimiters used for internal processing -->
        <xsl:variable name="vDefaultDel" select="':+.? '''"/>
        <!-- Get delimiters from sender interchange payload -->
        <xsl:variable name="vDelimiters"
            select="
                if ($vFirstSegment = 'UNA') then
                    substring(/node(), 4, 7)
                else
                    $vDefaultDel"/>
        <xsl:variable name="vCompSep" select="fx:setDelimiter($vDelimiters, 1)"/>
        <xsl:variable name="vDataElSep" select="fx:setDelimiter($vDelimiters, 2)"/>
        <xsl:variable name="vSegmentSep">
            <xsl:choose>
                <xsl:when test="ends-with($vDelimiters, '&#xa;')">
                    <xsl:value-of select="concat(fx:setDelimiter($vDelimiters, 6), '&#xa;')"/>
                </xsl:when>
                <xsl:when test="ends-with($vDelimiters, '&#10;')">
                    <xsl:value-of select="concat(fx:setDelimiter($vDelimiters, 6), '&#10;')"/>
                </xsl:when>
                <xsl:when test="ends-with($vDelimiters, ' ')">
                    <xsl:value-of select="concat(fx:setDelimiter($vDelimiters, 6), ' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="fx:setDelimiter($vDelimiters, 6)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Replace delimiters, if necessary -->
        <xsl:variable name="vPayload"
            select="
                if ($vFirstSegment = 'UNA') then
                    substring-after(/node(), concat('UNA', $vDelimiters))
                else
                    /node()"/>
        <!-- Get header token and extract it into the separate fields -->
        <xsl:variable name="vHeaderTokens" select="tokenize($vPayload, $vSegmentSep)"/>
        <xsl:call-template name="populateInterchangeHeader">
            <xsl:with-param name="pCompSep" select="$vCompSep"/>
            <xsl:with-param name="pHeader" select="tokenize($vHeaderTokens[1], $vDataElSep)"/>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="starts-with($vHeaderTokens[2], 'UNH')">
                <xsl:call-template name="populateMessageHeader">
                    <xsl:with-param name="pCompSep" select="$vCompSep"/>
                    <xsl:with-param name="pHeader" select="tokenize($vHeaderTokens[2], $vDataElSep)"
                    />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="starts-with($vHeaderTokens[2], 'UNG')">
                <xsl:call-template name="populateGroupHeader">
                    <xsl:with-param name="pCompSep" select="$vCompSep"/>
                    <xsl:with-param name="pHeader" select="tokenize($vHeaderTokens[2], $vDataElSep)"
                    />
                </xsl:call-template>
                <xsl:call-template name="populateMessageHeader">
                    <xsl:with-param name="pCompSep" select="$vCompSep"/>
                    <xsl:with-param name="pHeader" select="tokenize($vHeaderTokens[3], $vDataElSep)"
                    />
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        <!-- xsl:sequence select="$vPayload"/ -->
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
    <xsl:template name="populateInterchangeHeader">
        <xsl:param name="pCompSep"/>
        <xsl:param name="pHeader"/>
        <xsl:variable name="vS001" select="tokenize($pHeader[2], $pCompSep)"/>
        <xsl:variable name="vS002" select="tokenize($pHeader[3], $pCompSep)"/>
        <xsl:variable name="vS003" select="tokenize($pHeader[4], $pCompSep)"/>
        <xsl:variable name="vS004" select="tokenize($pHeader[5], $pCompSep)"/>
        <xsl:variable name="vS005" select="tokenize($pHeader[7], $pCompSep)"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Syntax_ID', $vS001[1])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Syntax_Version', $vS001[2])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Sender_ID', $vS002[1])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Sender_ID_Qualifier', $vS002[2])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Sender_Routing_Address', $vS002[3])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Receiver_ID', $vS003[1])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Receiver_ID_Qualifier', $vS003[2])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Receiver_Routing_Address', $vS003[3])"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_EDI_Interchange_DateTime', fx:setInterchangeCreationDateTime($vS004[1], $vS004[2], $SAP_TPA_SND_TimeZone))"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_EDI_Interchange_Control_Number', $pHeader[6])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_ISA_Security_Information', $vS005[1])"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_EDI_Security_Information_Qualifier', $vS005[2])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Application_Reference', $pHeader[8])"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_EDI_Processing_Priority_Code', fx:setPriority($pHeader[9]))"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_EDI_REC_Acknowledgement_Request', fx:setFunctAckRequest($pHeader[10]))"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_EDI_Interchange_Agreement_ID', $pHeader[11])"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_EDI_Usage_Indicator', fx:setUsage($pHeader[12]))"/>
    </xsl:template>
    <xsl:template name="populateGroupHeader">
        <xsl:param name="pCompSep"/>
        <xsl:param name="pHeader"/>
        <xsl:variable name="vS006" select="tokenize($pHeader[3], $pCompSep)"/>
        <xsl:variable name="vS007" select="tokenize($pHeader[4], $pCompSep)"/>
        <xsl:variable name="vS004" select="tokenize($pHeader[5], $pCompSep)"/>
        <xsl:variable name="vS008" select="tokenize($pHeader[8], $pCompSep)"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_GS_Functional_Id_Code', $pHeader[2])"/>
        <!-- xsl:sequence select="fx:setExchangeHeader('SAP_EDI_GS_Sender_ID', $vS006[1])"/ -->
        <!-- xsl:sequence select="fx:setExchangeHeader('SAP_EDI_GS_Sender_ID_Qualifier', $vS006[2])"/ -->
        <!-- xsl:sequence select="fx:setExchangeHeader('SAP_EDI_GS_Receiver_ID', $vS007[1])"/ -->
        <!-- xsl:sequence select="fx:setExchangeHeader('SAP_EDI_GS_Receiver_ID_Qualifier', $vS007[2])"/ -->
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_EDI_Functional_Group_DateTime', fx:setInterchangeCreationDateTime($vS004[1], $vS004[2], $SAP_TPA_SND_TimeZone))"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_GS_Control_Number', $pHeader[6])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_GS_Responsible_Agency_Code', $pHeader[7])"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_GS_Message_Version', fx:setMessageVersion($vS008[1], $vS008[2], 'S3'))"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_GS_Message_Association_Assign_Code', $vS008[3])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_System_Password', $pHeader[9])"/>
    </xsl:template>
    <xsl:template name="populateMessageHeader">
        <xsl:param name="pCompSep"/>
        <xsl:param name="pHeader"/>
        <xsl:variable name="vS009" select="tokenize($pHeader[3], $pCompSep)"/>
        <xsl:variable name="vS010" select="tokenize($pHeader[5], $pCompSep)"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Message_Number', $pHeader[2])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Message_Type', $vS009[1])"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_EDI_Message_Version', fx:setMessageVersion($vS009[2], $vS009[3], 'S3'))"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Message_Release', $vS009[3])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Message_Controlling_Agency', $vS009[4])"/>
        <xsl:sequence
            select="fx:setExchangeHeader('SAP_EDI_Message_Association_Assign_Code', $vS009[5])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Common_Access_Reference', $pHeader[4])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Sequence_Of_Transfers', $vS010[1])"/>
        <xsl:sequence select="fx:setExchangeHeader('SAP_EDI_Transfer_Type', $vS010[2])"/>
    </xsl:template>

    <!-- ============================================================================================= -->
    <!-- Function: Write the interchange header values as parameters into the Camel exchange header -->
    <!-- ============================================================================================= -->

    <xsl:function name="fx:setExchangeHeader">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="xsd:string($value) != ''">
            <xsl:value-of select="cpi:setHeader($exchange, $name, xsd:string($value))"/>
        </xsl:if>
    </xsl:function>
<!--
    <xsl:function name="fx:setExchangeHeader">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="xsd:string($value) != ''">
            <xsl:value-of select="concat($name, ': ', xsd:string($value)), '&#xa;'"/>
        </xsl:if>
    </xsl:function> -->

    <!-- ============================================================================================= -->
    <!-- Function: Set delimiters according UNA segment  -->
    <!-- ============================================================================================= -->
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
        <xsl:variable name="dateTime"
            select="
                xsd:dateTime(replace(concat($date, $time),
                '^(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$',
                '20$1-$2-$3T$4:$5:00'))"/>
        <xsl:sequence
            select="
                if ($timeZone != '') then
                    adjust-dateTime-to-timezone($dateTime, xsd:dayTimeDuration($timeZone))
                else
                    $dateTime
                "
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set message version -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setMessageVersion" as="xsd:string">
        <xsl:param name="version" as="xsd:string"/>
        <xsl:param name="release" as="xsd:string"/>
        <xsl:param name="syntaxVer" as="xsd:string?"/>
        <xsl:sequence
            select="
                concat($version, '.', $release, ' ', $syntaxVer)
                "
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set the interchange processing priority -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setPriority" as="xsd:string">
        <xsl:param name="arg" as="xsd:string?"/>

        <xsl:sequence
            select="
                if ($arg = 'A') then
                    'true'
                else
                    'false'"
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set the functional acknowledgement requests -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setFunctAckRequest" as="xsd:string">
        <xsl:param name="arg" as="xsd:string?"/>

        <xsl:sequence
            select="
                if ($arg = '1') then
                    'true'
                else
                    'false'"
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Set, if the usage is productive, test or for information -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:setUsage" as="xsd:string">
        <xsl:param name="arg"/>
        <xsl:sequence
            select="
                if ($arg = '1' or $arg = '5') then
                    'test'
                else
                    'productive'"
        />
    </xsl:function>

    <!-- ============================================================================================= -->
    <!-- Function: Add characters to the right -->
    <!-- ============================================================================================= -->
    <xsl:function name="fx:padString" as="xsd:string">
        <xsl:param name="stringToPad" as="xsd:string?"/>
        <xsl:param name="padChar" as="xsd:string"/>
        <xsl:param name="length" as="xsd:integer"/>

        <xsl:sequence
            select="
                substring(
                string-join(
                ($stringToPad,
                for $i in (1 to $length)
                return
                    $padChar)
                , '')
                , 1, $length)
                "/>

    </xsl:function>
</xsl:stylesheet>
