#!/usr/bin/env python3
"""
Algorithms for Non-Standard Arithmetic

Type-hinted implementations of the key algorithms underlying
the ultrapower construction and transfer theorems.
"""

from typing import List, Set, Callable, Optional, Tuple
import math


class UltrafilterSim:
    """Simulates a free ultrafilter on ℕ using a 'principal-at-infinity' heuristic.

    A true free ultrafilter is non-constructive (requires Zorn's Lemma).
    This simulation decides membership by checking eventual behavior:
    a set S is 'in U' if S contains {n, n+1, n+2, ...} for some n.

    This captures the essential intuition: free ultrafilters on ℕ
    concentrate measure at infinity.
    """

    def __init__(self, threshold: int = 100):
        self.threshold = threshold

    def is_large(self, membership_fn: Callable[[int], bool]) -> bool:
        """Check if {i | membership_fn(i)} is 'U-large'."""
        # Heuristic: check if eventually true
        return all(membership_fn(i) for i in range(self.threshold, self.threshold + 50))

    def select_value(self, fn: Callable[[int], int], finite_range: List[int]) -> int:
        """Given fn: ℕ → finite set, return the U-selected value.
        This implements ultrafilter_finite_image_resolution."""
        for val in finite_range:
            if self.is_large(lambda i, v=val: fn(i) == v):
                return val
        raise ValueError("No value selected (should not happen with a genuine ultrafilter)")


class NonstdNatElement:
    """Represents an element of ℕ* as a sequence ℕ → ℕ."""

    def __init__(self, seq: Callable[[int], int], name: str = ""):
        self.seq = seq
        self.name = name

    def __repr__(self) -> str:
        if self.name:
            return f"NonstdNat({self.name})"
        vals = [self.seq(i) for i in range(8)]
        return f"NonstdNat([{', '.join(map(str, vals))}, ...])"

    @staticmethod
    def standard(n: int) -> 'NonstdNatElement':
        """The standard embedding: std(n) = [n, n, n, ...]."""
        return NonstdNatElement(lambda _: n, f"std({n})")

    @staticmethod
    def omega() -> 'NonstdNatElement':
        """The canonical infinite element: ω = [0, 1, 2, 3, ...]."""
        return NonstdNatElement(lambda i: i, "ω")

    @staticmethod
    def omega_factorial() -> 'NonstdNatElement':
        """The infinitely divisible element: ω! = [0!, 1!, 2!, ...]."""
        return NonstdNatElement(lambda i: math.factorial(i), "ω!")

    @staticmethod
    def nth_prime_seq() -> 'NonstdNatElement':
        """The infinite prime: p* = [p₀, p₁, p₂, ...]."""
        primes: List[int] = []

        def get_nth_prime(n: int) -> int:
            while len(primes) <= n:
                candidate = primes[-1] + 1 if primes else 2
                while True:
                    if all(candidate % d != 0 for d in range(2, int(math.sqrt(candidate)) + 1)):
                        primes.append(candidate)
                        break
                    candidate += 1
            return primes[n]

        return NonstdNatElement(get_nth_prime, "p*")

    def add(self, other: 'NonstdNatElement') -> 'NonstdNatElement':
        """Pointwise addition."""
        return NonstdNatElement(
            lambda i: self.seq(i) + other.seq(i),
            f"({self.name} + {other.name})" if self.name and other.name else ""
        )

    def mul(self, other: 'NonstdNatElement') -> 'NonstdNatElement':
        """Pointwise multiplication."""
        return NonstdNatElement(
            lambda i: self.seq(i) * other.seq(i),
            f"({self.name} × {other.name})" if self.name and other.name else ""
        )

    def le(self, other: 'NonstdNatElement', U: UltrafilterSim) -> bool:
        """Check self ≤ other in ℕ*."""
        return U.is_large(lambda i: self.seq(i) <= other.seq(i))

    def dvd(self, other: 'NonstdNatElement', U: UltrafilterSim) -> bool:
        """Check self | other in ℕ* (internal divisibility)."""
        return U.is_large(lambda i: self.seq(i) != 0 and other.seq(i) % self.seq(i) == 0)

    def is_prime(self, U: UltrafilterSim) -> bool:
        """Check internal primality."""
        def is_nat_prime(n: int) -> bool:
            if n < 2:
                return False
            return all(n % d != 0 for d in range(2, int(math.sqrt(n)) + 1))
        return U.is_large(lambda i: is_nat_prime(self.seq(i)))


def transfer_algorithm(
    property_fn: Callable[[int], bool],
    U: UltrafilterSim
) -> bool:
    """Transfer a property from ℕ to ℕ* via the ultrafilter.

    Given a property P: ℕ → Prop and an ultrafilter U,
    returns whether {i | P(i)} ∈ U.

    This is the computational version of the transfer principle:
    a first-order property holds in ℕ* iff it holds on a U-large set.
    """
    return U.is_large(property_fn)


def overspill_witness(
    property_fn: Callable[[int, int], bool],
    U: UltrafilterSim,
    max_search: int = 1000
) -> Optional[int]:
    """Find an overspill witness: if P(i, n) holds for all standard n
    on U-large sets, find a non-standard bound N beyond all tested n.

    Returns the largest n for which P(·, n) is U-large.
    """
    best_n = 0
    for n in range(max_search):
        if U.is_large(lambda i, n=n: property_fn(i, n)):
            best_n = n
        else:
            break
    return best_n


def descending_chain(start: int, length: int) -> List[NonstdNatElement]:
    """Construct a descending chain in ℕ*:
    ω, ω-1, ω-2, ..., ω-length
    where subtraction is truncating (as in ℕ)."""
    return [
        NonstdNatElement(
            lambda i, k=k: max(0, i - k),
            f"ω-{k}" if k > 0 else "ω"
        )
        for k in range(length)
    ]


def geometric_sum(p: int, n: int) -> int:
    """Compute Σ_{k=0}^{n-1} p^k = (p^n - 1)/(p - 1)."""
    if p == 1:
        return n
    return (p**n - 1) // (p - 1)


def padic_valuation(n: int, p: int) -> int:
    """Compute v_p(n) = max k such that p^k | n."""
    if n == 0:
        return float('inf')  # type: ignore
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def legendre_formula(n: int, p: int) -> int:
    """Compute v_p(n!) using Legendre's formula:
    v_p(n!) = Σ_{k≥1} ⌊n/p^k⌋"""
    result = 0
    pk = p
    while pk <= n:
        result += n // pk
        pk *= p
    return result


if __name__ == "__main__":
    U = UltrafilterSim(threshold=50)

    print("=== Algorithm Demonstrations ===\n")

    # Demonstrate transfer
    omega = NonstdNatElement.omega()
    pstar = NonstdNatElement.nth_prime_seq()
    omega_fact = NonstdNatElement.omega_factorial()

    print(f"ω = {omega}")
    print(f"p* = {pstar}")
    print(f"ω! = {omega_fact}")
    print()

    # Check ordering
    for n in [10, 100]:
        std_n = NonstdNatElement.standard(n)
        print(f"std({n}) ≤ ω: {std_n.le(omega, U)}")
        print(f"std({n}) ≤ p*: {std_n.le(pstar, U)}")

    print()

    # Check primality
    print(f"isPrime(p*): {pstar.is_prime(U)}")

    # Check divisibility
    for n in [2, 3, 5, 7, 100]:
        std_n = NonstdNatElement.standard(n)
        print(f"{n} | ω!: {std_n.dvd(omega_fact, U)}")

    print()

    # Descending chain
    chain = descending_chain(0, 5)
    print("Descending chain:")
    for elem in chain:
        print(f"  {elem}")

    # Geometric bound
    print("\nGeometric sum bounds:")
    for p in [2, 3]:
        for n in [4, 8]:
            gs = geometric_sum(p, n)
            print(f"  Σ_{{k<{n}}} {p}^k = {gs} ≤ {p}^{n} = {p**n}")

    # Legendre formula bridge
    print("\nLegendre formula (p-adic bridge):")
    for p in [2, 3, 5]:
        for n in [10, 50, 100]:
            v = legendre_formula(n, p)
            approx = n / (p - 1)
            print(f"  v_{p}({n}!) = {v}, n/(p-1) = {approx:.1f}, ratio = {v/approx:.4f}")
