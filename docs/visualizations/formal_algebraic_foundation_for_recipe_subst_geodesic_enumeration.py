def enumerate_geodesics(u, v):
    differing = [i for i in range(len(u)) if u[i] != v[i]]
    geodesics = []
    for perm in itertools.permutations(differing):
        path = [list(u)]
        current = list(u)
        for pos in perm:
            current = current[:]
            current[pos] = v[pos]
            path.append(current)
        geodesics.append([tuple(w) for w in path])
    return geodesics