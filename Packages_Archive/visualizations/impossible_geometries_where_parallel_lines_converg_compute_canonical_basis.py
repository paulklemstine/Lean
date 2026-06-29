def compute_canonical_basis(cl, universe):
    basis = []
    for x in sorted(universe):
        for r in range(len(universe) + 1):
            for combo in combinations(sorted(universe), r):
                A = frozenset(combo)
                if x not in cl(set(A)):
                    continue
                is_minimal = all(
                    x not in cl(set(A - {elem}))
                    for elem in A
                )
                if is_minimal:
                    basis.append((x, A))
    return basis