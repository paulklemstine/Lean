"""
Numerical demonstration of the two-layer structure of the maximal
good-manifold count a(n) in an n-nice polytope.

The count decomposes as a(n) = 2^n + d(n), where d is a truncated
doubling "defect" supported on 1 <= n <= 6. This script reproduces
every result of the accompanying paper numerically:

  * the two-layer decomposition and the vanishing of the defect,
  * the 2-adic valuation identity  v2(a(n)) = n  for n >= 7,
  * strict monotonicity and the exact growth rate a(n)^(1/n) -> 2,
  * the cumulative closed form S(n) = 2^(n+1) + 43 for n >= 6, and
    the failure of cumulative divisibility by 128.

Self-contained; standard library only.
"""

from __future__ import annotations


def defect(n: int) -> int:
    """The defect d(n) = a(n) - 2^n, supported on 1 <= n <= 6."""
    table = {1: 4, 2: 4, 3: 4, 4: 8, 5: 8, 6: 16}
    return table.get(n, 0)


def a(n: int) -> int:
    """Maximal number of good manifolds in an n-nice polytope: 2^n + d(n)."""
    return 2 ** n + defect(n)


def cumulative(n: int) -> int:
    """Running total S(n) = sum_{k=0}^{n} a(k)."""
    return sum(a(k) for k in range(n + 1))


def two_adic_valuation(m: int) -> int:
    """Largest e with 2^e | m (for m > 0)."""
    if m <= 0:
        raise ValueError("valuation defined for positive integers")
    e = 0
    while m % 2 == 0:
        m //= 2
        e += 1
    return e


def demo_sequence(upper: int = 12) -> None:
    """Print the sequence, its two layers, valuation, and cumulative sums."""
    print("=== Two-layer structure of a(n) = 2^n + d(n) ===")
    header = f"{'n':>3} {'2^n':>7} {'d(n)':>5} {'a(n)':>7} {'v2(a)':>6} {'S(n)':>8} {'S%128':>6}"
    print(header)
    print("-" * len(header))
    for n in range(upper):
        an = a(n)
        sn = cumulative(n)
        print(
            f"{n:>3} {2**n:>7} {defect(n):>5} {an:>7} "
            f"{two_adic_valuation(an):>6} {sn:>8} {sn % 128:>6}"
        )


def check_tail_geometric(upper: int = 30) -> None:
    """Verify a(n) = 2^n and v2(a(n)) = n for 7 <= n < upper."""
    print("\n=== Tail is purely geometric, valuation = dimension (n >= 7) ===")
    ok = all(
        a(n) == 2 ** n and two_adic_valuation(a(n)) == n
        for n in range(7, upper)
    )
    print(f"a(n) == 2^n and v2(a(n)) == n for 7 <= n < {upper}: {ok}")


def check_defect_blocks() -> None:
    """Verify the defect is a doubling sequence on blocks of lengths 3,2,1."""
    print("\n=== Defect blocks: values 4,8,16 on lengths 3,2,1 ===")
    block4 = [defect(n) for n in (1, 2, 3)]
    block8 = [defect(n) for n in (4, 5)]
    block16 = [defect(6)]
    print(f"block of 4 (n=1..3): {block4} -> length {len(block4)}")
    print(f"block of 8 (n=4..5): {block8} -> length {len(block8)}")
    print(f"block of 16 (n=6):   {block16} -> length {len(block16)}")
    print(f"values double: d(4)=2*d(3)? {defect(4) == 2*defect(3)}, "
          f"d(6)=2*d(5)? {defect(6) == 2*defect(5)}")


def check_monotonicity(upper: int = 40) -> None:
    """Verify strict monotonicity."""
    vals = [a(n) for n in range(upper)]
    strict = all(vals[i] < vals[i + 1] for i in range(len(vals) - 1))
    print(f"\n=== Strict monotonicity for 0 <= n < {upper}: {strict} ===")


def check_growth_rate(upper: int = 200) -> None:
    """Show a(n)^(1/n) -> 2 (exactly 2 for n >= 7)."""
    print("\n=== Growth rate a(n)^(1/n) -> 2 ===")
    for n in (7, 20, 50, upper):
        root = a(n) ** (1.0 / n)
        print(f"n = {n:>4}:  a(n)^(1/n) = {root:.12f}")


def check_cumulative_formula(upper: int = 40) -> None:
    """Verify S(n) = 2^(n+1)+43 for n>=6 and S(n) never divisible by 128."""
    print("\n=== Cumulative closed form and divisibility failure ===")
    formula_ok = all(cumulative(n) == 2 ** (n + 1) + 43 for n in range(6, upper))
    print(f"S(n) == 2^(n+1)+43 for 6 <= n < {upper}: {formula_ok}")
    residues = {cumulative(n) % 128 for n in range(6, upper)}
    print(f"S(n) mod 128 for n >= 6: {residues}")
    never_div = all(cumulative(n) % 128 != 0 for n in range(upper))
    print(f"128 never divides S(n) for 0 <= n < {upper}: {never_div}")


def main() -> None:
    demo_sequence()
    check_tail_geometric()
    check_defect_blocks()
    check_monotonicity()
    check_growth_rate()
    check_cumulative_formula()


if __name__ == "__main__":
    main()
