#!/usr/bin/env python3
"""
Holographic Depth Algebra: Core Algorithms

Type-hinted implementations of the key algorithms from the
Holographic Depth Algebra framework.
"""

import math
from typing import Callable, Dict, List, Optional, Tuple


# ============================================================
# Core Data Structures
# ============================================================

class HolographicDepthAlgebra:
    """A Holographic Depth Algebra with customizable boundary weights.

    The canonical instance uses w(p) = log(p), yielding depth(n) = log(n).
    """

    def __init__(self, weight: Optional[Callable[[int], float]] = None):
        """Initialize with a weight function w: prime -> R+.

        Args:
            weight: Boundary weight function. Default: w(p) = log(p).
        """
        self.weight = weight or (lambda p: math.log(p))

    def depth(self, n: int) -> float:
        """Compute holographic depth from prime factorization.

        depth(n) = sum_{p | n} v_p(n) * w(p)

        Args:
            n: A positive integer.

        Returns:
            The holographic depth of n.
        """
        if n <= 0:
            raise ValueError(f"n must be positive, got {n}")
        if n == 1:
            return 0.0
        factors = self._factorize(n)
        return sum(exp * self.weight(p) for p, exp in factors.items())

    def local_partition(self, p: int, beta: float) -> float:
        """Local partition function Z_p(beta) = (1 - p^{-beta})^{-1}.

        Args:
            p: A prime number.
            beta: Inverse temperature (must be positive).

        Returns:
            The local partition function value.
        """
        return 1.0 / (1.0 - p ** (-beta))

    def local_free_energy(self, p: int, beta: float) -> float:
        """Local free energy F_p(beta) = log(1 - p^{-beta}).

        Args:
            p: A prime number.
            beta: Inverse temperature (must be positive).

        Returns:
            The local free energy (always non-positive for beta > 0).
        """
        return math.log(1.0 - p ** (-beta))

    def boltzmann(self, p: int, beta: float) -> float:
        """Boltzmann weight b_p(beta) = p^{-beta}.

        Args:
            p: A prime number.
            beta: Inverse temperature.

        Returns:
            The Boltzmann weight.
        """
        return p ** (-beta)

    def boundary_entropy(self, p: int) -> float:
        """Boundary entropy S(p) = log(p).

        Args:
            p: A prime number.

        Returns:
            The boundary entropy of prime p.
        """
        return math.log(p)

    @staticmethod
    def _factorize(n: int) -> Dict[int, int]:
        """Compute prime factorization of n."""
        factors: Dict[int, int] = {}
        d = 2
        while d * d <= n:
            while n % d == 0:
                factors[d] = factors.get(d, 0) + 1
                n //= d
            d += 1
        if n > 1:
            factors[n] = factors.get(n, 0) + 1
        return factors


# ============================================================
# Arithmetic RG Flow
# ============================================================

class ArithmeticRGFlow:
    """Arithmetic Renormalization Group operator.

    R_beta(f)(n) = f(n) * n^{-beta}

    Satisfies the semigroup law: R_alpha . R_beta = R_{alpha + beta}
    """

    def __init__(self, f: Callable[[int], float]):
        """Initialize with base function f.

        Args:
            f: Arithmetic function f: N -> R.
        """
        self.f = f

    def rescale(self, beta: float, n: int) -> float:
        """Apply RG operator at depth beta.

        Args:
            beta: Depth parameter.
            n: Positive integer.

        Returns:
            f(n) * n^{-beta}
        """
        if n <= 0:
            raise ValueError(f"n must be positive, got {n}")
        return self.f(n) * n ** (-beta)

    def dirichlet_partial_sum(self, beta: float, N: int) -> float:
        """Compute partial Dirichlet series sum_{n=1}^{N} f(n) * n^{-beta}.

        Args:
            beta: Depth parameter (Re(s) in Dirichlet series).
            N: Upper summation bound.

        Returns:
            The partial sum.
        """
        return sum(self.rescale(beta, n) for n in range(1, N + 1))


# ============================================================
# Holographic Reconstruction
# ============================================================

def holographic_reconstruct_additive(
    boundary_data: Dict[int, float],
    n: int
) -> float:
    """Reconstruct bulk value from boundary data for completely additive f.

    Given f(p) for primes p, computes f(n) = sum v_p(n) * f(p).

    Args:
        boundary_data: Dictionary {prime: f(prime)} of boundary values.
        n: Positive integer to reconstruct.

    Returns:
        The reconstructed value f(n).
    """
    if n <= 0:
        raise ValueError(f"n must be positive, got {n}")
    if n == 1:
        return 0.0
    factors = HolographicDepthAlgebra._factorize(n)
    return sum(exp * boundary_data.get(p, 0.0) for p, exp in factors.items())


def holographic_reconstruct_multiplicative(
    boundary_data: Dict[Tuple[int, int], float],
    n: int
) -> float:
    """Reconstruct bulk value from boundary data for multiplicative f.

    Given f(p^k) for prime powers, computes f(n) = prod f(p^{v_p(n)}).

    Args:
        boundary_data: Dictionary {(p, k): f(p^k)} of boundary values.
        n: Positive integer to reconstruct.

    Returns:
        The reconstructed value f(n).
    """
    if n <= 0:
        raise ValueError(f"n must be positive, got {n}")
    if n == 1:
        return 1.0
    factors = HolographicDepthAlgebra._factorize(n)
    result = 1.0
    for p, exp in factors.items():
        result *= boundary_data.get((p, exp), 1.0)
    return result


# ============================================================
# Euler Product Computation
# ============================================================

def euler_product(beta: float, prime_bound: int = 10000) -> float:
    """Compute the Euler product approximation to zeta(beta).

    zeta(beta) = prod_{p <= prime_bound} (1 - p^{-beta})^{-1}

    Args:
        beta: Must be > 1 for convergence.
        prime_bound: Upper bound for primes in the product.

    Returns:
        Approximate value of zeta(beta).
    """
    hda = HolographicDepthAlgebra()
    product = 1.0
    d = 2
    while d <= prime_bound:
        if _is_prime(d):
            product *= hda.local_partition(d, beta)
        d += 1
    return product


def _is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


# ============================================================
# Entropy Bound Verification
# ============================================================

def verify_entropy_bound(p: int, beta: float) -> Tuple[float, float, bool]:
    """Verify the holographic entropy bound: -F_p(beta) <= b/(1-b).

    Args:
        p: A prime number.
        beta: Inverse temperature > 0.

    Returns:
        Tuple of (lhs, rhs, is_satisfied).
    """
    hda = HolographicDepthAlgebra()
    lhs = -hda.local_free_energy(p, beta)
    b = hda.boltzmann(p, beta)
    rhs = b / (1.0 - b)
    return (lhs, rhs, lhs <= rhs + 1e-15)


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    hda = HolographicDepthAlgebra()

    # Demonstrate depth computation
    print("Holographic depths (canonical HDA):")
    for n in [1, 2, 6, 12, 60, 360]:
        print(f"  depth({n}) = {hda.depth(n):.6f}")

    # Demonstrate reconstruction
    print("\nHolographic reconstruction (additive, f(p) = 1):")
    boundary = {2: 1.0, 3: 1.0, 5: 1.0, 7: 1.0, 11: 1.0}
    for n in [1, 2, 4, 6, 12, 60]:
        val = holographic_reconstruct_additive(boundary, n)
        factors = HolographicDepthAlgebra._factorize(n) if n > 1 else {}
        omega = sum(factors.values())
        print(f"  f({n}) = {val:.0f} = Ω({n}) = {omega}")

    # Demonstrate RG flow
    print("\nRG semigroup verification:")
    rg = ArithmeticRGFlow(lambda n: float(n))
    for n in [2, 5, 10]:
        v1 = rg.rescale(1.0, n) * n ** (-2.0)  # R_2(R_1(id))
        v2 = rg.rescale(3.0, n)                  # R_3(id)
        print(f"  R_2(R_1(id))({n}) = {v1:.6f}, R_3(id)({n}) = {v2:.6f}")

    # Euler product
    print("\nEuler product approximations:")
    for s in [2.0, 3.0, 4.0]:
        val = euler_product(s, 1000)
        print(f"  ζ({s:.0f}) ≈ {val:.10f}")
