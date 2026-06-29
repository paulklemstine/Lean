"""
demo.py — Numerical demonstrations for:

    "Skew Conference Matrices and the Order-Preserving Core of the Paley I
     Construction of Hadamard Matrices"

Self-contained pure-Python (no third-party dependencies). All matrices are
lists of lists of ints. We demonstrate the formally verified results:

  * IsSkewConference  : zero diagonal, +-1 off-diagonal, C^T = -C, C C^T = (n-1)I
  * skewConference_mulSelf                : C * C       = (1 - n) I     (Thm 4.1)
  * skewConference_add_one_isSkewHadamard : I + C is skew-Hadamard      (Thm 5.1)
  * skewConference_isHadamard             : (I+C)(I+C)^T = n I          (Cor 5.2)
  * skewConference_hadamardOrder          : existence bridge            (Thm 5.3)
  * isSkewHadamard_sub_one_skewConference : H - I is skew conference    (Thm 6.1)

Skew conference matrices of order q + 1 are produced by bordering the
Jacobsthal (quadratic-residue) matrix over GF(q) for primes q = 3 (mod 4).

Run:  python3 demo.py
"""

from __future__ import annotations

from typing import List, Set

Matrix = List[List[int]]


# --------------------------------------------------------------------------- #
# Basic integer matrix algebra (inlined, no numpy)                            #
# --------------------------------------------------------------------------- #
def identity(n: int) -> Matrix:
    """The n x n identity matrix."""
    return [[1 if i == j else 0 for j in range(n)] for i in range(n)]


def transpose(M: Matrix) -> Matrix:
    """Matrix transpose M^T."""
    n, m = len(M), len(M[0])
    return [[M[i][j] for i in range(n)] for j in range(m)]


def matmul(A: Matrix, B: Matrix) -> Matrix:
    """Matrix product A * B."""
    n, k, m = len(A), len(B), len(B[0])
    return [[sum(A[i][t] * B[t][j] for t in range(k)) for j in range(m)]
            for i in range(n)]


def matadd(A: Matrix, B: Matrix) -> Matrix:
    """Entrywise sum A + B."""
    return [[A[i][j] + B[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def matsub(A: Matrix, B: Matrix) -> Matrix:
    """Entrywise difference A - B."""
    return [[A[i][j] - B[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def negate(M: Matrix) -> Matrix:
    """Entrywise negation -M."""
    return [[-M[i][j] for j in range(len(M[0]))] for i in range(len(M))]


def scalar(c: int, n: int) -> Matrix:
    """The scalar multiple c * I of the n x n identity."""
    return [[c if i == j else 0 for j in range(n)] for i in range(n)]


def equal(A: Matrix, B: Matrix) -> bool:
    """Exact entrywise equality."""
    return A == B


def show(M: Matrix, name: str) -> None:
    """Pretty-print a small integer matrix."""
    print(f"{name} =")
    for row in M:
        print("   [" + " ".join(f"{x:>2}" for x in row) + "]")


# --------------------------------------------------------------------------- #
# Predicates matching the Lean definitions                                     #
# --------------------------------------------------------------------------- #
def is_skew_conference(C: Matrix) -> bool:
    """Check IsSkewConference: zero diagonal, +-1 off-diagonal, C^T=-C, C C^T=(n-1)I."""
    n = len(C)
    if any(C[i][i] != 0 for i in range(n)):
        return False
    if any(C[i][j] not in (1, -1) for i in range(n) for j in range(n) if i != j):
        return False
    if not equal(transpose(C), negate(C)):
        return False
    return equal(matmul(C, transpose(C)), scalar(n - 1, n))


def is_hadamard(H: Matrix) -> bool:
    """Check IsHadamardP: +-1 entries and H H^T = n I."""
    n = len(H)
    if any(H[i][j] not in (1, -1) for i in range(n) for j in range(n)):
        return False
    return equal(matmul(H, transpose(H)), scalar(n, n))


def is_skew_hadamard(H: Matrix) -> bool:
    """Check IsSkewHadamardP: Hadamard and H + H^T = 2 I."""
    n = len(H)
    return is_hadamard(H) and equal(matadd(H, transpose(H)), scalar(2, n))


# --------------------------------------------------------------------------- #
# Construction: bordered Jacobsthal skew conference matrix of order q + 1      #
# --------------------------------------------------------------------------- #
def quadratic_residues(q: int) -> Set[int]:
    """The set of nonzero quadratic residues modulo a prime q."""
    return {(x * x) % q for x in range(1, q)}


def chi(x: int, q: int, qr: Set[int]) -> int:
    """Quadratic-residue character: 0 at 0, +1 on residues, -1 on non-residues."""
    r = x % q
    if r == 0:
        return 0
    return 1 if r in qr else -1


def jacobsthal(q: int) -> Matrix:
    """Jacobsthal matrix Q over GF(q): Q[a][b] = chi(a - b).  Skew when q = 3 (mod 4)."""
    qr = quadratic_residues(q)
    return [[chi(a - b, q, qr) for b in range(q)] for a in range(q)]


def bordered_conference(q: int) -> Matrix:
    """Skew conference matrix of order q + 1: border the Jacobsthal matrix Q.

    Layout (index 0 is the border):
        C[0][0] = 0,  C[0][j] = +1,  C[i][0] = -1,  C[i][j] = Q[i-1][j-1].
    Skew (C^T = -C) and conference (C C^T = q I) hold for primes q = 3 (mod 4).
    """
    Q = jacobsthal(q)
    n = q + 1
    C = [[0] * n for _ in range(n)]
    for j in range(1, n):
        C[0][j] = 1
    for i in range(1, n):
        C[i][0] = -1
    for i in range(1, n):
        for j in range(1, n):
            C[i][j] = Q[i - 1][j - 1]
    return C


def add_identity(C: Matrix) -> Matrix:
    """The Paley I core map  C |-> I + C."""
    return matadd(identity(len(C)), C)


def sub_identity(H: Matrix) -> Matrix:
    """The inverse map  H |-> H - I."""
    return matsub(H, identity(len(H)))


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_master_identity(C: Matrix) -> None:
    """Theorem 4.1:  C * C = (1 - n) I  for a skew conference matrix C."""
    n = len(C)
    lhs = matmul(C, C)
    rhs = scalar(1 - n, n)
    print(f"[Thm 4.1] C*C == (1 - n) I  (n = {n}):           {equal(lhs, rhs)}")
    assert equal(lhs, rhs)


def demo_forward(C: Matrix) -> Matrix:
    """Theorem 5.1 / Cor 5.2:  I + C is skew-Hadamard (hence Hadamard)."""
    H = add_identity(C)
    n = len(C)
    print(f"[Thm 5.1] I + C is skew-Hadamard of order {n}:    {is_skew_hadamard(H)}")
    print(f"[Cor 5.2] I + C is Hadamard:                     {is_hadamard(H)}")
    assert is_skew_hadamard(H) and is_hadamard(H)
    return H


def demo_converse(H: Matrix) -> None:
    """Theorem 6.1:  H - I is skew conference; bijection round-trip (Cor 6.2)."""
    C = sub_identity(H)
    print(f"[Thm 6.1] H - I is skew conference:              {is_skew_conference(C)}")
    print(f"[Cor 6.2] round trip  I + (H - I) == H:          {equal(add_identity(C), H)}")
    assert is_skew_conference(C) and equal(add_identity(C), H)


def demo_symmetric_boundary(q: int = 5) -> None:
    """Section 7: for q = 1 (mod 4) the Jacobsthal matrix is *symmetric*, so the
    identity shift I + Q does NOT preserve the Hadamard property — illustrating
    why the skew hypothesis is essential (and why Paley II must double the order).
    """
    Q = jacobsthal(q)
    symmetric = equal(transpose(Q), Q)
    H = add_identity(Q)
    print(f"\n[Sec 7] q = {q} (q mod 4 = {q % 4}): Jacobsthal symmetric = {symmetric}")
    print(f"        I + Q Hadamard? {is_hadamard(H)}  (expected False: skewness needed)")


def main() -> None:
    print("=" * 70)
    print(" Skew Conference Matrices and the Paley I Construction — Demo")
    print("=" * 70)

    for q in [3, 7, 11, 19, 23]:
        n = q + 1
        print("\n" + "-" * 70)
        print(f" q = {q}  (q mod 4 = {q % 4})  ->  skew conference / Hadamard order {n}")
        print("-" * 70)
        C = bordered_conference(q)
        ok = is_skew_conference(C)
        print(f"Bordered Jacobsthal is skew conference (order {n}): {ok}")
        if q == 3:
            show(C, "C  (skew conference, order 4)")
            show(add_identity(C), "I + C  (Hadamard, order 4)")
        demo_master_identity(C)
        H = demo_forward(C)
        demo_converse(H)
        print(f"[Thm 5.3] order {n} certified as a Hadamard order: {is_hadamard(H)}")

    demo_symmetric_boundary(5)
    demo_symmetric_boundary(13)

    print("\n" + "=" * 70)
    print(" All formally verified identities reproduced numerically. OK")
    print(" New (non power-of-two) Hadamard orders certified: 12, 20, 24.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
visualize.py — Visualize skew conference and Hadamard matrices as +-1 / 0 grids.

Standalone: uses matplotlib only. Renders, for a prime q = 3 (mod 4):
  (left)  the skew conference matrix C of order q+1   (blue=-1, white=0, red=+1)
  (right) the Hadamard matrix H = I + C of order q+1  (blue=-1, red=+1)

Run:  python3 visualize.py
Saves: hadamard_paley.png
"""

from __future__ import annotations

from typing import List, Set

import matplotlib.pyplot as plt
import numpy as np

Matrix = List[List[int]]


def quadratic_residues(q: int) -> Set[int]:
    return {(x * x) % q for x in range(1, q)}


def chi(x: int, q: int, qr: Set[int]) -> int:
    r = x % q
    return 0 if r == 0 else (1 if r in qr else -1)


def bordered_conference(q: int) -> Matrix:
    qr = quadratic_residues(q)
    Q = [[chi(a - b, q, qr) for b in range(q)] for a in range(q)]
    n = q + 1
    C = [[0] * n for _ in range(n)]
    for j in range(1, n):
        C[0][j] = 1
    for i in range(1, n):
        C[i][0] = -1
    for i in range(1, n):
        for j in range(1, n):
            C[i][j] = Q[i - 1][j - 1]
    return C


def add_identity(C: Matrix) -> Matrix:
    n = len(C)
    return [[C[i][j] + (1 if i == j else 0) for j in range(n)] for i in range(n)]


def main(q: int = 11) -> None:
    C = bordered_conference(q)
    H = add_identity(C)
    fig, axes = plt.subplots(1, 2, figsize=(11, 5))
    for ax, M, title in (
        (axes[0], C, f"Skew conference C (order {q + 1})"),
        (axes[1], H, f"Hadamard H = I + C (order {q + 1})"),
    ):
        ax.imshow(np.array(M), cmap="RdBu", vmin=-1, vmax=1)
        ax.set_title(title)
        ax.set_xticks([]); ax.set_yticks([])
    fig.suptitle(f"Paley I core for q = {q}:  C*C = (1 - n)I  ->  H*H^T = n I",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("hadamard_paley.png", dpi=150)
    print("saved hadamard_paley.png")


if __name__ == "__main__":
    main(11)
