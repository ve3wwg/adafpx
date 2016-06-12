-- pugi_xml.ads - Fri Jun 10 21:47:48 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Posix, System, Ada.Finalization;
use Posix;

package Pugi_Xml is

   type XML_Document is new Ada.Finalization.Controlled with private;
   type XML_Node is new Ada.Finalization.Controlled with private;

   procedure Load(Obj: in out Xml_Document; Pathname: string);
   procedure Child(Obj: in out Xml_Document; Name: String; Node: out XML_Node'Class);

   function Name(Obj: XML_Node) return String;
   procedure Parent(Obj: XML_Node; Node: out XML_Node'Class);
   procedure Child(Obj: in out XML_Node; Name: String; Node: out XML_Node'Class);

private

   type XML_Document is new Ada.Finalization.Controlled with
      record
         Doc:        System.Address;   -- ptr to pugi::xml_document
      end record;

   procedure Initialize(Obj: in out Xml_Document);
   procedure Finalize(Obj: in out Xml_Document);

   type XML_Node is new Ada.Finalization.Controlled with
      record
         Node:       System.Address;   -- ptr to pugi::xml_node
      end record;

   procedure Initialize(Obj: in out Xml_Node);
   procedure Finalize(Obj: in out Xml_Node);

end Pugi_Xml;
