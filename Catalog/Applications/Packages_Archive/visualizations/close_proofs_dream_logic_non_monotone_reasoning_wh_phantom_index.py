def phantom_index(rel, universe):
    """phantom_index = |universe| - |universe / extensional-equivalence|.
    Equals 0 iff extensionality holds (Phantom Quotient Theorem)."""
    def ext_equiv(a, b):
        ma, mb = rel.get(a, set()), rel.get(b, set())
        return all((x in ma) == (x in mb) for x in universe)
    classes = []
    for a in universe:
        if not any(ext_equiv(a, r) for r in classes):
            classes.append(a)
    return len(universe) - len(classes)
