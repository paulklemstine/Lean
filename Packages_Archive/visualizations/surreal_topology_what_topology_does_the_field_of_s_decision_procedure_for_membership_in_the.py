from fractions import Fraction
from typing import Dict, Optional, Tuple


def is_finite_surreal(terms: Dict[Fraction, Fraction]) -> bool:
    """Decide whether a surreal (given on the omega-scale as a map
    exponent -> coefficient) lies in the clopen set F of finite surreals.

    A surreal is finite iff it is dominated by some natural number, which on the
    leading-exponent model is exactly the condition that its largest nonzero
    exponent is <= 0.  Runs in O(#terms) to find the leading exponent."""
    nonzero = {e: c for e, c in terms.items() if c != 0}
    if not nonzero:
        return True  # the number 0 is finite
    leading_exponent = max(nonzero.keys())
    return leading_exponent <= 0
