"""
demo.py -- Numerical demonstrations of the spectral (Gram-matrix) Fisher bound.

This script illustrates, with concrete numbers, the theorems formalized in the
HegedusSpectral package:

  * incidence_inner          : <v_A, v_B> = |A cap B|
  * constPattern_posDef      : (k - lam) I + lam J is positive definite for 0 <= lam < k
  * indexed_fisher_card_le   : a k-uniform family with constant pairwise
                               intersection lam < k has at most n members
  * singletonFamily_fisher   : the n singletons attain the bound m = n (k=1, lam=0)
  * degenerate_gram_not_posDef : at lam = k the Gram matrix kJ loses positive definiteness

Everything is self-contained: only the Python standard library plus (optionally)
a tiny hand-rolled eigenvalue check are used, so no third-party packages are
required.
"""

from __future__ import annotations

from itertools import combinations
from typing import List, Sequence, Set, Tuple


# ---------------------------------------------------------------------------
# 1. The combinatorics <-> algebra dictionary
# ---------------------------------------------------------------------------

def incidence_vector(A: Set[int], n: int) -> List[float]:
    """Return the 0/1 incidence vector of subset A of {0,...,n-1} in R^n."""
    return [1.0 if t in A else 0.0 for t in range(n)]


def dot(u: Sequence[float], v: Sequence[float]) -> float:
    """Standard Euclidean inner product."""
    return sum(ui * vi for ui, vi in zip(u, v))


def verify_incidence_inner(A: Set[int], B: Set[int], n: int) -> Tuple[float, int]:
    """Check that <v_A, v_B> equals |A cap B|. Returns (inner_product, |A cap B|)."""
    vA = incidence_vector(A, n)
    vB = incidence_vector(B, n)
    return dot(vA, vB), len(A & B)


# ---------------------------------------------------------------------------
# 2. The Gram matrix and its spectrum
# ---------------------------------------------------------------------------

Matrix = List[List[float]]


def gram_matrix(vectors: Sequence[Sequence[float]]) -> Matrix:
    """Gram matrix G_ij = <v_i, v_j>."""
    return [[dot(u, v) for v in vectors] for u in vectors]


def constant_pattern_matrix(k: float, lam: float, m: int) -> Matrix:
    """The matrix (k - lam) I + lam J of size m x m."""
    return [[(k if i == j else lam) for j in range(m)] for i in range(m)]


def symmetric_eigenvalues(M: Matrix, iters: int = 2000) -> List[float]:
    """
    Compute eigenvalues of a small symmetric matrix via the cyclic Jacobi
    rotation method (no external dependencies). Suitable for the small matrices
    arising in these demos.
    """
    import math

    n = len(M)
    A = [row[:] for row in M]  # work on a copy
    for _ in range(iters):
        # find largest off-diagonal magnitude
        p, q, off = 0, 1, 0.0
        for i in range(n):
            for j in range(i + 1, n):
                if abs(A[i][j]) > off:
                    off, p, q = abs(A[i][j]), i, j
        if off < 1e-12:
            break
        app, aqq, apq = A[p][p], A[q][q], A[p][q]
        theta = 0.5 * math.atan2(2 * apq, aqq - app) if (aqq - app) != 0 else math.pi / 4
        c, s = math.cos(theta), math.sin(theta)
        for i in range(n):
            aip, aiq = A[i][p], A[i][q]
            A[i][p] = c * aip - s * aiq
            A[i][q] = s * aip + c * aiq
        for i in range(n):
            api, aqi = A[p][i], A[q][i]
            A[p][i] = c * api - s * aqi
            A[q][i] = s * api + c * aqi
    return sorted(A[i][i] for i in range(n))


def is_positive_definite(M: Matrix) -> bool:
    """A symmetric matrix is positive definite iff all eigenvalues are > 0."""
    return all(ev > 1e-9 for ev in symmetric_eigenvalues(M))


# ---------------------------------------------------------------------------
# 3. The Fisher bound, verified on explicit families
# ---------------------------------------------------------------------------

def check_fisher_hypotheses(
    family: Sequence[Set[int]], n: int, k: int, lam: int
) -> bool:
    """Check k-uniformity, constant pairwise intersection lam, and lam < k."""
    if not (0 <= lam < k):
        return False
    if any(len(A) != k for A in family):
        return False
    for A, B in combinations(family, 2):
        if len(A & B) != lam:
            return False
    return True


def fisher_bound_holds(family: Sequence[Set[int]], n: int, k: int, lam: int) -> bool:
    """Verify the conclusion m <= n given the hypotheses hold."""
    assert check_fisher_hypotheses(family, n, k, lam), "hypotheses not satisfied"
    return len(family) <= n


# ---------------------------------------------------------------------------
# 4. Concrete instances
# ---------------------------------------------------------------------------

def singleton_family(n: int) -> List[Set[int]]:
    """The n singletons {0}, ..., {n-1}: k=1, lam=0, attains m = n."""
    return [{i} for i in range(n)]


def fano_lines() -> List[Set[int]]:
    """
    The 7 lines of the Fano plane on points {0,...,6}: a 3-uniform family with
    every pair of lines meeting in exactly 1 point (k=3, lam=1, n=7, m=7).
    A celebrated tight instance of the Fisher bound.
    """
    return [
        {0, 1, 2}, {0, 3, 4}, {0, 5, 6},
        {1, 3, 5}, {1, 4, 6}, {2, 3, 6}, {2, 4, 5},
    ]


def degenerate_family(n: int, k: int) -> List[Set[int]]:
    """All sets equal: lam = k, the degenerate case where the bound fails to follow."""
    base = set(range(k))
    return [set(base) for _ in range(2)]  # two 'copies' (as a set, distinctness fails)


# ---------------------------------------------------------------------------
# 5. Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 68)
    print("SPECTRAL FISHER BOUND -- NUMERICAL DEMONSTRATIONS")
    print("=" * 68)

    # 1. Dictionary lemma
    print("\n[1] Dictionary:  <v_A, v_B> = |A cap B|")
    n = 6
    A, B = {0, 1, 3}, {1, 3, 4}
    ip, inter = verify_incidence_inner(A, B, n)
    print(f"    A = {A}, B = {B}, n = {n}")
    print(f"    <v_A, v_B> = {ip},   |A cap B| = {inter}   -> match: {ip == inter}")

    # 2. Constant-pattern positive definiteness
    print("\n[2] constPattern_posDef:  (k - lam) I + lam J positive definite for lam < k")
    for k, lam, m in [(3, 1, 7), (1, 0, 5), (5, 4, 4)]:
        M = constant_pattern_matrix(float(k), float(lam), m)
        eigs = symmetric_eigenvalues(M)
        pd = is_positive_definite(M)
        print(f"    k={k}, lam={lam}, m={m}: eigenvalues ~ "
              f"{[round(e, 3) for e in eigs]}  -> posdef: {pd}")
        print(f"        predicted spectrum: {k - lam} (x{m-1}), {k + (m-1)*lam} (x1)")

    # 3. Singleton family (sharp, k=1, lam=0)
    print("\n[3] singletonFamily_fisher:  the n singletons attain m = n")
    n = 5
    fam = singleton_family(n)
    ok = check_fisher_hypotheses(fam, n, k=1, lam=0)
    G = gram_matrix([incidence_vector(S, n) for S in fam])
    print(f"    n = {n}, family = {[sorted(s) for s in fam]}")
    print(f"    hypotheses hold: {ok},  m = {len(fam)} <= n = {n}: {len(fam) <= n}")
    print(f"    Gram matrix = identity? {G == [[1.0 if i==j else 0.0 for j in range(n)] for i in range(n)]}")

    # 4. Fano plane (sharp, k=3, lam=1, n=7, m=7)
    print("\n[4] indexed_fisher_card_le on the Fano plane (k=3, lam=1, n=7)")
    n = 7
    fam = fano_lines()
    ok = check_fisher_hypotheses(fam, n, k=3, lam=1)
    bound = fisher_bound_holds(fam, n, 3, 1) if ok else None
    vecs = [incidence_vector(S, n) for S in fam]
    eigs = symmetric_eigenvalues(gram_matrix(vecs))
    print(f"    hypotheses hold: {ok},  m = {len(fam)},  bound m <= n: {bound}")
    print(f"    Gram eigenvalues ~ {[round(e, 3) for e in eigs]}  (all > 0 => independent)")

    # 5. Degeneracy at lam = k
    print("\n[5] degenerate_gram_not_posDef:  lam = k gives kJ, not positive definite")
    k, m = 3, 4
    M = constant_pattern_matrix(float(k), float(k), m)  # (k-lam)=0, lam=k -> kJ
    eigs = symmetric_eigenvalues(M)
    print(f"    k = lam = {k}, m = {m}: matrix = {k}*J")
    print(f"    eigenvalues ~ {[round(e, 3) for e in eigs]}  -> posdef: {is_positive_definite(M)}")
    print("    (a zero eigenvalue: positive semidefinite but NOT positive definite)")

    print("\n" + "=" * 68)
    print("All demonstrations consistent with the formalized theorems.")
    print("=" * 68)


if __name__ == "__main__":
    main()


"""
visualization.py -- Visualize the spectrum of the constant-pattern Gram matrix
(k - lam) I + lam J and the phase transition at lam = k.

Generates two panels:
  (left)  the two-point spectrum {k - lam, k + (m-1) lam} as lam sweeps 0..k,
          showing the smallest eigenvalue k - lam crossing zero exactly at lam = k;
  (right) a heatmap of a sample Gram matrix for a uniform family.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def constant_pattern_spectrum(k: float, lam: float, m: int) -> tuple[float, float]:
    """Eigenvalues of (k - lam) I + lam J of size m: (k - lam, k + (m-1) lam)."""
    return (k - lam, k + (m - 1) * lam)


def main() -> None:
    k = 3.0
    m = 7
    lams = np.linspace(0.0, k, 200)
    small = np.array([constant_pattern_spectrum(k, l, m)[0] for l in lams])
    large = np.array([constant_pattern_spectrum(k, l, m)[1] for l in lams])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(lams, small, label=r"$\lambda_{\min} = k - \lambda$", lw=2, color="crimson")
    ax1.plot(lams, large, label=r"$\lambda_{\max} = k + (m-1)\lambda$", lw=2, color="navy")
    ax1.axhline(0, color="black", lw=0.8, ls="--")
    ax1.axvline(k, color="gray", lw=0.8, ls=":")
    ax1.fill_between(lams, 0, small, where=(small > 0), alpha=0.15, color="green",
                     label="positive definite region")
    ax1.set_xlabel(r"intersection size $\lambda$")
    ax1.set_ylabel("eigenvalue")
    ax1.set_title(f"Spectrum of $(k-\\lambda)I + \\lambda J$  (k={k:.0f}, m={m})")
    ax1.legend()
    ax1.annotate("degeneracy at $\\lambda=k$", xy=(k, 0), xytext=(k - 1.4, 4),
                 arrowprops=dict(arrowstyle="->"))

    # Fano plane Gram matrix (k=3, lam=1, m=7)
    fano = [
        {0, 1, 2}, {0, 3, 4}, {0, 5, 6},
        {1, 3, 5}, {1, 4, 6}, {2, 3, 6}, {2, 4, 5},
    ]
    n = 7
    V = np.array([[1.0 if t in S else 0.0 for t in range(n)] for S in fano])
    G = V @ V.T
    im = ax2.imshow(G, cmap="viridis")
    ax2.set_title("Gram matrix of the Fano plane (k=3, λ=1)")
    ax2.set_xlabel("line index")
    ax2.set_ylabel("line index")
    for i in range(7):
        for j in range(7):
            ax2.text(j, i, int(G[i, j]), ha="center", va="center",
                     color="white" if G[i, j] < 2 else "black")
    fig.colorbar(im, ax=ax2, fraction=0.046)

    plt.tight_layout()
    plt.savefig("hegedus_spectrum.png", dpi=150)
    print("Saved hegedus_spectrum.png")


if __name__ == "__main__":
    main()
