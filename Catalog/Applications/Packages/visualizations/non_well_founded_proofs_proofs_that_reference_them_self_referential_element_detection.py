def detect_self_referential(derive, universe):
    result = []
    for a in universe:
        safe = all(a in s or a not in derive(s)
                   for s in powerset(universe))
        selfref = safe and a in derive(frozenset([a]))
        if selfref:
            result.append(a)
    return result