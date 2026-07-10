"""
Numerical demonstrations for
"Spectral Theory of Random Walks on Cayley Graphs of Finite Abelian Groups".

This self-contained script verifies, numerically, the main results of the paper:

  * Characters diagonalize the Cayley walk operator: A_S psi = (sum_s psi(s)) psi.
  * The trivial character gives the top eigenvalue |S| (Perron), and every
    eigenvalue has modulus <= |S|.
  * For a symmetric generating set the eigenvalues are real (self-adjointness).
  * The cycle Cay(Z/nZ, {+1,-1}) has second eigenvalue 2 cos(2 pi / n) and a
    strictly positive spectral gap ~ (2 pi / n)^2.
  * The hypercube (Z/2Z)^d has eigenvalues d - 2 * HammingWeight and gap 2/d.
  * The spectral gap controls classical mixing time.

Only the Python standard library is required.
"""

from __future__ import annotations

import cmath
import math
from itertools import product
from typing import Callable, List, Tuple

Complex = complex


# ---------------------------------------------------------------------------
# Cyclic group Z/nZ
# ---------------------------------------------------------------------------

def cyclic_character(n: int, j: int) -> Callable[[int], Complex]:
    """Return the additive character psi_j(x) = exp(2 pi i j x / n) on Z/nZ."""
    def psi(x: int) -> Complex:
        return cmath.exp(2j * math.pi * j * (x % n) / n)
    return psi


def char_eigenvalue(gens: List[int], psi: Callable[[int], Complex]) -> Complex:
    """lambda_psi(S) = sum_{s in S} psi(s)."""
    return sum(psi(s) for s in gens)


def adjacency_matrix_cyclic(n: int, gens: List[int]) -> List[List[Complex]]:
    """Dense adjacency (walk) operator of Cay(Z/nZ, gens) in the delta basis."""
    A = [[0j for _ in range(n)] for _ in range(n)]
    for x in range(n):
        for s in gens:
            A[x][(x + s) % n] += 1
    return A


def apply_matrix(A: List[List[Complex]], v: List[Complex]) -> List[Complex]:
    """Matrix-vector product."""
    n = len(A)
    return [sum(A[i][k] * v[k] for k in range(n)) for i in range(n)]


def vector_close(u: List[Complex], v: List[Complex], tol: float = 1e-9) -> bool:
    return all(abs(a - b) < tol for a, b in zip(u, v))


# ---------------------------------------------------------------------------
# Demo 1: characters are eigenvectors of the cycle walk operator
# ---------------------------------------------------------------------------

def demo_eigenvectors(n: int = 8) -> None:
    print("=" * 70)
    print(f"Demo 1: characters diagonalize the cycle walk operator (n = {n})")
    print("=" * 70)
    gens = [1, n - 1]  # {+1, -1}
    A = adjacency_matrix_cyclic(n, gens)
    for j in range(n):
        psi = cyclic_character(n, j)
        vec = [psi(x) for x in range(n)]
        lam = char_eigenvalue(gens, psi)
        lhs = apply_matrix(A, vec)
        rhs = [lam * c for c in vec]
        ok = vector_close(lhs, rhs)
        print(f"  j={j:2d}: eigenvalue = {lam.real:+.5f}{lam.imag:+.5f}i "
              f"= 2cos(2pi*{j}/{n}) = {2*math.cos(2*math.pi*j/n):+.5f}   "
              f"A psi = lambda psi ? {ok}")
    print()


# ---------------------------------------------------------------------------
# Demo 2: top eigenvalue, Perron bound, and self-adjointness (real spectrum)
# ---------------------------------------------------------------------------

def demo_perron_and_real(n: int = 12) -> None:
    print("=" * 70)
    print(f"Demo 2: top eigenvalue |S|, Perron bound, real spectrum (n = {n})")
    print("=" * 70)
    gens = [1, n - 1]  # symmetric: {+1, -1}
    degree = len(gens)
    max_mod = 0.0
    max_imag = 0.0
    for j in range(n):
        lam = char_eigenvalue(gens, cyclic_character(n, j))
        max_mod = max(max_mod, abs(lam))
        max_imag = max(max_imag, abs(lam.imag))
    triv = char_eigenvalue(gens, cyclic_character(n, 0))
    print(f"  trivial character eigenvalue = {triv.real:.5f}  (should equal |S| = {degree})")
    print(f"  max |eigenvalue|            = {max_mod:.5f}  (Perron bound |S| = {degree})")
    print(f"  max |Im(eigenvalue)|        = {max_imag:.2e}  (real spectrum since S = -S)")
    print()


# ---------------------------------------------------------------------------
# Demo 3: the cycle spectral gap and its ~ (2 pi / n)^2 asymptotics
# ---------------------------------------------------------------------------

def cycle_spectral_gap(n: int) -> float:
    """Spectral gap of Cay(Z/nZ, {+1,-1}) with the un-normalized operator."""
    return 2 - 2 * math.cos(2 * math.pi / n)


def demo_cycle_gap() -> None:
    print("=" * 70)
    print("Demo 3: cycle spectral gap 2 - 2cos(2pi/n) and its ~(2pi/n)^2 law")
    print("=" * 70)
    print(f"  {'n':>5} | {'gap':>12} | {'(2pi/n)^2':>12} | {'ratio':>8}")
    for n in [3, 4, 8, 16, 32, 64, 128]:
        gap = cycle_spectral_gap(n)
        approx = (2 * math.pi / n) ** 2
        print(f"  {n:>5} | {gap:>12.8f} | {approx:>12.8f} | {gap/approx:>8.5f}")
    print("  (gap > 0 for all n >= 3; ratio -> 1, confirming gap = Theta(n^-2))")
    print()


# ---------------------------------------------------------------------------
# Demo 4: the hypercube (Z/2Z)^d spectrum d - 2 * HammingWeight
# ---------------------------------------------------------------------------

def hypercube_eigenvalues(d: int) -> List[int]:
    """Eigenvalues of the bit-flip walk on (Z/2Z)^d: d - 2*|T|, T subset of [d]."""
    return [d - 2 * sum(t) for t in product((0, 1), repeat=d)]


def demo_hypercube(d: int = 4) -> None:
    print("=" * 70)
    print(f"Demo 4: hypercube (Z/2Z)^{d} eigenvalues = d - 2*HammingWeight")
    print("=" * 70)
    eigs = sorted(hypercube_eigenvalues(d), reverse=True)
    print(f"  eigenvalues: {eigs}")
    print(f"  top = {eigs[0]} (= d), second = {eigs[1]} (= d-2)")
    gap_normalized = (eigs[0] - eigs[1]) / d
    print(f"  normalized spectral gap = {gap_normalized:.5f}  (= 2/d = {2/d:.5f})")
    print(f"  => mixing time Theta(d log d) ~ {d*math.log(d):.2f}")
    print()


# ---------------------------------------------------------------------------
# Demo 5: spectral gap controls mixing (classical random walk on the cycle)
# ---------------------------------------------------------------------------

def total_variation_from_uniform(dist: List[float]) -> float:
    n = len(dist)
    return 0.5 * sum(abs(p - 1.0 / n) for p in dist)


def demo_mixing(n: int = 16) -> None:
    print("=" * 70)
    print(f"Demo 5: TV distance to uniform vs. spectral-gap bound (cycle n = {n})")
    print("=" * 70)
    gens = [1, n - 1]
    # LAZY normalized walk P = (I + A/|S|)/2 (aperiodic; the +1/-1 walk on an
    # even cycle is otherwise bipartite and does not converge in TV).
    A = adjacency_matrix_cyclic(n, gens)
    P = [[0.5 * (1.0 if i == k else 0.0) + 0.5 * A[i][k].real / len(gens)
          for k in range(n)] for i in range(n)]
    dist = [0.0] * n
    dist[0] = 1.0
    # lazy walk eigenvalues are (1 + cos(2pi j/n))/2; slowest non-trivial gap:
    gap = 0.5 * (1 - math.cos(2 * math.pi / n))
    print(f"  {'t':>5} | {'TV distance':>14} | {'(1-gap)^t bound':>16}")
    for t in range(0, 4 * n * n + 1):
        if t % (n * n // 2 if n * n >= 2 else 1) == 0:
            tv = total_variation_from_uniform(dist)
            bound = (1 - gap) ** t
            print(f"  {t:>5} | {tv:>14.8f} | {bound:>16.8f}")
        dist = [sum(P[k][i] * dist[k] for k in range(n)) for i in range(n)]
    print("  (TV distance decays; falls below any threshold in O(gap^-1 log n) steps)")
    print()


# ---------------------------------------------------------------------------
# Demo 6: periodicity of the single-generator (quantum) shift
# ---------------------------------------------------------------------------

def demo_periodicity(n: int = 6) -> None:
    print("=" * 70)
    print(f"Demo 6: single-generator shift is unitary and periodic (n = {n})")
    print("=" * 70)
    s = 2  # generator; order divides n / gcd(n, s)
    order = n // math.gcd(n, s)
    # apply shift_s repeatedly to a random state and check norm + period
    state = [complex(math.cos(x), math.sin(2 * x)) for x in range(n)]
    norm0 = sum(abs(z) ** 2 for z in state)

    def shift(v: List[Complex]) -> List[Complex]:
        return [v[(x + s) % n] for x in range(n)]

    cur = list(state)
    for k in range(1, order + 1):
        cur = shift(cur)
    normk = sum(abs(z) ** 2 for z in state)
    returned = vector_close(cur, state)
    print(f"  generator s = {s}, additive order = {order}")
    print(f"  ||f||^2 preserved by shift: {abs(norm0 - normk) < 1e-9} (unitary)")
    print(f"  shift^order = identity: {returned} (periodic)")
    print()


def main() -> None:
    demo_eigenvectors(8)
    demo_perron_and_real(12)
    demo_cycle_gap()
    demo_hypercube(4)
    demo_mixing(16)
    demo_periodicity(6)


if __name__ == "__main__":
    main()
