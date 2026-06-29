from typing import List, Tuple
Matrix = Tuple[Tuple[int, ...], ...]

def minpoly_degree(a: Matrix, p: int) -> int:
    n = len(a)
    powers: List[Matrix] = [tuple(tuple(1 if i == j else 0 for j in range(n))
                                  for i in range(n))]
    flat = [list(x for row in powers[0] for x in row)]
    while True:
        nxt = mat_mul(a, powers[-1], p)
        powers.append(nxt)
        candidate = flat + [list(x for row in nxt for x in row)]
        if _rank([r[:] for r in candidate], p) < len(candidate):
            return len(powers) - 1
        flat = candidate

def is_regular_toral(a: Matrix, p: int) -> bool:
    return minpoly_degree(a, p) == len(a)
# mat_mul as above; _rank = Gaussian elimination rank over GF(p) (see demo.py)
