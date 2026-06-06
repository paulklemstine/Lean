def all_closed_theories(S):
    closed = set()
    for r in range(len(S.axioms) + 1):
        for subset in itertools.combinations(S.axioms, r):
            t = frozenset(subset)
            cl = S.theory_closure(t)
            if t == cl:
                closed.add(t)
    return closed