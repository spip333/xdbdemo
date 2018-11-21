-- --------------------------------------------
-- Transformation
-- --------------------------------------------
select xmltransform(d.doc.extract('/*'), x.stylesheet.extract('/*')) 
from t_xmldemo_xml d, t_xmldemo_xsl x 
where x.id = 1;

select t.* from v_transform t;

-- --------------------------------------------
-- View xml type data in sql*plus
-- --------------------------------------------
select t.doc.getClobVal() from v_transform t;

select 
  xmlserialize(
    document doc as clob
    indent size = 2
  ) as xmldoc
from v_transform;

-- --------------------------------------------
-- Extract node values with XPath
-- --------------------------------------------
 SELECT
        extractvalue(doc,'/data/contractID') AS contractid,
        extractvalue(doc,'/data/branchSPH') AS branchsph,
        extractvalue(doc,'/data/PREMIUM/totalAmount') AS premium,
        extractvalue(doc,'/data/PREMIUM/branchAccounting[branch=''V2'']/amount') AS verdientepraemiev2,
        extractvalue(doc,'/data/PREMIUM/branchAccounting[branch=''none'']/amount') AS verdientepraemiealtbestand,
        extractvalue(doc,'/data/UBPremium/totalAmount') AS ubpremium,
        extractvalue(doc,'/data/UBPremium/branchAccounting[branch=''V2'']/amount') AS ubpremiumv2,
        extractvalue(doc,'/data/UBProvided/totalAmount') AS ubprovided,
        extractvalue(doc,'/data/shorttimeServicePayments/totalAmount') AS shorttimeservicepayments,
        extractvalue(doc,'/data/claimAveragingCostsExternal/totalAmount') AS claimaveragingcostsexternal
    FROM
        v_transform doc;   
   
   