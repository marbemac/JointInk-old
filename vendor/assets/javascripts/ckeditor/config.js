/**
 * Copyright (c) 2003-2012, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
    CKEDITOR.config.toolbar_Basic = [['Bold', 'Italic', 'button-h1', 'button-h2', 'Blockquote', 'Link', 'Unlink']];
    config.toolbar = 'Basic';
    config.startupOutlineBlocks = true;
    config.extraPlugins = "button-h1,button-h2,whitelist";
    config.linkShowAdvancedTab = false
    config.linkShowTargetTab = false
//    config.forcePasteAsPlainText = true
};