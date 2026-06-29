def are_closure_equivalent(v1, v2, domain):
    def partition(v):
        groups = {}
        for x in domain:
            groups.setdefault(v(x), set()).add(x)
        return set(frozenset(g) for g in groups.values())
    return partition(v1) == partition(v2)