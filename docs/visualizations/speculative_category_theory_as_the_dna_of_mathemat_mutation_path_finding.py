def find_mutation_path(t1, t2):
    diff = t1.axiom_indices ^ t2.axiom_indices
    path, current = [t1], set(t1.axiom_indices)
    for ax in sorted(diff):
        if ax in t2.axiom_indices: current.add(ax)
        else: current.discard(ax)
        path.append(TheoryGenome(frozenset(current), t1.universe, t1.predicate_list))
    return path