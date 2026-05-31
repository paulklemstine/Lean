#!/usr/bin/env python3
"""
Hyperbolic Trace Arithmetic — Demonstration Script

Demonstrates the key results:
1. Chebyshev-Trace Invariant
2. Trace Product Identity
3. Fricke-Vogt Identity
4. Trace Spectrum Density
5. Farey Neighbor Mediant
6. Critical Line → Poincaré Disk
"""

from algorithms import (
    sl2_mul, sl2_inv, sl2_trace, cheb_trace, cheb_trace_invariant,
    trace_spectrum, fricke_vogt_check, trace_product_check,
    farey_neighbors, cayley_transform
)
import math


def demo_chebyshev_invariant():
    """Demonstrate the Chebyshev-Trace Invariant: Q(n) = 4 - t² for all n."""
    print("=" * 60)
    print("1. CHEBYSHEV-TRACE INVARIANT")
    print("   Q(n) = cheb(n+1)² + cheb(n)² - t·cheb(n)·cheb(n+1)")
    print("   should equal 4 - t² for all n")
    print("=" * 60)

    for t in [2, 3, 5, 7]:
        print(f"\n  t = {t}, expected invariant = {4 - t**2}")
        for n in range(8):
            cn = cheb_trace(t, n)
            cn1 = cheb_trace(t, n + 1)
            Q = cheb_trace_invariant(t, n)
            print(f"    n={n}: cheb({n})={cn:>6}, cheb({n+1})={cn1:>6}, Q={Q:>6} {'✓' if Q == 4 - t**2 else '✗'}")


def demo_trace_product():
    """Demonstrate the Trace Product Identity: tr(AB) + tr(AB⁻¹) = tr(A)·tr(B)."""
    print("\n" + "=" * 60)
    print("2. TRACE PRODUCT IDENTITY")
    print("   tr(AB) + tr(AB⁻¹) = tr(A) · tr(B)")
    print("=" * 60)

    S = (0, -1, 1, 0)
    T = (1, 1, 0, 1)
    ST = sl2_mul(S, T)
    TT = sl2_mul(T, T)
    names = {"S": S, "T": T, "ST": ST, "T²": TT}

    for nA, A in names.items():
        for nB, B in names.items():
            AB = sl2_mul(A, B)
            AB_inv = sl2_mul(A, sl2_inv(B))
            lhs = sl2_trace(AB) + sl2_trace(AB_inv)
            rhs = sl2_trace(A) * sl2_trace(B)
            ok = "✓" if lhs == rhs else "✗"
            print(f"  {nA}·{nB}: tr(AB)={sl2_trace(AB):>3}, "
                  f"tr(AB⁻¹)={sl2_trace(AB_inv):>3}, "
                  f"sum={lhs:>3} = tr(A)·tr(B)={rhs:>3} {ok}")


def demo_fricke_vogt():
    """Demonstrate the Fricke-Vogt Identity."""
    print("\n" + "=" * 60)
    print("3. FRICKE-VOGT IDENTITY")
    print("   tr(A)² + tr(B)² + tr(AB)² = tr(A)·tr(B)·tr(AB) + tr([A,B]) + 2")
    print("=" * 60)

    S = (0, -1, 1, 0)
    T = (1, 1, 0, 1)
    matrices = [
        ("S", S), ("T", T), ("ST", sl2_mul(S, T)),
        ("TS", sl2_mul(T, S)), ("T²", sl2_mul(T, T))
    ]

    for nA, A in matrices:
        for nB, B in matrices:
            AB = sl2_mul(A, B)
            comm = sl2_mul(sl2_mul(AB, sl2_inv(A)), sl2_inv(B))
            tA, tB, tAB, tC = sl2_trace(A), sl2_trace(B), sl2_trace(AB), sl2_trace(comm)
            lhs = tA**2 + tB**2 + tAB**2
            rhs = tA * tB * tAB + tC + 2
            ok = "✓" if lhs == rhs else "✗"
            print(f"  ({nA},{nB}): tr(A)={tA:>2}, tr(B)={tB:>2}, "
                  f"tr(AB)={tAB:>3}, tr([A,B])={tC:>3}, "
                  f"LHS={lhs:>4}=RHS={rhs:>4} {ok}")


def demo_trace_spectrum():
    """Demonstrate trace spectrum density for different word lengths."""
    print("\n" + "=" * 60)
    print("4. TRACE SPECTRUM DENSITY")
    print("   Count of distinct traces for words of length ≤ k")
    print("=" * 60)

    for k in range(1, 13):
        traces = trace_spectrum(k)
        min_t = min(traces)
        max_t = max(traces)
        print(f"  k={k:>2}: {len(traces):>4} distinct traces, "
              f"range [{min_t:>4}, {max_t:>4}], "
              f"|traces|/k² = {len(traces)/max(k*k, 1):.2f}")


def demo_farey_mediant():
    """Demonstrate the Farey Mediant Theorem."""
    print("\n" + "=" * 60)
    print("5. FAREY MEDIANT THEOREM")
    print("   Mediant (a+c, b+d) is a neighbor of both parents")
    print("=" * 60)

    neighbors = farey_neighbors(8)
    print(f"  Farey sequence F_8 has {len(neighbors)} neighbor pairs")
    for (a, b), (c, d) in neighbors[:10]:
        det = a * d - b * c
        med = (a + c, b + d)
        det_right = med[0] * d - med[1] * c
        det_left = a * med[1] - b * med[0]
        print(f"  ({a}/{b})-({c}/{d}): det={det:>2}, "
              f"mediant=({med[0]}/{med[1]}), "
              f"det_right={det_right:>2}, det_left={det_left:>2}")


def demo_critical_line():
    """Demonstrate the Critical Line → Poincaré Disk map."""
    print("\n" + "=" * 60)
    print("6. CRITICAL LINE → POINCARÉ DISK")
    print("   Cayley transform maps Re(s) = 1/2 into the closed disk")
    print("=" * 60)

    for y in [0, 1, 2, 5, 10, 14.134725, 21.022040, 25.010858, 50, 100]:
        s = complex(0.5, y)
        w = cayley_transform(s)
        norm = abs(w)
        print(f"  s = 1/2 + {y:>10.6f}i  →  w = {w.real:>8.5f} + {w.imag:>8.5f}i  "
              f"|w| = {norm:.6f} {'≤ 1 ✓' if norm <= 1.0001 else '> 1 ✗'}")

    print("\n  (Note: y ≈ 14.13, 21.02, 25.01 are the first three")
    print("   imaginary parts of Riemann zeta zeros on the critical line)")


def demo_growth_comparison():
    """Compare Chebyshev trace growth rates."""
    print("\n" + "=" * 60)
    print("7. CHEBYSHEV TRACE GROWTH")
    print("   cheb(t, n) grows exponentially for t ≥ 3")
    print("=" * 60)

    for t in [2, 3, 5, 10]:
        print(f"\n  t = {t}:")
        for n in range(10):
            cn = cheb_trace(t, n)
            ratio = cn / max(cheb_trace(t, max(n-1, 0)), 1)
            print(f"    cheb({t}, {n}) = {cn:>12}  "
                  f"ratio = {ratio:>8.3f}  "
                  f"(golden ≈ {((t + math.sqrt(t**2 - 4))/2) if t > 2 else 'N/A'})")


if __name__ == "__main__":
    demo_chebyshev_invariant()
    demo_trace_product()
    demo_fricke_vogt()
    demo_trace_spectrum()
    demo_farey_mediant()
    demo_critical_line()
    demo_growth_comparison()


#!/usr/bin/env python3
"""
Visualization: Chebyshev-Trace Sequences and the Invariant

Produces plots showing:
1. Growth of Chebyshev traces for different initial traces
2. The conserved invariant Q(n) = 4 - t²
3. Log-scale growth comparison
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def cheb_trace(t, n):
    """Compute chebTrace(t, n)."""
    if n == 0:
        return 2
    if n == 1:
        return t
    a, b = 2, t
    for _ in range(2, n + 1):
        a, b = b, t * b - a
    return b


def cheb_trace_invariant(t, n):
    """Compute the Chebyshev-Trace Invariant."""
    cn = cheb_trace(t, n)
    cn1 = cheb_trace(t, n + 1)
    return cn1**2 + cn**2 - t * cn * cn1


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Chebyshev-Trace Sequences on SL₂(ℤ)',
                 fontsize=16, fontweight='bold')

    # Plot 1: Chebyshev traces for different t values
    ax1 = axes[0, 0]
    ns = list(range(12))
    for t in [2, 3, 4, 5, 7]:
        vals = [cheb_trace(t, n) for n in ns]
        ax1.plot(ns, vals, 'o-', label=f't = {t}', linewidth=2, markersize=4)
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('chebTrace(t, n)', fontsize=12)
    ax1.set_title('Chebyshev Trace Growth', fontsize=13)
    ax1.legend()
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)

    # Plot 2: The invariant Q(n) = 4 - t²
    ax2 = axes[0, 1]
    for t in [2, 3, 5, 7, 10]:
        invariants = [cheb_trace_invariant(t, n) for n in ns]
        ax2.plot(ns, invariants, 's-', label=f't = {t} (Q = {4 - t**2})',
                 linewidth=2, markersize=5)
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Invariant Q(n)', fontsize=12)
    ax2.set_title('Conserved Invariant: Q(n) = 4 - t²', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=0, color='black', linestyle='--', alpha=0.5)

    # Plot 3: Growth rate (ratio of successive terms)
    ax3 = axes[1, 0]
    ns_ratio = list(range(1, 15))
    for t in [3, 4, 5, 7, 10]:
        ratios = [cheb_trace(t, n) / max(cheb_trace(t, n - 1), 1)
                  for n in ns_ratio]
        eigenvalue = (t + math.sqrt(t**2 - 4)) / 2
        ax3.plot(ns_ratio, ratios, 'o-', label=f't = {t} (λ = {eigenvalue:.2f})',
                 linewidth=2, markersize=4)
        ax3.axhline(y=eigenvalue, linestyle=':', alpha=0.4)
    ax3.set_xlabel('n', fontsize=12)
    ax3.set_ylabel('cheb(n+1) / cheb(n)', fontsize=12)
    ax3.set_title('Growth Rate → Largest Eigenvalue', fontsize=13)
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Trace sequence values mod small primes
    ax4 = axes[1, 1]
    ns_mod = list(range(30))
    for p in [2, 3, 5, 7]:
        vals = [cheb_trace(3, n) % p for n in ns_mod]
        ax4.scatter(ns_mod, vals, label=f'mod {p}', s=20, alpha=0.7)
    ax4.set_xlabel('n', fontsize=12)
    ax4.set_ylabel('chebTrace(3, n) mod p', fontsize=12)
    ax4.set_title('Periodicity of Traces mod p (t=3)', fontsize=13)
    ax4.legend()
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_chebyshev.png', dpi=150, bbox_inches='tight')
    print("Saved viz_chebyshev.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Poincaré Disk, Farey Graph, and Critical Line

Produces plots showing:
1. The modular tessellation on the Poincaré disk
2. The Farey graph structure
3. The critical line mapping to the disk
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import cmath


def sl2_mul(a, b):
    a1, b1, c1, d1 = a
    a2, b2, c2, d2 = b
    return (a1*a2 + b1*c2, a1*b2 + b1*d2,
            c1*a2 + d1*c2, c1*b2 + d1*d2)


def sl2_inv(m):
    a, b, c, d = m
    return (d, -b, -c, a)


def sl2_trace(m):
    return m[0] + m[3]


def mobius_upper_to_disk(z):
    """Map from upper half-plane to Poincaré disk: w = (z - i)/(z + i)."""
    i = complex(0, 1)
    return (z - i) / (z + i)


def mobius_action(m, z):
    """Apply SL₂ matrix to z in the upper half-plane."""
    a, b, c, d = m
    denom = c * z + d
    if abs(denom) < 1e-12:
        return None
    return (a * z + b) / denom


def cayley_transform(s):
    return (s - 1) / (s + 1)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Hyperbolic Number Theory on the Poincaré Disk',
                 fontsize=16, fontweight='bold')

    # Plot 1: SL₂(ℤ) orbit of i on the Poincaré disk
    ax1 = axes[0]
    theta = np.linspace(0, 2*np.pi, 200)
    ax1.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

    S = (0, -1, 1, 0)
    T = (1, 1, 0, 1)
    T_inv = sl2_inv(T)
    S_inv = sl2_inv(S)
    gens = [S, T, S_inv, T_inv]

    # Generate orbit points
    i = complex(0, 1)
    current = {(1, 0, 0, 1)}
    all_mats = set(current)
    orbit_points = [mobius_upper_to_disk(i)]
    traces = [2]

    for depth in range(5):
        next_level = set()
        for g in current:
            for gen in gens:
                h = sl2_mul(g, gen)
                if h not in all_mats:
                    z = mobius_action(h, i)
                    if z is not None and z.imag > 0.01:
                        w = mobius_upper_to_disk(z)
                        if abs(w) < 0.999:
                            orbit_points.append(w)
                            traces.append(sl2_trace(h))
                            all_mats.add(h)
                            next_level.add(h)
        current = next_level

    # Color by trace type
    for w, t in zip(orbit_points, traces):
        if abs(t) < 2:
            color = 'red'  # elliptic
        elif abs(t) == 2:
            color = 'blue'  # parabolic
        else:
            color = 'green'  # hyperbolic
        ax1.plot(w.real, w.imag, 'o', color=color, markersize=3, alpha=0.6)

    ax1.set_xlim(-1.15, 1.15)
    ax1.set_ylim(-1.15, 1.15)
    ax1.set_aspect('equal')
    ax1.set_title(f'SL₂(ℤ) Orbit on Poincaré Disk\n({len(orbit_points)} points)', fontsize=12)
    ax1.set_xlabel('Re(w)')
    ax1.set_ylabel('Im(w)')

    # Legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='red',
               markersize=6, label='Elliptic (|tr|<2)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='blue',
               markersize=6, label='Parabolic (|tr|=2)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='green',
               markersize=6, label='Hyperbolic (|tr|>2)')
    ]
    ax1.legend(handles=legend_elements, fontsize=8, loc='upper right')

    # Plot 2: Farey graph (Stern-Brocot tree mediant structure)
    ax2 = axes[1]

    def stern_brocot(a, b, c, d, depth, segments):
        if depth <= 0:
            return
        med_num = a + c
        med_den = b + d
        segments.append(((a/b, c/d), (a/b, med_num/med_den)))
        segments.append(((c/d, a/b), (c/d, med_num/med_den)))
        stern_brocot(a, b, med_num, med_den, depth - 1, segments)
        stern_brocot(med_num, med_den, c, d, depth - 1, segments)

    # Draw the Farey graph as a tree
    fractions = [(0, 1)]
    queue = [(0, 1, 1, 1, 0)]
    all_fracs = {(0, 1), (1, 1)}

    def farey_tree(a, b, c, d, depth):
        if depth > 6:
            return
        med = (a + c, b + d)
        if med not in all_fracs:
            all_fracs.add(med)
            ax2.plot([a/b, med[0]/med[1]], [1.0/b, 1.0/med[1]], 'b-',
                     linewidth=0.5, alpha=0.5)
            ax2.plot([c/d, med[0]/med[1]], [1.0/d, 1.0/med[1]], 'b-',
                     linewidth=0.5, alpha=0.5)
            ax2.plot(med[0]/med[1], 1.0/med[1], 'ro', markersize=2)
            farey_tree(a, b, med[0], med[1], depth + 1)
            farey_tree(med[0], med[1], c, d, depth + 1)

    ax2.plot(0, 1, 'ko', markersize=5)
    ax2.plot(1, 1, 'ko', markersize=5)
    ax2.plot([0, 1], [1, 1], 'k-', linewidth=1)
    farey_tree(0, 1, 1, 1, 0)

    ax2.set_title('Farey Graph (Stern-Brocot Tree)', fontsize=12)
    ax2.set_xlabel('p/q')
    ax2.set_ylabel('1/q (height)')
    ax2.set_xlim(-0.05, 1.05)

    # Plot 3: Critical line mapped to disk
    ax3 = axes[2]
    ax3.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)

    ys = np.linspace(-50, 50, 500)
    ws = [cayley_transform(complex(0.5, y)) for y in ys]
    ax3.plot([w.real for w in ws], [w.imag for w in ws], 'b-',
             linewidth=2, label='Critical line Re(s)=1/2')

    # Mark first few zeta zeros
    zeta_zeros = [14.134725, 21.022040, 25.010858, 30.424876, 32.935062]
    for y0 in zeta_zeros:
        w = cayley_transform(complex(0.5, y0))
        ax3.plot(w.real, w.imag, 'r*', markersize=8)
        w_neg = cayley_transform(complex(0.5, -y0))
        ax3.plot(w_neg.real, w_neg.imag, 'r*', markersize=8)

    ax3.set_xlim(-1.15, 1.15)
    ax3.set_ylim(-1.15, 1.15)
    ax3.set_aspect('equal')
    ax3.set_title('Critical Line → Poincaré Disk\n(★ = first 5 zeta zeros)', fontsize=12)
    ax3.set_xlabel('Re(w)')
    ax3.set_ylabel('Im(w)')
    ax3.legend(fontsize=8)

    plt.tight_layout()
    plt.savefig('viz_poincare.png', dpi=150, bbox_inches='tight')
    print("Saved viz_poincare.png")


if __name__ == "__main__":
    main()
