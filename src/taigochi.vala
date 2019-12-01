using Taigo.Globals;

namespace Taigo {
    public enum Taigos { TAIKOCHI, TAIKOCHA, TAIKOCHE, MOLICHI }
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
            names[Taigos.MOLICHI] = "Molichi";

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
        public int missed_calls {get; set;}

        // Drawing
        public Clutter.Actor self_img;
        public Clutter.Actor bg;
        public GtkClutter.Actor complain;
        public Gtk.Label complain_text;

        // State machine
        public Taigo.StateManager.StateMachine sm;

        protected void init_move() {
            int offset = 0;
			Timeout.add(1000, () => {
                offset += Random.int_range(-2, 3);
                if (offset < -5)
                    offset = -5;
                if (offset > 5)
                    offset = 5;
                self_img.animate(
                    Clutter.AnimationMode.EASE_IN_OUT_CUBIC, 100, 
                    "x", calc_center(scene.get_stage(), self_img, false) + (offset * 20),
                    "y", calc_bottom(scene.get_stage(), self_img) - 30
                );
                complain.animate(
                    Clutter.AnimationMode.EASE_IN_OUT_CUBIC, 100, 
                    "x", calc_center(scene.get_stage(), self_img, false) + (offset * 20),
                    "y", complain.y = self_img.y - complain.height - 20
                );
				return true;
			}, Priority.DEFAULT);
        }
        protected void init_blink() {
			Timeout.add(3273, () => {
                var pixbuf = new Gdk.Pixbuf.from_resource(this.get_image_name("blink"));
                var img = new Clutter.Image();
                img.set_data(
                    pixbuf.get_pixels(),
                    pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
                    pixbuf.width,
                    pixbuf.height,
                    pixbuf.rowstride
                );
                self_img.content = img;
                self_img.set_size (pixbuf.width, pixbuf.height);
				Timeout.add(Random.int_range(100,500), () => {
                    var _pixbuf = new Gdk.Pixbuf.from_resource(this.get_image_name("normal"));
                    var _img = new Clutter.Image();
                    _img.set_data(
                        _pixbuf.get_pixels(),
                        _pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
                        _pixbuf.width,
                        _pixbuf.height,
                        _pixbuf.rowstride
                    );
                    self_img.content = _img;
                    self_img.set_size (_pixbuf.width, _pixbuf.height);
					return false;
				}, Priority.DEFAULT);
				return true;
			}, Priority.DEFAULT);
        }
        protected void init_popover() {
            var poppy = new Gtk.Popover(null);
            poppy.modal = false;
            complain_text = new Gtk.Label("");
            complain_text.get_style_context().add_class("title-2");
            complain_text.margin = 20;
            poppy.add(complain_text);
            poppy.show_all();
            
            complain = new GtkClutter.Actor.with_contents(poppy);
            complain.hide();
            scene.get_stage().add(complain);
        }
        protected void init_character() {
            var pixbuf = new Gdk.Pixbuf.from_resource(this.get_image_name("normal"));
            var img = new Clutter.Image();
            img.set_data(
                pixbuf.get_pixels(),
                pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
                pixbuf.width,
                pixbuf.height,
                pixbuf.rowstride
            );
            self_img = new Clutter.Actor ();
            self_img.content = img;
            self_img.set_size (pixbuf.width, pixbuf.height);
            scene.get_stage().add(self_img);

            self_img.x = calc_center(scene.get_stage(), self_img, false);
            self_img.y = calc_bottom(scene.get_stage(), self_img) - 30;
        }
        protected void init_bg() {
            var pixbuf = new Gdk.Pixbuf.from_resource("/com/github/appadeia/Taigo/images/bgs/home.svg");
            var img = new Clutter.Image();
            img.set_data(
                pixbuf.get_pixels(),
                pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
                pixbuf.width,
                pixbuf.height,
                pixbuf.rowstride
            );
            bg = new Clutter.Actor ();
            bg.content = img;
            bg.set_size (pixbuf.width, pixbuf.height);
            scene.get_stage().add(bg);
        }
        protected void init_clutter() {
            this.init_bg();
            this.init_character();
            this.init_popover();
            this.init_move();
            this.init_blink();
        }
        protected float calc_bottom(Clutter.Actor parent, Clutter.Actor child) {
            return (parent.get_height()) - (child.get_height());
        }
        protected float calc_center(Clutter.Actor parent, Clutter.Actor child, bool return_height) {
            if (!return_height) {
                return (parent.get_width() / 2) - (child.get_width() / 2);
            } else {
                return (parent.get_height() / 2) - (child.get_height() / 2);
            }
        }

        protected void _init() {
            Utils.init();

            this.hunger = 0;
            this.happy = 0;
            this.weight = 0;
            
            this.age = 0;
            
            this.care_misses = 0;
            this.missed_calls = 0;

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
        }

        public void feed() {
            if (this.ttype == Taigos.MOLICHI)
                return;
            if (this.hunger == 4) {
                this.weight++;
            }
            hunger ++;
            verify();
        }
        public void game() {
            if (this.ttype == Taigos.MOLICHI)
                return;
            happy = happy + Random.double_range(0.5, 1.5);
            this.weight--;
            verify();
        }
        public void treat() {
            if (this.ttype == Taigos.MOLICHI)
                return;
            feed();
            game();

            this.weight += 3;
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
            if (this.ttype == Taigos.MOLICHI)
                a = ". . .";
            complain_text.label = a;
            if (a == "") {
                complain.hide();
            } else {
                complain.show();
            }
            return a.strip();
        }

        public void tick() {
            if (complaints() != "") {
                this.missed_calls++;
            }
            if (this.missed_calls > 3) {
                this.care_misses++;
                this.missed_calls = 0;
            }
            if (this.care_misses > 5) {
                this.ttype = Taigos.MOLICHI;
                var pixbuf = new Gdk.Pixbuf.from_resource("/com/github/appadeia/Taigo/images/bgs/graveyard.svg");
                var img = new Clutter.Image();
                img.set_data(
                    pixbuf.get_pixels(),
                    pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
                    pixbuf.width,
                    pixbuf.height,
                    pixbuf.rowstride
                );
                bg.content = img;
                bg.set_size (pixbuf.width, pixbuf.height);
            }
            if (Random.int_range(0, 3) == 2) {
                this.hunger--;
            }
            if (Random.int_range(0, 2) == 1) {
                this.happy = this.happy - Random.double_range(0.1, 1);
            }
            verify();
        }

        public Mood calc_mood() {
            if (this.ttype == Taigos.MOLICHI)
                return Mood.BAD;
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
            const string resource_root = "/com/github/appadeia/Taigo/images/taigochi";
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
            this._init_statemachine();
            this.init_clutter();
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
            Timeout.add(50, () => {
                return true;
            }, Priority.DEFAULT);
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
                this.missed_calls = obj.missed_calls;
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
                this.notify_property("missed_calls");
                this.notify_property("gender");
                this.notify_property("ttype");
                this.notify_property("hunger");
                this.notify_property("happy");
                return false;
            }, Priority.DEFAULT);
            this.init_clutter();
            this._init_statemachine();
        }
        protected void _init_statemachine() {
            this.sm = new StateManager.StateMachine();
            
            var idle_tick = new StateManager.Idle() {
                interval = Taigo.Globals.fastfoward ? 5000 : 300000,
                name = "tick"
            };
            var normal_state = new StateManager.State() {
                name = "normal",
                idles = { idle_tick }
            };
            var daycare_state = new StateManager.State() {
                name = "daycare"
            };
            var norm_to_day = new StateManager.StateTransition() {
                from = "normal",
                to = "daycare"
            };
            var day_to_norm = new StateManager.StateTransition() {
                from = "daycare",
                to = "normal"
            };

            this.sm.add_state(normal_state);
            this.sm.add_state(daycare_state);
            this.sm.add_state_transition(norm_to_day);
            this.sm.add_state_transition(day_to_norm);
            this.sm.idle.connect((i) => {
                if (i == "tick") {
                    this.tick();
                }
            });
        }
    }
}