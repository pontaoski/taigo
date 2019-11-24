namespace Taigo {
    public enum Taigos { TAIKOCHI, TAIKOCHA, TAIKOCHE }
    public enum Genders { MALE, FEMALE, ENBY }
    public enum Mood { BAD, OKAY, GOOD, GREAT, SICK }

    public class Utils {
        public static Taigos[] male = { Taigos.TAIKOCHI };
        public static Taigos[] female = { Taigos.TAIKOCHA };
        public static Taigos[] enby = { Taigos.TAIKOCHE };
        public static Gee.HashMap<Taigos,string> names;

        protected static bool initted = false;

        public static Genders gender_from_taigo_type(Taigos type) {
            for (int i = 0; i < Utils.male.length; i++ ) {
                if (type == Utils.male[i]) {
                    return Genders.MALE;
                }
            }
            for (int i = 0; i < Utils.female.length; i++ ) {
                if (type == Utils.female[i]) {
                    return Genders.FEMALE;
                }
            }
            return Genders.ENBY;
        }

        public static void init() {
            if (initted)
                return;

            names = new Gee.HashMap<Taigos,string>();

            names[Taigos.TAIKOCHI] = "Taikochi";
            names[Taigos.TAIKOCHA] = "Taikocha";
            names[Taigos.TAIKOCHE] = "Taikoche";

            male = { Taigos.TAIKOCHI };
            female = { Taigos.TAIKOCHA };
            enby = { Taigos.TAIKOCHE };

            initted = true;
        }
    }
    public class Taigochi : Object {
        // Needs
        public double hunger {get; set;}
        public double happy {get; set;}
        
        // About
        public int gender {get; set;}
        public int age {get; set;}
        public int ttype {get; set;}
        public int weight {get; set;}

        // Other
        public int care_misses {get; set;}

        protected void _init() {
            Utils.init();

            this.hunger = 0;
            this.happy = 0;
            this.weight = 0;
            
            this.age = 0;
            
            this.care_misses = 0;

            this.gender = Utils.gender_from_taigo_type((Taigos) this.ttype);
        }

        public void verify() {
            if (this.hunger < 0)
                this.hunger = 0;
            if (this.hunger > 4)
                this.hunger = 4;
            if (this.happy < 0)
                this.happy = 0;
            if (this.happy > 4)
                this.happy = 4;
            if (this.weight < 0)
                this.weight = 0;
            
            this.notify_property("weight");
            this.notify_property("happy");
            this.notify_property("hunger");
        }

        public void feed() {
            if (this.hunger == 4) {
                this.weight++;
                this.notify_property("weight");
            }
            hunger ++;
            verify();
        }
        public void game() {
            happy = happy + Random.double_range(0.5, 1.5);
            this.weight--;
            this.notify_property("weight");
            verify();
        }
        public void treat() {
            feed();
            game();

            this.weight += 3;
            this.notify_property("weight");
            verify();
        }
        public string complaints() {
            string a = "";
            if (hunger <= 2)
                a += "Feed me!\n";
            if (happy <= 2)
                a += "Play with me!\n";
            if (weight >= 4)
                a += "I'm fat!\n";
            return a.strip();
        }

        public void tick() {
            if (Random.int_range(0, 3) == 2) {
                this.hunger--;
            }
            if (Random.int_range(0, 2) == 1) {
                this.happy = this.happy - Random.double_range(0.1, 1);
            }
            verify();
        }

        public Mood calc_mood() {
            var mood = Mood.OKAY;
            if(hunger > 3 && happy > 3.5) {
                mood = Mood.GREAT;
            } else if (hunger > 3 && happy > 3) {
                mood = Mood.GOOD;
            } else if (hunger > 2 && happy > 2) {
                mood = Mood.OKAY;
            } else {
                mood = Mood.BAD;
            }
            return mood;
        }

        public string get_image_name(string state) {
            const string resource_root = "/me/appadeia/Taigo/images/taigochi";
            var str = "%s/%s/%s.svg".printf(resource_root, Utils.names[(Taigos) ttype], state);
            return str;
        }

        public Taigochi.from_baby() {
            int rand = Random.int_range(0, 3);
            switch (rand) {
                case 0:
                    ttype = Taigos.TAIKOCHI;
                    break;
                case 1:
                    ttype = Taigos.TAIKOCHA;
                    break;
                case 2:
                    ttype = Taigos.TAIKOCHE;
                    break;
            }
            this._init();
        }
        public void save() {
            var path = Path.build_path("/", Environment.get_user_data_dir(), "taigo", "saves", "taigo.tk");
            var path2 = Path.build_path("/", Environment.get_user_data_dir(), "taigo", "saves");

            var dir = File.new_for_path(path2);
            try {
                dir.make_directory_with_parents();
            } catch {}

            try {
                var obj_serialised = Json.gobject_to_data(this, null);
                var stream = FileStream.open(path, "w");
                
                stream.puts(obj_serialised);
            } catch (Error e) {
                print("%s\n", e.message);
            }
        }
        public Taigochi() {
            var path = Path.build_path("/", Environment.get_user_data_dir(), "taigo", "saves", "taigo.tk");
            try {
                string content;
                FileUtils.get_contents(path, out content);
                if (content == "") {
                    throw new FileError.INVAL("blank");
                }
                Taigochi obj = Json.gobject_from_data(typeof(Taigochi), content) as Taigochi;
                assert (obj != null);

                this.hunger = obj.hunger;
                this.happy = obj.happy;
                this.weight = obj.weight;
                this.age = obj.age;
                this.care_misses = obj.care_misses;
                this.gender = obj.gender;
                this.ttype = obj.ttype;

                Utils.init();
            } catch {
                print("randing\n");
                int rand = Random.int_range(0, 3);
                switch (rand) {
                    case 0:
                        ttype = Taigos.TAIKOCHI;
                        break;
                    case 1:
                        ttype = Taigos.TAIKOCHA;
                        break;
                    case 2:
                        ttype = Taigos.TAIKOCHE;
                        break;
                }
                this._init();
            }
            Timeout.add(100, () => {
                this.notify_property("weight");
                this.notify_property("age");
                this.notify_property("care_misses");
                this.notify_property("gender");
                this.notify_property("ttype");
                this.notify_property("hunger");
                this.notify_property("happy");
                return false;
            }, Priority.DEFAULT);
        }
    }
}