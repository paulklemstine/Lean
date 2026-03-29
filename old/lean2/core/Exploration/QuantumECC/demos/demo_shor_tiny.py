#!/usr/bin/env python3
"""
Shor's Algorithm Simulation on Tiny Elliptic Curves
=====================================================

Simulates the core of Shor's ECDLP algorithm on small curves to demonstrate:
1. Period-finding structure
2. How QFT extracts the discrete log
3. Why the same technique scales to secp256k1 (in principle)

Usage: python demo_shor_tiny.py
Outputs: shor_period_finding.png
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import Optional, Tuple, List, Dict

# --- EC arithmetic (same as demo_elliptic_curve.py) ---

def extended_gcd(a, b):
    if a == 0: return b, 0, 1
    g, x, y = extended_gcd(b % a, a)
    return g, y - (b // a) * x, x

def mod_inverse(a, p):
    g, x, _ = extended_gcd(a % p, p)
    if g != 1: raise ValueError(f"No inverse")
    return x % p

def ec_add(P, Q, a, p):
    if P is None: return Q
    if Q is None: return P
    x1, y1 = P; x2, y2 = Q
    if x1 == x2 and y1 == (p - y2) % p: return None
    if x1 == x2 and y1 == y2:
        if y1 == 0: return None
        lam = (3 * x1**2 + a) * mod_inverse(2 * y1, p) % p
    else:
        lam = (y2 - y1) * mod_inverse(x2 - x1, p) % p
    x3 = (lam**2 - x1 - x2) % p
    y3 = (lam * (x1 - x3) - y1) % p
    return (x3, y3)

def ec_scalar_mul(k, P, a, p):
    result = None; addend = P
    while k > 0:
        if k & 1: result = ec_add(result, addend, a, p)
        addend = ec_add(addend, addend, a, p)
        k >>= 1
    return result

def ec_points(a, b, p):
    pts = []
    for x in range(p):
        rhs = (x**3 + a*x + b) % p
        for y in range(p):
            if (y*y) % p == rhs: pts.append((x, y))
    return pts

def group_order(G, a, p):
    """Find the order of point G."""
    n = 1; current = G
    while current is not None:
        current = ec_add(current, G, a, p)
        n += 1
        if n > p + 2 * int(p**0.5) + 5: break
    return n

# --- Shor's algorithm simulation ---

def simulate_shor_ecdlp(a_curve, b_curve, p, G, Q, verbose=True):
    """
    Simulate Shor's algorithm for finding k such that Q = kG.
    
    This is a classical simulation that demonstrates the structure:
    1. Compute f(a,b) = aG + bQ for all (a,b)
    2. Find the "period lattice" — pairs (a1,b1), (a2,b2) with f(a1,b1) = f(a2,b2)
    3. Extract k from the period
    
    On a real quantum computer, steps 1-2 would use superposition + QFT.
    """
    n = group_order(G, a_curve, p)
    
    if verbose:
        print(f"\n  Curve: y² = x³ + {a_curve}x + {b_curve} over F_{p}")
        print(f"  G = {G}, Q = {Q}")
        print(f"  Group order n = {n}")
    
    # Step 1: Build the function f(a,b) = aG + bQ
    f_values: Dict[Tuple, Optional[Tuple]] = {}
    collisions = []
    
    for a_val in range(n):
        for b_val in range(n):
            aG = ec_scalar_mul(a_val, G, a_curve, p)
            bQ = ec_scalar_mul(b_val, Q, a_curve, p)
            result = ec_add(aG, bQ, a_curve, p)
            
            # Check for collision
            for (prev_a, prev_b), prev_result in f_values.items():
                if result == prev_result and (prev_a, prev_b) != (a_val, b_val):
                    collisions.append(((prev_a, prev_b), (a_val, b_val), result))
            
            f_values[(a_val, b_val)] = result
    
    if verbose:
        print(f"  Found {len(collisions)} collisions in f(a,b) = aG + bQ")
    
    # Step 2: Extract k from collisions
    # f(a1,b1) = f(a2,b2) means a1*G + b1*Q = a2*G + b2*Q
    # => (a1-a2)*G = (b2-b1)*Q = (b2-b1)*k*G
    # => a1-a2 ≡ (b2-b1)*k (mod n)
    # => k ≡ (a1-a2) * (b2-b1)^(-1) (mod n)
    
    found_k = None
    for (a1, b1), (a2, b2), _ in collisions:
        da = (a1 - a2) % n
        db = (b2 - b1) % n
        if db == 0: continue
        try:
            k_candidate = (da * mod_inverse(db, n)) % n
            # Verify
            if ec_scalar_mul(k_candidate, G, a_curve, p) == Q:
                found_k = k_candidate
                if verbose:
                    print(f"  ✅ Found k = {k_candidate} (from collision ({a1},{b1}) vs ({a2},{b2}))")
                break
        except ValueError:
            continue
    
    if found_k is None and verbose:
        print("  ❌ Failed to extract k (shouldn't happen with enough collisions)")
    
    return found_k, collisions, f_values

def plot_period_structure():
    """Visualize the period-finding structure of Shor's ECDLP algorithm."""
    # Use a small curve: y² = x³ + x + 1 over F_23
    p = 23
    a_curve, b_curve = 1, 1
    points = ec_points(a_curve, b_curve, p)
    
    if len(points) < 3:
        print("Not enough points, trying different curve...")
        return
    
    G = points[0]
    n = group_order(G, a_curve, p)
    
    # Choose a random k
    k_secret = 7  # Our "private key"
    Q = ec_scalar_mul(k_secret, G, a_curve, p)
    
    print(f"\n🔬 Shor's Algorithm Simulation")
    print(f"   Curve: y² = x³ + {a_curve}x + {b_curve} over F_{p}")
    print(f"   G = {G}, order = {n}")
    print(f"   Secret k = {k_secret}")
    print(f"   Q = kG = {Q}")
    
    found_k, collisions, f_values = simulate_shor_ecdlp(a_curve, b_curve, p, G, Q)
    
    # Visualize the function f(a,b) as a heatmap
    fig, axes = plt.subplots(2, 2, figsize=(16, 14))
    fig.suptitle(f"Shor's Algorithm: Period-Finding for ECDLP\n"
                 f"y² = x³ + {a_curve}x + {b_curve} over F_{{{p}}}, "
                 f"G={G}, Q=kG={Q}, secret k={k_secret}", 
                 fontsize=14, fontweight='bold')
    
    # Plot 1: f(a,b) encoded as color
    ax1 = axes[0][0]
    grid = np.zeros((n, n))
    for (a_val, b_val), pt in f_values.items():
        if a_val < n and b_val < n:
            if pt is not None:
                grid[b_val][a_val] = (pt[0] * p + pt[1]) % (n * 3)
            else:
                grid[b_val][a_val] = -1
    
    im = ax1.imshow(grid, cmap='tab20', origin='lower', aspect='equal')
    ax1.set_xlabel('a (coefficient of G)')
    ax1.set_ylabel('b (coefficient of Q)')
    ax1.set_title('f(a,b) = aG + bQ\n(same color = collision = period)', fontsize=11)
    plt.colorbar(im, ax=ax1, label='Point encoding')
    
    # Plot 2: Collision structure
    ax2 = axes[0][1]
    if collisions:
        for (a1, b1), (a2, b2), pt in collisions[:50]:
            ax2.plot([a1, a2], [b1, b2], 'r-', alpha=0.1, linewidth=0.5)
            ax2.plot(a1, b1, 'b.', markersize=2)
            ax2.plot(a2, b2, 'r.', markersize=2)
    
    ax2.set_xlabel('a')
    ax2.set_ylabel('b')
    ax2.set_title('Collision Pairs\n(lines connect (a₁,b₁) ↔ (a₂,b₂) with f equal)', fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: DFT of function values (simulating QFT)
    ax3 = axes[1][0]
    # Create 1D slice of f along b=0
    f_slice = []
    for a_val in range(n):
        pt = f_values.get((a_val, 0))
        if pt is not None:
            f_slice.append(pt[0])  # Use x-coordinate
        else:
            f_slice.append(0)
    
    f_slice = np.array(f_slice, dtype=float)
    fft = np.abs(np.fft.fft(f_slice))
    freqs = np.arange(len(fft))
    
    ax3.bar(freqs, fft, color='purple', alpha=0.7)
    ax3.set_xlabel('Frequency (QFT output)')
    ax3.set_ylabel('Amplitude')
    ax3.set_title('DFT of f(a, 0) = aG\n(simulating Quantum Fourier Transform)', fontsize=11)
    ax3.grid(True, alpha=0.3)
    
    # Peak annotation
    peaks = np.argsort(fft)[-3:]
    for pk in peaks:
        if fft[pk] > np.mean(fft):
            ax3.annotate(f'peak at {pk}', (pk, fft[pk]), 
                        textcoords="offset points", xytext=(10, 10), fontsize=9)
    
    # Plot 4: Summary
    ax4 = axes[1][1]
    ax4.axis('off')
    
    summary = f"""
    Shor's Algorithm Results
    ════════════════════════
    
    Curve: y² = x³ + {a_curve}x + {b_curve} (mod {p})
    Generator: G = {G}
    Public key: Q = {Q}
    Group order: n = {n}
    
    Secret key: k = {k_secret}  (hidden)
    
    Algorithm finds: k = {found_k}  {'✅' if found_k == k_secret else '❌'}
    
    Collisions found: {len(collisions)}
    
    ════════════════════════
    
    Key insight: The function f(a,b) = aG + bQ
    has a hidden linear structure that the
    Quantum Fourier Transform can detect.
    
    Classically: must search O(√n) values
    Quantumly:   O(log³ n) operations
    
    For secp256k1: n ≈ 2²⁵⁶
      Classical: 2¹²⁸ operations
      Quantum:   256³ ≈ 10⁷ operations
    """
    
    ax4.text(0.05, 0.95, summary, transform=ax4.transAxes,
             fontsize=10, verticalalignment='top', fontfamily='monospace',
             bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='green', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('shor_period_finding.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✅ Saved: shor_period_finding.png")

if __name__ == '__main__':
    print("=" * 60)
    print("Shor's Algorithm for ECDLP — Tiny Curve Simulation")
    print("=" * 60)
    
    # Test on multiple small curves
    test_cases = [
        (1, 1, 23, 7),   # y² = x³ + x + 1 over F_23, k=7
        (0, 7, 11, 3),   # y² = x³ + 7 over F_11 (secp256k1 eq!), k=3
        (2, 3, 17, 5),   # y² = x³ + 2x + 3 over F_17, k=5
    ]
    
    for a_c, b_c, p, k_secret in test_cases:
        points = ec_points(a_c, b_c, p)
        if not points:
            print(f"\n  ⚠️ No points on y² = x³ + {a_c}x + {b_c} over F_{p}")
            continue
        
        G = points[0]
        n = group_order(G, a_c, p)
        
        if k_secret >= n:
            k_secret = k_secret % n
            if k_secret == 0:
                k_secret = 1
        
        Q = ec_scalar_mul(k_secret, G, a_c, p)
        
        if Q is None:
            print(f"\n  ⚠️ Q = kG is the point at infinity for k={k_secret}")
            continue
        
        found_k, _, _ = simulate_shor_ecdlp(a_c, b_c, p, G, Q)
        
        if found_k == k_secret:
            print(f"  🎯 SUCCESS: Recovered secret key k = {k_secret}")
        else:
            print(f"  ⚠️ Found k = {found_k}, expected {k_secret}")
    
    print("\n📊 Generating period-finding visualization...")
    plot_period_structure()
    
    print("\n✅ All Shor simulations complete!")
