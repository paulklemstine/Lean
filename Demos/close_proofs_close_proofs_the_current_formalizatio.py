"""
Fractal Dimension of Proof Search — numerical demonstrations.

This self-contained script illustrates every theorem of the formal development:

  - search dimension  D(b, k) = log(k) / log(b)
  - range, monotonicity, endpoints (D(b,1)=0, D(b,b)=1)
  - the critical threshold  D = 1  <=>  k = b
  - subcritical exponential decay of the success fraction (k/b)^d
  - the entropy-dimension bridge  H_S / H_T = D
  - per-level information rate  log(b) * (1 - D)
  - linear information decomposition over depth
  - composition of searches: containment bound and additive log-entropy

Run with:  python demo.py
No third-party dependencies; uses only the standard library.
"""

from __future__ import annotations

import math
from dataclasses import dataclass


# --------------------------------------------------------------------------- #
# Core definitions (mirror of the formal model)
# --------------------------------------------------------------------------- #

def search_dimension(b: int, k: int) -> float:
    """Fractal dimension of proof search: D(b, k) = log(k) / log(b).

    Requires b >= 2 and k >= 1.
    """
    if b < 2:
        raise ValueError("branching factor b must be >= 2")
    if k < 1:
        raise ValueError("survivor count k must be >= 1")
    return math.log(k) / math.log(b)


def total_leaves(b: int, d: int) -> int:
    """All derivation attempts of length d: b ** d."""
    return b ** d


def successful_leaves(k: int, d: int) -> int:
    """Completed proofs of length d: k ** d."""
    return k ** d


def search_entropy(k: int, d: int) -> float:
    """Search entropy H_S(k, d) = log(k ** d)."""
    return math.log(k ** d)


def full_tree_entropy(b: int, d: int) -> float:
    """Full-tree entropy H_T(b, d) = log(b ** d)."""
    return math.log(b ** d)


def per_level_information(b: int, k: int) -> float:
    """Information gained per search level: log(b) - log(k) = log(b)*(1 - D)."""
    return math.log(b) - math.log(k)


@dataclass(frozen=True)
class ComposedSearch:
    """Sequential composition of two branching searches."""

    b1: int
    k1: int
    d1: int
    b2: int
    k2: int
    d2: int

    def total_space(self) -> int:
        return self.b1 ** self.d1 * self.b2 ** self.d2

    def successful_paths(self) -> int:
        return self.k1 ** self.d1 * self.k2 ** self.d2

    def log_entropy(self) -> float:
        """log(k1^d1 * k2^d2) = d1*log(k1) + d2*log(k2)."""
        return math.log(self.k1 ** self.d1 * self.k2 ** self.d2)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_endpoints_and_range() -> None:
    print("=" * 68)
    print("1. Endpoints and range:  0 <= D(b,k) <= 1")
    print("=" * 68)
    for b in (2, 3, 5, 10):
        d_unique = search_dimension(b, 1)   # k = 1  -> 0
        d_full = search_dimension(b, b)     # k = b  -> 1
        print(f"  b={b:2d}:  D(b,1) = {d_unique:.4f}   D(b,b) = {d_full:.4f}")
    print("  All intermediate values lie strictly inside (0, 1):")
    b = 8
    for k in range(1, b + 1):
        print(f"    D({b},{k}) = {search_dimension(b, k):.4f}")
    print()


def demo_monotonicity() -> None:
    print("=" * 68)
    print("2. Monotonicity in survivors k (b fixed)")
    print("=" * 68)
    b = 12
    prev = -1.0
    ok = True
    for k in range(1, b + 1):
        d = search_dimension(b, k)
        ok = ok and (d >= prev - 1e-12)
        prev = d
    print(f"  b={b}: dimension non-decreasing as k grows?  {ok}")
    print()


def demo_critical_threshold() -> None:
    print("=" * 68)
    print("3. Critical threshold:  D(b,k) = 1  <=>  k = b")
    print("=" * 68)
    b = 6
    for k in range(1, b + 1):
        d = search_dimension(b, k)
        is_one = math.isclose(d, 1.0, abs_tol=1e-12)
        print(f"  D({b},{k}) = {d:.4f}   (=1? {is_one})   (k==b? {k == b})")
    print()


def demo_subcritical_decay() -> None:
    print("=" * 68)
    print("4. Subcritical decay: success fraction (k/b)^d strictly shrinks")
    print("=" * 68)
    b, k = 5, 3
    print(f"  b={b}, k={k}, D={search_dimension(b, k):.4f}")
    print(f"  {'d':>3} {'succ=k^d':>12} {'total=b^d':>14} {'fraction':>12}")
    for d in range(1, 9):
        s = successful_leaves(k, d)
        t = total_leaves(b, d)
        print(f"  {d:>3} {s:>12} {t:>14} {s / t:>12.6f}")
    print("  Worsening ratio: k^(d+1)*b^d < k^d*b^(d+1) for each d:")
    for d in range(0, 5):
        lhs = k ** (d + 1) * b ** d
        rhs = k ** d * b ** (d + 1)
        print(f"    d={d}: {lhs} < {rhs}  -> {lhs < rhs}")
    print()


def demo_entropy_bridge() -> None:
    print("=" * 68)
    print("5. Entropy-dimension bridge:  H_S / H_T = D  (any depth)")
    print("=" * 68)
    b, k = 7, 4
    d_true = search_dimension(b, k)
    print(f"  b={b}, k={k}, D={d_true:.6f}")
    for d in (1, 3, 10, 50):
        ratio = search_entropy(k, d) / full_tree_entropy(b, d)
        print(f"    d={d:>3}:  H_S/H_T = {ratio:.6f}   (matches D? "
              f"{math.isclose(ratio, d_true)})")
    print()


def demo_information_rate() -> None:
    print("=" * 68)
    print("6. Per-level information rate  log(b)*(1 - D)")
    print("=" * 68)
    b, k = 9, 4
    d_val = search_dimension(b, k)
    direct = per_level_information(b, k)
    formula = math.log(b) * (1 - d_val)
    print(f"  b={b}, k={k}, D={d_val:.4f}")
    print(f"    log(b)-log(k)      = {direct:.6f}")
    print(f"    log(b)*(1 - D)     = {formula:.6f}")
    print(f"    equal? {math.isclose(direct, formula)}")
    print("  Linear decomposition over depth: log(b^d)-log(k^d) = d*(...)")
    for d in (1, 4, 20):
        lhs = full_tree_entropy(b, d) - search_entropy(k, d)
        rhs = d * direct
        print(f"    d={d:>3}: {lhs:.4f} == {rhs:.4f}  -> "
              f"{math.isclose(lhs, rhs)}")
    print()


def demo_composition() -> None:
    print("=" * 68)
    print("7. Composition of searches: containment + additive entropy")
    print("=" * 68)
    c = ComposedSearch(b1=3, k1=2, d1=4, b2=5, k2=2, d2=3)
    total = c.total_space()
    succ = c.successful_paths()
    print(f"  stage 1: b={c.b1}, k={c.k1}, d={c.d1}")
    print(f"  stage 2: b={c.b2}, k={c.k2}, d={c.d2}")
    print(f"  successful paths = {succ}")
    print(f"  total space      = {total}")
    print(f"  containment succ <= total?  {succ <= total}")
    additive = c.d1 * math.log(c.k1) + c.d2 * math.log(c.k2)
    print(f"  log-entropy  log(k1^d1 * k2^d2) = {c.log_entropy():.6f}")
    print(f"  additive     d1*log(k1)+d2*log(k2) = {additive:.6f}")
    print(f"  equal? {math.isclose(c.log_entropy(), additive)}")
    print()


def main() -> None:
    print("\nFRACTAL DIMENSION OF PROOF SEARCH — NUMERICAL DEMOS\n")
    demo_endpoints_and_range()
    demo_monotonicity()
    demo_critical_threshold()
    demo_subcritical_decay()
    demo_entropy_bridge()
    demo_information_rate()
    demo_composition()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
