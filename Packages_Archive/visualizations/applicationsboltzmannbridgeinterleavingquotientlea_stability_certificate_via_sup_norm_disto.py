from typing import Dict, Tuple

DistMatrix = Dict[Tuple[int, int], float]


def stability_certificate(d1: DistMatrix, d2: DistMatrix, n: int) -> float:
    """Return the sup-norm distortion eps = max_{x,y} |d1(x,y) - d2(x,y)|.

    By the stability theorem the Vietoris-Rips filtrations of d1 and d2 are
    eps-interleaved, certifying eInterleavingDist <= ofReal(eps). The value eps is
    a constructive upper bound on (in fact, often equal to) the interleaving
    distance, and bounds the distance between the corresponding classes in the
    interleaving metric quotient. Cost O(n^2).
    """
    return max(abs(d1[(i, j)] - d2[(i, j)]) for i in range(n) for j in range(n))
