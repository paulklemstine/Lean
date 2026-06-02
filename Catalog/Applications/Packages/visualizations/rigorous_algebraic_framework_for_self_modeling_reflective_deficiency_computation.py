def compute_reflective_deficiency(n, encode):
    from itertools import product
    represented = {encode(x) for x in range(n)}
    all_endos = set(product(range(n), repeat=n))
    return all_endos - represented