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
        public Genders gender;
        public int age;
        public Taigos type;
        public int weight {get; set;}

        // Other
        public int care_misses;

        protected void _init() {
            Utils.init();

            this.hunger = 0;
            this.happy = 0;
            this.weight = 0;
            
            this.age = 0;
            
            this.care_misses = 0;

            this.gender = Utils.gender_from_taigo_type(this.type);
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
            var str = "%s/%s/%s.svg".printf(resource_root, Utils.names[this.type], state);
            return str;
        }

        public Taigochi.from_baby() {
            int rand = Random.int_range(0, 3);
            switch (rand) {
                case 0:
                    this.type = Taigos.TAIKOCHI;
                    break;
                case 1:
                    this.type = Taigos.TAIKOCHA;
                    break;
                case 2:
                    this.type = Taigos.TAIKOCHE;
                    break;
            }
            this._init();
        }
    }
}