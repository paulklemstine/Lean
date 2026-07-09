from itertools import product
from typing import List, Sequence, Tuple

Affine = Tuple[Tuple[float, ...], float]


def poly_add(g: Sequence[Affine], h: Sequence[Affine]) -> List[Affine]:
    """Tropical product (pointwise sum): min_S(.) + min_T(.) = min_{SxT}(.)."""
    out: List[Affine] = []
    for (a, b), (c, d) in product(g, h):
        out.append((tuple(ai + ci for ai, ci in zip(a, c)), b + d))
    return out


def poly_min(g: Sequence[Affine], h: Sequence[Affine]) -> List[Affine]:
    """Tropical sum (pointwise min): union of the two affine families."""
    return list(g) + list(h)


def trop_max(f1: Tuple[List[Affine], List[Affine]],
             f2: Tuple[List[Affine], List[Affine]]
             ) -> Tuple[List[Affine], List[Affine]]:
    """Given f1 = g1 - h1 and f2 = g2 - h2, return (G, H) with
    max(f1, f2) = G - H, using max(p,q) = (p+q) - min(p,q):
        A = g1 + h2,  B = g2 + h1,
        G = A + B,    H = min(A, B) + (h1 + h2)."""
    g1, h1 = f1
    g2, h2 = f2
    A = poly_add(g1, h2)
    B = poly_add(g2, h1)
    G = poly_add(A, B)
    H = poly_add(poly_min(A, B), poly_add(h1, h2))
    return G, H
