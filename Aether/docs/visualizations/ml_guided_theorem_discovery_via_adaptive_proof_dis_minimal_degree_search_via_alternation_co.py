from typing import List, Sequence, Tuple

def minimal_degree_search(
    nodes: Sequence[float], labels: Sequence[int]
) -> Tuple[int, int]:
    """Return (alternation_count A, minimal degree that classifies all points).

    Sorts by feature value, counts sign changes A, then fits increasing-degree
    least-squares polynomials until every sign matches. The minimal classifying
    degree tracks A, exhibiting representational cost as a combinatorial invariant
    rather than an architectural one. Guaranteed fallback degree n-1.
    """
    order = sorted(range(len(nodes)), key=lambda k: nodes[k])
    sl = [labels[k] for k in order]
    A = sum(1 for k in range(len(sl) - 1) if sl[k] != sl[k + 1])
    n = len(nodes)
    for d in range(n):
        coeffs = _lstsq_poly(nodes, [float(y) for y in labels], d)
        if all((_peval(coeffs, t) > 0) == (y > 0) for t, y in zip(nodes, labels)):
            return A, d
    return A, n - 1


def _peval(coeffs: Sequence[float], t: float) -> float:
    return sum(c * t ** k for k, c in enumerate(coeffs))


def _lstsq_poly(nodes: Sequence[float], values: Sequence[float], degree: int) -> List[float]:
    m = degree + 1
    ata = [[0.0] * m for _ in range(m)]
    atb = [0.0] * m
    for t, v in zip(nodes, values):
        p = [t ** k for k in range(m)]
        for a in range(m):
            atb[a] += p[a] * v
            for b in range(m):
                ata[a][b] += p[a] * p[b]
    aug = [ata[i] + [atb[i]] for i in range(m)]
    for col in range(m):
        piv_row = max(range(col, m), key=lambda r: abs(aug[r][col]))
        aug[col], aug[piv_row] = aug[piv_row], aug[col]
        piv = aug[col][col]
        if abs(piv) < 1e-14:
            continue
        aug[col] = [v / piv for v in aug[col]]
        for r in range(m):
            if r != col and aug[r][col] != 0.0:
                f = aug[r][col]
                aug[r] = [a - f * b for a, b in zip(aug[r], aug[col])]
    return [aug[i][m] for i in range(m)]
