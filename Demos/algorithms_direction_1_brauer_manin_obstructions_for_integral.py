#!/usr/bin/env python3
"""
algorithms.py — Certified obstruction checking algorithms for x³ + y³ + z³ = k.

Implements the finite obstruction checker and profile computation that
correspond to the formally verified Lean definitions.
"""

from typing import List, Set, Dict, Tuple, Optional
import time


def cube_residues(m: int) -> Set[int]:
    """
    Compute the set of cubic residues modulo m.

    Returns {x³ mod m : x ∈ {0, ..., m-1}}.

    Time complexity: O(m)
    Space complexity: O(m)
    """
    return {pow(x, 3, m) for x in range(m)}


def has_cubic_solution_mod(k: int, m: int) -> bool:
    """
    Check if x³ + y³ + z³ ≡ k (mod m) has a solution.

    Algorithm: Compute cube residues C, then check if any
    c1 + c2 + c3 ≡ k (mod m) with c1, c2, c3 ∈ C.

    Optimization: Compute C, then for each pair (c1, c2),
    check if (k - c1 - c2) mod m ∈ C.

    Time complexity: O(m + |C|²) where |C| ≤ m
    Space complexity: O(m)

    This corresponds to the Lean definition:
      def hasCubicSolutionMod (k : ℤ) (m : ℕ) : Bool
    """
    if m <= 0:
        return True
    target = k % m
    cubes = cube_residues(m)
    for c1 in cubes:
        for c2 in cubes:
            if (target - c1 - c2) % m in cubes:
                return True
    return False


def obstruction_profile_up_to(k: int, M: int) -> List[int]:
    """
    Compute the obstruction profile of k up to modulus M.

    Returns the sorted list of moduli m ∈ {1, ..., M} such that
    x³ + y³ + z³ ≡ k (mod m) has no solution.

    This corresponds to the Lean definition:
      def obstructionProfileUpTo (k : ℤ) (M : ℕ) : List ℕ

    The correctness theorem guarantees that every listed modulus
    is a genuine obstruction: no integer solution exists.

    Time complexity: O(M · m_max²) where m_max = M
    Space complexity: O(M)
    """
    return [m for m in range(1, M + 1) if not has_cubic_solution_mod(k, m)]


def prime_power_obstruction_analysis(k: int, p: int, max_e: int) -> Dict[int, bool]:
    """
    Analyze obstruction at prime power levels p^e for e = 1, ..., max_e.

    Returns {e: has_solution_mod_p^e} for each exponent.

    This implements the analysis behind Theorem 5:
    mod_nine_obstruction_controls_all_three_power_levels
    """
    results = {}
    for e in range(1, max_e + 1):
        m = p ** e
        results[e] = has_cubic_solution_mod(k, m)
    return results


def find_minimal_obstructions(k: int, M: int) -> List[int]:
    """
    Find minimal moduli in the obstruction profile.

    A modulus m is minimal if no proper divisor of m is also an obstruction.
    By the upward closure theorem (obstruction_upward_closed), any multiple
    of an obstruction is also an obstruction, so minimal elements generate
    the entire profile.

    Time complexity: O(M² · m_max)
    """
    profile = set(obstruction_profile_up_to(k, M))
    minimal = []
    for m in sorted(profile):
        # Check if any proper divisor is in the profile
        is_minimal = True
        for d in range(2, m):
            if m % d == 0 and d in profile:
                is_minimal = False
                break
        if is_minimal:
            minimal.append(m)
    return minimal


def bounded_three_cube_search(k: int, B: int) -> Optional[Tuple[int, int, int]]:
    """
    Search for x, y, z with |x|, |y|, |z| ≤ B and x³ + y³ + z³ = k.

    Uses the cube-root optimization: for each (x, y), compute z³ = k - x³ - y³
    and check if it's a perfect cube within bounds.

    Time complexity: O(B²)
    Space complexity: O(1)
    """
    for x in range(-B, B + 1):
        x3 = x ** 3
        for y in range(x, B + 1):  # y ≥ x by symmetry
            z3_needed = k - x3 - y ** 3
            if z3_needed == 0:
                z = 0
            else:
                sign = 1 if z3_needed > 0 else -1
                z_approx = round(abs(z3_needed) ** (1/3))
                z = None
                for candidate in [z_approx - 1, z_approx, z_approx + 1]:
                    if candidate >= 0 and (sign * candidate) ** 3 == z3_needed:
                        z = sign * candidate
                        break
                if z is None:
                    continue
            if abs(z) <= B:
                return (x, y, z)
    return None


def classify_residue_classes_mod9() -> Dict[str, List[int]]:
    """
    Classify residue classes mod 9 by their obstruction status.

    Returns a dictionary with keys:
    - 'obstructed': residues where no sum of three cubes is possible
    - 'admissible': residues where sums of three cubes exist
    """
    obstructed = []
    admissible = []
    for r in range(9):
        if has_cubic_solution_mod(r, 9):
            admissible.append(r)
        else:
            obstructed.append(r)
    return {'obstructed': obstructed, 'admissible': admissible}


def analyze_cube_residues_mod(m: int) -> Dict[str, object]:
    """
    Detailed analysis of cubic residues and sums modulo m.
    """
    cubes = cube_residues(m)
    sum_two_cubes = set()
    for c1 in cubes:
        for c2 in cubes:
            sum_two_cubes.add((c1 + c2) % m)
    sum_three_cubes = set()
    for s2 in sum_two_cubes:
        for c3 in cubes:
            sum_three_cubes.add((s2 + c3) % m)
    missing = set(range(m)) - sum_three_cubes
    return {
        'modulus': m,
        'cube_residues': sorted(cubes),
        'num_cube_residues': len(cubes),
        'sum_three_cubes_residues': sorted(sum_three_cubes),
        'missing_residues': sorted(missing),
        'coverage': len(sum_three_cubes) / m if m > 0 else 1.0
    }


if __name__ == "__main__":
    print("=== Cubic Obstruction Algorithms ===\n")

    # Demo: residue class analysis mod 9
    classes = classify_residue_classes_mod9()
    print(f"Mod 9 classification:")
    print(f"  Obstructed residues: {classes['obstructed']}")
    print(f"  Admissible residues: {classes['admissible']}")

    # Demo: cube residue analysis
    print(f"\nCube residue analysis mod 9:")
    analysis = analyze_cube_residues_mod(9)
    print(f"  Cube residues: {analysis['cube_residues']}")
    print(f"  Representable as sum of 3 cubes: {analysis['sum_three_cubes_residues']}")
    print(f"  Missing: {analysis['missing_residues']}")
    print(f"  Coverage: {analysis['coverage']:.1%}")

    # Demo: obstruction profiles
    print(f"\nObstruction profiles (up to M=100):")
    for k in [4, 5, 33, 42, 114]:
        profile = obstruction_profile_up_to(k, 100)
        minimal = find_minimal_obstructions(k, 100)
        print(f"  k={k}: profile={profile[:10]}{'...' if len(profile) > 10 else ''}")
        print(f"        minimal obstructions: {minimal}")

    # Demo: prime power analysis at p=3
    print(f"\nPrime power analysis at p=3:")
    for k in [4, 5, 33]:
        results = prime_power_obstruction_analysis(k, 3, 7)
        print(f"  k={k}: ", end="")
        for e, solvable in results.items():
            status = "✓" if solvable else "✗"
            print(f"3^{e}:{status} ", end="")
        print()

    # Demo: bounded search
    print(f"\nBounded search (B=100):")
    for k in [2, 29, 33, 42]:
        result = bounded_three_cube_search(k, 100)
        if result:
            x, y, z = result
            print(f"  k={k}: ({x})³ + ({y})³ + ({z})³ = {x**3+y**3+z**3}")
        else:
            print(f"  k={k}: no solution found within B=100")
