import itertools, math
from typing import Tuple, List

def prob(bits: Tuple[int, ...], p: float) -> float:
    ones = sum(bits)
    return (p ** ones) * ((1.0 - p) ** (len(bits) - ones))

def empirical_coset_exponent(n: int, R_bits: int, p: float, rho: float,
                             syndrome: int = 0) -> float:
    """Estimate the constrained coset exponent by direct enumeration.

    Uses a single-parity-check style linear constraint: the coset is
    {x in F_2^n : sum(x) = syndrome (mod 2)} giving rate (n-1)/n.
    Returns (1/n) log2 of the conditional rho-th guessing moment.
    Complexity: O(2^n * n) time, O(2^n) memory.
    """
    coset: List[Tuple[int, ...]] = [
        v for v in itertools.product((0, 1), repeat=n) if sum(v) % 2 == syndrome
    ]
    weights = [prob(v, p) for v in coset]
    z = sum(weights)
    order = sorted(range(len(coset)), key=lambda i: weights[i], reverse=True)
    moment = sum((weights[i] / z) * (rank ** rho)
                 for rank, i in enumerate(order, start=1))
    return math.log2(moment) / n
