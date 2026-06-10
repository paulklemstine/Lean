#!/usr/bin/env python3
"""
Gap Automaton Demo: Interactive exploration of prime gap patterns
through the lens of modular sieve automata.

This script demonstrates the key phenomena:
1. The sieve automaton structure for small primorials
2. Forcing patterns where gaps are uniquely determined
3. Spectral analysis of the transition matrix
4. Scaling of the spectral gap with sieve depth
"""

from algorithms import (
    primorial, sieve_forbidden, admissible_states, step,
    admissible_successors, is_forcing, build_transition_matrix,
    spectral_gap, analyze_forcing_density, spectral_gap_scaling
)
import numpy as np


def demo_sieve6():
    """Demonstrate the {2,3}-sieve automaton with modulus 6."""
    print("=" * 60)
    print("DEMO 1: The Sieve-6 Automaton ({2,3}-sieve, modulus 6)")
    print("=" * 60)

    primes = [2, 3]
    m = primorial(primes)
    forbidden = sieve_forbidden(primes)
    admissible = admissible_states(primes)

    print(f"\nSieve primes: {primes}")
    print(f"Primorial (modulus): {m}")
    print(f"Forbidden residues: {sorted(forbidden)}")
    print(f"Admissible residues: {sorted(admissible)}")
    print(f"  (These correspond to numbers ≡ 1 or 5 mod 6)")

    print("\n--- Transition Table (even gaps 2,4,6) ---")
    alphabet = [2, 4, 6]
    print(f"{'State':>6} | ", end="")
    for g in alphabet:
        print(f"gap={g:>2} ", end="")
    print()
    print("-" * 40)

    for s in sorted(admissible):
        print(f"  {s:>3}  | ", end="")
        for g in alphabet:
            t = step(s, g, m)
            status = "✓" if t in admissible else "✗"
            print(f"  {t}{status}  ", end="")
        print()

    print("\n--- Forcing Analysis ---")
    for s in sorted(admissible):
        succs = admissible_successors(s, [2, 4], m, forbidden)
        forced = is_forcing(s, [2, 4], m, forbidden)
        if forced is not None:
            print(f"  State {s}: FORCED gap = {forced}")
            print(f"    (Only gap {forced} leads to admissible state {step(s, forced, m)})")
        else:
            print(f"  State {s}: {len(succs)} admissible successors: gaps {succs}")


def demo_transition_matrix():
    """Demonstrate the transition matrix and its spectral properties."""
    print("\n" + "=" * 60)
    print("DEMO 2: Transition Matrix & Spectral Analysis")
    print("=" * 60)

    primes = [2, 3]
    alphabet = [2, 4, 6]

    T, states = build_transition_matrix(primes, alphabet)
    print(f"\nSieve: {primes}, Alphabet: {alphabet}")
    print(f"Admissible states: {states}")
    print(f"\nTransition matrix T (restricted to admissible states):")
    print(T)

    eigenvalues = np.linalg.eigvals(T)
    print(f"\nEigenvalues: {eigenvalues}")
    print(f"Trace: {np.trace(T):.0f}")
    print(f"Determinant: {np.linalg.det(T):.0f}")
    print(f"Spectral gap (λ₁ - |λ₂|): {spectral_gap(T):.4f}")


def demo_forcing_density():
    """Demonstrate how forcing density varies with sieve depth."""
    print("\n" + "=" * 60)
    print("DEMO 3: Forcing Density Across Sieve Depths")
    print("=" * 60)

    sieve_sets = [
        [2, 3],
        [2, 3, 5],
        [2, 3, 5, 7],
    ]

    for primes in sieve_sets:
        m = primorial(primes)
        max_gap = min(2 * max(primes) + 2, 30)
        result = analyze_forcing_density(primes, max_gap)
        print(f"\nSieve {primes} (mod {m}):")
        print(f"  Admissible states: {result['num_admissible']}")
        print(f"  Alphabet size: {result['alphabet_size']} (gaps 2,4,...,{max_gap})")
        print(f"  Forcing states: {result['num_forcing']}")
        print(f"  Forcing density: {result['forcing_density']:.4f}")
        if result['forcing_states'][:5]:
            print(f"  First few forcing (state, forced_gap):")
            for s, g in result['forcing_states'][:5]:
                print(f"    state {s} → forced gap {g}")


def demo_spectral_scaling():
    """Demonstrate how the spectral gap scales with primorial size."""
    print("\n" + "=" * 60)
    print("DEMO 4: Spectral Gap Scaling")
    print("=" * 60)

    results = spectral_gap_scaling(4)

    print(f"\n{'Primes':>20} {'Primorial':>10} {'log(P)':>8} "
          f"{'#States':>8} {'Spec Gap':>10} {'Gap/log':>10}")
    print("-" * 75)

    for r in results:
        print(f"{str(r['primes']):>20} {r['primorial']:>10} "
              f"{r['log_primorial']:>8.3f} {r['num_admissible']:>8} "
              f"{r['spectral_gap']:>10.4f} {r['gap_over_log']:>10.4f}")

    print("\nConjecture: spectral gap ~ c / log(primorial) for some constant c > 0")
    if len(results) >= 2:
        ratios = [r['gap_over_log'] for r in results if r['gap_over_log'] < float('inf')]
        if ratios:
            print(f"Observed gap/log ratios: {[f'{r:.4f}' for r in ratios]}")


def demo_prime_gap_verification():
    """Verify the automaton against actual prime gaps."""
    print("\n" + "=" * 60)
    print("DEMO 5: Verification Against Actual Prime Gaps")
    print("=" * 60)

    # Generate primes up to 200 via sieve of Eratosthenes
    def sieve_eratosthenes(limit):
        is_prime = [True] * (limit + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(limit**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, limit + 1, i):
                    is_prime[j] = False
        return [i for i in range(2, limit + 1) if is_prime[i]]

    primes_list = sieve_eratosthenes(200)
    print(f"\nPrimes up to 200: {primes_list}")

    # Check gaps starting from primes > 5 against sieve-30 automaton
    sieve_primes = [2, 3, 5]
    m = primorial(sieve_primes)
    forbidden = sieve_forbidden(sieve_primes)

    print(f"\nSieve primes: {sieve_primes}, modulus: {m}")
    print(f"Verifying that consecutive primes > 5 have admissible transitions...")

    all_valid = True
    for i in range(3, len(primes_list) - 1):  # Start from 7
        p = primes_list[i]
        q = primes_list[i + 1]
        gap = q - p
        state = p % m
        next_state = q % m

        if state in forbidden:
            print(f"  ERROR: prime {p} has forbidden residue {state} mod {m}")
            all_valid = False
        if next_state in forbidden:
            print(f"  ERROR: prime {q} has forbidden residue {next_state} mod {m}")
            all_valid = False

        computed_next = step(state, gap, m)
        if computed_next != next_state:
            print(f"  ERROR: step({state}, {gap}) = {computed_next} ≠ {next_state}")
            all_valid = False

    if all_valid:
        print("  ✓ All transitions verified correctly!")
        print(f"  Every prime > 5 lands on an admissible residue mod {m},")
        print(f"  and every gap correctly transitions between admissible states.")


if __name__ == "__main__":
    demo_sieve6()
    demo_transition_matrix()
    demo_forcing_density()
    demo_spectral_scaling()
    demo_prime_gap_verification()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Gap Automaton State Diagram and Transition Structure

Produces a visualization of the sieve-6 automaton showing states,
transitions, and the forcing phenomenon.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from math import gcd
from functools import reduce


def primorial(primes):
    return reduce(lambda a, b: a * b, primes, 1)


def sieve_forbidden(primes):
    m = primorial(primes)
    return {r for r in range(m) if gcd(r, m) > 1}


def admissible_states(primes):
    m = primorial(primes)
    return set(range(m)) - sieve_forbidden(primes)


def step(state, gap, modulus):
    return (state + gap) % modulus


def build_transition_matrix(primes, alphabet):
    m = primorial(primes)
    forbidden = sieve_forbidden(primes)
    states = sorted(admissible_states(primes))
    n = len(states)
    state_idx = {s: i for i, s in enumerate(states)}
    T = np.zeros((n, n), dtype=float)
    for i, s in enumerate(states):
        for g in alphabet:
            t = step(s, g, m)
            if t in state_idx:
                T[i, state_idx[t]] += 1
    return T, states


def spectral_gap(T):
    eigenvalues = np.linalg.eigvals(T)
    mags = sorted(np.abs(eigenvalues), reverse=True)
    if len(mags) < 2:
        return 0.0
    return float(mags[0] - mags[1])


def plot_sieve6_automaton():
    """Plot the sieve-6 automaton as a state diagram."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left panel: Full state diagram mod 6
    ax = axes[0]
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title('Sieve-6 Automaton: All States mod 6', fontsize=14, fontweight='bold')

    primes = [2, 3]
    m = 6
    forbidden = sieve_forbidden(primes)
    admissible = admissible_states(primes)

    # Draw states in a circle
    angles = [np.pi/2 - 2*np.pi*i/6 for i in range(6)]
    positions = {i: (1.8*np.cos(angles[i]), 1.8*np.sin(angles[i])) for i in range(6)}

    for s in range(6):
        x, y = positions[s]
        color = '#2ecc71' if s in admissible else '#e74c3c'
        alpha = 1.0 if s in admissible else 0.4
        circle = plt.Circle((x, y), 0.3, color=color, alpha=alpha, ec='black', lw=2)
        ax.add_patch(circle)
        ax.text(x, y, str(s), ha='center', va='center', fontsize=16, fontweight='bold',
                color='white' if s not in admissible else 'black')

    # Draw transitions for gaps 2, 4 between admissible states
    gap_colors = {2: '#3498db', 4: '#e67e22', 6: '#9b59b6'}
    for g in [2, 4, 6]:
        for s in admissible:
            t = step(s, g, m)
            if t in admissible:
                sx, sy = positions[s]
                tx, ty = positions[t]
                if s == t:
                    # Self-loop
                    loop = patches.Arc((sx, sy + 0.4), 0.5, 0.5, angle=0,
                                       theta1=0, theta2=300, color=gap_colors[g], lw=2)
                    ax.add_patch(loop)
                else:
                    offset = 0.05 * (g - 4)
                    dx, dy = tx - sx, ty - sy
                    length = np.sqrt(dx**2 + dy**2)
                    nx, ny = -dy/length, dx/length
                    ax.annotate('', xy=(tx + nx*offset - dx*0.17/length,
                                        ty + ny*offset - dy*0.17/length),
                                xytext=(sx + nx*offset + dx*0.17/length,
                                        sy + ny*offset + dy*0.17/length),
                                arrowprops=dict(arrowstyle='->', color=gap_colors[g],
                                               lw=2, connectionstyle='arc3,rad=0.1'))

    # Legend
    for i, (g, c) in enumerate(gap_colors.items()):
        ax.plot([], [], color=c, lw=2, label=f'Gap {g}')
    ax.plot([], [], 'o', color='#2ecc71', markersize=10, label='Admissible')
    ax.plot([], [], 'o', color='#e74c3c', markersize=10, alpha=0.4, label='Forbidden')
    ax.legend(loc='lower left', fontsize=10)
    ax.axis('off')

    # Right panel: Spectral gap scaling
    ax2 = axes[1]
    all_primes_list = [2, 3, 5, 7, 11]
    gaps_data = []
    log_primorials = []

    for k in range(1, 5):
        ps = all_primes_list[:k]
        pm = primorial(ps)
        max_gap = min(2 * pm, 100)
        alphabet = list(range(2, max_gap + 1, 2))
        T, states = build_transition_matrix(ps, alphabet)
        sg = spectral_gap(T)
        gaps_data.append(sg)
        log_primorials.append(np.log(pm))

    ax2.plot(log_primorials, gaps_data, 'bo-', markersize=10, lw=2, label='Spectral gap')
    ax2.set_xlabel('log(Primorial)', fontsize=12)
    ax2.set_ylabel('Spectral Gap (λ₁ - |λ₂|)', fontsize=12)
    ax2.set_title('Spectral Gap vs Sieve Depth', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)

    # Fit a line
    if len(log_primorials) >= 2:
        coeffs = np.polyfit(log_primorials, gaps_data, 1)
        x_fit = np.linspace(min(log_primorials), max(log_primorials), 100)
        y_fit = np.polyval(coeffs, x_fit)
        ax2.plot(x_fit, y_fit, 'r--', lw=1.5, alpha=0.7,
                 label=f'Linear fit: slope={coeffs[0]:.2f}')

    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('gap_automaton_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: gap_automaton_visualization.png")


if __name__ == "__main__":
    plot_sieve6_automaton()
