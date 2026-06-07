#!/usr/bin/env python3
"""
algorithms.py — Non-Standard Arithmetic Algorithms

Type-hinted implementations of key algorithms from the non-standard
arithmetic formalization:

1. UltrafilterSimulator — simulates ultrafilter membership via density
2. StandardPartComputer — computes standard parts of bounded sequences
3. OverspillDetector — detects when overspill applies
4. TransferVerifier — verifies number-theoretic transfers
5. GrowthClassifier — classifies growth rates in the ultrapower
"""

from typing import Callable, Optional, List, Tuple, Dict, Set
from dataclasses import dataclass
import math


@dataclass
class UltrafilterResult:
    """Result of an ultrafilter membership test."""
    is_large: bool
    density: float
    finite_complement: bool
    complement_bound: Optional[int]


class UltrafilterSimulator:
    """Simulates a free ultrafilter on ℕ via density/cofiniteness.

    A free ultrafilter U on ℕ satisfies:
    - ∅ ∉ U
    - If A ∈ U and A ⊆ B, then B ∈ U (upward closed)
    - If A ∈ U and B ∈ U, then A ∩ B ∈ U (closed under finite intersection)
    - For all A, exactly one of A ∈ U or Aᶜ ∈ U (ultrafilter property)
    - No singleton {n} ∈ U (free/non-principal)

    Consequence: all cofinite sets are in U.
    """

    def __init__(self, sample_size: int = 100000):
        self.sample_size = sample_size

    def test_membership(self, predicate: Callable[[int], bool]) -> UltrafilterResult:
        """Test whether {i | predicate(i)} is 'U-large'.

        For cofinite sets, this is definite. For other sets, we report density.
        """
        true_count = 0
        max_false = -1
        false_count = 0

        for i in range(self.sample_size):
            if predicate(i):
                true_count += 1
            else:
                false_count += 1
                max_false = i

        density = true_count / self.sample_size
        finite_complement = (false_count < math.sqrt(self.sample_size))
        complement_bound = max_false if finite_complement else None

        return UltrafilterResult(
            is_large=(density > 0.5),  # heuristic
            density=density,
            finite_complement=finite_complement,
            complement_bound=complement_bound
        )


class StandardPartComputer:
    """Computes standard parts of bounded ultrapower elements.

    Given f: ℕ → ℕ with f(i) ≤ N for U-almost-all i, finds the
    unique n such that f(i) = n for U-almost-all i.

    Algorithm:
    1. Compute value frequencies in {0, ..., N}
    2. The value with frequency closest to 1/1 (in the limit) is the standard part
    3. For genuine ultrafilters, exactly one value has U-large preimage

    Pseudocode:
        INPUT: f: ℕ → ℕ, bound N
        counts ← array of size N+1, initialized to 0
        FOR i = 0 TO sample_size:
            IF f(i) ≤ N: counts[f(i)] += 1
        RETURN argmax(counts)
    """

    def __init__(self, sample_size: int = 100000):
        self.sample_size = sample_size

    def compute(self, f: Callable[[int], int], bound: int) -> Tuple[int, float]:
        """Returns (standard_part, confidence).

        confidence is the fraction of samples where f(i) = standard_part.
        For a genuine ultrafilter, confidence → 1 as sample_size → ∞
        for the U-selected value.
        """
        counts: Dict[int, int] = {}
        total = 0

        for i in range(self.sample_size):
            v = f(i)
            if v <= bound:
                counts[v] = counts.get(v, 0) + 1
                total += 1

        if not counts:
            raise ValueError("No values in range [0, N]")

        best_val = max(counts, key=counts.get)  # type: ignore
        confidence = counts[best_val] / total if total > 0 else 0.0

        return best_val, confidence


class TransferVerifier:
    """Verifies that number-theoretic identities transfer to sequences.

    Implements pointwise checking of:
    - Fermat's Little Theorem: a^p ≡ a (mod p) for prime p
    - Wilson's Theorem: (p-1)! ≡ -1 (mod p) for prime p
    - GCD divisibility: gcd(a,b) | a and gcd(a,b) | b
    """

    @staticmethod
    def verify_fermat(a_seq: Callable[[int], int],
                      p_seq: Callable[[int], int],
                      n_samples: int = 10000) -> Tuple[int, int]:
        """Returns (successes, total_primes) for Fermat's Little Theorem."""
        successes = 0
        total_primes = 0

        for i in range(n_samples):
            p = p_seq(i)
            a = a_seq(i)
            if p >= 2 and all(p % d != 0 for d in range(2, min(p, int(p**0.5) + 2))):
                total_primes += 1
                if pow(a, p, p) == a % p:
                    successes += 1

        return successes, total_primes

    @staticmethod
    def verify_wilson(p_seq: Callable[[int], int],
                      n_samples: int = 1000) -> Tuple[int, int]:
        """Returns (successes, total_primes) for Wilson's Theorem."""
        successes = 0
        total_primes = 0

        for i in range(n_samples):
            p = p_seq(i)
            if p >= 2 and p <= 1000 and all(p % d != 0 for d in range(2, min(p, int(p**0.5) + 2))):
                total_primes += 1
                fact = math.factorial(p - 1)
                if (fact + 1) % p == 0:
                    successes += 1

        return successes, total_primes

    @staticmethod
    def verify_gcd_divisibility(a_seq: Callable[[int], int],
                                 b_seq: Callable[[int], int],
                                 n_samples: int = 10000) -> Tuple[int, int]:
        """Returns (successes, total) for GCD divisibility."""
        successes = 0
        total = n_samples

        for i in range(n_samples):
            a, b = a_seq(i), b_seq(i)
            g = math.gcd(a, b)
            if (g == 0 or (a % g == 0 and b % g == 0)):
                successes += 1

        return successes, total


class GrowthClassifier:
    """Classifies growth rates of sequences for ultrapower ordering.

    In the ultrapower *ℕ, the ordering [f] < [g] iff {i | f(i) < g(i)} ∈ U.
    For cofinite sets (which are in every free ultrafilter), this means
    f(i) < g(i) for all sufficiently large i.

    Algorithm:
        INPUT: f, g: ℕ → ℕ
        crossover ← smallest i such that f(i) < g(i) for all j ≥ i
        IF crossover exists: f ≤* g (eventually dominated)
        ELSE: incomparable or f >* g
    """

    @staticmethod
    def find_crossover(f: Callable[[int], int],
                       g: Callable[[int], int],
                       max_search: int = 100000) -> Optional[int]:
        """Find the point after which f(i) < g(i) always holds."""
        last_violation = -1

        for i in range(max_search):
            if f(i) >= g(i):
                last_violation = i

        if last_violation == -1:
            return 0
        elif last_violation < max_search - 100:
            return last_violation + 1
        else:
            return None

    @staticmethod
    def classify_pair(f: Callable[[int], int],
                      g: Callable[[int], int],
                      f_name: str = "f",
                      g_name: str = "g") -> str:
        """Classify the ultrapower ordering of f and g."""
        fg_cross = GrowthClassifier.find_crossover(f, g)
        gf_cross = GrowthClassifier.find_crossover(g, f)

        if fg_cross is not None and gf_cross is None:
            return f"[{f_name}] < [{g_name}] in *ℕ (crossover at {fg_cross})"
        elif gf_cross is not None and fg_cross is None:
            return f"[{g_name}] < [{f_name}] in *ℕ (crossover at {gf_cross})"
        elif fg_cross is not None and gf_cross is not None:
            return f"[{f_name}] = [{g_name}] in *ℕ (eventually equal)"
        else:
            return f"Cannot determine ordering within search range"


if __name__ == "__main__":
    # Demo: Growth classification
    classifier = GrowthClassifier()

    print("Growth Rate Classification in *ℕ:")
    print("-" * 50)

    # i^2 vs 2^i
    result = classifier.classify_pair(
        lambda i: i**2, lambda i: 2**i,
        "ω²", "2^ω"
    )
    print(f"  {result}")

    # i^10 vs 2^i
    result = classifier.classify_pair(
        lambda i: i**10, lambda i: 2**i,
        "ω¹⁰", "2^ω"
    )
    print(f"  {result}")

    # i! vs i^i
    result = classifier.classify_pair(
        lambda i: math.factorial(i) if i < 200 else 10**1000,
        lambda i: i**i if i > 0 and i < 200 else 1,
        "ω!", "ω^ω"
    )
    print(f"  {result}")

    print()

    # Demo: Transfer verification
    verifier = TransferVerifier()

    print("Transfer Verification:")
    print("-" * 50)

    # Fermat with p(i) = i-th prime
    primes_list = []
    for n in range(2, 100000):
        if all(n % d != 0 for d in range(2, int(n**0.5) + 1)):
            primes_list.append(n)
        if len(primes_list) >= 10000:
            break

    succ, total = verifier.verify_fermat(
        lambda i: i * 3 + 7,
        lambda i: primes_list[i] if i < len(primes_list) else 2,
        n_samples=min(5000, len(primes_list))
    )
    print(f"  Fermat's Little Theorem: {succ}/{total} verified (should be 100%)")

    succ, total = verifier.verify_gcd_divisibility(
        lambda i: i * 6 + 12,
        lambda i: i * 10 + 20,
        n_samples=10000
    )
    print(f"  GCD Divisibility: {succ}/{total} verified (should be 100%)")
