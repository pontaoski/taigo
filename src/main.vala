/* main.vala
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

int main (string[] args) {
	var env = Environment.get_variable("G_RESOURCE_OVERLAYS");
	if (env != null) {
		print("Sorry, this app does not allow you to overlay resources.\n");
		return 1;
	}
	env = Environment.get_variable("GTK_DEBUG");
	if (env.down() == "interactive") {
		print("Sorry, this app does not allow you to use the GTK inspector.\n");
		return 1;
	}
	Environment.set_variable("GTK_THEME", "Adwaita:dark", true);

	var app = new Gtk.Application ("me.appadeia.Taigo", ApplicationFlags.FLAGS_NONE);
	app.activate.connect (() => {
		var win = app.active_window;
		if (win == null) {
			win = new Taigo.Window (app);
		}

		bool ignore = false;
		Gtk.Settings.get_default ().notify.connect((s, p) => {
			print("notify\n");
			if (ignore) {
				GLib.Timeout.add(500, () => {
					ignore = false;
					return false;
				}, Priority.DEFAULT);
				return;
			}
			Gtk.Settings.get_default ().set ("gtk-application-prefer-dark-theme", true);
			Gtk.Settings.get_default ().set ("gtk-theme-name", "Adwaita");
			Gtk.Settings.get_default ().set ("gtk-icon-theme-name", "Adwaita");
			Gtk.Settings.get_default ().set ("gtk-font-name", "Cantarell 11");
			Gtk.Settings.get_default ().set ("gtk-decoration-layout", ":close");
			Gtk.Settings.get_default ().set ("gtk-dialogs-use-header", true);
			ignore = true;
		});

		Gtk.Settings.get_default ().set ("gtk-application-prefer-dark-theme", true);
		Gtk.Settings.get_default ().set ("gtk-theme-name", "Adwaita");
		Gtk.Settings.get_default ().set ("gtk-icon-theme-name", "Adwaita");
		Gtk.Settings.get_default ().set ("gtk-font-name", "Cantarell 11");
		Gtk.Settings.get_default ().set ("gtk-decoration-layout", ":close");
		Gtk.Settings.get_default ().set ("gtk-dialogs-use-header", true);
		win.present ();
	});

	return app.run (args);
}
