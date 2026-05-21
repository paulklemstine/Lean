#!/usr/bin/env python3
"""
algorithms.py — Core algorithms from the non-commutative Module-LWE framework.

Implements:
1. Exact TVD computation for finite distributions
2. Pushforward / coarse-graining computation
3. Contraction slack analysis
4. Hybrid telescope verification
5. Non-commutative group ring arithmetic (S3 over F_p)
"""

from fractions import Fraction
from typing import List, Callable, Dict, Tuple, Optional
import random


# ─── Algorithm 1: Exact TVD ─────────────────────────────────────────────

def exact_tvd(mu: List[Fraction], nu: List[Fraction]) -> Fraction:
    """
    Compute the exact total variation distance between two distributions.

    d_TV(μ, ν) = (1/2) Σ_i |μ(i) - ν(i)|

    Args:
        mu: Probability distribution as list of Fractions (sums to 1)
        nu: Probability distribution as list of Fractions (sums to 1)

    Returns:
        Exact TVD as a Fraction

    Complexity: O(n) time, O(1) space where n = |support|

    Example:
        >>> mu = [Fraction(1,3), Fraction(1,3), Fraction(1,3)]
        >>> nu = [Fraction(1,2), Fraction(1,4), Fraction(1,4)]
        >>> exact_tvd(mu, nu)
        Fraction(1, 6)
    """
    assert len(mu) == len(nu), "Distributions must have same support size"
    return sum(abs(mu[i] - nu[i]) for i in range(len(mu))) / 2


# ─── Algorithm 2: Pushforward ───────────────────────────────────────────

def pushforward(
    f: Callable[[int], int],
    mu: List[Fraction],
    domain_size: int,
    codomain_size: int
) -> List[Fraction]:
    """
    Compute the pushforward distribution f_* μ.

    (f_*μ)(b) = Σ_{a : f(a)=b} μ(a)

    Args:
        f: Function from {0,...,domain_size-1} to {0,...,codomain_size-1}
        mu: Distribution on the domain
        domain_size: Size of the domain
        codomain_size: Size of the codomain

    Returns:
        Distribution on the codomain

    Complexity: O(domain_size) time

    Example:
        >>> f = lambda x: x % 3
        >>> mu = [Fraction(1,6)] * 6
        >>> pushforward(f, mu, 6, 3)
        [Fraction(1, 3), Fraction(1, 3), Fraction(1, 3)]
    """
    result = [Fraction(0)] * codomain_size
    for a in range(domain_size):
        result[f(a)] += mu[a]
    return result


# ─── Algorithm 3: Contraction Slack ─────────────────────────────────────

def contraction_slack(
    f: Callable[[int], int],
    mu: List[Fraction],
    nu: List[Fraction],
    domain_size: int,
    codomain_size: int
) -> Tuple[Fraction, Fraction, Fraction]:
    """
    Compute the TVD contraction slack under pushforward.

    Returns (d_before, d_after, slack) where:
        d_before = d_TV(μ, ν)
        d_after  = d_TV(f_*μ, f_*ν)
        slack    = d_before - d_after ≥ 0  (by data processing inequality)

    Args:
        f: Function from domain to codomain
        mu, nu: Distributions on the domain
        domain_size, codomain_size: Sizes

    Returns:
        Tuple of (d_before, d_after, slack) as exact Fractions

    Complexity: O(domain_size + codomain_size) time
    """
    d_before = exact_tvd(mu, nu)
    mu_push = pushforward(f, mu, domain_size, codomain_size)
    nu_push = pushforward(f, nu, domain_size, codomain_size)
    d_after = exact_tvd(mu_push, nu_push)
    slack = d_before - d_after
    assert slack >= 0, f"Contraction violation! slack = {slack}"
    return d_before, d_after, slack


# ─── Algorithm 4: Fiber Analysis ────────────────────────────────────────

def fiber_analysis(
    f: Callable[[int], int],
    mu: List[Fraction],
    nu: List[Fraction],
    domain_size: int,
    codomain_size: int
) -> Dict[int, Dict]:
    """
    Analyze the fiber structure of a function and its effect on distributions.

    For each output value b, computes:
    - fiber size |f^{-1}(b)|
    - fiberwise mass under μ and ν
    - fiberwise signed measure (μ - ν) restricted to fiber
    - whether the fiber is sign-coherent

    Args:
        f: Function from domain to codomain
        mu, nu: Distributions on the domain
        domain_size, codomain_size: Sizes

    Returns:
        Dictionary mapping each codomain element to fiber statistics

    Complexity: O(domain_size) time
    """
    fibers: Dict[int, Dict] = {}

    for b in range(codomain_size):
        fibers[b] = {
            'size': 0,
            'mu_mass': Fraction(0),
            'nu_mass': Fraction(0),
            'signed_diffs': [],
            'sign_coherent': True
        }

    for a in range(domain_size):
        b = f(a)
        fibers[b]['size'] += 1
        fibers[b]['mu_mass'] += mu[a]
        fibers[b]['nu_mass'] += nu[a]
        fibers[b]['signed_diffs'].append(mu[a] - nu[a])

    for b in range(codomain_size):
        diffs = fibers[b]['signed_diffs']
        if len(diffs) > 0:
            signs = set(1 if d > 0 else (-1 if d < 0 else 0) for d in diffs)
            signs.discard(0)
            fibers[b]['sign_coherent'] = len(signs) <= 1
        fibers[b]['abs_mass_diff'] = abs(fibers[b]['mu_mass'] - fibers[b]['nu_mass'])
        fibers[b]['sum_abs_diffs'] = sum(abs(d) for d in diffs)

    return fibers


# ─── Algorithm 5: Hybrid Telescope ──────────────────────────────────────

def verify_telescope(
    hybrids: List[List[Fraction]]
) -> Tuple[Fraction, Fraction, bool, float]:
    """
    Verify the hybrid telescope bound for a sequence of distributions.

    d_TV(H_0, H_n) ≤ Σ_i d_TV(H_i, H_{i+1})

    Args:
        hybrids: List of distributions (each a list of Fractions)

    Returns:
        Tuple of (total_tvd, sum_steps, holds, tightness_ratio)

    Complexity: O(n * |support|) where n = len(hybrids)
    """
    n = len(hybrids)
    assert n >= 2, "Need at least 2 hybrid distributions"

    total_tvd = exact_tvd(hybrids[0], hybrids[-1])
    step_tvds = [exact_tvd(hybrids[i], hybrids[i + 1]) for i in range(n - 1)]
    sum_steps = sum(step_tvds)

    holds = total_tvd <= sum_steps
    ratio = float(total_tvd / sum_steps) if sum_steps > 0 else 1.0

    return total_tvd, sum_steps, holds, ratio


# ─── Algorithm 6: S3 Group Ring Arithmetic ───────────────────────────────

class S3GroupRing:
    """
    Arithmetic in the group ring F_p[S3].

    Elements of S3 are indexed 0-5:
        0=e, 1=(12), 2=(13), 3=(23), 4=(123), 5=(132)

    An element of F_p[S3] is a list of 6 coefficients in F_p.

    This is a non-commutative ring (since S3 is non-abelian).
    """

    # S3 multiplication table
    MULT_TABLE = [
        [0, 1, 2, 3, 4, 5],  # e * _
        [1, 0, 4, 5, 2, 3],  # (12) * _
        [2, 5, 0, 4, 3, 1],  # (13) * _
        [3, 4, 5, 0, 1, 2],  # (23) * _
        [4, 3, 1, 2, 5, 0],  # (123) * _
        [5, 2, 3, 1, 0, 4],  # (132) * _
    ]

    ELEMENT_NAMES = ["e", "(12)", "(13)", "(23)", "(123)", "(132)"]

    def __init__(self, p: int):
        """Initialize group ring F_p[S3]."""
        self.p = p

    def multiply(self, a: List[int], b: List[int]) -> List[int]:
        """Multiply two elements of F_p[S3]."""
        result = [0] * 6
        for i in range(6):
            for j in range(6):
                k = self.MULT_TABLE[i][j]
                result[k] = (result[k] + a[i] * b[j]) % self.p
        return result

    def add(self, a: List[int], b: List[int]) -> List[int]:
        """Add two elements of F_p[S3]."""
        return [(a[i] + b[i]) % self.p for i in range(6)]

    def scalar_mult(self, c: int, a: List[int]) -> List[int]:
        """Scalar multiplication by c ∈ F_p."""
        return [(c * a[i]) % self.p for i in range(6)]

    def is_commutative_pair(self, a: List[int], b: List[int]) -> bool:
        """Check if a*b = b*a."""
        return self.multiply(a, b) == self.multiply(b, a)

    def left_mult_map(self, a: List[int]) -> Callable[[int], int]:
        """
        Return the left-multiplication-by-a map as a function
        on the regular representation F_p^6.

        Maps an element index (0 to p^6-1) encoding coefficients
        to another element index.
        """
        def f(x_idx: int) -> int:
            # Decode x from index
            x = []
            temp = x_idx
            for _ in range(6):
                x.append(temp % self.p)
                temp //= self.p
            # Multiply: a * x
            result = self.multiply(a, x)
            # Encode result as index
            idx = 0
            for i in range(5, -1, -1):
                idx = idx * self.p + result[i]
            return idx
        return f

    def format_element(self, a: List[int]) -> str:
        """Format a group ring element as a string."""
        terms = []
        for i in range(6):
            if a[i] != 0:
                if a[i] == 1:
                    terms.append(self.ELEMENT_NAMES[i])
                else:
                    terms.append(f"{a[i]}·{self.ELEMENT_NAMES[i]}")
        return " + ".join(terms) if terms else "0"


# ─── Algorithm 7: Non-Commutative Module-LWE Instance ───────────────────

class NoncommModuleLWEInstance:
    """
    A non-commutative Module-LWE instance.

    Parameterized by:
    - A domain (secret space) of size domain_size
    - A codomain (sample space) of size codomain_size
    - A linear map f : domain → codomain
    - A secret distribution
    - A noise distribution
    - A reference (uniform) distribution
    - Number of samples
    """

    def __init__(
        self,
        domain_size: int,
        codomain_size: int,
        linear_map: Callable[[int], int],
        secret_dist: List[Fraction],
        noise_dist: List[Fraction],
        uniform_dist: List[Fraction],
        num_samples: int
    ):
        self.domain_size = domain_size
        self.codomain_size = codomain_size
        self.linear_map = linear_map
        self.secret_dist = secret_dist
        self.noise_dist = noise_dist
        self.uniform_dist = uniform_dist
        self.num_samples = num_samples

    def one_step_advantage(self) -> Fraction:
        """Compute the one-step advantage d_TV(f_* secret, uniform)."""
        secret_push = pushforward(
            self.linear_map, self.secret_dist,
            self.domain_size, self.codomain_size
        )
        return exact_tvd(secret_push, self.uniform_dist)

    def decision_advantage_bound(self) -> Fraction:
        """Compute the decision advantage bound: samples * one_step."""
        return self.num_samples * self.one_step_advantage()

    def verify_contraction(self, other_dist: List[Fraction]) -> bool:
        """Verify TVD contraction for secret_dist vs other_dist."""
        _, _, slack = contraction_slack(
            self.linear_map, self.secret_dist, other_dist,
            self.domain_size, self.codomain_size
        )
        return slack >= 0


# ─── Example Usage ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # 1. Exact TVD
    mu = [Fraction(1, 4), Fraction(1, 4), Fraction(1, 4), Fraction(1, 4)]
    nu = [Fraction(1, 2), Fraction(1, 6), Fraction(1, 6), Fraction(1, 6)]
    print(f"1. Exact TVD: {exact_tvd(mu, nu)} = {float(exact_tvd(mu, nu)):.6f}")

    # 2. Pushforward
    f = lambda x: x % 2
    pushed = pushforward(f, mu, 4, 2)
    print(f"2. Pushforward (mod 2): {pushed}")

    # 3. Contraction slack
    d_b, d_a, slack = contraction_slack(f, mu, nu, 4, 2)
    print(f"3. Contraction: before={float(d_b):.4f}, after={float(d_a):.4f}, slack={float(slack):.4f}")

    # 4. S3 non-commutativity
    R = S3GroupRing(5)
    a = [1, 2, 0, 0, 0, 0]
    b = [0, 0, 1, 3, 0, 0]
    print(f"4. S3 non-commutative: {R.format_element(a)} * {R.format_element(b)}")
    print(f"   = {R.format_element(R.multiply(a, b))}")
    print(f"   Commutes: {R.is_commutative_pair(a, b)}")

    # 5. Module-LWE instance
    q = 7
    secret = [Fraction(w, sum([10,5,1,0,0,1,5])) for w in [10, 5, 1, 0, 0, 1, 5]]
    uniform = [Fraction(1, q)] * q
    noise = uniform  # uniform noise
    instance = NoncommModuleLWEInstance(
        domain_size=q, codomain_size=q,
        linear_map=lambda s: (3 * s) % q,
        secret_dist=secret, noise_dist=noise,
        uniform_dist=uniform, num_samples=5
    )
    print(f"5. Module-LWE one-step advantage: {float(instance.one_step_advantage()):.6f}")
    print(f"   Decision bound (5 samples): {float(instance.decision_advantage_bound()):.6f}")
