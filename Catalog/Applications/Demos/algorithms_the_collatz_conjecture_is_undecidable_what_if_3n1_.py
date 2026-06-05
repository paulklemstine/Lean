#!/usr/bin/env python3
"""
Algorithms for Collatz Orbit Analysis

Type-hinted implementations of the key algorithms from the research.
"""

from fractions import Fraction
from typing import List, Optional, Tuple, Dict
from dataclasses import dataclass


# =============================================================================
# Algorithm 1: Affine Representation Computation
# =============================================================================

def compute_affine_coefficients(w: List[bool]) -> Tuple[Fraction, Fraction]:
    """
    Compute the slope and intercept of the affine map for parity word w.
    
    Algorithm:
        slope([]) = 1, intercept([]) = 0
        For b :: rest:
            If b (odd): slope = 3 * slope(rest), intercept = slope(rest) + intercept(rest)
            If ¬b (even): slope = slope(rest) / 2, intercept = intercept(rest)
    
    Returns (slope, intercept) as exact fractions.
    
    Time: O(k) where k = len(w)
    Space: O(k) for recursion (O(1) with iterative version)
    """
    if not w:
        return Fraction(1), Fraction(0)
    
    rest_slope, rest_intercept = compute_affine_coefficients(w[1:])
    
    if w[0]:  # odd step
        return 3 * rest_slope, rest_slope + rest_intercept
    else:  # even step
        return rest_slope / 2, rest_intercept


def compute_affine_iterative(w: List[bool]) -> Tuple[Fraction, Fraction]:
    """
    Iterative version of affine coefficient computation.
    
    Works right-to-left through the word, building up the affine map.
    
    Time: O(k), Space: O(1) (excluding arbitrary-precision arithmetic)
    """
    slope = Fraction(1)
    intercept = Fraction(0)
    
    for b in reversed(w):
        if b:  # odd step
            # New: slope' = 3 * slope, intercept' = slope + intercept
            intercept = slope + intercept
            slope = 3 * slope
        else:  # even step
            # New: slope' = slope / 2, intercept' = intercept
            slope = slope / 2
    
    return slope, intercept


# =============================================================================
# Algorithm 2: Cycle Candidate Computation
# =============================================================================

@dataclass
class CycleCandidateResult:
    """Result of cycle candidate analysis for a parity word."""
    word: List[bool]
    slope: Fraction
    intercept: Fraction
    candidate: Optional[Fraction]
    is_positive_integer: bool
    
    def __repr__(self) -> str:
        word_str = ''.join('O' if b else 'E' for b in self.word)
        cand_str = str(self.candidate) if self.candidate else "undefined"
        return (f"CycleCandidateResult(word={word_str}, slope={self.slope}, "
                f"intercept={self.intercept}, candidate={cand_str}, "
                f"is_positive_integer={self.is_positive_integer})")


def analyze_cycle_candidate(w: List[bool]) -> CycleCandidateResult:
    """
    Analyze the cycle candidate for a parity word.
    
    Algorithm:
        1. Compute slope s and intercept c.
        2. If s = 1, candidate is undefined (no unique fixed point).
        3. Otherwise, candidate = c / (1 - s).
        4. Check if candidate is a positive integer.
    
    Time: O(k) for coefficient computation + O(1) for analysis
    """
    s, c = compute_affine_iterative(w)
    
    if s == 1:
        return CycleCandidateResult(w, s, c, None, False)
    
    candidate = c / (1 - s)
    is_pos_int = candidate > 0 and candidate.denominator == 1
    
    return CycleCandidateResult(w, s, c, candidate, is_pos_int)


# =============================================================================
# Algorithm 3: Valid Parity Word Enumeration
# =============================================================================

def enumerate_valid_words(k: int) -> List[List[bool]]:
    """
    Enumerate all valid parity words of length k.
    
    A parity word is valid if it contains no two consecutive True values
    (by the parity exclusion theorem: after an odd Collatz step, the
    result is always even).
    
    The count follows the Fibonacci sequence: F(k+2) valid words of length k.
    
    Algorithm: Dynamic programming / recursive enumeration with constraint.
    
    Time: O(F(k+2)) ≈ O(φ^k) where φ = golden ratio
    Space: O(k * F(k+2)) to store all words
    """
    if k == 0:
        return [[]]
    if k == 1:
        return [[False], [True]]
    
    result: List[List[bool]] = []
    for w in enumerate_valid_words(k - 1):
        result.append(w + [False])
        if not w[-1]:
            result.append(w + [True])
    
    return result


def count_valid_words(k: int) -> int:
    """Count valid parity words of length k without enumerating them.
    
    Returns F(k+2) where F is the Fibonacci sequence.
    Time: O(k), Space: O(1)
    """
    if k == 0:
        return 1
    a, b = 1, 2  # F(2), F(3)
    for _ in range(k - 1):
        a, b = b, a + b
    return b


# =============================================================================
# Algorithm 4: Systematic Cycle Elimination
# =============================================================================

def check_no_cycles_up_to(max_length: int) -> Tuple[bool, Optional[CycleCandidateResult]]:
    """
    Check that no valid parity word of length ≤ max_length has a positive
    integer cycle candidate.
    
    Algorithm:
        For each length k from 1 to max_length:
            For each valid parity word w of length k:
                If w has at least one odd and one even step (mixed):
                    Compute cycle candidate
                    If candidate is a positive integer: return (False, result)
        Return (True, None)
    
    Time: O(sum_{k=1}^{max_length} F(k+2)) ≈ O(φ^{max_length+2})
    """
    for k in range(1, max_length + 1):
        for w in enumerate_valid_words(k):
            if not any(w) or all(w):
                continue  # skip pure-even or pure-odd words
            
            result = analyze_cycle_candidate(w)
            if result.is_positive_integer:
                return False, result
    
    return True, None


# =============================================================================
# Algorithm 5: Orbit Complexity Profiling
# =============================================================================

@dataclass
class OrbitProfile:
    """Complete dynamical profile of a Collatz orbit."""
    start: int
    orbit: List[int]
    stopping_time: int
    peak_value: int
    odd_count: int
    even_count: int
    odd_density: float
    parity_word: List[bool]
    affine_slope: Fraction
    affine_intercept: Fraction


def profile_orbit(n: int, max_steps: int = 10000) -> Optional[OrbitProfile]:
    """
    Compute the complete dynamical profile of n's Collatz orbit.
    
    Returns None if n doesn't reach 1 within max_steps.
    
    Time: O(stopping_time)
    """
    if n < 1:
        return None
    
    orbit = [n]
    parities: List[bool] = []
    val = n
    
    while val != 1 and len(orbit) < max_steps:
        parities.append(val % 2 == 1)
        val = 3 * val + 1 if val % 2 == 1 else val // 2
        orbit.append(val)
    
    if val != 1:
        return None
    
    stopping_time = len(orbit) - 1
    peak = max(orbit)
    odd_count = sum(1 for b in parities if b)
    even_count = stopping_time - odd_count
    odd_density = odd_count / stopping_time if stopping_time > 0 else 0.0
    
    slope, intercept = compute_affine_iterative(parities)
    
    return OrbitProfile(
        start=n,
        orbit=orbit,
        stopping_time=stopping_time,
        peak_value=peak,
        odd_count=odd_count,
        even_count=even_count,
        odd_density=odd_density,
        parity_word=parities,
        affine_slope=slope,
        affine_intercept=intercept,
    )


if __name__ == "__main__":
    # Quick demo
    print("Affine coefficients for [O, E, O, E]:")
    w = [True, False, True, False]
    s, c = compute_affine_iterative(w)
    print(f"  Slope = {s}, Intercept = {c}")
    print(f"  Cycle candidate = {c / (1 - s)} = {float(c / (1 - s)):.6f}")
    
    print("\nChecking no cycles up to length 20...")
    ok, counterexample = check_no_cycles_up_to(20)
    print(f"  No cycles found: {ok}")
    
    print("\nOrbit profile for n=27:")
    p = profile_orbit(27)
    if p:
        print(f"  Stopping time: {p.stopping_time}")
        print(f"  Peak value: {p.peak_value}")
        print(f"  Odd density: {p.odd_density:.4f}")
        print(f"  Affine slope: {float(p.affine_slope):.6e}")
