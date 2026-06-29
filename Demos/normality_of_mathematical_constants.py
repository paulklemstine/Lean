"""
demo.py — Numerical demonstrations for the combinatorial theory of simple normality
of digit streams.

This script is fully self-contained (standard library only) and illustrates every
core result of the accompanying paper:

  * countDigit / freq / SimplyNormal primitives
  * the conservation law          sum_d countDigit(s,d,n) = n
  * the simplex constraint        sum_d freq(s,d,n)       = 1   (n > 0)
  * monotonicity of the count
  * the single-coordinate obstruction
  * the cyclic stream cyc_b(k) = k mod b: periodicity, exact count,
    O(1) discrepancy, and convergence of frequencies to 1/b

Run:  python3 demo.py
"""

from __future__ import annotations

from typing import Callable, Dict, List

# A digit stream is a function s : N -> {0, ..., b-1}.
DigitStream = Callable[[int], int]


# --------------------------------------------------------------------------- #
# Core combinatorial primitives (mirror the Lean definitions)
# --------------------------------------------------------------------------- #
def count_digit(s: DigitStream, d: int, n: int) -> int:
    """Number of indices k < n with s(k) == d  (== countDigit s d n)."""
    return sum(1 for k in range(n) if s(k) == d)


def freq(s: DigitStream, d: int, n: int) -> float:
    """Empirical frequency of digit d in the first n terms (junk value 0 at n=0)."""
    if n == 0:
        return 0.0
    return count_digit(s, d, n) / n


def is_simply_normal_window(s: DigitStream, b: int, n: int, tol: float) -> bool:
    """Heuristic finite-window check: every digit frequency within tol of 1/b."""
    return all(abs(freq(s, d, n) - 1.0 / b) <= tol for d in range(b))


# --------------------------------------------------------------------------- #
# Example streams
# --------------------------------------------------------------------------- #
def cyc(b: int) -> DigitStream:
    """The cyclic / round-robin stream cyc_b(k) = k mod b (periodic, simply normal)."""
    return lambda k: k % b


def constant_stream(value: int) -> DigitStream:
    """Degenerate stream that always emits the same digit (NOT simply normal)."""
    return lambda k: value


def digits_of_real(x: float, b: int) -> DigitStream:
    """
    Base-b digit stream of x in [0,1) via the multiply-by-b map:
        d_n = floor(b * (b^n x mod 1)).
    (Float precision limits this to the first ~15-50 base-b digits; for serious
    use one would carry exact arithmetic. Here it illustrates the bridge.)
    """
    def s(n: int) -> int:
        y = (x * (b ** n)) % 1.0
        return min(int(y * b), b - 1)
    return s


# --------------------------------------------------------------------------- #
# Exact count for the cyclic stream (Theorem cyc_count_bounds):
#     countDigit(cyc_b, d, n) = n // b + (1 if d < n % b else 0)
# --------------------------------------------------------------------------- #
def cyc_count_closed_form(b: int, d: int, n: int) -> int:
    return n // b + (1 if d < n % b else 0)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_conservation_and_simplex(b: int = 10, n: int = 137) -> None:
    print("=" * 70)
    print(f"Conservation law & simplex constraint  (base b={b}, window n={n})")
    print("-" * 70)
    s = digits_of_real(0.123456789, b)
    counts = [count_digit(s, d, n) for d in range(b)]
    total = sum(counts)
    freqs = [freq(s, d, n) for d in range(b)]
    print(f"counts per digit : {counts}")
    print(f"sum of counts    : {total}   (must equal n = {n})  -> {total == n}")
    print(f"sum of freqs     : {sum(freqs):.12f}   (must equal 1)")
    assert total == n, "conservation law violated!"
    assert abs(sum(freqs) - 1.0) < 1e-9, "simplex constraint violated!"
    print("OK: counts partition the window; frequencies live on the simplex.")
    print()


def demo_monotonicity(b: int = 7) -> None:
    print("=" * 70)
    print(f"Monotonicity of the digit count  (base b={b}, digit d=3)")
    print("-" * 70)
    s = cyc(b)
    prev = 0
    monotone = True
    for n in range(0, 40):
        c = count_digit(s, 3, n)
        if c < prev:
            monotone = False
        prev = c
    print(f"count_digit(cyc_{b}, 3, n) for n=0..39 is non-decreasing: {monotone}")
    assert monotone
    print()


def demo_obstruction(b: int = 10, n: int = 500) -> None:
    print("=" * 70)
    print(f"Single-coordinate obstruction  (constant stream, base b={b})")
    print("-" * 70)
    s = constant_stream(4)  # every digit is 4
    f4 = freq(s, 4, n)
    f0 = freq(s, 0, n)
    print(f"freq(digit 4) -> {f4}  (tends to 1, not 1/{b})")
    print(f"freq(digit 0) -> {f0}  (tends to 0, not 1/{b})")
    print(f"is simply normal (window)? "
          f"{is_simply_normal_window(s, b, n, tol=0.05)}  (expected False)")
    assert not is_simply_normal_window(s, b, n, tol=0.05)
    print("OK: one coordinate converging to the wrong value forbids normality.")
    print()


def demo_cyclic_normality(b: int = 10) -> None:
    print("=" * 70)
    print(f"Cyclic stream cyc_{b}: closed-form count, O(1) discrepancy, convergence")
    print("-" * 70)
    s = cyc(b)
    # Verify the closed-form count formula against brute force.
    ok_formula = all(
        count_digit(s, d, n) == cyc_count_closed_form(b, d, n)
        for n in range(0, 200)
        for d in range(b)
    )
    print(f"closed-form count matches brute force (n<200, all d): {ok_formula}")
    assert ok_formula

    # Discrepancy |count - n/b| <= 1 uniformly.
    max_disc = max(
        abs(count_digit(s, d, n) - n / b)
        for n in range(1, 2000)
        for d in range(b)
    )
    print(f"max discrepancy |count - n/b| over n<2000 : {max_disc:.4f}  (<= 1)")
    assert max_disc <= 1.0 + 1e-9

    # Frequency convergence to 1/b.
    print(f"\n  digit 0 frequency approaching 1/{b} = {1/b}:")
    for n in (10, 100, 1000, 10000, 100000):
        print(f"    n={n:>7}  freq(0)={freq(s, 0, n):.6f}")
    final = freq(s, 0, 100000)
    assert abs(final - 1.0 / b) < 1.0 / 100000 + 1e-9
    print("OK: cyc is simply normal (frequencies -> 1/b).")
    print()


def demo_periodicity_means_rational(b: int = 10) -> None:
    print("=" * 70)
    print(f"Periodicity: cyc_{b} is rational yet simply normal")
    print("-" * 70)
    s = cyc(b)
    periodic = all(s(k + b) == s(k) for k in range(100))
    print(f"cyc_{b}(k+{b}) == cyc_{b}(k) for k=0..99 : {periodic}")
    assert periodic
    # The corresponding real number 0.(0123...{b-1}) repeating is rational.
    block = "".join(str(s(k)) for k in range(b))
    print(f"repeating block of digits : {block}")
    print("=> the number 0." + block + block + "... is RATIONAL,")
    print("   yet (by demo_cyclic_normality) it is simply normal.")
    print("   Hence: simple normality does NOT imply irrationality/transcendence.")
    print()


def main() -> None:
    demo_conservation_and_simplex()
    demo_monotonicity()
    demo_obstruction()
    demo_cyclic_normality()
    demo_periodicity_means_rational()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
