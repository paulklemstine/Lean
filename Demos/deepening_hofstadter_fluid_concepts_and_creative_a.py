"""
Analogy as an Adjoint Operation — numerical demonstrations.

This self-contained script illustrates the core results of the accompanying
paper on analogy-making formalized as a monotone Galois connection between
ordered structures:

  * an analogy is a forward/backward pair (F, G) bound by the adjunction law
        F(a) <= b   <=>   a <= G(b),
  * the round trip C = G . F is a CLOSURE OPERATOR (inflationary, monotone,
    idempotent),
  * the backward map G is UNIQUELY determined by F via
        G(b) = sup { a : F(a) <= b },
  * FIDELITY = number of round-trip fixed points, maximized exactly by
    PERFECT analogies (G . F = id),
  * in the min-plus (tropical) semiring the min-plus product v |-> A (x) v is
    partnered by its MAX-PLUS RESIDUAL A^#, and the unit/counit become the
    reconstruction sandwich
        w <= A (x) (A^# w)    and    A^# (A (x) v) <= v.

Everything is written with plain Python (plus `math`), fully inlined.
"""

from __future__ import annotations

from itertools import product
from math import inf
from typing import Callable, List, Sequence, Tuple

# A finite poset is (list of elements, "<=" predicate).
Poset = Tuple[List[int], Callable[[int, int], bool]]


# --------------------------------------------------------------------------
# 1. Finite posets and monotone Galois connections
# --------------------------------------------------------------------------

def chain(n: int) -> Poset:
    """The chain {0, 1, ..., n} with the usual order."""
    return list(range(n + 1)), (lambda a, b: a <= b)


def is_analogy(A: Poset, B: Poset,
               F: Callable[[int], int], G: Callable[[int], int]) -> bool:
    """Verify the adjunction law  F(a) <= b  <=>  a <= G(b)  for all a, b."""
    A_elems, leA = A
    B_elems, leB = B
    return all(leB(F(a), b) == leA(a, G(b))
               for a, b in product(A_elems, B_elems))


def induced_backward(A: Poset, B: Poset,
                     F: Callable[[int], int]) -> Callable[[int], int]:
    """Unique backward map  G(b) = sup { a : F(a) <= b }  on a finite lattice.

    For a chain this is simply the largest source element whose forward image
    still lies below b (or the bottom element if none qualifies).
    """
    A_elems, _ = A
    _, leB = B

    def G(b: int) -> int:
        candidates = [a for a in A_elems if leB(F(a), b)]
        return max(candidates) if candidates else A_elems[0]

    return G


# --------------------------------------------------------------------------
# 2. Closure operator and fidelity
# --------------------------------------------------------------------------

def round_trip(F: Callable[[int], int],
               G: Callable[[int], int]) -> Callable[[int], int]:
    return lambda a: G(F(a))


def closure_properties(A: Poset, C: Callable[[int], int]) -> dict:
    elems, leA = A
    inflationary = all(leA(a, C(a)) for a in elems)
    monotone = all((not leA(a, b)) or leA(C(a), C(b))
                   for a in elems for b in elems)
    idempotent = all(C(C(a)) == C(a) for a in elems)
    return {"inflationary": inflationary,
            "monotone": monotone,
            "idempotent": idempotent}


def fidelity(A: Poset, F: Callable[[int], int],
             G: Callable[[int], int]) -> int:
    elems, _ = A
    C = round_trip(F, G)
    return sum(1 for a in elems if C(a) == a)


def is_perfect(A: Poset, F: Callable[[int], int],
               G: Callable[[int], int]) -> bool:
    elems, _ = A
    return fidelity(A, F, G) == len(elems)


# --------------------------------------------------------------------------
# 3. Tropical (min-plus) analogy: forward map, max-plus residual
# --------------------------------------------------------------------------

Matrix = List[List[float]]
Vector = List[float]


def trop_mul(A: Matrix, v: Vector) -> Vector:
    """Min-plus product  (A (x) v)_i = min_j (A_ij + v_j)."""
    return [min(A[i][j] + v[j] for j in range(len(v))) for i in range(len(A))]


def residual(A: Matrix, w: Vector) -> Vector:
    """Max-plus residual  (A^# w)_j = max_i (w_i - A_ij), with w_i - inf = -inf."""
    n = len(A[0])
    out: Vector = []
    for j in range(n):
        vals = [(-inf if A[i][j] == inf else w[i] - A[i][j])
                for i in range(len(A))]
        out.append(max(vals))
    return out


def le_vec(u: Vector, v: Vector) -> bool:
    return all(x <= y + 1e-12 for x, y in zip(u, v))


# --------------------------------------------------------------------------
# Demonstration driver
# --------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("PART 1 — A finite analogy is a Galois connection (floor / ceiling)")
    print("=" * 70)
    # Classic Galois connection between chains: F(x) = floor(x/2), G(y) = 2y+1.
    A = chain(5)          # source concepts {0,...,5}
    B = chain(2)          # target concepts {0,1,2}
    F = lambda x: x // 2
    G = lambda y: 2 * y + 1
    print(f"Source A                : {A[0]}")
    print(f"Target B                : {B[0]}")
    print(f"F(x) = x // 2           : {[F(x) for x in A[0]]}")
    print(f"G(y) = 2y + 1           : {[G(y) for y in B[0]]}")
    print(f"(F, G) is an analogy    : {is_analogy(A, B, F, G)}")

    Gind = induced_backward(A, B, F)
    print(f"Backward map is unique  : "
          f"{[Gind(y) for y in B[0]] == [G(y) for y in B[0]]}"
          f"  (induced G = {[Gind(y) for y in B[0]]})")

    print("\n" + "=" * 70)
    print("PART 2 — The round trip C = G.F is a closure operator")
    print("=" * 70)
    C = round_trip(F, G)
    print(f"C(x) = 2*(x//2)+1       : {[C(x) for x in A[0]]}")
    for k, v in closure_properties(A, C).items():
        print(f"  {k:13s}: {v}")

    print("\n" + "=" * 70)
    print("PART 3 — Fidelity and perfect analogies")
    print("=" * 70)
    stable = [x for x in A[0] if C(x) == x]
    print(f"Stable concepts         : {stable}")
    print(f"Fidelity of (F, G)      : {fidelity(A, F, G)} / {len(A[0])}")
    print(f"Perfect?                : {is_perfect(A, F, G)}")
    idF = lambda x: x
    idG = lambda x: x
    print(f"Identity analogy fidelity: {fidelity(A, idF, idG)} / {len(A[0])}"
          f"  perfect={is_perfect(A, idF, idG)}")

    print("\n" + "=" * 70)
    print("PART 4 — Tropical analogy: max-plus residual & reconstruction")
    print("=" * 70)
    # Directed-network cost matrix (inf = no edge).
    Amat: Matrix = [
        [0.0, 3.0, inf, 7.0],
        [3.0, 0.0, 2.0, inf],
        [inf, 2.0, 0.0, 1.0],
        [7.0, inf, 1.0, 0.0],
    ]
    v: Vector = [0.0, 5.0, 2.0, 4.0]
    w: Vector = [1.0, 0.0, 3.0, 2.0]

    print(f"v                       : {v}")
    print(f"A (x) v (min-plus)      : {trop_mul(Amat, v)}")
    print(f"A^# w (max-plus resid.) : {residual(Amat, w)}")

    # Adjunction:  A^# w <= v  <=>  w <= A (x) v
    lhs = le_vec(residual(Amat, w), v)
    rhs = le_vec(w, trop_mul(Amat, v))
    print(f"Adjunction (A^#w<=v)==(w<=A(x)v) : {lhs} == {rhs}  -> {lhs == rhs}")

    # Reconstruction sandwich
    counit = le_vec(residual(Amat, trop_mul(Amat, v)), v)   # A^#(A v) <= v
    unit = le_vec(w, trop_mul(Amat, residual(Amat, w)))     # w <= A (A^# w)
    print(f"unit    w <= A (x) (A^# w)          : {unit}")
    print(f"counit  A^# (A (x) v) <= v          : {counit}")

    # Solvability of A (x) x = b via  A (x) (A^# b) == b
    b: Vector = trop_mul(Amat, v)   # constructed to lie in the range of A (x) -
    recon = trop_mul(Amat, residual(Amat, b))
    solvable = le_vec(recon, b) and le_vec(b, recon)
    print(f"System A(x)x=b solvable (b in range): {solvable}"
          f"  (greatest solution A^# b = {residual(Amat, b)})")


if __name__ == "__main__":
    main()
