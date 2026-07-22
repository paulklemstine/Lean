from fractions import Fraction
from typing import Callable, Hashable, Sequence

Challenge = Hashable


def kround_survival_bound(num_challenges: int, k: int) -> Fraction:
    """Upper bound ((|Omega|-1)/|Omega|)^k on k-round survival probability.

    This is the Multi-Round Soundness Amplification bound. Complexity O(log k)
    via exponentiation by squaring on exact rationals.
    """
    if num_challenges <= 0:
        raise ValueError("challenge space must be nonempty")
    return Fraction(num_challenges - 1, num_challenges) ** k


def rounds_for_error(num_challenges: int, k: int) -> int:
    """Smallest number of independent rounds R with survival <= 2^-k.

    Solves ((n-1)/n)^R <= 2^-k for the least integer R. This is Theta(n*k),
    exposing the true round complexity behind the folklore "O(k) rounds".
    """
    import math
    n = num_challenges
    if n <= 1:
        raise ValueError("need at least two challenges for a soundness gap")
    return math.ceil(k * math.log(2) / math.log(n / (n - 1)))


def exact_kround_survival(
    omega: Sequence[Challenge],
    checks: Sequence[Callable[[Challenge], bool]],
) -> Fraction:
    """Exact product of per-round accepting fractions over independent rounds."""
    prob = Fraction(1)
    for check in checks:
        passing = sum(1 for e in omega if check(e))
        prob *= Fraction(passing, len(omega))
    return prob
