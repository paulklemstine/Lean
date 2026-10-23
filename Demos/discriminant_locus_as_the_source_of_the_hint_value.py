#!/usr/bin/env python3
"""
Branch value and conic value: numerical companion.

A *battery* over the residue ring Z/q (q odd) is a finite population Omega, uniformly
weighted, together with two factor residues P(x), Q(x) and a label L(x) per individual.

    residue view   rho(x) = (s, d) = (P + Q, Q - P)
    branch view    beta(x) = (s, d^2)           (the double cover (s,d) -> (s,d^2))
    product view   N(x) = P * Q = (s^2 - d^2)/4

    hint value     HV = I(L; rho) - I(L; N)      (bits)
    branch value   B  = I(L; rho) - I(L; beta)
    conic value    C  = I(L; beta) - I(L; N)

The script checks, numerically, every result of the accompanying paper:
  * HV = B + C with B, C >= 0;
  * swap-invariant labels have B = 0, hence HV = C = I(L; s,N) - I(L; N);
  * B <= 1 bit, and B <= (mass off d = 0 whose mirror (s,-d) is populated);
  * the three two-individual examples mod 5 (counterexample and sharpness);
  * the uniform-battery law B = (q-1)/q for L = d (a conjecture in the paper's outlook,
    shown here only numerically).

Pure standard library; no third-party packages.
"""
from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Hashable, List, Sequence, Tuple

Individual = Tuple[int, int]          # (P, Q) residues
Battery = List[Individual]
Labels = List[Hashable]


# ----------------------------------------------------------------------------------
# Entropy calculus on a uniformly weighted finite population
# ----------------------------------------------------------------------------------
def entropy_bits(values: Sequence[Hashable]) -> float:
    """Shannon entropy (bits) of the empirical distribution of `values`."""
    n = len(values)
    if n == 0:
        return 0.0
    return -sum((c / n) * math.log2(c / n) for c in Counter(values).values())


def mutual_info_bits(labels: Sequence[Hashable], view: Sequence[Hashable]) -> float:
    """I(L; f) = H(L) + H(f) - H(L, f), in bits."""
    return (entropy_bits(labels) + entropy_bits(view)
            - entropy_bits(list(zip(labels, view))))


# ----------------------------------------------------------------------------------
# Views of a battery
# ----------------------------------------------------------------------------------
def residue_view(bat: Battery, q: int) -> List[Tuple[int, int]]:
    return [((p + r) % q, (r - p) % q) for p, r in bat]


def branch_view(bat: Battery, q: int) -> List[Tuple[int, int]]:
    return [(s, (d * d) % q) for s, d in residue_view(bat, q)]


def product_view(bat: Battery, q: int) -> List[int]:
    return [(p * r) % q for p, r in bat]


def sum_product_view(bat: Battery, q: int) -> List[Tuple[int, int]]:
    return [((p + r) % q, (p * r) % q) for p, r in bat]


def decompose(labels: Labels, bat: Battery, q: int) -> Tuple[float, float, float]:
    """Return (hint value, branch value, conic value) in bits."""
    i_rho = mutual_info_bits(labels, residue_view(bat, q))
    i_beta = mutual_info_bits(labels, branch_view(bat, q))
    i_n = mutual_info_bits(labels, product_view(bat, q))
    def clean(v: float) -> float:
        return 0.0 if abs(v) < 1e-12 else v
    return clean(i_rho - i_n), clean(i_rho - i_beta), clean(i_beta - i_n)


def ramified_hint_value(labels: Labels, bat: Battery, q: int) -> float:
    """Hint value of the battery restricted to the ramification locus d = 0."""
    idx = [i for i, (s, d) in enumerate(residue_view(bat, q)) if d == 0]
    sub = [bat[i] for i in idx]
    lab = [labels[i] for i in idx]
    return decompose(lab, sub, q)[0] if sub else 0.0


def is_swap_invariant(labels: Labels, bat: Battery, q: int) -> bool:
    """L x = L y whenever s(x) = s(y) and d(y) = -d(x)."""
    rho = residue_view(bat, q)
    n = len(bat)
    return all(labels[i] == labels[j]
               for i in range(n) for j in range(n)
               if rho[i][0] == rho[j][0] and rho[j][1] == (-rho[i][1]) % q)


def split_fraction(bat: Battery, q: int) -> float:
    """Fraction of individuals off d = 0 whose mirror (s, -d) is populated."""
    rho = residue_view(bat, q)
    present = set(rho)
    hits = sum(1 for s, d in rho if d != 0 and (s, (-d) % q) in present)
    return hits / len(bat)


def symmetrize_labels(labels: Labels, bat: Battery, q: int) -> Labels:
    """Make labels swap-invariant: one label per fibre of the branch view."""
    beta = branch_view(bat, q)
    first: dict = {}
    for b, l in zip(beta, labels):
        first.setdefault(b, l)
    return [first[b] for b in beta]


# ----------------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------------
def show(name: str, labels: Labels, bat: Battery, q: int) -> None:
    hv, b, c = decompose(labels, bat, q)
    print(f"  {name}")
    print(f"    individuals (P,Q): {bat}   labels: {labels}")
    print(f"    residue view (s,d): {residue_view(bat, q)}")
    print(f"    branch view (s,d^2): {branch_view(bat, q)}   products N: {product_view(bat, q)}")
    print(f"    swap-invariant: {is_swap_invariant(labels, bat, q)}")
    print(f"    hint value = {hv:.4f}   branch = {b:.4f}   conic = {c:.4f}   "
          f"ramified hint value = {ramified_hint_value(labels, bat, q):.4f}")


def demo_examples() -> None:
    print("=" * 78)
    print("1. Three two-individual batteries over Z/5")
    print("=" * 78)
    show("Counterexample to the ramification conjecture",
         [0, 1], [(1, 2), (3, 4)], 5)
    print("    -> swap-invariant, no individual on d = 0, yet one full bit of hint value.\n")
    show("Pure branch information (the swapped pair)",
         [0, 1], [(1, 2), (2, 1)], 5)
    print("    -> branch value attains its maximum of one bit.\n")
    show("Ramified battery: all information is conic",
         [0, 1], [(1, 1), (4, 4)], 5)
    print("    -> on d = 0 the cover loses nothing; the bit is the sign of s, i.e. conic.\n")


def random_battery(q: int, n: int, n_labels: int, rng: random.Random) -> Tuple[Battery, Labels]:
    bat = [(rng.randrange(q), rng.randrange(q)) for _ in range(n)]
    labels: Labels = [rng.randrange(n_labels) for _ in range(n)]
    return bat, labels


def demo_random_checks(trials: int = 3000, seed: int = 2026) -> None:
    print("=" * 78)
    print("2. Random batteries: decomposition, positivity, swap invariance, bounds")
    print("=" * 78)
    rng = random.Random(seed)
    eps = 1e-9
    worst_gap = 0.0
    max_branch = 0.0
    tight = 0.0
    for _ in range(trials):
        q = rng.choice([3, 5, 7, 11])
        bat, lab = random_battery(q, rng.randint(1, 14), rng.randint(1, 4), rng)
        hv, b, c = decompose(lab, bat, q)
        assert abs(hv - (b + c)) < eps                      # HV = B + C
        assert b > -eps and c > -eps                        # both nonnegative
        assert b <= 1 + eps                                 # at most one bit
        frac = split_fraction(bat, q)
        assert b <= frac + eps                              # split-fraction bound
        assert hv <= 1 + c + eps
        sym = symmetrize_labels(lab, bat, q)
        assert is_swap_invariant(sym, bat, q)
        hv_s, b_s, c_s = decompose(sym, bat, q)
        assert abs(b_s) < eps                               # swap-invariant: B = 0
        i_sn = mutual_info_bits(sym, sum_product_view(bat, q))
        i_n = mutual_info_bits(sym, product_view(bat, q))
        assert abs(hv_s - (i_sn - i_n)) < eps               # HV = I(L;s,N) - I(L;N)
        worst_gap = max(worst_gap, abs(hv - b - c))
        max_branch = max(max_branch, b)
        tight = max(tight, b / frac if frac > 0 else 0.0)
    print(f"  {trials} random batteries checked, all assertions passed.")
    print(f"  max |HV - (B + C)|          = {worst_gap:.2e}")
    print(f"  largest branch value seen   = {max_branch:.4f} bits (bound: 1)")
    print(f"  largest B / split-fraction  = {tight:.4f} (bound: 1)\n")


def demo_uniform(qs: Sequence[int] = (3, 5, 7, 11, 13)) -> None:
    print("=" * 78)
    print("3. Uniform battery over Z/q (all q^2 pairs), labels L = d   [numerical only]")
    print("=" * 78)
    print(f"  {'q':>3} {'branch B':>10} {'(q-1)/q':>10} {'conic C':>10} {'hint HV':>10}")
    for q in qs:
        bat = [(p, r) for p in range(q) for r in range(q)]
        lab: Labels = [d for _, d in residue_view(bat, q)]
        hv, b, c = decompose(lab, bat, q)
        print(f"  {q:>3} {b:>10.4f} {(q - 1) / q:>10.4f} {c:>10.4f} {hv:>10.4f}")
    print()
    print("  Labels L = s on the uniform battery are swap-invariant, so B = 0 and HV = C:")
    print(f"  {'q':>3} {'branch B':>10} {'conic C':>10} {'log2 q':>10}")
    for q in qs:
        bat = [(p, r) for p in range(q) for r in range(q)]
        lab = [s for s, _ in residue_view(bat, q)]
        hv, b, c = decompose(lab, bat, q)
        print(f"  {q:>3} {b:>10.4f} {c:>10.4f} {math.log2(q):>10.4f}")
    print()
    print("  Labels L = chi(d) (quadratic character of the gap, chi(0) = 0):")
    print(f"  {'q':>3} {'q mod 4':>8} {'swap-inv':>9} {'branch B':>10} {'(q-1)/q':>10}")
    for q in qs:
        bat = [(p, r) for p in range(q) for r in range(q)]
        squares = {(x * x) % q for x in range(1, q)}
        lab = [0 if d == 0 else (1 if d in squares else -1) for _, d in residue_view(bat, q)]
        hv, b, c = decompose(lab, bat, q)
        print(f"  {q:>3} {q % 4:>8} {str(is_swap_invariant(lab, bat, q)):>9} "
              f"{b:>10.4f} {(q - 1) / q:>10.4f}")
    print()


def demo_cover_geometry(q: int = 7) -> None:
    print("=" * 78)
    print(f"4. Geometry of the double cover over Z/{q}")
    print("=" * 78)
    pts = [(s, d) for s in range(q) for d in range(q)]
    fibres: dict = {}
    for s, d in pts:
        fibres.setdefault((s, d * d % q), []).append((s, d))
    sizes = Counter(len(v) for v in fibres.values())
    print(f"  fibre sizes of (s,d) -> (s,d^2): {dict(sizes)}  "
          f"(size 1 exactly on d = 0: {all((len(v) == 1) == (k[1] == 0) for k, v in fibres.items())})")
    for (s, d) in pts:                                   # N is swap invariant
        n1 = (s * s - d * d) * pow(4, -1, q) % q
        n2 = (s * s - (q - d) ** 2) * pow(4, -1, q) % q
        assert n1 == n2
    conic = Counter(((s * s - d * d) * pow(4, -1, q)) % q for s, d in pts)
    print(f"  fibres of the product map (s,d) -> N have sizes {sorted(set(conic.values()))}:")
    print("  conics s^2 - d^2 = 4N of size about q -- far more than the 2 points of a cover fibre.\n")


if __name__ == "__main__":
    demo_examples()
    demo_random_checks()
    demo_uniform()
    demo_cover_geometry()
