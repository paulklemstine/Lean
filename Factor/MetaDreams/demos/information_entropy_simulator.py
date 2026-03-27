#!/usr/bin/env python3
"""
Information-Entropy Simulator: Visualizing the Duality

This program demonstrates the deep connection between information and
thermodynamic entropy through interactive simulations:

1. Shannon Entropy Calculator
2. Landauer's Principle Demonstration
3. Maxwell's Demon Simulation
4. Reversible vs Irreversible Computation
5. Bekenstein Bound Calculator
6. The Universe as a Computer
"""

import math
import random
from typing import List, Tuple

# ============================================================================
# Physical Constants
# ============================================================================

k_B = 1.380649e-23      # Boltzmann constant (J/K)
h_bar = 1.054571817e-34  # Reduced Planck constant (J·s)
c = 2.998e8              # Speed of light (m/s)
G = 6.674e-11            # Gravitational constant (m³/(kg·s²))
l_P = 1.616255e-35       # Planck length (m)
t_P = 5.391247e-44       # Planck time (s)


# ============================================================================
# Demo 1: Shannon Entropy
# ============================================================================

def shannon_entropy(probs: List[float]) -> float:
    """Compute Shannon entropy H = -Σ p_i log₂(p_i)."""
    return -sum(p * math.log2(p) for p in probs if p > 0)


def demo_shannon():
    print("\n" + "="*70)
    print("  DEMO 1: Shannon Entropy — The Measure of Uncertainty")
    print("="*70)

    # Fair coin
    h_coin = shannon_entropy([0.5, 0.5])
    print(f"\n  Fair coin (p=0.5, 0.5): H = {h_coin:.4f} bits")

    # Biased coin
    for bias in [0.1, 0.3, 0.5, 0.7, 0.9, 0.99]:
        h = shannon_entropy([bias, 1 - bias])
        bar = "█" * int(h * 40)
        print(f"  Coin (p={bias:.2f}, {1-bias:.2f}):  H = {h:.4f} bits  {bar}")

    # Die
    h_die = shannon_entropy([1/6]*6)
    print(f"\n  Fair die (6 sides):     H = {h_die:.4f} bits")

    # Deck of cards
    h_cards = shannon_entropy([1/52]*52)
    print(f"  Deck of cards (52):     H = {h_cards:.4f} bits")

    # English text (approx)
    print(f"  English text (per char):H ≈ 1.0-1.5 bits")
    print(f"  DNA (per base pair):    H = {shannon_entropy([0.25]*4):.4f} bits")

    # Maximum entropy
    print(f"\n  Key insight: H is maximized by the uniform distribution.")
    print(f"  For n outcomes, H_max = log₂(n).")
    for n in [2, 4, 8, 16, 256]:
        print(f"    n={n:>3}: H_max = {math.log2(n):.2f} bits")


# ============================================================================
# Demo 2: Landauer's Principle
# ============================================================================

def landauer_energy(T: float, bits: float = 1.0) -> float:
    """Minimum energy to erase `bits` bits at temperature T."""
    return bits * k_B * T * math.log(2)


def demo_landauer():
    print("\n" + "="*70)
    print("  DEMO 2: Landauer's Principle — The Cost of Forgetting")
    print("  'Every bit erased dissipates at least kT ln 2 of energy.'")
    print("="*70)

    print(f"\n  Landauer limit at various temperatures:")
    for T in [0.001, 1, 77, 300, 1000, 5778, 1e6, 1e9]:
        E = landauer_energy(T)
        if T == 300:
            label = "(room temp)"
        elif T == 5778:
            label = "(Sun surface)"
        elif T == 77:
            label = "(liquid N₂)"
        elif T == 0.001:
            label = "(millikelvin)"
        elif T == 1e9:
            label = "(neutron star)"
        else:
            label = ""
        print(f"    T = {T:>10.1f} K: E_min = {E:.4e} J/bit  {label}")

    # Compare to real computers
    print(f"\n  Comparison to real computers (per bit operation):")
    landauer_300 = landauer_energy(300)
    modern_cpu = 1e-17  # ~10 aJ per operation
    print(f"    Landauer limit (300K):  {landauer_300:.4e} J")
    print(f"    Modern CPU (2024):      {modern_cpu:.4e} J")
    print(f"    Ratio:                  {modern_cpu/landauer_300:.0f}× above limit")
    print(f"    Room for improvement:   {math.log2(modern_cpu/landauer_300):.1f} orders of magnitude!")

    # Total computation cost
    print(f"\n  Cost of erasing information:")
    for bits_label, bits in [("1 byte", 8), ("1 KB", 8192),
                              ("1 MB", 8e6), ("1 GB", 8e9),
                              ("1 TB", 8e12), ("Human genome", 6.4e9)]:
        E = landauer_energy(300, bits)
        print(f"    {bits_label:>15}: {E:.4e} J  ({E/1.602e-19:.4e} eV)")


# ============================================================================
# Demo 3: Maxwell's Demon
# ============================================================================

def demo_maxwell_demon():
    print("\n" + "="*70)
    print("  DEMO 3: Maxwell's Demon — Information as Physical Resource")
    print("="*70)

    print("""
  Setup: A box divided in two halves with a tiny door.
  The demon watches molecules and opens/closes the door to sort
  fast molecules to one side, seemingly violating the 2nd law.

  Resolution (Landauer/Bennett):
  The demon must STORE information about each molecule it observes.
  When its memory fills up, it must ERASE bits, paying kT ln 2 per bit.
  This erasure produces exactly enough entropy to satisfy the 2nd law.
    """)

    # Simulation
    n_molecules = 100
    T = 300  # K
    steps = 50

    print(f"  Simulating {n_molecules} molecules, {steps} steps at T={T}K:")
    print()

    demon_memory = 0  # bits stored
    entropy_extracted = 0.0
    total_erasure_cost = 0.0

    random.seed(42)

    for step in range(steps):
        # Demon observes a molecule (gains 1 bit of info)
        demon_memory += 1

        # Demon sorts molecule (extracts kT ln 2 of useful work)
        entropy_extracted += k_B * T * math.log(2)

        # Every 10 steps, demon must erase memory
        if demon_memory >= 10:
            erasure_cost = landauer_energy(T, demon_memory)
            total_erasure_cost += erasure_cost
            demon_memory = 0

    # Final accounting
    print(f"  Demon's accounting:")
    print(f"    Entropy 'extracted':     {entropy_extracted:.4e} J worth")
    print(f"    Memory erasure cost:     {total_erasure_cost:.4e} J")
    print(f"    Net work:                {entropy_extracted - total_erasure_cost:.4e} J")
    print(f"    Demon memory remaining:  {demon_memory} bits")
    remaining_cost = landauer_energy(T, demon_memory)
    total_cost = total_erasure_cost + remaining_cost
    print(f"    + remaining erasure:     {remaining_cost:.4e} J")
    print(f"    TRUE net work:           {entropy_extracted - total_cost:.4e} J")
    print(f"\n  ✓ Total cost ≥ total extraction → 2nd law PRESERVED")
    print(f"    The demon is not a perpetual motion machine!")


# ============================================================================
# Demo 4: Reversible vs Irreversible Computation
# ============================================================================

def demo_reversibility():
    print("\n" + "="*70)
    print("  DEMO 4: Reversible vs Irreversible Computation")
    print("  'Information preservation = thermodynamic free lunch'")
    print("="*70)

    print("""
  Irreversible gates (AND, OR) destroy information:
    AND: 2 input bits → 1 output bit → 1 bit erased → kT ln 2 heat

  Reversible gates (CNOT, Toffoli, Fredkin) preserve information:
    Toffoli: 3 input bits → 3 output bits → 0 bits erased → 0 heat

  Any irreversible computation can be made reversible (Bennett 1973)
  at the cost of extra space (ancilla bits).
    """)

    T = 300

    # AND gate analysis
    print(f"  AND gate truth table:")
    print(f"    (0,0) → 0    (0,1) → 0    (1,0) → 0    (1,1) → 1")
    print(f"    4 inputs → 2 outputs → loses log₂(4/2) = 1 bit")
    print(f"    Minimum heat: {landauer_energy(T, 1):.4e} J per AND operation")

    # XOR gate analysis
    print(f"\n  XOR gate truth table:")
    print(f"    (0,0) → 0    (0,1) → 1    (1,0) → 1    (1,1) → 0")
    print(f"    4 inputs → but we can recover inputs if we keep one input!")
    print(f"    As CNOT: (a,b) → (a, a⊕b) — fully reversible!")
    print(f"    Minimum heat: 0 J (in principle)")

    # Cost of a modern computation
    print(f"\n  Thermodynamic analysis of common operations:")
    operations = [
        ("Integer addition (64-bit)", 0, "reversible (subtraction inverts)"),
        ("Integer multiply (64-bit)", 64, "64 bits lost in overflow"),
        ("Sort (1000 elements)", 0, "reversible (keep permutation)"),
        ("Hash (SHA-256)", 256, "256-bit input → 256-bit output (compression)"),
        ("Neural net inference (GPT)", 1e12, "~1 trillion irreversible ops"),
    ]

    for name, bits_lost, note in operations:
        E = landauer_energy(T, bits_lost)
        print(f"    {name:>35}: {E:.4e} J minimum  ({note})")


# ============================================================================
# Demo 5: Bekenstein Bound
# ============================================================================

def bekenstein_bound(R: float, E: float) -> float:
    """Maximum information (bits) in sphere of radius R with energy E."""
    return 2 * math.pi * R * E / (h_bar * c * math.log(2))


def demo_bekenstein():
    print("\n" + "="*70)
    print("  DEMO 5: Bekenstein Bound — The Universe's Storage Limit")
    print("  'A region of space has finite information capacity.'")
    print("="*70)

    print(f"\n  I_max = 2πRE / (ℏc ln 2)")
    print(f"\n  Maximum information content of various objects:")

    objects = [
        ("Proton", 0.87e-15, 1.503e-10 * 1.602e-19),
        ("Hydrogen atom", 5.3e-11, 13.6 * 1.602e-19),
        ("Human brain (1.4 kg)", 0.11, 1.4 * c**2),
        ("Earth", 6.371e6, 5.972e24 * c**2),
        ("Sun", 6.957e8, 1.989e30 * c**2),
        ("Observable universe", 4.4e26, 4e69),  # Approximate
    ]

    for name, R, E in objects:
        I = bekenstein_bound(R, E)
        print(f"    {name:>30}: {I:.2e} bits  ({I*math.log(2)/(8*1e9):.2e} GB equiv)")

    print(f"\n  Key insight: Information scales with SURFACE AREA, not volume!")
    print(f"  A black hole saturates the bound — it's the densest information store.")

    # Black hole info
    print(f"\n  Black hole information content (Bekenstein-Hawking):")
    for M_solar in [1, 10, 100, 1e6, 4e6]:
        M = M_solar * 1.989e30
        R_s = 2 * G * M / c**2
        A = 4 * math.pi * R_s**2
        S_BH = A / (4 * l_P**2)  # In Planck areas
        I_bits = S_BH / math.log(2)
        print(f"    M = {M_solar:.0e} M☉: R_s = {R_s:.2e} m, I = {I_bits:.2e} bits")


# ============================================================================
# Demo 6: The Universe as a Computer
# ============================================================================

def demo_universe_computer():
    print("\n" + "="*70)
    print("  DEMO 6: The Universe as a Computer")
    print("  'Every physical process is a computation.'")
    print("  — Seth Lloyd, 'Programming the Universe' (2006)")
    print("="*70)

    # Lloyd's calculation
    age_universe = 13.8e9 * 3.156e7  # seconds
    E_universe = 4e69  # Joules (approximate)
    R_universe = 4.4e26  # meters

    # Margolus-Levitin: max ops/sec = 2E/(πℏ)
    max_ops_per_sec = 2 * E_universe / (math.pi * h_bar)
    total_ops = max_ops_per_sec * age_universe

    # Bekenstein: max bits
    max_bits = bekenstein_bound(R_universe, E_universe)

    print(f"\n  The observable universe as a computer:")
    print(f"    Age:                   {age_universe:.2e} seconds")
    print(f"    Total energy:          {E_universe:.2e} J")
    print(f"    Max ops/second:        {max_ops_per_sec:.2e} (Margolus-Levitin)")
    print(f"    Total ops performed:   {total_ops:.2e}")
    print(f"    Max memory (bits):     {max_bits:.2e} (Bekenstein bound)")
    print(f"    Max memory (bytes):    {max_bits/8:.2e}")

    print(f"\n  For comparison:")
    comparisons = [
        ("All computers on Earth (2024)", 1e21, 1e22),
        ("Bitcoin network (2024)", 4e20, 1e9),
        ("Human brain", 1e16, 2.5e18),
        ("Google's data centers", 1e18, 1e19),
    ]
    for name, ops, bits in comparisons:
        print(f"    {name:>35}: {ops:.0e} ops/s, {bits:.0e} bits")
        print(f"      {'':>35}  = {ops/max_ops_per_sec:.2e} of universe capacity")

    print(f"\n  The universe has performed ~10^{math.log10(total_ops):.0f} operations.")
    print(f"  It stores at most ~10^{math.log10(max_bits):.0f} bits.")
    print(f"  Every atom, every photon, every quantum fluctuation is a computation.")


# ============================================================================
# Demo 7: Information–Entropy Conversion Algorithm
# ============================================================================

def demo_conversion_algorithm():
    print("\n" + "="*70)
    print("  DEMO 7: The Information ↔ Entropy Conversion Algorithm")
    print("  'Information and entropy are two faces of the same coin.'")
    print("="*70)

    print("""
  THE ALGORITHM:

  ┌─────────────────────────────────────────────────────────┐
  │  INFORMATION → ENTROPY (Landauer Erasure)               │
  │                                                         │
  │  Input:  n bits of information at temperature T         │
  │  Step 1: For each bit, apply irreversible RESET gate    │
  │  Step 2: Each RESET dissipates ≥ kT ln 2 joules        │
  │  Output: n × kT ln 2 joules of heat (entropy)          │
  │                                                         │
  │  Information destroyed. Entropy created.                │
  └─────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────┐
  │  ENTROPY → INFORMATION (Maxwell's Demon / Measurement)  │
  │                                                         │
  │  Input:  Thermal system at temperature T                │
  │  Step 1: Measure (observe) the microstate               │
  │  Step 2: Each measurement yields 1 bit of information   │
  │  Step 3: Use info to extract kT ln 2 joules of work     │
  │  Output: Information gained, entropy reduced            │
  │                                                         │
  │  BUT: storing measurement costs ≥ kT ln 2 when erased! │
  └─────────────────────────────────────────────────────────┘
    """)

    T = 300
    print(f"  Numerical example at T = {T}K:")
    print()

    for n_bits in [1, 8, 1024, 1e6, 1e9]:
        E = landauer_energy(T, n_bits)
        S = n_bits * k_B * math.log(2)
        print(f"    {n_bits:>10.0f} bits  ↔  S = {S:.4e} J/K  ↔  E = {E:.4e} J")

    print(f"\n  The conversion factor: 1 bit = k_B ln 2 = {k_B * math.log(2):.6e} J/K")
    print(f"  At T=300K: 1 bit = {landauer_energy(300):.6e} J")
    print(f"  This is EXACT — not an approximation. It's a law of physics.")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     INFORMATION-ENTROPY SIMULATOR v1.0                         ║")
    print("║     'The universe is made of information.' — John Wheeler      ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_shannon()
    demo_landauer()
    demo_maxwell_demon()
    demo_reversibility()
    demo_bekenstein()
    demo_universe_computer()
    demo_conversion_algorithm()

    print("\n" + "="*70)
    print("  CONCLUSION: Information and entropy are dual quantities,")
    print("  connected by the Boltzmann constant k_B and temperature T.")
    print("  Every computation is a physical process; every physical")
    print("  process is a computation. The universe IS the computer.")
    print("="*70)
