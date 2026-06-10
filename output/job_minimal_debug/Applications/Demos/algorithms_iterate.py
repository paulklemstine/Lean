#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Compositional Certification

Implements the core algorithms from the modular composition framework:
- Modular decomposition optimizer
- Compositional regret calculator
- Fibonacci GCD verifier
- Carmichael number tester (Korselt's criterion)
- Interface bound calculator

Each algorithm includes docstrings, type hints, and complexity analysis.
"""

import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


# ============================================================
# Algorithm 1: Compositional System Optimizer
# ============================================================

@dataclass
class CertifiedModule:
    """A module with a certified cost bound.

    Attributes:
        name: Human-readable module name
        cost: Verified upper bound on module cost (≥ 0)
    """
    name: str
    cost: float

    def __post_init__(self):
        assert self.cost >= 0, f"Module cost must be nonneg, got {self.cost}"


@dataclass
class CompositionalSystem:
    """A system of k certified modules with interface cost.

    The global cost is:
        global_cost = sum(module.cost for module in modules) + interface_cost

    This is the data structure behind the Compositional Certification Theorem.

    Time complexity: O(k) for cost computation
    Space complexity: O(k) for module storage
    """
    modules: List[CertifiedModule]
    interface_cost: float

    def __post_init__(self):
        assert self.interface_cost >= 0, "Interface cost must be nonneg"

    @property
    def k(self) -> int:
        """Number of modules."""
        return len(self.modules)

    @property
    def global_cost(self) -> float:
        """Total system cost: sum of local costs + interface cost.

        Time: O(k)
        """
        return sum(m.cost for m in self.modules) + self.interface_cost

    def refine_module(self, index: int, new_cost: float) -> 'CompositionalSystem':
        """Refine a module to a lower cost, decreasing global cost.

        Precondition: 0 ≤ new_cost ≤ modules[index].cost
        Postcondition: new.global_cost ≤ self.global_cost

        Time: O(k)  Space: O(k)

        Args:
            index: Module to refine
            new_cost: New (lower) cost bound

        Returns:
            New system with refined module
        """
        assert 0 <= new_cost <= self.modules[index].cost
        new_modules = self.modules.copy()
        new_modules[index] = CertifiedModule(
            name=self.modules[index].name + " (refined)",
            cost=new_cost
        )
        return CompositionalSystem(modules=new_modules, interface_cost=self.interface_cost)

    @staticmethod
    def compose(sys1: 'CompositionalSystem', sys2: 'CompositionalSystem',
                connection_cost: float = 0.0) -> 'CompositionalSystem':
        """Compose two systems into a larger system.

        Global cost = sys1.global_cost + sys2.global_cost + connection_cost

        Time: O(k₁ + k₂)  Space: O(k₁ + k₂)
        """
        assert connection_cost >= 0
        return CompositionalSystem(
            modules=sys1.modules + sys2.modules,
            interface_cost=sys1.interface_cost + sys2.interface_cost + connection_cost
        )


# ============================================================
# Algorithm 2: Modular Regret Calculator
# ============================================================

def regret_bound(n_experts: int, T_rounds: int) -> float:
    """Compute the multiplicative weights regret bound.

    Formula: √(T · log(n) / 2)

    This is the standard regret guarantee for the Hedge algorithm
    with n experts over T rounds.

    Time: O(1)  Space: O(1)

    Args:
        n_experts: Number of experts (must be ≥ 1)
        T_rounds: Number of rounds (must be ≥ 1)

    Returns:
        Upper bound on cumulative regret
    """
    assert n_experts >= 1, "Need at least 1 expert"
    assert T_rounds >= 1, "Need at least 1 round"
    return math.sqrt(T_rounds * math.log(n_experts) / 2)


def modular_regret_bound(modules: List[int], T: int, k: Optional[int] = None) -> dict:
    """Compute the modular regret bound for a hierarchical expert system.

    For k modules with n_i experts each over T rounds:
      total_regret ≤ Σ √(T · log(n_i) / 2) + k · √T

    Time: O(k)  Space: O(k)

    Args:
        modules: List of expert counts per module [n_1, ..., n_k]
        T: Time horizon
        k: Number of modules (defaults to len(modules))

    Returns:
        Dictionary with regret breakdown
    """
    if k is None:
        k = len(modules)

    module_regrets = [regret_bound(n, T) for n in modules]
    total_module_regret = sum(module_regrets)
    iface = k * math.sqrt(T)
    monolithic = regret_bound(sum(modules), T)

    return {
        'module_regrets': module_regrets,
        'total_module_regret': total_module_regret,
        'interface_bound': iface,
        'total_bound': total_module_regret + iface,
        'monolithic_bound': monolithic,
        'modularity_overhead': (total_module_regret + iface) / monolithic if monolithic > 0 else float('inf')
    }


# ============================================================
# Algorithm 3: Fibonacci GCD Verifier
# ============================================================

def fibonacci(n: int) -> int:
    """Compute the n-th Fibonacci number.

    Time: O(n)  Space: O(1)
    """
    if n <= 0:
        return 0
    if n == 1:
        return 1
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b


def verify_fib_gcd(m: int, n: int) -> bool:
    """Verify gcd(F(m), F(n)) = F(gcd(m, n)) for given m, n.

    This is Carmichael's theorem on the GCD of Fibonacci numbers.
    The identity expresses that the Fibonacci sequence is a
    "divisibility morphism" from (ℕ, gcd) to (ℕ, gcd).

    Time: O(max(m, n))  Space: O(1)

    Returns:
        True if the identity holds
    """
    fm, fn = fibonacci(m), fibonacci(n)
    g = math.gcd(m, n)
    return math.gcd(fm, fn) == fibonacci(g)


# ============================================================
# Algorithm 4: Carmichael Number Tester (Korselt's Criterion)
# ============================================================

def prime_factors(n: int) -> List[int]:
    """Find all prime factors of n.

    Time: O(√n)  Space: O(log n)
    """
    factors = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        factors.append(temp)
    return factors


def is_squarefree(n: int) -> bool:
    """Check if n is squarefree.

    Time: O(√n)
    """
    d = 2
    while d * d <= n:
        if n % (d * d) == 0:
            return False
        d += 1
    return True


def korselt_test(n: int) -> dict:
    """Test if n is a Carmichael number using Korselt's criterion.

    Korselt's criterion: n is Carmichael iff
      1. n is composite
      2. n is squarefree
      3. For every prime p | n, (p-1) | (n-1)

    This is the quintessential modular composition: local conditions
    at each prime factor compose into a global pseudoprimality property.

    Time: O(√n)  Space: O(log n)

    Returns:
        Dictionary with test results
    """
    from sympy import isprime  # type: ignore

    factors = prime_factors(n)
    is_composite = not isprime(n) and n > 1
    sqfree = is_squarefree(n)

    factor_results = []
    for p in factors:
        divides = n % p == 0
        korselt = (n - 1) % (p - 1) == 0
        factor_results.append({
            'prime': p,
            'divides_n': divides,
            'korselt_condition': korselt,
            'quotient': (n - 1) // (p - 1) if korselt else None
        })

    is_carmichael = (is_composite and sqfree and
                     all(r['korselt_condition'] for r in factor_results))

    return {
        'n': n,
        'is_composite': is_composite,
        'is_squarefree': sqfree,
        'prime_factors': factors,
        'factor_results': factor_results,
        'is_carmichael': is_carmichael
    }


# ============================================================
# Algorithm 5: Interface Bound Calculator
# ============================================================

def interface_bound_calc(k: int, n: int) -> float:
    """Compute the holographic interface bound: k · √n.

    This models the "area law" for modular proof complexity:
    the interface between k modules over n items scales as k√n,
    which is sublinear in n (the "holographic" property).

    Time: O(1)  Space: O(1)

    Args:
        k: Number of modules
        n: Size of the problem space

    Returns:
        The interface bound k · √n
    """
    return k * math.sqrt(n)


def optimal_decomposition(n: int, max_k: int = 100) -> dict:
    """Find the optimal number of modules k to minimize total bound.

    Minimizes: k · regret_per_module(n/k) + interface_bound(k, n)

    where regret_per_module(m) = √(n · log(m) / 2)

    This is a continuous optimization that illustrates the
    fundamental tradeoff in modular decomposition.

    Time: O(max_k)  Space: O(1)

    Args:
        n: Total number of experts
        max_k: Maximum number of modules to try

    Returns:
        Dictionary with optimal decomposition
    """
    T = n  # Use n as time horizon for simplicity
    best_k = 1
    best_total = float('inf')
    results = []

    for k in range(1, min(max_k + 1, n + 1)):
        experts_per_module = max(1, n // k)
        module_regret = regret_bound(experts_per_module, T) * k
        iface = interface_bound_calc(k, T)
        total = module_regret + iface

        results.append({
            'k': k,
            'experts_per_module': experts_per_module,
            'module_regret': module_regret,
            'interface_bound': iface,
            'total': total
        })

        if total < best_total:
            best_total = total
            best_k = k

    return {
        'optimal_k': best_k,
        'optimal_total': best_total,
        'monolithic_total': regret_bound(n, n) + interface_bound_calc(1, n),
        'all_results': results[:min(20, len(results))]
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Example 1: Build and refine a compositional system
    sys = CompositionalSystem(
        modules=[
            CertifiedModule("Parser", 3.0),
            CertifiedModule("Optimizer", 5.0),
            CertifiedModule("Codegen", 2.0),
        ],
        interface_cost=1.5
    )
    print(f"Original system cost: {sys.global_cost}")
    refined = sys.refine_module(1, 3.0)
    print(f"Refined system cost: {refined.global_cost}")

    # Example 2: Modular regret
    result = modular_regret_bound([10, 20, 30], T=1000)
    print(f"\nModular regret: {result['total_bound']:.2f}")
    print(f"Monolithic regret: {result['monolithic_bound']:.2f}")

    # Example 3: Fibonacci GCD
    for m, n in [(12, 18), (20, 15)]:
        ok = verify_fib_gcd(m, n)
        print(f"\ngcd(F({m}), F({n})) = F(gcd({m},{n}))? {ok}")

    # Example 4: Carmichael numbers
    for n in [561, 1105, 1729]:
        try:
            result = korselt_test(n)
            print(f"\n{n} is Carmichael: {result['is_carmichael']}")
            print(f"  Factors: {result['prime_factors']}")
        except ImportError:
            print(f"\n{n}: Korselt test requires sympy")

    # Example 5: Optimal decomposition
    opt = optimal_decomposition(100)
    print(f"\nOptimal decomposition for n=100: k={opt['optimal_k']}")
    print(f"  Total: {opt['optimal_total']:.2f}")
