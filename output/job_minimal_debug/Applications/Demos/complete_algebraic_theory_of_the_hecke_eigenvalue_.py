#!/usr/bin/env python3
"""
Hecke Eigenvalue Recursion: Numerical Demonstrations

Demonstrates the key identities of the Hecke eigenvalue sequence
h(n+2) = a*h(n+1) - q*h(n), h(0) = 1, h(1) = a
over integers, with verification of:
  - Cassini-Hecke identity: h(n+1)^2 - h(n+2)*h(n) = q^(n+1)
  - Addition formula: h(m+n+2) = h(m+1)*h(n+1) - q*h(m)*h(n)
  - Parity identity: h_{-a}(n) = (-1)^n * h_a(n)
  - Boundary case: h_2,1(n) = n + 1
  - Scaling: h(ca, c^2*q, n) = c^n * h(a,q,n)
  - Mod-q reduction: q | (h(n) - a^n)
"""

from algorithms import hecke_seq, hecke_companion_matrix
import numpy as np


def demo_cassini():
    """Verify the Cassini-Hecke identity for various parameters."""
    print("=" * 60)
    print("CASSINI-HECKE IDENTITY: h(n+1)^2 - h(n+2)*h(n) = q^(n+1)")
    print("=" * 60)
    test_cases = [(3, 2, "a=3, q=2"), (1, -1, "Fibonacci (a=1, q=-1)"),
                  (5, 7, "a=5, q=7"), (0, 3, "a=0, q=3")]
    for a, q, label in test_cases:
        print(f"\n  {label}:")
        h = hecke_seq(a, q, 12)
        for n in range(10):
            lhs = h[n+1]**2 - h[n+2]*h[n]
            rhs = q**(n+1)
            status = "✓" if lhs == rhs else "✗"
            print(f"    n={n:2d}: h({n+1})²-h({n+2})·h({n}) = {lhs:>12d} = q^{n+1} = {rhs:>12d}  {status}")


def demo_addition():
    """Verify the addition formula."""
    print("\n" + "=" * 60)
    print("ADDITION FORMULA: h(m+n+2) = h(m+1)*h(n+1) - q*h(m)*h(n)")
    print("=" * 60)
    a, q = 3, 5
    h = hecke_seq(a, q, 20)
    print(f"\n  a={a}, q={q}:")
    for m in range(6):
        for n in range(6):
            lhs = h[m+n+2]
            rhs = h[m+1]*h[n+1] - q*h[m]*h[n]
            status = "✓" if lhs == rhs else "✗"
            if m <= 3 and n <= 3:
                print(f"    m={m}, n={n}: h({m+n+2}) = {lhs:>10d}, "
                      f"h({m+1})*h({n+1}) - {q}*h({m})*h({n}) = {rhs:>10d}  {status}")


def demo_parity():
    """Verify the parity identity."""
    print("\n" + "=" * 60)
    print("PARITY IDENTITY: h_{-a}(n) = (-1)^n * h_a(n)")
    print("=" * 60)
    a, q = 4, 3
    h_pos = hecke_seq(a, q, 10)
    h_neg = hecke_seq(-a, q, 10)
    print(f"\n  a={a}, q={q}:")
    for n in range(10):
        expected = ((-1)**n) * h_pos[n]
        status = "✓" if h_neg[n] == expected else "✗"
        print(f"    n={n}: h_{{-{a}}}({n}) = {h_neg[n]:>10d}, "
              f"(-1)^{n} * h_{{{a}}}({n}) = {expected:>10d}  {status}")


def demo_boundary():
    """Verify the boundary Chebyshev case."""
    print("\n" + "=" * 60)
    print("BOUNDARY CHEBYSHEV: a=2, q=1 => h(n) = n+1")
    print("=" * 60)
    h = hecke_seq(2, 1, 15)
    for n in range(15):
        status = "✓" if h[n] == n + 1 else "✗"
        print(f"    h({n:2d}) = {h[n]:>4d}, expected {n+1:>4d}  {status}")


def demo_scaling():
    """Verify the scaling identity."""
    print("\n" + "=" * 60)
    print("SCALING: h(c*a, c^2*q, n) = c^n * h(a, q, n)")
    print("=" * 60)
    a, q, c = 3, 2, 5
    h_original = hecke_seq(a, q, 10)
    h_scaled = hecke_seq(c * a, c**2 * q, 10)
    print(f"\n  a={a}, q={q}, c={c}:")
    for n in range(10):
        expected = c**n * h_original[n]
        status = "✓" if h_scaled[n] == expected else "✗"
        print(f"    n={n}: h({c*a},{c**2*q},{n}) = {h_scaled[n]:>15d}, "
              f"{c}^{n} * h({a},{q},{n}) = {expected:>15d}  {status}")


def demo_mod_q():
    """Verify the mod-q reduction: q | (h(n) - a^n)."""
    print("\n" + "=" * 60)
    print("MOD-Q REDUCTION: q | (h(n) - a^n)")
    print("=" * 60)
    a, q = 7, 11
    h = hecke_seq(a, q, 12)
    print(f"\n  a={a}, q={q}:")
    for n in range(12):
        diff = h[n] - a**n
        divisible = diff % q == 0
        status = "✓" if divisible else "✗"
        print(f"    n={n:2d}: h({n})-a^{n} = {diff:>15d}, "
              f"div by q={q}? {status} (quotient {diff // q})")


def demo_companion_matrix():
    """Verify the companion matrix power formula."""
    print("\n" + "=" * 60)
    print("COMPANION MATRIX: C^(n+1)[0,0] = h(n+1)")
    print("=" * 60)
    a, q = 3, 2
    C = hecke_companion_matrix(a, q)
    h = hecke_seq(a, q, 10)
    print(f"\n  a={a}, q={q}, C = [[{a}, {-q}], [1, 0]]")
    M = np.eye(2, dtype=object)
    for n in range(8):
        M = M @ C
        entry = int(M[0, 0])
        status = "✓" if entry == h[n + 1] else "✗"
        print(f"    C^{n+1}[0,0] = {entry:>8d}, h({n+1}) = {h[n+1]:>8d}  {status}")
    print(f"\n  det(C) = {int(np.linalg.det(C.astype(float))):>4d} (should be q={q})")


def demo_fibonacci_specialization():
    """Show that a=1, q=-1 gives shifted Fibonacci numbers."""
    print("\n" + "=" * 60)
    print("FIBONACCI SPECIALIZATION: a=1, q=-1")
    print("=" * 60)
    h = hecke_seq(1, -1, 15)
    print("  The Hecke sequence h(n) with a=1, q=-1 gives:")
    print(f"  {[h[n] for n in range(15)]}")
    print("  These are F_{n+1} (Fibonacci numbers shifted by 1):")
    fibs = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610]
    print(f"  {fibs}")
    print(f"  Match: {'✓' if all(h[n] == fibs[n] for n in range(15)) else '✗'}")
    print("\n  Cassini-Hecke specializes to Fibonacci-Cassini:")
    for n in range(8):
        lhs = h[n+1]**2 - h[n+2]*h[n]
        print(f"    F_{n+2}^2 - F_{n+3}*F_{n+1} = {lhs} = (-1)^{n+1} = {(-1)**(n+1)}")


if __name__ == "__main__":
    demo_cassini()
    demo_addition()
    demo_parity()
    demo_boundary()
    demo_scaling()
    demo_mod_q()
    demo_companion_matrix()
    demo_fibonacci_specialization()


#!/usr/bin/env python3
"""
Visualization: Companion Matrix Eigenvalue Trajectories

Shows how the eigenvalues of the Hecke companion matrix C = [[a,-q],[1,0]]
trace out circles in the complex plane as a varies, illustrating
the Ramanujan bound geometrically.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def companion_eigenvalues(a, q):
    """Compute eigenvalues of [[a, -q], [1, 0]]."""
    disc = a*a - 4*q
    if disc >= 0:
        sqrt_disc = np.sqrt(disc)
        return (a + sqrt_disc) / 2, (a - sqrt_disc) / 2
    else:
        sqrt_disc = np.sqrt(-disc)
        return complex(a/2, sqrt_disc/2), complex(a/2, -sqrt_disc/2)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
    fig.suptitle('Hecke Companion Matrix: Eigenvalue Geometry', fontsize=14, fontweight='bold')

    # Panel 1: Eigenvalue trajectories as a varies
    ax = axes[0]
    q = 5
    a_range = np.linspace(-8, 8, 500)
    eig1_real, eig1_imag = [], []
    eig2_real, eig2_imag = [], []
    for a in a_range:
        e1, e2 = companion_eigenvalues(a, q)
        eig1_real.append(np.real(e1))
        eig1_imag.append(np.imag(e1))
        eig2_real.append(np.real(e2))
        eig2_imag.append(np.imag(e2))

    ax.plot(eig1_real, eig1_imag, 'b-', linewidth=1.5, label='λ₁')
    ax.plot(eig2_real, eig2_imag, 'r-', linewidth=1.5, label='λ₂')

    # Draw the circle |z| = sqrt(q)
    theta = np.linspace(0, 2*np.pi, 100)
    sq = np.sqrt(q)
    ax.plot(sq*np.cos(theta), sq*np.sin(theta), 'k--', alpha=0.4, label=f'|z|=√{q}')

    # Mark Ramanujan boundary
    ram_a = 2*np.sqrt(q)
    for a_mark in [ram_a, -ram_a]:
        e1, e2 = companion_eigenvalues(a_mark, q)
        ax.plot(np.real(e1), np.imag(e1), 'g*', markersize=12)

    ax.set_xlabel('Re(λ)')
    ax.set_ylabel('Im(λ)')
    ax.set_title(f'Eigenvalue trajectories (q={q})\nas a varies from -8 to 8')
    ax.legend(fontsize=8)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Panel 2: |eigenvalue| vs a
    ax = axes[1]
    for q, color in [(2, 'blue'), (5, 'green'), (11, 'red')]:
        a_range = np.linspace(-10, 10, 500)
        max_eig = []
        for a in a_range:
            e1, e2 = companion_eigenvalues(a, q)
            max_eig.append(max(abs(e1), abs(e2)))
        ax.plot(a_range, max_eig, color=color, label=f'q={q}')
        ram = 2*np.sqrt(q)
        ax.axvline(x=ram, color=color, linestyle=':', alpha=0.5)
        ax.axvline(x=-ram, color=color, linestyle=':', alpha=0.5)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('a (eigenvalue)')
    ax.set_ylabel('max |λ_i|')
    ax.set_title('Spectral radius vs eigenvalue\n(dashed = Ramanujan boundary)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: log|h(n)| growth rates
    ax = axes[2]
    q = 7
    N = 20
    for a in [2, 4, 6, 8]:
        h = [0] * N
        h[0] = 1
        h[1] = a
        for n in range(2, N):
            h[n] = a * h[n-1] - q * h[n-2]
        log_h = [np.log(abs(x) + 1e-15) for x in h]
        ram = "R" if a*a <= 4*q else "NR"
        ax.plot(range(N), log_h, '-o', markersize=3, label=f'a={a} ({ram})')
    # Reference lines
    ax.plot(range(N), [n * np.log(np.sqrt(q)) for n in range(N)],
            'k--', alpha=0.5, label=f'n·ln(√q) [Ramanujan growth]')
    ax.set_xlabel('n')
    ax.set_ylabel('ln|h(n)|')
    ax.set_title(f'Growth rate (q={q})\nR=Ramanujan, NR=non-Ramanujan')
    ax.legend(fontsize=7, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_companion_matrix.png', dpi=150, bbox_inches='tight')
    print("Saved viz_companion_matrix.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Hecke Eigenvalue Sequence Growth Regimes

Plots the Hecke sequence h(n) for different (a, q) parameters,
illustrating the Ramanujan vs non-Ramanujan growth dichotomy.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def hecke_seq(a, q, length):
    """Compute Hecke eigenvalue sequence."""
    if length <= 0:
        return []
    h = [0] * length
    h[0] = 1
    if length > 1:
        h[1] = a
    for n in range(2, length):
        h[n] = a * h[n-1] - q * h[n-2]
    return h


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Hecke Eigenvalue Sequence: Growth Regimes', fontsize=16, fontweight='bold')
    N = 20

    # Panel 1: Ramanujan vs non-Ramanujan for fixed q
    ax = axes[0, 0]
    q = 5
    for a, style, label in [(4, '-o', f'a=4 (|a|<2√q, Ramanujan)'),
                             (5, '-s', f'a=5 (|a|>2√q, non-Ramanujan)'),
                             (2, '-^', f'a=2 (deep Ramanujan)')]:
        h = hecke_seq(a, q, N)
        ax.semilogy(range(N), [abs(x) for x in h], style, label=label, markersize=4)
    ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('n')
    ax.set_ylabel('|h(n)| (log scale)')
    ax.set_title(f'Growth regimes (q={q})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 2: Cassini-Hecke identity verification
    ax = axes[0, 1]
    a_vals = [2, 3, 5, 7]
    q = 3
    for a in a_vals:
        h = hecke_seq(a, q, N + 2)
        cassini = [h[n+1]**2 - h[n+2]*h[n] for n in range(N)]
        expected = [q**(n+1) for n in range(N)]
        errors = [abs(c - e) for c, e in zip(cassini, expected)]
        ax.plot(range(N), errors, '-o', label=f'a={a}', markersize=3)
    ax.set_xlabel('n')
    ax.set_ylabel('|Cassini error|')
    ax.set_title(f'Cassini-Hecke identity (exact, q={q})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 1.5)

    # Panel 3: Boundary Chebyshev case
    ax = axes[1, 0]
    h_boundary = hecke_seq(2, 1, 15)
    ns = list(range(15))
    ax.plot(ns, h_boundary, 'bo-', label='h(n) with a=2, q=1', markersize=5)
    ax.plot(ns, [n + 1 for n in ns], 'r--', label='n + 1', linewidth=2)
    ax.set_xlabel('n')
    ax.set_ylabel('h(n)')
    ax.set_title('Boundary Chebyshev: h(n) = n+1')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 4: Fibonacci specialization
    ax = axes[1, 1]
    h_fib = hecke_seq(1, -1, 15)
    fibs = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610]
    ax.semilogy(range(15), h_fib, 'go-', label='Hecke(1,-1)', markersize=5)
    ax.semilogy(range(15), fibs, 'r--', label='Fibonacci F_{n+1}', linewidth=2)
    phi = (1 + np.sqrt(5)) / 2
    ax.semilogy(range(15), [phi**(n+1)/np.sqrt(5) for n in range(15)],
                'k:', label=f'φ^(n+1)/√5', alpha=0.5)
    ax.set_xlabel('n')
    ax.set_ylabel('h(n) (log scale)')
    ax.set_title('Fibonacci specialization (a=1, q=-1)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_hecke_growth.png', dpi=150, bbox_inches='tight')
    print("Saved viz_hecke_growth.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical Hecke Recursion and Ramanujan Linearization

Compares the classical Hecke eigenvalue sequence with its tropical
(min-plus) analogue, demonstrating the linearization phenomenon
in the Ramanujan regime.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def tropical_hecke_seq(a, q, length):
    """Tropical min-plus Hecke: t(0)=0, t(1)=a, t(n+2)=min(a+t(n+1), q+t(n))."""
    if length <= 0:
        return []
    t = [0.0] * length
    if length > 1:
        t[1] = a
    for n in range(2, length):
        t[n] = min(a + t[n-1], q + t[n-2])
    return t


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle('Tropical Hecke Recursion: Ramanujan Linearization', fontsize=14, fontweight='bold')
    N = 25

    # Panel 1: Tropical sequences for different a, fixed q
    ax = axes[0]
    q = 10
    for a, color in [(3, 'blue'), (5, 'green'), (8, 'orange'), (12, 'red')]:
        t = tropical_hecke_seq(a, q, N)
        ramanujan = "R" if 2*a <= q else "NR"
        ax.plot(range(N), t, '-o', color=color, markersize=3,
                label=f'a={a} ({ramanujan})')
        # Reference line n*a
        ax.plot(range(N), [n*a for n in range(N)], ':', color=color, alpha=0.4)
    ax.set_xlabel('n')
    ax.set_ylabel('t(n)')
    ax.set_title(f'Tropical Hecke (q={q})\nR=Ramanujan, NR=non-Ramanujan')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 2: Tropical Cassini defect
    ax = axes[1]
    q = 10
    for a in [3, 5, 8, 12]:
        t = tropical_hecke_seq(a, q, N + 2)
        defects = [2*t[n+1] - t[n+2] - t[n] for n in range(N)]
        ramanujan = "R" if 2*a <= q else "NR"
        ax.plot(range(N), defects, '-o', markersize=3,
                label=f'a={a} ({ramanujan})')
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('n')
    ax.set_ylabel('Tropical Cassini defect')
    ax.set_title('Cassini defect vanishes\nin Ramanujan regime')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: Phase diagram - which branch wins
    ax = axes[2]
    q_vals = np.linspace(1, 20, 40)
    a_vals = np.linspace(0.5, 15, 40)
    Q, A = np.meshgrid(q_vals, a_vals)
    # Color by: is it Ramanujan? (2a <= q)
    Z = np.where(2*A <= Q, 1, 0)
    ax.contourf(Q, A, Z, levels=[-0.5, 0.5, 1.5], colors=['#ffcccc', '#ccffcc'], alpha=0.7)
    ax.contour(Q, A, Z, levels=[0.5], colors='black', linewidths=2)
    ax.plot(q_vals, q_vals/2, 'k-', linewidth=2, label='a = q/2 (boundary)')
    ax.plot(q_vals, np.sqrt(q_vals)*2, 'r--', linewidth=1.5, label='a = 2√q (Ramanujan)')
    ax.set_xlabel('q (determinant)')
    ax.set_ylabel('a (eigenvalue)')
    ax.set_title('Phase diagram:\nGreen = Ramanujan regime')
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_tropical_hecke.png', dpi=150, bbox_inches='tight')
    print("Saved viz_tropical_hecke.png")


if __name__ == "__main__":
    main()
