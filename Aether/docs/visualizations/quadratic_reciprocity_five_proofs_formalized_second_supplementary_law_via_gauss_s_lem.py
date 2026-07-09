from __future__ import annotations


def second_supplement_via_gauss(p: int) -> int:
    """Compute (2/p) for an odd prime p by Gauss's lemma and verify the
    exponent formula (-1)^((p^2-1)/8).

    Gauss's lemma: (a/p) = (-1)^mu, where mu counts x in [1,(p-1)/2]
    whose reduced multiple (a*x mod p) exceeds p/2.  For a = 2 the
    count simplifies to floor(p/2) - floor(p/4).
    """
    half = (p - 1) // 2
    mu = sum(1 for x in range(1, half + 1) if (2 * x) % p > p / 2)
    assert mu == p // 2 - p // 4                 # closed form of the count
    assert (mu % 2) == (((p * p - 1) // 8) % 2)  # parity identity mod 8
    return (-1) ** mu
