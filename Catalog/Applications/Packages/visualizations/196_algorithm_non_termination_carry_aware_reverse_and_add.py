#!/usr/bin/env python3
"""
Algorithms for Reverse-and-Add Dynamics
========================================

This module implements certified algorithms for:
1. Carry-aware reverse-and-add computation
2. Symmetry defect calculation and tracking
3. Modular signature evolution
4. Palindrome obstruction checking
5. Digit signature automata simulation

Each algorithm includes correctness documentation referencing
the formally verified theorems.

Complexity Analysis:
- All single-step operations are O(d) where d = number of digits
- Orbit computation for k steps is O(k * d_max) where d_max is max digit count
- Signature tracking is O(1) per step after initialization
"""

from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass
from collections import defaultdict


# ============================================================================
# Core Data Structures
# ============================================================================

@dataclass
class CarryProfile:
    """
    Carry profile for reverse-and-add computation.

    When computing n + rev(n), the carries at each position determine the
    output digits. This structure tracks the full carry chain.

    Formally corresponds to the CarryProfile structure in the Lean formalization.
    """
    input_len: int
    carries: List[int]  # carries[i] = carry into position i

    @property
    def max_carry(self) -> int:
        return max(self.carries) if self.carries else 0

    @property
    def has_overflow(self) -> bool:
        """Whether the addition produces a carry beyond the input length."""
        return self.carries[self.input_len] > 0 if len(self.carries) > self.input_len else False


@dataclass
class DigitState:
    """
    Complete state of a number in the digit representation.

    Maintains coherence between the numeric value and its digit decomposition,
    along with the carry profile from the most recent reverse-and-add step.
    """
    digits: List[int]     # Little-endian base-10 digits
    carries: List[int]    # Carry profile from last step
    value: int            # The actual number

    @property
    def coherent(self) -> bool:
        """Verify that value equals ofDigits10(digits)."""
        return self.value == sum(d * 10**i for i, d in enumerate(self.digits))


@dataclass
class DigitSignature:
    """
    Reduced state for automata-style analysis of reverse-and-add dynamics.

    Captures enough information to track modular evolution and basic
    structural properties without storing the full digit string.
    """
    length: int
    mod9: int
    mod11: int
    first_digit: int
    last_digit: int
    defect_parity: bool  # Whether symmetry defect is odd

    def __hash__(self):
        return hash((self.length, self.mod9, self.mod11,
                      self.first_digit, self.last_digit, self.defect_parity))


# ============================================================================
# Algorithm 1: Carry-Aware Reverse-and-Add
# ============================================================================

def carry_aware_rev_add(n: int) -> Tuple[int, CarryProfile, DigitState]:
    """
    Compute rev_add(n) with full carry tracking.

    Returns:
        result: The value n + rev(n)
        profile: Complete carry profile
        state: Full digit state of the result

    Complexity: O(d) where d = number of digits of n

    Correctness: Verified to agree with the arithmetic definition
    revAdd n = n + reverseNat n (Lean: revAdd_spec).
    """
    if n == 0:
        profile = CarryProfile(input_len=0, carries=[0])
        state = DigitState(digits=[], carries=[0], value=0)
        return 0, profile, state

    # Extract digits (little-endian)
    digits = []
    temp = n
    while temp > 0:
        digits.append(temp % 10)
        temp //= 10

    d = len(digits)
    rev_digits = list(reversed(digits))

    # Compute addition with carry tracking
    carries = [0] * (d + 2)
    result_digits = []

    for i in range(d):
        s = digits[i] + rev_digits[i] + carries[i]
        result_digits.append(s % 10)
        carries[i + 1] = s // 10

    # Handle final carry
    if carries[d] > 0:
        result_digits.append(carries[d])

    result = sum(digit * 10**i for i, digit in enumerate(result_digits))

    profile = CarryProfile(input_len=d, carries=carries[:d+1])
    state = DigitState(digits=result_digits, carries=carries[:d+1], value=result)

    return result, profile, state


# ============================================================================
# Algorithm 2: Symmetry Defect Computation
# ============================================================================

def symmetry_defect(digits: List[int]) -> int:
    """
    Compute the symmetry defect of a digit list.

    The symmetry defect is the sum of absolute differences between
    mirror-symmetric positions: Σ_{i < len/2} |L[i] - L[len-1-i]|.

    Correctness: Formally verified in Lean (symmetryDefect_eq_zero_iff_palindrome):
    symmetryDefect L = 0 ⟺ L = L.reverse

    Complexity: O(d) where d = len(digits)
    """
    length = len(digits)
    total = 0
    for i in range(length // 2):
        j = length - 1 - i
        total += abs(digits[i] - digits[j])
    return total


def symmetry_defect_vector(digits: List[int]) -> List[int]:
    """
    Compute the per-position symmetry defect vector.

    Returns |L[i] - L[len-1-i]| for each i < len/2.
    Useful for identifying which digit pairs contribute most to non-palindromicity.

    Complexity: O(d)
    """
    length = len(digits)
    return [abs(digits[i] - digits[length - 1 - i]) for i in range(length // 2)]


# ============================================================================
# Algorithm 3: Modular Signature Evolution
# ============================================================================

def mod9_evolution(n: int, steps: int) -> List[int]:
    """
    Compute the mod 9 trajectory of the reverse-and-add orbit.

    By the formally verified theorem revAdd_mod9:
        revAdd(n) % 9 = (2 * n) % 9

    Therefore T^k(n) % 9 = (2^k * n) % 9, which cycles with period
    dividing ord_9(2) = 6.

    This can be computed WITHOUT performing the actual reverse-and-add!

    Complexity: O(steps) — independent of digit length!
    """
    trajectory = []
    r = n % 9
    for _ in range(steps):
        trajectory.append(r)
        r = (2 * r) % 9
    return trajectory


def mod11_evolution(n: int, steps: int) -> List[int]:
    """
    Compute the mod 11 trajectory of the reverse-and-add orbit.

    Unlike mod 9, the mod 11 evolution is NOT simply (2*n) % 11 because
    rev(n) mod 11 depends on the alternating digit sum, not just the digit sum.

    Must be computed by actual iteration.

    Complexity: O(steps * d_max)
    """
    trajectory = []
    for _ in range(steps):
        trajectory.append(n % 11)
        n = n + int(str(n)[::-1])
    return trajectory


# ============================================================================
# Algorithm 4: Palindrome Obstruction Checker
# ============================================================================

@dataclass
class PalindromeObstruction:
    """
    A modular obstruction certificate.

    States that no palindrome can have residue `residue` modulo `modulus`.

    Formally corresponds to the PalindromeObstruction structure in Lean.
    """
    modulus: int
    residue: int
    explanation: str

    def check(self, n: int) -> bool:
        """Return True if n is obstructed (cannot be a palindrome) by this certificate."""
        return n % self.modulus == self.residue


def build_mod11_obstruction() -> List[PalindromeObstruction]:
    """
    Build palindrome obstruction certificates using the mod 11 theorem.

    By palindrome_mod11_of_even_length: if n is a palindrome with an even
    number of digits, then n ≡ 0 (mod 11).

    This means any number with an even number of digits and n % 11 ≠ 0
    cannot be an even-length palindrome.

    Returns a list of obstruction certificates.
    """
    obstructions = []
    for r in range(1, 11):
        obstructions.append(PalindromeObstruction(
            modulus=11,
            residue=r,
            explanation=f"Even-length palindromes must be ≡ 0 (mod 11), "
                        f"but this number is ≡ {r} (mod 11)"
        ))
    return obstructions


def check_palindrome_obstructions(n: int,
                                   obstructions: List[PalindromeObstruction]) -> Optional[PalindromeObstruction]:
    """
    Check if any obstruction certificate applies to n.

    Returns the first applicable obstruction, or None if no obstruction applies.

    Note: An obstruction only proves the number cannot be a palindrome of
    the specific type (e.g., even-length). It does not rule out odd-length palindromes.
    """
    for obs in obstructions:
        if obs.check(n):
            return obs
    return None


# ============================================================================
# Algorithm 5: Signature Automaton Simulation
# ============================================================================

def compute_signature(n: int) -> DigitSignature:
    """
    Compute the digit signature of n.

    Complexity: O(d) where d = number of digits
    """
    if n == 0:
        return DigitSignature(
            length=0, mod9=0, mod11=0,
            first_digit=0, last_digit=0,
            defect_parity=False
        )

    digits = []
    temp = n
    while temp > 0:
        digits.append(temp % 10)
        temp //= 10

    return DigitSignature(
        length=len(digits),
        mod9=n % 9,
        mod11=n % 11,
        first_digit=digits[-1],
        last_digit=digits[0],
        defect_parity=(symmetry_defect(digits) % 2 == 1)
    )


def simulate_signature_automaton(seed: int, steps: int) -> List[DigitSignature]:
    """
    Simulate the signature automaton for the reverse-and-add orbit.

    Tracks how the reduced signature evolves, looking for cycles or
    patterns in the finite-state projection.

    Complexity: O(steps * d_max)
    """
    trajectory = []
    n = seed

    for _ in range(steps):
        sig = compute_signature(n)
        trajectory.append(sig)
        n = n + int(str(n)[::-1])

    return trajectory


def find_signature_cycles(trajectory: List[DigitSignature]) -> Dict[DigitSignature, List[int]]:
    """
    Find repeated signatures in a trajectory.

    Returns a dict mapping each signature to the list of steps where it appears.
    Repeated signatures suggest (but don't prove) quasi-periodic behavior.
    """
    visits: Dict[DigitSignature, List[int]] = defaultdict(list)
    for step, sig in enumerate(trajectory):
        visits[sig].append(step)
    return {sig: steps for sig, steps in visits.items() if len(steps) > 1}


# ============================================================================
# Algorithm 6: Comprehensive Orbit Analysis
# ============================================================================

def full_orbit_analysis(seed: int, max_steps: int = 100) -> Dict:
    """
    Perform comprehensive analysis of a reverse-and-add orbit.

    Returns a dictionary with:
    - orbit: list of values
    - signatures: list of digit signatures
    - defects: list of symmetry defects
    - carry_profiles: list of carry profiles
    - mod9_trajectory: mod 9 values (computed algebraically)
    - mod11_trajectory: mod 11 values
    - palindrome_step: step at which palindrome is reached (or None)

    Complexity: O(max_steps * d_max)
    """
    orbit = []
    signatures = []
    defects = []
    carry_profiles = []
    palindrome_step = None

    n = seed
    for step in range(max_steps):
        # Record current state
        orbit.append(n)
        sig = compute_signature(n)
        signatures.append(sig)

        digits = []
        temp = n
        while temp > 0:
            digits.append(temp % 10)
            temp //= 10
        if not digits:
            digits = []

        defects.append(symmetry_defect(digits))

        # Check palindrome
        if digits == list(reversed(digits)):
            palindrome_step = step
            break

        # Compute next step with carries
        result, profile, state = carry_aware_rev_add(n)
        carry_profiles.append(profile)
        n = result

    return {
        'seed': seed,
        'orbit': orbit,
        'signatures': signatures,
        'defects': defects,
        'carry_profiles': carry_profiles,
        'mod9_trajectory': mod9_evolution(seed, len(orbit)),
        'palindrome_step': palindrome_step,
        'orbit_length': len(orbit),
    }


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Reverse-and-Add Dynamics: Algorithm Demonstrations")
    print("=" * 60)

    # Demo 1: Carry-aware computation
    print("\n--- Carry-Aware Reverse-and-Add ---")
    for n in [196, 887, 1675]:
        result, profile, state = carry_aware_rev_add(n)
        print(f"  {n} + rev({n}) = {result}")
        print(f"    Carries: {profile.carries}")
        print(f"    Overflow: {profile.has_overflow}")
        print(f"    Coherent: {state.coherent}")

    # Demo 2: Symmetry defect
    print("\n--- Symmetry Defect Analysis ---")
    for n in [121, 196, 12321, 12345]:
        digits = []
        temp = n
        while temp > 0:
            digits.append(temp % 10)
            temp //= 10
        defect = symmetry_defect(digits)
        vec = symmetry_defect_vector(digits)
        print(f"  n={n}, digits(LE)={digits}, defect={defect}, vector={vec}")

    # Demo 3: Mod 9 algebraic prediction
    print("\n--- Mod 9 Algebraic Prediction vs Actual ---")
    predicted = mod9_evolution(196, 10)
    n = 196
    for k in range(10):
        actual = n % 9
        print(f"  Step {k}: predicted={predicted[k]}, actual={actual}, match={'✓' if predicted[k] == actual else '✗'}")
        n = n + int(str(n)[::-1])

    # Demo 4: Palindrome obstructions
    print("\n--- Palindrome Obstruction Certificates ---")
    obstructions = build_mod11_obstruction()
    n = 196
    for k in range(5):
        obs = check_palindrome_obstructions(n, obstructions)
        digits = []
        temp = n
        while temp > 0:
            digits.append(temp % 10)
            temp //= 10
        even_len = len(digits) % 2 == 0
        if obs and even_len:
            print(f"  Step {k}: n={n}, even-len={even_len}, OBSTRUCTED ({obs.explanation})")
        else:
            print(f"  Step {k}: n={n}, even-len={even_len}, not obstructed by mod 11")
        n = n + int(str(n)[::-1])

    # Demo 5: Full analysis
    print("\n--- Full Orbit Analysis for 89 (reaches palindrome) ---")
    analysis = full_orbit_analysis(89, max_steps=50)
    if analysis['palindrome_step'] is not None:
        print(f"  Palindrome reached at step {analysis['palindrome_step']}")
        print(f"  Value: {analysis['orbit'][-1]}")
    print(f"  Defect evolution: {analysis['defects'][:10]}...")

    print("\n--- Full Orbit Analysis for 196 ---")
    analysis = full_orbit_analysis(196, max_steps=30)
    print(f"  Palindrome reached: {analysis['palindrome_step'] is not None}")
    print(f"  Defect evolution: {analysis['defects'][:15]}...")
    print(f"  All defects positive: {all(d > 0 for d in analysis['defects'][1:])}")
