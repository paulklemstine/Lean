from typing import List, Tuple

Matrix = List[List[int]]
Vector = Tuple[int, ...]


def _mat_vec(M: Matrix, v: Vector, p: int) -> Vector:
    return tuple(sum(M[i][j] * v[j] for j in range(len(v))) % p
                 for i in range(len(M)))


def _rank(vectors: List[Vector], p: int) -> int:
    basis: List[List[int]] = []
    pivots: List[int] = []
    for v in vectors:
        w = [x % p for x in v]
        for b, pc in zip(basis, pivots):
            if w[pc]:
                f = w[pc] * pow(b[pc], p - 2, p) % p
                w = [(w[k] - f * b[k]) % p for k in range(len(w))]
        pc = next((k for k in range(len(w)) if w[k]), None)
        if pc is not None:
            basis.append(w)
            pivots.append(pc)
    return len(basis)


def orbit_spans(M: Matrix, v: Vector, p: int) -> bool:
    """Verify Theorem 5.2: orbit {v, Mv, ..., M^{n-1}v} spans F_p^n."""
    n = len(M)
    orb: List[Vector] = [v]
    cur = v
    for _ in range(n - 1):
        cur = _mat_vec(M, cur, p)
        orb.append(cur)
    return _rank(orb, p) == n
