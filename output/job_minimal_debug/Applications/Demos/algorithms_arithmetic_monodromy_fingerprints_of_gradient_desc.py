#!/usr/bin/env python3
"""
algorithms.py — Certified Algorithms for Arithmetic Gradient Descent Analysis

Implements the core computational methods for analyzing polynomial gradient
descent over finite fields, including:

1. Functional graph construction for gradient step maps
2. Fixed point and critical point enumeration
3. Basin-of-attraction computation
4. Cycle detection and classification
5. Arithmetic fingerprint comparison across primes
6. Quadratic residuosity analysis

All algorithms operate over F_p (integers mod p) and use exact arithmetic.
"""

from typing import Dict, List, Tuple, Set, Optional
from collections import Counter, defaultdict
from dataclasses import dataclass


@dataclass
class PolynomialFp:
    """Polynomial over F_p, stored as coefficient list [a0, a1, ..., an]."""
    coeffs: List[int]
    p: int

    def eval(self, x: int) -> int:
        """Evaluate polynomial at x mod p."""
        result = 0
        power = 1
        for c in self.coeffs:
            result = (result + c * power) % self.p
            power = (power * x) % self.p
        return result

    def derivative(self) -> 'PolynomialFp':
        """Compute formal derivative."""
        if len(self.coeffs) <= 1:
            return PolynomialFp([0], self.p)
        return PolynomialFp(
            [(i * self.coeffs[i]) % self.p for i in range(1, len(self.coeffs))],
            self.p
        )

    def __repr__(self) -> str:
        terms = []
        for i, c in enumerate(self.coeffs):
            c = c % self.p
            if c == 0:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}*x" if c != 1 else "x")
            else:
                terms.append(f"{c}*x^{i}" if c != 1 else f"x^{i}")
        return " + ".join(terms) if terms else "0"


@dataclass
class FunctionalGraph:
    """The functional graph of a map F_p → F_p."""
    successor: Dict[int, int]
    p: int

    @property
    def fixed_points(self) -> Set[int]:
        return {x for x, fx in self.successor.items() if fx == x}

    @property
    def periodic_points(self) -> Set[int]:
        """Points that are on a cycle."""
        result = set()
        for x in range(self.p):
            # Follow until we revisit
            seen = {}
            current = x
            step = 0
            while current not in seen:
                seen[current] = step
                current = self.successor[current]
                step += 1
            # current is on a cycle
            cycle_start = current
            result.add(cycle_start)
            node = self.successor[cycle_start]
            while node != cycle_start:
                result.add(node)
                node = self.successor[node]
        return result

    def cycle_decomposition(self) -> List[List[int]]:
        """Decompose into disjoint cycles."""
        periodic = self.periodic_points
        visited = set()
        cycles = []
        for x in sorted(periodic):
            if x in visited:
                continue
            cycle = [x]
            visited.add(x)
            current = self.successor[x]
            while current != x:
                cycle.append(current)
                visited.add(current)
                current = self.successor[current]
            cycles.append(cycle)
        return cycles

    def basin_sizes(self) -> Dict[int, int]:
        """For each cycle, count the total number of points that eventually reach it."""
        # Find which cycle each point eventually reaches
        cycle_id = {}
        cycles = self.cycle_decomposition()
        for i, cycle in enumerate(cycles):
            for x in cycle:
                cycle_id[x] = i

        basin_count = Counter()
        for x in range(self.p):
            current = x
            while current not in cycle_id:
                current = self.successor[current]
            basin_count[cycle_id[current]] += 1

        return dict(basin_count)

    def tree_depths(self) -> Dict[int, int]:
        """For each point, compute how many steps until it reaches a cycle."""
        periodic = self.periodic_points
        depths = {x: 0 for x in periodic}
        changed = True
        while changed:
            changed = False
            for x in range(self.p):
                if x in depths:
                    continue
                fx = self.successor[x]
                if fx in depths:
                    depths[x] = depths[fx] + 1
                    changed = True
        return depths


@dataclass
class GradientDescentAnalysis:
    """Complete analysis of gradient descent on a polynomial over F_p."""
    polynomial: PolynomialFp
    eta: int
    p: int
    critical_points: List[int]
    fixed_points: List[int]
    functional_graph: FunctionalGraph
    cycles: List[List[int]]
    basin_sizes: Dict[int, int]


def build_gradient_step_map(f: PolynomialFp, eta: int) -> FunctionalGraph:
    """
    Build the functional graph of T(x) = x - η·f'(x) over F_p.

    Algorithm:
        For each x in {0, 1, ..., p-1}:
            1. Compute f'(x) mod p
            2. Compute T(x) = (x - η·f'(x)) mod p
            3. Record the edge x → T(x)

    Complexity: O(p · deg(f)) time, O(p) space.
    """
    df = f.derivative()
    p = f.p
    successor = {}
    for x in range(p):
        dfx = df.eval(x)
        successor[x] = (x - eta * dfx) % p
    return FunctionalGraph(successor=successor, p=p)


def analyze_gradient_descent(
    coeffs: List[int], eta: int, p: int
) -> GradientDescentAnalysis:
    """
    Complete analysis of gradient descent T(x) = x - η·f'(x) over F_p.

    Args:
        coeffs: Polynomial coefficients [a0, a1, ..., an]
        eta: Step size
        p: Prime modulus

    Returns:
        GradientDescentAnalysis with all computed invariants

    Complexity: O(p · deg(f)) time, O(p) space.
    """
    f = PolynomialFp(coeffs, p)
    df = f.derivative()

    # Find critical points (roots of f')
    critical = [x for x in range(p) if df.eval(x) % p == 0]

    # Build functional graph
    graph = build_gradient_step_map(f, eta)

    # Fixed points
    fixed = sorted(graph.fixed_points)

    # Cycle structure
    cycles = graph.cycle_decomposition()

    # Basin sizes
    basins = graph.basin_sizes()

    return GradientDescentAnalysis(
        polynomial=f,
        eta=eta,
        p=p,
        critical_points=critical,
        fixed_points=fixed,
        functional_graph=graph,
        cycles=cycles,
        basin_sizes=basins
    )


def compare_fingerprints(
    f_coeffs: List[int],
    g_coeffs: List[int],
    eta: int,
    prime_bound: int
) -> Dict[str, object]:
    """
    Compare arithmetic fingerprints of two polynomial families across primes.

    For each prime p up to prime_bound, computes:
    - Fixed point counts for both f and g
    - Basin size distributions
    - Cycle length distributions
    - Whether the primes separate the two families

    Args:
        f_coeffs, g_coeffs: Coefficient lists for the two polynomials
        eta: Step size
        prime_bound: Test all primes up to this bound

    Returns:
        Dictionary with comparison statistics
    """
    def sieve(n):
        is_prime = [True] * (n + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, n+1, i):
                    is_prime[j] = False
        return [i for i in range(n+1) if is_prime[i]]

    primes = [p for p in sieve(prime_bound) if p > 3]
    results = {
        'primes_tested': len(primes),
        'separating_primes': 0,
        'details': []
    }

    for p in primes:
        analysis_f = analyze_gradient_descent(f_coeffs, eta, p)
        analysis_g = analyze_gradient_descent(g_coeffs, eta, p)

        fp_f = len(analysis_f.fixed_points)
        fp_g = len(analysis_g.fixed_points)

        cycles_f = sorted([len(c) for c in analysis_f.cycles])
        cycles_g = sorted([len(c) for c in analysis_g.cycles])

        basins_f = sorted(analysis_f.basin_sizes.values(), reverse=True)
        basins_g = sorted(analysis_g.basin_sizes.values(), reverse=True)

        separates = fp_f != fp_g or cycles_f != cycles_g

        if separates:
            results['separating_primes'] += 1

        results['details'].append({
            'p': p,
            'fp_f': fp_f,
            'fp_g': fp_g,
            'cycles_f': cycles_f,
            'cycles_g': cycles_g,
            'basins_f': basins_f,
            'basins_g': basins_g,
            'separates': separates
        })

    return results


def is_quadratic_residue(a: int, p: int) -> bool:
    """Test if a is a quadratic residue mod p using Euler's criterion.
    Complexity: O(log p) via modular exponentiation."""
    if a % p == 0:
        return True
    return pow(a % p, (p - 1) // 2, p) == 1


def quartic_family_fixed_point_formula(a: int, p: int, eta: int = 1) -> int:
    """
    Certified fixed-point count for the quartic family f_a(x) = x^4 - 2ax^2.

    f'(x) = 4x^3 - 4ax = 4x(x^2 - a)

    Fixed points of T(x) = x - η·f'(x) with η ≠ 0 are roots of f'(x) = 0:
    - x = 0 is always a root (if char(F_p) ≠ 2)
    - x^2 = a has 0 or 2 solutions depending on QR(a, p)

    Returns:
        Number of fixed points when p > 3 and eta is invertible mod p

    Complexity: O(log p) for the quadratic residue test.
    """
    if p <= 3:
        raise ValueError("Need p > 3")
    if (eta * 4) % p == 0:
        raise ValueError("Need 4η invertible mod p")

    a_mod = a % p
    if a_mod == 0:
        return 1  # Only x = 0

    if is_quadratic_residue(a_mod, p):
        return 3  # x = 0 and two square roots of a
    else:
        return 1  # Only x = 0


# Example usage
if __name__ == "__main__":
    print("=== Quartic Family Analysis ===\n")

    # Compare f1: a=2 vs f2: a=3
    f1 = [0, 0, -4, 0, 1]  # x^4 - 4x^2
    f2 = [0, 0, -6, 0, 1]  # x^4 - 6x^2

    result = compare_fingerprints(f1, f2, eta=1, prime_bound=50)
    print(f"Primes tested: {result['primes_tested']}")
    print(f"Separating primes: {result['separating_primes']}")
    print(f"Separation rate: {100*result['separating_primes']/result['primes_tested']:.1f}%\n")

    for d in result['details']:
        sep = "SEP" if d['separates'] else "   "
        print(f"  p={d['p']:3d}: #FP(f)={d['fp_f']}, #FP(g)={d['fp_g']}  {sep}")

    print("\n=== Certified Formula Verification ===\n")
    for p in [5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        for a in [2, 3]:
            formula_count = quartic_family_fixed_point_formula(a, p)
            f = [0, 0, -2*a, 0, 1]
            actual = analyze_gradient_descent(f, 1, p)
            actual_count = len(actual.fixed_points)
            check = "✓" if formula_count == actual_count else "✗"
            print(f"  p={p:3d}, a={a}: formula={formula_count}, actual={actual_count}  {check}")
