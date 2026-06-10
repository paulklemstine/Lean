#!/usr/bin/env python3
"""
Counterfactual Number Theory: Core Algorithms

Type-hinted implementations of the mathematical structures and
algorithms from the Lean 4 formalization.
"""

from dataclasses import dataclass, field
from typing import FrozenSet, Dict, List, Tuple, Optional, Set
import math
from collections import defaultdict


@dataclass(frozen=True)
class FactorizationSystem:
    """A factorization system: a set of generators ⊆ ℕ \\ {0,1}."""
    generators: FrozenSet[int]

    def __post_init__(self) -> None:
        assert 0 not in self.generators, "0 cannot be a generator"
        assert 1 not in self.generators, "1 cannot be a generator"
        assert all(g >= 2 for g in self.generators), "All generators must be ≥ 2"

    def is_product_free(self) -> bool:
        """Check if no product of two generators is a generator."""
        gens = sorted(self.generators)
        for i, a in enumerate(gens):
            for b in gens[i:]:
                if a * b in self.generators:
                    return False
        return True

    def is_divisor_closed(self) -> bool:
        """Check if every divisor ≥ 2 of a generator is a generator."""
        for n in self.generators:
            for d in range(2, n):
                if n % d == 0 and d not in self.generators:
                    return False
        return True

    def is_prime_factor_closed(self) -> bool:
        """Check if every prime factor of a generator is a generator."""
        for n in self.generators:
            temp = n
            d = 2
            while d * d <= temp:
                if temp % d == 0:
                    if d not in self.generators:
                        return False
                    while temp % d == 0:
                        temp //= d
                d += 1
            if temp > 1 and temp not in self.generators:
                return False
        return True

    def factorizations(self, n: int, max_depth: int = 50) -> List[Tuple[int, ...]]:
        """Find all factorizations of n into generators."""
        if n < 2:
            return [()] if n == 1 else []
        results: List[Tuple[int, ...]] = []
        gens = sorted(g for g in self.generators if g <= n)

        def backtrack(remaining: int, min_gen: int, current: List[int], depth: int) -> None:
            if depth > max_depth:
                return
            if remaining == 1:
                results.append(tuple(current))
                return
            for g in gens:
                if g < min_gen:
                    continue
                if g > remaining:
                    break
                if remaining % g == 0:
                    current.append(g)
                    backtrack(remaining // g, g, current, depth + 1)
                    current.pop()

        backtrack(n, 2, [], 0)
        return results

    def has_unique_factorization(self, max_n: int = 1000) -> Tuple[bool, Optional[int]]:
        """Check UF for all products ≤ max_n. Returns (is_uf, counterexample)."""
        for n in range(2, max_n + 1):
            facts = self.factorizations(n)
            if len(facts) > 1:
                return False, n
        return True, None

    def find_collisions(self, max_product: int = 1000) -> List[Tuple[int, List[Tuple[int, int]]]]:
        """Find product collisions among generators."""
        products: Dict[int, List[Tuple[int, int]]] = defaultdict(list)
        gens = sorted(self.generators)
        for i, a in enumerate(gens):
            for b in gens[i:]:
                p = a * b
                if p <= max_product:
                    products[p].append((a, b))
        return [(p, pairs) for p, pairs in products.items() if len(pairs) > 1]

    def cramer_defect(self, k: int) -> Set[int]:
        """Compute the Cramér defect at level k: generators that are
        products of k other generators."""
        if k < 2:
            return set()
        defects: Set[int] = set()
        gens = sorted(self.generators)
        # Find all k-fold products of generators that land in generators
        def find_products(remaining_k: int, min_idx: int, product: int) -> None:
            if remaining_k == 0:
                if product in self.generators:
                    defects.add(product)
                return
            for i in range(min_idx, len(gens)):
                new_product = product * gens[i]
                if new_product > max(gens) * 2:
                    break
                find_products(remaining_k - 1, i, new_product)
        find_products(k, 0, 1)
        return defects


def big_omega(n: int) -> int:
    """Count prime factors with multiplicity (Ω function)."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    while d * d <= n:
        while n % d == 0:
            count += 1
            n //= d
        d += 1
    if n > 1:
        count += 1
    return count


def k_almost_primes(n: int, k: int) -> List[int]:
    """Return all k-almost primes up to n."""
    return [m for m in range(2, n + 1) if big_omega(m) == k]


def cramer_random_model(n: int, seed: int = 42) -> FactorizationSystem:
    """Generate a Cramér random model."""
    import random
    rng = random.Random(seed)
    gens: Set[int] = set()
    for k in range(2, n + 1):
        if rng.random() < 1.0 / math.log(k):
            gens.add(k)
    return FactorizationSystem(frozenset(gens))


def prime_system(n: int) -> FactorizationSystem:
    """The standard prime factorization system up to n."""
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    primes = frozenset(i for i in range(2, n + 1) if sieve[i])
    return FactorizationSystem(primes)


def verify_prime_saturation(max_n: int = 50) -> bool:
    """Verify Prime Saturation Theorem computationally."""
    from itertools import combinations
    candidates = list(range(2, max_n + 1))
    # Check all subsets up to size 5
    for size in range(1, min(6, len(candidates) + 1)):
        for subset in combinations(candidates, size):
            fs = FactorizationSystem(frozenset(subset))
            pf = fs.is_product_free()
            dc = fs.is_divisor_closed()
            all_prime = all(_is_prime(g) for g in subset)
            if pf and dc and not all_prime:
                print(f"COUNTEREXAMPLE: {subset} is PF+DC but not all prime!")
                return False
            if all_prime and not (pf and dc):
                print(f"COUNTEREXAMPLE: {subset} all prime but not PF+DC!")
                return False
    return True


def _is_prime(n: int) -> bool:
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


if __name__ == "__main__":
    # Quick verification
    ps = prime_system(100)
    print(f"Prime system (≤100): {len(ps.generators)} generators")
    print(f"  Product-free: {ps.is_product_free()}")
    print(f"  Divisor-closed: {ps.is_divisor_closed()}")
    print(f"  UF: {ps.has_unique_factorization(200)}")

    # Cramér model
    cm = cramer_random_model(100)
    print(f"\nCramér model (≤100): {len(cm.generators)} generators")
    print(f"  Product-free: {cm.is_product_free()}")
    print(f"  Collisions: {len(cm.find_collisions(200))}")

    # k-almost primes
    for k in range(1, 5):
        kap = k_almost_primes(100, k)
        fs = FactorizationSystem(frozenset(kap))
        print(f"\n{k}-almost primes (≤100): {len(kap)} elements")
        print(f"  Product-free: {fs.is_product_free()}")
