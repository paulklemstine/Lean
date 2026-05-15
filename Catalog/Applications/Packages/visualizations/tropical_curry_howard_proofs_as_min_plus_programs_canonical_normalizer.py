def normalize(p):
    """Canonical normalizer: evaluate cost, wrap as atom."""
    return Atom(cost(p))