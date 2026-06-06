def enumerate_shell(A, L, k, ref):
    from itertools import combinations, product
    for positions in combinations(range(L), k):
        for offsets in product(range(1, A), repeat=k):
            vol = list(ref)
            for pos, offset in zip(positions, offsets):
                vol[pos] = (ref[pos] + offset) % A
            yield tuple(vol)