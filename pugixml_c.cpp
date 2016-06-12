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
	pugi::xml_document *pugi_new_xml_document();
	void pugi_delete_xml_document(pugi::xml_document *doc);
	void pugi_load_xml_file(pugi::xml_document *obj,const char *pathname);

	int pugi_node_empty(pugi::xml_node obj);
	int pugi_node_type(pugi::xml_node obj);

	pugi::xml_node pugi_xml_child(pugi::xml_document *obj,const char *name);
	pugi::xml_node pugi_xml_parent(pugi::xml_node obj);
	pugi::xml_node pugi_node_child(pugi::xml_node obj,const char *name);

	const char *pugi_node_name(pugi::xml_node xml_node);
	const char *pugi_node_value(pugi::xml_node xml_node);
}

pugi::xml_document *
pugi_new_xml_document() {
	assert(sizeof(pugi::xml_node) == sizeof(void*));
	assert(sizeof(pugi::xml_attribute) == sizeof(void*));
	return new pugi::xml_document();
}

void
pugi_delete_xml_document(pugi::xml_document *obj) {
	delete obj;
}

void
pugi_load_xml_file(pugi::xml_document *obj,const char *pathname) {
	
	obj->load_file(pathname);
}

pugi::xml_node
pugi_xml_child(pugi::xml_document *doc,const char *name) {
	return doc->child(name);
}

const char *
pugi_node_name(pugi::xml_node xml_node) {

	return xml_node.name();
}

const char *
pugi_node_value(pugi::xml_node xml_node) {

	return xml_node.value();
}

pugi::xml_node 
pugi_xml_parent(pugi::xml_node obj) {
	return obj.parent();
}

pugi::xml_node
pugi_node_child(pugi::xml_node obj,const char *name) {

	return obj.child(name);
}

int
pugi_node_empty(pugi::xml_node obj) {
	return obj.empty() ? 1 : 0;
}

int
pugi_node_type(pugi::xml_node obj) {
	return obj.type();
}

// End pugixml_c.cpp
