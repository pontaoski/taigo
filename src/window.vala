/* window.vala
 *
 * Copyright 2019 Carson Black
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using Taigo.Globals;

namespace Taigo {
	[GtkTemplate (ui = "/com/github/appadeia/Taigo/debugwindow.ui")]
	public class DebugWindow : Gtk.Window {
		[GtkChild]
		public Gtk.Box keyval;
	}

	[GtkTemplate (ui = "/com/github/appadeia/Taigo/debuglabel.ui")]
	public class DebugLabel : Gtk.Box {
		[GtkChild]
		public Gtk.Label key;
		[GtkChild]
		public Gtk.Label value;
	}

	[GtkTemplate (ui = "/com/github/appadeia/Taigo/game.ui")]
	public class Play : Gtk.Popover {
		[GtkCallback]
		private void rps() {
			print("taigochi null: %s\n", (taigochi == null).to_string());
			var changed = statemachine.change_to_state("away");
			if (changed) {
				var game = new Taigo.Rps();
				game.set_transient_for(global_win);
				game.present();
			}
		}
	}

	[GtkTemplate (ui = "/com/github/appadeia/Taigo/food.ui")]
	public class Food : Gtk.Popover {
		public signal void feed_meal ();
		public signal void feed_treat ();

		[GtkChild]
		Gtk.Image meal_img;
		[GtkChild]
		Gtk.Image treat_img;
		[GtkChild]
		Gtk.Button meal_btn;
		[GtkChild]
		Gtk.Button treat_btn;

		[GtkCallback]
		private void meal() {
			meal_btn.sensitive = false;
			Timeout.add((fastfoward ? 60 : 600), () => {
				meal_img.resource = "/com/github/appadeia/Taigo/images/animations/meal/eat-1.svg";
				Timeout.add((fastfoward ? 60 : 600), () => {
					meal_img.resource = "/com/github/appadeia/Taigo/images/animations/meal/eat-2.svg";
					Timeout.add((fastfoward ? 60 : 600), () => {
						meal_img.resource = "/com/github/appadeia/Taigo/images/animations/meal/eat-3.svg";
						Timeout.add((fastfoward ? 60 : 600), () => {
							meal_img.resource = "/com/github/appadeia/Taigo/images/animations/meal/eat-4.svg";
							Timeout.add((fastfoward ? 60 : 600), () => {
								meal_img.resource = "/com/github/appadeia/Taigo/images/animations/meal/blank.svg";
								Timeout.add((fastfoward ? 60 : 600), () => {
									meal_img.resource = "/com/github/appadeia/Taigo/images/animations/meal/idle.svg";
									meal_btn.sensitive = true;
									return false;
								}, Priority.DEFAULT);
								return false;
							}, Priority.DEFAULT);
							return false;
						}, Priority.DEFAULT);
						return false;
					}, Priority.DEFAULT);
					return false;
				}, Priority.DEFAULT);
				return false;
			}, Priority.DEFAULT);
			feed_meal();
		}

		[GtkCallback]
		private void treat() {
			treat_btn.sensitive = false;
			Timeout.add((fastfoward ? 60 : 600), () => {
				treat_img.resource = "/com/github/appadeia/Taigo/images/animations/treat/eat-1.svg";
				Timeout.add((fastfoward ? 60 : 600), () => {
					treat_img.resource = "/com/github/appadeia/Taigo/images/animations/treat/eat-2.svg";
					Timeout.add((fastfoward ? 60 : 600), () => {
						treat_img.resource = "/com/github/appadeia/Taigo/images/animations/treat/eat-3.svg";
						Timeout.add((fastfoward ? 60 : 600), () => {
							treat_img.resource = "/com/github/appadeia/Taigo/images/animations/treat/eat-4.svg";
							Timeout.add((fastfoward ? 60 : 600), () => {
								treat_img.resource = "/com/github/appadeia/Taigo/images/animations/treat/blank.svg";
								Timeout.add((fastfoward ? 60 : 600), () => {
									treat_img.resource = "/com/github/appadeia/Taigo/images/animations/treat/idle.svg";
									treat_btn.sensitive = true;
									return false;
								}, Priority.DEFAULT);
								return false;
							}, Priority.DEFAULT);
							return false;
						}, Priority.DEFAULT);
						return false;
					}, Priority.DEFAULT);
					return false;
				}, Priority.DEFAULT);
				return false;
			}, Priority.DEFAULT);
			feed_treat();
		}
	}

	[GtkTemplate (ui = "/com/github/appadeia/Taigo/status.ui")]
	public class Status : Gtk.Popover {
		[GtkChild]
		public Gtk.LevelBar food;

		[GtkChild]
		public Gtk.LevelBar happy;

		[GtkChild]
		public Gtk.Label gender;

		[GtkChild]
		public Gtk.Label weight;

		[GtkChild]
		public Gtk.Label tg_name;

	}

	[GtkTemplate (ui = "/com/github/appadeia/Taigo/window.ui")]
	public class Window : Gtk.ApplicationWindow {
		[GtkChild]
		Gtk.Button heart;

		[GtkChild]
		Gtk.Button eat;

		[GtkChild]
		Gtk.Button play;

		[GtkChild]
		Gtk.ToggleButton go;

		[GtkChild]
		Gtk.Image status_icon;

		[GtkChild]
		Gtk.MenuButton hamberder;

		[GtkChild]
		Gtk.Stack content_stack;

		[GtkChild]
		Gtk.Image taigo_sleeping;

		protected Status status;
		protected Food food;
		protected Play game;
		protected int offset;

		//  [GtkCallback]
		//  private void tick() {
		//  	taigochi.tick();
		//  }
		
		[GtkCallback]
		protected void save() {
			taigochi.save();
		}

		protected void debug_win() {
			var win = new Taigo.DebugWindow();
			string[] property_list = { "hunger", "happy", "gender", "age", "ttype", "weight", "care-misses", "missed-calls" };
			foreach(string s in property_list) {
				var kv = new Taigo.DebugLabel();
				kv.key.label = s;
				taigochi.bind_property(s, kv.value, "label", BindingFlags.DEFAULT, (a,b, ref c) => {
					if (b.holds(Type.DOUBLE))
						c = "%f".printf(b.get_double());
					if (b.holds(Type.INT))
						c = "%d".printf(b.get_int());
					return true;
				});
				win.keyval.add(kv);
			}
			win.show_all();
		}

		protected void init_taikochi(bool force_new = false) {
			if (force_new) {
				taigochi = new Taigochi.from_baby();
			} else {
				taigochi = new Taigochi();
			}

			taigochi.bind_property("hunger", status.food, "value", BindingFlags.DEFAULT);
			taigochi.bind_property("happy", status.happy, "value", BindingFlags.DEFAULT);
			taigochi.bind_property("weight", status.weight, "label", BindingFlags.DEFAULT, (a,b, ref c) => {
				c = "%dg".printf(taigochi.weight);
				return true;
			});
			taigochi.notify.connect(() => {
				status.food.value = taigochi.hunger;
				status.happy.value = taigochi.happy;	
			});
			statemachine.transitioned.connect(() => {
				print("Changing visible child name to: %s\n", statemachine.current_state);
				this.content_stack.set_visible_child_name(statemachine.current_state);
			});

			this.status.tg_name.set_text(Utils.names[(Taigos) taigochi.ttype]);
			status.food.value = taigochi.hunger;
			status.happy.value = taigochi.happy;

			taigo_sleeping.resource = taigochi.get_image_name("zzz");
			taigochi.bind_property("ttype", taigo_sleeping, "resource", BindingFlags.DEFAULT, (a, b, ref c) => {
				c = taigochi.get_image_name("zzz");
				return true;
			});

			if (taigochi.gender == Genders.MALE)
				this.status.gender.set_text("Male");
			if (taigochi.gender == Genders.FEMALE)
				this.status.gender.set_text("Female");
			if (taigochi.gender == Genders.ENBY)
				this.status.gender.set_text("Enby");

			Timeout.add_seconds(3, () => {
				var mood = taigochi.calc_mood();
				switch(mood) {
					case Mood.GREAT:
						status_icon.icon_name = "face-smile-big-symbolic";
						break;
					case Mood.GOOD:
						status_icon.icon_name = "face-smile-symbolic";
						break;
					case Mood.OKAY:
						status_icon.icon_name = "face-plain-symbolic";
						break;
					case Mood.BAD:
						status_icon.icon_name = "face-sad-symbolic";
						break;
				}
				taigochi.complaints();
				return true;
			}, Priority.DEFAULT);
			if(fastfoward)
				this.debug_win();
		}

		public Window (Gtk.Application app) {
			Object (application: app);
            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/appadeia/Taigo/css/app.css");

			var quit_action = new SimpleAction("quit", null);
			quit_action.activate.connect(() => {
				app.quit();
			});

            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                css_provider,
                1000
			);
			
			status = new Taigo.Status();
			status.relative_to = heart;
			heart.clicked.connect(() => {
				status.show_all();
			});

			food = new Taigo.Food();
			food.relative_to = eat;
			eat.clicked.connect(() => {
				food.show_all();
			});

			game = new Taigo.Play();
			game.relative_to = play;
			play.clicked.connect(() => {
				game.show_all();
			});

			food.feed_meal.connect(() => {
				taigochi.feed();
			});
			food.feed_treat.connect(() => {
				taigochi.treat();
			});

			go.toggled.connect(() => {
				if (go.active) {
					this.content_stack.set_visible_child_name("daycare");
					statemachine.change_to_state("daycare");
				} else {
					this.content_stack.set_visible_child_name("normal");
					statemachine.change_to_state("normal");
				}
			});
			go.bind_property("active", eat, "sensitive", BindingFlags.INVERT_BOOLEAN);
			go.bind_property("active", play, "sensitive", BindingFlags.INVERT_BOOLEAN);

			global_win = this;

			var menu = new Menu();
			hamberder.image = new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.BUTTON);
			hamberder.menu_model = menu;

			menu.append("New Taigochi", "app.new");
			menu.append("About Taigo", "app.about");

			var about = new SimpleAction("about", null);
			app.add_action(about);

			about.activate.connect(() => {
                // Configure the dialog:
                Gtk.AboutDialog dialog = new Gtk.AboutDialog ();
                dialog.set_destroy_with_parent (true);
				dialog.set_modal (true);
				dialog.set_transient_for(this);

                dialog.artists = {"Carson Black"};
                dialog.authors = {"Carson Black"};
                dialog.documenters = null; // Real inventors don't document.
                dialog.translator_credits = null; // We only need a scottish version.

                dialog.program_name = "Taigo";
				dialog.comments = "A virtual pet for your desktop";
				
				dialog.logo_icon_name = "com.github.appadeia.Taigo";
				dialog.license_type = Gtk.License.GPL_3_0;

                dialog.response.connect ((response_id) => {
                    if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
                        dialog.hide_on_delete ();
                    }
                });

                // Show the dialog:
                dialog.present ();
			});

			var nowy = new SimpleAction("new", null);
			app.add_action(nowy);

			Globals.scene = new GtkClutter.Embed();
			Globals.scene.show_all();
			Globals.scene.get_stage().set_size(360, 576);
			this.content_stack.add_named(Globals.scene, "normal");
			this.content_stack.set_visible_child_name("normal");

			nowy.activate.connect(() => {
				var dialog = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.YES_NO, "Are you sure you want to delete your Taigochi and make a new one? This cannot be undone.");
				dialog.response.connect((a) => {
					if (a == Gtk.ResponseType.YES) {
						this.init_taikochi(true);
						Globals.scene.hide();
						Timeout.add(1000, () => {
							Globals.scene.show();
							return false;
						}, Priority.DEFAULT);
					}
					dialog.hide_on_delete();
				});
				dialog.run();
			});

			this.init_taikochi();
		}
	}
}
