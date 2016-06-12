-- pugitest.adb - Fri Jun 10 22:20:07 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Posix, Pugi_Xml;
use Posix, Pugi_Xml;

with Ada.Text_IO;

procedure PugiTest is
   Doc:  Xml_Document;
   Node: Xml_Node;
   Gnat_Prep: Xml_Node;
   Par_Node: Xml_Node;
begin

   pragma Assert(Node.Empty = True);

   Ada.Text_IO.Put_Line("Running");
   Load(Doc,"pugitest.xml");

   Ada.Text_IO.Put_Line("Getting Child");
   Child(Doc,"entities",Node);
   Ada.Text_IO.Put("Node name is '");
   Ada.Text_IO.Put(Node.Name);
   Ada.Text_IO.Put_Line("', Type=" & XML_Node_Type'Image(Node.Node_Type));

   pragma Assert(Node.Empty = False);

   Child(Node,"gnatprep",Gnat_Prep);
   Ada.Text_IO.Put("Gnat_Prep name is '");
   Ada.Text_IO.Put(Gnat_Prep.Name);
   Ada.Text_IO.Put_Line("'");

   declare
      V : String := Gnat_Prep.Node_Value;
   begin
      Ada.Text_IO.Put("Value='");
      Ada.Text_IO.Put(V);
      Ada.Text_IO.Put_line("'");
   end;

   declare
      First, Last, Temp : XML_Node;
   begin
      First_Child(Gnat_Prep,First);
      Last_Child(Gnat_Prep,Last);
      Ada.Text_IO.Put("First and last child of Gnat_Prep are ");
      Ada.Text_IO.Put(First.Name);
      Ada.Text_IO.Put(" and ");
      Ada.Text_IO.Put_Line(Last.Name);

      Ada.Text_IO.Put_Line("All Siblings are:");
      Temp := First;
      loop
         Ada.Text_IO.Put_Line(Temp.Name);
         Temp.Next_Sibling(Temp);
         exit when Temp.Is_Null;
      end loop;
      Ada.Text_IO.Put_Line("--");

      Ada.Text_IO.Put_Line("All Siblings in Reverse Order:");
      Temp := Last;
      loop
         Ada.Text_IO.Put_Line(Temp.Name);
         Temp.Previous_Sibling(Temp);
         exit when Temp.Is_Null;
      end loop;
      Ada.Text_IO.Put_Line("--");
   end;

   Parent(Gnat_Prep,Par_Node);
   Ada.Text_IO.Put("Parent name is '");
   Ada.Text_IO.Put(Par_Node.Name);
   Ada.Text_IO.Put_Line("'");

   declare
      Root : XML_Node;
      Temp : XML_Node;
   begin
      Gnat_Prep.Root_Node(Root);
      Root.First_Child(Temp);
      pragma Assert(Temp.Name = "entities");
      Ada.Text_IO.Put_Line("Root passed.");
   end;

   declare
      Root : XML_Node;
      Temp : XML_Node;
   begin
      Doc.As_Node(Root);
      Root.First_Child(Temp);
      pragma Assert(Temp.Name = "entities");
      Ada.Text_IO.Put_Line("As_Node passed.");
   end;

   Ada.Text_IO.Put_Line("Done");

end PugiTest;
