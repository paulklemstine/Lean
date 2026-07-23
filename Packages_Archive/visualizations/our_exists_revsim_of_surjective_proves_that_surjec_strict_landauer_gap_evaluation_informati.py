import math
from collections import defaultdict
from typing import Callable, Hashable, Sequence


def landauer_gap_joules(
    domain: Sequence[Hashable],
    f: Callable[[Hashable], Hashable],
    kT: float,
) -> float:
    """Strict Landauer gap (joules): kT * ln 2 * (log2|domain| - log2|image|).

    Positive iff f is non-injective; zero iff f is injective.
    """
    n = len(domain)
    image = {f(a) for a in domain}
    if n == 0 or len(image) == 0:
        return 0.0
    info_erased_bits = math.log2(n) - math.log2(len(image))
    return kT * math.log(2.0) * info_erased_bits
