#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Reverse-and-Add Dynamics

Implements the core algorithms from the research paper, including:
- Digit manipulation in arbitrary bases
- Reverse-and-add iteration with orbit tracking
- Modular residue analysis and obstruction detection
- Carry automaton simulation
- Palindrome residue computation
"""

from typing import Optional
from collections import defaultdict


# ============================================================
# Core digit algorithms
# ============================================================

def digits_base(b: int, n: int) -> list[int]:
    """
    Compute the base-b digits of n, least-significant first.
    
    Time: O(log_b(n))
    Space: O(log_b(n))
    
    Examples:
        >>> digits_base(10, 196)
        [6, 9, 1]
        >>> digits_base(2, 13)
        [1, 0, 1, 1]
    """
    if b < 2:
        raise ValueError(f"Base must be ≥ 2, got {b}")
    if n == 0:
        return []
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def of_digits_base(b: int, digits: list[int]) -> int:
    """
    Reconstruct a number from its base-b digit list (LSB first).
    
    Time: O(len(digits))
    Space: O(1)
    
    Examples:
        >>> of_digits_base(10, [6, 9, 1])
        196
    """
    result = 0
    power = 1
    for d in digits:
        result += d * power
        power *= b
    return result


def reverse_digits(b: int, n: int) -> int:
    """
    Compute the digit-reversal of n in base b.
    
    Time: O(log_b(n))
    Space: O(log_b(n))
    
    Examples:
        >>> reverse_digits(10, 196)
        691
    """
    d = digits_base(b, n)
    return of_digits_base(b, list(reversed(d)))


def is_palindrome_base(b: int, n: int) -> bool:
    """
    Check if n is a palindrome in base b.
    
    Time: O(log_b(n))
    Space: O(log_b(n))
    
    Examples:
        >>> is_palindrome_base(10, 121)
        True
        >>> is_palindrome_base(10, 196)
        False
    """
    d = digits_base(b, n)
    return d == list(reversed(d))


# ============================================================
# Reverse-and-add iteration
# ============================================================

def rev_add_step(b: int, n: int) -> int:
    """One step of the reverse-and-add algorithm."""
    return n + reverse_digits(b, n)


def rev_add_orbit(b: int, n: int, max_steps: int = 1000) -> list[int]:
    """
    Compute the reverse-and-add orbit of n in base b.
    Stops early if a palindrome is reached.
    
    Returns the orbit as a list [n, T(n), T²(n), ...].
    
    Time: O(max_steps * D) where D = digit count of largest iterate
    Space: O(max_steps * D)
    
    Examples:
        >>> rev_add_orbit(10, 89, 30)  # 89 reaches palindrome at step 24
        [89, 187, 968, ...]
    """
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if is_palindrome_base(b, current) and len(orbit) > 1:
            break
        current = rev_add_step(b, current)
        orbit.append(current)
    return orbit


def find_palindrome_step(b: int, n: int, max_steps: int = 10000) -> Optional[int]:
    """
    Find the first step k > 0 at which rev_add_iter(b, k, n) is a palindrome.
    Returns None if no palindrome is found within max_steps.
    
    Examples:
        >>> find_palindrome_step(10, 89)
        24
        >>> find_palindrome_step(10, 196, 1000)  # returns None
    """
    current = n
    for k in range(1, max_steps + 1):
        current = rev_add_step(b, current)
        if is_palindrome_base(b, current):
            return k
    return None


# ============================================================
# Modular residue analysis (Theorems D & E)
# ============================================================

def modular_orbit(b: int, n: int, m: int, max_steps: int) -> list[int]:
    """
    Compute the orbit of n modulo m under reverse-and-add in base b.
    
    By Theorem E: rev_add_iter(b, k, n) ≡ 2^k * n (mod b-1).
    This function computes the actual residues for comparison.
    
    Time: O(max_steps * log_b(n_k)) where n_k is the k-th iterate
    """
    residues = []
    current = n
    for _ in range(max_steps + 1):
        residues.append(current % m)
        current = rev_add_step(b, current)
    return residues


def predicted_residues_mod_base_pred(b: int, n: int, max_steps: int) -> list[int]:
    """
    Compute predicted residues using Theorem E: iter_k ≡ 2^k * n (mod b-1).
    
    Time: O(max_steps)
    """
    m = b - 1
    if m == 0:
        return [0] * (max_steps + 1)
    return [pow(2, k, m) * n % m for k in range(max_steps + 1)]


def palindrome_residues(b: int, m: int, max_digits: int) -> set[int]:
    """
    Compute all residues modulo m achieved by base-b palindromes
    with at most max_digits digits.
    
    Time: O(b^(max_digits/2) * max_digits)
    
    Examples:
        >>> sorted(palindrome_residues(10, 9, 3))
        [0]
    """
    residues = set()
    # Generate all palindromes up to max_digits digits
    for length in range(1, max_digits + 1):
        half = (length + 1) // 2
        # Generate all possible first-half digit sequences
        for i in range(b ** half):
            first_half = digits_base(b, i) if i > 0 else [0]
            # Pad to half length
            while len(first_half) < half:
                first_half.append(0)
            first_half = first_half[:half]
            
            # Build palindrome
            if length % 2 == 0:
                full = first_half + list(reversed(first_half))
            else:
                full = first_half + list(reversed(first_half[:-1]))
            
            # Skip if leading digit (last in LSB-first) is 0 for multi-digit
            if length > 1 and full[-1] == 0:
                continue
            
            n = of_digits_base(b, full)
            residues.add(n % m)
    
    residues.add(0)  # 0 is a palindrome
    return residues


def residue_obstruction_check(b: int, n: int, m: int, K: int) -> dict:
    """
    Check if any iterate of n (up to step K) has a residue mod m
    that is incompatible with palindromicity.
    
    Returns a dict with analysis results.
    
    This implements the residue exclusion principle from Theorem F.
    """
    # Estimate max digits needed
    current = n
    max_val = n
    for k in range(K + 1):
        if k > 0:
            current = rev_add_step(b, current)
        max_val = max(max_val, current)
    
    max_digits = len(digits_base(b, max_val)) + 1
    pal_res = palindrome_residues(b, m, max_digits)
    
    obstructions = []
    current = n
    for k in range(K + 1):
        r = current % m
        if r not in pal_res:
            obstructions.append((k, current, r))
        if k < K:
            current = rev_add_step(b, current)
    
    return {
        "modulus": m,
        "palindrome_residues": sorted(pal_res),
        "num_obstructed_steps": len(obstructions),
        "total_steps": K + 1,
        "obstructed_steps": obstructions[:20],  # first 20
    }


# ============================================================
# Carry automaton
# ============================================================

def carry_add(b: int, pairs: list[tuple[int, int]], carry: int = 0) -> tuple[list[int], int]:
    """
    Simulate the carry automaton for addition.
    
    Given pairs of digits and initial carry, produce output digits
    and trace the carry states.
    
    Returns: (output_digits_lsb_first, final_carry)
    
    Time: O(len(pairs))
    Space: O(len(pairs))
    """
    output = []
    c = carry
    for a, d in pairs:
        s = a + d + c
        output.append(s % b)
        c = s // b
    return output, c


def carry_automaton_eval(b: int, digit_list: list[int]) -> int:
    """
    Evaluate the carry automaton: add n to its digit-reversal
    by processing digit pairs with carry propagation.
    
    This computes the same result as rev_add_step(b, n) but
    through the finite-state automaton formulation.
    """
    pairs = list(zip(digit_list, list(reversed(digit_list))))
    out_digits, final_carry = carry_add(b, pairs)
    # Append remaining carry digits
    while final_carry > 0:
        out_digits.append(final_carry % b)
        final_carry //= b
    return of_digits_base(b, out_digits)


def carry_state_trace(b: int, n: int) -> list[int]:
    """
    Trace the carry states during one reverse-and-add step.
    
    Returns the sequence of carry values [c_0, c_1, ..., c_L]
    where c_0 = 0 (initial carry) and c_i is the carry into position i.
    
    This is the state sequence of the carry automaton.
    """
    d = digits_base(b, n)
    rev_d = list(reversed(d))
    carries = [0]
    c = 0
    for a, r in zip(d, rev_d):
        s = a + r + c
        c = s // b
        carries.append(c)
    return carries


# ============================================================
# Lychrel candidate detection
# ============================================================

def classify_seeds(b: int, max_n: int, max_steps: int = 500) -> dict:
    """
    Classify natural numbers up to max_n as reaching palindrome or
    Lychrel candidates in base b.
    
    Returns dict with 'palindromic' and 'lychrel_candidates' lists.
    """
    palindromic = {}  # n -> steps to palindrome
    candidates = []
    
    for n in range(1, max_n + 1):
        step = find_palindrome_step(b, n, max_steps)
        if step is not None:
            palindromic[n] = step
        else:
            candidates.append(n)
    
    return {
        "base": b,
        "range": max_n,
        "max_steps": max_steps,
        "palindromic_count": len(palindromic),
        "candidate_count": len(candidates),
        "candidates": candidates,
        "slowest_convergers": sorted(palindromic.items(), key=lambda x: -x[1])[:10],
    }


if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")
    
    # Example 1: Basic operations
    print("digits_base(10, 196) =", digits_base(10, 196))
    print("reverse_digits(10, 196) =", reverse_digits(10, 196))
    print("rev_add_step(10, 196) =", rev_add_step(10, 196))
    print()
    
    # Example 2: Verify Theorem E
    print("Theorem E verification (base 10, n=196, mod 9):")
    for k in range(8):
        actual = rev_add_orbit(10, 196, k + 1)[-1] % 9
        predicted = pow(2, k, 9) * 196 % 9
        print(f"  k={k}: actual={actual}, predicted={predicted}, match={actual == predicted}")
    print()
    
    # Example 3: Carry automaton
    print("Carry automaton verification:")
    for n in [196, 887, 1675]:
        d = digits_base(10, n)
        arith = rev_add_step(10, n)
        autom = carry_automaton_eval(10, d)
        trace = carry_state_trace(10, n)
        print(f"  n={n}: arithmetic={arith}, automaton={autom}, carries={trace}")
    print()
    
    # Example 4: Lychrel candidates in base 10 up to 1000
    print("Lychrel candidate search (base 10, n ≤ 1000, 500 steps):")
    result = classify_seeds(10, 1000, 500)
    print(f"  Palindromic: {result['palindromic_count']}")
    print(f"  Candidates:  {result['candidate_count']}")
    print(f"  Candidate list: {result['candidates'][:20]}...")
    print(f"  Slowest convergers: {result['slowest_convergers'][:5]}")
