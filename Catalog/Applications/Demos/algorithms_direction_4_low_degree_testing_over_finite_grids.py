#!/usr/bin/env python3
"""
Algorithms for Low-Degree Testing over Finite Grids.

Implements:
1. Grid Schwartz-Zippel zero counter (exact)
2. Reed-Muller encoding and distance computation
3. Low-degree testing via random line sampling
4. Self-correction algorithm for noisy polynomial oracles

All algorithms work over Z/pZ for a prime p.
"""

import random
import itertools
from typing import Dict, Tuple, List, Optional, Callable


# =============================================================================
# Core Polynomial Arithmetic over Z/pZ
# =============================================================================

class MvPoly:
    """Multivariate polynomial over Z/pZ.
    
    Represented as a dictionary: monomial exponent tuple -> coefficient.
    """
    
    def __init__(self, coeffs: Dict[Tuple[int, ...], int], prime: int, nvars: int):
        self.prime = prime
        self.nvars = nvars
        self.coeffs = {k: v % prime for k, v in coeffs.items() if v % prime != 0}
    
    def total_degree(self) -> int:
        if not self.coeffs:
            return 0
        return max(sum(exp) for exp in self.coeffs.keys())
    
    def eval(self, point: Tuple[int, ...]) -> int:
        result = 0
        for exponents, coeff in self.coeffs.items():
            term = coeff
            for i, e in enumerate(exponents):
                term = (term * pow(point[i], e, self.prime)) % self.prime
            result = (result + term) % self.prime
        return result
    
    def __sub__(self, other: 'MvPoly') -> 'MvPoly':
        result = dict(self.coeffs)
        for k, v in other.coeffs.items():
            result[k] = (result.get(k, 0) - v) % self.prime
        return MvPoly(result, self.prime, self.nvars)
    
    def __eq__(self, other: 'MvPoly') -> bool:
        return self.coeffs == other.coeffs and self.prime == other.prime
    
    def is_zero(self) -> bool:
        return len(self.coeffs) == 0
    
    def __repr__(self) -> str:
        if not self.coeffs:
            return "0"
        terms = []
        for exp, coeff in sorted(self.coeffs.items()):
            if coeff == 0:
                continue
            vars_str = ""
            for i, e in enumerate(exp):
                if e == 1:
                    vars_str += f"x{i}"
                elif e > 1:
                    vars_str += f"x{i}^{e}"
            if not vars_str:
                terms.append(str(coeff))
            elif coeff == 1:
                terms.append(vars_str)
            else:
                terms.append(f"{coeff}*{vars_str}")
        return " + ".join(terms) if terms else "0"


# =============================================================================
# Algorithm 1: Grid Schwartz-Zippel Zero Counter
# =============================================================================

def schwartz_zippel_bound(d: int, s_card: int, n: int) -> int:
    """
    Compute the Schwartz-Zippel bound: d * |S|^(n-1).
    
    This is the maximum number of zeros a nonzero polynomial of total degree d
    can have on the grid S^n, when d < |S|.
    
    Time complexity: O(1)
    Space complexity: O(1)
    """
    if n == 0:
        return 0
    return d * (s_card ** (n - 1))


def count_grid_zeros(poly: MvPoly, S: List[int], n: int) -> int:
    """
    Count the exact number of zeros of poly on the grid S^n.
    
    Time complexity: O(|S|^n * d) where d = total degree
    Space complexity: O(|S|^n)
    
    Args:
        poly: Multivariate polynomial over Z/pZ
        S: Finite subset of the field
        n: Number of variables
    
    Returns:
        Number of points x in S^n where poly(x) = 0
    """
    count = 0
    for point in itertools.product(S, repeat=n):
        if poly.eval(point) == 0:
            count += 1
    return count


# =============================================================================
# Algorithm 2: Reed-Muller Encoding
# =============================================================================

def reed_muller_encode(poly: MvPoly, S: List[int], n: int) -> List[int]:
    """
    Encode a polynomial as its evaluation vector on the grid S^n.
    
    This is the Reed-Muller encoding: the codeword for polynomial p is
    the vector (p(x))_{x in S^n}.
    
    Time complexity: O(|S|^n * d)
    Space complexity: O(|S|^n)
    
    Args:
        poly: The message polynomial
        S: Evaluation set
        n: Number of variables
    
    Returns:
        List of evaluations (the codeword)
    """
    return [poly.eval(point) for point in itertools.product(S, repeat=n)]


def reed_muller_distance(poly1: MvPoly, poly2: MvPoly,
                         S: List[int], n: int) -> int:
    """
    Compute the Hamming distance between two Reed-Muller codewords.
    
    By Theorem C, this is at least |S|^n - d*|S|^(n-1) when the
    polynomials are distinct and have degree ≤ d < |S|.
    
    Time complexity: O(|S|^n * d)
    Space complexity: O(1)
    """
    cw1 = reed_muller_encode(poly1, S, n)
    cw2 = reed_muller_encode(poly2, S, n)
    return sum(1 for a, b in zip(cw1, cw2) if a != b)


def reed_muller_min_distance(d: int, s_card: int, n: int) -> int:
    """
    Compute the minimum distance of the Reed-Muller code RM(d, S^n).
    
    By Theorem C: min_distance = |S|^n - d * |S|^(n-1) = |S|^(n-1) * (|S| - d)
    """
    return s_card ** n - d * s_card ** (n - 1)


# =============================================================================
# Algorithm 3: Low-Degree Test via Random Lines
# =============================================================================

def random_line_test(oracle: Callable[[Tuple[int, ...]], int],
                     S: List[int], n: int, d: int, prime: int,
                     num_tests: int = 100) -> Tuple[bool, float]:
    """
    Low-degree test: check if an oracle function is consistent with a
    degree-≤d polynomial by testing along random lines.
    
    For each test:
    1. Pick a random point a in S^n
    2. Pick a random direction b in S^n
    3. Query oracle at a + t*b for all t in S
    4. Check if these |S| values form a univariate polynomial of degree ≤ d
    
    By the Grid Schwartz-Zippel theorem (Theorem A), if the oracle agrees
    with a degree-≤d polynomial on too many points, the polynomial is
    uniquely determined. This test checks local consistency.
    
    Time complexity: O(num_tests * |S| * n)
    Space complexity: O(|S|)
    
    Args:
        oracle: Function mapping grid points to field elements
        S: Evaluation set
        n: Number of variables
        d: Maximum total degree
        prime: Field characteristic
        num_tests: Number of random line tests
    
    Returns:
        (passed, acceptance_rate): Whether the test passed, and fraction accepted
    """
    accepted = 0
    
    for _ in range(num_tests):
        # Random point and direction
        a = tuple(random.choice(S) for _ in range(n))
        b = tuple(random.choice(S) for _ in range(n))
        
        # Evaluate along the line a + t*b
        line_values = []
        for t in S:
            point = tuple((a[i] + t * b[i]) % prime for i in range(n))
            line_values.append(oracle(point))
        
        # Check if values are consistent with a degree-≤d univariate polynomial
        # Use Lagrange interpolation to find the unique degree-|S|-1 polynomial
        # and check if its degree is ≤ d
        if is_low_degree_univariate(line_values, S, d, prime):
            accepted += 1
    
    rate = accepted / num_tests
    return rate > 0.9, rate  # Threshold for passing


def is_low_degree_univariate(values: List[int], S: List[int],
                              d: int, prime: int) -> bool:
    """
    Check if values at points S are consistent with a univariate polynomial
    of degree ≤ d, using finite differences.
    
    A polynomial of degree ≤ d has its (d+1)-th finite difference equal to 0.
    """
    # Compute forward differences
    diffs = list(values)
    for order in range(d + 1):
        new_diffs = []
        for i in range(len(diffs) - 1):
            new_diffs.append((diffs[i + 1] - diffs[i]) % prime)
        diffs = new_diffs
        if not diffs:
            return True
    
    return all(v == 0 for v in diffs)


# =============================================================================
# Algorithm 4: Self-Correction Algorithm
# =============================================================================

def self_correct(oracle: Callable[[Tuple[int, ...]], int],
                 point: Tuple[int, ...], S: List[int], n: int,
                 d: int, prime: int, num_samples: int = 20) -> int:
    """
    Self-correction algorithm for noisy polynomial oracles.
    
    Given a noisy oracle that agrees with a degree-≤d polynomial p on at least
    (1 - delta) fraction of points in S^n (where delta < 1 - d/|S|), this
    algorithm recovers p(point) with high probability.
    
    Method:
    1. Pick a random direction r in S^n
    2. Query oracle at point + t*r for all t in {0,...,d}
    3. Use Lagrange interpolation to recover p(point) from these d+1 values
    4. Repeat and take majority vote
    
    By Theorem A, the polynomial is uniquely determined by its agreement,
    so this procedure converges to the correct value.
    
    Time complexity: O(num_samples * d * n)
    Space complexity: O(d)
    
    Args:
        oracle: Noisy oracle for the polynomial
        point: Point at which to evaluate
        S: Evaluation set
        n: Number of variables
        d: Maximum degree of the polynomial
        prime: Field characteristic
        num_samples: Number of correction attempts
    
    Returns:
        Corrected value of p(point)
    """
    votes = {}
    
    for _ in range(num_samples):
        # Random direction
        r = tuple(random.choice(S) for _ in range(n))
        
        # Query along line through point in direction r
        eval_points = list(range(d + 2))
        line_values = []
        for t in eval_points:
            query = tuple((point[i] + t * r[i]) % prime for i in range(n))
            line_values.append(oracle(query))
        
        # Interpolate to find value at t=0 (which is the original point)
        # Using Lagrange interpolation
        value = lagrange_eval_at_zero(eval_points, line_values, prime)
        votes[value] = votes.get(value, 0) + 1
    
    # Return majority vote
    return max(votes, key=votes.get)


def lagrange_eval_at_zero(xs: List[int], ys: List[int], prime: int) -> int:
    """Evaluate the Lagrange interpolant at x=0."""
    n = len(xs)
    result = 0
    for i in range(n):
        # Compute Lagrange basis polynomial L_i(0)
        numer = 1
        denom = 1
        for j in range(n):
            if i != j:
                numer = (numer * (0 - xs[j])) % prime
                denom = (denom * (xs[i] - xs[j])) % prime
        # Modular inverse
        denom_inv = pow(denom, prime - 2, prime)
        result = (result + ys[i] * numer * denom_inv) % prime
    return result


# =============================================================================
# Main: Run all algorithms
# =============================================================================

if __name__ == "__main__":
    print("Low-Degree Testing Algorithms\n")
    
    # Setup
    prime = 7
    S = list(range(prime))
    n = 2
    d = 2
    
    # Create a test polynomial: p(x,y) = x^2 + 3xy + 2y + 1 (mod 7)
    p = MvPoly({(2, 0): 1, (1, 1): 3, (0, 1): 2, (0, 0): 1}, prime, n)
    
    print(f"Test polynomial: {p}")
    print(f"Total degree: {p.total_degree()}")
    print(f"Field: Z/{prime}Z, S = {{0,...,{prime-1}}}, n={n}")
    print()
    
    # Algorithm 1: Zero counting
    zeros = count_grid_zeros(p, S, n)
    bound = schwartz_zippel_bound(d, len(S), n)
    print(f"Zero count: {zeros} (Schwartz-Zippel bound: {bound})")
    print()
    
    # Algorithm 2: Reed-Muller encoding
    codeword = reed_muller_encode(p, S, n)
    print(f"Reed-Muller codeword length: {len(codeword)}")
    print(f"Min distance of RM({d}, S^{n}): {reed_muller_min_distance(d, len(S), n)}")
    
    # Create another polynomial
    q = MvPoly({(2, 0): 1, (0, 2): 1}, prime, n)
    dist = reed_muller_distance(p, q, S, n)
    print(f"Distance between p and q={q}: {dist}")
    print()
    
    # Algorithm 3: Low-degree test
    def true_oracle(pt):
        return p.eval(pt)
    
    passed, rate = random_line_test(true_oracle, S, n, d, prime, num_tests=200)
    print(f"Low-degree test on true oracle: {'PASS' if passed else 'FAIL'} "
          f"(acceptance rate: {rate:.2%})")
    
    # Test with a non-low-degree function
    def bad_oracle(pt):
        return (pt[0] ** 5 + pt[1] ** 3) % prime
    
    passed_bad, rate_bad = random_line_test(bad_oracle, S, n, d, prime, num_tests=200)
    print(f"Low-degree test on bad oracle:  {'PASS' if passed_bad else 'FAIL'} "
          f"(acceptance rate: {rate_bad:.2%})")
    print()
    
    # Algorithm 4: Self-correction
    # Create noisy oracle (corrupt ~10% of points)
    corruption_rate = 0.10
    corrupted_values = {}
    for pt in itertools.product(S, repeat=n):
        val = p.eval(pt)
        if random.random() < corruption_rate:
            corrupted_values[pt] = (val + random.randint(1, prime - 1)) % prime
        else:
            corrupted_values[pt] = val
    
    def noisy_oracle(pt):
        return corrupted_values[pt]
    
    # Test self-correction at several points
    print("Self-correction results (with ~10% noise):")
    test_points = [(0, 0), (1, 2), (3, 4), (5, 6)]
    for pt in test_points:
        true_val = p.eval(pt)
        noisy_val = noisy_oracle(pt)
        corrected = self_correct(noisy_oracle, pt, S, n, d, prime, num_samples=30)
        status = "✓" if corrected == true_val else "✗"
        print(f"  Point {pt}: true={true_val}, noisy={noisy_val}, "
              f"corrected={corrected} {status}")
