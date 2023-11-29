public class SubjectManager : Object {
    private static Once<SubjectManager> instance;
    public static SubjectManager get_default () {
        return instance.once (() => new SubjectManager ());
    }

    public HashTable<string, Subject> subjects;

    construct {
        subjects = new HashTable<string, Subject> (str_hash, str_equal);
    }

    public void write_to_file (File file, string write_data) {
        uint8[] write_bytes = (uint8[]) write_data.to_utf8 ();

        try {
            file.replace_contents (write_bytes, null, false, FileCreateFlags.NONE, null, null);
        } catch (Error e) {
            print (e.message);
        }
    }




    public string read_from_file (File file)
    {
        try {
            string file_content = "";
            uint8[] contents;
            string etag_out;


            file.load_contents (null, out contents, out etag_out);

            file_content = (string) contents;

            return file_content;
        } catch (Error e) {
            print ("Error: %s\n", e.message);
        }
        return "-1";
    }


    public void read_data () {
        for (int i = 0; i < 20 && FileUtils.test (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i", FileTest.EXISTS); i++) {
            File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");

            var parser = new SubjectParser ();
            Subject sub = parser.to_object (read_from_file (file));
            subjects[sub.name] = sub;
        }
    }

    public void write_data () {
        int z = 0;
        File dir = File.new_for_path (Environment.get_user_data_dir () + "/gradebook/savedata/");
        if (!dir.query_exists ()) {
            try {
                dir.make_directory_with_parents ();
            } catch (Error e) {
                print (e.message);
            }
        }
        int i = 0;
        foreach (var subject in subjects.get_values ()) {
            var parser = new SubjectParser ();
            File file = File.new_for_path (Environment.get_user_data_dir () + @"/gradebook/savedata/subjectsave$i");
            //TODO: Delete old files
            write_to_file (file, parser.to_string (subject));
            warning ("write: %s", parser.to_string (subject));
            z = i + 1;
            i++;
        }
    }



    // public void new_grade (int index, string grade, string note, int c) {
    //     bool worked = false;

    //     for (int i = 0; i < subjects[index].grades.length; i++) {
    //         if (subjects[index].grades[i] == null) {
    //             subjects[index].grades[i] = new Grade (grade, note, c);
    //             i = subjects[index].grades.length;
    //             worked = true;
    //         }
    //     }


    //     if (worked == false) {
    //         print ("no more grades available");
    //     } else {
    //         window_grade_rows_ui (index);
    //     }
    // }




    public void new_subject (string name, Category[] c) {
        bool worked = false;

        subjects[name] = new Subject (name);
    }

    // public void delete_grade (int sub_index, int gra_index) {
    //     subjects[sub_index].grades[gra_index] = null;


    //     for (int i = gra_index; i < subjects[sub_index].grades.length - 1; i++) {
    //         subjects[sub_index].grades[i] = subjects[sub_index].grades[i + 1];
    //     }

    //     subjects[sub_index].grades[subjects[sub_index].grades.length - 1] = null;

    //     window_grade_rows_ui (sub_index);
    // }
}
