def compute_orbit(book, alpha):
    import itertools
    orbit = set()
    for sub in itertools.product(range(alpha), repeat=alpha):
        sigma = dict(enumerate(sub))
        orbit.add(tuple(sigma[c] for c in book))
    return orbit