#!/usr/bin/env python3
"""
The Delete-a-Term Screen and the General-Exponent Reveal Identity
=================================================================

Numerical companion to "Which Terms Carry the Exponent?".  Everything here is
self-contained (standard library only) and uses exact rational arithmetic.

Part I   -- exponent minimax models of Harvey's N^(1/5) balance:
            * exact solver for min over (a, b) in [0,1]^2 of max of affine terms
            * the delete-a-term screen on the four terms {interior, r, m, M}
            * the M-leg value function V(theta) = max(1/5, theta/(1+theta))
            * Lehman (no baby-step split), the collapse model, levers.
Part II  -- the general-exponent reveal identity
            R(E) = d_p (q-1) + d_q (p-1) - 2 d_p d_q, checked by brute force.
Part III -- the maximal-gap extreme: factoring q = k(p-1)+1 by one integer
            square root.
"""

from __future__ import annotations

from fractions import Fraction as Fr
from itertools import combinations
from math import gcd, isqrt
from typing import Callable, Dict, List, Optional, Sequence, Tuple

# ---------------------------------------------------------------------------
# Part I. Exact two-parameter minimax of affine exponent terms
# ---------------------------------------------------------------------------

# An affine term c0 + ca*a + cb*b is stored as the triple (c0, ca, cb).
Affine = Tuple[Fr, Fr, Fr]


def affine(c0: object, ca: object = 0, cb: object = 0) -> Affine:
    return (Fr(c0), Fr(ca), Fr(cb))


def evaluate(term: Affine, a: Fr, b: Fr) -> Fr:
    return term[0] + term[1] * a + term[2] * b


def solve2(r1: Tuple[Fr, Fr, Fr], r2: Tuple[Fr, Fr, Fr]) -> Optional[Tuple[Fr, Fr]]:
    """Solve x*a + y*b = z for two rows (x, y, z); None if singular."""
    (x1, y1, z1), (x2, y2, z2) = r1, r2
    det = x1 * y2 - x2 * y1
    if det == 0:
        return None
    return ((z1 * y2 - z2 * y1) / det, (x1 * z2 - x2 * z1) / det)


def minimax(terms: Sequence[Affine]) -> Tuple[Fr, Tuple[Fr, Fr]]:
    """Exact value of  min_{(a,b) in [0,1]^2} max_i term_i(a,b).

    The epigraph is a polyhedron; its optimum lies at a point where two
    independent 'lines' are tight, each line being either an equality
    term_i = term_j or a box edge.  We enumerate all such points.
    """
    lines: List[Tuple[Fr, Fr, Fr]] = [
        (Fr(1), Fr(0), Fr(0)), (Fr(1), Fr(0), Fr(1)),
        (Fr(0), Fr(1), Fr(0)), (Fr(0), Fr(1), Fr(1)),
    ]
    for s, t in combinations(terms, 2):  # s = t  <=>  (sa-ta) a + (sb-tb) b = t0-s0
        lines.append((s[1] - t[1], s[2] - t[2], t[0] - s[0]))
    cands = [(Fr(0), Fr(0)), (Fr(1), Fr(1))]
    for l1, l2 in combinations(lines, 2):
        pt = solve2(l1, l2)
        if pt is not None and 0 <= pt[0] <= 1 and 0 <= pt[1] <= 1:
            cands.append(pt)
    best: Optional[Tuple[Fr, Tuple[Fr, Fr]]] = None
    for a, b in cands:
        v = max(evaluate(t, a, b) for t in terms)
        if best is None or v < best[0]:
            best = (v, (a, b))
    assert best is not None
    return best


# The four terms of the order-free balance (exponents of N; r = N^a, m = N^b).
INTERIOR: Affine = affine(Fr(1, 2), Fr(-1, 2), -1)   # N^(1/2) / (r^(1/2) m)
PAIRS: Affine = affine(0, 1, 0)                      # r
BABY: Affine = affine(0, 0, 1)                       # m
def mleg(theta: Fr) -> Affine:                       # (N/r)^theta
    return affine(theta, -theta, 0)


def show(label: str, terms: Sequence[Affine]) -> Fr:
    v, (a, b) = minimax(terms)
    print(f"  {label:<44} value = {str(v):>6}   at a = {a}, b = {b}")
    return v


def part_one() -> None:
    print("=" * 78)
    print("PART I.  The delete-a-term screen on Harvey's order-free balance")
    print("=" * 78)
    full = [INTERIOR, PAIRS, BABY, mleg(Fr(1, 4))]
    names = ["interior N^(1/2)/(r^(1/2) m)", "pair family r", "baby-step list m",
             "M-leg (N/r)^(1/4)"]
    v_full = show("all four terms", full)
    print("  Step 1: screen the M-leg against the other three terms:")
    v = show("  without the M-leg", full[:3])
    show("  M-leg made free (theta = 0)", full[:3] + [mleg(Fr(0))])
    print(f"      -> {'LOAD-BEARING' if v != v_full else 'redundant (inert)'}")
    core = full[:3]
    print("  Step 2: screen each term of the remaining three-term core:")
    for i, nm in enumerate(names[:3]):
        rest = core[:i] + core[i + 1:]
        v = show(f"  without {nm}", rest)
        verdict = "LOAD-BEARING" if v != v_full else "redundant (inert)"
        print(f"      -> {verdict}")
    print("  Caution: screening is relative to the terms kept.  With the M-leg still")
    print("  present, deleting the interior or m leaves 1/5, because the M-leg takes over:")
    show("  {r, m, M} (interior deleted)", [PAIRS, BABY, mleg(Fr(1, 4))])
    show("  {interior, r, M} (m deleted)", [INTERIOR, PAIRS, mleg(Fr(1, 4))])

    print("\n  M-leg value function V(theta) versus max(1/5, theta/(1+theta)):")
    for theta in [Fr(0), Fr(1, 10), Fr(1, 5), Fr(1, 4), Fr(3, 10), Fr(1, 2), Fr(1)]:
        v, _ = minimax([INTERIOR, PAIRS, BABY, mleg(theta)])
        predicted = max(Fr(1, 5), theta / (1 + theta))
        print(f"    theta = {str(theta):>5}:  V = {str(v):>6}   formula = "
              f"{str(predicted):>6}   {'OK' if v == predicted else 'MISMATCH'}")

    print("\n  Co-tightness: at the optimum a = 1/5 the real leg has exponent",
          Fr(1, 4) * (1 - Fr(1, 5)), "(active, yet deletable).")

    print("\n  The m-reuse is load-bearing:")
    # Force b = 0 exactly (m = 1): minimise over a only.
    best = min((max(x, Fr(1, 2) - x / 2), x) for x in [Fr(k, 300) for k in range(301)])
    print(f"    no baby-step split (m = 1): min_a max(a, 1/2 - a/2) = {best[0]} at a = {best[1]}"
          "   (Lehman's 1/3)")
    collapse = min((max(x, Fr(1, 4) + x / 4), x) for x in [Fr(k, 400) for k in range(401)])
    print(f"    collapse model max(a, 1/4 + a/4): optimum {collapse[0]} at a = {collapse[1]}")
    print(f"    penalty against 1/5: {collapse[0] - Fr(1, 5)}  (= 1/20)")
    print("    reported experiment: fitted penalty slope 0.046-0.052 vs 1/20 = 0.050")

    print("\n  Screening the untouched m-leg (discount m -> m^(1-eps)):")
    for eps in [Fr(0), Fr(1, 10), Fr(1, 4), Fr(1, 2)]:
        v, _ = minimax([INTERIOR, PAIRS, affine(0, 0, 1 - eps)])
        delta = eps / (5 - 3 * eps)
        v_int, _ = minimax([affine(Fr(1, 2) - delta, Fr(-1, 2), -1), PAIRS, BABY])
        print(f"    eps = {str(eps):>4}: value {str(v):>6} = (1-eps)/(5-3eps) = "
              f"{(1 - eps) / (5 - 3 * eps)};  equivalent interior gain delta = "
              f"{delta} gives {v_int}")
    print("  Interior gain N^(-delta) gives (1-2 delta)/5, NOT (1/2-delta)/5:")
    for delta in [Fr(0), Fr(1, 20), Fr(1, 10)]:
        v, _ = minimax([affine(Fr(1, 2) - delta, Fr(-1, 2), -1), PAIRS, BABY])
        print(f"    delta = {str(delta):>5}: value {v}   (1-2d)/5 = {(1 - 2 * delta) / 5}"
              f"   misstated (1/2-d)/5 = {(Fr(1, 2) - delta) / 5}")


# ---------------------------------------------------------------------------
# Part II. The general-exponent reveal identity
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def reveal_counts(p: int, q: int, E: int) -> Dict[str, int]:
    """Brute-force the four cells over (Z/p)^* x (Z/q)^* for exponent E."""
    left = sum(1 for x in range(1, p) if pow(x, E, p) == 1)   # = gcd(E, p-1)
    right = sum(1 for y in range(1, q) if pow(y, E, q) == 1)  # = gcd(E, q-1)
    both = left * right
    only_left = left * (q - 1) - both
    only_right = right * (p - 1) - both
    neither = (p - 1 - left) * (q - 1 - right)
    return {"dp": left, "dq": right, "both": both, "reveal": only_left + only_right,
            "neither": neither}


def reveal_via_gcd(p: int, q: int, E: int) -> int:
    """Count residues a mod N, coprime to N, for which gcd(a^E - 1, N) is proper."""
    N = p * q
    return sum(1 for a in range(1, N) if gcd(a, N) == 1
               and 1 < gcd((pow(a, E, N) - 1) % N, N) < N)


def reveal_formula(p: int, q: int, E: int) -> int:
    dp, dq = gcd(E, p - 1), gcd(E, q - 1)
    return dp * (q - 1) + dq * (p - 1) - 2 * dp * dq


def part_two() -> None:
    print("\n" + "=" * 78)
    print("PART II.  General-exponent reveal identity R(E) = dp(q-1) + dq(p-1) - 2 dp dq")
    print("=" * 78)
    pairs = [(5, 7), (7, 13), (11, 23), (13, 37)]
    checked = 0
    for p, q in pairs:
        N = p * q
        for E in range(1, 2 * N):
            assert reveal_via_gcd(p, q, E) == reveal_formula(p, q, E), (p, q, E)
            c = reveal_counts(p, q, E)
            assert c["both"] + c["reveal"] + c["neither"] == (p - 1) * (q - 1)
            checked += 1
    print(f"  identity and four-cell partition checked for {checked} (p, q, E) triples")
    p, q = 13, 37
    N = p * q
    g = gcd(p - 1, q - 1)
    print(f"  example p = {p}, q = {q}, N = {N}:")
    for E in [1, 2, 3, 4, 6, 12, 36, N - 1]:
        c = reveal_counts(p, q, E)
        print(f"    E = {E:>4}: d_p = {c['dp']:>2}, d_q = {c['dq']:>2}, R(E) = "
              f"{c['reveal']:>3}  (formula {reveal_formula(p, q, E)}; brute gcd count "
              f"{reveal_via_gcd(p, q, E)})")
    print(f"  at E = N-1 both gcds equal the Euler gap g = gcd(p-1, q-1) = {g}:",
          f"g(q-1) + g(p-1) - 2g^2 = {g * (q - 1) + g * (p - 1) - 2 * g * g}")


# ---------------------------------------------------------------------------
# Part III. The algebraically solvable extreme
# ---------------------------------------------------------------------------

def factor_by_one_sqrt(N: int, k: int, s: int = 1) -> Optional[int]:
    """If N = p*q with q = k(p-1) + s, return p using one integer square root.

    k p^2 + (s - k) p - N = 0 has discriminant (s-k)^2 + 4kN = (2kp + s - k)^2.
    """
    disc = (s - k) ** 2 + 4 * k * N
    root = isqrt(disc)
    if root * root != disc:
        return None
    num = root - (s - k)
    if num % (2 * k):
        return None
    p = num // (2 * k)
    return p if 1 < p < N and N % p == 0 else None


def search_extreme(N: int, kmax: int = 64) -> Optional[Tuple[int, int, int]]:
    for k in range(1, kmax + 1):
        for s in (1, -1):
            p = factor_by_one_sqrt(N, k, s)
            if p is not None:
                return p, k, s
    return None


def part_three() -> None:
    print("\n" + "=" * 78)
    print("PART III.  The maximal-gap extreme is factored by one integer square root")
    print("=" * 78)
    shown = 0
    for p in range(1000, 200000):
        if not is_prime(p):
            continue
        for k in (2, 6, 10, 30):
            q = k * (p - 1) + 1
            if q > p and is_prime(q):
                N = p * q
                res = search_extreme(N)
                dens = Fr((p - 1) * (q - p), (p - 1) * (q - 1))
                print(f"  N = {N:>13} : q = {k}(p-1)+1, recovered {res}, "
                      f"reveal density R/phi = {dens} = 1 - 1/{k}")
                shown += 1
                break
        if shown >= 6:
            break
    # A small brute-force check of the reveal count (p-1)(q-p) on the extreme.
    for p, q in [(7, 13), (11, 31), (13, 37)]:
        assert (q - 1) % (p - 1) == 0
        assert reveal_via_gcd(p, q, p * q - 1) == (p - 1) * (q - p)
    print("  reveal count (p-1)(q-p) confirmed by brute force on (7,13), (11,31), (13,37)")
    # The s = -1 ("eulergap2") extreme.
    for p in range(500, 20000):
        q = 4 * (p - 1) - 1
        if is_prime(p) and is_prime(q):
            print(f"  s = -1 example: N = {p * q}, q = 4(p-1)-1, recovered {search_extreme(p * q)}")
            break


if __name__ == "__main__":
    part_one()
    part_two()
    part_three()
