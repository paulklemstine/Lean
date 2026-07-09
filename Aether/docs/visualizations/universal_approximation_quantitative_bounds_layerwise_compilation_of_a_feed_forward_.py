from itertools import product
from typing import Callable, List, Sequence, Tuple

Affine = Tuple[Tuple[float, ...], float]
TropRational = Tuple[List[Affine], List[Affine]]  # (G, H) meaning G - H


def poly_add(g: Sequence[Affine], h: Sequence[Affine]) -> List[Affine]:
    return [(tuple(ai + ci for ai, ci in zip(a, c)), b + d)
            for (a, b), (c, d) in product(g, h)]


def poly_min(g: Sequence[Affine], h: Sequence[Affine]) -> List[Affine]:
    return list(g) + list(h)


def scale(f: TropRational, c: float) -> TropRational:
    """Scalar multiple c * (G - H), handling the sign of c."""
    G, H = f
    sg = [(tuple(c * ai for ai in a), c * b) for a, b in G]
    sh = [(tuple(c * ai for ai in a), c * b) for a, b in H]
    return (sg, sh) if c >= 0 else (sh, sg)


def add(f1: TropRational, f2: TropRational) -> TropRational:
    (g1, h1), (g2, h2) = f1, f2
    return poly_add(g1, g2), poly_add(h1, h2)


def relu(f: TropRational, n: int) -> TropRational:
    """ReLU(f) = max(0, f) as a tropical rational function."""
    zero: List[Affine] = [(tuple(0.0 for _ in range(n)), 0.0)]
    A = poly_add(zero, f[1])      # g_zero + h_f
    B = poly_add(f[0], zero)      # g_f + h_zero
    G = poly_add(A, B)
    H = poly_add(poly_min(A, B), poly_add(zero, f[1]))
    return G, H


def relu_network(x_dim: int,
                 weights: Sequence[Sequence[Sequence[float]]],
                 biases: Sequence[Sequence[float]]) -> List[TropRational]:
    """Compile a feed-forward ReLU network into tropical rational functions.

    weights[l] is a matrix (rows = neurons, cols = inputs) for layer l;
    ReLU is applied after every layer except the last (readout)."""
    # Inputs as affine tropical rationals x_j = e_j . x  (single-term G, zero H).
    e = lambda j: tuple(1.0 if k == j else 0.0 for k in range(x_dim))
    zero1: List[Affine] = [(tuple(0.0 for _ in range(x_dim)), 0.0)]
    cur: List[TropRational] = [([(e(j), 0.0)], list(zero1)) for j in range(x_dim)]
    L = len(weights)
    for l in range(L):
        nxt: List[TropRational] = []
        for row, b in zip(weights[l], biases[l]):
            acc: TropRational = ([(tuple(0.0 for _ in range(x_dim)), b)], list(zero1))
            for w, f in zip(row, cur):
                acc = add(acc, scale(f, w))
            if l < L - 1:
                acc = relu(acc, x_dim)
            nxt.append(acc)
        cur = nxt
    return cur
