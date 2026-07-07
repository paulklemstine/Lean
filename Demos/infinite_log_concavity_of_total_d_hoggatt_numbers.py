"""
demo.py — Numerical demonstrations for
"A Log-Concavity Dichotomy for the Total d-Hoggatt Numbers"

The total d-Hoggatt numbers H_d(n) = sum_k H_d(n,k) specialize to:
    d = 1 : powers of two 2^n           (row sums of Pascal's triangle)
    d = 2 : Catalan numbers C_n
    d = 3 : Baxter numbers B_n

We work with the LOG-CONCAVITY OPERATOR

    (L a)(n) = a(n+1)^2 - a(n) * a(n+2)

A sequence is:
    log-concave        iff (L a)(n) >= 0  for all n
    log-convex         iff (L a)(n) <= 0  for all n
    infinitely log-concave  iff  (L^k a)(n) >= 0  for all k, n

Main facts demonstrated here (exactly, over the rationals / integers):
    * geometric sequences r^n are annihilated by L, hence infinitely log-concave
    * the Catalan numbers are STRICTLY log-convex (L C < 0 everywhere)
    * the Baxter numbers are (empirically) strictly log-convex too
    * so infinite log-concavity holds at d = 1 and fails at d = 2.

Everything uses exact arithmetic (Python ints / fractions.Fraction), so the
sign tests are rigorous, not floating-point approximations.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import Callable, List, Optional, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Core operator
# --------------------------------------------------------------------------- #
def log_concavity_operator(a: Sequence[Fraction]) -> List[Fraction]:
    """Apply L: (L a)(n) = a[n+1]^2 - a[n]*a[n+2].

    Consumes a[0..N+1] and returns a[0..N-1] (window shrinks by two).
    """
    return [a[n + 1] ** 2 - a[n] * a[n + 2] for n in range(len(a) - 2)]


def iterate_operator(a: Sequence[Fraction], depth: int) -> List[List[Fraction]]:
    """Return [a, L a, L^2 a, ..., L^depth a], each as a list."""
    levels: List[List[Fraction]] = [list(a)]
    cur = list(a)
    for _ in range(depth):
        if len(cur) < 3:
            break
        cur = log_concavity_operator(cur)
        levels.append(cur)
    return levels


def first_violation(
    a: Sequence[Fraction], depth: int
) -> Optional[Tuple[int, int, Fraction]]:
    """Test infinite log-concavity up to `depth` iterations.

    Returns the first (k, n, value) with (L^k a)(n) < 0, or None if no
    violation is found within the available window.
    """
    cur = list(a)
    for k in range(depth + 1):
        for n, v in enumerate(cur):
            if v < 0:
                return (k, n, v)
        if len(cur) < 3:
            break
        cur = log_concavity_operator(cur)
    return None


# --------------------------------------------------------------------------- #
# The total d-Hoggatt sequences
# --------------------------------------------------------------------------- #
def geometric(r: Fraction, length: int) -> List[Fraction]:
    """The d = 1 totals: geometric sequence r^n (r = 2 gives 2^n)."""
    return [r ** n for n in range(length)]


def catalan(length: int) -> List[Fraction]:
    """The d = 2 totals: Catalan numbers via the ratio recurrence
    C_0 = 1,  C_{n+1} = 2(2n+1)/(n+2) * C_n."""
    out: List[Fraction] = [Fraction(1)]
    for n in range(length - 1):
        out.append(Fraction(2 * (2 * n + 1), n + 2) * out[-1])
    return out


def baxter(length: int) -> List[Fraction]:
    """The d = 3 totals: Baxter numbers via the triple-binomial sum
    B_n = sum_{k=1}^n C(n+1,k-1) C(n+1,k) C(n+1,k+1) / (C(n+1,1) C(n+1,2))."""
    out: List[Fraction] = []
    for n in range(length):
        if n == 0:
            out.append(Fraction(1))
            continue
        denom = comb(n + 1, 1) * comb(n + 1, 2)
        total = sum(
            comb(n + 1, k - 1) * comb(n + 1, k) * comb(n + 1, k + 1)
            for k in range(1, n + 1)
        )
        out.append(Fraction(total, denom))
    return out


# --------------------------------------------------------------------------- #
# Pretty-printing helpers
# --------------------------------------------------------------------------- #
def fmt(x: Fraction) -> str:
    return str(x.numerator) if x.denominator == 1 else f"{x.numerator}/{x.denominator}"


def classify(a: Sequence[Fraction]) -> str:
    disc = log_concavity_operator(a)
    if all(d >= 0 for d in disc):
        if all(d == 0 for d in disc):
            return "log-LINEAR (L a = 0)"
        return "log-CONCAVE (L a >= 0)"
    if all(d < 0 for d in disc):
        return "strictly log-CONVEX (L a < 0)"
    if all(d <= 0 for d in disc):
        return "log-CONVEX (L a <= 0)"
    return "neither (mixed signs)"


def show_sequence(name: str, seq: Sequence[Fraction], depth: int = 4) -> None:
    print(f"\n=== {name} ===")
    print("  terms :", ", ".join(fmt(x) for x in seq[:10]), "...")
    print("  L a   :", ", ".join(fmt(x) for x in log_concavity_operator(seq)[:8]), "...")
    print("  class :", classify(seq))
    v = first_violation(seq, depth)
    if v is None:
        print(f"  infinite log-concavity: no violation up to depth {depth} "
              f"(window permitting)")
    else:
        k, n, val = v
        print(f"  infinite log-concavity FAILS: (L^{k} a)({n}) = {fmt(val)} < 0")


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_geometric() -> None:
    """d = 1: 2^n is annihilated by L, hence infinitely log-concave."""
    seq = geometric(Fraction(2), 14)
    show_sequence("d = 1 totals: powers of two 2^n", seq)
    disc = log_concavity_operator(seq)
    assert all(x == 0 for x in disc), "L should annihilate a geometric sequence"
    print("  CHECK: L(2^n) is identically zero  -> infinitely log-concave.")


def demo_catalan() -> None:
    """d = 2: Catalan numbers are strictly log-convex."""
    seq = catalan(14)
    show_sequence("d = 2 totals: Catalan numbers", seq)
    disc = log_concavity_operator(seq)
    assert all(x < 0 for x in disc), "Catalan discriminant should be < 0 everywhere"
    # Verify the exact identity behind the sign: (L C)(n) = -12(2n+1)/((n+2)^2(n+3)) C_n^2
    for n in range(len(disc)):
        predicted = -Fraction(12 * (2 * n + 1), (n + 2) ** 2 * (n + 3)) * seq[n] ** 2
        assert disc[n] == predicted, f"closed form mismatch at n={n}"
    print("  CHECK: (L C)(n) = -12(2n+1)/((n+2)^2 (n+3)) * C_n^2  < 0 for all n.")
    print("         Witness: C_1^2 = 1 < 2 = C_0 * C_2.")


def demo_baxter() -> None:
    """d = 3: Baxter numbers are (empirically) strictly log-convex."""
    seq = baxter(14)
    show_sequence("d = 3 totals: Baxter numbers", seq)
    disc = log_concavity_operator(seq)
    assert all(x < 0 for x in disc), "Baxter discriminant should be < 0 in this range"
    print("  CHECK: L B < 0 at every computed index (mirrors the Catalan case).")


def demo_key_identity() -> None:
    """The exact identity (2n+3)(n+2) - (2n+1)(n+3) = 3 driving log-convexity."""
    print("\n=== Key identity ===")
    for n in range(6):
        lhs = (2 * n + 3) * (n + 2) - (2 * n + 1) * (n + 3)
        assert lhs == 3
        print(f"  n={n}: (2n+3)(n+2) - (2n+1)(n+3) = {lhs}")
    print("  The stubborn residue 3 never cancels -> negative discriminant.")


def demo_dichotomy_table() -> None:
    """Side-by-side summary of the dichotomy."""
    print("\n=== Dichotomy summary ===")
    print(f"  {'d':>2}  {'sequence':<18}{'classification':<30}{'inf. log-concave?'}")
    rows: List[Tuple[int, str, Callable[[int], List[Fraction]]]] = [
        (1, "2^n", lambda L: geometric(Fraction(2), L)),
        (2, "Catalan C_n", catalan),
        (3, "Baxter B_n", baxter),
    ]
    for d, label, gen in rows:
        seq = gen(14)
        cls = classify(seq)
        yes = first_violation(seq, 6) is None
        print(f"  {d:>2}  {label:<18}{cls:<30}{'YES' if yes else 'NO'}")


def main() -> None:
    print("Log-Concavity Dichotomy for the Total d-Hoggatt Numbers")
    print("=" * 60)
    demo_geometric()
    demo_catalan()
    demo_baxter()
    demo_key_identity()
    demo_dichotomy_table()
    print("\nAll assertions passed (exact arithmetic).")


if __name__ == "__main__":
    main()
