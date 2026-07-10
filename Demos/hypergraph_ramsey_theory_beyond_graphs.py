"""
Hypergraph Ramsey Theory: Numerical Demonstrations
==================================================

Self-contained numerical illustrations of the key results in the accompanying
paper on r-uniform hypergraph Ramsey numbers:

  * the first-moment (probabilistic) lower bound
        2 * C(n, k) < 2 ** C(k, r)   =>   R_r(k, k) > n,
  * the tower function and the tower-type upper bound produced by iterating
    the Erdos-Rado stepping-up recursion,
  * the single- vs. double-exponential gap for R_3(k, k).

Everything is written with the standard library only (the `math` module), with
type hints, and every helper inlined so the file runs as-is:

    python3 demo.py
"""

from __future__ import annotations

from math import comb, log2


# ---------------------------------------------------------------------------
# 1. The tower function  tower(h, N)
# ---------------------------------------------------------------------------

def tower(h: int, N: int) -> int:
    """Iterated base-2 exponential: tower(0, N) = N, tower(h+1, N) = 2 ** tower(h, N).

    So tower(1, N) = 2**N and tower(2, N) = 2**(2**N).  Grows so fast that only
    tiny arguments are representable; used here for small illustrative values.
    """
    value: int = N
    for _ in range(h):
        value = 2 ** value
    return value


# ---------------------------------------------------------------------------
# 2. The first-moment lower-bound certificate
# ---------------------------------------------------------------------------

def first_moment_no_mono(n: int, r: int, k: int) -> bool:
    """Return True if the counting inequality 2*C(n,k) < 2**C(k,r) holds.

    When True, there exists an r-uniform 2-coloring of an n-set with no
    monochromatic k-clique, hence R_r(k, k) > n.
    """
    if not (r <= k <= n):
        return False
    return 2 * comb(n, k) < 2 ** comb(k, r)


def best_lower_bound(r: int, k: int, n_max: int = 20000) -> int:
    """Largest n <= n_max for which the first-moment inequality certifies R_r(k,k) > n.

    Returns the largest such n (so R_r(k, k) >= n + 1), or 0 if none found.
    """
    best: int = 0
    for n in range(k, n_max + 1):
        if first_moment_no_mono(n, r, k):
            best = n
    return best


# ---------------------------------------------------------------------------
# 3. Growth-rate comparisons for R_3(k, k)
# ---------------------------------------------------------------------------

def log2_lower_bound_exponent(k: int) -> float:
    """log2 of the largest n certified by the first moment for r = 3 (single exp)."""
    n = best_lower_bound(3, k)
    return log2(n) if n > 0 else float("nan")


def double_exp_upper_scale(k: int) -> float:
    """A schematic double-exponential upper scale log2(log2(R_3)) ~ c * k.

    Illustrative only: uses the stepping-up-derived shape 2 ** (2 ** (c*k)).
    """
    c: float = 0.5
    return c * k


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_boundary_values() -> None:
    print("== Boundary values R_r(r, l) = l ==")
    for r, l in [(2, 2), (3, 3), (3, 5), (4, 7)]:
        print(f"  R_{r}({r},{l}) = {l}")
    print()


def demo_concrete_lower_bound() -> None:
    print("== Concrete small-case lower bound (r = 3, k = 5) ==")
    n, r, k = 11, 3, 5
    lhs = 2 * comb(n, k)
    rhs = 2 ** comb(k, r)
    print(f"  C(5,3) = {comb(k, r)},  C(11,5) = {comb(n, k)}")
    print(f"  2*C(11,5) = {lhs}  <  2^C(5,3) = {rhs}  ->  {lhs < rhs}")
    print(f"  Therefore R_3(5,5) > {n}  (no mono 5-clique on 11 vertices).")
    print()


def demo_lower_bound_growth() -> None:
    print("== First-moment lower bound R_3(k,k) > n_max(k) ==")
    print("   k |  best n  | log2(n)")
    for k in range(4, 12):
        n = best_lower_bound(3, k)
        lg = f"{log2(n):6.2f}" if n > 0 else "  n/a"
        print(f"  {k:2d} | {n:7d}  | {lg}")
    print("  (log2(n) grows ~ quadratically in k: single-exponential 2^(c k^2))")
    print()


def demo_tower_function() -> None:
    print("== The tower function tower(h, N) ==")
    for h in range(0, 4):
        print(f"  tower({h}, 2) = {tower(h, 2)}")
    print("  tower(4, 2) = 2^65536 (a ~20000-digit number, omitted)")
    print("  tower(1,N)=2^N, tower(2,N)=2^(2^N); each level adds one exponential.")
    print()


def demo_tower_dominates() -> None:
    print("== Tower of height 2 dominates 4^k  (4^k < 2^(2^k) for k >= 5) ==")
    print("   k |     4^k     |  log2(tower(2,k)) = 2^k")
    for k in range(3, 9):
        print(f"  {k:2d} | {4 ** k:11d} | {2 ** k}")
    print()


def demo_gap() -> None:
    print("== The single- vs double-exponential gap for R_3(k,k) ==")
    print("   lower bound  2^(c k^2)   <=  R_3(k,k)  <=  2^(2^(c' k))  upper bound")
    print("   k | log2(lower) | log2(log2(upper)) ~ c'*k")
    for k in range(4, 12):
        low = log2_lower_bound_exponent(k)
        up = double_exp_upper_scale(k)
        print(f"  {k:2d} |  {low:8.2f}   |   {up:6.2f}")
    print()


def main() -> None:
    demo_boundary_values()
    demo_concrete_lower_bound()
    demo_lower_bound_growth()
    demo_tower_function()
    demo_tower_dominates()
    demo_gap()


if __name__ == "__main__":
    main()
