-- pugi_xml.adb - Fri Jun 10 21:55:55 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

-- with Ada.Text_IO;

package body Pugi_Xml is

   function Strlen(C_Ptr : System.Address) return Natural is
      function UX_strlen(cstr : System.Address) return uint_t; -- From posix support
      pragma Import(C,UX_strlen,"c_strlen");
   begin
      return Natural(UX_strlen(C_Ptr));
   end Strlen;

   procedure Initialize(Obj: in out Xml_Document) is
      function new_xml_document return System.Address;
      pragma Import(C,new_xml_document,"pugi_new_xml_document");
   begin
      Obj.Doc := new_xml_document;
   end Initialize;

   procedure Finalize(Obj: in out Xml_Document) is
      procedure delete_xml_document(doc: System.Address);
      pragma Import(C,delete_xml_document,"pugi_delete_xml_document");
   begin
      delete_xml_document(Obj.Doc);
      Obj.Doc := System.Null_Address;
   end Finalize;

   procedure Initialize(Obj: in out Xml_Node) is
      function new_xml_node return System.Address;
      pragma Import(C,new_xml_node,"pugi_new_xml_node");
   begin
      Obj.Node := System.Null_Address;
   end Initialize;

   procedure Finalize(Obj: in out Xml_Node) is
      use System;
      procedure pugi_delete_node(node: System.Address);
      pragma Import(C,pugi_delete_node,"pugi_delete_node");
   begin
      if ( Obj.Node /= System.Null_Address ) then
         pugi_delete_node(Obj.Node);
         Obj.Node := System.Null_Address;   
      end if;
   end Finalize;

   procedure Load(Obj: in out Xml_Document; Pathname: in String) is
      function load_xml_file(doc: System.Address; Pathname: System.Address) return System.Address;
      pragma Import(C,load_xml_file,"pugi_load_xml_file");
      C_Path:  aliased String := C_String(Pathname);
      Ignored: System.Address;
   begin
      Ignored := load_xml_file(Obj.Doc,C_Path'Address);
   end Load;

   procedure Child(Obj: in out Xml_Document; Name: String; Node: out XML_Node'Class) is
      function xml_child(Doc: System.Address; Name: System.Address) return System.Address;
      pragma Import(C,xml_child,"pugi_xml_child");
      C_Name:  aliased String := C_String(Name);
   begin
      Node.Node := xml_child(Obj.Doc,C_Name'Address);
   end Child;

   procedure Child(Obj: in out XML_Node; Name: String; Node: out XML_Node'Class) is
      function xml_child(Doc: System.Address; Name: System.Address) return System.Address;
      pragma Import(C,xml_child,"pugi_node_child");
      C_Name:  aliased String := C_String(Name);
   begin
      Node.Node := xml_child(Obj.Node,C_Name'Address);
   end Child;

   function Name(Obj: XML_Node) return String is
      function node_name(Node: System.Address) return System.Address;
      pragma Import(C,node_name,"pugi_node_name");
      C_Str :  constant System.Address := node_name(Obj.Node);
      Len :    constant Natural := Strlen(C_Str);
      Name :   String(1..Len);
      for Name'Address use C_Str;
   begin
      return Name;
   end Name;

   procedure Parent(Obj: XML_Node; Node: out XML_Node'Class) is
      function xml_parent(Node: System.Address) return System.Address;
      pragma Import(C,xml_parent,"pugi_xml_parent");
   begin
      Node.Node := xml_parent(Obj.Node);
   end Parent;

   function Empty(Obj: XML_Node) return Boolean is
      function xml_node_empty(Node: System.Address) return int_t;
      pragma Import(C,xml_node_empty,"pugi_node_empty");
   begin
      return xml_node_empty(Obj'Address) /= 0;
   end Empty;

   function Node_Type(Obj: XML_Node) return XML_Node_Type is
      function get_xml_node_type(Node: System.Address) return int_t;
      pragma Import(C,get_xml_node_type,"pugi_node_type");
   begin
      return XML_Node_Type'Val(get_xml_node_type(Obj.Node));
   end Node_Type;   

   function Node_Value(Obj: XML_Node) return String is
      function node_value(Node: System.Address) return System.Address;
      pragma Import(C,node_value,"pugi_node_value");
      C_Str :  constant System.Address := node_value(Obj.Node);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Node_Value;

end Pugi_Xml;
