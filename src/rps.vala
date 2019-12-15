using Taigo.Globals;

namespace Taigo { 
    [GtkTemplate (ui = "/com/github/appadeia/Taigo/rps.ui")]
	public class Rps : Gtk.Window {
        [GtkChild]
        Gtk.Image rps_img;
        [GtkChild]
        Gtk.Image taigochi_img;

        public bool pause;
        public enum Choices { ROCK, PAPER, SCISSOR }
        public uint randomizer;

        construct {
            taigochi_img.resource = taigochi.get_image_name("normal");
            int rand = Random.int_range(0, 3);
            switch (rand) {
                case 0:
                    rps_img.resource = "/com/github/appadeia/Taigo/images/animations/rps/paper.svg";
                    break;
                case 1:
                    rps_img.resource = "/com/github/appadeia/Taigo/images/animations/rps/scissor.svg";
                    break;
                case 2:
                    rps_img.resource = "/com/github/appadeia/Taigo/images/animations/rps/rock.svg";
                    break;
            }
            randomizer = GLib.Timeout.add(500, () => {
                if (pause)
                    return true;
                int randy = Random.int_range(0, 3);
                switch (randy) {
                    case 0:
                        rps_img.resource = "/com/github/appadeia/Taigo/images/animations/rps/paper.svg";
                        break;
                    case 1:
                        rps_img.resource = "/com/github/appadeia/Taigo/images/animations/rps/scissor.svg";
                        break;
                    case 2:
                        rps_img.resource = "/com/github/appadeia/Taigo/images/animations/rps/rock.svg";
                        break;
                }
                return true;
            }, GLib.Priority.DEFAULT);
        }
        [GtkCallback]
        private void rps_end() {
            statemachine.change_to_state("normal");
            Source.remove(randomizer);
        }
        private string counter(Choices choice) {
            switch(choice) {
                case Choices.ROCK: return "/com/github/appadeia/Taigo/images/animations/rps/paper.svg";
                case Choices.PAPER: return "/com/github/appadeia/Taigo/images/animations/rps/scissor.svg";
                case Choices.SCISSOR: return "/com/github/appadeia/Taigo/images/animations/rps/rock.svg";
                default: return "";
            }
        }
        private string strong(Choices choice) {
            switch(choice) {
                case Choices.ROCK: return "/com/github/appadeia/Taigo/images/animations/rps/scissor.svg";
                case Choices.PAPER: return "/com/github/appadeia/Taigo/images/animations/rps/rock.svg";
                case Choices.SCISSOR: return "/com/github/appadeia/Taigo/images/animations/rps/paper.svg";
                default: return "";
            }
        }
        private string same(Choices choice) {
            switch(choice) {
                case Choices.ROCK: return "/com/github/appadeia/Taigo/images/animations/rps/rock.svg";
                case Choices.PAPER: return "/com/github/appadeia/Taigo/images/animations/rps/paper.svg";
                case Choices.SCISSOR: return "/com/github/appadeia/Taigo/images/animations/rps/scissor.svg";
                default: return "";
            }
        }
        private void game(Choices choice) {
            if(pause)
                return;
            bool won = false;
            int randy = Random.int_range(0, 3);
            switch (randy) {
                case 0:
                    rps_img.resource = strong(choice);
                    break;
                case 1:
                    rps_img.resource = counter(choice);
                    won = true;
                    taigochi.game();
                    break;
                case 2:
                    rps_img.resource = same(choice);
                    break;
            }
            pause = true;
            GLib.Timeout.add(2000, () => {
                pause = false;
                return false;
            }, GLib.Priority.DEFAULT);
            if (won) {
                GLib.Timeout.add(500, () => {
                    taigochi_img.resource = taigochi.get_image_name("yay");
                    GLib.Timeout.add(500, () => {
                        taigochi_img.resource = taigochi.get_image_name("normal");
                        GLib.Timeout.add(500, () => {
                            taigochi_img.resource = taigochi.get_image_name("yay");
                            GLib.Timeout.add(500, () => {
                                taigochi_img.resource = taigochi.get_image_name("normal");
                                return false;
                            }, GLib.Priority.DEFAULT);
                            return false;
                        }, GLib.Priority.DEFAULT);
                        return false;
                    }, GLib.Priority.DEFAULT);
                    return false;
                }, GLib.Priority.DEFAULT);
            } else {
                GLib.Timeout.add(500, () => {
                    taigochi_img.resource = taigochi.get_image_name("aww");
                    GLib.Timeout.add(500, () => {
                        taigochi_img.resource = taigochi.get_image_name("normal");
                        GLib.Timeout.add(500, () => {
                            taigochi_img.resource = taigochi.get_image_name("aww");
                            GLib.Timeout.add(500, () => {
                                taigochi_img.resource = taigochi.get_image_name("normal");
                                return false;
                            }, GLib.Priority.DEFAULT);
                            return false;
                        }, GLib.Priority.DEFAULT);
                        return false;
                    }, GLib.Priority.DEFAULT);
                    return false;
                }, GLib.Priority.DEFAULT);
            }
        }
        [GtkCallback]
        private void scissors() { game(Choices.SCISSOR); }
        [GtkCallback]
        private void paper() { game(Choices.PAPER); }
        [GtkCallback]
        private void rock() { game(Choices.ROCK); }
	}
}