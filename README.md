# abapJSONTransformation
ABAP &lt;=> JSON simple transformation

There are a lot of other implementations of the ABAP to JSON Serializer and Deserializer on SDN.

Importante for me: Support from SAP!

So, I have written my own example with JSON serializer/deserializer which has some differences:
- Class /UI2/CL_JSON delivered with UI2 Add-on (can be applied on SAP_BASIS 700 – 76X).
- The statement CALL TRANSFORMATION avaiable available in Release 7.40 and downported to 7.02 and 7.31 (Kernelpatch 116) (SAP Notes 1648418 and 1650141) 
- Classes CL_TREX_JSON_SERIALIZER and CL_TREX_JSON_DESERIALIZER
