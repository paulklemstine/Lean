def boundary(s):
    """Boundary of an oriented simplex s, as {face: coefficient}."""
    chain = {}
    for x in s:
        face = tuple(y for y in s if y != x)
        chain[face] = chain.get(face, 0) + (-1) ** sum(1 for y in s if y < x)
    return {f: c for f, c in chain.items() if c != 0}
