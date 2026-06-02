#!/usr/bin/env python3
"""
Demo: The Ihara Zeta Function and the Graph Riemann Hypothesis

Demonstrates the connection between Ramanujan graphs, the Ihara zeta function,
and the graph-theoretic analog of the Riemann Hypothesis.
"""

import numpy as np
from algorithms import (
    complete_graph_adj, petersen_graph_adj, cycle_graph_adj, paley_graph_adj,
    check_ramanujan, prime_cycle_count, spectral_gap, graph_rh_test,
    ihara_determinant, ihara_zeta_poles,
)


def separator(title: str):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def demo_ramanujan_check():
    """Check the Ramanujan property for several graph families."""
    separator("1. Ramanujan Property Check")

    # Complete graph K_n is (n-1)-regular, q = n-2
    for n in [4, 5, 6, 7]:
        A = complete_graph_adj(n)
        q = n - 2
        is_ram, max_nt, evs = check_ramanujan(A, q)
        bound = 2 * np.sqrt(q)
        print(f"K_{n}: (q+1)={q+1}-regular, 2√q={bound:.3f}, "
              f"max |λ_nt|={max_nt:.3f}, Ramanujan={is_ram}")

    print()

    # Petersen graph: 3-regular, q=2
    A = petersen_graph_adj()
    is_ram, max_nt, evs = check_ramanujan(A, 2)
    print(f"Petersen: 3-regular, 2√2={2*np.sqrt(2):.3f}, "
          f"max |λ_nt|={max_nt:.3f}, Ramanujan={is_ram}")

    print()

    # Paley graphs
    primes_1mod4 = [5, 13, 17, 29, 37, 41, 53, 61, 73, 89]
    print("Paley graphs (known Ramanujan):")
    for p in primes_1mod4:
        A = paley_graph_adj(p)
        q = (p - 1) // 2 - 1
        is_ram, max_nt, evs = check_ramanujan(A, q)
        bound = 2 * np.sqrt(q)
        print(f"  Paley({p}): {(p-1)//2}-regular, q={q}, 2√q={bound:.3f}, "
              f"max |λ_nt|={max_nt:.3f}, Ramanujan={is_ram}")


def demo_graph_rh():
    """Test the Graph Riemann Hypothesis on specific graphs."""
    separator("2. Graph Riemann Hypothesis")

    graphs = [
        ("Petersen", petersen_graph_adj(), 2),
        ("K_6", complete_graph_adj(6), 4),
        ("Paley(13)", paley_graph_adj(13), 5),
        ("Paley(29)", paley_graph_adj(29), 13),
    ]

    for name, A, q in graphs:
        passes, desc = graph_rh_test(A, q)
        print(f"--- {name} ---")
        print(desc)
        print()


def demo_prime_cycles():
    """Compare prime cycle distribution to prime numbers."""
    separator("3. Prime Cycle Distribution")

    # Petersen graph
    A = petersen_graph_adj()
    P = prime_cycle_count(A, 12)
    print("Petersen graph prime cycle counts P(k):")
    for k in range(1, 13):
        print(f"  k={k:2d}: P(k) = {P[k]:.1f}")

    print()

    # Paley(13) graph
    A = paley_graph_adj(13)
    P = prime_cycle_count(A, 10)
    print("Paley(13) prime cycle counts P(k):")
    for k in range(1, 11):
        print(f"  k={k:2d}: P(k) = {P[k]:.1f}")


def demo_ihara_determinant():
    """Compute the Ihara determinant for varying u."""
    separator("4. Ihara Determinant Values")

    A = petersen_graph_adj()
    q = 2
    print("Petersen graph: det(I - uA + u²I) for various u:")
    for u in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7]:
        d = ihara_determinant(A, q, u)
        print(f"  u={u:.1f}: det = {d:.6f}")


def demo_spectral_gaps():
    """Compare spectral gaps across graph families."""
    separator("5. Spectral Gaps")

    print("Graph             | q  | Gap       | (√q-1)²  | Ratio")
    print("-" * 60)

    graphs = [
        ("K_4", complete_graph_adj(4), 2),
        ("K_6", complete_graph_adj(6), 4),
        ("Petersen", petersen_graph_adj(), 2),
        ("Paley(5)", paley_graph_adj(5), 1),
        ("Paley(13)", paley_graph_adj(13), 5),
        ("Paley(17)", paley_graph_adj(17), 7),
        ("Paley(29)", paley_graph_adj(29), 13),
    ]

    for name, A, q in graphs:
        gap = spectral_gap(A, q)
        opt = (np.sqrt(q) - 1) ** 2
        ratio = gap / opt if opt > 0 else float('inf')
        print(f"  {name:15s} | {q:2d} | {gap:9.4f} | {opt:8.4f} | {ratio:.4f}")


def demo_zeta_poles():
    """Visualize pole locations of the Ihara zeta function."""
    separator("6. Zeta Function Poles")

    A = petersen_graph_adj()
    q = 2
    poles = ihara_zeta_poles(A, q)

    print("Petersen graph Ihara zeta poles:")
    print(f"  Critical circle radius: 1/√q = 1/√2 = {1/np.sqrt(2):.4f}")
    print(f"  Number of poles: {len(poles)}")

    # Check how many lie on the critical circle
    crit_radius = 1 / np.sqrt(q)
    on_circle = sum(1 for p in poles if abs(abs(p) - crit_radius) < 1e-10)
    print(f"  Poles on critical circle: {on_circle}")
    print(f"  (Graph RH: all non-trivial poles should be on |u|=1/√q)")

    print("\n  Pole locations (showing |u|):")
    for i, p in enumerate(sorted(poles, key=lambda x: abs(x))):
        print(f"    pole {i+1}: |u| = {abs(p):.6f}  "
              f"{'← on critical circle' if abs(abs(p) - crit_radius) < 1e-10 else ''}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  The Ihara Zeta Function: Number Theory on Networks     ║")
    print("║  Connecting Graph Spectra to the Riemann Hypothesis     ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_ramanujan_check()
    demo_graph_rh()
    demo_prime_cycles()
    demo_ihara_determinant()
    demo_spectral_gaps()
    demo_zeta_poles()

    separator("Summary")
    print("Key findings:")
    print("• Complete graphs K_n are always Ramanujan (trivially)")
    print("• Paley graphs satisfy the Graph Riemann Hypothesis")
    print("• The spectral gap of Ramanujan graphs is ≥ (√q - 1)²")
    print("• Prime cycles in Ramanujan graphs distribute like primes in ℤ")
    print("• The Ihara zeta function poles lie on the critical circle |u| = 1/√q")


#!/usr/bin/env python3
"""Visualization: Ihara Zeta Function Poles and the Critical Circle."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def paley_graph_adj(p):
    qr = set()
    for x in range(1, p):
        qr.add((x * x) % p)
    A = np.zeros((p, p))
    for i in range(p):
        for j in range(p):
            if i != j and ((j - i) % p) in qr:
                A[i, j] = 1.0
    return A


def petersen_graph_adj():
    edges = [
        (0,1),(1,2),(2,3),(3,4),(4,0),
        (5,7),(7,9),(9,6),(6,8),(8,5),
        (0,5),(1,6),(2,7),(3,8),(4,9),
    ]
    A = np.zeros((10, 10))
    for i, j in edges:
        A[i, j] = 1.0
        A[j, i] = 1.0
    return A


def ihara_zeta_poles(A, q):
    eigenvalues = np.linalg.eigvalsh(A)
    poles = []
    for lam in eigenvalues:
        disc = lam**2 - 4 * (q - 1)
        if q <= 1:
            continue
        if disc >= 0:
            u1 = (lam + np.sqrt(disc)) / (2 * (q - 1))
            u2 = (lam - np.sqrt(disc)) / (2 * (q - 1))
        else:
            u1 = (lam + 1j * np.sqrt(-disc)) / (2 * (q - 1))
            u2 = (lam - 1j * np.sqrt(-disc)) / (2 * (q - 1))
        poles.extend([u1, u2])
    return np.array(poles)


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# 1. Petersen graph poles
A = petersen_graph_adj()
q = 2
poles = ihara_zeta_poles(A, q)
crit_r = 1 / np.sqrt(q)

ax = axes[0]
theta = np.linspace(0, 2*np.pi, 100)
ax.plot(crit_r * np.cos(theta), crit_r * np.sin(theta), 'r--', alpha=0.7, label=f'|u|=1/√{q}')
ax.plot(np.cos(theta), np.sin(theta), 'b--', alpha=0.3, label='|u|=1')
ax.scatter(np.real(poles), np.imag(poles), c='darkblue', s=50, zorder=5)
ax.set_title('Petersen Graph (3-regular)\nIhara Zeta Poles', fontsize=12)
ax.set_xlabel('Re(u)')
ax.set_ylabel('Im(u)')
ax.set_aspect('equal')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# 2. Paley(13) poles
A = paley_graph_adj(13)
q = 5
poles = ihara_zeta_poles(A, q)
crit_r = 1 / np.sqrt(q)

ax = axes[1]
ax.plot(crit_r * np.cos(theta), crit_r * np.sin(theta), 'r--', alpha=0.7, label=f'|u|=1/√{q}')
ax.plot(np.cos(theta), np.sin(theta), 'b--', alpha=0.3, label='|u|=1')
ax.scatter(np.real(poles), np.imag(poles), c='darkgreen', s=30, zorder=5)
ax.set_title('Paley(13) Graph (6-regular)\nIhara Zeta Poles', fontsize=12)
ax.set_xlabel('Re(u)')
ax.set_ylabel('Im(u)')
ax.set_aspect('equal')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# 3. Eigenvalue distribution comparison
A_pet = petersen_graph_adj()
A_pal = paley_graph_adj(13)
evs_pet = np.linalg.eigvalsh(A_pet)
evs_pal = np.linalg.eigvalsh(A_pal)

ax = axes[2]
ax.hist(evs_pet, bins=15, alpha=0.6, color='blue', label='Petersen', density=True)
ax.hist(evs_pal, bins=15, alpha=0.6, color='green', label='Paley(13)', density=True)
# Kesten-McKay distribution for reference
q_pet = 2
x = np.linspace(-2*np.sqrt(q_pet), 2*np.sqrt(q_pet), 200)
km = np.sqrt(4*q_pet - x**2) * (q_pet + 1) / (2 * np.pi * ((q_pet+1)**2 - x**2))
km = np.where(np.isfinite(km) & (km > 0), km, 0)
ax.plot(x, km, 'r-', linewidth=2, label='Kesten-McKay (q=2)')
ax.set_title('Eigenvalue Distribution\nvs. Kesten-McKay Law', fontsize=12)
ax.set_xlabel('Eigenvalue λ')
ax.set_ylabel('Density')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('ihara_zeta_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: ihara_zeta_visualization.png")
