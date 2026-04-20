#!/usr/bin/env python3
"""
Ghost Map Explorer: Interactive demonstration of Berggren Universal Parent factoring.

Demonstrates:
1. Ghost map computation and orbit visualization
2. Linear triplet fixed-point property
3. Unit probe descent chain
4. Deficit channel for factor discovery
5. Multi-triplet GCD voting strategy
6. Eigenvalue analysis of the ghost map matrix

Usage:
    python ghost_explorer.py
"""

import math
from collections import Counter

# ═══════════════════════════════════════════════════════════════
# Core Ghost Map
# ═══════════════════════════════════════════════════════════════

def ghost_p(a, b, c):
    return a + 2*b - 2*c

def ghost_q(a, b, c):
    return 2*a + b - 2*c

def ghost_h(a, b, c):
    return 3*c - 2*(a + b)

def deficit(a, b, c):
    return a**2 + b**2 - c**2

def UP(a, b, c):
    """Universal Parent with absolute values."""
    return (abs(ghost_p(a,b,c)), abs(ghost_q(a,b,c)), ghost_h(a,b,c))

def ghost_signed(a, b, c):
    """Ghost map without absolute values (signed)."""
    return (ghost_p(a,b,c), ghost_q(a,b,c), ghost_h(a,b,c))

# ═══════════════════════════════════════════════════════════════
# Demo 1: Ghost Map Orbits
# ═══════════════════════════════════════════════════════════════

def demo_orbits():
    print("=" * 60)
    print("DEMO 1: Ghost Map Orbits")
    print("=" * 60)

    # PPT orbit (Berggren ancestry)
    print("\n--- PPT (3, 4, 5) orbit (signed ghost map) ---")
    triple = (3, 4, 5)
    for i in range(6):
        d = deficit(*triple)
        print(f"  G^{i}(3,4,5) = {triple}  deficit = {d}")
        triple = ghost_signed(*triple)

    # Factoring triplet orbit
    N = 15
    x = 1
    c = x**2 + N**2
    print(f"\n--- Factoring triplet ({x}, {N}, {c}) orbit (UP with abs) ---")
    triple = (x, N, c)
    for i in range(4):
        d = deficit(*triple)
        print(f"  UP^{i} = {triple}  deficit = {d}")
        triple = UP(*triple)

    # Linear triplet (fixed point)
    print(f"\n--- Linear triplet (3, 15, 18) orbit (UP with abs) ---")
    triple = (3, 15, 18)
    for i in range(3):
        d = deficit(*triple)
        print(f"  UP^{i} = {triple}  deficit = {d}")
        triple = UP(*triple)

# ═══════════════════════════════════════════════════════════════
# Demo 2: Unit Probe Descent Chain
# ═══════════════════════════════════════════════════════════════

def demo_unit_probe():
    print("\n" + "=" * 60)
    print("DEMO 2: Unit Probe Descent Chain (1, N, N)")
    print("=" * 60)

    for N in [77, 143, 35]:
        print(f"\n--- N = {N} ---")
        M = N
        step = 0
        while M >= 3:
            d = deficit(1, M, M)
            gcd_val = math.gcd(abs(ghost_q(1, M, M)), N)
            print(f"  Step {step}: (1, {M}, {M})  deficit = {d}  "
                  f"|q| = {abs(ghost_q(1,M,M))}  gcd(|q|, {N}) = {gcd_val}")
            M -= 2
            step += 1
            if step > 20:
                print("  ... (truncated)")
                break

# ═══════════════════════════════════════════════════════════════
# Demo 3: Deficit Channel Factor Discovery
# ═══════════════════════════════════════════════════════════════

def demo_deficit_channel():
    print("\n" + "=" * 60)
    print("DEMO 3: Deficit Channel Factor Discovery")
    print("=" * 60)

    semiprimes = [(15, 3, 5), (77, 7, 11), (143, 11, 13),
                  (221, 13, 17), (899, 29, 31)]

    for N, p, q in semiprimes:
        print(f"\n--- N = {N} = {p} × {q} ---")

        # Check deficit of divisor triplet
        d_div = deficit(p, q, p*q)
        print(f"  Divisor triplet ({p}, {q}, {N}): deficit = {d_div}")
        print(f"    {p} | deficit? {d_div % p == 0}")
        print(f"    Factor gap |p-q| = {abs(p-q)}")
        print(f"    Ghost gap |gp-gq| = {abs(ghost_p(p,q,N) - ghost_q(p,q,N))}")

        # Check deficit channel for factoring triplet
        hits = []
        for x in range(1, min(N, 50)):
            c = x**2 + N**2
            d = deficit(x, N, c)
            g = math.gcd(abs(d), N)
            if g > 1 and g < N:
                hits.append((x, g))
        if hits:
            print(f"  Factoring triplet deficit hits: {hits[:5]}")

# ═══════════════════════════════════════════════════════════════
# Demo 4: Multi-Triplet GCD Voting
# ═══════════════════════════════════════════════════════════════

def demo_multi_triplet_voting():
    print("\n" + "=" * 60)
    print("DEMO 4: Multi-Triplet GCD Voting Strategy")
    print("=" * 60)

    semiprimes = [(15, 3, 5), (77, 7, 11), (143, 11, 13),
                  (899, 29, 31), (2021, 43, 47)]

    for N, true_p, true_q in semiprimes:
        votes = Counter()
        for x in range(1, min(N, 100)):
            # Factoring triplet
            c = x**2 + N**2
            for val in [ghost_p(x, N, c), ghost_q(x, N, c), ghost_h(x, N, c)]:
                g = math.gcd(abs(val), N)
                if 1 < g < N:
                    votes[g] += 1

            # Split triplet
            if 0 < x < N:
                for val in [ghost_p(N-x, x, N), ghost_q(N-x, x, N)]:
                    g = math.gcd(abs(val), N)
                    if 1 < g < N:
                        votes[g] += 1

            # Linear triplet
            d = deficit(x, N, x + N)
            g = math.gcd(abs(d), N)
            if 1 < g < N:
                votes[g] += 1

        if votes:
            top = votes.most_common(3)
            winner = top[0][0]
            correct = winner in (true_p, true_q)
            print(f"  N={N}: top votes = {top}  "
                  f"winner = {winner}  correct = {'✓' if correct else '✗'}")
        else:
            print(f"  N={N}: no factor found")

# ═══════════════════════════════════════════════════════════════
# Demo 5: Trace Invariant Verification
# ═══════════════════════════════════════════════════════════════

def demo_trace_invariant():
    print("\n" + "=" * 60)
    print("DEMO 5: Trace Invariant p + q + h = a + b - c")
    print("=" * 60)

    triples = [(3, 4, 5), (5, 12, 13), (7, 11, 77), (1, 15, 226)]
    for a, b, c in triples:
        p, q, h = ghost_p(a,b,c), ghost_q(a,b,c), ghost_h(a,b,c)
        trace_ghost = p + q + h
        trace_orig = a + b - c
        print(f"  ({a},{b},{c}): trace = {trace_orig}, "
              f"ghost trace = {trace_ghost}, match = {'✓' if trace_ghost == trace_orig else '✗'}")

# ═══════════════════════════════════════════════════════════════
# Demo 6: Eigenvalue Analysis
# ═══════════════════════════════════════════════════════════════

def demo_eigenvalues():
    print("\n" + "=" * 60)
    print("DEMO 6: Ghost Map Matrix Eigenvalue Analysis")
    print("=" * 60)

    import numpy as np

    G = np.array([[1, 2, -2],
                  [2, 1, -2],
                  [-2, -2, 3]], dtype=float)

    eigenvalues, eigenvectors = np.linalg.eig(G)

    print(f"  Ghost map matrix G:")
    print(f"  {G[0]}")
    print(f"  {G[1]}")
    print(f"  {G[2]}")
    print(f"\n  Eigenvalues: {eigenvalues}")
    print(f"  Expected: -1, 3+2√2 ≈ {3+2*math.sqrt(2):.4f}, 3-2√2 ≈ {3-2*math.sqrt(2):.4f}")
    print(f"\n  Eigenvectors (columns):")
    for i in range(3):
        v = eigenvectors[:, i]
        print(f"    λ = {eigenvalues[i]:.4f}: v = ({v[0]:.4f}, {v[1]:.4f}, {v[2]:.4f})")

    print(f"\n  det(G) = {np.linalg.det(G):.0f}")
    print(f"  tr(G) = {np.trace(G):.0f}")

    # Verify G² is NOT -I
    G2 = G @ G
    print(f"\n  G² =")
    for row in G2:
        print(f"    {row}")
    print(f"  (Note: G² ≠ -I, confirming period is NOT 2 for signed map)")

    # Check spectral radius and contracting direction
    print(f"\n  Spectral radius: {max(abs(eigenvalues)):.4f}")
    print(f"  Contracting eigenvalue: {min(abs(eigenvalues)):.4f}")
    print(f"  Expansion ratio: {max(abs(eigenvalues))/min(abs(eigenvalues)):.2f}")

# ═══════════════════════════════════════════════════════════════
# Demo 7: Two-Invariant Product Recovery
# ═══════════════════════════════════════════════════════════════

def demo_two_invariants():
    print("\n" + "=" * 60)
    print("DEMO 7: Two-Invariant Product Recovery (2ab from τ, δ)")
    print("=" * 60)

    triples = [(3, 4, 5), (7, 11, 77), (5, 12, 13), (1, 15, 226)]
    for a, b, c in triples:
        tau = a + b - c
        delta = a**2 + b**2 - c**2
        recovered_2ab = tau**2 + 2*tau*c - delta
        actual_2ab = 2*a*b
        print(f"  ({a},{b},{c}): τ={tau}, δ={delta}, "
              f"2ab={actual_2ab}, recovered={recovered_2ab}, "
              f"match={'✓' if recovered_2ab == actual_2ab else '✗'}")

# ═══════════════════════════════════════════════════════════════
# Demo 8: Ghost GCD vs Trial Division Benchmark
# ═══════════════════════════════════════════════════════════════

def demo_benchmark():
    print("\n" + "=" * 60)
    print("DEMO 8: Ghost GCD vs Trial Division Benchmark")
    print("=" * 60)

    semiprimes = [(77, 7, 11), (143, 11, 13), (341, 11, 31),
                  (899, 29, 31), (2021, 43, 47), (6557, 79, 83)]

    print(f"  {'N':>6}  {'Factors':>10}  {'Trial ops':>10}  "
          f"{'Ghost ops':>10}  {'Speedup':>8}")
    print(f"  {'-'*6}  {'-'*10}  {'-'*10}  {'-'*10}  {'-'*8}")

    for N, p, q in semiprimes:
        # Trial division
        trial_ops = 0
        for i in range(2, N):
            trial_ops += 1
            if N % i == 0:
                break

        # Ghost GCD
        ghost_ops = 0
        found = False
        for x in range(1, N):
            ghost_ops += 1
            c = x**2 + N**2
            gp_val = ghost_p(x, N, c)
            gq_val = ghost_q(x, N, c)
            g1 = math.gcd(abs(gp_val), N)
            g2 = math.gcd(abs(gq_val), N)
            if 1 < g1 < N or 1 < g2 < N:
                found = True
                break

        speedup = trial_ops / ghost_ops if ghost_ops > 0 else 0
        print(f"  {N:>6}  {p}×{q:>3}  {trial_ops:>10}  "
              f"{ghost_ops:>10}  {speedup:>8.1f}×")

# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Ghost Map Explorer: Berggren Universal Parent Factoring ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_orbits()
    demo_unit_probe()
    demo_deficit_channel()
    demo_multi_triplet_voting()
    demo_trace_invariant()

    try:
        import numpy as np
        demo_eigenvalues()
    except ImportError:
        print("\n[Skipping eigenvalue demo: numpy not available]")

    demo_two_invariants()
    demo_benchmark()

    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)
