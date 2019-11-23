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

namespace Taigo {
	[GtkTemplate (ui = "/me/appadeia/Taigo/food.ui")]
	public class Food : Gtk.Popover {
		public signal void feed_meal ();
		public signal void feed_treat ();

		[GtkCallback]
		private void meal() {
			print("food\n");
			feed_meal();
		}

		[GtkCallback]
		private void treat() {
			print("desert\n");
			feed_treat();
		}
	}

	[GtkTemplate (ui = "/me/appadeia/Taigo/status.ui")]
	public class Status : Gtk.Popover {
		[GtkChild]
		public Gtk.LevelBar food;

		[GtkChild]
		public Gtk.LevelBar happy;

		[GtkChild]
		public Gtk.Label gender;

		[GtkChild]
		public Gtk.Label tg_name;
	}

	[GtkTemplate (ui = "/me/appadeia/Taigo/window.ui")]
	public class Window : Gtk.ApplicationWindow {
		public Taigochi taigochi;

		[GtkChild]
		Gtk.Button heart;

		[GtkChild]
		Gtk.Button eat;

		[GtkChild]
		Gtk.Image taigochi_img;

		[GtkChild]
		Gtk.Image status_icon;

		protected Status status;
		protected Food food;

		//  [GtkCallback]
		//  private void tick() {
		//  	this.taigochi.tick();
		//  }
		
		protected void init_taikochi() {
			this.taigochi = new Taigochi.from_baby();
			this.taigochi_img.resource = this.taigochi.get_image_name("normal");
			this.taigochi.bind_property("hunger", status.food, "value", BindingFlags.DEFAULT);
			this.taigochi.bind_property("happy", status.happy, "value", BindingFlags.DEFAULT);

			this.status.tg_name.set_text(Utils.names[this.taigochi.type]);

			if (taigochi.gender == Genders.MALE)
				this.status.gender.set_text("Male");
			if (taigochi.gender == Genders.FEMALE)
				this.status.gender.set_text("Female");
			if (taigochi.gender == Genders.ENBY)
				this.status.gender.set_text("Enby");
			
			this.taigochi.hunger = 0.1;
			this.taigochi.happy = 0.1;

			Timeout.add_seconds(300, () => {
				this.taigochi.tick();
				return true;
			}, Priority.DEFAULT);
			Timeout.add_seconds(5, () => {
				var mood = this.taigochi.calc_mood();
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
				return true;
			}, Priority.DEFAULT);
		}

		public Window (Gtk.Application app) {
			Object (application: app);
            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/me/appadeia/Taigo/css/app.css");
            
            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
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

			food.feed_meal.connect(() => {
				this.taigochi.hunger ++;
			});
			food.feed_treat.connect(() => {
				this.taigochi.hunger ++;
				this.taigochi.happy = this.taigochi.happy + Random.double_range(0.5, 1.5);
			});

			this.init_taikochi();
		}
	}
}
