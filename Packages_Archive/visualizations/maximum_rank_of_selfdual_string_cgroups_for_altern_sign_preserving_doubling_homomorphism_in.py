from typing import List, Tuple

Perm = Tuple[int, ...]

def transposition(n: int, a: int, b: int) -> Perm:
    p = list(range(n))
    p[a], p[b] = p[b], p[a]
    return tuple(p)

def sign(p: Perm) -> int:
    """+1 if even, -1 if odd."""
    n = len(p)
    seen = [False] * n
    s = 1
    for start in range(n):
        if seen[start]:
            continue
        length, j = 0, start
        while not seen[j]:
            seen[j] = True
            j = p[j]
            length += 1
        if length % 2 == 0:
            s = -s
    return s

def simplex(r: int) -> List[Perm]:
    """Rank-r simplex: adjacent transpositions (i, i+1) on {0,...,r}."""
    n = r + 1
    return [transposition(n, i, i + 1) for i in range(r)]

def double(sigma: Perm, m: int) -> Perm:
    """sigma |-> sigma (+) sigma (+) 1 on Fin(4m+3)."""
    block = 2 * m + 1
    n = 4 * m + 3
    p = list(range(n))
    for i in range(block):
        p[i] = sigma[i]
        p[block + i] = block + sigma[i]
    return tuple(p)

def doubled_simplex(m: int) -> List[Perm]:
    """Self-dual rank-2m representation of A_{4m+3}."""
    gens = [double(g, m) for g in simplex(2 * m)]
    assert all(sign(g) == 1 for g in gens)  # lands in alternating group
    return gens
