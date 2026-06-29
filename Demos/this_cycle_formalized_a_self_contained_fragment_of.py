"""
Byzantine Certificates: A Cohomological Framework for Distributed Consensus
===========================================================================

Self-contained numerical demonstrations of the main results.

Core idea
---------
Model a distributed system by a finite group ``G`` of participant relationships
acting on an abelian "value" module ``A``. A *disagreement pattern* is a function
``f : G -> A``. It is a **cocycle** (coherent) when

    f(g*h) = f(g) + g . f(h)        for all g, h in G,

and a **coboundary** (resolvable) when there is a single global value ``a`` with

    f(g) = g . a - a                for all g in G.

Consensus is achievable  <=>  the pattern is a coboundary.
The obstruction lives in the first cohomology group H^1(G, A).

Every function below is inlined; the script depends only on the standard library.
Run ``python demo.py`` to print all demonstrations.
"""

from __future__ import annotations

from itertools import product
from math import log2, ceil
from typing import Callable, Dict, List, Tuple, Optional


# ---------------------------------------------------------------------------
# A concrete finite group + module to make everything computable.
#
# We use G = Z/m (cyclic group, elements 0..m-1, op = addition mod m)
# acting on A = Z/q (integers mod q) by a fixed automorphism: g . a = (s^g * a) mod q
# where s is a unit mod q. (s = 1 gives the trivial action.)
# ---------------------------------------------------------------------------

class CyclicAction:
    """G = Z/m acting on A = Z/q by g . a = (s**g * a) mod q."""

    def __init__(self, m: int, q: int, s: int = 1) -> None:
        self.m: int = m
        self.q: int = q
        self.s: int = s % q

    def elements(self) -> List[int]:
        return list(range(self.m))

    def op(self, g: int, h: int) -> int:
        return (g + h) % self.m

    def inv(self, g: int) -> int:
        return (-g) % self.m

    def act(self, g: int, a: int) -> int:
        return (pow(self.s, g, self.q) * a) % self.q

    def coboundary(self, a: int) -> Callable[[int], int]:
        """delta(a)(g) = g . a - a."""
        return lambda g: (self.act(g, a) - a) % self.q


# ---------------------------------------------------------------------------
# Verification procedures (Theorems 3.1-3.3, 5.9).
# ---------------------------------------------------------------------------

def is_cocycle(act: CyclicAction, f: Callable[[int], int]) -> bool:
    """O(|G|^2): check f(g*h) = f(g) + g.f(h) for all pairs."""
    for g, h in product(act.elements(), act.elements()):
        lhs = f(act.op(g, h)) % act.q
        rhs = (f(g) + act.act(g, f(h))) % act.q
        if lhs != rhs:
            return False
    return True


def is_coboundary_of(act: CyclicAction, f: Callable[[int], int], a: int) -> bool:
    """O(|G|): check f(g) = g.a - a for all g (Theorem 3.1)."""
    delta = act.coboundary(a)
    return all(f(g) % act.q == delta(g) % act.q for g in act.elements())


def find_consensus_value(act: CyclicAction,
                         f: Callable[[int], int]) -> Optional[int]:
    """Search A for a witness a with f = delta(a). Returns a or None.

    None  <=>  the class of f in H^1(G, A) is nonzero (irreducible obstruction).
    """
    for a in range(act.q):
        if is_coboundary_of(act, f, a):
            return a
    return None


def cocycle_check_pairs(card_G: int) -> int:
    """Theorem 3.3: number of (g,h) pairs to verify the cocycle condition."""
    return card_G * card_G  # = |G x G| = |G|^2


# ---------------------------------------------------------------------------
# Byzantine bound and composition (Theorems 4.1-4.5).
# ---------------------------------------------------------------------------

def byzantine_feasible(n: int, f: int) -> bool:
    """Classical bound: consensus achievable iff 3f + 1 <= n."""
    return 3 * f + 1 <= n


def honest_supermajority(n: int, f: int) -> bool:
    """Equivalent form (Theorem 4.1): n - f >= 2f + 1."""
    return n - f >= 2 * f + 1


def sequential_tolerance(n: int, f1: int, f2: int) -> int:
    """Theorem 4.3: composite tolerates min(f1, f2)."""
    assert byzantine_feasible(n, f1) and byzantine_feasible(n, f2)
    return min(f1, f2)


def round_lower_bound(n: int) -> int:
    """Theorem 4.5: at least ceil(log2 n) rounds (>= 1 for n >= 2)."""
    return max(1, ceil(log2(n))) if n >= 2 else 0


# ---------------------------------------------------------------------------
# Cross-domain bounds (Theorems 6.1-6.8).
# ---------------------------------------------------------------------------

def post_quantum_dimension_ok(n: int, security_bits: int) -> bool:
    """Theorem 6.1: post-quantum requires n >= 256 and security_bits <= n."""
    return n >= 256 and security_bits <= n


def certified_radius(eps: float, lipschitz_L: float) -> float:
    """Theorem 6.2: certified robustness radius eps / L (> 0 when both > 0)."""
    assert eps > 0 and lipschitz_L > 0
    return eps / lipschitz_L


def coboundary_norm_bound(norm_a: float) -> float:
    """Theorem 6.3: ||delta(a)|| <= 2 ||a|| under an isometric action."""
    return 2.0 * norm_a


def entropy_bound_bits(card_A: int) -> float:
    """Theorem 6.5: certificate size bounded by log2|A| bits."""
    return log2(card_A)


def averaging_factor(n: int) -> float:
    """Theorem 6.6: per-round contraction 1 - 1/n in (0,1) for n >= 2."""
    return 1.0 - 1.0 / n


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_consensus_achievable() -> None:
    print("=" * 70)
    print("DEMO 1: A coboundary IS achievable consensus")
    print("=" * 70)
    act = CyclicAction(m=6, q=7, s=3)  # Z/6 acting on Z/7 via 3^g
    a_true = 4
    f = act.coboundary(a_true)         # f = delta(4) by construction
    print(f"Group G = Z/{act.m}, module A = Z/{act.q}, action s = {act.s}")
    print(f"Pattern f = delta({a_true}):  f(g) = {[f(g) for g in act.elements()]}")
    print(f"  is_cocycle(f)        = {is_cocycle(act, f)}")
    found = find_consensus_value(act, f)
    print(f"  recovered consensus  = {found}  (expected {a_true})")
    print(f"  -> H^1 class is ZERO; consensus certified.\n")


def demo_consensus_obstructed() -> None:
    print("=" * 70)
    print("DEMO 2: A cocycle that is NOT a coboundary (nonzero H^1 class)")
    print("=" * 70)
    # Trivial action (s=1): cocycles are homomorphisms Z/m -> Z/q.
    # f(g) = c*g (mod q) is a homomorphism; it is a coboundary only when c == 0
    # (since g.a - a = 0 under trivial action).
    act = CyclicAction(m=5, q=5, s=1)
    c = 2
    f = lambda g: (c * g) % act.q
    print(f"Group G = Z/{act.m}, module A = Z/{act.q}, TRIVIAL action (s=1)")
    print(f"Pattern f(g) = {c}*g:  {[f(g) for g in act.elements()]}")
    print(f"  is_cocycle(f)        = {is_cocycle(act, f)}  (it is a homomorphism)")
    found = find_consensus_value(act, f)
    print(f"  consensus value      = {found}")
    print(f"  -> No witness exists: H^1 class is NONZERO; consensus impossible.\n")


def demo_complexity() -> None:
    print("=" * 70)
    print("DEMO 3: Verification complexity (Theorems 3.1-3.3)")
    print("=" * 70)
    for m in (2, 4, 8, 16, 64):
        print(f"  |G| = {m:3d}:  coboundary check O(|G|) = {m:4d} ops, "
              f"cocycle check O(|G|^2) = {cocycle_check_pairs(m):6d} pairs")
    print()


def demo_byzantine_bound() -> None:
    print("=" * 70)
    print("DEMO 4: Byzantine bound 3f+1<=n  <=>  honest 2/3 supermajority")
    print("=" * 70)
    print(f"  {'n':>3} {'f':>3} {'3f+1<=n':>9} {'n-f>=2f+1':>11} {'agree?':>8}")
    for (n, f) in [(3, 1), (4, 1), (7, 2), (10, 3), (10, 4), (2, 1), (2, 0)]:
        a, b = byzantine_feasible(n, f), honest_supermajority(n, f)
        print(f"  {n:>3} {f:>3} {str(a):>9} {str(b):>11} {str(a == b):>8}")
    print("  Two agents tolerate only f=0 (Theorem 4.2).\n")


def demo_composition() -> None:
    print("=" * 70)
    print("DEMO 5: Protocol composition (weakest link, Theorems 4.3-4.4)")
    print("=" * 70)
    n, f1, f2 = 13, 4, 2
    print(f"  n={n}: protocol A tolerates f1={f1}, protocol B tolerates f2={f2}")
    print(f"  sequential composite tolerance = {sequential_tolerance(n, f1, f2)} "
          f"(= min, still feasible: {byzantine_feasible(n, min(f1, f2))})")
    print(f"  rounds needed for n={n}: >= {round_lower_bound(n)} (Theorem 4.5)\n")


def demo_cross_domain() -> None:
    print("=" * 70)
    print("DEMO 6: Cross-domain bounds (crypto / ML / information theory)")
    print("=" * 70)
    print(f"  Post-quantum (n=256, sec=128): ok = {post_quantum_dimension_ok(256, 128)}")
    print(f"  Post-quantum (n=128, sec=128): ok = {post_quantum_dimension_ok(128, 128)}")
    eps, L = 0.30, 2.0
    print(f"  Certified robustness radius (eps={eps}, L={L}) = {certified_radius(eps, L)}")
    print(f"  Coboundary norm bound (||a||=1.5)            = {coboundary_norm_bound(1.5)}")
    print(f"  Entropy bound for |A|=256                    = {entropy_bound_bits(256)} bits")
    print(f"  Averaging contraction for n=10               = {averaging_factor(10):.4f}")
    print()


def demo_additivity() -> None:
    print("=" * 70)
    print("DEMO 7: Coboundary additivity  delta(a+b) = delta(a) + delta(b)")
    print("=" * 70)
    act = CyclicAction(m=5, q=11, s=4)
    a, b = 3, 6
    da, db = act.coboundary(a), act.coboundary(b)
    dab = act.coboundary((a + b) % act.q)
    lhs = [dab(g) for g in act.elements()]
    rhs = [(da(g) + db(g)) % act.q for g in act.elements()]
    print(f"  delta({a}+{b}) = {lhs}")
    print(f"  delta({a})+delta({b}) = {rhs}")
    print(f"  equal? {lhs == rhs}  (Theorem 5.1)\n")


def main() -> None:
    demo_consensus_achievable()
    demo_consensus_obstructed()
    demo_complexity()
    demo_byzantine_bound()
    demo_composition()
    demo_cross_domain()
    demo_additivity()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
