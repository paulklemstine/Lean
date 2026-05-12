def membership_test(cl, X, x):
    """x in cl(X) iff capacity unchanged by adding x."""
    return len(cl(X)) == len(cl(X | frozenset([x])))