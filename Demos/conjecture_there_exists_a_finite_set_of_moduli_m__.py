#!/usr/bin/env python3
"""
Beal Obstruction Theory — Applications

Demonstrates real-world applications of the residue obstruction
and ABC threshold frameworks.
"""

from math import gcd
from algorithms import (
    enumerate_primitive_residue_solutions,
    has_primitive_residue_solution,
    find_single_modulus_obstruction,
    abc_exponent_threshold,
    euler_totient,
    generate_obstruction_certificate,
)


# ─────────────────────────────────────────────────────────────────────
# Application 1: Systematic Beal Signature Classification
# ─────────────────────────────────────────────────────────────────────

def classify_beal_signatures(max_exp: int = 10, max_mod: int = 50):
    """
    Classify Beal exponent signatures by their modular obstruction status.

    For each signature (x, y, z) with 3 ≤ x ≤ y ≤ z ≤ max_exp,
    search for a single-modulus obstruction up to max_mod.

    This creates a "phase diagram" of which signatures are
    provably impossible via modular methods alone.
    """
    print("Application 1: Beal Signature Classification")
    print("=" * 60)
    print(f"Searching signatures (x,y,z) with 3 ≤ x ≤ y ≤ z ≤ {max_exp}")
    print(f"Moduli range: 2 to {max_mod}")
    print()

    obstructed = []
    surviving = []

    for x in range(3, max_exp + 1):
        for y in range(x, max_exp + 1):
            for z in range(y, max_exp + 1):
                obs = find_single_modulus_obstruction(x, y, z, max_N=max_mod)
                if obs:
                    obstructed.append((x, y, z, obs))
                else:
                    surviving.append((x, y, z))

    print(f"Obstructed signatures ({len(obstructed)}):")
    for x, y, z, N in obstructed:
        print(f"  ({x},{y},{z}) — obstructed by N = {N}")

    print(f"\nSurviving signatures ({len(surviving)}):")
    for x, y, z in surviving:
        print(f"  ({x},{y},{z}) — no single-modulus obstruction ≤ {max_mod}")

    return obstructed, surviving


# ─────────────────────────────────────────────────────────────────────
# Application 2: Power Residue Spectrum Analysis
# ─────────────────────────────────────────────────────────────────────

def power_residue_spectrum(max_exp: int = 8, modulus: int = 7):
    """
    Analyze the power residue spectrum modulo a prime.

    For each exponent x, compute the image of the x-th power map
    on (ℤ/pℤ)*. This determines which residues can appear as
    x-th powers and constrains Beal solutions.
    """
    print("\n\nApplication 2: Power Residue Spectrum")
    print("=" * 60)
    print(f"Modulus: {modulus}")
    print()

    units = [a for a in range(1, modulus) if gcd(a, modulus) == 1]

    for x in range(2, max_exp + 1):
        image = sorted(set(pow(a, x, modulus) for a in units))
        print(f"  x={x}: {x}-th power residues = {image} "
              f"({len(image)}/{len(units)} units)")

    print()
    print("When the power residue image is small, the Beal congruence")
    print("a^x + b^y ≡ c^z (mod p) is highly constrained.")


# ─────────────────────────────────────────────────────────────────────
# Application 3: ABC Phase Diagram
# ─────────────────────────────────────────────────────────────────────

def abc_phase_diagram():
    """
    Display the ABC phase diagram: for each K, show which
    exponent signatures are forbidden.
    """
    print("\n\nApplication 3: ABC Phase Diagram")
    print("=" * 60)
    print()
    print("The ABC Threshold Theorem creates a 'phase diagram':")
    print("given IntAbcBound(K), exponent triples (x,y,z) with all")
    print("components ≥ 3K+1 lie in the 'forbidden phase'.")
    print()

    for K in range(1, 6):
        threshold = abc_exponent_threshold(K)
        # Count how many Beal signatures (x,y,z) with x,y,z ≥ 3 are forbidden
        total_sigs = 0
        forbidden_sigs = 0
        for x in range(3, 20):
            for y in range(x, 20):
                for z in range(y, 20):
                    total_sigs += 1
                    if x >= threshold and y >= threshold and z >= threshold:
                        forbidden_sigs += 1

        print(f"  K={K}: threshold={threshold}, "
              f"forbidden signatures (3≤x≤y≤z<20): "
              f"{forbidden_sigs}/{total_sigs} "
              f"({100*forbidden_sigs/total_sigs:.1f}%)")


# ─────────────────────────────────────────────────────────────────────
# Application 4: Certificate Database
# ─────────────────────────────────────────────────────────────────────

def build_certificate_database():
    """
    Build a database of obstruction certificates for Beal signatures.
    Each certificate is a machine-checkable proof that a specific
    modulus obstructs a specific exponent signature.
    """
    print("\n\nApplication 4: Obstruction Certificate Database")
    print("=" * 60)
    print()

    certificates = []
    for x in range(3, 8):
        for y in range(x, 8):
            for z in range(y, 8):
                for N in range(2, 30):
                    if not has_primitive_residue_solution(N, x, y, z):
                        cert = generate_obstruction_certificate(N, x, y, z)
                        certificates.append(cert)
                        print(f"  ✓ ({x},{y},{z}) mod {N}: OBSTRUCTION CERTIFIED")
                        break  # One certificate per signature suffices

    print(f"\nTotal certificates generated: {len(certificates)}")
    return certificates


# ─────────────────────────────────────────────────────────────────────
# Application 5: Density Heatmap Data
# ─────────────────────────────────────────────────────────────────────

def solution_density_heatmap():
    """
    Compute primitive residue solution densities for a heatmap.
    Density = |solutions| / φ(N)³ for various N and signatures.
    """
    print("\n\nApplication 5: Solution Density Data")
    print("=" * 60)
    print()

    signatures = [(3,3,3), (3,3,5), (3,5,5), (5,5,5)]
    moduli = [p for p in range(2, 40) if all(p % i != 0 for i in range(2, p))]  # primes

    print(f"{'N':>4}", end="")
    for sig in signatures:
        print(f"  {str(sig):>12}", end="")
    print()
    print("-" * (4 + 14 * len(signatures)))

    for N in moduli:
        phi_cubed = euler_totient(N) ** 3
        print(f"{N:>4}", end="")
        for x, y, z in signatures:
            count = len(enumerate_primitive_residue_solutions(N, x, y, z))
            density = count / phi_cubed if phi_cubed > 0 else 0
            print(f"  {density:>12.4f}", end="")
        print()


if __name__ == "__main__":
    classify_beal_signatures(max_exp=7, max_mod=30)
    power_residue_spectrum(modulus=7)
    abc_phase_diagram()
    build_certificate_database()
    solution_density_heatmap()


#!/usr/bin/env python3
"""
Beal Obstruction Theory — Demonstration Script

Demonstrates the two main theoretical tools:
1. Residue-class covering obstruction: checking whether a modulus N
   eliminates all primitive residue solutions for exponent signature (x,y,z).
2. ABC threshold calculus: computing the exponent threshold 3K+1 above which
   IntAbcBound(K) eliminates primitive Beal solutions.
"""

from math import gcd
from itertools import product


def primitive_residue_solutions(N: int, x: int, y: int, z: int) -> list[tuple[int, int, int]]:
    """
    Enumerate all primitive residue solutions modulo N for signature (x, y, z).

    A primitive residue solution is a triple (a, b, c) with 0 ≤ a, b, c < N,
    each coprime to N, satisfying a^x + b^y ≡ c^z (mod N).

    Parameters
    ----------
    N : int
        The modulus (must be > 0).
    x, y, z : int
        The exponent signature.

    Returns
    -------
    list of (int, int, int)
        All primitive residue solutions modulo N.
    """
    solutions = []
    for a in range(N):
        if gcd(a, N) != 1:
            continue
        ax = pow(a, x, N)
        for b in range(N):
            if gcd(b, N) != 1:
                continue
            by_ = pow(b, y, N)
            lhs = (ax + by_) % N
            for c in range(N):
                if gcd(c, N) != 1:
                    continue
                cz = pow(c, z, N)
                if lhs == cz:
                    solutions.append((a, b, c))
    return solutions


def residue_solutions(N: int, x: int, y: int, z: int) -> list[tuple[int, int, int]]:
    """
    Enumerate all residue solutions (without coprimality) modulo N.

    Returns all triples (a, b, c) with 0 ≤ a, b, c < N
    satisfying a^x + b^y ≡ c^z (mod N).
    """
    solutions = []
    for a in range(N):
        ax = pow(a, x, N)
        for b in range(N):
            by_ = pow(b, y, N)
            lhs = (ax + by_) % N
            for c in range(N):
                cz = pow(c, z, N)
                if lhs == cz:
                    solutions.append((a, b, c))
    return solutions


def abc_threshold(K: int) -> int:
    """
    Compute the exponent threshold n such that IntAbcBound(K) implies
    no primitive Beal solution with all exponents ≥ n.

    By the ABC Threshold Theorem: n = 3K + 1 suffices.

    Parameters
    ----------
    K : int
        The ABC exponent strength.

    Returns
    -------
    int
        The minimal exponent threshold 3K + 1.
    """
    return 3 * K + 1


def demo_residue_obstruction():
    """Demonstrate the residue obstruction framework."""
    print("=" * 70)
    print("DEMO 1: Residue-Class Covering Obstruction")
    print("=" * 70)
    print()

    # Check various signatures against small moduli
    signatures = [(3, 3, 3), (3, 3, 5), (3, 5, 7), (4, 4, 4), (5, 5, 5)]
    moduli = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16]

    for x, y, z in signatures:
        print(f"\nSignature ({x}, {y}, {z}):")
        print("-" * 40)
        for N in moduli:
            sols = primitive_residue_solutions(N, x, y, z)
            status = f"{len(sols):>5} solutions" if sols else "  *** EMPTY — OBSTRUCTION ***"
            print(f"  mod {N:>3}: {status}")

    # Look for complete obstructions
    print("\n\nSearching for single-modulus obstructions (N ≤ 50)...")
    for x, y, z in signatures:
        obstructions = []
        for N in range(2, 51):
            if not primitive_residue_solutions(N, x, y, z):
                obstructions.append(N)
        if obstructions:
            print(f"  ({x},{y},{z}): Obstruction at N = {obstructions}")
        else:
            print(f"  ({x},{y},{z}): No single-modulus obstruction found for N ≤ 50")


def demo_abc_threshold():
    """Demonstrate the ABC threshold calculus."""
    print("\n\n" + "=" * 70)
    print("DEMO 2: ABC Threshold Calculus")
    print("=" * 70)
    print()
    print("The ABC Threshold Theorem states:")
    print("  If IntAbcBound(K) holds and 3K < n,")
    print("  then no primitive Beal solution exists with all exponents ≥ n.")
    print()
    print("Threshold table:")
    print(f"  {'K':>4}  {'Threshold n = 3K+1':>20}  {'Forbidden region':>30}")
    print("  " + "-" * 60)
    for K in range(1, 11):
        n = abc_threshold(K)
        print(f"  {K:>4}  {n:>20}  {'All exponents ≥ ' + str(n):>30}")

    print()
    print("Concrete corollaries (proved in the formalization):")
    print("  • IntAbcBound(1) ⟹ no primitive solution with x,y,z ≥ 4")
    print("  • IntAbcBound(2) ⟹ no primitive solution with x,y,z ≥ 7")
    print("  • IntAbcBound(3) ⟹ no primitive solution with x,y,z ≥ 10")
    print()
    print("Note: The existing theorem abc_int_implies_no_primitive_beal_K2")
    print("uses K=2 with threshold x,y,z > 6 (i.e., ≥ 7), which matches")
    print("our general formula 3×2+1 = 7 exactly!")


def demo_residue_density():
    """Analyze how residue solution density varies with modulus."""
    print("\n\n" + "=" * 70)
    print("DEMO 3: Residue Solution Density Analysis")
    print("=" * 70)
    print()

    x, y, z = 3, 3, 3
    print(f"Signature: ({x}, {y}, {z})")
    print(f"{'N':>5}  {'Total solutions':>15}  {'Primitive solutions':>20}  {'Density (prim/N³)':>18}")
    print("-" * 65)
    for N in range(2, 26):
        total = len(residue_solutions(N, x, y, z))
        prim = len(primitive_residue_solutions(N, x, y, z))
        density = prim / N**3 if N > 0 else 0
        print(f"{N:>5}  {total:>15}  {prim:>20}  {density:>18.4f}")


if __name__ == "__main__":
    demo_residue_obstruction()
    demo_abc_threshold()
    demo_residue_density()
