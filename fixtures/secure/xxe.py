# FIXTURE — unsafe XML parse (XXE)
from lxml import etree
import xml.etree.ElementTree as ET
doc = etree.fromstring(untrusted, etree.XMLParser(resolve_entities=True))
tree = ET.parse(untrusted_path)
