#!/usr/bin/env python3
"""
Algorithms for Self-Avoiding Walk Theory

Type-hinted implementations of key algorithms from the SAW theory formalization.
"""

from typing import List, Tuple, Set, Dict, Optional
import math


def count_saws_backtrack(n: int) -> int:
    """
    Count self-avoiding walks of length n on Z^2 starting at origin.

    Algorithm: Depth-first backtracking search.
    Complexity: O(3^n) time (each step has at most 3 choices, since we can't go back).

    Args:
        n: Walk length (non-negative integer).

    Returns:
        Number of self-avoiding walks of length n.
    """
    if n == 0:
        return 1

    directions: List[Tuple[int, int]] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    count: int = 0

    def backtrack(x: int, y: int, steps: int, visited: Set[Tuple[int, int]]) -> None:
        nonlocal count
        if steps == n:
            count += 1
            return
        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                backtrack(nx, ny, steps + 1, visited)
                visited.remove((nx, ny))

    visited: Set[Tuple[int, int]] = {(0, 0)}
    backtrack(0, 0, 0, visited)
    return count


def connective_constant_approx(saw_counts: List[int]) -> List[float]:
    """
    Approximate the connective constant from SAW count data.

    For a submultiplicative sequence c(n), the connective constant is
    μ = lim c(n)^{1/n} = inf_{n≥1} c(n)^{1/n}.

    Args:
        saw_counts: List of c(0), c(1), ..., c(N).

    Returns:
        List of approximations c(n)^{1/n} for n = 1, ..., N.
    """
    approx: List[float] = []
    for n in range(1, len(saw_counts)):
        cn = saw_counts[n]
        if cn > 0:
            approx.append(cn ** (1.0 / n))
        else:
            approx.append(0.0)
    return approx


def tropical_valuation(x: float) -> float:
    """
    Compute the tropical valuation of a positive real number.

    val(x) = -log(x)

    This maps multiplication to addition: val(xy) = val(x) + val(y).

    Args:
        x: Positive real number.

    Returns:
        Tropical valuation -log(x).
    """
    assert x > 0, "Tropical valuation requires positive input"
    return -math.log(x)


def tropical_polynomial_eval(coefficients: List[float], v: float) -> float:
    """
    Evaluate a tropical polynomial at v.

    The tropical polynomial trop(Σ a_i x^i) is max_i(val(a_i) + i*v).

    Args:
        coefficients: List of tropical valuations of coefficients [val(a_0), val(a_1), ...].
        v: Point at which to evaluate.

    Returns:
        max_i(coefficients[i] + i * v).
    """
    return max(coefficients[i] + i * v for i in range(len(coefficients)))


def fekete_ratio_sequence(subadditive_seq: List[float]) -> List[float]:
    """
    Compute the Fekete ratio a(n)/n for a subadditive sequence.

    By Fekete's lemma, if a is subadditive, then a(n)/n → inf_{n≥1} a(n)/n.

    Args:
        subadditive_seq: Values a(0), a(1), ..., a(N).

    Returns:
        List of ratios a(n)/n for n = 1, ..., N.
    """
    ratios: List[float] = []
    for n in range(1, len(subadditive_seq)):
        ratios.append(subadditive_seq[n] / n)
    return ratios


def nienhuis_constant() -> float:
    """
    Compute the Nienhuis constant √(2 + √2).

    This is the connective constant of the hexagonal lattice.
    It satisfies x^4 - 4x^2 + 2 = 0.

    Returns:
        The Nienhuis constant ≈ 1.84776.
    """
    return math.sqrt(2 + math.sqrt(2))


def verify_submultiplicativity(seq: List[int]) -> bool:
    """
    Verify that a sequence is submultiplicative: a(m+n) <= a(m)*a(n).

    Args:
        seq: Sequence values a(0), a(1), ..., a(N).

    Returns:
        True if submultiplicativity holds for all tested pairs.
    """
    n = len(seq)
    for m in range(n):
        for k in range(n - m):
            if seq[m + k] > seq[m] * seq[k]:
                return False
    return True


def radius_of_convergence(saw_counts: List[int]) -> float:
    """
    Estimate the radius of convergence of Σ c(n) x^n.

    R = 1/μ where μ = inf c(n)^{1/n}.

    Args:
        saw_counts: SAW counts c(0), ..., c(N).

    Returns:
        Estimated radius of convergence.
    """
    mu_approx = min(
        saw_counts[n] ** (1.0 / n)
        for n in range(1, len(saw_counts))
        if saw_counts[n] > 0
    )
    return 1.0 / mu_approx


def bridge_saw_count(n: int) -> int:
    """
    Count bridge SAWs of length n on Z^2 starting at origin.

    A bridge SAW is one where the endpoint has strictly maximal
    first coordinate among all visited points.

    Args:
        n: Walk length.

    Returns:
        Number of bridge SAWs of length n.
    """
    if n == 0:
        return 0  # Bridge must have positive length

    directions: List[Tuple[int, int]] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    count: int = 0

    def backtrack(x: int, y: int, steps: int,
                  visited: Set[Tuple[int, int]], max_x: int) -> None:
        nonlocal count
        if steps == n:
            if x > max_x - 1:  # endpoint has strictly max x
                # Check: x must be strictly greater than all OTHER visited x
                if all(x > vx for (vx, vy) in visited if (vx, vy) != (x, y)):
                    count += 1
            return
        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                backtrack(nx, ny, steps + 1, visited, max(max_x, nx))
                visited.remove((nx, ny))

    visited: Set[Tuple[int, int]] = {(0, 0)}
    backtrack(0, 0, 0, visited, 0)
    return count


if __name__ == "__main__":
    # Verify SAW counts
    print("SAW counts c(n):")
    for n in range(8):
        c = count_saws_backtrack(n)
        print(f"  c({n}) = {c}")

    # Verify submultiplicativity
    counts = [count_saws_backtrack(n) for n in range(8)]
    print(f"\nSubmultiplicativity holds: {verify_submultiplicativity(counts)}")

    # Connective constant approximation
    approx = connective_constant_approx(counts)
    print(f"\nConnective constant approximations c(n)^(1/n):")
    for i, a in enumerate(approx):
        print(f"  n={i+1}: {a:.6f}")

    # Nienhuis constant
    mu_hex = nienhuis_constant()
    print(f"\nNienhuis constant: {mu_hex:.10f}")
    print(f"Minimal poly check: {mu_hex**4 - 4*mu_hex**2 + 2:.2e}")

    # Radius of convergence
    R = radius_of_convergence(counts)
    print(f"\nRadius of convergence ≈ {R:.6f}")

    # Bridge counts
    print(f"\nBridge SAW counts:")
    for n in range(1, 7):
        b = bridge_saw_count(n)
        print(f"  b({n}) = {b}")
