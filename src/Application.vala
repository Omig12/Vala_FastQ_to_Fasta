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

        string filename = "";
        open_button.clicked.connect (() =>{

            var file_chooser = new Gtk.FileChooserDialog("Open File", main_window, Gtk.FileChooserAction.OPEN,"_Cancel", Gtk.ResponseType.CANCEL, "_Open", Gtk.ResponseType.ACCEPT, null);

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

            // open_file();

            convert_button.sensitive = true;
            convert_button.set_label ("Convert to Fasta");
        });

	    convert_button.clicked.connect (() => {

	        int lines = 0;
            string[] text = text_view.buffer.text.split("\n");
            string edit = "";

            foreach (string line in text) {
                lines += 1;
                if (lines != 3 && lines != 4) {
                    edit = string.join("\n", edit ,line);
                    // stdout.printf (@"$lines $line \n\n");
                };
                if (lines == 4) {
                    lines = 0;
                };
                // stdout.printf (@"$edit");
            };

            text_view.buffer.text = edit[1:-1];
            // stdout.printf ("FileConverted\n");

            convert_button.set_label ("File Converted");
            convert_button.sensitive = false;
            save_button.sensitive = true;
        });

        save_button.clicked.connect (() =>{
            try {
                // stdout.printf("%s \n",filename[0:-6]);
                FileUtils.set_contents(string.join(".",filename[0:-6],"fasta"), text_view.buffer.text);
            } catch (Error e) {
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