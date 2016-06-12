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
   begin
      Obj.Node := System.Null_Address;
   end Initialize;

   procedure Finalize(Obj: in out Xml_Node) is
   begin
      Obj.Node := System.Null_Address;   
   end Finalize;

   procedure Initialize(Obj: in out Xml_Attribute) is
   begin
      Obj.Attr := System.Null_Address;
   end Initialize;

   procedure Finalize(Obj: in out Xml_Attribute) is
   begin
      Obj.Attr := System.Null_Address;   
   end Finalize;

   procedure As_Node(Obj: in out XML_Document; Node: out XML_Node'Class) is
      function as_node(Doc: System.Address) return System.Address;
      pragma Import(C,as_node,"pugi_doc_node");
   begin
      Node.Node := as_node(Obj.Doc);
   end As_Node;

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

   function Value(Obj: XML_Node) return String is
      function node_value(Node: System.Address) return System.Address;
      pragma Import(C,node_value,"pugi_node_value");
      C_Str :  constant System.Address := node_value(Obj.Node);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Value;

   procedure First_Child(Obj: XML_Node; Node: out XML_Node) is
      function get_first_child(Node: System.Address) return System.Address;
      pragma Import(C,get_first_child,"pugi_first_child");
   begin
      Node.Node := get_first_child(Obj.Node);
   end First_Child;

   procedure Last_Child(Obj: XML_Node; Node: out XML_Node) is
      function get_last_child(Node: System.Address) return System.Address;
      pragma Import(C,get_last_child,"pugi_last_child");
   begin
      Node.Node := get_last_child(Obj.Node);
   end Last_Child;

   procedure Root_Node(Obj: XML_Node; Node: out XML_Node) is
      function get_root_node(Node: System.Address) return System.Address;
      pragma Import(C,get_root_node,"pugi_root_node");
   begin
      Node.Node := get_root_node(Obj.Node);
   end Root_Node;

   procedure Next_Sibling(Obj: XML_Node; Node: out XML_Node) is
      function get_next_sibling(Node: System.Address) return System.Address;
      pragma Import(C,get_next_sibling,"pugi_next_sibling");
   begin
      Node.Node := get_next_sibling(Obj.Node);
   end Next_Sibling;

   procedure Next_Sibling(Obj: XML_Node; Name: String; Node: out XML_Node) is
      function get_next_sibling(Node, Name: System.Address) return System.Address;
      pragma Import(C,get_next_sibling,"pugi_next_named_sibling");
      C_Name:  aliased String := C_String(Name);
   begin
      Node.Node := get_next_sibling(Obj.Node,C_Name'Address);
   end Next_Sibling;

   procedure Previous_Sibling(Obj: XML_Node; Node: out XML_Node) is
      function get_prev_sibling(Node: System.Address) return System.Address;
      pragma Import(C,get_prev_sibling,"pugi_prev_sibling");
   begin
      Node.Node := get_prev_sibling(Obj.Node);
   end Previous_Sibling;

   procedure Previous_Sibling(Obj: XML_Node; Name: String; Node: out XML_Node) is
      function get_prev_sibling(Node, Name: System.Address) return System.Address;
      pragma Import(C,get_prev_sibling,"pugi_prev_named_sibling");
      C_Name:  aliased String := C_String(Name);
   begin
      Node.Node := get_prev_sibling(Obj.Node,C_Name'Address);
   end Previous_Sibling;

   function Is_Null(Obj: XML_Node) return Boolean is
      Node_Info : XML_Node_Type := Node_Type(Obj);
   begin
      return Node_Info = Node_Null;
   end Is_Null;

   function Child_Value(Obj: XML_Node) return String is
      function child_value(Node: System.Address) return System.Address;
      pragma Import(C,child_value,"pugi_child_value");
      C_Str :  constant System.Address := child_value(Obj.Node);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Child_Value;

   function Child_Value(Obj: XML_Node; Name: String) return String is
      function child_value(Node: System.Address; Name: System.Address) return System.Address;
      pragma Import(C,child_value,"pugi_named_child_value");
      C_Name:  aliased String := C_String(Name);
      C_Str :  constant System.Address := child_value(Obj.Node,C_Name'Address);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Child_Value;

   procedure Set_Name(Obj: XML_Node; Data: String; OK: out Boolean) is
      function set_name(Node, Data: System.Address) return int_t;
      pragma Import(C,set_name,"pugi_set_name");
      C_Data: aliased String := C_String(Data);
   begin
      OK := set_name(Obj.Node,C_Data'Address) /= 0;
   end Set_Name;

   procedure Set_Value(Obj: XML_Node; Data: String; OK: out Boolean) is
      function set_value(Node, Data: System.Address) return int_t;
      pragma Import(C,set_value,"pugi_set_value");
      C_Data: aliased String := C_String(Data);
   begin
      OK := set_value(Obj.Node,C_Data'Address) /= 0;
   end Set_Value;

   function "="(Left: XML_Node; Right: XML_Node) return Boolean is
      function is_eq(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_eq,"pugi_is_eq");
   begin
      return is_eq(Left.Node'Address,Right.Node'Address) /= 0;
   end "=";

   function "<"(Left: XML_Node; Right: XML_Node) return Boolean is
      function is_lt(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_lt,"pugi_is_lt");
   begin
      return is_lt(Left.Node'Address,Right.Node'Address) /= 0;
   end "<";

   function "<="(Left: XML_Node; Right: XML_Node) return Boolean is
      function is_le(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_le,"pugi_is_le");
   begin
      return is_le(Left.Node'Address,Right.Node'Address) /= 0;
   end "<=";

   function ">"(Left: XML_Node; Right: XML_Node) return Boolean is
      function is_gt(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_gt,"pugi_is_gt");
   begin
      return is_gt(Left.Node'Address,Right.Node'Address) /= 0;
   end ">";

   function ">="(Left: XML_Node; Right: XML_Node) return Boolean is
      function is_ge(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_ge,"pugi_is_ge");
   begin
      return is_ge(Left.Node'Address,Right.Node'Address) /= 0;
   end ">=";

   procedure First_Attribute(Obj: XML_Node; Attr: out XML_Attribute'Class) is
      function get_first(Obj: System.Address) return System.Address;
      pragma Import(C,get_first,"pugi_first_attr");
   begin
      Attr.Attr := get_first(Obj.Node);
   end First_Attribute;

   procedure Last_Attribute(Obj: XML_Node; Attr: out XML_Attribute'Class) is
      function get_last(Obj: System.Address) return System.Address;
      pragma Import(C,get_last,"pugi_last_attr");
   begin
      Attr.Attr := get_last(Obj.Node);
   end Last_Attribute;

   function Text(Obj: XML_Node) return String is
      function text(Node: System.Address) return System.Address;
      pragma Import(C,text,"pugi_text");
      C_Str :  constant System.Address := text(Obj.Node);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Text;

   procedure Attribute(Obj: XML_Node; Name: String; Attr: out XML_Attribute'Class) is
      function get_attr(Node: System.Address; Name: System.Address) return System.Address;
      pragma Import(C,get_attr,"pugi_attr");
      C_Name:  aliased String := C_String(Name);
   begin
      Attr.Attr := get_attr(Obj.Node,Name'Address);
   end Attribute;

   function Name(Obj: XML_Attribute) return String is
      function get_name(Attr: System.Address) return System.Address;
      pragma Import(C,get_name,"pugi_attr_name");
      C_Str :  constant System.Address := get_name(Obj.Attr);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Name;

   function Value(Obj: XML_Attribute) return String is
      function get_value(Attr: System.Address) return System.Address;
      pragma Import(C,get_value,"pugi_attr_value");
      C_Str :  constant System.Address := get_value(Obj.Attr);
      Len :    constant Natural := Strlen(C_Str);
      V :   String(1..Len);
      for V'Address use C_Str;
   begin
      return V;
   end Value;

   function Empty(Obj: XML_Attribute) return Boolean is
      function attr_empty(Node: System.Address) return Standard.Integer;
      pragma Import(C,attr_empty,"pugi_attr_empty");
   begin
      return attr_empty(Obj'Address) /= 0;
   end Empty;

   function "="(Left, Right: XML_Attribute) return Boolean is
      function is_eq(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_eq,"pugi_is_attr_eq");
   begin
      return is_eq(Left.Attr'Address,Right.Attr'Address) /= 0;
   end "=";

   function "<"(Left, Right: XML_Attribute) return Boolean is
      function is_lt(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_lt,"pugi_is_attr_lt");
   begin
      return is_lt(Left.Attr'Address,Right.Attr'Address) /= 0;
   end "<";

   function "<="(Left, Right: XML_Attribute) return Boolean is
      function is_le(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_le,"pugi_is_attr_le");
   begin
      return is_le(Left.Attr'Address,Right.Attr'Address) /= 0;
   end "<=";

   function ">"(Left, Right: XML_Attribute) return Boolean is
      function is_gt(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_gt,"pugi_is_attr_gt");
   begin
      return is_gt(Left.Attr'Address,Right.Attr'Address) /= 0;
   end ">";

   function ">="(Left, Right: XML_Attribute) return Boolean is
      function is_ge(Left, Right: System.Address) return Standard.Integer;
      pragma Import(C,is_ge,"pugi_is_attr_ge");
   begin
      return is_ge(Left.Attr'Address,Right.Attr'Address) /= 0;
   end ">=";

   procedure Append_Attribute(Obj: in out XML_Node; Name: String; Attr: out XML_Attribute'Class) is
      function insert(Obj, Name: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_append_attr");
      C_Name: aliased String := C_String(Name);
   begin
      Attr.Attr := insert(Obj.Node,C_Name'Address);
   end Append_Attribute;
   
   procedure Prepend_Attribute(Obj: in out XML_Node; Name: String; Attr: out XML_Attribute'Class) is
      function insert(Obj, Name: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_prepend_attr");
      C_Name: aliased String := C_String(Name);
   begin
      Attr.Attr := insert(Obj.Node,C_Name'Address);
   end Prepend_Attribute;
   
   procedure Insert_Attribute_After(Obj: in out XML_Node; Name: String; Other: XML_Attribute'Class; Attr: out XML_Attribute'Class) is
      function insert(Obj, Name, Other: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_append_after");
      C_Name: aliased String := C_String(Name);
   begin
      Attr.Attr := insert(Obj.Node,C_Name'Address,Other.Attr);
   end Insert_Attribute_After;
   
   procedure Insert_Attribute_Before(Obj: in out XML_Node; Name: String; Other: XML_Attribute'Class; Attr: out XML_Attribute'Class) is
      function insert(Obj, Name, Other: System.Address) return System.Address;
      pragma Import(C,insert,"pugi_append_before");
      C_Name: aliased String := C_String(Name);
   begin
      Attr.Attr := insert(Obj.Node,C_Name'Address,Other.Attr);
   end Insert_Attribute_Before;

   procedure Next_Attribute(Obj: XML_Attribute; Next: out XML_Attribute'Class) is
      function get_next(Obj: System.Address) return System.Address;
      pragma Import(C,get_next,"pugi_next_attr");
   begin
      Next.Attr := get_next(Obj.Attr);
   end Next_Attribute;

   procedure Previous_Attribute(Obj: XML_Attribute; Prev: out XML_Attribute'Class) is
      function get_prev(Obj: System.Address) return System.Address;
      pragma Import(C,get_prev,"pugi_prev_attr");
   begin
      Prev.Attr := get_prev(Obj.Attr);
   end Previous_Attribute;

   function Is_Null(Obj: XML_Attribute) return Boolean is
      use System;
   begin
      return Obj.Attr = System.Null_Address;
   end Is_Null;

end Pugi_Xml;
