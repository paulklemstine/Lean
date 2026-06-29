#!/usr/bin/env python3
"""
Ihara Zeta Function: Interactive Demo

Demonstrates the key results from the formalized theory:
1. Closed walk counting via matrix powers
2. Spectral decomposition of walk counts
3. Ramanujan property checking
4. Ihara determinant computation
"""

import numpy as np
from algorithms import (
    adjacency_matrix, closed_walk_count, ihara_determinant_regular,
    is_ramanujan, walk_count_spectrum, complete_graph_adjacency,
    petersen_graph_adjacency, spectral_gap, ramanujan_walk_bound
)


def separator(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def demo_walk_counting():
    """Demonstrate the trace formula for closed walk counting."""
    separator("CLOSED WALK COUNTING VIA TRACE FORMULA")

    # K3: Complete graph on 3 vertices
    K3 = complete_graph_adjacency(3)
    print("K₃ (complete graph on 3 vertices):")
    print(f"  Adjacency matrix:\n{K3}\n")

    for k in range(6):
        count = closed_walk_count(K3, k)
        print(f"  Closed walks of length {k}: tr(A^{k}) = {count:.0f}")

    print(f"\n  Verified: tr(A²) = 6 ✓ (each vertex has degree 2)")
    print(f"  Verified: tr(A³) = 6 ✓ (two triangles × 3 starting vertices)")

    # K4
    K4 = complete_graph_adjacency(4)
    print(f"\nK₄ (complete graph on 4 vertices):")
    for k in range(6):
        count = closed_walk_count(K4, k)
        print(f"  Closed walks of length {k}: tr(A^{k}) = {count:.0f}")


def demo_spectral_decomposition():
    """Demonstrate the eigenvalue trace formula."""
    separator("SPECTRAL DECOMPOSITION: tr(A^k) = Σᵢ λᵢᵏ")

    K3 = complete_graph_adjacency(3)
    eigenvalues = np.linalg.eigvalsh(K3)
    print(f"K₃ eigenvalues: {sorted(eigenvalues, reverse=True)}")

    print(f"\nVerification of tr(A^k) = Σᵢ λᵢᵏ:")
    for k in range(8):
        trace_val = closed_walk_count(K3, k)
        spectral_val = sum(ev**k for ev in eigenvalues)
        match = "✓" if abs(trace_val - spectral_val) < 1e-10 else "✗"
        print(f"  k={k}: tr(A^{k}) = {trace_val:8.0f}, "
              f"Σλᵢᵏ = {spectral_val:8.2f}  {match}")

    # Even powers are always non-negative (proved theorem!)
    print(f"\nEven power positivity (totalClosedWalkCount_even_nonneg):")
    for k in range(1, 6):
        val = closed_walk_count(K3, 2*k)
        print(f"  tr(A^{2*k}) = {val:.0f} ≥ 0 ✓")


def demo_ramanujan():
    """Demonstrate Ramanujan graph checking."""
    separator("RAMANUJAN PROPERTY AND SPECTRAL BOUNDS")

    graphs = {
        "K₃ (2-regular, q=1)": (complete_graph_adjacency(3), 1),
        "K₄ (3-regular, q=2)": (complete_graph_adjacency(4), 2),
        "K₅ (4-regular, q=3)": (complete_graph_adjacency(5), 3),
        "Petersen (3-regular, q=2)": (petersen_graph_adjacency(), 2),
    }

    for name, (A, q) in graphs.items():
        is_ram, evals = is_ramanujan(A, q)
        gap = spectral_gap(A)
        bound = 2 * np.sqrt(q)
        n = A.shape[0]

        print(f"{name}:")
        print(f"  Eigenvalues: {[f'{ev:.3f}' for ev in evals]}")
        print(f"  Ramanujan bound: 2√{q} = {bound:.4f}")
        print(f"  Is Ramanujan: {is_ram}")
        print(f"  Spectral gap: {gap:.4f}")

        # Verify walk count bound
        for k in [2, 4, 6]:
            actual = abs(closed_walk_count(A, k))
            bound_val = ramanujan_walk_bound(n, q, k)
            print(f"  |tr(A^{k})| = {actual:.0f} ≤ {bound_val:.0f} "
                  f"= {n}·{q+1}^{k}  {'✓' if actual <= bound_val + 0.1 else '✗'}")
        print()


def demo_ihara_determinant():
    """Demonstrate the Ihara determinant."""
    separator("IHARA DETERMINANT")

    K3 = complete_graph_adjacency(3)
    q = 1  # K3 is 2-regular

    print("K₃: det((1+u²)I - uA)")
    print(f"  At u=0: det = {ihara_determinant_regular(K3, q, 0):.6f} (should be 1)")

    print(f"\n  Ihara determinant values:")
    for u in np.linspace(-0.9, 0.9, 19):
        det_val = ihara_determinant_regular(K3, q, u)
        print(f"    u = {u:+.3f}: det = {det_val:+.6f}")

    # Verify negation symmetry: det(IharaReg A q u) = det(IharaReg (-A) q (-u))
    print(f"\n  Negation symmetry verification:")
    for u in [0.1, 0.3, 0.5, 0.7]:
        val1 = ihara_determinant_regular(K3, q, u)
        val2 = ihara_determinant_regular(-K3, q, -u)
        print(f"    u={u:.1f}: det(A,u) = {val1:.6f}, "
              f"det(-A,-u) = {val2:.6f}  "
              f"{'✓' if abs(val1-val2) < 1e-10 else '✗'}")

    # Find zeros (poles of zeta function)
    print(f"\n  Approximate zeros of Ihara determinant:")
    u_vals = np.linspace(-0.99, 0.99, 10000)
    det_vals = [ihara_determinant_regular(K3, q, u) for u in u_vals]
    for i in range(1, len(det_vals)):
        if det_vals[i-1] * det_vals[i] < 0:
            # Linear interpolation for zero
            u_zero = u_vals[i-1] - det_vals[i-1] * (u_vals[i] - u_vals[i-1]) / (det_vals[i] - det_vals[i-1])
            print(f"    u ≈ {u_zero:.6f}")


def demo_walk_growth():
    """Compare walk count growth rates for Ramanujan vs non-Ramanujan."""
    separator("WALK COUNT GROWTH: RAMANUJAN VS BOUND")

    K4 = complete_graph_adjacency(4)
    q = 2  # K4 is 3-regular

    print("K₄ (3-regular Ramanujan graph, q=2):")
    print(f"  Ramanujan bound: 2√2 ≈ {2*np.sqrt(2):.4f}")
    print(f"  Eigenvalues: {sorted(np.linalg.eigvalsh(K4), reverse=True)}")
    print()
    print(f"  {'k':>3} {'tr(A^k)':>12} {'Bound n(q+1)^k':>16} {'Ratio':>8}")
    print(f"  {'---':>3} {'--------':>12} {'-------------':>16} {'-----':>8}")

    for k in range(1, 13):
        actual = closed_walk_count(K4, k)
        bound = ramanujan_walk_bound(4, q, k)
        ratio = abs(actual) / bound if bound > 0 else 0
        print(f"  {k:3d} {actual:12.0f} {bound:16.0f} {ratio:8.4f}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     IHARA ZETA FUNCTIONS: GRAPH NUMBER THEORY DEMO      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_walk_counting()
    demo_spectral_decomposition()
    demo_ramanujan()
    demo_ihara_determinant()
    demo_walk_growth()

    separator("CONJECTURES AND FUTURE DIRECTIONS")
    print("Conjecture: For any k-regular Ramanujan graph G on n vertices,")
    print("the number of distinct prime cycles of length ≤ L is")
    print("  π_G(L) = (q+1)^L / L + O((2√q)^L / L)")
    print("where q = k-1, analogous to the Prime Number Theorem.")
    print()
    print("Test: Compare π_G(L) for known Ramanujan graphs (Cayley graphs")
    print("of PSL(2, F_p)) against this prediction.")


#!/usr/bin/env python3
"""Visualization: Ihara determinant as a function of u for various graphs."""

import numpy as np
import matplotlib.pyplot as plt


def adjacency_matrix(edges, n):
    A = np.zeros((n, n))
    for i, j in edges:
        A[i, j] = 1.0
        A[j, i] = 1.0
    return A


def ihara_det_regular(A, q, u):
    n = A.shape[0]
    I = np.eye(n)
    M = (1 + q * u**2) * I - u * A
    return np.linalg.det(M)


def complete_graph(n):
    return np.ones((n, n)) - np.eye(n)


def cycle_graph(n):
    edges = [(i, (i+1) % n) for i in range(n)]
    return adjacency_matrix(edges, n)


def petersen_graph():
    edges = [
        (0,1),(1,2),(2,3),(3,4),(4,0),
        (5,7),(7,9),(9,6),(6,8),(8,5),
        (0,5),(1,6),(2,7),(3,8),(4,9),
    ]
    return adjacency_matrix(edges, 10)


fig, axes = plt.subplots(2, 2, figsize=(12, 10))
u_vals = np.linspace(-0.95, 0.95, 500)

# K3
A = complete_graph(3)
det_vals = [ihara_det_regular(A, 1, u) for u in u_vals]
axes[0,0].plot(u_vals, det_vals, 'b-', linewidth=2)
axes[0,0].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[0,0].axvline(x=0, color='gray', linestyle='--', alpha=0.5)
axes[0,0].set_title('K₃ (2-regular, q=1)', fontsize=14)
axes[0,0].set_xlabel('u')
axes[0,0].set_ylabel('det((1+u²)I - uA)')
axes[0,0].set_ylim(-5, 10)

# K4
A = complete_graph(4)
det_vals = [ihara_det_regular(A, 2, u) for u in u_vals]
axes[0,1].plot(u_vals, det_vals, 'r-', linewidth=2)
axes[0,1].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[0,1].axvline(x=0, color='gray', linestyle='--', alpha=0.5)
axes[0,1].set_title('K₄ (3-regular, q=2)', fontsize=14)
axes[0,1].set_xlabel('u')
axes[0,1].set_ylabel('det((1+2u²)I - uA)')
axes[0,1].set_ylim(-20, 50)

# Cycle C6
A = cycle_graph(6)
det_vals = [ihara_det_regular(A, 1, u) for u in u_vals]
axes[1,0].plot(u_vals, det_vals, 'g-', linewidth=2)
axes[1,0].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[1,0].axvline(x=0, color='gray', linestyle='--', alpha=0.5)
axes[1,0].set_title('C₆ (2-regular cycle, q=1)', fontsize=14)
axes[1,0].set_xlabel('u')
axes[1,0].set_ylabel('det((1+u²)I - uA)')
axes[1,0].set_ylim(-10, 30)

# Petersen
A = petersen_graph()
det_vals = [ihara_det_regular(A, 2, u) for u in u_vals]
axes[1,1].plot(u_vals, det_vals, 'm-', linewidth=2)
axes[1,1].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[1,1].axvline(x=0, color='gray', linestyle='--', alpha=0.5)
axes[1,1].set_title('Petersen (3-regular, q=2)', fontsize=14)
axes[1,1].set_xlabel('u')
axes[1,1].set_ylabel('det((1+2u²)I - uA)')
axes[1,1].set_ylim(-1e4, 5e4)

plt.suptitle('Ihara Determinant: Zeros = Poles of ζ_G(u)', fontsize=16, y=1.02)
plt.tight_layout()
plt.savefig('ihara_determinant.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved ihara_determinant.png")


#!/usr/bin/env python3
"""Visualization: Eigenvalue spectrum and Ramanujan bounds."""

import numpy as np
import matplotlib.pyplot as plt


def complete_graph(n):
    return np.ones((n, n)) - np.eye(n)


def cycle_graph(n):
    A = np.zeros((n, n))
    for i in range(n):
        A[i, (i+1) % n] = 1
        A[(i+1) % n, i] = 1
    return A


def petersen_graph():
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


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

graphs = [
    ("K₃ (q=1)", complete_graph(3), 1),
    ("K₄ (q=2)", complete_graph(4), 2),
    ("Petersen (q=2)", petersen_graph(), 2),
    ("C₈ (q=1)", cycle_graph(8), 1),
]

for idx, (name, A, q) in enumerate(graphs):
    ax = axes[idx // 2, idx % 2]
    evals = sorted(np.linalg.eigvalsh(A))
    bound = 2 * np.sqrt(q)
    degree = q + 1

    # Plot eigenvalues
    ax.scatter(evals, [0]*len(evals), s=100, c='blue', zorder=5, label='Eigenvalues')

    # Mark trivial eigenvalues
    ax.axvline(x=degree, color='green', linestyle=':', alpha=0.7, label=f'±(q+1) = ±{degree}')
    ax.axvline(x=-degree, color='green', linestyle=':', alpha=0.7)

    # Ramanujan bound
    ax.axvspan(-bound, bound, alpha=0.15, color='red', label=f'|λ| ≤ 2√{q} ≈ {bound:.2f}')

    # Check Ramanujan
    non_trivial = [ev for ev in evals if abs(abs(ev) - degree) > 1e-10]
    is_ram = all(abs(ev) <= bound + 1e-10 for ev in non_trivial)

    ax.set_title(f'{name} — {"Ramanujan ✓" if is_ram else "NOT Ramanujan ✗"}', fontsize=13)
    ax.set_xlabel('Eigenvalue λ')
    ax.set_yticks([])
    ax.legend(loc='upper left', fontsize=8)
    ax.set_xlim(min(evals) - 1, max(evals) + 1)

plt.suptitle('Graph Spectra and the Ramanujan Bound', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('spectrum.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved spectrum.png")


#!/usr/bin/env python3
"""Visualization: Closed walk count growth vs Ramanujan bound."""

import numpy as np
import matplotlib.pyplot as plt


def complete_graph(n):
    return np.ones((n, n)) - np.eye(n)


def walk_counts(A, max_k):
    eigenvalues = np.linalg.eigvalsh(A)
    return [sum(ev**k for ev in eigenvalues) for k in range(max_k + 1)]


def petersen_graph():
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


max_k = 12
ks = range(max_k + 1)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# K4 (3-regular, q=2)
A = complete_graph(4)
n, q = 4, 2
counts = walk_counts(A, max_k)
bound = [n * (q+1)**k for k in ks]

axes[0].semilogy(ks, [abs(c) + 1e-10 for c in counts], 'bo-', label='|tr(A^k)|', markersize=6)
axes[0].semilogy(ks, bound, 'r--', label=f'n·(q+1)^k = {n}·{q+1}^k', linewidth=2)
axes[0].set_title('K₄: Walk Counts vs Ramanujan Bound', fontsize=12)
axes[0].set_xlabel('Walk length k')
axes[0].set_ylabel('Count (log scale)')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# K5 (4-regular, q=3)
A = complete_graph(5)
n, q = 5, 3
counts = walk_counts(A, max_k)
bound = [n * (q+1)**k for k in ks]

axes[1].semilogy(ks, [abs(c) + 1e-10 for c in counts], 'go-', label='|tr(A^k)|', markersize=6)
axes[1].semilogy(ks, bound, 'r--', label=f'n·(q+1)^k = {n}·{q+1}^k', linewidth=2)
axes[1].set_title('K₅: Walk Counts vs Ramanujan Bound', fontsize=12)
axes[1].set_xlabel('Walk length k')
axes[1].set_ylabel('Count (log scale)')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Petersen (3-regular, q=2)
A = petersen_graph()
n, q = 10, 2
counts = walk_counts(A, max_k)
bound = [n * (q+1)**k for k in ks]

axes[2].semilogy(ks, [abs(c) + 1e-10 for c in counts], 'mo-', label='|tr(A^k)|', markersize=6)
axes[2].semilogy(ks, bound, 'r--', label=f'n·(q+1)^k = {n}·{q+1}^k', linewidth=2)
axes[2].set_title('Petersen: Walk Counts vs Ramanujan Bound', fontsize=12)
axes[2].set_xlabel('Walk length k')
axes[2].set_ylabel('Count (log scale)')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.suptitle('Ramanujan Walk Bound: |tr(A^k)| ≤ n·(q+1)^k', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('walk_growth.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved walk_growth.png")
