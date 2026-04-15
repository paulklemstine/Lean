#!/usr/bin/env python3
"""
Factoring Energy Landscape & Phase Transition Demo
====================================================
Explores the energy function E(x) = N mod x, its statistical mechanics,
and the sharp phase transition in the partition function.
"""

from math import sqrt, exp, log
from collections import Counter

def factoring_energy(N, x):
    """The factoring energy: E(x) = N mod x."""
    return N % x

def divisors(N):
    """Find all divisors of N."""
    divs = []
    for d in range(1, int(sqrt(N)) + 1):
        if N % d == 0:
            divs.append(d)
            if d != N // d:
                divs.append(N // d)
    return sorted(divs)

def partition_function(N, beta):
    """Z(β) = Σ_{x=1}^{N} exp(-β·E(x))."""
    return sum(exp(-beta * factoring_energy(N, x)) for x in range(1, N+1))

def free_energy(N, beta):
    """F(β) = -log(Z(β))/β."""
    Z = partition_function(N, beta)
    if Z <= 0 or beta <= 0:
        return float('inf')
    return -log(Z) / beta

def density_of_states(N, max_E=None):
    """ρ(E) = number of x ∈ [1,N] with energy E."""
    if max_E is None:
        max_E = N
    counts = Counter()
    for x in range(1, N+1):
        E = factoring_energy(N, x)
        if E <= max_E:
            counts[E] += 1
    return counts

def demo_landscape_profile():
    """Show energy landscape for specific N."""
    print("=" * 70)
    print("FACTORING ENERGY LANDSCAPE")
    print("=" * 70)
    print()
    
    for N, desc in [(35, "5×7"), (77, "7×11"), (221, "13×17")]:
        divs = divisors(N)
        print(f"N = {N} = {desc}")
        print(f"Divisors (energy = 0): {divs}")
        print()
        
        # Show energy profile
        limit = min(N, 50)
        print(f"Energy landscape E(x) = N mod x, x = 1..{limit}:")
        for x in range(1, limit + 1):
            E = factoring_energy(N, x)
            bar = "█" * min(E, 40)
            factor_mark = " ← FACTOR" if E == 0 else ""
            print(f"  x={x:>3}: E={E:>4} |{bar}{factor_mark}")
        print()

def demo_phase_transition():
    """Demonstrate the sharp phase transition in the partition function."""
    print("=" * 70)
    print("PHASE TRANSITION ANALYSIS")
    print("=" * 70)
    print()
    
    N = 143  # 11 × 13
    print(f"N = {N} = 11 × 13")
    print()
    
    print(f"{'β':>8} {'Z(β)':>15} {'⟨E⟩':>10} {'Factor contribution':>20}")
    print("-" * 58)
    
    betas = [0.01, 0.05, 0.1, 0.2, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0]
    num_factors = len(divisors(N))
    
    for beta in betas:
        Z = partition_function(N, beta)
        # Expected energy
        avg_E = sum(factoring_energy(N, x) * exp(-beta * factoring_energy(N, x))
                    for x in range(1, N+1)) / Z
        # Factor contribution to Z
        factor_Z = num_factors  # Each factor contributes exp(0) = 1
        factor_frac = factor_Z / Z
        
        print(f"{beta:>8.2f} {Z:>15.2f} {avg_E:>10.2f} {factor_frac:>19.4f}")
    
    print()
    print("At high β (low temperature): factors dominate → factoring is 'easy'")
    print("At low β (high temperature): all x contribute → no useful signal")
    print(f"Critical β ≈ {2/log(N):.3f} (≈ 2/ln(N))")
    print()

def demo_density_of_states():
    """Analyze the density of states ρ(E)."""
    print("=" * 70)
    print("DENSITY OF STATES ρ(E)")
    print("=" * 70)
    print()
    
    N = 1001  # 7 × 11 × 13
    dos = density_of_states(N, max_E=50)
    
    print(f"N = {N} = 7 × 11 × 13")
    print(f"Number of divisors: {len(divisors(N))}")
    print()
    print(f"{'E':>5} {'ρ(E)':>6} Distribution")
    print("-" * 50)
    
    for E in range(0, 51):
        count = dos.get(E, 0)
        if count > 0:
            bar = "█" * min(count, 40)
            print(f"{E:>5} {count:>6} {bar}")
    
    print()
    print("ρ(0) counts the divisors — these are the 'ground state' configurations")
    print("Higher energy states are more numerous but carry less 'signal'")
    print()

def demo_gradient_analysis():
    """Analyze the energy gradient near factors."""
    print("=" * 70)
    print("ENERGY GRADIENT NEAR FACTORS")
    print("=" * 70)
    print()
    
    N = 323  # 17 × 19
    divs = divisors(N)
    
    print(f"N = {N} = 17 × 19")
    print(f"Divisors: {divs}")
    print()
    print("Energy gradient ΔE(x) = E(x+1) - E(x) near each factor:")
    print()
    
    for d in divs:
        if d == N:
            continue
        print(f"  Near factor d = {d}:")
        start = max(1, d - 3)
        end = min(N, d + 4)
        for x in range(start, end):
            E_x = factoring_energy(N, x)
            E_x1 = factoring_energy(N, x + 1) if x + 1 <= N else 0
            grad = E_x1 - E_x
            marker = " ← FACTOR" if E_x == 0 else ""
            print(f"    x={x:>4}: E={E_x:>4}, ΔE={grad:>+5}{marker}")
        print()

def demo_morse_theory():
    """Morse theory perspective: critical points of the energy landscape."""
    print("=" * 70)
    print("MORSE THEORY OF FACTORING (E9)")
    print("=" * 70)
    print()
    
    N = 143  # 11 × 13
    print(f"N = {N} = 11 × 13")
    print()
    
    # Find local minima (factors) and local maxima
    minima = []
    maxima = []
    saddles = []
    
    for x in range(2, N):
        E_prev = factoring_energy(N, x - 1)
        E_curr = factoring_energy(N, x)
        E_next = factoring_energy(N, x + 1)
        
        if E_curr <= E_prev and E_curr <= E_next:
            minima.append((x, E_curr))
        elif E_curr >= E_prev and E_curr >= E_next:
            maxima.append((x, E_curr))
    
    print(f"Local minima (global = factors at E=0):")
    for x, E in sorted(minima, key=lambda t: t[1])[:15]:
        print(f"  x={x:>4}, E={E:>4} {'← FACTOR' if E == 0 else ''}")
    
    print(f"\nTop 10 local maxima:")
    for x, E in sorted(maxima, key=lambda t: -t[1])[:10]:
        print(f"  x={x:>4}, E={E:>4}")
    
    print(f"\nTotal critical points: {len(minima)} minima, {len(maxima)} maxima")
    print(f"Morse inequality: #minima - #maxima + ... = χ (Euler characteristic)")
    print()

if __name__ == "__main__":
    demo_landscape_profile()
    demo_phase_transition()
    demo_density_of_states()
    demo_gradient_analysis()
    demo_morse_theory()
