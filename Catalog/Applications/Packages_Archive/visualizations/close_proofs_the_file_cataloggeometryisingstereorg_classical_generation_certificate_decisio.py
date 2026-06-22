from itertools import product
from typing import List, Tuple

Mat = Tuple[int, int, int, int]   # [[a,b],[c,d]]
Vec = Tuple[int, int]


def trace(x: Mat, p: int) -> int:
    a, _, _, d = x
    return (a + d) % p


def det(x: Mat, p: int) -> int:
    a, b, c, d = x
    return (a * d - b * c) % p


def charpoly_irreducible_2x2(x: Mat, p: int) -> bool:
    """charpoly t^2 - tr t + det is irreducible over F_p iff its
    discriminant tr^2 - 4 det is a nonzero quadratic non-residue."""
    disc = (trace(x, p) ** 2 - 4 * det(x, p)) % p
    if disc == 0:
        return False
    return pow(disc, (p - 1) // 2, p) != 1


def mat_vec(x: Mat, v: Vec, p: int) -> Vec:
    a, b, c, d = x
    u, w = v
    return ((a * u + b * w) % p, (c * u + d * w) % p)


def eigenvectors(x: Mat, p: int) -> List[Vec]:
    out: List[Vec] = []
    for v in product(range(p), repeat=2):
        if v == (0, 0):
            continue
        xv = mat_vec(x, v, p)
        scalars, ok = set(), True
        for vi, xvi in zip(v, xv):
            if vi == 0:
                if xvi != 0:
                    ok = False
                    break
            else:
                scalars.add((xvi * pow(vi, -1, p)) % p)
        if ok and len(scalars) <= 1:
            out.append(v)  # type: ignore[arg-type]
    return out


def gl2_certificate(s: Mat, t: Mat, p: int) -> bool:
    """Definition 5.1 / Theorem 6: both invertible, charpoly(s) irreducible,
    and no common eigenvector -> <s,t> acts irreducibly on F_p^2."""
    if det(s, p) == 0 or det(t, p) == 0:
        return False
    if not charpoly_irreducible_2x2(s, p):
        return False
    common = set(eigenvectors(s, p)) & set(eigenvectors(t, p))
    return len(common) == 0
