DROP TABLE T_XMLDEMO_XSL;
DROP TABLE T_XMLDEMO_XML;

CREATE TABLE T_XMLDEMO_XSL (id number, stylesheet XMLTYPE);
CREATE TABLE T_XMLDEMO_XML (id number, doc  XMLTYPE);

-- ----------------------------------------
-- Insert test data
-- ----------------------------------------
INSERT INTO T_XMLDEMO_XML(id, doc) VALUES (1, XMLTYPE.createxml('<?xml version="1.0" encoding="utf-8"?>
<characteristics>
    <totalAmount>
        <amount>861.03</amount>
        <dataType>AMOUNT</dataType>
    </totalAmount>
</characteristics>
'));

INSERT INTO T_XMLDEMO_XML(id, doc) VALUES (2, XMLTYPE.createxml('<?xml version="1.0" encoding="utf-8"?>
<characteristics>
    <totalAmount>
        <amount>777.07</amount>
        <dataType>AMOUNT</dataType>
    </totalAmount>
</characteristics>
'));

INSERT INTO T_XMLDEMO_XML(id, doc) VALUES (2, XMLTYPE.createxml('<?xml version="1.0" encoding="utf-8"?>
<characteristics>
    <totalAmount>
        <amount>999.09</amount>
        <dataType>AMOUNT</dataType>
    </totalAmount>
</characteristics>
'));

INSERT INTO T_XMLDEMO_XSL(id, stylesheet) VALUES (1, xmltype.createxml('<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <data>
            <xsl:for-each select="//characteristics">
                <element>
                    <xsl:value-of select="./characteristicName"></xsl:value-of>
                    <xsl:for-each select="./totalAmount">
                        <amount>
                            <xsl:value-of select="./amount"></xsl:value-of>
                        </amount>
                    </xsl:for-each>
                </element>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </data>
    </xsl:template>
</xsl:stylesheet>
'));

-- ----------------------------------------
-- Create xml views with transformed data
-- ----------------------------------------
CREATE OR REPLACE FORCE VIEW  V_XMLDEMO_VIEW_XML_AS_CLOB(doc) AS
SELECT 
  xmlserialize(
    document doc as clob
    indent size = 2
  ) as xmldoc
FROM T_XMLDEMO_XML;

CREATE OR REPLACE FORCE VIEW  V_XMLDEMO_VIEW_XML_TRANSFO(doc) AS
SELECT XMLTRANSFORM(d.doc, x.stylesheet) 
FROM T_XMLDEMO_XML d, T_XMLDEMO_XSL x 
WHERE x.id = 1;

CREATE OR REPLACE FORCE VIEW  V_XMLDEMO_TRANSFO_AS_CLOB(doc) AS
SELECT 
  xmlserialize(
    document doc as clob
    indent size = 2
  ) as xmldoc
FROM V_XMLDEMO_VIEW_XML_TRANSFO;

-- ----------------------------------------
-- A few samples
-- ----------------------------------------

-- create an xmltype object from a String:
SELECT
    XMLTYPE.createxml('<?xml version="1.0" encoding="utf-8"?>
    <characteristics>
        <totalAmount>
            <amount>861.03</amount>
            <dataType>AMOUNT</dataType>
        </totalAmount>
    </characteristics>
    '))
FROM dual;
 
-- Select an xmltype column from a xmltype view:
SELECT t.* FROM v_transform t;
 
-- ... and now use getClobVal() and xmlserialize to convert XML Type objects to CLOB:
SELECT t.doc.getClobVal() FROM v_transform t;
 
-- ... can use xmlserialize for the same result:
SELECT
  xmlserialize(
    document doc as clob
    indent size = 2
  ) as xmldoc
FROM v_transform;
 
-- Apply a xsl Stylesheet to a xmltype object to transform it:
SELECT xmltransform(d.doc.extract('/*'), x.stylesheet.extract('/*'))
FROM t_xmldemo_xml d, t_xmldemo_xsl x
WHERE x.id = 1;
 
-- extract nodes using XPath using extractvalue, and create a mapping XML to relational:
SELECT
  extractvalue(doc,'/data/contractID') AS contractid,
  extractvalue(doc,'/data/branchSPH') AS branchsph,
  extractvalue(doc,'/data/PREMIUM/branchAccounting[branch=''V2'']/amount') AS verdientepraemiev2,
FROM v_transform doc;  
