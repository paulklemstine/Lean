#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Interactive Demo
==========================================

Demonstrates key results from the hyperbolic arithmetic framework:
1. SL₂(ℤ) trace arithmetic and the Chebyshev recurrence
2. The Fricke trace identity on concrete examples
3. Orbit enumeration on the Poincaré disk
4. The Vieta involution generating Markov-like triples
5. Lattice point counting and the conjectured asymptotic
"""

from algorithms import (
    SL2Z, S, T, hyperbolic_distance, enumerate_orbit,
    counting_function, chebyshev_trace_sequence, fricke_character,
    vieta_involution, upper_half_to_disk
)
import math


def demo_trace_arithmetic():
    """Demonstrate trace identities for SL₂(ℤ)."""
    print("=" * 60)
    print("DEMO 1: SL₂(ℤ) Trace Arithmetic")
    print("=" * 60)
    
    # Cayley-Hamilton: tr(g²) = tr(g)² - 2
    g = S.mul(T).mul(T)  # g = ST²
    g_sq = g.mul(g)
    print(f"\ng = ST² = {g}")
    print(f"tr(g) = {g.trace()}")
    print(f"tr(g²) = {g_sq.trace()}")
    print(f"tr(g)² - 2 = {g.trace()**2 - 2}")
    print(f"Cayley-Hamilton verified: {g_sq.trace() == g.trace()**2 - 2}")
    
    # Chebyshev recurrence
    print("\nChebyshev trace recurrence for g = ST²:")
    traces = chebyshev_trace_sequence(g, 8)
    print(f"  tr(g^n) for n=0..7: {traces}")
    for n in range(len(traces) - 2):
        lhs = traces[n + 2]
        rhs = g.trace() * traces[n + 1] - traces[n]
        print(f"  n={n}: tr(g^{n+2})={lhs}, tr(g)·tr(g^{n+1})-tr(g^{n})={rhs}, match={lhs==rhs}")


def demo_fricke_identity():
    """Demonstrate the Fricke trace identity."""
    print("\n" + "=" * 60)
    print("DEMO 2: The Fricke Trace Identity")
    print("=" * 60)
    
    test_pairs = [
        (S, T, "S, T"),
        (S.mul(T), T, "ST, T"),
        (T.mul(T), S.mul(T), "T², ST"),
    ]
    
    for g, h, name in test_pairs:
        gh = g.mul(h)
        comm = g.mul(h).mul(g.inv()).mul(h.inv())
        
        lhs = g.trace()**2 + h.trace()**2 + gh.trace()**2 - g.trace()*h.trace()*gh.trace()
        rhs = comm.trace() + 2
        
        print(f"\n(g, h) = ({name}):")
        print(f"  Fricke char = ({g.trace()}, {h.trace()}, {gh.trace()})")
        print(f"  LHS = tr(g)²+tr(h)²+tr(gh)² - tr(g)tr(h)tr(gh) = {lhs}")
        print(f"  RHS = tr([g,h]) + 2 = {comm.trace()} + 2 = {rhs}")
        print(f"  Identity verified: {lhs == rhs}")
        
        # Check Markov surface: x²+y²+z² - xyz = κ where κ = tr([g,h]) + 2
        kappa = comm.trace() + 2
        x, y, z = g.trace(), h.trace(), gh.trace()
        surface_val = x**2 + y**2 + z**2 - x*y*z
        print(f"  Markov surface: {x}²+{y}²+{z}² - {x}·{y}·{z} = {surface_val} = κ={kappa}")


def demo_vieta():
    """Demonstrate the Vieta involution on the Markov surface."""
    print("\n" + "=" * 60)
    print("DEMO 3: Vieta Involution on the Markov Surface")
    print("=" * 60)
    
    # Start from (1,1,1) on x²+y²+z²-xyz = 2
    triple = (1, 1, 1)
    kappa = sum(t**2 for t in triple) - triple[0]*triple[1]*triple[2]
    print(f"\nRoot triple: {triple}, κ = {kappa}")
    
    # Apply Vieta involutions
    print("\nVieta tree (first few levels):")
    visited = {triple}
    queue = [triple]
    for level in range(5):
        new_queue = []
        for (x, y, z) in queue:
            for new_triple in [
                vieta_involution(x, y, z),
                (y, z, y*z - x),
                (x, z, x*z - y),
            ]:
                canonical = tuple(sorted(new_triple))
                if canonical not in visited:
                    # Verify surface equation
                    a, b, c = new_triple
                    val = a**2 + b**2 + c**2 - a*b*c
                    visited.add(canonical)
                    new_queue.append(new_triple)
                    print(f"  Level {level+1}: {new_triple}, surface value = {val}, verified = {val == kappa}")
        queue = new_queue


def demo_orbit():
    """Demonstrate orbit enumeration and counting."""
    print("\n" + "=" * 60)
    print("DEMO 4: Orbit Enumeration on the Poincaré Disk")
    print("=" * 60)
    
    base_point = complex(0, 0)
    
    print("\nEnumerating modular group orbit at origin...")
    orbit = enumerate_orbit([S, T], max_word_length=6)
    
    # Classify by word length
    by_length = {}
    for g, length in orbit.items():
        by_length.setdefault(length, []).append(g)
    
    print(f"\n{'Word length':<15} {'Count':<10} {'Cumulative':<12} {'New traces'}")
    print("-" * 60)
    cumulative = 0
    for length in sorted(by_length.keys()):
        elements = by_length[length]
        cumulative += len(elements)
        traces = sorted(set(g.trace() for g in elements))[:5]
        trace_str = str(traces) + ("..." if len(set(g.trace() for g in elements)) > 5 else "")
        print(f"{length:<15} {len(elements):<10} {cumulative:<12} {trace_str}")
    
    # Counting function
    print(f"\n{'R':<8} {'N(R)':<10} {'e^R':<12} {'N(R)/e^R':<12} {'3/π ≈ 0.955'}")
    print("-" * 55)
    for R in [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0]:
        N = counting_function(base_point, orbit, R)
        eR = math.exp(R)
        ratio = N / eR if eR > 0 else 0
        print(f"{R:<8.1f} {N:<10} {eR:<12.2f} {ratio:<12.4f} {'←' if abs(ratio - 3/math.pi) < 0.3 else ''}")


def demo_trace_spectrum():
    """Demonstrate that every integer is a trace of some SL₂(ℤ) element."""
    print("\n" + "=" * 60)
    print("DEMO 5: The Trace Spectrum of SL₂(ℤ)")
    print("=" * 60)
    
    print("\nConstructing elements with prescribed traces:")
    for t in range(-5, 11):
        # The matrix [[t-1, t-2], [1, 1]] has det = (t-1) - (t-2) = 1, trace = t
        g = SL2Z(t - 1, t - 2, 1, 1)
        print(f"  trace {t:>3}: {g}, det = {g.a*g.d - g.b*g.c}, tr = {g.trace()}")


def demo_counting_conjecture():
    """Test the hyperbolic counting conjecture N(R)/e^R → 3/π."""
    print("\n" + "=" * 60)
    print("DEMO 6: Testing the Counting Conjecture")
    print("=" * 60)
    
    target = 3 / math.pi
    print(f"\nConjectured limit: 3/π ≈ {target:.6f}")
    print("\nNote: The base point is the origin. For small R, finite-size effects")
    print("dominate. The asymptotic should emerge for large R, but our enumeration")
    print("is limited by word length.")
    
    # Use larger word length for better statistics
    orbit = enumerate_orbit([S, T], max_word_length=8)
    base = complex(0, 0)
    
    print(f"\nTotal orbit elements enumerated: {len(orbit)}")
    print(f"\n{'R':<8} {'N(R)':<10} {'N(R)/e^R':<12} {'Deviation from 3/π'}")
    print("-" * 50)
    for R in [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]:
        N = counting_function(base, orbit, R)
        eR = math.exp(R)
        ratio = N / eR
        dev = abs(ratio - target) / target * 100
        print(f"{R:<8.1f} {N:<10} {ratio:<12.6f} {dev:.1f}%")


if __name__ == "__main__":
    demo_trace_arithmetic()
    demo_fricke_identity()
    demo_vieta()
    demo_orbit()
    demo_trace_spectrum()
    demo_counting_conjecture()


#!/usr/bin/env python3
"""
Visualization: Poincaré Disk Orbit and Trace Spectrum
=====================================================

Standalone matplotlib visualization of the modular group orbit
on the Poincaré disk, trace spectrum, and Chebyshev recurrence.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from dataclasses import dataclass
from typing import Dict, List, Set, Tuple


@dataclass(frozen=True)
class SL2Z:
    a: int; b: int; c: int; d: int
    def mul(self, o: 'SL2Z') -> 'SL2Z':
        return SL2Z(self.a*o.a+self.b*o.c, self.a*o.b+self.b*o.d,
                     self.c*o.a+self.d*o.c, self.c*o.b+self.d*o.d)
    def inv(self) -> 'SL2Z': return SL2Z(self.d, -self.b, -self.c, self.a)
    def trace(self) -> int: return self.a + self.d
    def mobius(self, z: complex) -> complex:
        d = self.c*z + self.d
        return (self.a*z + self.b) / d if abs(d) > 1e-15 else complex(1e10)


S = SL2Z(0, -1, 1, 0)
T = SL2Z(1, 1, 0, 1)


def enumerate_orbit(gens: List[SL2Z], max_len: int) -> Dict[SL2Z, int]:
    visited = {SL2Z(1,0,0,1): 0}
    frontier = {SL2Z(1,0,0,1)}
    all_g = gens + [g.inv() for g in gens]
    for l in range(1, max_len + 1):
        nf = set()
        for g in frontier:
            for gen in all_g:
                p = g.mul(gen)
                if p not in visited:
                    visited[p] = l
                    nf.add(p)
        frontier = nf
    return visited


def hyp_dist(z: complex, w: complex) -> float:
    num = abs(z - w)
    den = abs(1 - z.conjugate() * w)
    tau = num / den if den > 1e-15 else 1.0
    return math.log((1 + min(tau, 0.9999)) / (1 - min(tau, 0.9999))) if tau < 1 else 30.0


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 14))

    # 1. Poincaré disk orbit
    ax1 = axes[0, 0]
    orbit = enumerate_orbit([S, T], 7)
    base = complex(0.1, 0.2)

    xs, ys, colors = [], [], []
    for g, wl in orbit.items():
        gz = g.mobius(base)
        if abs(gz) < 0.999:
            xs.append(gz.real)
            ys.append(gz.imag)
            colors.append(wl)

    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax1.add_patch(circle)
    sc = ax1.scatter(xs, ys, c=colors, cmap='viridis', s=8, alpha=0.7)
    ax1.set_xlim(-1.1, 1.1)
    ax1.set_ylim(-1.1, 1.1)
    ax1.set_aspect('equal')
    ax1.set_title('PSL(2,ℤ) Orbit on the Poincaré Disk', fontsize=14)
    ax1.set_xlabel('Re(z)')
    ax1.set_ylabel('Im(z)')
    plt.colorbar(sc, ax=ax1, label='Word length')

    # 2. Trace distribution
    ax2 = axes[0, 1]
    traces = [g.trace() for g in orbit.keys()]
    trace_range = range(min(traces), max(traces) + 1)
    trace_counts = {t: traces.count(t) for t in trace_range}
    ax2.bar(trace_counts.keys(), trace_counts.values(), color='steelblue', alpha=0.7)
    ax2.set_title('Trace Distribution of Orbit Elements', fontsize=14)
    ax2.set_xlabel('Trace value')
    ax2.set_ylabel('Count')
    ax2.axvline(x=2, color='red', linestyle='--', alpha=0.5, label='tr=2 (parabolic)')
    ax2.axvline(x=-2, color='red', linestyle='--', alpha=0.5, label='tr=-2')
    ax2.legend()

    # 3. Chebyshev trace sequences
    ax3 = axes[1, 0]
    test_elements = [
        (SL2Z(2, 1, 1, 1), "tr=3 (hyp)"),
        (SL2Z(3, 2, 1, 1), "tr=4 (hyp)"),
        (SL2Z(4, 3, 1, 1), "tr=5 (hyp)"),
    ]
    for g, label in test_elements:
        tr_seq = [2, g.trace()]
        t = g.trace()
        for _ in range(8):
            tr_seq.append(t * tr_seq[-1] - tr_seq[-2])
        ax3.semilogy(range(len(tr_seq)), [abs(x) for x in tr_seq], 'o-', label=label, markersize=4)
    ax3.set_title('Chebyshev Trace Growth (log scale)', fontsize=14)
    ax3.set_xlabel('Power n')
    ax3.set_ylabel('|tr(gⁿ)|')
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    # 4. Counting function
    ax4 = axes[1, 1]
    Rs = np.linspace(0.1, 8, 50)
    Ns = []
    for R in Rs:
        count = sum(1 for g in orbit if abs(g.mobius(base)) < 0.999 and
                    hyp_dist(base, g.mobius(base)) <= R)
        Ns.append(count)

    ax4.plot(Rs, Ns, 'b-', label='N(R)', linewidth=2)
    ax4.plot(Rs, [3/math.pi * math.exp(R) for R in Rs], 'r--',
             label=f'(3/π)·eᴿ ≈ {3/math.pi:.3f}·eᴿ', linewidth=1.5)
    ax4.set_title('Lattice Point Counting N(R)', fontsize=14)
    ax4.set_xlabel('Hyperbolic radius R')
    ax4.set_ylabel('Count')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    ax4.set_yscale('log')

    plt.tight_layout()
    plt.savefig('poincare_orbit.png', dpi=150, bbox_inches='tight')
    print("Saved poincare_orbit.png")


if __name__ == "__main__":
    main()
