def build_minimal_automaton(states, T, refutes, equiv_classes):
    state_to_class = {}
    class_list = list(equiv_classes.values())
    for idx, cls in enumerate(class_list):
        for s in cls:
            state_to_class[s] = idx
    class_trans = {}
    for idx, cls in enumerate(class_list):
        rep = cls[0]
        class_trans[idx] = state_to_class[T[rep]]
    class_refutes = {}
    for idx, cls in enumerate(class_list):
        class_refutes[idx] = refutes[cls[0]]
    return class_list, class_trans, class_refutes, state_to_class