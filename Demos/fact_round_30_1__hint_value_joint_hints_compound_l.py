#!/usr/bin/env python3
"""
Hints compound by one orientation bit per field -- numerical companion.

Everything here is exact finite arithmetic on small "batteries":
a battery is a finite population of samples x, each carrying
  * a label T(x) (the secret we want to learn),
  * two factor residues p(x), q(x) in a ring R = Z/p1 x ... x Z/pk.
From (p, q) we form the four views
  N = p*q (product),  s = p+q (sum),  d = q-p (gap),  (s, d) (joint).
Information is the plug-in mutual information of the uniform population, in bits.

Hints are *conditional*:
  sumHint   = I(T; N, s) - I(T; N)
  gapHint   = I(T; N, d) - I(T; N)
  hintValue = I(T; s, d) - I(T; N)
  synergy   = hintValue - sumHint - gapHint

The demo reproduces:
  1. the redundant battery mod 5 (synergy -1),
  2. the compounding battery mod 7 (synergy +1, the one-bit ceiling),
  3. the two-field battery over Z/7 x Z/7 (synergy +2, the two-bit ceiling),
  4. a random search over single-prime batteries (synergy never exceeds 1),
  5. the orientation-cell census: a cell (N, s) hosts two factorisations
     iff its discriminant s^2 - 4N is a nonzero quadratic residue.
"""
from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Hashable, Sequence, Tuple

Residue = Tuple[int, ...]          # an element of Z/p1 x ... x Z/pk
Sample = Tuple[Hashable, Residue, Residue]  # (label, p, q)


# ---------------------------------------------------------------- ring arithmetic
def r_add(a: Residue, b: Residue, mods: Sequence[int]) -> Residue:
    return tuple((x + y) % m for x, y, m in zip(a, b, mods))


def r_sub(a: Residue, b: Residue, mods: Sequence[int]) -> Residue:
    return tuple((x - y) % m for x, y, m in zip(a, b, mods))


def r_mul(a: Residue, b: Residue, mods: Sequence[int]) -> Residue:
    return tuple((x * y) % m for x, y, m in zip(a, b, mods))


# ---------------------------------------------------------------- plug-in information
def entropy_bits(values: Sequence[Hashable]) -> float:
    """Empirical Shannon entropy (bits) of a list under the uniform population."""
    n = len(values)
    return -sum(c / n * math.log2(c / n) for c in Counter(values).values())


def mutual_info_bits(labels: Sequence[Hashable], view: Sequence[Hashable]) -> float:
    """I(T; V) = H(T) + H(V) - H(T, V), all plug-in, in bits."""
    return entropy_bits(labels) + entropy_bits(view) - entropy_bits(list(zip(labels, view)))


def routing_table(battery: Sequence[Sample], mods: Sequence[int]) -> dict[str, float]:
    """Exact routing table of a battery: the four views and the three hints."""
    T = [t for t, _, _ in battery]
    N = [r_mul(p, q, mods) for _, p, q in battery]
    S = [r_add(p, q, mods) for _, p, q in battery]
    D = [r_sub(q, p, mods) for _, p, q in battery]
    i_N = mutual_info_bits(T, N)
    i_Ns = mutual_info_bits(T, list(zip(N, S)))
    i_Nd = mutual_info_bits(T, list(zip(N, D)))
    i_sd = mutual_info_bits(T, list(zip(S, D)))
    sum_hint, gap_hint, hint_value = i_Ns - i_N, i_Nd - i_N, i_sd - i_N
    return {
        "H(T)": entropy_bits(T),
        "I(T;N)": i_N, "I(T;N,s)": i_Ns, "I(T;N,d)": i_Nd, "I(T;s,d)": i_sd,
        "sumHint": sum_hint, "gapHint": gap_hint, "hintValue": hint_value,
        "synergy": hint_value - sum_hint - gap_hint,
    }


def show(name: str, table: dict[str, float]) -> None:
    print(f"\n{name}")
    for k, v in table.items():
        print(f"   {k:<10s} = {v:+.6f}")


# ---------------------------------------------------------------- the witnesses
def redundant_battery() -> Tuple[list[Sample], list[int]]:
    """Two samples on the hyperbola pq = 1 mod 5: (1,1) and (2,3), labels 0 and 1."""
    return [(0, (1,), (1,)), (1, (2,), (3,))], [5]


def compound_battery() -> Tuple[list[Sample], list[int]]:
    """Four samples on pq = 1 mod 7; the label is the orientation (which factor is which)."""
    pts = [((2,), (4,)), ((4,), (2,)), ((3,), (5,)), ((5,), (3,))]
    labels = [0, 1, 1, 0]
    return [(t, p, q) for t, (p, q) in zip(labels, pts)], [7]


def two_field_battery() -> Tuple[list[Sample], list[int]]:
    """The 16-sample product of two copies of the mod-7 battery over Z/7 x Z/7."""
    base, _ = compound_battery()
    bat: list[Sample] = []
    for t1, p1, q1 in base:
        for t2, p2, q2 in base:
            bat.append((2 * t1 + t2, (p1[0], p2[0]), (q1[0], q2[0])))
    return bat, [7, 7]


# ---------------------------------------------------------------- random search
def random_battery(p: int, n: int, n_labels: int, rng: random.Random) -> list[Sample]:
    return [(rng.randrange(n_labels), (rng.randrange(p),), (rng.randrange(p),)) for _ in range(n)]


def random_search(trials: int, seed: int = 101) -> Tuple[float, float]:
    """Max / min synergy over random single-prime batteries (never exceeds +1)."""
    rng = random.Random(seed)
    hi, lo = -math.inf, math.inf
    for _ in range(trials):
        p = rng.choice([5, 7, 11, 13])
        bat = random_battery(p, rng.randint(4, 12), rng.randint(2, 6), rng)
        syn = routing_table(bat, [p])["synergy"]
        hi, lo = max(hi, syn), min(lo, syn)
    return hi, lo


# ---------------------------------------------------------------- orientation cells
def legendre(a: int, p: int) -> int:
    """Legendre symbol via Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def factorisations(N: int, s: int, p: int) -> list[Tuple[int, int]]:
    """All ordered pairs (a, b) mod p with a*b = N and a+b = s."""
    return [(a, (s - a) % p) for a in range(p) if a * (s - a) % p == N % p]


def cell_census(p: int) -> Counter:
    """Check the Legendre law on every cell (N, s) of Z/p and count cell types."""
    census: Counter = Counter()
    for N in range(p):
        for s in range(p):
            disc = (s * s - 4 * N) % p
            chi = legendre(disc, p)
            k = len(factorisations(N, s, p))
            assert k == 1 + chi, (N, s, disc, k)   # 2 roots / 1 root / 0 roots
            census[{1: "residue (2 factorisations)", 0: "zero (1 factorisation)",
                    -1: "non-residue (0)"}[chi]] += 1
    return census


def sign_selector(a: int, p: int) -> bool:
    """The lower-half sign selector of Z/p: separates a and -a for a != 0."""
    return 2 * (a % p) < p


def check_selector(p: int) -> bool:
    return all(
        not (a * a % p == b * b % p and sign_selector(a, p) == sign_selector(b, p)) or a == b
        for a in range(p) for b in range(p)
    )


# ---------------------------------------------------------------- main
def main() -> None:
    print("=" * 66)
    print(" HINTS COMPOUND BY ONE ORIENTATION BIT PER FIELD")
    print("=" * 66)

    for name, (bat, mods) in [
        ("[1] Redundant battery mod 5 (synergy should be -1)", redundant_battery()),
        ("[2] Compounding battery mod 7 (synergy should be +1)", compound_battery()),
        ("[3] Two-field battery over Z/7 x Z/7 (synergy should be +2)", two_field_battery()),
    ]:
        show(name, routing_table(bat, mods))

    hi, lo = random_search(20_000)
    print(f"\n[4] Random single-prime batteries (20 000 trials, p in 5,7,11,13):")
    print(f"   max synergy = {hi:+.6f}  (theorem: <= 1)")
    print(f"   min synergy = {lo:+.6f}")

    print("\n[5] Orientation-cell census (Legendre law checked on every cell):")
    for p in [5, 7, 11, 13]:
        c = cell_census(p)
        print(f"   p = {p:2d}: " + ", ".join(f"{k}: {v}" for k, v in sorted(c.items())))
    print("   cell (N,s) = (1,6) mod 7: disc =", (36 - 4) % 7,
          "factorisations =", factorisations(1, 6, 7))
    print("   cell (N,s) = (1,0) mod 7: disc =", (0 - 4) % 7,
          "factorisations =", factorisations(1, 0, 7))

    print("\n[6] Sign selector 'lower half' separates square roots:",
          all(check_selector(p) for p in [3, 5, 7, 11, 13, 17]))
    print("    ... but fails on Z/9 (0, 3, 6 all square to 0):",
          [d for d in range(9) if d * d % 9 == 0])

    print("\n[7] The reported round-30 figures (empirical, 2-field CRT modulus):")
    prod, sd = 2.1314, 4.5605
    print(f"   joint hint value = {sd:.4f} - {prod:.4f} = {sd - prod:+.4f} bits")
    print("   a synergy of +1.40 bits is impossible over one prime field (ceiling 1)")
    print("   and compatible with two fields (ceiling 2).")


if __name__ == "__main__":
    main()
