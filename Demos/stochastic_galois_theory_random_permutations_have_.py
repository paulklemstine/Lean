"""
Stochastic Galois Theory over Finite Fields — numerical demonstrations.

This self-contained script verifies, by brute-force enumeration over small prime
fields F_p, the exact theorems of the accompanying paper:

  1. The Expected-Roots Identity: summed over all p^n monic degree-n polynomials,
     the total number of roots in F_p is exactly p^n, so the average number of
     roots is exactly 1 (in every degree) — mirroring the mean number of fixed
     points of a uniform random permutation in S_n.

  2. The Degree-Two Census (p odd): exactly p monic quadratics have a repeated
     root, exactly p(p+1)/2 are reducible, and exactly p(p-1)/2 are irreducible,
     so the proportion irreducible tends to 1/2.

  3. The Cyclic Obstruction: over a finite field the Galois group is cyclic, so it
     is never S_n for n >= 3. We illustrate the analogue that survives — the
     factorization type of a random polynomial converges to the cycle type of a
     random permutation in S_n — by comparing empirical factorization-type
     frequencies over F_p to exact symmetric-group cycle-type probabilities.

Run: python demo.py
"""

from __future__ import annotations

from itertools import product
from math import factorial, gcd
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Basic finite-field polynomial utilities over F_p (p prime).
# A monic polynomial x^n + v_{n-1} x^{n-1} + ... + v_0 is stored as the tuple
# of its lower coefficients (v_0, v_1, ..., v_{n-1}).
# --------------------------------------------------------------------------- #
def eval_monic(coeffs: Tuple[int, ...], r: int, p: int) -> int:
    """Evaluate the monic polynomial with lower coefficients `coeffs` at r mod p."""
    n = len(coeffs)
    val = pow(r, n, p)  # leading x^n term
    for i, c in enumerate(coeffs):
        val = (val + c * pow(r, i, p)) % p
    return val % p


def count_roots(coeffs: Tuple[int, ...], p: int) -> int:
    """Number of roots in F_p of the monic polynomial with lower `coeffs`."""
    return sum(1 for r in range(p) if eval_monic(coeffs, r, p) == 0)


# --------------------------------------------------------------------------- #
# Demonstration 1 — the Expected-Roots Identity.
# --------------------------------------------------------------------------- #
def expected_roots_identity(p: int, n: int) -> Tuple[int, int, float]:
    """
    Return (total_incidences, p**n, average_roots) over all p^n monic degree-n
    polynomials over F_p. The theorem asserts total_incidences == p**n and
    average_roots == 1.0 exactly.
    """
    total = 0
    for coeffs in product(range(p), repeat=n):
        total += count_roots(coeffs, p)
    return total, p ** n, total / p ** n


# --------------------------------------------------------------------------- #
# Demonstration 2 — the Degree-Two Census.
# --------------------------------------------------------------------------- #
def degree_two_census(p: int) -> Dict[str, int]:
    """
    Classify all p^2 monic quadratics x^2 + b x + c over F_p (p odd) by their
    number of roots. Returns the exact counts alongside the closed-form
    predictions.
    """
    repeated = reducible = irreducible = 0
    for b in range(p):
        for c in range(p):
            nr = count_roots((c, b), p)  # coeffs = (v_0=c, v_1=b)
            if nr == 1:
                repeated += 1
            if nr >= 1:
                reducible += 1
            if nr == 0:
                irreducible += 1
    return {
        "repeated_root": repeated,
        "predicted_repeated": p,
        "reducible": reducible,
        "predicted_reducible": p * (p + 1) // 2,
        "irreducible": irreducible,
        "predicted_irreducible": p * (p - 1) // 2,
    }


# --------------------------------------------------------------------------- #
# Demonstration 3 — Frobenius cycle-type equidistribution.
# --------------------------------------------------------------------------- #
def _roots_with_multiplicity(coeffs: List[int], p: int) -> List[int]:
    """Return the list of roots in F_p of a monic polynomial (ascending coeffs),
    each repeated according to how many times (x - r) divides it."""
    roots: List[int] = []
    poly = coeffs[:]
    changed = True
    while changed and len(poly) > 1:
        changed = False
        for r in range(p):
            # Horner evaluation
            val = 0
            for c in reversed(poly):
                val = (val * r + c) % p
            if val == 0:
                # synthetic division by (x - r): poly ascending
                deg = len(poly) - 1
                quo = [0] * deg
                rem = poly[-1]
                for i in range(deg - 1, -1, -1):
                    quo[i] = rem
                    rem = (poly[i] + r * rem) % p
                poly = quo
                roots.append(r)
                changed = True
                break
    return roots


def factorization_type(coeffs: Tuple[int, ...], p: int) -> Tuple[int, ...]:
    """
    Multiset of irreducible-factor degrees (the Frobenius cycle type) of a
    monic polynomial over F_p, computed for small degree (n <= 3) by peeling off
    linear factors and classifying the remaining low-degree cofactor. For n <= 3
    a squarefree cofactor of degree 2 or 3 with no F_p-root is irreducible, so
    the partition returned is exact for squarefree inputs. Non-squarefree inputs
    have density -> 0 and are reported by their peeled type.
    """
    n = len(coeffs)
    poly = list(coeffs) + [1]  # ascending, monic degree n
    linear = _roots_with_multiplicity(poly, p)
    degrees: List[int] = [1] * len(linear)
    remaining = n - len(linear)
    if remaining >= 2:
        # For n <= 3 the leftover (no F_p roots) is a single irreducible factor.
        degrees.append(remaining)
    return tuple(sorted(degrees))


def sn_cycle_type_distribution(n: int) -> Dict[Tuple[int, ...], float]:
    """Exact probabilities of each cycle type (partition of n) in S_n."""
    dist: Dict[Tuple[int, ...], float] = {}
    for perm in _partitions(n):
        # number of permutations with cycle type = perm
        # n! / prod_k (k^{m_k} * m_k!)
        counts: Dict[int, int] = {}
        for part in perm:
            counts[part] = counts.get(part, 0) + 1
        denom = 1
        for k, mk in counts.items():
            denom *= (k ** mk) * factorial(mk)
        dist[tuple(sorted(perm))] = factorial(n) / denom / factorial(n)
    return dist


def _partitions(n: int, mx: int | None = None) -> List[Tuple[int, ...]]:
    """All integer partitions of n (as tuples of parts)."""
    if mx is None:
        mx = n
    if n == 0:
        return [()]
    out: List[Tuple[int, ...]] = []
    for k in range(min(n, mx), 0, -1):
        for rest in _partitions(n - k, k):
            out.append((k,) + rest)
    return out


def empirical_vs_sn(p: int, n: int) -> None:
    """Compare empirical factorization-type frequencies over F_p with S_n."""
    emp: Dict[Tuple[int, ...], int] = {}
    total = 0
    for coeffs in product(range(p), repeat=n):
        ft = factorization_type(coeffs, p)
        if sum(ft) != n:  # skip degenerate parse
            continue
        emp[ft] = emp.get(ft, 0) + 1
        total += 1
    sn = sn_cycle_type_distribution(n)
    print(f"    factorization type   empirical(F_{p})    S_{n} probability")
    for part in sorted(sn, reverse=True):
        e = emp.get(part, 0) / total if total else 0.0
        print(f"    {str(part):<18}   {e:>10.4f}       {sn[part]:>10.4f}")


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("1. EXPECTED-ROOTS IDENTITY  (average number of roots = 1 exactly)")
    print("=" * 70)
    for p in (3, 5, 7):
        for n in (1, 2, 3):
            total, pn, avg = expected_roots_identity(p, n)
            ok = "OK" if total == pn and abs(avg - 1.0) < 1e-12 else "FAIL"
            print(f"  p={p}, n={n}:  total roots = {total:>5} = p^n = {pn:>5}"
                  f"   avg = {avg:.4f}  [{ok}]")

    print()
    print("=" * 70)
    print("2. DEGREE-TWO CENSUS  (q odd)")
    print("=" * 70)
    for p in (3, 5, 7, 11, 13):
        c = degree_two_census(p)
        print(f"  p={p:>3}:  repeated={c['repeated_root']:>3} (pred {c['predicted_repeated']:>3})"
              f"   reducible={c['reducible']:>4} (pred {c['predicted_reducible']:>4})"
              f"   irreducible={c['irreducible']:>4} (pred {c['predicted_irreducible']:>4})"
              f"   irred. frac={c['irreducible']/p**2:.4f}")
    print("  -> proportion irreducible -> 1/2 as p grows.")

    print()
    print("=" * 70)
    print("3. FROBENIUS CYCLE-TYPE EQUIDISTRIBUTION  (n=3)")
    print("=" * 70)
    for p in (5, 7, 11):
        print(f"  Over F_{p}:")
        empirical_vs_sn(p, 3)
        print()
    print("  -> empirical factorization frequencies approach the S_3 cycle-type law.")


if __name__ == "__main__":
    main()
