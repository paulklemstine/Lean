def canonical_support(x):
    """Compute canonical minimal support."""
    return frozenset(i for i in range(len(x)) if x[i] != 0)