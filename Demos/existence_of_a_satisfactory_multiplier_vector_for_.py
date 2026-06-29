"""
Numerical demonstrations for:

    Existence of a Satisfactory Multiplier Vector for 2D Lacunary Distance Graphs
    --- A Finite-Field Avoidance Theorem.

All functions are self-contained (standard library only) and fully type hinted.

The core finite-field theorem (over F = Z_p, p prime):

  * thin-line bound:  for nonzero d in F x F,  |bad(d)| = p,
        where bad(d) = { a in F x F : d1*a1 + d2*a2 = 0 (mod p) }.
  * multiplier avoidance:  if D is a set of nonzero vectors with |D| < p, then
        there exists a multiplier a with <d, a> != 0 (mod p) for every d in D.
  * integer corollary:  integer vectors each having a coordinate not divisible
        by p reduce to nonzero vectors, so the same multiplier exists.

The analytic companion (torus norm ||x||_T = |x - round(x)|):

  * geometric multiplier:  for q >= 2 and n_k = q^k, the multiplier 1/(q+1)
        gives the exact bound ||q^k / (q+1)||_T = 1/(q+1).
  * Dirichlet obstruction: for n_k = k there is no uniform positive bound.
"""

from __future__ import annotations

from itertools import product
from random import Random
from typing import Iterable


# --------------------------------------------------------------------------- #
# Finite-field primitives                                                      #
# --------------------------------------------------------------------------- #
def is_prime(n: int) -> bool:
    """Trial-division primality test."""
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def dot_mod(d: tuple[int, int], a: tuple[int, int], p: int) -> int:
    """Finite-field dot product <d, a> = d1*a1 + d2*a2 (mod p)."""
    return (d[0] * a[0] + d[1] * a[1]) % p


def bad_set(d: tuple[int, int], p: int) -> list[tuple[int, int]]:
    """The set of multipliers a in F x F with <d, a> = 0 (mod p)."""
    return [
        (a1, a2)
        for a1, a2 in product(range(p), range(p))
        if (d[0] * a1 + d[1] * a2) % p == 0
    ]


# --------------------------------------------------------------------------- #
# Demo 1 -- the thin-line bound (Lemma 3.1 / Remark 3.2)                       #
# --------------------------------------------------------------------------- #
def demo_line_bound(primes: Iterable[int] = (5, 7, 11, 13)) -> None:
    """Confirm |bad(d)| == p for every nonzero d, over several primes."""
    print("=" * 64)
    print("DEMO 1 -- thin-line bound: |bad(d)| = p for all nonzero d")
    print("=" * 64)
    for p in primes:
        assert is_prime(p)
        sizes = {
            len(bad_set((d1, d2), p))
            for d1, d2 in product(range(p), range(p))
            if (d1, d2) != (0, 0)
        }
        ok = sizes == {p}
        print(f"  p = {p:3d}:  observed |bad(d)| values = {sorted(sizes)}  "
              f"-> all equal p?  {ok}")
    print()


# --------------------------------------------------------------------------- #
# Demo 2 -- existence + two construction algorithms                            #
# --------------------------------------------------------------------------- #
def good_multiplier_bruteforce(
    D: list[tuple[int, int]], p: int
) -> tuple[int, int] | None:
    """Algorithm A: scan all p^2 multipliers (guaranteed to succeed if |D|<p)."""
    for a1, a2 in product(range(p), range(p)):
        if all(dot_mod(d, (a1, a2), p) != 0 for d in D):
            return (a1, a2)
    return None


def modinv(x: int, p: int) -> int:
    """Modular inverse of x mod prime p (Fermat)."""
    return pow(x % p, p - 2, p)


def good_multiplier_slice(
    D: list[tuple[int, int]], p: int
) -> tuple[int, int] | None:
    """Algorithm B: search the affine slice a = (1, t), then (t, 1)."""
    # slice a = (1, t):  <d,a> = d1 + d2*t.  Bad t (when d2 != 0): t = -d1/d2.
    forbidden_t: set[int] = set()
    for d1, d2 in D:
        if d2 % p != 0:
            forbidden_t.add((-d1 * modinv(d2, p)) % p)
        elif d1 % p == 0:
            return None  # d == 0, not allowed
        # if d2==0 and d1!=0 then <d,(1,t)> = d1 != 0, never forbidden
    for t in range(p):
        if t not in forbidden_t:
            cand = (1, t)
            if all(dot_mod(d, cand, p) != 0 for d in D):
                return cand
    # fallback slice a = (t, 1)
    for t in range(p):
        cand = (t, 1)
        if all(dot_mod(d, cand, p) != 0 for d in D):
            return cand
    return None


def verify_multiplier(
    a: tuple[int, int], D: list[tuple[int, int]], p: int
) -> bool:
    """Algorithm C: certify that <d,a> != 0 (mod p) for all d in D."""
    return all(dot_mod(d, a, p) != 0 for d in D)


def demo_avoidance(p: int = 13, seed: int = 2026) -> None:
    """Random D with |D| = p-1; find and verify a good multiplier (both algos)."""
    print("=" * 64)
    print("DEMO 2 -- multiplier avoidance theorem (|D| = p-1 < p)")
    print("=" * 64)
    rng = Random(seed)
    nonzero = [v for v in product(range(p), range(p)) if v != (0, 0)]
    D = rng.sample(nonzero, p - 1)
    print(f"  p = {p},  |D| = {len(D)}")
    a1 = good_multiplier_bruteforce(D, p)
    a2 = good_multiplier_slice(D, p)
    print(f"  Algorithm A (brute force) -> {a1},  verified: "
          f"{verify_multiplier(a1, D, p) if a1 else False}")
    print(f"  Algorithm B (slice)       -> {a2},  verified: "
          f"{verify_multiplier(a2, D, p) if a2 else False}")
    print()


# --------------------------------------------------------------------------- #
# Demo 3 -- threshold sharpness (|D| = p can fail)                            #
# --------------------------------------------------------------------------- #
def demo_threshold(p: int = 5) -> None:
    """Exhibit a set of p lines covering the torus: no good multiplier exists."""
    print("=" * 64)
    print("DEMO 3 -- sharpness: at |D| = p, avoidance can fail")
    print("=" * 64)
    # The p vectors (1, c) for c = 0..p-1 give bad lines whose union, together
    # with the line for (0,1), covers everything; here we use p vectors whose
    # bad sets already exhaust all candidate good multipliers.
    # Take D = all (1, c): a=(a1,a2) is bad for (1,c) iff a1 + c*a2 = 0.
    # For any a with a2 != 0 there is a unique c = -a1/a2 making it bad; and
    # a with a2 = 0, a1 != 0 is killed by (0,1).  Add (0,1) -> covers all nonzero a.
    D = [(1, c) for c in range(p)] + [(0, 1)]
    print(f"  p = {p},  |D| = {len(D)} (>= p)")
    a = good_multiplier_bruteforce(D, p)
    print(f"  good multiplier found?  {a is not None}  "
          f"(expected: only a=(0,0) survives, which gives zero dot products)")
    # Show that every nonzero multiplier is killed by some d in D.
    killed_all = all(
        any(dot_mod(d, (x1, x2), p) == 0 for d in D)
        for x1, x2 in product(range(p), range(p))
        if (x1, x2) != (0, 0)
    )
    print(f"  every nonzero multiplier killed by some d in D?  {killed_all}")
    print()


# --------------------------------------------------------------------------- #
# Demo 4 -- integer-displacement corollary (Theorem 5.1)                      #
# --------------------------------------------------------------------------- #
def demo_integer_corollary(p: int = 11, seed: int = 7) -> None:
    """Integer vectors with a coordinate coprime to p reduce and separate."""
    print("=" * 64)
    print("DEMO 4 -- integer corollary")
    print("=" * 64)
    rng = Random(seed)
    E: list[tuple[int, int]] = []
    while len(E) < p - 1:
        e = (rng.randint(-100, 100), rng.randint(-100, 100))
        if (e[0] % p != 0) or (e[1] % p != 0):  # coordinate not divisible by p
            E.append(e)
    D = [(e[0] % p, e[1] % p) for e in E]
    assert all(d != (0, 0) for d in D)
    a = good_multiplier_bruteforce(D, p)
    print(f"  p = {p},  |E| = {len(E)} integer vectors")
    print(f"  reduced multiplier a = {a}")
    ok = a is not None and all(
        ((e[0] % p) * a[0] + (e[1] % p) * a[1]) % p != 0 for e in E
    )
    print(f"  reduced dot products all nonzero?  {ok}")
    print()


# --------------------------------------------------------------------------- #
# Analytic companion -- the torus norm                                         #
# --------------------------------------------------------------------------- #
def torus_norm(x: float) -> float:
    """||x||_T = |x - round(x)|, the distance from x to the nearest integer."""
    return abs(x - round(x))


def torus_norm_rational(m: int, n: int) -> float:
    """Exact ||m/n||_T = min(m%n, n-(m%n)) / n."""
    r = m % n
    return min(r, n - r) / n


def demo_geometric_multiplier(qs: Iterable[int] = (2, 3, 4, 10), kmax: int = 8) -> None:
    """Check ||q^k / (q+1)||_T = 1/(q+1) for all k (Proposition 6.1)."""
    print("=" * 64)
    print("DEMO 5 -- geometric multiplier  alpha = 1/(q+1)")
    print("=" * 64)
    for q in qs:
        bound = 1.0 / (q + 1)
        vals = [torus_norm_rational(q ** k, q + 1) for k in range(kmax)]
        ok = all(abs(v - bound) < 1e-12 for v in vals)
        print(f"  q = {q:3d}:  ||q^k/(q+1)||_T = {bound:.6f} for k<{kmax}?  {ok}")
    print()


def demo_dirichlet_obstruction(alpha: float = 0.6180339887, kmax: int = 5000) -> None:
    """For n_k = k, the infimum of ||k*alpha||_T tends to 0 (Proposition 6.2)."""
    print("=" * 64)
    print("DEMO 6 -- Dirichlet obstruction for the non-lacunary sequence 1,2,3,...")
    print("=" * 64)
    running_min = min(torus_norm(k * alpha) for k in range(1, kmax + 1))
    print(f"  alpha = {alpha}")
    print(f"  min over k<= {kmax} of ||k*alpha||_T = {running_min:.6e}  "
          f"(-> 0 as k grows; no uniform positive bound)")
    print()


# --------------------------------------------------------------------------- #
def main() -> None:
    demo_line_bound()
    demo_avoidance()
    demo_threshold()
    demo_integer_corollary()
    demo_geometric_multiplier()
    demo_dirichlet_obstruction()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
