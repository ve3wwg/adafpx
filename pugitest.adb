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
begin

   Ada.Text_IO.Put_Line("Running");
   Load(Doc,"config.xml");
   Ada.Text_IO.Put_Line("Done");

end PugiTest;

