"""
Graded Descent Complexity: Certificate Depth as Complexity Exponent

Type-hinted implementations of the core algorithms and data structures
for computing certificate depth profiles, adversarial descent constructions,
and the single-power gap ratio analysis.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Optional
import math


@dataclass
class DescentSystem:
    """A finite descent system with a measure function.

    The state space is implicitly {0, 1, ..., num_states-1}.
    The measure function maps each state to a natural number.
    The descent relation connects states with strictly decreasing measures.
    """
    dim: int
    num_states: int
    measure: Callable[[int], int]
    can_descend: Callable[[int, int], bool]

    def worst_case(self) -> int:
        """Maximum measure over all states."""
        return max(self.measure(s) for s in range(self.num_states))

    def longest_descent_chain(self) -> list[int]:
        """Find the longest descent chain by greedy exploration."""
        # Start from the state with maximum measure
        start = max(range(self.num_states), key=self.measure)
        chain = [start]
        current = start
        while True:
            # Find the successor with smallest measure (greedy)
            successors = [
                t for t in range(self.num_states)
                if self.can_descend(current, t)
            ]
            if not successors:
                break
            next_state = min(successors, key=self.measure)
            chain.append(next_state)
            current = next_state
        return chain


def adversarial_system(d: int) -> DescentSystem:
    """Construct the adversarial descent system for dimension d.

    State space: {0, 1, ..., d^d}
    Measure: identity function
    Descent: s -> t iff t + 1 = s
    Achieves worst-case descent length exactly d^d.
    """
    n = d ** d + 1
    return DescentSystem(
        dim=d,
        num_states=n,
        measure=lambda s: s,
        can_descend=lambda s, t: t + 1 == s,
    )


def certificate_depth_profile(d: int, k: int) -> int:
    """Compute T(d, k) = d^(d-k), the certificate depth profile.

    This is the theoretical upper bound on worst-case descent length
    for a depth-k system in dimension d.
    """
    if k > d:
        return 1  # Convention: d^0 = 1 when k > d
    return d ** (d - k)


def depth_decrement(d: int, k: int, c: float = 1.0) -> float:
    """Compute the depth-parameterized decrement δ(d, k) = c / d^(d-k).

    This is the minimum potential decrease per descent step at depth k.
    """
    if d == 0:
        return float('inf')
    return c / (d ** (d - k))


def graded_descent_bound(
    d: int, k: int, c: float, C0: float, D: int
) -> float:
    """Compute the graded descent upper bound: C0 * D * d^(d-k) / c.

    Args:
        d: dimension
        k: certificate depth
        c: decrement constant
        C0: potential range constant
        D: diameter bound

    Returns:
        Upper bound on descent chain length.
    """
    if c <= 0 or d <= 0:
        return float('inf')
    return C0 * D * (d ** (d - k)) / c


def single_power_gap_ratio(
    d: int, k: int, worst_case: int
) -> dict[str, float]:
    """Compute diagnostic ratios for the single-power gap conjecture.

    Args:
        d: dimension
        k: certificate depth
        worst_case: observed worst-case descent length

    Returns:
        Dictionary with:
        - 'tight_ratio': worst_case / d^(d-k), should converge to c_k > 0 if tight
        - 'slack_ratio': worst_case / d^(d-k-1), converges to 0 if tight, c_k if slack
        - 'log_ratio': log(worst_case) / ((d-k) * log(d)), approaches 1 if tight
    """
    profile = certificate_depth_profile(d, k)
    slack_profile = certificate_depth_profile(d, k + 1) if k < d else 1

    tight_ratio = worst_case / profile if profile > 0 else float('inf')
    slack_ratio = worst_case / slack_profile if slack_profile > 0 else float('inf')

    if worst_case > 0 and d > 1 and d > k:
        log_ratio = math.log(worst_case) / ((d - k) * math.log(d))
    else:
        log_ratio = float('nan')

    return {
        'tight_ratio': tight_ratio,
        'slack_ratio': slack_ratio,
        'log_ratio': log_ratio,
    }


@dataclass
class DepthHierarchy:
    """Represents the complete depth hierarchy for a given dimension d."""
    d: int
    profiles: list[int] = field(default_factory=list)

    def compute(self) -> None:
        """Compute T(d, k) for k = 0, 1, ..., d."""
        self.profiles = [
            certificate_depth_profile(self.d, k)
            for k in range(self.d + 1)
        ]

    def ratios(self) -> list[float]:
        """Compute consecutive profile ratios T(d,k)/T(d,k+1)."""
        if not self.profiles:
            self.compute()
        return [
            self.profiles[k] / self.profiles[k + 1]
            for k in range(len(self.profiles) - 1)
        ]

    def is_strict(self) -> bool:
        """Check that the hierarchy is strictly decreasing."""
        if not self.profiles:
            self.compute()
        return all(
            self.profiles[k] > self.profiles[k + 1]
            for k in range(len(self.profiles) - 1)
        ) if self.d >= 2 else True


@dataclass
class ProductSystem:
    """Product of two descent systems."""
    D1: DescentSystem
    D2: DescentSystem

    def worst_case(self) -> int:
        """Worst case of product = sum of worst cases."""
        return self.D1.worst_case() + self.D2.worst_case()

    def dim(self) -> int:
        return self.D1.dim + self.D2.dim


def iterated_product_worst_case(d: int, n: int) -> int:
    """Worst case of n-fold product of adversarial system in dim d.

    Returns n * d^d.
    """
    return n * (d ** d)


def entropy_bound(num_states: int) -> int:
    """Information-theoretic lower bound on worst-case descent length.

    If the measure is injective, then worst_case >= log2(num_states) - 1.
    """
    if num_states <= 1:
        return 0
    return int(math.log2(num_states))


def scan_conjecture(
    k: int,
    d_range: range,
    system_constructor: Optional[Callable[[int], DescentSystem]] = None,
) -> list[dict]:
    """Scan the single-power gap conjecture for given k and d range.

    For each d, constructs the adversarial system (or user-provided system),
    computes worst-case, and returns the diagnostic ratios.

    Args:
        k: certificate depth
        d_range: range of dimensions to scan
        system_constructor: optional custom system builder

    Returns:
        List of {d, worst_case, tight_ratio, slack_ratio, log_ratio} dicts.
    """
    results = []
    for d in d_range:
        if d < k + 1:
            continue
        if system_constructor:
            sys = system_constructor(d)
        else:
            sys = adversarial_system(d)
        wc = sys.worst_case()
        ratios = single_power_gap_ratio(d, k, wc)
        results.append({
            'd': d,
            'k': k,
            'worst_case': wc,
            **ratios,
        })
    return results


def depth_separation_factor(d: int, k1: int, k2: int) -> float:
    """Compute the speedup factor from depth k1 to depth k2.

    Returns d^(k2 - k1) when k1 < k2 <= d.
    """
    if k1 >= k2 or k2 > d:
        return 1.0
    return float(d ** (k2 - k1))
