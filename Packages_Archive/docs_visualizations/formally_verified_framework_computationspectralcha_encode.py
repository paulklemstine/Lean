def encode(elements, phis):
    """Algorithm A (Encode): fingerprint each element by the vector of test answers.
    Returns {x: (phi_0(x), ..., phi_{n-1}(x))}. Separation reduces to injectivity
    of this table on large closed sets (Theorem 6.1)."""
    return {x: tuple(p(x) for p in phis) for x in elements}
