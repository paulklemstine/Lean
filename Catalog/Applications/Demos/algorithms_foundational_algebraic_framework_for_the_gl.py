#!/usr/bin/env python3
"""
GL₁ Langlands Bilinear Framework — Core Algorithms

Type-hinted implementations of the bilinear symbol evaluation,
shape-color pairing, and reciprocity verification algorithms.
"""

from typing import List, Tuple, Dict, Optional
from math import gcd, isqrt
from dataclasses import dataclass


def sieve_primes(limit: int) -> List[int]:
    """Sieve of Eratosthenes up to limit."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, isqrt(limit) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def factorize(n: int) -> List[Tuple[int, int]]:
    """Return the prime factorization of n as list of (prime, exponent) pairs."""
    if n <= 1:
        return []
    factors: List[Tuple[int, int]] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            exp = 0
            while n % d == 0:
                n //= d
                exp += 1
            factors.append((d, exp))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors


def legendre_symbol(a: int, p: int) -> int:
    """
    Compute the Legendre symbol (a/p) for odd prime p.

    Uses Euler's criterion: (a/p) ≡ a^((p-1)/2) (mod p).
    Returns +1, -1, or 0.
    """
    a = a % p
    if a == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return 1 if result == 1 else -1


def jacobi_symbol(a: int, n: int) -> int:
    """
    Compute the Jacobi symbol (a/n) for odd positive n.

    Uses the recursive algorithm based on quadratic reciprocity
    and the supplementary laws for -1 and 2.

    Complexity: O(log²(n)) via the binary GCD-like recursion.
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be a positive odd integer")
    if n == 1:
        return 1
    a = a % n
    if a == 0:
        return 0

    result = 1
    while a != 0:
        # Extract factors of 2
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        # Quadratic reciprocity: swap a and n
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


@dataclass
class BilinearSymbol:
    """
    A bilinear symbol σ : ℤ × ℕ → {-1, 0, 1}.

    Satisfies:
    - σ(a₁a₂, b) = σ(a₁,b) · σ(a₂,b)  (left multiplicativity)
    - σ(a, b₁b₂) = σ(a,b₁) · σ(a,b₂)  (right multiplicativity, b₁b₂ ≠ 0)
    - σ(a, b) ∈ {-1, 0, 1}              (value constraint)
    """
    name: str
    _eval: object  # Callable[[int, int], int]

    def __call__(self, a: int, b: int) -> int:
        return self._eval(a, b)

    def verify_bilinearity(self, a1: int, a2: int, b1: int, b2: int) -> bool:
        """Verify the full bilinearity equation at given inputs."""
        if b1 <= 0 or b2 <= 0 or b1 % 2 == 0 or b2 % 2 == 0:
            return True  # Skip invalid inputs
        lhs = self(a1 * a2, b1 * b2)
        rhs = self(a1, b1) * self(a1, b2) * self(a2, b1) * self(a2, b2)
        return lhs == rhs


@dataclass
class ReciprocityData:
    """
    Reciprocity data for a bilinear symbol.

    The correction sign ε(a,b) satisfies:
    - σ(a, b) = ε(a,b) · σ(b, a)  for odd a, b
    - ε(a, b) ∈ {-1, +1}
    - ε(a, b) = ε(b, a)
    """
    correction_sign: object  # Callable[[int, int], int]

    def verify(self, symbol: BilinearSymbol, a: int, b: int) -> bool:
        """Verify the reciprocity law at (a, b)."""
        if a <= 0 or b <= 0 or a % 2 == 0 or b % 2 == 0:
            return True
        lhs = symbol(a, b)
        eps = self.correction_sign(a, b)
        rhs = eps * symbol(b, a)
        return lhs == rhs


def qr_correction_sign(a: int, b: int) -> int:
    """The quadratic reciprocity correction sign (-1)^((a//2)(b//2))."""
    return (-1) ** ((a // 2) * (b // 2))


# Canonical instances
JACOBI = BilinearSymbol("Jacobi", jacobi_symbol)
QR_RECIPROCITY = ReciprocityData(qr_correction_sign)


@dataclass
class ShapeColorPairing:
    """
    The GL₁ shape-color dictionary.

    - shape: quadratic field discriminant d
    - color: the character χ_d given by n ↦ J(d, n)
    - splitting: for prime p, J(d, p) detects splitting in ℚ(√d)
    """
    discriminant: int
    symbol: BilinearSymbol

    def character(self, n: int) -> int:
        """Evaluate the Dirichlet character χ_d at n."""
        if n <= 0 or n % 2 == 0:
            return 0
        return self.symbol(self.discriminant, n)

    def splitting_behavior(self, p: int) -> str:
        """Determine splitting behavior of prime p in ℚ(√d)."""
        val = self.character(p)
        if val == 1:
            return "splits"
        elif val == -1:
            return "inert"
        else:
            return "ramifies"

    def split_primes(self, limit: int) -> List[int]:
        """Find all primes ≤ limit that split in ℚ(√d)."""
        return [p for p in sieve_primes(limit)
                if p > 2 and self.character(p) == 1]

    def inert_primes(self, limit: int) -> List[int]:
        """Find all primes ≤ limit that remain inert in ℚ(√d)."""
        return [p for p in sieve_primes(limit)
                if p > 2 and self.character(p) == -1]


def kernel_at(symbol: BilinearSymbol, b: int) -> List[int]:
    """
    Compute the kernel {a ∈ (ℤ/bℤ)× | σ(a, b) = 1}.

    Returns elements in [1, b-1] that are in the kernel.
    """
    return [a for a in range(1, b) if gcd(a, b) == 1 and symbol(a, b) == 1]


def verify_kernel_closure(symbol: BilinearSymbol, b: int) -> bool:
    """Verify that the kernel is closed under multiplication mod b."""
    ker = set(kernel_at(symbol, b))
    for a1 in ker:
        for a2 in ker:
            if (a1 * a2) % b not in ker:
                return False
    return True


def euler_product_partial(d: int, s: float, limit: int) -> float:
    """
    Compute the partial Euler product
    L_N(s, χ_d) = ∏_{p ≤ N} (1 - χ_d(p) · p^{-s})^{-1}
    """
    product = 1.0
    for p in sieve_primes(limit):
        if p == 2:
            continue
        chi_val = jacobi_symbol(d, p)
        factor = 1.0 - chi_val * (p ** (-s))
        if abs(factor) > 1e-15:
            product /= factor
    return product


if __name__ == "__main__":
    # Quick verification
    print("Bilinearity check:", JACOBI.verify_bilinearity(3, 7, 5, 11))
    print("Reciprocity check:", QR_RECIPROCITY.verify(JACOBI, 3, 5))

    # Shape-color pairing for ℚ(i)
    pairing = ShapeColorPairing(-4, JACOBI)
    print(f"\nSplit primes in ℚ(i) up to 50: {pairing.split_primes(50)}")
    print(f"Inert primes in ℚ(i) up to 50: {pairing.inert_primes(50)}")

    # Kernel structure
    ker = kernel_at(JACOBI, 13)
    print(f"\nKernel of J(·, 13): {ker}")
    print(f"Kernel closure verified: {verify_kernel_closure(JACOBI, 13)}")

    # Euler product convergence
    for N in [100, 1000, 10000]:
        L = euler_product_partial(-4, 1.5, N)
        print(f"L_{N}(1.5, χ₋₄) = {L:.8f}")
