-- pugi_xml.ads - Fri Jun 10 21:47:48 2016
--
-- (c) Warren W. Gay VE3WWG  ve3wwg@gmail.com
--
-- Protected under the following license:
-- GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

with Posix, System, Ada.Finalization;
use Posix;

package Pugi_Xml is

   type Xml_Document is new Ada.Finalization.Controlled with private;

   procedure Initialize(Obj: in out Xml_Document);
   procedure Finalize(Obj: in out Xml_Document);
   procedure Load(Obj: in out Xml_Document; Pathname: string);

private

   type Xml_Document is new Ada.Finalization.Controlled with
      record
         doc:           System.Address;   -- ptr to pugixml::xml_document
      end record;

end Pugi_Xml;
