"""Numerical demonstrations for the Fractal Dimension of Proof Search.

This standalone script illustrates the formally verified results:

  * SearchDimension(b, k) = log k / log b lies in [0, 1]
  * D = 0 iff unique proof (k = 1); D = 1 iff trivial (k = b)
  * D is monotone in the survival count k
  * subcritical decay: k^d < b^d when k < b
  * the success ratio (k/b)^d strictly worsens with depth
  * the critical threshold: D = 1  <=>  k = b
  * the entropy-dimension bridge: SearchEntropy / FullTreeEntropy = D
  * information rate: log b - log k = log b * (1 - D)
  * composition: log(k1^d1 * k2^d2) = d1 log k1 + d2 log k2

Every function is inlined and uses only the standard library.

Run:  python demo.py
"""

from __future__ import annotations

import math
from dataclasses import dataclass


# --------------------------------------------------------------------------
# Core definitions (mirroring the Lean development)
# --------------------------------------------------------------------------

def search_dimension(b: int, k: int) -> float:
    """Fractal dimension of proof search: D(b, k) = log k / log b.

    Requires b >= 2 and 1 <= k <= b.
    """
    assert b >= 2, "branching factor must satisfy b >= 2"
    assert 1 <= k <= b, "survival count must satisfy 1 <= k <= b"
    return math.log(k) / math.log(b)


def total_leaves(b: int, d: int) -> int:
    """Total candidate proof attempts of length d: b^d."""
    return b ** d


def successful_leaves(k: int, d: int) -> int:
    """Successful proof paths of length d: k^d."""
    return k ** d


def search_entropy(k: int, d: int) -> float:
    """Search entropy: log(k^d)."""
    return math.log(k ** d)


def full_tree_entropy(b: int, d: int) -> float:
    """Full-tree entropy: log(b^d)."""
    return math.log(b ** d)


@dataclass
class BranchingSearchModel:
    """A complete b-ary search tree with k surviving branches at each node."""
    b: int
    k: int
    d: int

    def __post_init__(self) -> None:
        assert self.b >= 2
        assert 1 <= self.k <= self.b
        assert self.d >= 0

    @property
    def dimension(self) -> float:
        return search_dimension(self.b, self.k)

    @property
    def total(self) -> int:
        return total_leaves(self.b, self.d)

    @property
    def successful(self) -> int:
        return successful_leaves(self.k, self.d)

    @property
    def success_ratio(self) -> float:
        return self.successful / self.total


@dataclass
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

    def composed_entropy(self) -> float:
        return math.log(self.successful_paths())


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_range_and_boundaries() -> None:
    print("=" * 70)
    print("1. Dimension lies in [0, 1]; boundary cases D=0 (k=1) and D=1 (k=b)")
    print("=" * 70)
    b = 8
    for k in range(1, b + 1):
        d = search_dimension(b, k)
        tag = ""
        if k == 1:
            tag = "  <- unique proof, D = 0"
        if k == b:
            tag = "  <- trivial, D = 1"
        assert 0.0 - 1e-12 <= d <= 1.0 + 1e-12
        print(f"  b={b}, k={k}:  D = {d:.4f}{tag}")
    print()


def demo_monotonicity() -> None:
    print("=" * 70)
    print("2. Monotonicity: more surviving branches -> higher dimension")
    print("=" * 70)
    b = 10
    prev = -1.0
    for k in range(1, b + 1):
        d = search_dimension(b, k)
        assert d >= prev - 1e-12, "monotonicity violated!"
        prev = d
    print(f"  D(b={b}, k) is non-decreasing in k:  verified for k=1..{b}")
    print()


def demo_subcritical_decay() -> None:
    print("=" * 70)
    print("3. Subcritical decay: k < b  =>  k^d < b^d, and ratio worsens")
    print("=" * 70)
    b, k = 5, 3
    print(f"  branching b={b}, survival k={k}, D = {search_dimension(b, k):.4f}")
    prev_ratio = 2.0
    for d in range(1, 9):
        succ = successful_leaves(k, d)
        tot = total_leaves(b, d)
        ratio = succ / tot
        assert succ < tot
        assert ratio < prev_ratio  # decay_ratio_worsens
        prev_ratio = ratio
        print(f"    d={d}:  {succ:>7} / {tot:>9}  ratio = {ratio:.5f}")
    print()


def demo_critical_threshold() -> None:
    print("=" * 70)
    print("4. Critical threshold: D = 1  <=>  k = b")
    print("=" * 70)
    b = 6
    for k in range(1, b + 1):
        d = search_dimension(b, k)
        is_one = abs(d - 1.0) < 1e-12
        assert is_one == (k == b)
        print(f"  k={k}: D={d:.4f}  (D==1 is {is_one}, k==b is {k == b})")
    print()


def demo_entropy_bridge() -> None:
    print("=" * 70)
    print("5. Entropy-dimension bridge: SearchEntropy / FullTreeEntropy = D")
    print("=" * 70)
    b, k = 7, 4
    for d in range(1, 6):
        lhs = search_entropy(k, d) / full_tree_entropy(b, d)
        rhs = search_dimension(b, k)
        assert abs(lhs - rhs) < 1e-12
        print(f"  d={d}:  {lhs:.6f}  ==  D = {rhs:.6f}   (depth cancels)")
    print()


def demo_information_rate() -> None:
    print("=" * 70)
    print("6. Information rate: log b - log k = log b * (1 - D)")
    print("=" * 70)
    for (b, k) in [(4, 1), (4, 2), (4, 3), (4, 4), (16, 5)]:
        d = search_dimension(b, k)
        lhs = math.log(b) - math.log(k)
        rhs = math.log(b) * (1 - d)
        assert abs(lhs - rhs) < 1e-12
        print(f"  b={b:>2}, k={k}:  per-step search info = {lhs:.4f} nats "
              f"= log b * (1 - {d:.3f})")
    print()


def demo_composition() -> None:
    print("=" * 70)
    print("7. Composition: log(k1^d1 * k2^d2) = d1 log k1 + d2 log k2")
    print("=" * 70)
    c = ComposedSearch(b1=4, k1=2, d1=3, b2=6, k2=5, d2=2)
    lhs = c.composed_entropy()
    rhs = c.d1 * math.log(c.k1) + c.d2 * math.log(c.k2)
    assert abs(lhs - rhs) < 1e-12
    assert c.successful_paths() <= c.total_space()  # ComposedSearch.bound
    print(f"  stage 1: (b,k,d)=({c.b1},{c.k1},{c.d1});  "
          f"stage 2: (b,k,d)=({c.b2},{c.k2},{c.d2})")
    print(f"  successful paths = {c.successful_paths()}  <=  "
          f"total space = {c.total_space()}")
    print(f"  composed entropy = {lhs:.4f} = sum of stage entropies = {rhs:.4f}")
    print()


def main() -> None:
    demo_range_and_boundaries()
    demo_monotonicity()
    demo_subcritical_decay()
    demo_critical_threshold()
    demo_entropy_bridge()
    demo_information_rate()
    demo_composition()
    print("All demonstrations passed and match the formally verified theorems.")


if __name__ == "__main__":
    main()
