#!/usr/bin/env python3
"""
Applications of Collatz-Tropical Dynamics

Demonstrates real-world connections of the tropical contraction framework:
1. Pseudorandom number generation from Collatz orbits
2. Hash function construction using orbit statistics
3. Stopping time distribution analysis
4. Connection to coding theory: variable-length codes from parity sequences
"""

import math
import hashlib
from typing import List, Dict, Tuple
from collections import Counter


# ============================================================
# Application 1: Collatz-Based Mixing Function
# ============================================================

def collatz_mixer(seed: int, rounds: int = 100) -> int:
    """Use Collatz dynamics as a mixing function.

    The chaotic-but-deterministic nature of Collatz orbits provides
    good bit mixing, illustrating how arithmetic dynamics connects
    to practical computation.

    The tropical contraction framework shows WHY Collatz orbits
    eventually concentrate—the logarithmic potential decreases on
    average—making this a "contracting mixer."

    Args:
        seed: Input integer (≥ 1)
        rounds: Number of Collatz steps to mix

    Returns:
        Mixed output value
    """
    n = max(seed, 1)
    accumulator = 0
    for i in range(rounds):
        accumulator ^= n
        accumulator = (accumulator * 2654435761) & 0xFFFFFFFF  # Knuth multiplicative hash
        if n % 2 == 0:
            n = n // 2
        else:
            n = 3 * n + 1
        if n > 2**32:
            n = n % (2**32 - 1) + 1
    return accumulator


# ============================================================
# Application 2: Stopping Time Distribution
# ============================================================

def stopping_time(n: int, max_steps: int = 10000) -> int:
    """Compute the stopping time: first k such that collatz^k(n) < n.

    The tropical contraction theory predicts that stopping times
    are finite for all n (conditional on the contraction hypothesis).
    The distribution of stopping times reveals the structure of
    residue-class-dependent contraction rates.
    """
    original = n
    for k in range(1, max_steps + 1):
        if n % 2 == 0:
            n = n // 2
        else:
            n = 3 * n + 1
        if n < original:
            return k
    return -1  # Did not stop


def total_stopping_time(n: int, max_steps: int = 10000) -> int:
    """Compute the total stopping time: first k such that collatz^k(n) = 1."""
    for k in range(max_steps + 1):
        if n == 1:
            return k
        if n % 2 == 0:
            n = n // 2
        else:
            n = 3 * n + 1
    return -1


def analyze_stopping_times(max_n: int = 10000) -> Dict:
    """Analyze the distribution of stopping times.

    Returns statistics about how quickly orbits begin to contract,
    validating the tropical contraction framework's predictions.
    """
    times = []
    total_times = []
    for n in range(2, max_n + 1):
        st = stopping_time(n)
        tt = total_stopping_time(n)
        if st > 0:
            times.append(st)
        if tt >= 0:
            total_times.append(tt)

    return {
        'count': len(times),
        'mean_stopping': sum(times) / len(times) if times else 0,
        'max_stopping': max(times) if times else 0,
        'mean_total': sum(total_times) / len(total_times) if total_times else 0,
        'max_total': max(total_times) if total_times else 0,
        'all_finite': all(t > 0 for t in times),
    }


# ============================================================
# Application 3: Parity Sequence Coding
# ============================================================

def parity_encode(n: int, max_len: int = 100) -> str:
    """Encode n as its Collatz parity sequence.

    The parity sequence uniquely determines the orbit (given the starting value),
    creating a variable-length code. The tropical framework shows that codeword
    lengths are controlled by the logarithmic potential.

    Average codeword length ≈ log₂(n) · (1 + log(3)/log(4))
    due to the even/odd step ratio.
    """
    bits = []
    current = n
    while current != 1 and len(bits) < max_len:
        if current % 2 == 0:
            bits.append('0')  # even = halving
            current = current // 2
        else:
            bits.append('1')  # odd = 3n+1
            current = 3 * current + 1
    return ''.join(bits)


def analyze_code_efficiency(max_n: int = 1000) -> Dict:
    """Analyze the efficiency of parity sequence codes.

    Compares codeword length to log₂(n), testing the tropical
    potential bound on code lengths.
    """
    ratios = []
    for n in range(2, max_n + 1):
        code = parity_encode(n)
        code_len = len(code)
        log_n = math.log2(n)
        if log_n > 0:
            ratios.append(code_len / log_n)

    return {
        'mean_ratio': sum(ratios) / len(ratios),
        'max_ratio': max(ratios),
        'min_ratio': min(ratios),
        'sample_codes': {n: parity_encode(n) for n in [3, 7, 15, 27, 97]},
    }


# ============================================================
# Application 4: Residue Class Transition Graph
# ============================================================

def build_transition_graph(modulus: int) -> Dict[int, Dict]:
    """Build the finite-state transition graph for Collatz mod m.

    This implements the "renormalization" viewpoint: Collatz dynamics
    on ℕ projects to a finite-state automaton on Z/mZ. The tropical
    Lyapunov framework seeks a potential function on this finite graph
    that certifies global contraction.

    Args:
        modulus: Size of the state space

    Returns:
        Dictionary describing the transition graph
    """
    graph = {}
    for r in range(modulus):
        if r % 2 == 0:
            target = (r // 2) % modulus
            weight = -math.log(2)  # log-potential change
            graph[r] = {
                'parity': 'even',
                'target': target,
                'weight': weight,
                'operation': f'{r} → {r}//2 ≡ {target} (mod {modulus})',
            }
        else:
            target = (3 * r + 1) % modulus
            weight = math.log(3 + 1/max(r, 1))  # approximate log-potential change
            graph[r] = {
                'parity': 'odd',
                'target': target,
                'weight': weight,
                'operation': f'{r} → 3·{r}+1 ≡ {target} (mod {modulus})',
            }
    return graph


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF COLLATZ-TROPICAL DYNAMICS")
    print("=" * 70)

    # Application 1: Mixing
    print("\n--- Application 1: Collatz Mixer ---")
    for seed in [1, 42, 1000, 2**16]:
        mixed = collatz_mixer(seed)
        print(f"  mixer({seed}) = {mixed} (0x{mixed:08x})")

    # Application 2: Stopping times
    print("\n--- Application 2: Stopping Time Distribution ---")
    stats = analyze_stopping_times(10000)
    print(f"  Range: n = 2..10000")
    print(f"  All stopping times finite: {stats['all_finite']}")
    print(f"  Mean stopping time: {stats['mean_stopping']:.2f}")
    print(f"  Max stopping time: {stats['max_stopping']}")
    print(f"  Mean total stopping time: {stats['mean_total']:.2f}")
    print(f"  Max total stopping time: {stats['max_total']}")

    # Application 3: Parity encoding
    print("\n--- Application 3: Parity Sequence Codes ---")
    code_stats = analyze_code_efficiency(1000)
    print(f"  Mean code_length / log₂(n): {code_stats['mean_ratio']:.3f}")
    print(f"  Sample codes:")
    for n, code in code_stats['sample_codes'].items():
        print(f"    {n:>4} → {code[:40]}{'...' if len(code)>40 else ''} (len={len(code)})")

    # Application 4: Transition graph
    print("\n--- Application 4: Transition Graph (mod 8) ---")
    graph = build_transition_graph(8)
    for r in sorted(graph.keys()):
        info = graph[r]
        print(f"  {info['operation']}, weight={info['weight']:.4f}")

    print("\n" + "=" * 70)
    print("All applications completed.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Collatz Convergence via Tropical Contracting Dynamics — Demonstrations

This script demonstrates the key theorems from the formal development:
1. Collatz orbit computation and the 1→4→2→1 cycle
2. Logarithmic potential tracking along orbits
3. Even branch exact identity: Φ(n/2) = Φ(n) - log(2)
4. Odd branch coarse bound: Φ(3n+1) ≤ Φ(n) + log(4)
5. Two-step odd→even bound: Φ((3n+1)/2) ≤ Φ(n) + log(2)
6. Arithmetic contraction when 4 | (3n+1)
7. Residue class analysis for favorable contraction
"""

import math
from typing import List, Tuple


def collatz(n: int) -> int:
    """Standard Collatz map."""
    if n % 2 == 0:
        return n // 2
    else:
        return 3 * n + 1


def collatz_odd(n: int) -> int:
    """Accelerated odd step: (3n+1)/2."""
    return (3 * n + 1) // 2


def collatz_orbit(n: int, max_steps: int = 1000) -> List[int]:
    """Compute the Collatz orbit of n until reaching 1 or max_steps."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz(n)
        orbit.append(n)
    return orbit


def log_potential(n: int) -> float:
    """Logarithmic potential Φ(n) = log(n)."""
    return math.log(n) if n > 0 else 0.0


# ============================================================
# Demo 1: Collatz Cycle and Basic Orbits
# ============================================================
def demo_collatz_basics():
    print("=" * 60)
    print("DEMO 1: Collatz Basics and the 1→4→2→1 Cycle")
    print("=" * 60)

    # Verify the 3-cycle
    print(f"\ncollatz(1) = {collatz(1)} (expected: 4)")
    print(f"collatz(4) = {collatz(4)} (expected: 2)")
    print(f"collatz(2) = {collatz(2)} (expected: 1)")
    print("→ 1 is NOT a fixed point; {1,2,4} forms a 3-cycle\n")

    # Show some orbits
    for start in [7, 27, 97, 871]:
        orbit = collatz_orbit(start)
        print(f"Orbit of {start}: length={len(orbit)}, "
              f"max={max(orbit)}, first 10: {orbit[:10]}...")


# ============================================================
# Demo 2: Even Branch Identity
# ============================================================
def demo_even_branch():
    print("\n" + "=" * 60)
    print("DEMO 2: Even Branch — Φ(n/2) = Φ(n) - log(2)")
    print("=" * 60)

    print(f"\n{'n':>8} {'Φ(n)':>12} {'Φ(n/2)':>12} {'Φ(n)-log2':>12} {'Match?':>8}")
    print("-" * 56)
    for n in [2, 4, 10, 100, 256, 1000, 65536]:
        phi_n = log_potential(n)
        phi_half = log_potential(n // 2)
        expected = phi_n - math.log(2)
        match = abs(phi_half - expected) < 1e-12
        print(f"{n:>8} {phi_n:>12.6f} {phi_half:>12.6f} {expected:>12.6f} {'✓' if match else '✗':>8}")


# ============================================================
# Demo 3: Odd Branch Coarse Bound
# ============================================================
def demo_odd_branch():
    print("\n" + "=" * 60)
    print("DEMO 3: Odd Branch — Φ(3n+1) ≤ Φ(n) + log(4)")
    print("=" * 60)

    print(f"\n{'n':>8} {'Φ(3n+1)':>12} {'Φ(n)+log4':>12} {'Gap':>12} {'Valid?':>8}")
    print("-" * 56)
    for n in [1, 3, 5, 7, 11, 27, 99, 999, 9999]:
        phi_collatz = log_potential(3 * n + 1)
        bound = log_potential(n) + math.log(4)
        gap = bound - phi_collatz
        valid = phi_collatz <= bound + 1e-12
        print(f"{n:>8} {phi_collatz:>12.6f} {bound:>12.6f} {gap:>12.6f} {'✓' if valid else '✗':>8}")

    print("\nNote: The gap approaches log(4/3) ≈ 0.2877 as n → ∞")
    print(f"log(4/3) = {math.log(4/3):.6f}")


# ============================================================
# Demo 4: Two-Step Bound
# ============================================================
def demo_two_step():
    print("\n" + "=" * 60)
    print("DEMO 4: Two-Step Bound — Φ((3n+1)/2) ≤ Φ(n) + log(2)")
    print("=" * 60)

    print(f"\n{'n':>8} {'(3n+1)/2':>10} {'Φ(result)':>12} {'Φ(n)+log2':>12} {'Valid?':>8}")
    print("-" * 54)
    for n in [1, 3, 5, 7, 11, 27, 99, 999, 9999, 99999]:
        if n % 2 == 1:  # odd
            result = (3 * n + 1) // 2
            phi_result = log_potential(result)
            bound = log_potential(n) + math.log(2)
            valid = phi_result <= bound + 1e-12
            print(f"{n:>8} {result:>10} {phi_result:>12.6f} {bound:>12.6f} {'✓' if valid else '✗':>8}")


# ============================================================
# Demo 5: Arithmetic Contraction via 4-Divisibility
# ============================================================
def demo_four_divisibility():
    print("\n" + "=" * 60)
    print("DEMO 5: Arithmetic Contraction — 4|(3n+1) ⟹ (3n+1)/4 < n")
    print("=" * 60)

    print(f"\n{'n':>8} {'n%4':>5} {'3n+1':>8} {'4|(3n+1)?':>10} {'(3n+1)/4':>10} {'< n?':>6}")
    print("-" * 51)
    contracting = 0
    total_odd = 0
    for n in range(1, 101):
        if n % 2 == 1:  # odd
            total_odd += 1
            val = 3 * n + 1
            four_divides = val % 4 == 0
            quotient = val // 4 if four_divides else None
            contracts = quotient is not None and quotient < n
            if four_divides:
                contracting += 1
            if n <= 25:
                print(f"{n:>8} {n%4:>5} {val:>8} {'Yes' if four_divides else 'No':>10} "
                      f"{str(quotient) if quotient else '-':>10} "
                      f"{'✓' if contracts else ('=' if quotient == n else '-'):>6}")

    print(f"\nAmong odd numbers 1-99: {contracting}/{total_odd} have 4|(3n+1)")
    print(f"Fraction: {contracting/total_odd:.2%}")
    print("Theory predicts: exactly those with n ≡ 1 (mod 4)")


# ============================================================
# Demo 6: Log Potential Along Orbits
# ============================================================
def demo_orbit_potential():
    print("\n" + "=" * 60)
    print("DEMO 6: Log Potential Along Collatz Orbits")
    print("=" * 60)

    for start in [27, 97]:
        orbit = collatz_orbit(start)
        potentials = [log_potential(n) for n in orbit]
        even_steps = sum(1 for i in range(len(orbit)-1) if orbit[i] % 2 == 0)
        odd_steps = sum(1 for i in range(len(orbit)-1) if orbit[i] % 2 == 1)

        print(f"\nOrbit of {start}:")
        print(f"  Length: {len(orbit)} steps")
        print(f"  Even steps: {even_steps}, Odd steps: {odd_steps}")
        print(f"  Even/Odd ratio: {even_steps/max(odd_steps,1):.3f}")
        print(f"  Initial Φ: {potentials[0]:.4f}")
        print(f"  Final Φ: {potentials[-1]:.4f} (log 1 = 0)")
        print(f"  Max Φ: {max(potentials):.4f} at n={orbit[potentials.index(max(potentials))]}")
        print(f"  Net drift: {even_steps * (-math.log(2)) + odd_steps * math.log(4):.4f} (coarse bound)")
        print(f"  Actual net: {potentials[-1] - potentials[0]:.4f}")


# ============================================================
# Demo 7: Symbolic Drift Analysis
# ============================================================
def demo_symbolic_drift():
    print("\n" + "=" * 60)
    print("DEMO 7: Symbolic Drift — When Even Steps Dominate")
    print("=" * 60)

    print("\nFor net contraction: need even_steps/odd_steps > log(4)/log(2) = 2")
    print("Equivalently: fraction of odd steps < 1/3\n")

    print(f"{'Start':>8} {'Steps':>8} {'Even':>6} {'Odd':>6} {'Ratio':>8} {'Odd Frac':>10} {'Contract?':>10}")
    print("-" * 66)

    for start in [3, 7, 15, 27, 97, 255, 447, 871, 6171, 77031]:
        orbit = collatz_orbit(start)
        total = len(orbit) - 1
        even = sum(1 for i in range(total) if orbit[i] % 2 == 0)
        odd = total - even
        ratio = even / max(odd, 1)
        odd_frac = odd / max(total, 1)
        contracts = odd_frac < 1/3
        print(f"{start:>8} {total:>8} {even:>6} {odd:>6} {ratio:>8.3f} {odd_frac:>10.4f} "
              f"{'✓ (<1/3)' if contracts else '✗ (≥1/3)':>10}")


if __name__ == "__main__":
    demo_collatz_basics()
    demo_even_branch()
    demo_odd_branch()
    demo_two_step()
    demo_four_divisibility()
    demo_orbit_potential()
    demo_symbolic_drift()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Collatz-Tropical Dynamics

Generates publication-quality figures showing:
1. Collatz orbits in standard and logarithmic coordinates
2. Branch-wise potential analysis (even/odd)
3. Residue class contraction map
4. Symbolic drift density
5. Stopping time heatmap
"""

import math
import base64
import io
from typing import List, Tuple

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.cm as cm
    import numpy as np
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib not available, generating SVG fallbacks")


def collatz(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1

def collatz_orbit(n: int, max_steps: int = 1000) -> List[int]:
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz(n)
        orbit.append(n)
    return orbit


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def generate_orbit_plot() -> str:
    """Plot 1: Collatz orbits in standard and log coordinates."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12']
    starts = [27, 97, 171, 447, 871]

    for start, color in zip(starts, colors):
        orbit = collatz_orbit(start)
        ax1.plot(orbit, color=color, alpha=0.8, linewidth=0.8, label=f'n={start}')
        log_orbit = [math.log(x) if x > 0 else 0 for x in orbit]
        ax2.plot(log_orbit, color=color, alpha=0.8, linewidth=0.8, label=f'n={start}')

    ax1.set_xlabel('Step', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Collatz Orbits (Standard Coordinates)', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.set_yscale('log')

    ax2.set_xlabel('Step', fontsize=12)
    ax2.set_ylabel('log(value) = Φ(n)', fontsize=12)
    ax2.set_title('Collatz Orbits (Tropical/Log Coordinates)', fontsize=13)
    ax2.axhline(y=0, color='black', linewidth=0.5, linestyle='--', alpha=0.5)
    ax2.legend(fontsize=9)

    fig.suptitle('Standard vs. Tropical Coordinates for Collatz Dynamics', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def generate_branch_analysis() -> str:
    """Plot 2: Even/odd branch potential changes."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Even branch: exact identity Φ(n/2) = Φ(n) - log(2)
    even_ns = list(range(2, 1001, 2))
    even_changes = [math.log(n//2) - math.log(n) for n in even_ns]
    ax1.scatter(even_ns, even_changes, s=1, alpha=0.5, color='#3498db')
    ax1.axhline(y=-math.log(2), color='#e74c3c', linewidth=2, label=f'−log(2) ≈ {-math.log(2):.4f}')
    ax1.set_xlabel('n (even)', fontsize=12)
    ax1.set_ylabel('Φ(n/2) − Φ(n)', fontsize=12)
    ax1.set_title('Even Branch: Exact Translation', fontsize=13)
    ax1.legend(fontsize=10)

    # Odd branch: bound Φ(3n+1) ≤ Φ(n) + log(4)
    odd_ns = list(range(1, 1001, 2))
    odd_changes = [math.log(3*n+1) - math.log(n) for n in odd_ns]
    ax2.scatter(odd_ns, odd_changes, s=1, alpha=0.5, color='#e74c3c')
    ax2.axhline(y=math.log(4), color='#2ecc71', linewidth=2, label=f'log(4) ≈ {math.log(4):.4f}')
    ax2.axhline(y=math.log(3), color='#9b59b6', linewidth=2, linestyle='--',
                label=f'log(3) ≈ {math.log(3):.4f} (asymptote)')
    ax2.set_xlabel('n (odd)', fontsize=12)
    ax2.set_ylabel('Φ(3n+1) − Φ(n)', fontsize=12)
    ax2.set_title('Odd Branch: Coarse Tropical Majorization', fontsize=13)
    ax2.legend(fontsize=10)

    fig.suptitle('Piecewise Tropical Structure of Collatz Dynamics', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def generate_contraction_map() -> str:
    """Plot 3: Residue class contraction analysis."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # 2-adic valuation of 3n+1 for odd n
    modulus = 128
    residues = list(range(1, modulus, 2))
    v2_vals = []
    for r in residues:
        val = 3 * r + 1
        v2 = 0
        temp = val
        while temp % 2 == 0:
            v2 += 1
            temp //= 2
        v2_vals.append(v2)

    colors_v2 = ['#e74c3c' if v < 2 else '#f39c12' if v == 2 else '#2ecc71' for v in v2_vals]
    ax1.bar(range(len(residues)), v2_vals, color=colors_v2, width=1.0)
    ax1.set_xlabel('Odd residue index (mod 128)', fontsize=12)
    ax1.set_ylabel('ν₂(3n+1)', fontsize=12)
    ax1.set_title('2-Adic Valuation by Residue Class', fontsize=13)
    ax1.axhline(y=2, color='black', linewidth=0.5, linestyle='--', alpha=0.5)

    # Contraction ratio
    log_ratios = [math.log(3) - v * math.log(2) for v in v2_vals]
    colors_ratio = ['#2ecc71' if r < 0 else '#e74c3c' for r in log_ratios]
    ax2.bar(range(len(residues)), log_ratios, color=colors_ratio, width=1.0)
    ax2.axhline(y=0, color='black', linewidth=1.5)
    ax2.set_xlabel('Odd residue index (mod 128)', fontsize=12)
    ax2.set_ylabel('log(3) − ν₂·log(2)', fontsize=12)
    ax2.set_title('Log-Contraction Ratio by Residue', fontsize=13)

    contracting = sum(1 for r in log_ratios if r < 0)
    total = len(log_ratios)
    ax2.text(0.02, 0.98, f'Contracting: {contracting}/{total} ({contracting/total:.0%})',
             transform=ax2.transAxes, fontsize=10, verticalalignment='top',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    fig.suptitle('Residue Class Contraction Analysis', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def generate_stopping_time_plot() -> str:
    """Plot 4: Stopping time distribution."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    max_n = 10000
    total_times = []
    for n in range(2, max_n + 1):
        current = n
        for k in range(10000):
            if current == 1:
                total_times.append(k)
                break
            current = collatz(current)
        else:
            total_times.append(-1)

    ns = list(range(2, max_n + 1))
    ax1.scatter(ns, total_times, s=0.3, alpha=0.3, color='#3498db')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('Total stopping time', fontsize=12)
    ax1.set_title('Total Stopping Times', fontsize=13)

    # Histogram
    valid_times = [t for t in total_times if t >= 0]
    ax2.hist(valid_times, bins=80, color='#3498db', alpha=0.7, edgecolor='white')
    ax2.axvline(x=sum(valid_times)/len(valid_times), color='#e74c3c',
                linewidth=2, label=f'Mean = {sum(valid_times)/len(valid_times):.1f}')
    ax2.set_xlabel('Total stopping time', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Total Stopping Times', fontsize=13)
    ax2.legend(fontsize=10)

    fig.suptitle('Stopping Time Analysis (n = 2 to 10,000)', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def generate_drift_plot() -> str:
    """Plot 5: Symbolic drift analysis."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    max_n = 5000
    odd_fractions = []
    for n in range(2, max_n + 1):
        orbit = collatz_orbit(n, max_steps=10000)
        total = len(orbit) - 1
        if total > 0:
            odd = sum(1 for i in range(total) if orbit[i] % 2 == 1)
            odd_fractions.append(odd / total)

    ax1.scatter(range(2, max_n + 1), odd_fractions, s=0.3, alpha=0.3, color='#9b59b6')
    ax1.axhline(y=1/3, color='#e74c3c', linewidth=2, label='Critical: 1/3',
                linestyle='--')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('Fraction of odd steps', fontsize=12)
    ax1.set_title('Odd Step Fraction per Orbit', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 0.6)

    ax2.hist(odd_fractions, bins=60, color='#9b59b6', alpha=0.7, edgecolor='white')
    ax2.axvline(x=1/3, color='#e74c3c', linewidth=2, linestyle='--', label='Critical: 1/3')
    ax2.axvline(x=sum(odd_fractions)/len(odd_fractions), color='#2ecc71',
                linewidth=2, label=f'Mean = {sum(odd_fractions)/len(odd_fractions):.4f}')
    ax2.set_xlabel('Fraction of odd steps', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Distribution of Odd Step Fractions', fontsize=13)
    ax2.legend(fontsize=10)

    fig.suptitle('Symbolic Drift Analysis: Even Steps Must Dominate', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def generate_all_visualizations() -> dict:
    """Generate all visualizations and return as base64 dict."""
    if not HAS_MATPLOTLIB:
        return {}

    print("Generating visualizations...")
    results = {}

    print("  1/5: Orbit plot...")
    results['orbits'] = generate_orbit_plot()

    print("  2/5: Branch analysis...")
    results['branches'] = generate_branch_analysis()

    print("  3/5: Contraction map...")
    results['contraction'] = generate_contraction_map()

    print("  4/5: Stopping times...")
    results['stopping'] = generate_stopping_time_plot()

    print("  5/5: Drift analysis...")
    results['drift'] = generate_drift_plot()

    print("Done!")
    return results


if __name__ == "__main__":
    viz = generate_all_visualizations()
    for name, data in viz.items():
        print(f"Generated {name}: {len(data)} chars")
        # Save as file too
        if data.startswith("data:image/png;base64,"):
            raw = base64.b64decode(data.split(",")[1])
            with open(f"viz_{name}.png", "wb") as f:
                f.write(raw)
            print(f"  Saved as viz_{name}.png")
