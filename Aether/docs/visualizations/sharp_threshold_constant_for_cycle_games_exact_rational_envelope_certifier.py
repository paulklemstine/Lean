from __future__ import annotations
from fractions import Fraction

def certify_envelope(k: int) -> bool:
    """Exactly certify 3/2 <= c_k < 3 using only integer/rational arithmetic.

    Checks the three exact witnesses used in the proof:
      (1) 2(k-1)/k >= 3/2         (lower base bound)
      (2) 2(k-1)/k <  2           (upper base bound)
      (3) (k-1)*2^(k-2) < 3^(k-1) (exponential dominance)
    and confirms (3/2)^(k-1) <= c_k^(k-1) < 3^(k-1) with c_k^(k-1) exact.
    """
    if k < 4:
        raise ValueError("k must be >= 4")
    avg = Fraction(2 * (k - 1), k)
    assert avg >= Fraction(3, 2) and avg < 2
    assert Fraction(k - 1) * 2 ** (k - 2) < 3 ** (k - 1)
    c_pow = Fraction(k - 1) * avg ** (k - 2)          # = c_k^(k-1), exact
    return Fraction(3, 2) ** (k - 1) <= c_pow < 3 ** (k - 1)

if __name__ == '__main__':
    print(all(certify_envelope(k) for k in range(4,100)))
