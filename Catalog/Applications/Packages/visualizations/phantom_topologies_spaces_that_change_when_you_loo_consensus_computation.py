def compute_consensus(observers):
    if not observers:
        return frozenset()
    result = set(observers[0])
    for t in observers[1:]:
        result &= set(t)
    return frozenset(result)