def find_geodesics(r1, r2, m):
    slots = [i for i,(a,b) in enumerate(zip(r1,r2)) if a!=b]
    paths = []
    for perm in itertools.permutations(slots):
        path, cur = [r1], list(r1)
        for s in perm:
            cur[s] = r2[s]; path.append(tuple(cur))
        paths.append(path)
    return paths