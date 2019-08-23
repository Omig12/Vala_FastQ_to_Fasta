public class  Fastq_to_Fasta : Gtk.Application {
    public Fastq_to_Fasta() {
        Object (
            application_id: "com.github.omig12.Vala_FastQ_to_Fasta",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this);
        main_window.title = "FastQ to Fasta";
        main_window.window_position = Gtk.WindowPosition.CENTER;
        main_window.set_default_size (750, 750);

        var toolbar = new Gtk.Toolbar ();
        toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_PRIMARY_TOOLBAR);

        var open_icon = new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
        var open_button = new Gtk.ToolButton (open_icon, "Open");
        open_button.is_important = true;
        toolbar.add (open_button);

        var convert_icon = new Gtk.Image.from_icon_name ("document-edit", Gtk.IconSize.SMALL_TOOLBAR);
        var convert_button = new Gtk.ToolButton (convert_icon, "Convert to Fasta");
        convert_button.sensitive = false;
        convert_button.is_important = true;
        toolbar.add (convert_button);

        var save_icon = new Gtk.Image.from_icon_name ("document-save-as", Gtk.IconSize.SMALL_TOOLBAR);
        var save_button = new Gtk.ToolButton (save_icon, "Save as");
        save_button.sensitive = false;
        save_button.is_important = true;
        toolbar.add (save_button);

        var text_view = new Gtk.TextView ();
        text_view.editable = false;
        text_view.cursor_visible = false;

        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scroll.add (text_view);

        var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        vbox.pack_start (toolbar, false, true, 0);
        vbox.pack_start (scroll, true, true, 0);
        main_window.add (vbox);

        var file_chooser = new Gtk.FileChooserDialog("Open File", main_window, Gtk.FileChooserAction.OPEN,"_Cancel", Gtk.ResponseType.CANCEL, "_Open", Gtk.ResponseType.ACCEPT, null);
        var file_saver = new Gtk.FileChooserDialog("Save file as", main_window, Gtk.FileChooserAction.SAVE,"_Cancel", Gtk.ResponseType.CANCEL, "_Save", Gtk.ResponseType.ACCEPT, null);


    //
    // Methods
    //

        string filename = "";
        open_button.clicked.connect (() =>{
            if (file_chooser.run() == Gtk.ResponseType.ACCEPT) {
                filename = file_chooser.get_filename ();
            }
            file_chooser.destroy ();
            try {
                string text;
                FileUtils.get_contents (filename, out text);
                text_view.buffer.text = text;
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
            convert_button.sensitive = true;
            convert_button.set_label ("Convert to Fasta");
        });


        // Convert file method
	    convert_button.clicked.connect (() => {
	        int lines = 0;
            string[] text = text_view.buffer.text.split("\n");
            text_view.buffer.text = "";

            foreach (string line in text) {
                lines += 1;
                if (lines != 3 && lines != 4) {
                    if (lines == 1) {
                        // text_view.buffer.text = string.join("\n",text_view.buffer.text, "Here! Inner \n");
                        // line = line.splice(0,1,">");
                        // line = string.join("",">", line[1:-1]);
                        text_view.buffer.text = string.join("\n",text_view.buffer.text, line.splice(0,1,">"));
                    }
                    if (lines == 2) {
                        text_view.buffer.text = string.join("\n",text_view.buffer.text, line);
                    }
                }
                if (lines == 4) {
                    lines = 0;
                }
            }
            text_view.buffer.text = text_view.buffer.text[1:-2];
            stdout.printf ("FileConverted\n");
            convert_button.set_label ("File Converted");
            convert_button.sensitive = false;
            save_button.sensitive = true;
        });


        // Save file method

        save_button.clicked.connect (() =>{
            try {
                file_saver.set_do_overwrite_confirmation (true);
                file_saver.set_current_name (string.join(".",filename[0:-6],"fasta"));
                if (file_saver.run() == Gtk.ResponseType.ACCEPT) {
                    string name = file_saver.get_filename ();
                    FileUtils.set_contents(name, text_view.buffer.text);
                }
                file_saver.destroy ();
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
            save_button.sensitive = false;
        });
        main_window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Fastq_to_Fasta ();
        return app.run (args);
    }

}

