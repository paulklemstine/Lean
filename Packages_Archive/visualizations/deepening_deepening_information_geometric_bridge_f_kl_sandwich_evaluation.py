import math
from typing import Sequence, Tuple

def kl_sandwich(p: Sequence[float], q: Sequence[float]
                ) -> Tuple[float, float, float, bool]:
    """Return (Pinsker lower bound, KL, chi^2 upper bound, chain holds)."""
    tv = sum(abs(pi - qi) for pi, qi in zip(p, q))
    tv_lower = 0.5 * tv ** 2
    kl = sum(pi * math.log(pi / qi) for pi, qi in zip(p, q))
    chi2 = sum((pi - qi) ** 2 / qi for pi, qi in zip(p, q))
    ok = (tv_lower <= kl + 1e-12) and (kl <= chi2 + 1e-12)
    return tv_lower, kl, chi2, ok
