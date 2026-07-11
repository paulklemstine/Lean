"""
The Fractal Dimension of Mathematical Truth -- numerical demonstrations.

This self-contained script illustrates the paper's main results:

  * statements are encoded as binary sequences (Cantor space) with the prefix
    metric d(x, y) = 2^{-m}, where m is the first index of disagreement;
  * a "theory" admits/rejects finite prefixes, carving out a "truth set";
  * the box-counting dimension of a truth set equals the growth rate of the
    number A_n of admissible length-n prefixes:
        dim_B = lim_n  log2(A_n) / n
      which equals the asymptotic density of information-bearing coordinates;
  * the parity theory has dimension exactly 1/2 (sparse but not negligible);
  * arbitrary densities in [0, 1] are realizable (full dimension spectrum);
  * the dimension is approximable from above, dual to Chaitin's Omega, which is
    approximable from below (both uncomputable in general).

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Iterator, List, Tuple

# A theory is described by a predicate telling whether coordinate i is "free".
# Non-free coordinates are forced (here, to a default), so they carry no
# branching; free coordinates each double the number of admissible prefixes.
FreePredicate = Callable[[int], bool]


def admissible_prefix_count(free: FreePredicate, n: int) -> int:
    """A_n : the number of admissible length-n prefixes of a density-pattern
    theory whose free coordinates are exactly those i < n with free(i) true.
    Each free coordinate contributes a factor of 2 (the identity
    sum_{i<=k} C(k, i) = 2^k made concrete)."""
    free_coords: int = sum(1 for i in range(n) if free(i))
    return 2 ** free_coords


def dimension_estimate(free: FreePredicate, n: int) -> float:
    """Finite box-counting estimate log2(A_n) / n at resolution 2^{-n}."""
    a_n: int = admissible_prefix_count(free, n)
    return math.log2(a_n) / n if n > 0 else 0.0


def free_coordinate_density(free: FreePredicate, n: int) -> float:
    """Empirical density of free coordinates among the first n positions;
    this equals the dimension estimate and converges to dim_B."""
    return sum(1 for i in range(n) if free(i)) / n if n > 0 else 0.0


# ---- Concrete theories -------------------------------------------------------

def parity_free(i: int) -> bool:
    """Parity theory: even coordinates free, odd coordinates forced (copies)."""
    return i % 2 == 0


def periodic_free(p: int, q: int) -> FreePredicate:
    """Rational density p/q: free on p positions in every block of q."""
    return lambda i: (i % q) < p


def beatty_free(r: float) -> FreePredicate:
    """Irrational density r via a Beatty pattern; asymptotic density -> r."""
    return lambda i: (math.floor((i + 1) * r) - math.floor(i * r)) == 1


def prefix_distance(x: str, y: str) -> float:
    """Prefix (ultra)metric on finite/prefix-truncated sequences."""
    m: int = 0
    for a, b in zip(x, y):
        if a != b:
            return 2.0 ** (-m)
        m += 1
    return 2.0 ** (-min(len(x), len(y)))


# ---- Chaitin-Omega-style from-below approximation ---------------------------

def toy_halting(program: int, steps: int) -> bool:
    """A decidable stand-in for a universal machine: 'program' halts within
    'steps' iff steps exceeds a deterministic pseudo-random runtime. Purely
    illustrative -- it mimics the *shape* of Omega's from-below approximation,
    not a real universal machine."""
    runtime: int = (program * 2654435761) % 97 + 1
    return steps >= runtime


def omega_lower_bounds(num_programs: int, budgets: List[int]) -> List[float]:
    """Ascending rational lower bounds for a toy halting probability
    Omega = sum over halting programs p of 2^{-(|p|+1)}. As the step budget
    grows, more programs are seen to halt and the estimate rises monotonically
    -- the dual of the dimension's from-above approximation."""
    bounds: List[float] = []
    for budget in budgets:
        total: float = 0.0
        for p in range(num_programs):
            weight: float = 2.0 ** (-(p + 1))
            if toy_halting(p, budget):
                total += weight
        bounds.append(total)
    return bounds


def dimension_upper_bounds(free: FreePredicate, depths: List[int]) -> List[float]:
    """A descending-in-the-limit sequence of dimension estimates. For the
    density-pattern theories the estimate converges to the density from both
    sides; we report the running tail-max to emphasise the from-above view."""
    raw: List[float] = [dimension_estimate(free, n) for n in depths]
    tail_max: List[float] = []
    running: float = 0.0
    for value in reversed(raw):
        running = max(running, value)
        tail_max.append(running)
    return list(reversed(tail_max))


# ---- Reporting ---------------------------------------------------------------

def _banner(title: str) -> None:
    print("\n" + "=" * 68)
    print(title)
    print("=" * 68)


def demo_parity() -> None:
    _banner("1. Parity theory: dimension -> 1/2 (sparse but not negligible)")
    print(f"{'n':>6} | {'A_n':>14} | {'log2(A_n)/n':>12}")
    print("-" * 40)
    for n in [2, 4, 8, 16, 32, 64, 128, 256]:
        est: float = dimension_estimate(parity_free, n)
        print(f"{n:>6} | {admissible_prefix_count(parity_free, n):>14} | {est:>12.6f}")
    print("Limit dimension = 0.5  (0 < 0.5 < 1)")
    mu: float = 2.0 ** (-(256 // 2))  # fair-coin measure of depth-256 truth set
    print(f"Fair-coin measure at depth 256 ~ {mu:.3e}  (-> 0: Lebesgue-null)")


def demo_spectrum() -> None:
    _banner("2. Dimension spectrum: every target in [0,1] is realizable")
    targets: List[Tuple[str, FreePredicate, float]] = [
        ("periodic 1/3", periodic_free(1, 3), 1 / 3),
        ("periodic 2/5", periodic_free(2, 5), 2 / 5),
        ("periodic 3/4", periodic_free(3, 4), 3 / 4),
        ("Beatty 1/sqrt2", beatty_free(1 / math.sqrt(2)), 1 / math.sqrt(2)),
        ("Beatty golden-1", beatty_free((math.sqrt(5) - 1) / 2), (math.sqrt(5) - 1) / 2),
    ]
    print(f"{'theory':>16} | {'target':>10} | {'estimate n=2048':>16} | {'|error|':>10}")
    print("-" * 62)
    for name, free, target in targets:
        est: float = free_coordinate_density(free, 2048)
        print(f"{name:>16} | {target:>10.6f} | {est:>16.6f} | {abs(est - target):>10.2e}")


def demo_metric() -> None:
    _banner("3. The prefix ultrametric on statement encodings")
    samples: List[Tuple[str, str]] = [
        ("0000", "0001"),
        ("0101", "0100"),
        ("1010", "0010"),
        ("1111", "1111"),
    ]
    for x, y in samples:
        print(f"d({x}, {y}) = {prefix_distance(x, y):.4f}")


def demo_duality() -> None:
    _banner("4. Duality: Omega from below vs. dimension from above")
    budgets: List[int] = [1, 5, 20, 60, 200]
    om: List[float] = omega_lower_bounds(64, budgets)
    print("Toy-Omega ascending lower bounds (approximable from BELOW):")
    for b, v in zip(budgets, om):
        print(f"   budget {b:>4} -> {v:.6f}")
    print("   (monotonically non-decreasing towards the toy halting probability)")

    depths: List[int] = [4, 8, 16, 32, 64, 128, 256, 512]
    ub: List[float] = dimension_upper_bounds(parity_free, depths)
    print("\nParity dimension upper bounds (approximable from ABOVE):")
    for d, v in zip(depths, ub):
        print(f"   depth  {d:>4} -> {v:.6f}")
    print("   (tail suprema descending towards dim_B = 0.5)")


def main() -> None:
    demo_parity()
    demo_spectrum()
    demo_metric()
    demo_duality()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
