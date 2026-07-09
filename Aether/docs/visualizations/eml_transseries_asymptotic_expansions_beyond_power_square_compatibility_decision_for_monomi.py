from math import sqrt
from typing import Dict, Optional, Tuple

TransMono = Dict[int, float]

def term_sqrt(g: TransMono, a: float
              ) -> Optional[Tuple[TransMono, float]]:
    """Return (k, sqrt a) with term(k,sqrt a)^2 = term(g,a), or None.

    None encodes 'not a square' (a<0) per not_square_negative_monomial.
    """
    if a < 0:
        return None
    k: TransMono = {h: p / 2.0 for h, p in g.items()}
    return k, sqrt(a)
