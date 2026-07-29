#!/usr/bin/env python3
"""Numerical demonstrations for character-twisted power sums modulo four."""

from __future__ import annotations

from typing import Callable, Iterable


def chi_four(a: int) -> int:
    """Return the primitive quadratic character modulo four at a."""
    residue = a % 4
    if residue == 1:
        return 1
    if residue == 3:
        return -1
    return 0


def twisted_power_sum(k: int, m: int, x: int) -> int:
    """Compute sum_{a=1}^m chi_four(a) * (x+a)^k directly."""
    if k < 0 or m < 0:
        raise ValueError("k and m must be nonnegative")
    return sum(chi_four(a) * (x + a) ** k for a in range(1, m + 1))


def linear_closed_form(q: int, x: int = 0) -> int:
    """Evaluate the degree-one sum over q complete periods."""
    if q < 0:
        raise ValueError("q must be nonnegative")
    _ = x  # The exact value is translation-invariant.
    return -2 * q


def quadratic_closed_form(q: int, x: int) -> int:
    """Evaluate the degree-two sum over q complete periods."""
    if q < 0:
        raise ValueError("q must be nonnegative")
    return -4 * q * (x + 2 * q)


def is_even_power_candidate(value: int, exponent: int) -> bool:
    """Test whether an integer is an integral power with the given even exponent."""
    if exponent < 2 or exponent % 2:
        raise ValueError("exponent must be even and at least two")
    if value < 0:
        return False
    lo, hi = 0, max(1, value)
    while lo <= hi:
        mid = (lo + hi) // 2
        power = mid**exponent
        if power == value:
            return True
        if power < value:
            lo = mid + 1
        else:
            hi = mid - 1
    return False


def verify_closed_forms(q_values: Iterable[int], x_values: Iterable[int]) -> None:
    """Assert agreement between direct sums and both closed forms."""
    for q in q_values:
        for x in x_values:
            direct_linear = twisted_power_sum(1, 4 * q, x)
            direct_quadratic = twisted_power_sum(2, 4 * q, x)
            assert direct_linear == linear_closed_form(q, x)
            assert direct_quadratic == quadratic_closed_form(q, x)


def print_table(title: str, rows: list[tuple[object, ...]]) -> None:
    """Print a compact text table."""
    print(f"\n{title}")
    for row in rows:
        print("  " + " | ".join(str(item) for item in row))


def main() -> None:
    """Run exact-formula, sign-threshold, and perfect-power demonstrations."""
    verify_closed_forms(range(0, 9), range(-20, 21))
    print("Closed forms agree with direct summation for q=0,...,8 and x=-20,...,20.")

    linear_rows = [
        (f"q={q}", f"S_1(4q,x)={linear_closed_form(q)}", "independent of x")
        for q in range(1, 5)
    ]
    print_table("Linear complete-period values", linear_rows)

    quadratic_rows = [
        (f"q={q}", f"S_2(4q,0)={quadratic_closed_form(q, 0)}")
        for q in range(1, 5)
    ]
    print_table("Quadratic values at x=0", quadratic_rows)

    q = 3
    threshold_rows = [
        (f"x={x}", f"S_2(12,x)={quadratic_closed_form(q, x)}")
        for x in (-7, -6, -5)
    ]
    print_table("Sharp sign transition for q=3", threshold_rows)

    for q in range(1, 9):
        for x in range(-2 * q + 1, 11):
            value = quadratic_closed_form(q, x)
            assert value < 0
            for exponent in (2, 4, 6):
                assert not is_even_power_candidate(value, exponent)
    print("Negativity excludes exponents 2, 4, and 6 throughout the sampled quadratic range.")

    # Sharpness examples outside the exclusion hypotheses.
    assert quadratic_closed_form(1, -3) == 4 == 2**2
    assert linear_closed_form(4) == -8 == (-2) ** 3
    print("Sharpness: S_2(4,-3)=4=2^2 and S_1(16,x)=-8=(-2)^3.")


if __name__ == "__main__":
    main()
