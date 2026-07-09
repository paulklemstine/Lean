from __future__ import annotations


def field_inverse(a: int, q: int) -> int:
    """Multiplicative inverse of a modulo a prime q, via Fermat's little theorem."""
    return pow(a % q, q - 2, q)


def extract_discrete_log(
    c1: int, s1: int, c2: int, s2: int, q: int
) -> int:
    """Schnorr special-soundness extractor.

    Given two accepting transcripts (A, c1, s1) and (A, c2, s2) sharing the
    commitment A with c1 != c2 (mod q), return the discrete logarithm
        x = (s1 - s2) * (c1 - c2)^{-1}  (mod q)
    which satisfies Y = g^x.
    """
    assert (c1 - c2) % q != 0, "challenges must differ modulo q"
    return ((s1 - s2) * field_inverse(c1 - c2, q)) % q
