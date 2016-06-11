//////////////////////////////////////////////////////////////////////
// pugixml_c.cpp -- C Interface to PugiXml
// Date: Fri Jun 10 22:15:37 2016  (C) Warren W. Gay VE3WWG 
///////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>

#include "pugixml.hpp"

extern "C" {
	void *pugi_new_xml_document();
	void pugi_delete_xml_document(void *doc);
	void pugi_load_xml_file(void *obj,const char *pathname);
}

void *
pugi_new_xml_document() {
	return new pugi::xml_document();
}

void
pugi_delete_xml_document(void *obj) {
	delete (pugi::xml_document*)obj;
}

void
pugi_load_xml_file(void *obj,const char *pathname) {
	pugi::xml_document *doc = (pugi::xml_document*)obj;
	
	doc->load_file(pathname);
}

// End pugixml_c.cpp
