def axiom_closure(axioms, all_predicates, universe):
    m = frozenset(x for x in universe if all(ax(x) for ax in axioms))
    return [p for p in all_predicates if all(p(x) for x in m)]