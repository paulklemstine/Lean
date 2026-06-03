def verify_reduction(clauses, assignment):
    for c in clauses:
        sat = any(lit.eval(assignment) for lit in c)
        tab = any(lit.to_edge(assignment) == TAB for lit in c)
        assert sat == tab
    return all(c.is_satisfied(assignment) for c in clauses)