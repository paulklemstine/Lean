"""Numerical demonstrations of the multilateral cross-intersecting product bound.

This script exercises the main theorem

    prod_{i=1}^{r} |F_i|  <=  g(n,k)^r,   g(n,k) = C(n,k) - C(n-k,k),

for r >= 2 non-empty, k-uniform, pairwise cross-intersecting families of
k-subsets of an n-element ground set. It also illustrates the per-family pinning
bound |F_i| <= g(n,k), the bilateral r=2 corollary, and the gap between the
proven base g(n,k) and the conjectured sharp Hilton-Milner base
h(n,k) = C(n-1,k-1) - C(n-k-1,k-1) + 1.

All functions are self-contained and type-hinted.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import FrozenSet, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Core counts (mirroring the Lean definitions `g` and `hm`)
# ---------------------------------------------------------------------------

def fixed_set_meeting_count(n: int, k: int) -> int:
    """g(n,k) = C(n,k) - C(n-k,k): number of k-subsets of [n] meeting a fixed k-set."""
    if n < k:
        return 0
    return comb(n, k) - comb(n - k, k)


def hilton_milner_value(n: int, k: int) -> int:
    """h(n,k) = C(n-1,k-1) - C(n-k-1,k-1) + 1: the conjectured sharp base."""
    return comb(n - 1, k - 1) - comb(n - k - 1, k - 1) + 1


def multilateral_product_ceiling(n: int, k: int, r: int) -> int:
    """Right-hand side of the main theorem: g(n,k)^r."""
    return fixed_set_meeting_count(n, k) ** r


# ---------------------------------------------------------------------------
# Explicit family machinery for empirical verification
# ---------------------------------------------------------------------------

Subset = FrozenSet[int]
Family = List[Subset]


def all_k_subsets(n: int, k: int) -> List[Subset]:
    """All k-subsets of the ground set {0, ..., n-1}."""
    return [frozenset(c) for c in combinations(range(n), k)]


def is_uniform(family: Family, k: int) -> bool:
    """Every member has exactly k elements."""
    return all(len(a) == k for a in family)


def is_star(family: Family) -> bool:
    """Some fixed point lies in every member."""
    if not family:
        return True
    common = set.intersection(*(set(a) for a in family))
    return len(common) > 0


def is_non_trivial(family: Family) -> bool:
    """Not contained in any star (for every point some member avoids it)."""
    return not is_star(family)


def cross_intersecting(f: Family, g: Family) -> bool:
    """Every member of f meets every member of g."""
    return all(len(a & b) > 0 for a in f for b in g)


def k_subsets_meeting(a0: Subset, n: int, k: int) -> Family:
    """All k-subsets of [n] that intersect the fixed k-set a0 (realizes g(n,k))."""
    return [b for b in all_k_subsets(n, k) if len(a0 & b) > 0]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_per_family_bound(n: int, k: int) -> None:
    """Check Lemma card_le_of_cross: |{B : B meets A0}| = g(n,k) exactly."""
    print(f"[Per-family pinning bound]  n={n}, k={k}")
    a0 = frozenset(range(k))  # a fixed k-set
    meeting = k_subsets_meeting(a0, n, k)
    g = fixed_set_meeting_count(n, k)
    print(f"  fixed k-set A0 = {sorted(a0)}")
    print(f"  # k-subsets meeting A0 (counted)  = {len(meeting)}")
    print(f"  g(n,k) = C(n,k) - C(n-k,k)        = {g}")
    assert len(meeting) == g, "per-family count must equal g(n,k)"
    print("  OK: every family pinned by A0 has size <= g(n,k).\n")


def build_pairwise_cross_families(n: int, k: int, r: int) -> List[Family]:
    """Build r pairwise cross-intersecting k-uniform families, all equal to the
    star through point 0 (a simple but valid witness satisfying all hypotheses)."""
    star = [s for s in all_k_subsets(n, k) if 0 in s]
    return [list(star) for _ in range(r)]


def demo_multilateral_bound(n: int, k: int, r: int) -> None:
    """Check the main theorem prod |F_i| <= g(n,k)^r on explicit families."""
    print(f"[Multilateral product bound]  n={n}, k={k}, r={r}")
    families = build_pairwise_cross_families(n, k, r)
    # verify hypotheses
    assert all(is_uniform(f, k) for f in families), "uniformity"
    assert all(len(f) > 0 for f in families), "non-emptiness"
    for i in range(r):
        for j in range(r):
            if i != j:
                assert cross_intersecting(families[i], families[j]), "cross-intersecting"
    product = 1
    for f in families:
        product *= len(f)
    ceiling = multilateral_product_ceiling(n, k, r)
    print(f"  realized product  prod |F_i| = {product}")
    print(f"  theorem ceiling   g(n,k)^r   = {ceiling}")
    assert product <= ceiling, "MAIN THEOREM violated!"
    print("  OK: prod |F_i| <= g(n,k)^r.\n")


def demo_bilateral_bound(n: int, k: int) -> None:
    """Check the r=2 corollary |F|*|G| <= g(n,k)^2."""
    print(f"[Bilateral (Pyber-type) bound]  n={n}, k={k}")
    star = [s for s in all_k_subsets(n, k) if 0 in s]
    f, g_fam = list(star), list(star)
    assert cross_intersecting(f, g_fam)
    lhs = len(f) * len(g_fam)
    rhs = fixed_set_meeting_count(n, k) ** 2
    print(f"  |F|*|G| = {lhs},   g(n,k)^2 = {rhs}")
    assert lhs <= rhs
    print("  OK: |F|*|G| <= g(n,k)^2.\n")


def demo_gap_g_vs_h(triples: Sequence[Tuple[int, int]]) -> None:
    """Tabulate the proven base g(n,k) against the conjectured sharp base h(n,k)."""
    print("[Gap: proven g(n,k) vs conjectured Hilton-Milner h(n,k)]")
    print(f"  {'n':>3} {'k':>3} {'g(n,k)':>8} {'h(n,k)':>8} {'g/h':>7}")
    for n, k in triples:
        g = fixed_set_meeting_count(n, k)
        h = hilton_milner_value(n, k)
        ratio = g / h if h else float("inf")
        print(f"  {n:>3} {k:>3} {g:>8} {h:>8} {ratio:>7.3f}")
    print()


def main() -> None:
    print("=" * 64)
    print("Multilateral cross-intersecting product bound — numerical demo")
    print("=" * 64, "\n")

    demo_per_family_bound(n=6, k=3)
    demo_multilateral_bound(n=6, k=3, r=3)
    demo_bilateral_bound(n=6, k=3)
    demo_gap_g_vs_h([(6, 3), (7, 3), (8, 3), (8, 4), (10, 4), (10, 5)])

    # headline numerical anchor from the paper
    print("Headline (n=6, k=3): g=19, h=10; for r=3, 19^3=6859 vs 10^3=1000.")


if __name__ == "__main__":
    main()
