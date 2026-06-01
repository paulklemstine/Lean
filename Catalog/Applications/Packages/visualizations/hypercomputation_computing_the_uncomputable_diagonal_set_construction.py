def diagonal_set(family, universe):
    return {n for n in range(universe) if n not in family.get(n, set())}