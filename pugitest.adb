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
   use Ada.Text_IO;

   Doc:  Xml_Document;
   Node: Xml_Node;
   Gnat_Prep: Xml_Node;
   Par_Node: Xml_Node;
begin

   pragma Assert(Node.Empty = True);

   Put_Line("Running");
   Load(Doc,"pugitest.xml");

   Put_Line("Getting Child");
   Child(Doc,"entities",Node);
   Put("Node name is '");
   Put(Node.Name);
   Put_Line("', Type=" & XML_Node_Type'Image(Node.Node_Type));

   pragma Assert(Node.Empty = False);

   Child(Node,"gnatprep",Gnat_Prep);
   Put("Gnat_Prep name is '");
   Put(Gnat_Prep.Name);
   Put_Line("'");

   pragma Assert(Gnat_Prep = Gnat_Prep);
   declare
      Other : XML_Node;
   begin
      Child(Node,"gnatprep",Other);
      pragma Assert(Gnat_Prep = Other);
      pragma Assert(Other /= Par_Node);
   end;

   declare
      V : String := Gnat_Prep.Value;
   begin
      Put("Value='");
      Put(V);
      Put_line("'");
   end;

   declare
      First, Last, Temp : XML_Node;
   begin
      First_Child(Gnat_Prep,First);
      Last_Child(Gnat_Prep,Last);
      Put("First and last child of Gnat_Prep are ");
      Put(First.Name);
      Put(" and ");
      Put_Line(Last.Name);

      Put_Line("All Siblings are:");
      Temp := First;
      loop
         Put_Line(Temp.Name);
         Temp.Next_Sibling(Temp);
         exit when Temp.Is_Null;
      end loop;
      Put_Line("--");

      Put_Line("All Siblings in Reverse Order:");
      Temp := Last;
      loop
         Put_Line(Temp.Name);
         Temp.Previous_Sibling(Temp);
         exit when Temp.Is_Null;
      end loop;
      Put_Line("--");

      declare
         Middle : String := First.Child_Value;
      begin
         Put_Line("Child value is '" & Middle & "'");
      end;

      declare
         Middle : String := Gnat_Prep.Child_Value("Middle");
         M : XML_Node;
      begin
         Put_Line("Child value('Middle') is '" & Middle & "'");
         Gnat_Prep.Child("Middle",M);

         declare
            Mid2 : String := M.Text;
         begin
         pragma Assert(Mid2 = Middle);
         end;
      end;
   end;

   Parent(Gnat_Prep,Par_Node);
   Put("Parent name is '");
   Put(Par_Node.Name);
   Put_Line("'");

   declare
      Root : XML_Node;
      Temp : XML_Node;
   begin
      Gnat_Prep.Root_Node(Root);
      Root.First_Child(Temp);
      pragma Assert(Temp.Name = "entities");
      Put_Line("Root passed.");
   end;

   declare
      Attr : XML_Attribute;
   begin
      Gnat_Prep.First_Attribute(Attr);
      loop
         Put("Attribute: ");
         Put_Line(Attr.Name);
         Attr.Next_Attribute(Attr);
         exit when Attr.Is_Null;
      end loop;

      Put_Line("In Reverse Order:");
      Gnat_Prep.Last_Attribute(Attr);
      loop
         Put("Attribute: ");
         Put_Line(Attr.Name);
         Attr.Previous_Attribute(Attr);
         exit when Attr.Is_Null;
      end loop;
   end;

   declare
      Root : XML_Node;
      Temp : XML_Node;
      A1, A2, A3, A4: XML_Attribute;
   begin
      Doc.As_Node(Root);
      Root.First_Child(Temp);
      pragma Assert(Temp.Name = "entities");
      Put_Line("As_Node passed.");

      Temp.Append_Attribute("A4",A4);
      Temp.Prepend_Attribute("A1",A1);
      Temp.Insert_Attribute_After("A2",A1,A2);
      Temp.Insert_Attribute_Before("A3",A4,A3);

   end;

   Put_Line("Testing document creation:");

   declare
      New_Doc : XML_Document;
      Root : XML_Node;
      OK : Boolean;
   begin
      New_Doc.As_Node(Root);
      Root.Set_Name("Named_Root",OK);
      pragma Assert(OK);
      Root.Set_Value("OINKERS",OK);
      pragma Assert(OK);
      pragma Assert(Root.Name = "Named_Root");
      pragma Assert(Root.Value = "OINKERS");
      Put_Line("New Document Test passed.");
   end;

   declare
      First, Two, Last: XML_Attribute;
   begin
      First_Attribute(Gnat_Prep,First);
      Attribute(Gnat_Prep,"Two",Two);
      Last_Attribute(Gnat_Prep,Last);

      pragma Assert(First.Name = "attr1");
      pragma Assert(Two.Name = "attr2");
      pragma Assert(Last.Name = "attr3");

      pragma Assert(First.Value = "One");
      pragma Assert(Two.Value = "Two");
      pragma Assert(Last.Value = "Three");

      pragma Assert(First.Empty = False);
      pragma Assert(Two.Empty = False);
      pragma Assert(Last.Empty = False);

      Put_Line("Attributes passed.");
   end;

   Put_Line("Done");

end PugiTest;
