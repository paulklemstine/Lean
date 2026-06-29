"""
A Conserved-Quantity View of Cryptographic Reductions — Numerical Demonstrations
================================================================================

This self-contained script demonstrates, with concrete numbers, the nine results
of the package:

Quantitative conservation laws of the *advantage* coordinate
  1. advantage_triangle        |a - c| <= |a - b| + |b - c|
  2. hybrid_argument           |d0 - dn| <= sum_i |d_i - d_{i+1}|
  3. hybrid_averaging          total gap >= eps  =>  some step >= eps / n
  4. reduction_composition     advC <= (l2 * l1) * advA
  5. prg_stretch_amplification per-step gap <= eps over n hybrids => <= n * eps

Structural conservation law (rank invariant) of the construction calculus
  6. cryptoImplies_rank_mono   CryptoImplies X Y  =>  rank X <= rank Y
  7. enc_not_implies_owf       not CryptoImplies ENC OWF
  8. prf_not_implies_prg       not CryptoImplies PRF PRG
  9. owf_implies_enc           CryptoImplies OWF ENC

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import IntEnum
from typing import Callable, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. Triangle inequality for the advantage coordinate
# ---------------------------------------------------------------------------
def advantage_triangle_gap(a: float, b: float, c: float) -> float:
    """Return slack of |a-c| <= |a-b| + |b-c|; non-negative iff the law holds."""
    return (abs(a - b) + abs(b - c)) - abs(a - c)


# ---------------------------------------------------------------------------
# 2. Hybrid argument: end-to-end advantage <= sum of per-step advantages
# ---------------------------------------------------------------------------
def per_step_advantages(d: Sequence[float]) -> List[float]:
    """|d_i - d_{i+1}| for i = 0 .. n-1 where n = len(d) - 1."""
    return [abs(d[i] - d[i + 1]) for i in range(len(d) - 1)]


def hybrid_argument_bound(d: Sequence[float]) -> Tuple[float, float]:
    """Return (end_to_end_advantage, telescoping_upper_bound)."""
    n = len(d) - 1
    end_to_end = abs(d[0] - d[n])
    bound = sum(per_step_advantages(d))
    return end_to_end, bound


# ---------------------------------------------------------------------------
# 3. Hybrid averaging (pigeonhole extraction); requires n > 0
# ---------------------------------------------------------------------------
def hybrid_averaging(a: Sequence[float], eps: float) -> Optional[int]:
    """
    If sum(a) >= eps and n = len(a) > 0, return an index i with a[i] >= eps/n.
    Returns the argmax, which provably satisfies the bound. None if n == 0.
    """
    n = len(a)
    if n == 0:
        return None
    i_star = max(range(n), key=lambda i: a[i])
    assert a[i_star] >= eps / n - 1e-12, "averaging guarantee violated"
    return i_star


# ---------------------------------------------------------------------------
# 4. Reduction composition: losses multiply
# ---------------------------------------------------------------------------
def reduction_composition(adv_a: float, l1: float, l2: float) -> Tuple[float, float]:
    """
    Given advB <= l1*advA and advC <= l2*advB (l2 >= 0), return
    (worst_case_advC, composed_bound) where composed_bound = (l2*l1)*advA.
    """
    assert l2 >= 0.0, "l2 must be non-negative to preserve the inequality"
    adv_b = l1 * adv_a
    adv_c = l2 * adv_b
    composed = (l2 * l1) * adv_a
    return adv_c, composed


# ---------------------------------------------------------------------------
# 5. PRG-stretch amplification: uniform per-step eps over n hybrids -> n*eps
# ---------------------------------------------------------------------------
def prg_stretch_amplification(eps: float, n: int) -> float:
    """End-to-end advantage upper bound for n hybrids each costing <= eps."""
    return n * eps


def simulate_stretch_chain(eps: float, n: int, seed: float = 0.5) -> Tuple[float, float]:
    """
    Build a concrete chain d_0..d_n with |d_i - d_{i+1}| <= eps (alternating
    sign) and confirm |d_0 - d_n| <= n*eps.
    """
    d = [seed]
    sign = 1.0
    for _ in range(n):
        d.append(d[-1] + sign * eps)
        sign = -sign
    realized = abs(d[0] - d[n])
    return realized, prg_stretch_amplification(eps, n)


# ---------------------------------------------------------------------------
# 6-9. The primitive tower, rank invariant, and black-box separations
# ---------------------------------------------------------------------------
class Primitive(IntEnum):
    OWF = 0  # one-way function
    PRG = 1  # pseudorandom generator
    PRF = 2  # pseudorandom function
    ENC = 3  # IND-CPA encryption


def rank(p: Primitive) -> int:
    """The conserved scalar: rank increases by one along each upgrade."""
    return int(p)


# The three classical upgrade constructors (each climbs exactly one rung).
UPGRADES: List[Tuple[Primitive, Primitive]] = [
    (Primitive.OWF, Primitive.PRG),  # HILL
    (Primitive.PRG, Primitive.PRF),  # GGM
    (Primitive.PRF, Primitive.ENC),  # encryption from PRF
]


def crypto_implies(x: Primitive, y: Primitive) -> bool:
    """
    Decide CryptoImplies x y for the calculus generated by refl, trans, and the
    three upgrades. Reachability via BFS over the upgrade edges (refl = x == y).
    """
    if x == y:  # reflexivity
        return True
    frontier = [x]
    seen = {x}
    while frontier:
        cur = frontier.pop()
        for src, dst in UPGRADES:  # transitivity along upgrade edges
            if src == cur and dst not in seen:
                if dst == y:
                    return True
                seen.add(dst)
                frontier.append(dst)
    return False


def crypto_implies_rank_mono(x: Primitive, y: Primitive) -> bool:
    """Verify the invariant: CryptoImplies x y  =>  rank x <= rank y."""
    if crypto_implies(x, y):
        return rank(x) <= rank(y)
    return True  # vacuously holds when no derivation exists


# ---------------------------------------------------------------------------
# Demonstration driver
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 72)
    print("A Conserved-Quantity View of Cryptographic Reductions — demo")
    print("=" * 72)

    # 1. Triangle inequality ------------------------------------------------
    print("\n[1] advantage_triangle: |a-c| <= |a-b| + |b-c|")
    for a, b, c in [(0.5, 0.5, 0.5), (0.9, 0.4, 0.1), (-0.3, 0.7, 0.2)]:
        slack = advantage_triangle_gap(a, b, c)
        print(f"    a={a:+.2f} b={b:+.2f} c={c:+.2f}  slack={slack:+.4f}  "
              f"{'OK' if slack >= -1e-12 else 'FAIL'}")

    # 2. Hybrid argument ----------------------------------------------------
    print("\n[2] hybrid_argument: |d0 - dn| <= sum of per-step advantages")
    d = [0.50, 0.52, 0.49, 0.55, 0.60]
    e2e, bound = hybrid_argument_bound(d)
    print(f"    chain d = {d}")
    print(f"    per-step      = {[round(x, 3) for x in per_step_advantages(d)]}")
    print(f"    end-to-end    = {e2e:.4f}")
    print(f"    telescope sum = {bound:.4f}   ({'OK' if e2e <= bound + 1e-12 else 'FAIL'})")

    # 3. Hybrid averaging ---------------------------------------------------
    print("\n[3] hybrid_averaging: total gap >= eps forces one step >= eps/n")
    a = [0.01, 0.02, 0.30, 0.05]  # one heavy step
    eps = sum(a)
    i_star = hybrid_averaging(a, eps)
    n = len(a)
    print(f"    a = {a},  eps = sum = {eps:.3f},  eps/n = {eps/n:.4f}")
    print(f"    extracted index i* = {i_star}, a[i*] = {a[i_star]:.3f} "
          f"(>= eps/n)  {'OK' if a[i_star] >= eps/n - 1e-12 else 'FAIL'}")

    # 4. Reduction composition ---------------------------------------------
    print("\n[4] reduction_composition: advC <= (l2*l1)*advA")
    adv_a, l1, l2 = 1e-3, 4.0, 2.5
    adv_c, composed = reduction_composition(adv_a, l1, l2)
    print(f"    advA={adv_a:.1e}, l1={l1}, l2={l2}")
    print(f"    advC={adv_c:.3e}  composed bound (l2*l1)*advA={composed:.3e}  "
          f"{'OK' if adv_c <= composed + 1e-18 else 'FAIL'}")

    # 5. PRG-stretch amplification -----------------------------------------
    print("\n[5] prg_stretch_amplification: per-step eps over n hybrids -> n*eps")
    eps, n = 2.0 ** -20, 64
    realized, bound = simulate_stretch_chain(eps, n)
    print(f"    eps=2^-20, n={n} hybrids")
    print(f"    realized |d0-dn|={realized:.3e}  bound n*eps={bound:.3e}  "
          f"{'OK' if realized <= bound + 1e-18 else 'FAIL'}")

    # 6. Rank invariant -----------------------------------------------------
    print("\n[6] cryptoImplies_rank_mono: every derivation preserves rank order")
    all_ok = all(
        crypto_implies_rank_mono(x, y)
        for x in Primitive for y in Primitive
    )
    print(f"    checked all {len(Primitive)**2} ordered pairs: "
          f"{'INVARIANT HOLDS' if all_ok else 'VIOLATION'}")

    # 7-8. Separations ------------------------------------------------------
    print("\n[7] enc_not_implies_owf:", not crypto_implies(Primitive.ENC, Primitive.OWF),
          f"(rank ENC={rank(Primitive.ENC)} > rank OWF={rank(Primitive.OWF)})")
    print("[8] prf_not_implies_prg:", not crypto_implies(Primitive.PRF, Primitive.PRG),
          f"(rank PRF={rank(Primitive.PRF)} > rank PRG={rank(Primitive.PRG)})")

    # 9. Non-triviality -----------------------------------------------------
    print("[9] owf_implies_enc:", crypto_implies(Primitive.OWF, Primitive.ENC),
          "(OWF -> PRG -> PRF -> ENC)")

    print("\n" + "=" * 72)
    print("All nine results demonstrated numerically.")
    print("=" * 72)


if __name__ == "__main__":
    main()
