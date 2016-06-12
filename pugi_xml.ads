-- pugi_xml.ads - Fri Jun 10 21:47:48 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Posix, System, Ada.Finalization;
use Posix;

package Pugi_Xml is

   type XML_Node_Type is (
      Node_Null,        -- Empty (null) node handle
      Node_Document,	-- A document tree's absolute root
      Node_Element,	-- Element tag, i.e. '<node/>'
      Node_Pcdata,	-- Plain character data, i.e. 'text'
      Node_Cdata,	-- Character data, i.e. '<![CDATA[text]]>'
      Node_Comment,	-- Comment tag, i.e. '<!-- text -->'
      Node_Pi,		-- Processing instruction, i.e. '<?name?>'
      Node_Declaration,	-- Document declaration, i.e. '<?xml version="1.0"?>'
      Node_Doctype	-- Document type declaration, i.e. '<!DOCTYPE doc>'
   );   

   for XML_Node_Type use (    -- These must match pugixml.hpp values
      Node_Null => 0,
      Node_Document => 1,
      Node_Element => 2,
      Node_Pcdata => 3,
      Node_Cdata => 4,
      Node_Comment => 5,
      Node_Pi => 6,
      Node_Declaration => 7,
      Node_Doctype => 8
   );

   type XML_Document is new Ada.Finalization.Controlled with private;
   type XML_Node is new Ada.Finalization.Controlled with private;
   type XML_Attribute is new Ada.Finalization.Controlled with private;

   -- XML_Document
   procedure As_Node(Obj: in out XML_Document; Node: out XML_Node'Class);
   procedure Load(Obj: in out XML_Document; Pathname: string);
   procedure Child(Obj: in out XML_Document; Name: String; Node: out XML_Node'Class);

   -- XML_Node
   function Name(Obj: XML_Node) return String;
   procedure Parent(Obj: XML_Node; Node: out XML_Node'Class);
   procedure Child(Obj: in out XML_Node; Name: String; Node: out XML_Node'Class);
   function Empty(Obj: XML_Node) return Boolean;
   function Node_Type(Obj: XML_Node) return XML_Node_Type;
   function Value(Obj: XML_Node) return String;
   procedure First_Child(Obj: XML_Node; Node: out XML_Node);
   procedure Last_Child(Obj: XML_Node; Node: out XML_Node);
   procedure Root_Node(Obj: XML_Node; Node: out XML_Node);
   procedure Next_Sibling(Obj: XML_Node; Node: out XML_Node);
   procedure Next_Sibling(Obj: XML_Node; Name: String; Node: out XML_Node);
   procedure Previous_Sibling(Obj: XML_Node; Node: out XML_Node);
   procedure Previous_Sibling(Obj: XML_Node; Name: String; Node: out XML_Node);
   function Is_Null(Obj: XML_Node) return Boolean;
   function Child_Value(Obj: XML_Node) return String;
   function Child_Value(Obj: XML_Node; Name: String) return String;

   procedure Append_Copy(Obj: in out XML_Node; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class);
   procedure Prepend_Copy(Obj: in out XML_Node; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class);
   procedure Insert_Copy_After(Obj: in out XML_Node; After: XML_Attribute'Class; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class);
   procedure Insert_Copy_Before(Obj: in out XML_Node; Before: XML_Attribute'Class; Proto: XML_Attribute'Class; Attr: out XML_Attribute'Class);

   function "="(Left: XML_Node; Right: XML_Node) return Boolean;
   function "<"(Left: XML_Node; Right: XML_Node) return Boolean;
   function "<="(Left: XML_Node; Right: XML_Node) return Boolean;
   function ">"(Left: XML_Node; Right: XML_Node) return Boolean;
   function ">="(Left: XML_Node; Right: XML_Node) return Boolean;

   procedure Set_Name(Obj: XML_Node; Data: String; OK: out Boolean);
   procedure Set_Value(Obj: XML_Node; Data: String; OK: out Boolean);

   procedure First_Attribute(Obj: XML_Node; Attr: out XML_Attribute'Class);
   procedure Last_Attribute(Obj: XML_Node; Attr: out XML_Attribute'Class);
   procedure Attribute(Obj: XML_Node; Name: String; Attr: out XML_Attribute'Class);

   function Text(Obj: XML_Node) return String;

   procedure Append_Attribute(Obj: in out XML_Node; Name: String; Attr: out XML_Attribute'Class);
   procedure Prepend_Attribute(Obj: in out XML_Node; Name: String; Attr: out XML_Attribute'Class);
   procedure Insert_Attribute_After(Obj: in out XML_Node; Name: String; Other: XML_Attribute'Class; Attr: out XML_Attribute'Class);
   procedure Insert_Attribute_Before(Obj: in out XML_Node; Name: String; Other: XML_Attribute'Class; Attr: out XML_Attribute'Class);

   procedure Append_Child(Obj: in out XML_Node; Node_Type: XML_Node_Type; Node: out XML_Node'Class);
   procedure Prepend_Child(Obj: in out XML_Node; Node_Type: XML_Node_Type; Node: out XML_Node'Class);
   procedure Insert_Child_After(Obj: in out XML_Node; After: XML_Node'Class; Node_Type: XML_Node_Type; Node: out XML_Node'Class);
   procedure Insert_Child_Before(Obj: in out XML_Node; Before: XML_Node'Class; Node_Type: XML_Node_Type; Node: out XML_Node'Class);

   procedure Append_Child(Obj: in out XML_Node; Name: String; Node: out XML_Node'Class);
   procedure Prepend_Child(Obj: in out XML_Node; Name: String; Node: out XML_Node'Class);
   procedure Insert_Child_After(Obj: in out XML_Node; After: XML_Node'Class; Name: String; Node: out XML_Node'Class);
   procedure Insert_Child_Before(Obj: in out XML_Node; Before: XML_Node'Class; Name: String; Node: out XML_Node'Class);

   -- // Add a copy of the specified node as a child. Returns added node, or empty node on errors.
   -- xml_node append_copy(const xml_node& proto);
   -- xml_node prepend_copy(const xml_node& proto);
   -- xml_node insert_copy_after(const xml_node& proto, const xml_node& node);
   -- xml_node insert_copy_before(const xml_node& proto, const xml_node& node);
   -- 
   -- // Remove specified attribute
   -- bool remove_attribute(const xml_attribute& a);
   -- bool remove_attribute(const char_t* name);
   -- 
   -- // Remove specified child
   -- bool remove_child(const xml_node& n);
   -- bool remove_child(const char_t* name);
   -- 
   -- // Search for a node by path consisting of node names and . or .. elements.
   -- xml_node first_element_by_path(const char_t* path, char_t delimiter = '/') const;
   -- 
   -- // Child nodes iterators
   -- typedef xml_node_iterator iterator;
   -- 
   -- iterator begin() const;
   -- iterator end() const;
   -- 
   -- // Attribute iterators
   -- typedef xml_attribute_iterator attribute_iterator;
   -- 
   -- attribute_iterator attributes_begin() const;
   -- attribute_iterator attributes_end() const;


   function Name(Obj: XML_Attribute) return String;
   function Value(Obj: XML_Attribute) return String;
   function Empty(Obj: XML_Attribute) return Boolean;

   function "="(Left, Right: XML_Attribute) return Boolean;
   function "<"(Left, Right: XML_Attribute) return Boolean;
   function "<="(Left, Right: XML_Attribute) return Boolean;
   function ">"(Left, Right: XML_Attribute) return Boolean;
   function ">="(Left, Right: XML_Attribute) return Boolean;

   procedure Next_Attribute(Obj: XML_Attribute; Next: out XML_Attribute'Class);
   procedure Previous_Attribute(Obj: XML_Attribute; Prev: out XML_Attribute'Class);

   function Is_Null(Obj: XML_Attribute) return Boolean;

private

   type XML_Document is new Ada.Finalization.Controlled with
      record
         Doc:        System.Address;   -- ptr to pugi::xml_document
      end record;

   procedure Initialize(Obj: in out XML_Document);
   procedure Finalize(Obj: in out XML_Document);

   type XML_Node is new Ada.Finalization.Controlled with
      record
         Node:       System.Address;   -- pugi::xml_node
      end record;

   procedure Initialize(Obj: in out XML_Node);
   procedure Finalize(Obj: in out XML_Node);

   type XML_Attribute is new Ada.Finalization.Controlled with
      record
         Attr:       System.Address;   -- pugi::xml_attribute
      end record;

   procedure Initialize(Obj: in out XML_Attribute);
   procedure Finalize(Obj: in out XML_Attribute);

end Pugi_Xml;
