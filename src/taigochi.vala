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

        // Other
        public int care_misses;

        protected void _init() {
            Utils.init();

            this.hunger = 0;
            this.happy = 0;
            
            this.age = 0;
            
            this.care_misses = 0;

            this.gender = Utils.gender_from_taigo_type(this.type);
        }

        public void tick() {
            if (Random.int_range(0, 3) == 2) {
                this.hunger--;
                if (this.hunger < 0)
                    this.hunger = 0;
                if (this.hunger > 4)
                    this.hunger = 4;
            }
            if (Random.int_range(0, 2) == 1) {
                this.happy = this.happy - Random.double_range(0.1, 1);
                if (this.happy < 0)
                    this.happy = 0;
                if (this.happy > 4)
                    this.happy = 4;
            }
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
            print(rand.to_string() + "\n");
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