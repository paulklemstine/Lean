#!/usr/bin/env python3
"""
Baker-Norine Theory: Numerical Demonstrations

Demonstrates chip-firing, divisor rank computation, and the Riemann-Roch
theorem on small graphs.
"""

import numpy as np
from itertools import combinations, product
from typing import Dict, List, Tuple, Set, Optional


def adjacency_matrix(n: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Build adjacency matrix from edge list."""
    A = np.zeros((n, n), dtype=int)
    for u, v in edges:
        A[u][v] = 1
        A[v][u] = 1
    return A


def laplacian_matrix(A: np.ndarray) -> np.ndarray:
    """Compute the graph Laplacian L = D - A."""
    D = np.diag(A.sum(axis=1))
    return D - A


def complete_graph_edges(n: int) -> List[Tuple[int, int]]:
    """All edges of the complete graph K_n."""
    return list(combinations(range(n), 2))


def cycle_graph_edges(n: int) -> List[Tuple[int, int]]:
    """All edges of the cycle graph C_n."""
    return [(i, (i + 1) % n) for i in range(n)]


def graph_genus(n: int, edges: List[Tuple[int, int]]) -> int:
    """Genus g = |E| - |V| + 1."""
    return len(edges) - n + 1


def canonical_divisor(A: np.ndarray) -> np.ndarray:
    """K_G(v) = deg(v) - 2."""
    return A.sum(axis=1) - 2


def chip_fire(A: np.ndarray, D: np.ndarray, q: int) -> np.ndarray:
    """Fire vertex q: sends one chip to each neighbor."""
    D_new = D.copy()
    degree = A[q].sum()
    D_new[q] -= degree
    for v in range(len(D)):
        if A[q][v] == 1:
            D_new[v] += 1
    return D_new


def is_effective(D: np.ndarray) -> bool:
    """Check if all values are >= 0."""
    return all(d >= 0 for d in D)


def dhar_burning(A: np.ndarray, D: np.ndarray, q: int) -> Tuple[bool, Set[int]]:
    """
    Dhar's burning algorithm.
    Returns (all_burned, unburned_set).
    A vertex v burns if its number of burning neighbors exceeds D(v).
    If unburned_set is nonempty, firing it moves toward q-reduced form.
    """
    n = len(D)
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if v in burned:
                continue
            burned_neighbors = sum(1 for w in range(n) if A[v][w] == 1 and w in burned)
            if D[v] < burned_neighbors:
                burned.add(v)
                changed = True
    unburned = set(range(n)) - burned
    return len(unburned) == 0, unburned


def fire_subset(A: np.ndarray, D: np.ndarray, S: Set[int]) -> np.ndarray:
    """Fire all vertices in subset S simultaneously.
    Each v in S sends one chip along each edge to its neighbor."""
    n = len(D)
    D_new = D.copy()
    for v in S:
        deg_v = int(A[v].sum())
        D_new[v] -= deg_v
        for w in range(n):
            if A[v][w] == 1:
                D_new[w] += 1
    return D_new

def q_reduce(A: np.ndarray, D: np.ndarray, q: int, max_iter: int = 10000) -> np.ndarray:
    """Find the q-reduced divisor equivalent to D.
    
    First make D(v) >= 0 for all v != q by reverse-firing vertices,
    then use Dhar's algorithm to reach the unique q-reduced form.
    """
    n = len(D)
    D_cur = D.copy()
    # Phase 1: make all non-q values non-negative by reverse-firing
    for _ in range(max_iter):
        found_neg = False
        for v in range(n):
            if v == q:
                continue
            if D_cur[v] < 0:
                # Reverse-fire v (anti-fire): v receives from neighbors
                deg_v = int(A[v].sum())
                D_cur[v] += deg_v
                for w in range(n):
                    if A[v][w] == 1:
                        D_cur[w] -= 1
                found_neg = True
                break
        if not found_neg:
            break
    # Phase 2: Dhar's burning to reach q-reduced form
    for _ in range(max_iter):
        all_burned, unburned = dhar_burning(A, D_cur, q)
        if all_burned:
            return D_cur
        D_cur = fire_subset(A, D_cur, unburned)
    return D_cur


def divisor_rank(A: np.ndarray, D: np.ndarray, q: int = 0) -> int:
    """
    Compute the rank of divisor D.
    r(D) = max k such that for all effective E with deg(E) = k,
    D - E is linearly equivalent to an effective divisor.
    r(D) = -1 if D is not equivalent to any effective divisor.
    
    Uses the q-reduced form: r(D) = D_0(q) where D_0 is the
    q-reduced representative of D (Baker-Norine, Prop 3.1).
    """
    D_red = q_reduce(A, D, q)
    if D_red[q] < 0:
        return -1
    return int(D_red[q])


def verify_riemann_roch(A: np.ndarray, D: np.ndarray, q: int = 0) -> dict:
    """Verify the Baker-Norine Riemann-Roch theorem for divisor D."""
    n = len(D)
    edges = [(i, j) for i in range(n) for j in range(i + 1, n) if A[i][j] == 1]
    g = graph_genus(n, edges)
    K = canonical_divisor(A)

    r_D = divisor_rank(A, D, q)
    K_minus_D = K - D
    r_KD = divisor_rank(A, K_minus_D, q)
    deg_D = int(D.sum())

    lhs = r_D - r_KD
    rhs = deg_D - g + 1

    return {
        "D": D.tolist(),
        "K_G": K.tolist(),
        "K_G - D": K_minus_D.tolist(),
        "deg(D)": deg_D,
        "genus": g,
        "r(D)": r_D,
        "r(K-D)": r_KD,
        "LHS = r(D) - r(K-D)": lhs,
        "RHS = deg(D) - g + 1": rhs,
        "Riemann-Roch holds": lhs == rhs,
    }


def main():
    print("=" * 70)
    print("BAKER-NORINE THEORY: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # --- Demo 1: Chip-firing on K4 ---
    print("\n--- Demo 1: Chip-Firing on K₄ ---")
    n = 4
    edges = complete_graph_edges(n)
    A = adjacency_matrix(n, edges)
    g = graph_genus(n, edges)
    K = canonical_divisor(A)

    print(f"Complete graph K₄: {n} vertices, {len(edges)} edges")
    print(f"Genus: g = {g}")
    print(f"Canonical divisor K_G = {K.tolist()}")
    print(f"deg(K_G) = {K.sum()} (should be {2*g - 2})")
    assert K.sum() == 2 * g - 2, "deg(K_G) ≠ 2g-2!"

    D = np.array([5, -1, 0, 2])
    print(f"\nStarting divisor D = {D.tolist()}, deg(D) = {D.sum()}")

    D1 = chip_fire(A, D, 0)
    print(f"After firing vertex 0: D' = {D1.tolist()}, deg(D') = {D1.sum()}")
    assert D.sum() == D1.sum(), "Degree changed!"
    print("✓ Degree conserved under chip-firing")

    # --- Demo 2: Genus of Complete Graphs ---
    print("\n--- Demo 2: Genus of Complete Graphs ---")
    for n in range(2, 8):
        edges = complete_graph_edges(n)
        g = graph_genus(n, edges)
        expected = (n - 1) * (n - 2) // 2
        status = "✓" if g == expected else "✗"
        print(f"  K_{n}: g = {g}, (n-1)(n-2)/2 = {expected} {status}")

    # --- Demo 3: Q-Reduced Divisors ---
    print("\n--- Demo 3: Q-Reduced Divisors on C₅ ---")
    n = 5
    edges = cycle_graph_edges(n)
    A = adjacency_matrix(n, edges)
    g = graph_genus(n, edges)
    print(f"Cycle C₅: genus = {g}")

    D = np.array([3, -2, 1, 0, -1])
    print(f"Divisor D = {D.tolist()}, deg(D) = {D.sum()}")
    D_red = q_reduce(A, D, q=0)
    print(f"Q-reduced form (q=0): D₀ = {D_red.tolist()}")
    print(f"D₀(q) = {D_red[0]}, rank = {divisor_rank(A, D, q=0)}")

    # --- Demo 4: Riemann-Roch Verification ---
    print("\n--- Demo 4: Riemann-Roch Verification ---")

    # Test on K4
    print("\n  On K₄ (genus 3):")
    n = 4
    A = adjacency_matrix(n, complete_graph_edges(n))
    test_divisors = [
        np.array([3, 0, 0, 0]),
        np.array([2, 1, 0, 0]),
        np.array([1, 1, 1, 0]),
        np.array([5, -1, 0, 2]),
        np.array([0, 0, 0, 0]),
    ]
    all_pass = True
    for D in test_divisors:
        result = verify_riemann_roch(A, D)
        status = "✓" if result["Riemann-Roch holds"] else "✗"
        if not result["Riemann-Roch holds"]:
            all_pass = False
        print(
            f"    D={result['D']}: r(D)={result['r(D)']}, "
            f"r(K-D)={result['r(K-D)']}, "
            f"LHS={result['LHS = r(D) - r(K-D)']}, RHS={result['RHS = deg(D) - g + 1']} {status}"
        )
    if all_pass:
        print("  ✓ All Riemann-Roch checks passed on K₄!")

    # Test on C5
    print("\n  On C₅ (genus 1):")
    n = 5
    A = adjacency_matrix(n, cycle_graph_edges(n))
    test_divisors = [
        np.array([2, 0, 0, 0, 0]),
        np.array([1, 1, 0, 0, 0]),
        np.array([0, 0, 0, 0, 0]),
        np.array([3, -1, 0, 0, 0]),
    ]
    all_pass = True
    for D in test_divisors:
        result = verify_riemann_roch(A, D)
        status = "✓" if result["Riemann-Roch holds"] else "✗"
        if not result["Riemann-Roch holds"]:
            all_pass = False
        print(
            f"    D={result['D']}: r(D)={result['r(D)']}, "
            f"r(K-D)={result['r(K-D)']}, "
            f"LHS={result['LHS = r(D) - r(K-D)']}, RHS={result['RHS = deg(D) - g + 1']} {status}"
        )
    if all_pass:
        print("  ✓ All Riemann-Roch checks passed on C₅!")

    # --- Demo 5: Laplacian Lattice ---
    print("\n--- Demo 5: Laplacian Lattice Properties ---")
    n = 3
    A = adjacency_matrix(n, complete_graph_edges(n))
    L = laplacian_matrix(A)
    print(f"Laplacian of K₃:")
    print(L)
    print(f"Row sums: {L.sum(axis=1)} (should be all zeros)")
    print(f"Kernel: constant vectors (nullity = 1)")

    # Reduced Laplacian
    L_red = L[1:, 1:]
    det = int(round(np.linalg.det(L_red)))
    print(f"det(reduced Laplacian) = {det}")
    print(f"Number of spanning trees of K₃ = {det} (Cayley: 3^1 = 3)")

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Chip-Firing Dynamics on a Graph

Creates a matplotlib animation showing chip-firing on a small graph,
with the conservation of degree highlighted.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations


def complete_graph(n):
    A = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
    return A


def chip_fire(A, D, q):
    D_new = D.copy()
    deg = int(A[q].sum())
    D_new[q] -= deg
    for v in range(len(D)):
        if A[q][v] == 1:
            D_new[v] += 1
    return D_new


def draw_graph_state(ax, positions, A, D, title="", fired_vertex=None):
    """Draw the graph with chip counts at each vertex."""
    ax.clear()
    n = len(D)

    # Draw edges
    for i in range(n):
        for j in range(i + 1, n):
            if A[i][j] == 1:
                ax.plot(
                    [positions[i][0], positions[j][0]],
                    [positions[i][1], positions[j][1]],
                    "gray", linewidth=1, zorder=1
                )

    # Draw vertices
    for i in range(n):
        color = "gold" if i == fired_vertex else ("lightblue" if D[i] >= 0 else "salmon")
        size = max(800, 200 + abs(D[i]) * 150)
        ax.scatter(*positions[i], s=size, c=color, edgecolors="black",
                   linewidth=2, zorder=2)
        ax.annotate(
            f"v{i}\n{D[i]} chips",
            positions[i], ha="center", va="center",
            fontsize=9, fontweight="bold", zorder=3
        )

    ax.set_title(title, fontsize=13, fontweight="bold")
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect("equal")
    ax.axis("off")


def main():
    n = 5
    A = complete_graph(n)
    g = n * (n - 1) // 2 - n + 1
    K = A.sum(axis=1) - 2

    # Vertex positions (pentagon)
    angles = [2 * np.pi * i / n - np.pi / 2 for i in range(n)]
    positions = [(np.cos(a), np.sin(a)) for a in angles]

    # Initial divisor
    D = np.array([7, -1, 0, 2, -2])

    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle(
        f"Chip-Firing on K₅ (genus = {g})\n"
        f"Canonical divisor K_G = {K.tolist()}, deg(K_G) = {K.sum()} = 2g−2 = {2*g-2}",
        fontsize=14, fontweight="bold"
    )

    # Step 0: Initial state
    draw_graph_state(axes[0, 0], positions, A, D,
                     f"Step 0: D = {D.tolist()}\ndeg(D) = {D.sum()}")

    # Steps 1-5: Fire vertices
    firing_order = [0, 3, 1, 2, 4]
    D_cur = D.copy()
    for step, q in enumerate(firing_order):
        D_cur = chip_fire(A, D_cur, q)
        row, col = divmod(step + 1, 3)
        draw_graph_state(axes[row, col], positions, A, D_cur,
                         f"Step {step+1}: Fire v{q}\ndeg = {D_cur.sum()}")

    plt.tight_layout()
    plt.savefig("chipfiring_dynamics.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved chipfiring_dynamics.png")

    # Second figure: genus of complete graphs
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    ns = list(range(2, 15))
    genera = [(n - 1) * (n - 2) // 2 for n in ns]
    edges = [n * (n - 1) // 2 for n in ns]

    ax1.bar(ns, genera, color="steelblue", edgecolor="black")
    ax1.set_xlabel("n (number of vertices)", fontsize=12)
    ax1.set_ylabel("Genus g(K_n)", fontsize=12)
    ax1.set_title("Genus of Complete Graphs K_n\ng = (n−1)(n−2)/2", fontsize=13, fontweight="bold")
    for i, (x, y) in enumerate(zip(ns, genera)):
        ax1.annotate(str(y), (x, y + 0.5), ha="center", fontsize=8)

    # Canonical divisor values
    K_values = [n - 3 for n in ns]
    ax2.bar(ns, K_values, color="coral", edgecolor="black")
    ax2.set_xlabel("n (number of vertices)", fontsize=12)
    ax2.set_ylabel("K_{K_n}(v) = n − 3", fontsize=12)
    ax2.set_title("Canonical Divisor on K_n\nK_{K_n}(v) = n − 3 (uniform)", fontsize=13, fontweight="bold")
    ax2.axhline(y=0, color="black", linewidth=0.5)

    plt.tight_layout()
    plt.savefig("genus_canonical.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved genus_canonical.png")

    # Third figure: Laplacian spectrum
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    for n in [3, 4, 5, 6]:
        A = complete_graph(n)
        L = np.diag(A.sum(axis=1)) - A
        eigenvalues = sorted(np.linalg.eigvalsh(L))
        ax.plot(range(n), eigenvalues, "o-", label=f"K_{n}", markersize=8)

    ax.set_xlabel("Index", fontsize=12)
    ax.set_ylabel("Eigenvalue", fontsize=12)
    ax.set_title("Laplacian Spectrum of Complete Graphs\n(Eigenvalue 0 has multiplicity 1 for connected graphs)",
                 fontsize=13, fontweight="bold")
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("laplacian_spectrum.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved laplacian_spectrum.png")


if __name__ == "__main__":
    main()
