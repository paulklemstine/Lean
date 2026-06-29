def canonical_basis(cl, universe):
    basis = []
    for x in universe:
        for support in find_minimal_supports(cl, x, universe):
            basis.append((x, support))
    return basis