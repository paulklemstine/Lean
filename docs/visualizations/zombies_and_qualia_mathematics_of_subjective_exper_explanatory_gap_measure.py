def measure_gap(system):
    classes = {}
    for s in system.states:
        c = system.equiv_classes[s]
        classes.setdefault(c, []).append(s)
    mixed = sum(1 for states in classes.values()
                if any(system.has_qualia(s) for s in states)
                and any(not system.has_qualia(s) for s in states))
    return mixed / len(classes)