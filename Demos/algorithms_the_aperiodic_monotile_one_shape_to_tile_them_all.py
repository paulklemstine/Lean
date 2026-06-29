#!/usr/bin/env python3
"""
Algorithms for the Aperiodic Monotile Algebraic Theory

Type-hinted implementations of key algorithms from the research paper.
"""

import math
from typing import Tuple, List, Optional


def hat_trace(n: int) -> int:
    """
    Compute the n-th term of the hat trace sequence.

    The trace sequence a(n) = tr(M^n) = λ^n + μ^n where
    λ = 2 + √3 and μ = 2 - √3 are the eigenvalues of the
    hat substitution matrix.

    Satisfies the recurrence: a(n+2) = 4a(n+1) - a(n)
    with a(0) = 2, a(1) = 4.

    Time: O(n), Space: O(1)
    """
    if n == 0:
        return 2
    if n == 1:
        return 4
    prev2, prev1 = 2, 4
    for _ in range(2, n + 1):
        prev2, prev1 = prev1, 4 * prev1 - prev2
    return prev1


def hat_companion(n: int) -> int:
    """
    Compute the n-th term of the hat companion sequence.

    The companion sequence b(n) = (λ^n - μ^n)/(λ - μ)
    satisfies the same recurrence: b(n+2) = 4b(n+1) - b(n)
    with b(0) = 0, b(1) = 1.

    Time: O(n), Space: O(1)
    """
    if n == 0:
        return 0
    if n == 1:
        return 1
    prev2, prev1 = 0, 1
    for _ in range(2, n + 1):
        prev2, prev1 = prev1, 4 * prev1 - prev2
    return prev1


def hat_trace_and_companion(n: int) -> Tuple[int, int]:
    """
    Compute both a(n) and b(n) simultaneously.

    More efficient than computing separately when both are needed.
    Invariant: a(k)² - 12·b(k)² = 4 for all k.

    Time: O(n), Space: O(1)
    """
    if n == 0:
        return (2, 0)
    if n == 1:
        return (4, 1)
    a_prev2, a_prev1 = 2, 4
    b_prev2, b_prev1 = 0, 1
    for _ in range(2, n + 1):
        a_prev2, a_prev1 = a_prev1, 4 * a_prev1 - a_prev2
        b_prev2, b_prev1 = b_prev1, 4 * b_prev1 - b_prev2
    return (a_prev1, b_prev1)


def is_pisot_quadratic(trace: int, det: int) -> bool:
    """
    Determine if the 2x2 integer matrix with given trace and determinant
    has eigenvalues forming a Pisot pair (λ > 1, 0 < |μ| < 1).

    The eigenvalues are (trace ± √discriminant) / 2 where
    discriminant = trace² - 4·det.

    Returns True if the larger eigenvalue exceeds 1 and the smaller
    eigenvalue has absolute value less than 1.
    """
    disc = trace * trace - 4 * det
    if disc < 0:
        return False  # Complex eigenvalues
    sqrt_disc = math.sqrt(disc)
    lambda_val = (trace + sqrt_disc) / 2
    mu_val = (trace - sqrt_disc) / 2
    return lambda_val > 1 and abs(mu_val) < 1


def verify_no_period(max_n: int) -> bool:
    """
    Verify that tr(M^n) ≠ 2 for n = 1, ..., max_n.

    This is a computational check of the no-period theorem.
    The theorem proves this holds for ALL n ≥ 1, but this function
    provides numerical verification up to max_n.

    Returns True if no period is found.
    """
    a_prev2, a_prev1 = 2, 4
    for n in range(1, max_n + 1):
        if n <= 1:
            if a_prev1 == 2:
                return False
        else:
            a_next = 4 * a_prev1 - a_prev2
            if a_next == 2:
                return False
            a_prev2, a_prev1 = a_prev1, a_next
    return True


def pell_equation_solutions(max_n: int) -> List[Tuple[int, int]]:
    """
    Generate solutions (x, y) to x² - 12y² = 4 using the hat recurrence.

    Each pair (a(n), b(n)) is a solution. These are ALL non-negative
    solutions to the generalized Pell equation.

    Returns list of (x, y) pairs for n = 0, ..., max_n.
    """
    solutions = []
    a_prev2, a_prev1 = 2, 4
    b_prev2, b_prev1 = 0, 1
    for n in range(max_n + 1):
        if n == 0:
            solutions.append((2, 0))
        elif n == 1:
            solutions.append((4, 1))
        else:
            a_next = 4 * a_prev1 - a_prev2
            b_next = 4 * b_prev1 - b_prev2
            solutions.append((a_next, b_next))
            a_prev2, a_prev1 = a_prev1, a_next
            b_prev2, b_prev1 = b_prev1, b_next
    return solutions


def quadratic_recurrence_general(
    trace: int, det: int, n: int
) -> Tuple[int, int]:
    """
    Compute the n-th terms of the general quadratic recurrence pair.

    For a 2x2 matrix with given trace and determinant:
    - a(n+2) = trace·a(n+1) - det·a(n), a(0)=2, a(1)=trace
    - b(n+2) = trace·b(n+1) - det·b(n), b(0)=0, b(1)=1

    Returns (a(n), b(n)).
    """
    if n == 0:
        return (2, 0)
    if n == 1:
        return (trace, 1)
    a2, a1 = 2, trace
    b2, b1 = 0, 1
    for _ in range(2, n + 1):
        a2, a1 = a1, trace * a1 - det * a2
        b2, b1 = b1, trace * b1 - det * b2
    return (a1, b1)


def hat_matrix_power(n: int) -> Tuple[Tuple[int, int], Tuple[int, int]]:
    """
    Compute M^n for the hat substitution matrix M = [[2,1],[3,2]]
    using the trace and companion sequences.

    M^n = b(n)·M - b(n-1)·I = [[a(n)+a(n-1)·...]]

    Actually uses the Cayley-Hamilton reconstruction:
    M^n = b(n)·M - det(M)·b(n-1)·I

    where b(n) is the companion sequence and det(M) = 1.

    Returns ((m00, m01), (m10, m11)).
    """
    if n == 0:
        return ((1, 0), (0, 1))
    if n == 1:
        return ((2, 1), (3, 2))

    # Using M = [[2,1],[3,2]], we compute M^n directly
    # M^n can be expressed as: b(n)·M - b(n-1)·I
    bn = hat_companion(n)
    bn1 = hat_companion(n - 1) if n >= 1 else 0

    m00 = 2 * bn - bn1
    m01 = bn
    m10 = 3 * bn
    m11 = 2 * bn - bn1
    # Wait, this needs correction. Let me use direct matrix multiplication.

    # Direct approach via repeated squaring
    def mat_mul(
        a: Tuple[Tuple[int, int], Tuple[int, int]],
        b_mat: Tuple[Tuple[int, int], Tuple[int, int]],
    ) -> Tuple[Tuple[int, int], Tuple[int, int]]:
        return (
            (
                a[0][0] * b_mat[0][0] + a[0][1] * b_mat[1][0],
                a[0][0] * b_mat[0][1] + a[0][1] * b_mat[1][1],
            ),
            (
                a[1][0] * b_mat[0][0] + a[1][1] * b_mat[1][0],
                a[1][0] * b_mat[0][1] + a[1][1] * b_mat[1][1],
            ),
        )

    result = ((1, 0), (0, 1))
    base = ((2, 1), (3, 2))
    exp = n
    while exp > 0:
        if exp % 2 == 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        exp //= 2
    return result


def discriminant_analysis(
    trace_min: int, trace_max: int, det: int = 1
) -> List[dict]:
    """
    Analyze the discriminant tr² - 4·det for a range of traces.

    Identifies which trace values give:
    - Perfect square discriminant → rational eigenvalues (periodic possible)
    - Non-square discriminant → irrational eigenvalues (aperiodic)
    """
    results = []
    for tr in range(trace_min, trace_max + 1):
        disc = tr * tr - 4 * det
        if disc < 0:
            kind = "complex"
            is_square = False
        else:
            sqrt_disc = int(math.isqrt(disc))
            is_square = sqrt_disc * sqrt_disc == disc
            kind = "rational" if is_square else "irrational"

        results.append({
            "trace": tr,
            "det": det,
            "discriminant": disc,
            "is_perfect_square": is_square,
            "eigenvalue_type": kind,
            "is_pisot": is_pisot_quadratic(tr, det),
        })
    return results


if __name__ == "__main__":
    # Quick validation
    print("Hat trace sequence (first 10):", [hat_trace(n) for n in range(10)])
    print("Hat companion sequence (first 10):", [hat_companion(n) for n in range(10)])
    print("Pell solutions (first 8):", pell_equation_solutions(7))
    print("Is Pisot (tr=4, det=1):", is_pisot_quadratic(4, 1))
    print("No period up to 1000:", verify_no_period(1000))

    print("\nDiscriminant analysis (det=1):")
    for r in discriminant_analysis(0, 8):
        print(f"  tr={r['trace']}: disc={r['discriminant']}, "
              f"type={r['eigenvalue_type']}, pisot={r['is_pisot']}")
