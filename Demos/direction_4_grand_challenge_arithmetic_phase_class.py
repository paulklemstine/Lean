#!/usr/bin/env python3
"""
Arithmetic Phase Classification — Applications

Real-world and physics-inspired applications of prime torsion phase classification.
"""

from algorithms import (
    compute_torsion_profile,
    classify_phase,
    detect_transitions,
    persistent_prime_support,
    is_profile_complete,
    minimal_complete_bound,
    sieve_primes,
    prime_factors,
)
from typing import List, Dict, Set


# ─────────────────────────────────────────────────────────────────────────
# Application 1: Topological Quantum Code Classification
# ─────────────────────────────────────────────────────────────────────────

def classify_quantum_codes():
    """
    Classify topological quantum error-correcting codes by their
    arithmetic torsion signature.

    The toric code has Z/2Z homology (2-primary torsion).
    Color codes and other cyclic gauge models have different signatures.
    """
    print("=" * 65)
    print("  APPLICATION 1: Topological Quantum Code Classification")
    print("=" * 65)

    codes = {
        "Toric code (Z₂ gauge)": [2],
        "Z₃ gauge code": [3],
        "Z₅ gauge code": [5],
        "Z₂ × Z₃ code (composite)": [2, 3],
        "Z₂ × Z₂ code (doubled)": [2, 2],
        "Z₄ code (higher 2-primary)": [4],
        "Z₈ code (deep 2-primary)": [8],
        "Z₆ code (mixed gauge)": [6],
        "Z₃₀ code (rich structure)": [30],
    }

    P = 31  # Scan primes up to 31
    print(f"\n  Scanning primes up to P = {P}\n")
    print(f"  {'Code':35s} {'Classification':25s} {'Profile'}")
    print(f"  {'─' * 80}")

    for name, moduli in codes.items():
        classification = classify_phase(moduli, P)
        profile = sorted(compute_torsion_profile(moduli, P))
        complete = is_profile_complete(moduli, P)
        marker = "✓" if complete else "⚠"
        print(f"  {name:35s} {classification:25s} {profile} {marker}")

    print(f"\n  ✓ = profile complete at P={P}; ⚠ = may need larger P")

    # Demonstrate separation
    print("\n  Key separation results:")
    toric = compute_torsion_profile([2], P)
    z3 = compute_torsion_profile([3], P)
    z6 = compute_torsion_profile([6], P)
    print(f"  • Toric code ≠ Z₃ gauge: {toric != z3} (profiles differ)")
    print(f"  • Z₆ = Z₂ ∪ Z₃: {z6 == toric | z3} (product accumulation)")


# ─────────────────────────────────────────────────────────────────────────
# Application 2: Synthetic Material Phase Diagram
# ─────────────────────────────────────────────────────────────────────────

def material_phase_diagram():
    """
    Simulate a material phase diagram where different regions of
    parameter space have different gauge symmetry breaking patterns.
    """
    print("\n" + "=" * 65)
    print("  APPLICATION 2: Synthetic Material Phase Diagram")
    print("=" * 65)

    # Simulate a 2D phase diagram parameterized by temperature T
    # and pressure p (not to be confused with prime p)
    phases = {
        "High T, Low P (disordered)": [],         # trivial
        "Low T, Low P (Z₂ ordered)": [2],         # toric
        "Low T, Med P (Z₂×Z₃ ordered)": [2, 3],  # mixed
        "Low T, High P (Z₆ ordered)": [6],        # same as above
        "Med T, Med P (Z₃ ordered)": [3],         # pure Z₃
    }

    P = 10
    print(f"\n  Phase diagram (prime bound P = {P}):\n")
    print(f"  {'Region':35s} {'Profile':15s} {'Phase type'}")
    print(f"  {'─' * 65}")

    for region, moduli in phases.items():
        profile = sorted(compute_torsion_profile(moduli, P))
        ptype = classify_phase(moduli, P)
        print(f"  {region:35s} {str(profile):15s} {ptype}")

    # Show which transitions are detectable
    print("\n  Detectable phase transitions:")
    regions = list(phases.items())
    for i in range(len(regions)):
        for j in range(i + 1, len(regions)):
            p1 = compute_torsion_profile(regions[i][1], P)
            p2 = compute_torsion_profile(regions[j][1], P)
            if p1 != p2:
                print(f"  • {regions[i][0]} ↔ {regions[j][0]}: SEPARATED")


# ─────────────────────────────────────────────────────────────────────────
# Application 3: Energy Filtration Analysis
# ─────────────────────────────────────────────────────────────────────────

def energy_filtration_analysis():
    """
    Analyze a synthetic energy filtration where different energy scales
    reveal different topological orders.
    """
    print("\n" + "=" * 65)
    print("  APPLICATION 3: Energy Filtration Analysis")
    print("=" * 65)

    # Energy levels (in arbitrary units) and their gauge content
    filtration = {
        0: [],              # vacuum
        1: [2],             # 2-torsion appears (e.g., vortex pairs)
        2: [2],             # 2-torsion persists
        3: [2, 3],          # 3-torsion birth (new defect type)
        4: [2, 3, 5],       # 5-torsion birth (exotic excitation)
        5: [2, 3, 5],       # stable
        6: [2, 3],          # 5-torsion death (high-energy mode decouples)
        7: [2],             # 3-torsion death
        8: [],              # return to trivial (thermal destruction)
    }

    P = 10
    print(f"\n  Energy filtration with {len(filtration)} levels, P = {P}\n")

    # Detect transitions
    transitions = detect_transitions(filtration, P)
    print(f"  Detected {len(transitions)} arithmetic phase transitions:\n")
    for level, births, deaths in transitions:
        events = []
        if births:
            events.append(f"  BIRTH of {sorted(births)}-torsion")
        if deaths:
            events.append(f"  DEATH of {sorted(deaths)}-torsion")
        print(f"  Level {level}: {'; '.join(events)}")

    # Persistent support analysis
    print("\n  Persistent prime support (primes stable across level ranges):")
    for (i, j) in [(0, 8), (1, 7), (2, 6), (3, 5)]:
        ps = persistent_prime_support(filtration, i, j, P)
        print(f"  Levels [{i}, {j}]: {sorted(ps) if ps else '∅'}")

    # Barcode visualization (ASCII)
    print("\n  Torsion barcode (ASCII):")
    primes_seen = set()
    for moduli in filtration.values():
        primes_seen |= compute_torsion_profile(moduli, P)
    for p in sorted(primes_seen):
        bar = ""
        for level in sorted(filtration.keys()):
            profile = compute_torsion_profile(filtration[level], P)
            bar += "█" if p in profile else "·"
        print(f"  p={p}: [{bar}]  (levels 0-{max(filtration.keys())})")


# ─────────────────────────────────────────────────────────────────────────
# Application 4: Completeness Certification
# ─────────────────────────────────────────────────────────────────────────

def completeness_analysis():
    """
    Demonstrate the completeness theorem: for bounded systems,
    a finite prime scan captures all torsion information.
    """
    print("\n" + "=" * 65)
    print("  APPLICATION 4: Completeness Certification")
    print("=" * 65)

    models = [
        ("Small gauge", [6]),
        ("Medium gauge", [30]),
        ("Large gauge", [2310]),     # 2*3*5*7*11
        ("Prime power", [128]),      # 2^7
        ("Composite", [12, 35, 11]), # 2²×3, 5×7, 11
    ]

    print(f"\n  {'Model':25s} {'Moduli':20s} {'Min P':8s} {'All primes'}")
    print(f"  {'─' * 70}")

    for name, moduli in models:
        min_P = minimal_complete_bound(moduli)
        all_primes = set()
        for n in moduli:
            all_primes |= prime_factors(n)
        print(f"  {name:25s} {str(moduli):20s} {min_P:8d} {sorted(all_primes)}")

    # Demonstrate that increasing P beyond the minimum doesn't change the profile
    print("\n  Stability test: profile of Z/30Z at increasing P values:")
    moduli = [30]
    for P in [2, 3, 5, 7, 10, 20, 50]:
        profile = sorted(compute_torsion_profile(moduli, P))
        complete = is_profile_complete(moduli, P)
        print(f"    P = {P:3d}: profile = {str(profile):15s} complete = {complete}")


# ─────────────────────────────────────────────────────────────────────────

def main():
    print("╔═════════════════════════════════════════════════════════════╗")
    print("║  Arithmetic Phase Classification — Applications           ║")
    print("║  Prime torsion as a material phase observable              ║")
    print("╚═════════════════════════════════════════════════════════════╝")

    classify_quantum_codes()
    material_phase_diagram()
    energy_filtration_analysis()
    completeness_analysis()

    print("\n" + "=" * 65)
    print("  All applications demonstrated successfully.")
    print("=" * 65)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Arithmetic Phase Classification — Interactive Demo

Demonstrates the arithmetic torsion classifier on finite cyclic gauge models:
  1. ZMod 2 (toric-code-inspired toy model)
  2. ZMod 3 (Z/3Z gauge toy model)
  3. ZMod 6 (mixed model)
  4. Filtered synthetic defect model with changing prime support
"""

from math import gcd
from typing import List, Set, Dict


def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def has_p_torsion(n: int, p: int) -> bool:
    """
    Check if ZMod(n) has p-torsion.
    ZMod(n) has p-torsion iff p is prime and p divides n.
    """
    return is_prime(p) and n > 0 and n % p == 0


def torsion_profile(moduli: List[int], P: int) -> Set[int]:
    """
    Compute the torsion profile up to prime bound P for a product
    of cyclic groups specified by moduli [n1, n2, ...].

    A prime p <= P is in the profile iff p divides some ni.
    """
    primes = set()
    for p in range(2, P + 1):
        if is_prime(p):
            if any(n % p == 0 for n in moduli if n > 0):
                primes.add(p)
    return primes


def print_profile(name: str, moduli: List[int], P: int):
    """Pretty-print the torsion profile of a model."""
    profile = torsion_profile(moduli, P)
    print(f"\n{'='*60}")
    print(f"  Model: {name}")
    print(f"  Moduli: {moduli}")
    print(f"  Prime bound P = {P}")
    print(f"  Torsion profile: {sorted(profile) if profile else '∅ (empty)'}")
    print(f"{'='*60}")

    if profile:
        for p in sorted(profile):
            witnesses = [n for n in moduli if n > 0 and n % p == 0]
            print(f"  • p = {p}: detected via factors {witnesses}")
    else:
        print("  • No torsion detected — this is an arithmetic trivial phase.")

    # Show which primes are NOT detected
    non_detected = [p for p in range(2, P + 1) if is_prime(p) and p not in profile]
    if non_detected:
        print(f"  • Invisible primes (wrong characteristic): {non_detected}")


def demo_phase_separation():
    """Demonstrate that different models have different torsion profiles."""
    print("\n" + "=" * 60)
    print("  PHASE SEPARATION DEMO")
    print("=" * 60)

    models = {
        "Toric code (Z/2Z)": [2],
        "Z/3Z gauge": [3],
        "Mixed Z/6Z": [6],
        "Z/30Z (rich)": [30],
        "Free (Z)": [],
        "Z/4Z (2-primary)": [4],
        "Z/2Z × Z/3Z": [2, 3],
        "Z/2Z × Z/2Z": [2, 2],
    }

    P = 10
    profiles = {}

    for name, moduli in models.items():
        profile = torsion_profile(moduli, P)
        profiles[name] = profile
        print(f"\n  {name:25s} → profile = {sorted(profile) if profile else '∅'}")

    # Check pairwise separations
    print("\n  Pairwise separation matrix (✓ = separated, ✗ = same profile):")
    names = list(models.keys())
    print(f"  {'':25s}", end="")
    for i, n in enumerate(names):
        print(f" {i}", end="")
    print()
    for i, n1 in enumerate(names):
        print(f"  {n1:25s}", end="")
        for j, n2 in enumerate(names):
            if profiles[n1] != profiles[n2]:
                print(" ✓", end="")
            else:
                print(" =", end="")
        print()


def demo_filtered_system():
    """Demonstrate a filtered system where prime support changes with level."""
    print("\n" + "=" * 60)
    print("  FILTERED SYSTEM DEMO — Phase Transition Detection")
    print("=" * 60)

    # Model: a defect lattice where higher energy levels reveal more torsion
    # Level 0: free (no defects) → trivial phase
    # Level 1: Z/2Z appears (2-torsion birth)
    # Level 2: Z/2Z × Z/3Z (3-torsion birth)
    # Level 3: Z/2Z × Z/3Z × Z/5Z (5-torsion birth)
    # Level 4: Z/2Z × Z/3Z (5-torsion death)
    # Level 5: Z/2Z (3-torsion death)

    filtration = {
        0: [],
        1: [2],
        2: [2, 3],
        3: [2, 3, 5],
        4: [2, 3],
        5: [2],
    }

    P = 10
    print(f"\n  Prime bound P = {P}")
    print(f"\n  Level  Moduli                    Profile        Events")
    print(f"  {'─'*65}")

    prev_profile = set()
    for level in sorted(filtration.keys()):
        moduli = filtration[level]
        profile = torsion_profile(moduli, P)

        # Detect births and deaths
        births = profile - prev_profile
        deaths = prev_profile - profile

        events = []
        if births:
            events.append(f"birth({sorted(births)})")
        if deaths:
            events.append(f"death({sorted(deaths)})")
        event_str = ", ".join(events) if events else "—"

        moduli_str = " × ".join(f"Z/{n}Z" for n in moduli) if moduli else "Free(Z)"
        profile_str = str(sorted(profile)) if profile else "∅"

        print(f"  {level:5d}  {moduli_str:25s} {profile_str:15s} {event_str}")

        prev_profile = profile

    # Persistent prime support
    print(f"\n  Persistent prime support (primes present at ALL levels 1-5):")
    all_profiles = [torsion_profile(filtration[i], P) for i in range(1, 6)]
    persistent = set.intersection(*all_profiles) if all_profiles else set()
    print(f"  → {sorted(persistent) if persistent else '∅'}")

    print(f"\n  Persistent prime support (levels 2-4):")
    profiles_24 = [torsion_profile(filtration[i], P) for i in range(2, 5)]
    persistent_24 = set.intersection(*profiles_24)
    print(f"  → {sorted(persistent_24)}")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Arithmetic Phase Classification — Interactive Demo     ║")
    print("║  Prime torsion as a topological phase observable         ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Demo 1: Individual models
    print("\n▶ DEMO 1: Individual Model Profiles")
    print_profile("Toric Code Prototype (Z/2Z)", [2], 10)
    print_profile("Z/3Z Gauge Model", [3], 10)
    print_profile("Mixed Model (Z/6Z ≅ Z/2Z × Z/3Z)", [6], 10)
    print_profile("Free Module (trivial phase)", [], 10)

    # Demo 2: Phase separation
    print("\n▶ DEMO 2: Phase Separation via Arithmetic Profiles")
    demo_phase_separation()

    # Demo 3: Filtered system
    print("\n▶ DEMO 3: Filtered System with Phase Transitions")
    demo_filtered_system()

    # Demo 4: Prime power models
    print("\n▶ DEMO 4: Prime Power Models (Z/p^k Z)")
    for p in [2, 3, 5]:
        for k in [1, 2, 3]:
            print_profile(f"Z/{p**k}Z (p={p}, k={k})", [p**k], 10)


if __name__ == "__main__":
    main()
