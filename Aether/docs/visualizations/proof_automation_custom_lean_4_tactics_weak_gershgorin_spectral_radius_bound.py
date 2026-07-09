import cmath
from typing import List, Sequence

def absolute_row_sums(M: Sequence[Sequence[float]]) -> List[float]:
    return [sum(abs(e) for e in row) for row in M]

def weak_gershgorin_bound(M: Sequence[Sequence[float]]) -> float:
    """Certified bound B = max_i sum_j |M_ij|; every eigenvalue |lambda| <= B."""
    return max(absolute_row_sums(M))

def eigenvalues_2x2(M: Sequence[Sequence[float]]) -> List[complex]:
    (a, b), (c, d) = M[0], M[1]
    tr, det = a + d, a * d - b * c
    disc = cmath.sqrt(tr * tr - 4 * det)
    return [(tr + disc) / 2, (tr - disc) / 2]

def main() -> None:
    for M in [[[2.0,-1.0],[0.5,3.0]], [[5.0,-2.0],[-3.0,1.0]]]:
        B = weak_gershgorin_bound(M)
        mags = [abs(z) for z in eigenvalues_2x2(M)]
        print(f"M={M} B={B} |eig|={[round(m,4) for m in mags]} "
              f"certified={all(m <= B + 1e-9 for m in mags)}")

if __name__ == "__main__":
    main()
