#!/usr/bin/env python3
"""Numerical demonstrations for signed lattice-state Alexander models.

The script uses only the Python standard library. It enumerates balanced
monotone paths, constructs the T(2, 2k+1) Alexander coefficient family,
builds universal unit-sign state models, and checks product convolution,
reciprocity, normalization, determinant evaluation, and positivity.
"""

from __future__ import annotations

from collections import Counter
from itertools import combinations
from typing import Callable, Dict, Iterable, Iterator, List, Mapping, Sequence, Tuple

CoefficientMap = Dict[int, int]
Path = Tuple[str, ...]
SignedState = Tuple[int, int]  # (area, sign)


def balanced_paths(n: int) -> Iterator[Path]:
    """Yield every word with n east and n north steps."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    length = 2 * n
    for north_positions in combinations(range(length), n):
        north = set(north_positions)
        yield tuple("N" if i in north else "E" for i in range(length))


def east_before_north_area(path: Sequence[str]) -> int:
    """Count ordered east-before-north step pairs in a balanced path."""
    east_seen = 0
    area = 0
    for step in path:
        if step == "E":
            east_seen += 1
        elif step == "N":
            area += east_seen
        else:
            raise ValueError("path steps must be 'E' or 'N'")
    return area


def path_area_distribution(
    n: int, forbidden: Callable[[Path], bool] | None = None
) -> CoefficientMap:
    """Count allowed balanced paths by area."""
    reject = forbidden if forbidden is not None else (lambda _path: False)
    counts: Counter[int] = Counter()
    for path in balanced_paths(n):
        if not reject(path):
            counts[east_before_north_area(path)] += 1
    return dict(sorted(counts.items()))


def torus_alexander(k: int) -> CoefficientMap:
    """Return coefficients of the symmetric Alexander polynomial of T(2,2k+1)."""
    if k < 0:
        raise ValueError("k must be nonnegative")
    return {degree: 1 if (degree + k) % 2 == 0 else -1
            for degree in range(-k, k + 1)}


def evaluate(coefficients: Mapping[int, int], t: int) -> int:
    """Evaluate a Laurent polynomial at a nonzero integer t."""
    if t == 0 and any(degree < 0 for degree in coefficients):
        raise ValueError("cannot evaluate negative powers at zero")
    total = 0
    for degree, coefficient in coefficients.items():
        if degree >= 0:
            total += coefficient * (t ** degree)
        else:
            # The demonstrations evaluate negative degrees only at ±1.
            numerator = coefficient
            denominator = t ** (-degree)
            if numerator % denominator != 0:
                raise ValueError("evaluation is not integral")
            total += numerator // denominator
    return total


def universal_signed_states(coefficients: Mapping[int, int]) -> List[SignedState]:
    """Construct |c_m| unit-sign states of area m for every coefficient c_m."""
    states: List[SignedState] = []
    for degree, coefficient in sorted(coefficients.items()):
        sign = (coefficient > 0) - (coefficient < 0)
        states.extend((degree, sign) for _ in range(abs(coefficient)))
    return states


def signed_coefficients(states: Iterable[SignedState]) -> CoefficientMap:
    """Aggregate unit-sign states into a coefficient dictionary."""
    result: Counter[int] = Counter()
    for area, sign in states:
        result[area] += sign
    return {degree: value for degree, value in sorted(result.items()) if value != 0}


def convolve(left: Mapping[int, int], right: Mapping[int, int]) -> CoefficientMap:
    """Compute sparse Cauchy convolution of two Laurent coefficient maps."""
    result: Counter[int] = Counter()
    for left_degree, left_value in left.items():
        for right_degree, right_value in right.items():
            result[left_degree + right_degree] += left_value * right_value
    return {degree: value for degree, value in sorted(result.items()) if value != 0}


def product_states(left: Iterable[SignedState], right: Iterable[SignedState]) -> List[SignedState]:
    """Form Cartesian product states with additive area and multiplicative sign."""
    left_list = list(left)
    right_list = list(right)
    return [(a + b, sign_a * sign_b)
            for a, sign_a in left_list for b, sign_b in right_list]


def is_palindromic(coefficients: Mapping[int, int]) -> bool:
    """Test c_m = c_-m on the reflected support."""
    degrees = set(coefficients) | {-degree for degree in coefficients}
    return all(coefficients.get(d, 0) == coefficients.get(-d, 0) for d in degrees)


def format_laurent(coefficients: Mapping[int, int]) -> str:
    """Format a sparse Laurent coefficient map in descending degree."""
    terms: List[str] = []
    for degree in sorted(coefficients, reverse=True):
        coefficient = coefficients[degree]
        if coefficient == 0:
            continue
        magnitude = abs(coefficient)
        if degree == 0:
            body = str(magnitude)
        elif degree == 1:
            body = "t" if magnitude == 1 else f"{magnitude}t"
        else:
            body = f"t^{degree}" if magnitude == 1 else f"{magnitude}t^{degree}"
        if not terms:
            terms.append(body if coefficient > 0 else f"-{body}")
        else:
            terms.append((" + " if coefficient > 0 else " - ") + body)
    return "".join(terms) or "0"


def run_demonstrations() -> None:
    """Print and assert the principal numerical examples."""
    print("UNSIGNED MONOTONE-PATH AREA DISTRIBUTIONS")
    for n in range(1, 5):
        distribution = path_area_distribution(n)
        assert all(value >= 0 for value in distribution.values())
        print(f"n={n}: {distribution}")

    print("\nTORUS-KNOT ALEXANDER FAMILY")
    for k in range(0, 7):
        coefficients = torus_alexander(k)
        states = universal_signed_states(coefficients)
        assert signed_coefficients(states) == coefficients
        assert is_palindromic(coefficients)
        assert evaluate(coefficients, 1) == 1
        assert evaluate(coefficients, -1) == ((-1) ** k) * (2 * k + 1)
        if k >= 1:
            assert coefficients[k - 1] == -1
        print(
            f"k={k}, T(2,{2*k+1}): {format_laurent(coefficients)}; "
            f"Delta(1)=1, Delta(-1)={evaluate(coefficients, -1)}"
        )

    print("\nPRODUCT-STATE / CAUCHY-CONVOLUTION CHECK")
    trefoil = torus_alexander(1)
    trefoil_states = universal_signed_states(trefoil)
    via_coefficients = convolve(trefoil, trefoil)
    via_states = signed_coefficients(product_states(trefoil_states, trefoil_states))
    assert via_states == via_coefficients
    print(f"({format_laurent(trefoil)})^2 = {format_laurent(via_coefficients)}")

    print("\nAll positivity, signed reconstruction, reciprocity, evaluation, and product checks passed.")


if __name__ == "__main__":
    run_demonstrations()
