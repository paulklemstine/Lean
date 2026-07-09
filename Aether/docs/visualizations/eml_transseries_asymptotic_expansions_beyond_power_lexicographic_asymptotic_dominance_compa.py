from typing import Dict, List

Mono = Dict[int, float]  # tower height -> real exponent (zero exponents omitted)


def compare_mono(a: Mono, b: Mono) -> int:
    """Asymptotic dominance comparison of two transmonomials.

    Returns -1, 0, +1 for a < b, a == b, a > b. The order is lexicographic with
    the HIGHEST tower height most significant; within a height the larger real
    exponent dominates. Realizes `mono_lt_mono_of_height` and `mono_lt_mono_same`,
    hence `exp_dominates_pow` (e^x beats x^a for every real a)."""
    heights: List[int] = sorted(set(a) | set(b), reverse=True)
    for h in heights:
        ea, eb = a.get(h, 0.0), b.get(h, 0.0)
        if ea < eb:
            return -1
        if ea > eb:
            return 1
    return 0
