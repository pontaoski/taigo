namespace Taigo.StateManager {
    [CCode (has_target = false)]
    public delegate void TaigoFunc();

    public class State {
        public string name;
        public Idle[] idles;
    }
    public class Idle {
        public string name;
        public uint interval;
    }
    public class StateTransition {
        public string from;
        public string to;
    }
    public class StateMachine : Object {
        public List<State> states;
        public List<StateTransition> statetransitions;
        public string current_state = "";

        protected List<uint> active_idles;

        public signal void idle(string idle_name);
        public signal void transition(string from_name, string to_name);

        public void add_state(State state) {
            this.states.append(state);
            if (this.current_state == "") {
                this.current_state = state.name;
                foreach(var i in state.idles) {
                    active_idles.append(GLib.Timeout.add(i.interval, () => { this.idle(i.name); return true; }, GLib.Priority.DEFAULT));
                }
            }
        }
        public void add_state_transition(StateTransition transition) {
            this.statetransitions.append(transition);
        }
        public bool change_to_state(string name) {
            State? next_state = null;
            foreach(var state in this.states) {
                if (state.name == name) {
                    next_state = state;
                    break;
                }
            }
            if (next_state == null)
                return false;

            foreach(var i in this.active_idles) {
                Source.remove(i);
                this.active_idles.remove(i);
            }
            foreach(var i in next_state.idles) {
                active_idles.append(GLib.Timeout.add(i.interval, () => { this.idle(i.name); return true; }, GLib.Priority.DEFAULT));
            }
            foreach(var trans in this.statetransitions) {
                if (trans.from == current_state && trans.to == name) {
                    this.transition(current_state, name);
                    break;
                }
            }
            this.current_state = name;

            return true;
        }
    }
}