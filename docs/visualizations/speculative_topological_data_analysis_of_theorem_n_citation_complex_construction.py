def build_complex(network):
    faces = set()
    for t in network.theorems:
        cited = list(network.cites.get(t, set()))
        for k in range(1, len(cited) + 1):
            for combo in combinations(cited, k):
                faces.add(frozenset(combo))
    return faces