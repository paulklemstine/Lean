#!/usr/bin/env python3
"""
Applications of Reverse-and-Add Dynamics
=========================================

This module demonstrates practical applications of the formally verified
theorems about reverse-and-add dynamics:

1. Palindrome sieving using modular obstructions
2. Lychrel candidate classification
3. Orbit complexity analysis
4. Signature-based orbit prediction

Each application references the corresponding formally verified result.
"""

from typing import List, Dict, Tuple, Optional, Set
from collections import defaultdict
import time


# ============================================================================
# Core Functions (self-contained)
# ============================================================================

def digits10(n: int) -> List[int]:
    """Base-10 digits, least significant first."""
    if n == 0:
        return []
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def reverse_nat(n: int) -> int:
    """Digit reversal."""
    d = digits10(n)
    return sum(digit * 10**i for i, digit in enumerate(reversed(d)))


def rev_add(n: int) -> int:
    """Reverse-and-add: T(n) = n + rev(n)."""
    return n + reverse_nat(n)


def is_palindrome(n: int) -> bool:
    """Check palindromicity."""
    s = str(n)
    return s == s[::-1]


def symmetry_defect(n: int) -> int:
    """Symmetry defect of n's digit representation."""
    d = digits10(n)
    length = len(d)
    return sum(abs(d[i] - d[length - 1 - i]) for i in range(length // 2))


# ============================================================================
# Application 1: Palindrome Sieving via Modular Obstructions
# ============================================================================

def palindrome_sieve(limit: int) -> Dict[str, List[int]]:
    """
    Classify numbers by palindrome reachability using modular sieves.

    Uses the formally verified theorem:
        palindrome_mod11_of_even_length: even-length palindromes ≡ 0 (mod 11)

    This creates a sieve: at each step of the orbit, if the number has an
    even number of digits and is not ≡ 0 (mod 11), it cannot be an
    even-length palindrome.

    Application: Pre-filter palindrome candidates to reduce search space.
    """
    results = {
        'quick_palindromes': [],      # Reach palindrome within 10 steps
        'delayed_palindromes': [],     # Reach palindrome in 11-100 steps
        'persistent_candidates': [],   # No palindrome in 100 steps
        'mod11_obstructed_steps': [],  # Steps where mod 11 obstruction applies
    }

    for seed in range(1, limit + 1):
        n = seed
        found = False
        obstructed_count = 0

        for step in range(100):
            if is_palindrome(n) and step > 0:
                if step <= 10:
                    results['quick_palindromes'].append((seed, step))
                else:
                    results['delayed_palindromes'].append((seed, step))
                found = True
                break

            # Check mod 11 obstruction
            d = digits10(n)
            if len(d) % 2 == 0 and n % 11 != 0:
                obstructed_count += 1

            n = rev_add(n)

        if not found:
            results['persistent_candidates'].append(seed)
            results['mod11_obstructed_steps'].append((seed, obstructed_count))

    return results


# ============================================================================
# Application 2: Lychrel Candidate Classification
# ============================================================================

def classify_lychrel_candidates(limit: int, depth: int = 200) -> Dict[str, any]:
    """
    Classify potential Lychrel candidates by their orbit characteristics.

    Uses formally verified properties:
    - strict_growth_of_nonpalindrome: orbit grows strictly
    - revAdd_mod9: mod 9 evolves as 2n
    - palindrome_mod11_of_even_length: even-length palindrome obstruction

    Returns classification by:
    - Mod 9 residue class
    - Growth rate (digit length increase per step)
    - Maximum carry frequency
    """
    candidates = []
    classes = defaultdict(list)

    for seed in range(1, limit + 1):
        n = seed
        found_palindrome = False

        for _ in range(depth):
            n = rev_add(n)
            if is_palindrome(n):
                found_palindrome = True
                break

        if not found_palindrome:
            mod9_class = seed % 9
            digit_growth = len(str(n)) - len(str(seed))
            candidates.append({
                'seed': seed,
                'mod9': mod9_class,
                'digit_growth': digit_growth,
                'final_digits': len(str(n)),
            })
            classes[mod9_class].append(seed)

    return {
        'candidates': candidates,
        'by_mod9': dict(classes),
        'total': len(candidates),
    }


# ============================================================================
# Application 3: Orbit Complexity Analysis
# ============================================================================

def orbit_complexity_profile(seed: int, steps: int = 50) -> Dict:
    """
    Analyze the complexity profile of a reverse-and-add orbit.

    Measures:
    - Digit length growth rate
    - Symmetry defect trajectory
    - Carry density (fraction of positions with carry)
    - Mod 9 and mod 11 trajectories

    Application: Identify structural patterns that distinguish Lychrel
    candidates from numbers that eventually reach palindromes.
    """
    n = seed
    profile = {
        'seed': seed,
        'digit_lengths': [],
        'defects': [],
        'carry_densities': [],
        'mod9': [],
        'mod11': [],
        'values': [],
    }

    for step in range(steps):
        d = digits10(n)
        rev_d = list(reversed(d))

        # Compute carries
        carries = 0
        c = 0
        for i in range(len(d)):
            s = d[i] + rev_d[i] + c
            if s >= 10:
                carries += 1
            c = s // 10

        profile['digit_lengths'].append(len(d))
        profile['defects'].append(symmetry_defect(n))
        profile['carry_densities'].append(carries / max(len(d), 1))
        profile['mod9'].append(n % 9)
        profile['mod11'].append(n % 11)
        profile['values'].append(n)

        if is_palindrome(n) and step > 0:
            profile['palindrome_step'] = step
            break

        n = rev_add(n)

    # Compute growth rate
    lengths = profile['digit_lengths']
    if len(lengths) > 1:
        profile['avg_growth_rate'] = (lengths[-1] - lengths[0]) / (len(lengths) - 1)
    else:
        profile['avg_growth_rate'] = 0

    return profile


# ============================================================================
# Application 4: Signature-Based Orbit Prediction
# ============================================================================

def signature_prediction_accuracy(limit: int = 500, steps: int = 50) -> Dict:
    """
    Test how well the mod 9 algebraic prediction matches actual orbits.

    By revAdd_mod9_iter: T^k(n) % 9 = (2^k * n) % 9

    This prediction is exact (formally verified) and can be computed in O(1)
    per step without performing the actual reverse-and-add.

    Application: Fast pre-screening of orbit properties.
    """
    total_predictions = 0
    correct_predictions = 0
    mod9_period = 6  # ord_9(2) = 6

    for seed in range(1, limit + 1):
        n = seed
        for k in range(steps):
            predicted_mod9 = (pow(2, k, 9) * seed) % 9
            actual_mod9 = n % 9

            total_predictions += 1
            if predicted_mod9 == actual_mod9:
                correct_predictions += 1
            else:
                print(f"  MISMATCH at seed={seed}, step={k}: "
                      f"predicted={predicted_mod9}, actual={actual_mod9}")

            n = rev_add(n)
            if is_palindrome(n):
                break

    return {
        'total_predictions': total_predictions,
        'correct_predictions': correct_predictions,
        'accuracy': correct_predictions / total_predictions if total_predictions > 0 else 0,
        'mod9_period': mod9_period,
    }


# ============================================================================
# Application 5: Comparative Orbit Statistics
# ============================================================================

def comparative_statistics(seeds: List[int], steps: int = 100) -> None:
    """
    Compare orbit statistics across multiple seeds.

    Highlights differences between numbers that reach palindromes
    and Lychrel candidates.
    """
    print(f"\n{'Seed':>8} {'Steps':>8} {'Palindrome':>12} {'Final Len':>10} "
          f"{'Avg Defect':>12} {'Avg Carry%':>12} {'Mod9':>6} {'Mod11':>6}")
    print("-" * 82)

    for seed in seeds:
        profile = orbit_complexity_profile(seed, steps)
        pal_step = profile.get('palindrome_step', None)
        avg_defect = sum(profile['defects']) / len(profile['defects']) if profile['defects'] else 0
        avg_carry = sum(profile['carry_densities']) / len(profile['carry_densities']) if profile['carry_densities'] else 0

        print(f"{seed:8d} {len(profile['values']):8d} "
              f"{'Step ' + str(pal_step) if pal_step else 'NO':>12} "
              f"{profile['digit_lengths'][-1]:10d} "
              f"{avg_defect:12.2f} {avg_carry:12.3f} "
              f"{seed % 9:6d} {seed % 11:6d}")


# ============================================================================
# Main Demonstration
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("  APPLICATIONS OF REVERSE-AND-ADD DYNAMICS")
    print("  Based on Formally Verified Theorems")
    print("=" * 70)

    # Application 1: Palindrome Sieving
    print("\n" + "=" * 70)
    print("  APPLICATION 1: Palindrome Sieving via Mod 11 Obstruction")
    print("=" * 70)
    sieve = palindrome_sieve(200)
    print(f"\n  Numbers 1-200:")
    print(f"    Quick palindromes (≤10 steps): {len(sieve['quick_palindromes'])}")
    print(f"    Delayed palindromes (11-100 steps): {len(sieve['delayed_palindromes'])}")
    print(f"    Persistent candidates (>100 steps): {len(sieve['persistent_candidates'])}")
    print(f"    Persistent candidates: {sieve['persistent_candidates'][:20]}...")

    # Application 2: Lychrel Classification
    print("\n" + "=" * 70)
    print("  APPLICATION 2: Lychrel Candidate Classification")
    print("=" * 70)
    classification = classify_lychrel_candidates(500, depth=100)
    print(f"\n  Lychrel candidates up to 500: {classification['total']}")
    print(f"  Distribution by mod 9 residue:")
    for mod9, seeds in sorted(classification['by_mod9'].items()):
        print(f"    mod 9 ≡ {mod9}: {len(seeds)} candidates ({seeds[:5]}{'...' if len(seeds) > 5 else ''})")

    # Application 3: Mod 9 Prediction Verification
    print("\n" + "=" * 70)
    print("  APPLICATION 3: Mod 9 Algebraic Prediction Accuracy")
    print("=" * 70)
    accuracy = signature_prediction_accuracy(200, 30)
    print(f"\n  Total predictions: {accuracy['total_predictions']}")
    print(f"  Correct: {accuracy['correct_predictions']}")
    print(f"  Accuracy: {accuracy['accuracy']:.4%}")
    print(f"  (This is 100% by formal verification of revAdd_mod9)")

    # Application 4: Comparative Statistics
    print("\n" + "=" * 70)
    print("  APPLICATION 4: Comparative Orbit Statistics")
    print("=" * 70)
    test_seeds = [89, 196, 197, 295, 394, 493, 592, 689, 691, 788, 879, 978]
    comparative_statistics(test_seeds, steps=50)

    # Application 5: Orbit Complexity for 196
    print("\n" + "=" * 70)
    print("  APPLICATION 5: Orbit Complexity Profile for 196")
    print("=" * 70)
    profile = orbit_complexity_profile(196, steps=40)
    print(f"\n  Digit length growth: {profile['digit_lengths'][:15]}...")
    print(f"  Average growth rate: {profile['avg_growth_rate']:.3f} digits/step")
    print(f"  Symmetry defects: {profile['defects'][:15]}...")
    print(f"  All defects positive: {all(d > 0 for d in profile['defects'])}")
    print(f"  Carry densities: {[f'{c:.2f}' for c in profile['carry_densities'][:10]]}...")

    print("\n" + "=" * 70)
    print("  All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Reverse-and-Add Dynamics Explorer
=================================

Interactive exploration of reverse-and-add orbits, demonstrating:
- Digit strings, reversals, and carries
- Symmetry defect evolution
- Modular signatures (mod 9, mod 11)
- Palindrome detection and obstruction analysis

Usage:
    python demo.py [seed]

If no seed is given, defaults to 196.
"""

import sys
from typing import List, Tuple


def digits10(n: int) -> List[int]:
    """Return base-10 digits of n (least significant first), matching the Lean definition."""
    if n == 0:
        return []
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def of_digits10(L: List[int]) -> int:
    """Reconstruct a number from its base-10 digit list (little-endian)."""
    result = 0
    for i, d in enumerate(L):
        result += d * (10 ** i)
    return result


def reverse_nat(n: int) -> int:
    """Digit reversal: reverse base-10 digits and reconstruct."""
    return of_digits10(list(reversed(digits10(n))))


def rev_add(n: int) -> int:
    """The reverse-and-add map: T(n) = n + rev(n)."""
    return n + reverse_nat(n)


def is_palindrome(n: int) -> bool:
    """Check if n is a base-10 palindrome."""
    d = digits10(n)
    return d == list(reversed(d))


def symmetry_defect(L: List[int]) -> int:
    """
    Compute the symmetry defect of a digit list.
    Sum of |L[i] - L[len-1-i]| for i < len/2.
    Zero iff L is a palindrome.
    """
    length = len(L)
    total = 0
    for i in range(length // 2):
        j = length - 1 - i
        total += abs(L[i] - L[j])
    return total


def compute_carries(n: int) -> Tuple[List[int], List[int]]:
    """
    Compute the carry profile when adding n to its reversal.
    Returns (output_digits, carries) where carries[i] is the carry into position i.
    """
    d = digits10(n)
    r = list(reversed(d))
    # Pad to same length
    max_len = max(len(d), len(r))
    d = d + [0] * (max_len - len(d))
    r = r + [0] * (max_len - len(r))

    carries = [0] * (max_len + 1)
    output = []
    for i in range(max_len):
        s = d[i] + r[i] + carries[i]
        output.append(s % 10)
        carries[i + 1] = s // 10
    if carries[max_len] > 0:
        output.append(carries[max_len])
    return output, carries


def digit_signature(n: int) -> dict:
    """Compute the digit signature of n."""
    d = digits10(n)
    return {
        'len': len(d),
        'mod9': n % 9,
        'mod11': n % 11,
        'first_digit': d[-1] if d else 0,
        'last_digit': d[0] if d else 0,
        'defect': symmetry_defect(d),
    }


def format_number_big_endian(n: int) -> str:
    """Return the number as a big-endian digit string."""
    if n == 0:
        return "0"
    return str(n)


def explore_orbit(seed: int, max_steps: int = 50, verbose: bool = True) -> List[int]:
    """
    Explore the reverse-and-add orbit starting from seed.

    Args:
        seed: Starting number
        max_steps: Maximum number of iterations
        verbose: Print detailed information at each step

    Returns:
        List of orbit values
    """
    orbit = [seed]
    n = seed

    if verbose:
        print(f"{'='*80}")
        print(f"  REVERSE-AND-ADD ORBIT STARTING AT {seed}")
        print(f"{'='*80}")
        print()

    for step in range(max_steps):
        d = digits10(n)
        rev_d = list(reversed(d))
        rev_n = reverse_nat(n)
        sig = digit_signature(n)
        output_digits, carries = compute_carries(n)

        if verbose:
            print(f"Step {step:4d}: n = {n}")
            print(f"          digits (LE) = {d}")
            print(f"          reversed    = {rev_d}")
            print(f"          rev(n)      = {rev_n}")
            print(f"          carries     = {carries[:len(d)+1]}")
            print(f"          defect      = {sig['defect']}")
            print(f"          mod 9 = {sig['mod9']}, mod 11 = {sig['mod11']}, "
                  f"len = {sig['len']}")

            if is_palindrome(n):
                print(f"  *** PALINDROME FOUND at step {step}! ***")
                print()
                break

            # Verify mod 9 theorem: revAdd(n) % 9 == (2*n) % 9
            next_n = rev_add(n)
            assert next_n % 9 == (2 * n) % 9, "Mod 9 theorem violated!"

            # For even-length palindromes, verify mod 11 = 0
            if is_palindrome(n) and len(d) % 2 == 0:
                assert n % 11 == 0, "Even-length palindrome mod 11 theorem violated!"

            print()

        n = rev_add(n)
        orbit.append(n)

        if is_palindrome(n) and not verbose:
            break

    return orbit


def demonstrate_mod9_invariant(seed: int = 196, steps: int = 20):
    """Demonstrate the mod 9 evolution law: T^k(n) ≡ 2^k * n (mod 9)."""
    print(f"\n{'='*60}")
    print(f"  MOD 9 EVOLUTION LAW: T^k(n) ≡ 2^k · n (mod 9)")
    print(f"  Starting from n = {seed}")
    print(f"{'='*60}\n")

    n = seed
    print(f"{'Step':>6} {'Value':>20} {'val%9':>6} {'2^k*{0}%9'.format(seed):>12} {'Match':>6}")
    print(f"{'-'*56}")

    for k in range(steps):
        val_mod9 = n % 9
        predicted = (pow(2, k, 9) * seed) % 9
        match = "✓" if val_mod9 == predicted else "✗"
        print(f"{k:6d} {n:20d} {val_mod9:6d} {predicted:12d} {match:>6}")
        n = rev_add(n)


def demonstrate_mod11_obstruction():
    """Demonstrate the mod 11 obstruction for even-length palindromes."""
    print(f"\n{'='*60}")
    print(f"  MOD 11 OBSTRUCTION: Even-length palindromes ≡ 0 (mod 11)")
    print(f"{'='*60}\n")

    # Find some even-length palindromes
    palindromes = []
    for n in range(10, 10000):
        if is_palindrome(n) and len(digits10(n)) % 2 == 0:
            palindromes.append(n)

    print(f"{'Palindrome':>12} {'Digits':>8} {'Length':>8} {'mod 11':>8} {'Div by 11':>10}")
    print(f"{'-'*50}")

    for p in palindromes[:25]:
        d = digits10(p)
        print(f"{p:12d} {str(p):>8} {len(d):8d} {p % 11:8d} {'YES' if p % 11 == 0 else 'NO':>10}")


def demonstrate_symmetry_defect(seed: int = 196, steps: int = 30):
    """Track symmetry defect evolution along the orbit."""
    print(f"\n{'='*60}")
    print(f"  SYMMETRY DEFECT EVOLUTION FROM {seed}")
    print(f"{'='*60}\n")

    n = seed
    print(f"{'Step':>6} {'Value':>15} {'Defect':>8} {'Len':>5} {'Palindrome':>12}")
    print(f"{'-'*50}")

    for k in range(steps):
        d = digits10(n)
        defect = symmetry_defect(d)
        pal = is_palindrome(n)
        print(f"{k:6d} {n:15d} {defect:8d} {len(d):5d} {'YES' if pal else 'no':>12}")
        if pal:
            print(f"\n  Palindrome reached at step {k}!")
            break
        n = rev_add(n)


def search_lychrel_candidates(limit: int = 1000, test_steps: int = 200):
    """Search for Lychrel candidates up to a given limit."""
    print(f"\n{'='*60}")
    print(f"  LYCHREL CANDIDATE SEARCH (up to {limit}, {test_steps} steps each)")
    print(f"{'='*60}\n")

    candidates = []
    for seed in range(1, limit + 1):
        n = seed
        found_palindrome = False
        for _ in range(test_steps):
            n = rev_add(n)
            if is_palindrome(n):
                found_palindrome = True
                break
        if not found_palindrome:
            candidates.append(seed)

    print(f"Found {len(candidates)} Lychrel candidates up to {limit}:")
    for i, c in enumerate(candidates):
        sig = digit_signature(c)
        print(f"  {c:6d}  (mod9={sig['mod9']}, mod11={sig['mod11']}, "
              f"len={sig['len']}, defect={sig['defect']})")
        if i >= 30:
            print(f"  ... and {len(candidates) - i - 1} more")
            break


def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 196

    # Main orbit exploration
    explore_orbit(seed, max_steps=30)

    # Demonstrate the formally verified mod 9 invariant
    demonstrate_mod9_invariant(seed)

    # Demonstrate the mod 11 obstruction theorem
    demonstrate_mod11_obstruction()

    # Track symmetry defect
    demonstrate_symmetry_defect(seed)

    # Search for Lychrel candidates
    search_lychrel_candidates(limit=300, test_steps=100)

    print(f"\n{'='*60}")
    print("  All demonstrations complete.")
    print("  Key formally verified properties:")
    print("    • revAdd(n) % 9 = (2*n) % 9")
    print("    • Even-length palindromes are divisible by 11")
    print("    • symmetryDefect = 0 ⟺ palindrome")
    print("    • n < revAdd(n) for n > 0 (strict growth)")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
