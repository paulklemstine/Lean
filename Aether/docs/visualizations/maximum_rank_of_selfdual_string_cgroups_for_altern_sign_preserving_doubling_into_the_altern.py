from typing import List, Tuple

Perm = Tuple[int, ...]

def transposition(n: int, a: int, b: int) -> Perm:
    p = list(range(n)); p[a], p[b] = p[b], p[a]; return tuple(p)

def double(sigma: Perm) -> Perm:
    k = len(sigma); n = 2 * k + 1; out = list(range(n))
    for i in range(k):
        out[i] = sigma[i]
        out[k + i] = k + sigma[i]
    return tuple(out)

def sign(p: Perm) -> int:
    n = len(p)
    inv = sum(1 for i in range(n) for j in range(i + 1, n)
              if p[i] > p[j])
    return 1 if inv % 2 == 0 else -1

def doubled_simplex_generators(m: int) -> List[Perm]:
    k = 2 * m + 1
    gens = [double(transposition(k, i, i + 1)) for i in range(2 * m)]
    assert all(sign(g) == 1 for g in gens)
    return gens
