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
   function Node_Value(Obj: XML_Node) return String;
   procedure First_Child(Obj: XML_Node; Node: out XML_Node);
   procedure Last_Child(Obj: XML_Node; Node: out XML_Node);
   procedure Root_Node(Obj: XML_Node; Node: out XML_Node);

   -- // Comparison operators (compares wrapped node pointers)
   -- bool operator==(const xml_node& r) const;
   -- bool operator!=(const xml_node& r) const;
   -- bool operator<(const xml_node& r) const;
   -- bool operator>(const xml_node& r) const;
   -- bool operator<=(const xml_node& r) const;
   -- bool operator>=(const xml_node& r) const;
   -- 
   -- // Get attribute list
   -- xml_attribute first_attribute() const;
   -- xml_attribute last_attribute() const;
   -- 
   -- // Get next/previous sibling in the children list of the parent node
   -- xml_node next_sibling() const;
   -- xml_node previous_sibling() const;
   -- 
   -- // Get text object for the current node
   -- xml_text text() const;
   -- 
   -- // Get child, attribute or next/previous sibling with the specified name
   -- xml_node child(const char_t* name) const;
   -- xml_attribute attribute(const char_t* name) const;
   -- xml_node next_sibling(const char_t* name) const;
   -- xml_node previous_sibling(const char_t* name) const;
   -- 
   -- // Get child value of current node; that is, value of the first child node of type PCDATA/CDATA
   -- const char_t* child_value() const;
   -- 
   -- // Get child value of child with specified name. Equivalent to child(name).child_value().
   -- const char_t* child_value(const char_t* name) const;
   -- 
   -- // Set node name/value (returns false if node is empty, there is not enough memory, or node can not have name/value)
   -- bool set_name(const char_t* rhs);
   -- bool set_value(const char_t* rhs);

private

   type XML_Document is new Ada.Finalization.Controlled with
      record
         Doc:        System.Address;   -- ptr to pugi::xml_document
      end record;

   procedure Initialize(Obj: in out XML_Document);
   procedure Finalize(Obj: in out XML_Document);

   type XML_Node is new Ada.Finalization.Controlled with
      record
         Node:       System.Address;   -- ptr to pugi::xml_node
      end record;

   procedure Initialize(Obj: in out XML_Node);
   procedure Finalize(Obj: in out XML_Node);

end Pugi_Xml;
