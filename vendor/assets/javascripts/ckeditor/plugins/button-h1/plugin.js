(function(){
    var a= {
            exec:function(editor){
                var format = {
                    element : "h3"
                };
                var style = new CKEDITOR.style(format);
                style.apply(editor.document);
            }
        },

    b="button-h1";
    CKEDITOR.plugins.add(b,{
        init:function(editor){
            editor.addCommand(b,a);
            editor.ui.addButton(b,{
                label:"H1",
//                icon: this.path + "button-h1.png",
                command:b
            });
        }
    });
})();
