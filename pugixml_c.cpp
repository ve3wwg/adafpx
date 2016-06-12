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
	pugi::xml_node *pugi_xml_child(pugi::xml_document *obj,const char *name);
	void pugi_delete_node(pugi::xml_node *obj);
	const char *pugi_node_name(pugi::xml_node *xml_node);
	pugi::xml_node *pugi_xml_parent(pugi::xml_node *obj);
	pugi::xml_node *pugi_node_child(pugi::xml_node *obj,const char *name);
}

pugi::xml_document *
pugi_new_xml_document() {
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

pugi::xml_node *
pugi_xml_child(pugi::xml_document *doc,const char *name) {
	pugi::xml_node child = doc->child(name);

	pugi::xml_node *rchild = new pugi::xml_node;
	*rchild = child;
	
	return rchild;
}

void
pugi_delete_node(pugi::xml_node *node) {

	delete node;
}

const char *
pugi_node_name(pugi::xml_node *xml_node) {

	return xml_node->name();
}

pugi::xml_node *
pugi_xml_parent(pugi::xml_node *obj) {
	pugi::xml_node *rnode = new pugi::xml_node;

	*rnode = obj->parent();
	return rnode;
}

pugi::xml_node *
pugi_node_child(pugi::xml_node *obj,const char *name) {
	pugi::xml_node *rnode = new pugi::xml_node;

	*rnode = obj->child(name);
	return rnode;
}

// End pugixml_c.cpp
