from __future__ import annotations


def ladder_gap_witness(k: int, c: int) -> int:
    """Least n with (2^(n^k) + 2)^c < 2^(n^(k+1)), certifying that consecutive
    rungs of the power ladder powSystem(k) and powSystem(k+1) are NOT
    polynomially comparable (the core of the infinite-height theorem)."""
    n = 0
    while True:
        if (2 ** (n ** k) + 2) ** c < 2 ** (n ** (k + 1)):
            return n
        n += 1


def ladder_gap_witness_with_parity(k: int, c: int, even: bool) -> int:
    """Least n >= c+2 of the chosen parity satisfying the uniform gap, used to
    sandwich the parity-glued intermediate degree (density along the ladder)."""
    n = c + 2
    while True:
        if (n % 2 == 0) == even and (2 ** (n ** k) + 2) ** c < 2 ** (n ** (k + 1)):
            return n
        n += 1
