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
	pugi::xml_node pugi_doc_node(pugi::xml_document *doc);
	void pugi_delete_xml_document(pugi::xml_document *doc);
	void pugi_load_xml_file(pugi::xml_document *obj,const char *pathname);

	int pugi_node_empty(pugi::xml_node obj);
	int pugi_node_type(pugi::xml_node obj);

	pugi::xml_node pugi_xml_child(pugi::xml_document *obj,const char *name);
	pugi::xml_node pugi_xml_parent(pugi::xml_node obj);
	pugi::xml_node pugi_node_child(pugi::xml_node obj,const char *name);
	pugi::xml_node pugi_first_child(pugi::xml_node obj);
	pugi::xml_node pugi_last_child(pugi::xml_node obj);
	pugi::xml_node pugi_root_node(pugi::xml_node obj);
	pugi::xml_node pugi_next_sibling(pugi::xml_node obj);
	pugi::xml_node pugi_prev_sibling(pugi::xml_node obj);
	const char *pugi_node_name(pugi::xml_node obj);
	const char *pugi_node_value(pugi::xml_node obj);

	const char *pugi_child_value(pugi::xml_node obj);
	const char *pugi_named_child_value(pugi::xml_node obj,const char *name);
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
pugi_doc_node(pugi::xml_document *doc) {
	return doc->document_element();
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

pugi::xml_node
pugi_first_child(pugi::xml_node obj) {
	return obj.first_child();
}

pugi::xml_node 
pugi_last_child(pugi::xml_node obj) {
	return obj.last_child();
}

pugi::xml_node 
pugi_root_node(pugi::xml_node obj) {
	return obj.root();
}

pugi::xml_node
pugi_next_sibling(pugi::xml_node obj) {
	return obj.next_sibling();
}

pugi::xml_node
pugi_prev_sibling(pugi::xml_node obj) {
	return obj.previous_sibling();
}

const char *
pugi_child_value(pugi::xml_node obj) {
	return obj.child_value();
}

const char *
pugi_named_child_value(pugi::xml_node obj,const char *name) {
	return obj.child_value(name);
}

// End pugixml_c.cpp
