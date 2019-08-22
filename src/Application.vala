using Gtk;

public class Fastq_to_Fasta : Window {

    private TextView text_view;

    public Fastq_to_Fasta () {
        this.title = "FastQ to Fasta";
        this.window_position = WindowPosition.CENTER;
        set_default_size (750, 750);

        var toolbar = new Toolbar ();
        toolbar.get_style_context ().add_class (STYLE_CLASS_PRIMARY_TOOLBAR);

        var open_icon = new Gtk.Image.from_icon_name ("document-open", IconSize.SMALL_TOOLBAR);
        var open_button = new Gtk.ToolButton (open_icon, "Open");

        var convert_icon = new Gtk.Image.from_icon_name ("document-edit", IconSize.SMALL_TOOLBAR);
        var convert_button = new Gtk.ToolButton (convert_icon, "Convert to Fasta");
        convert_button.sensitive = false;

        var save_icon = new Gtk.Image.from_icon_name ("document-save-as", IconSize.SMALL_TOOLBAR);
        var save_button = new Gtk.ToolButton (save_icon, "Save as");
        save_button.sensitive = false;

        open_button.is_important = true;
        toolbar.add (open_button);


        convert_button.is_important = true;
        toolbar.add (convert_button);

        save_button.is_important = true;
        toolbar.add (save_button);

        open_button.clicked.connect (() =>{
            on_open_clicked();
            convert_button.sensitive = true;
            convert_button.set_label ("Convert to Fasta");
        });

		convert_button.clicked.connect (() => {
            convert_button.set_label ("File Converted");
            convert_button.sensitive = false;
            convert_file();
            save_button.sensitive = true;
        });

        save_button.clicked.connect (() =>{
            save_file();
            save_button.sensitive = false;
        });

        this.text_view = new TextView ();
        this.text_view.editable = false;
        this.text_view.cursor_visible = false;

        var scroll = new ScrolledWindow (null, null);
        scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll.add (this.text_view);

        var vbox = new Box (Orientation.VERTICAL, 0);
        vbox.pack_start (toolbar, false, true, 0);
        vbox.pack_start (scroll, true, true, 0);
        add (vbox);
    }

    private void on_open_clicked () {
        var file_chooser = new FileChooserDialog ("Open File", this,
                                      FileChooserAction.OPEN,
                                      "_Cancel", ResponseType.CANCEL,
                                      "_Open", ResponseType.ACCEPT);
        if (file_chooser.run () == ResponseType.ACCEPT) {
            open_file (file_chooser.get_filename ());
        }
        file_chooser.destroy ();
        // return file_chooser.get_filename ();
    }

    private void open_file (string filename) {
        try {
            string text;
            FileUtils.get_contents (filename, out text);
            this.text_view.buffer.text = text;
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
    }

    public void convert_file () {
            int lines = 0;
            // string all_text = ;
            string[] text = this.text_view.buffer.text.split("\n");
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

            this.text_view.buffer.text = edit[1:-1];
            // stdout.printf ("FileConverted\n");
    }

     public void save_file () {
        try {
            FileUtils.set_contents ("converted.fastq", this.text_view.buffer.text);
            } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        var window = new Fastq_to_Fasta ();
        window.destroy.connect (Gtk.main_quit);
        window.show_all ();

        Gtk.main ();
        return 0;
    }
}