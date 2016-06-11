-- pugi_xml.adb - Fri Jun 10 21:55:55 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

-- with Ada.Text_IO;

package body Pugi_Xml is

   procedure Initialize(Obj: in out Xml_Document) is
      function new_xml_document return System.Address;
      pragma Import(C,new_xml_document,"pugi_new_xml_document");
   begin
      Obj.doc := new_xml_document;
   end Initialize;

   procedure Finalize(Obj: in out Xml_Document) is
      procedure delete_xml_document(doc: System.Address);
      pragma Import(C,delete_xml_document,"pugi_delete_xml_document");
   begin
      delete_xml_document(Obj.Doc);
      Obj.doc := System.Null_Address;
   end Finalize;

   procedure Load(Obj: in out Xml_Document; Pathname: in String) is
      function load_xml_file(doc: System.Address; Pathname: System.Address) return System.Address;
      pragma Import(C,load_xml_file,"pugi_load_xml_file");
      C_Path:  aliased String := C_String(Pathname);
      Ignored: System.Address;
   begin
      Ignored := load_xml_file(Obj.Doc,C_Path'Address);
   end Load;

end Pugi_Xml;
