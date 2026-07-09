from typing import Dict

Mono = Dict[int, float]


def nth_root_mono(m: Mono, n: int) -> Mono:
    """The n-th root of a one-term transseries (transmonomial): divide every real
    exponent by n. Always defined because the value group is the *real* vector
    space of exponents, which is divisible (`valueGroup_divisible`,
    `exists_nthRoot_term`, `isSquare_term`). Over the integer-exponent Laurent
    field this fails (e.g. sqrt(x) needs exponent 1/2): the obstruction
    `laurent_value_group_not_divisible` (2k = 1 has no integer solution)."""
    if n <= 0:
        raise ValueError("n must be positive")
    return {h: e / n for h, e in m.items() if e != 0.0}
