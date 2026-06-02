#!/usr/bin/env python3
"""
Algorithms for the GL₁ Langlands Correspondence

Type-hinted implementations of the core algorithms used in the
shape-color correspondence between quadratic fields and Dirichlet characters.
"""

from math import gcd, sqrt, log
from typing import List, Tuple, Dict, Optional


def jacobi_symbol(a: int, n: int) -> int:
    """
    Compute the Jacobi symbol (a/n) for odd positive n.
    
    Algorithm: Binary Jacobi symbol computation.
    Time complexity: O(log(a) · log(n))
    
    The Jacobi symbol generalizes the Legendre symbol to composite
    odd moduli. It is the "evaluation map" of the shape-color
    correspondence: J(D, p) tells you how prime p behaves in Q(√d).
    
    Args:
        a: Integer (the "shape" parameter — discriminant D)
        n: Odd positive integer (the "color" parameter — prime p)
    
    Returns:
        -1, 0, or 1
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n must be odd and positive, got {n}")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def quad_disc(d: int) -> int:
    """
    Compute the fundamental discriminant of Q(√d).
    
    For squarefree d:
        D = d    if d ≡ 1 (mod 4)
        D = 4d   otherwise
    
    This is the "shape → color" map: it assigns to each
    quadratic field its unique discriminant.
    
    Args:
        d: Squarefree integer
    
    Returns:
        Fundamental discriminant D
    """
    return d if d % 4 == 1 else 4 * d


def is_squarefree(n: int) -> bool:
    """Check whether n is squarefree (not divisible by any perfect square > 1)."""
    if n == 0:
        return False
    n = abs(n)
    for p in range(2, int(n**0.5) + 1):
        if n % (p * p) == 0:
            return False
    return True


def splitting_type(D: int, p: int) -> str:
    """
    Determine how prime p behaves in the quadratic field with discriminant D.
    
    Returns:
        "split" if J(D, p) = +1 (p splits into two primes)
        "inert" if J(D, p) = -1 (p remains prime)
        "ramified" if J(D, p) = 0 (p divides the discriminant)
    """
    if p == 2:
        if D % 2 == 0:
            return "ramified"
        elif D % 8 in (1, 7):
            return "split"
        else:
            return "inert"
    
    j = jacobi_symbol(D, p)
    if j == 1:
        return "split"
    elif j == -1:
        return "inert"
    else:
        return "ramified"


def shape_color_dictionary(d_range: Tuple[int, int],
                           primes: List[int]) -> Dict[int, Dict[str, object]]:
    """
    Build the complete shape-color dictionary for squarefree d in range.
    
    For each squarefree d, computes:
    - The discriminant D = quadDisc(d)
    - The splitting behavior of each prime
    - The character values χ_D(p)
    
    Args:
        d_range: (min_d, max_d) range of squarefree integers to consider
        primes: List of primes to evaluate the character at
    
    Returns:
        Dictionary mapping d to its shape-color data
    """
    result: Dict[int, Dict[str, object]] = {}
    
    for d in range(d_range[0], d_range[1] + 1):
        if d == 0 or not is_squarefree(d):
            continue
        
        D = quad_disc(d)
        character_values: Dict[int, int] = {}
        splitting: Dict[int, str] = {}
        
        for p in primes:
            splitting[p] = splitting_type(D, p)
            if p == 2:
                character_values[p] = {"split": 1, "inert": -1, "ramified": 0}[splitting[p]]
            elif p % 2 == 1:
                character_values[p] = jacobi_symbol(D, p)
        
        result[d] = {
            "discriminant": D,
            "field": f"Q(√{d})",
            "character_values": character_values,
            "splitting": splitting,
        }
    
    return result


def verify_bimultiplicativity(a1: int, a2: int, b1: int, b2: int) -> bool:
    """
    Verify J(a1·a2, b1·b2) = J(a1,b1)·J(a1,b2)·J(a2,b1)·J(a2,b2)
    for odd positive b1, b2.
    
    Args:
        a1, a2: Integer factors for the first argument
        b1, b2: Odd positive integer factors for the second argument
    
    Returns:
        True if the bi-multiplicativity identity holds
    """
    lhs = jacobi_symbol(a1 * a2, b1 * b2)
    rhs = (jacobi_symbol(a1, b1) * jacobi_symbol(a1, b2) *
           jacobi_symbol(a2, b1) * jacobi_symbol(a2, b2))
    return lhs == rhs


def verify_reciprocity(a: int, b: int) -> Tuple[bool, int, int]:
    """
    Verify J(a,b)·J(b,a) = (-1)^((a//2)·(b//2)) for coprime odd a, b.
    
    Returns:
        (passed, lhs_value, rhs_value)
    """
    if a % 2 == 0 or b % 2 == 0 or gcd(a, b) != 1:
        raise ValueError("a and b must be coprime and odd")
    
    lhs = jacobi_symbol(a, b) * jacobi_symbol(b, a)
    exp = (a // 2) * (b // 2)
    rhs = (-1) ** exp
    return (lhs == rhs, lhs, rhs)


def character_partial_sum(D: int, N: int) -> List[int]:
    """
    Compute partial sums S_k = Σ_{n=1}^{k} χ_D(n) for k = 1, ..., N.
    
    Uses the Jacobi symbol for odd n coprime to D,
    and the Kronecker extension for even n.
    
    Args:
        D: Fundamental discriminant
        N: Upper bound for partial sums
    
    Returns:
        List of partial sums [S_1, S_2, ..., S_N]
    """
    sums: List[int] = []
    running_sum = 0
    for n in range(1, N + 1):
        if gcd(n, abs(D)) > 1:
            chi_n = 0
        elif n % 2 == 0:
            # Kronecker extension for even n
            chi_n = 0  # Simplified: χ_D(2) handled separately
            temp = n
            twos = 0
            while temp % 2 == 0:
                temp //= 2
                twos += 1
            if temp == 1:
                # Pure power of 2
                chi_2 = 0 if D % 2 == 0 else (1 if D % 8 in (1, 7) else -1)
                chi_n = chi_2 ** twos
            else:
                chi_2 = 0 if D % 2 == 0 else (1 if D % 8 in (1, 7) else -1)
                chi_n = (chi_2 ** twos) * jacobi_symbol(D, temp)
        else:
            chi_n = jacobi_symbol(D, n)
        running_sum += chi_n
        sums.append(running_sum)
    return sums


def find_quadratic_nonresidues(p: int) -> List[int]:
    """
    Find all quadratic non-residues modulo an odd prime p.
    
    These are the integers a ∈ {1, ..., p-1} with J(a, p) = -1.
    The non-triviality theorem guarantees this list is non-empty.
    
    Returns:
        List of quadratic non-residues
    """
    return [a for a in range(1, p) if jacobi_symbol(a, p) == -1]


# ============================================================
# Main demonstration
# ============================================================
if __name__ == "__main__":
    print("=== Shape-Color Dictionary for d ∈ [-10, 10] ===\n")
    
    primes = [2, 3, 5, 7, 11, 13]
    dictionary = shape_color_dictionary((-10, 10), primes)
    
    for d in sorted(dictionary.keys()):
        entry = dictionary[d]
        chars = ", ".join(f"χ({p})={v}" for p, v in sorted(entry["character_values"].items()))
        print(f"  {entry['field']:>10}  D={entry['discriminant']:>4}  {chars}")
    
    print("\n=== Bi-multiplicativity Verification ===\n")
    
    passed = 0
    total = 0
    for a1 in range(-5, 6):
        for a2 in range(-5, 6):
            for b1 in [3, 5, 7, 9, 11]:
                for b2 in [3, 5, 7, 9, 11]:
                    if verify_bimultiplicativity(a1, a2, b1, b2):
                        passed += 1
                    total += 1
    
    print(f"  Tested {total} cases, {passed} passed ({100*passed/total:.1f}%)")
    
    print("\n=== Reciprocity Verification ===\n")
    
    passed = 0
    total = 0
    for a in range(3, 50, 2):
        for b in range(3, 50, 2):
            if gcd(a, b) == 1:
                ok, _, _ = verify_reciprocity(a, b)
                if ok:
                    passed += 1
                total += 1
    
    print(f"  Tested {total} coprime odd pairs, {passed} passed ({100*passed/total:.1f}%)")
