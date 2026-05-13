import itertools
def reconstruct_basis(alphabet, cl):
    basis = []
    for r in range(len(alphabet) + 1):
        for prem_tuple in itertools.combinations(sorted(alphabet), r):
            prem = frozenset(prem_tuple)
            closure = cl(prem)
            for x in sorted(closure - prem):
                basis.append((prem, x))
    return basis