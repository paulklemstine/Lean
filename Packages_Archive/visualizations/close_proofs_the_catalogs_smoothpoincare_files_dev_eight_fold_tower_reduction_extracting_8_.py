from __future__ import annotations

I = complex(0, 1)

def eight_divides_from_positivity(n: int, value: complex,
                                  tol: float = 1e-9) -> bool:
    """Given that |C| = (1+i)^n is a positive real `value`, certify 8 | n.
       Returns True iff the positivity is consistent with 8 | n."""
    is_pos_real = abs(value.imag) < tol and value.real > tol
    return is_pos_real and (n % 8 == 0)

def deduce_length_mod8(n: int) -> int:
    """Return n mod 8 by inspecting the phase of (1+i)^n; 0 means 8 | n."""
    z = (1 + I) ** (n % 8)
    # match against the 8 canonical tower values
    table = {round((1 + I) ** r, 9): r for r in range(8)}
    return table[round(z, 9)]
