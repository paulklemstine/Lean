"""
Applications of Torsion-Aware Tropical Morse Theory.

Demonstrates real-world applications of the integer simplex insertion
trichotomy in quantum error correction, materials science, and
topological data analysis.
"""

import numpy as np
from algorithms import (
    SimplicialComplex, SimplexInsertionEvent, smith_normal_form,
    extract_torsion_spectrum, classify_insertion_event, TorsionSpectrum,
    compute_homology_Z
)
import random


# ============================================================
# Application 1: CSS Quantum Error Correcting Codes
# ============================================================

def css_code_analysis():
    """
    Analyze how simplex insertions affect CSS-type quantum codes.

    In a CSS code built from a chain complex C_2 → C_1 → C_0:
    - X-stabilizers come from rows of ∂_2
    - Z-stabilizers come from columns of ∂_1^T
    - Logical operators correspond to homology classes
    - Torsion in H_1 creates degenerate constraint sectors
    """
    print("=" * 70)
    print("APPLICATION 1: CSS Quantum Code Degeneracy Analysis")
    print("=" * 70)

    # Build a surface code on a small torus-like complex
    K = SimplicialComplex(6)

    # Complete 1-skeleton
    for i in range(6):
        for j in range(i + 1, 6):
            K.simplices.setdefault(1, set()).add(frozenset({i, j}))

    print("\nBase complex: K₆ (complete graph on 6 vertices)")
    rank, ts = K.homology(1)
    code_dim = rank  # Logical qubits ≈ β₁
    degeneracy = ts.mass
    print(f"  H₁(K; ℤ) = ℤ^{rank} ⊕ {ts}")
    print(f"  Logical qubits (free rank): {code_dim}")
    print(f"  Torsion degeneracy: {degeneracy}")

    # Insert triangles and track code properties
    triangles_order = []
    for i in range(6):
        for j in range(i + 1, 6):
            for k in range(j + 1, 6):
                triangles_order.append(frozenset({i, j, k}))
    random.shuffle(triangles_order)

    print(f"\nInserting {len(triangles_order)} triangles in random order:")
    print(f"{'Step':>4} | {'Event':>18} | {'β₁':>3} | {'Torsion':>20} | {'Mass':>6} | {'Comment'}")
    print("-" * 80)

    for idx, tri in enumerate(triangles_order[:10]):
        old_rank, old_ts = K.homology(1)
        event = K.add_simplex(tri)
        new_rank, new_ts = K.homology(1)

        comment = ""
        if event == SimplexInsertionEvent.CHANGE_TORSION:
            comment = "⚠ Torsion event!"
        elif event == SimplexInsertionEvent.KILL_FREE:
            comment = "Logical qubit lost"

        print(f"{idx + 1:4d} | {event.name:>18s} | {new_rank:3d} | {str(new_ts):>20s} | "
              f"{new_ts.mass:6d} | {comment}")

    final_rank, final_ts = K.homology(1)
    print(f"\nFinal code: {final_rank} logical qubits, torsion mass = {final_ts.mass}")


# ============================================================
# Application 2: Topological Data Analysis with Torsion
# ============================================================

def tda_torsion_analysis():
    """
    Torsion-sensitive topological data analysis.

    Standard TDA (persistent homology) works over fields and misses torsion.
    Integer homology reveals additional structure in point cloud data.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Torsion-Sensitive Topological Data Analysis")
    print("=" * 70)

    # Simulate building a Vietoris-Rips complex incrementally
    n_points = 8

    # Generate points on a projective-plane-like structure
    np.random.seed(42)

    K = SimplicialComplex(n_points)

    # Add edges in order of "distance"
    edges = []
    for i in range(n_points):
        for j in range(i + 1, n_points):
            dist = random.random()
            edges.append((dist, frozenset({i, j})))
    edges.sort()

    print(f"\nBuilding Rips complex on {n_points} points")
    print(f"{'Threshold':>10} | {'Edge':>10} | {'β₀':>3} | {'β₁':>3} | {'Torsion H₁':>15}")
    print("-" * 55)

    for dist, edge in edges:
        K.simplices.setdefault(1, set()).add(edge)

        # Check if any new triangles are formed
        verts = list(edge)
        for v in range(n_points):
            if v not in edge:
                tri = frozenset({verts[0], verts[1], v})
                # Check if all edges of tri are present
                edges_present = all(
                    frozenset({a, b}) in K.simplices.get(1, set())
                    for a in tri for b in tri if a < b
                )
                if edges_present and tri not in K.simplices.get(2, set()):
                    K.simplices.setdefault(2, set()).add(tri)

        rank0, _ = K.homology(0)
        rank1, ts1 = K.homology(1)

        if ts1.factors:
            print(f"{dist:10.4f} | {set(edge)} | {rank0:3d} | {rank1:3d} | {ts1}")

    final_r0, _ = K.homology(0)
    final_r1, final_ts = K.homology(1)
    print(f"\nFinal: β₀ = {final_r0}, β₁ = {final_r1}, torsion = {final_ts}")


# ============================================================
# Application 3: Crystallographic Defect Detection
# ============================================================

def defect_detection():
    """
    Model crystallographic defects via torsion in cell-complex homology.

    In a crystal lattice modeled as a simplicial complex:
    - Torsion in H₁ ↔ screw dislocations
    - Torsion in H₂ ↔ point defects with topological charge
    - Torsion events from simplex insertion ↔ defect creation/annihilation
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Crystallographic Defect Modeling")
    print("=" * 70)

    # Build a 2D triangular lattice patch
    n = 4  # 4×4 grid
    K = SimplicialComplex(n * n)

    def idx(i, j):
        return i * n + j

    # Add edges for triangular lattice
    for i in range(n):
        for j in range(n):
            if j + 1 < n:
                K.simplices.setdefault(1, set()).add(frozenset({idx(i, j), idx(i, j + 1)}))
            if i + 1 < n:
                K.simplices.setdefault(1, set()).add(frozenset({idx(i, j), idx(i + 1, j)}))
            if i + 1 < n and j + 1 < n:
                K.simplices.setdefault(1, set()).add(frozenset({idx(i, j), idx(i + 1, j + 1)}))

    print(f"\nTriangular lattice: {n}×{n} = {n*n} vertices")
    rank1, ts1 = K.homology(1)
    print(f"Initial H₁ = ℤ^{rank1} ⊕ {ts1}")
    print(f"Defect count (torsion factors): {len(ts1.factors)}")

    # Fill in triangles to create a "perfect crystal"
    print("\nFilling triangles (crystal formation):")
    defect_events = 0
    for i in range(n - 1):
        for j in range(n - 1):
            # Upper triangle
            tri1 = frozenset({idx(i, j), idx(i, j + 1), idx(i + 1, j + 1)})
            # Lower triangle
            tri2 = frozenset({idx(i, j), idx(i + 1, j), idx(i + 1, j + 1)})

            for tri in [tri1, tri2]:
                # Check edges exist
                verts = list(tri)
                edges_ok = all(
                    frozenset({a, b}) in K.simplices.get(1, set())
                    for a in tri for b in tri if a < b
                )
                if edges_ok:
                    event = K.add_simplex(tri)
                    if event == SimplexInsertionEvent.CHANGE_TORSION:
                        defect_events += 1
                        _, ts_now = K.homology(1)
                        print(f"  Defect event at triangle {set(tri)}: {ts_now}")

    final_rank, final_ts = K.homology(1)
    print(f"\nFinal crystal: H₁ = ℤ^{final_rank} ⊕ {final_ts}")
    print(f"Total defect-type events: {defect_events}")
    print(f"Residual defect invariant (torsion mass): {final_ts.mass}")


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)

    css_code_analysis()
    tda_torsion_analysis()
    defect_detection()

    print("\n" + "=" * 70)
    print("All applications complete.")
    print("=" * 70)


"""
Demo: Torsion-Aware Tropical Morse Theory

Interactive demonstration of the integer simplex insertion trichotomy.
Generates finite simplicial complexes, inserts simplices one by one,
computes H_*(K; ℤ) via Smith normal form, and classifies each event.

Includes random experiments testing the Single-Factor Torsion Pulse Conjecture.
"""

import numpy as np
from algorithms import (
    SimplicialComplex, SimplexInsertionEvent, smith_normal_form,
    extract_torsion_spectrum, classify_insertion_event, TorsionSpectrum
)
import random


def demo_triangle_insertion():
    """Demonstrate the trichotomy with explicit small examples."""
    print("=" * 70)
    print("DEMO 1: Triangle Insertion Trichotomy")
    print("=" * 70)

    # Build a complex: vertices 0,1,2,3 with edges forming a square + diagonal
    K = SimplicialComplex(4)

    # Add edges one by one
    edges = [
        frozenset({0, 1}), frozenset({1, 2}), frozenset({2, 3}),
        frozenset({0, 3}), frozenset({0, 2})
    ]

    print("\nStep 1: Building 1-skeleton (edges)")
    for e in edges:
        K.simplices.setdefault(1, set()).add(e)
        rank, ts = K.homology(1)
        print(f"  Added edge {set(e)}: H₁ = ℤ^{rank} ⊕ {ts}")

    # Now insert triangles
    print("\nStep 2: Inserting 2-simplices (triangles)")
    triangles = [frozenset({0, 1, 2}), frozenset({0, 2, 3})]

    for tri in triangles:
        old_rank, old_ts = K.homology(1)
        event = K.add_simplex(tri)
        new_rank, new_ts = K.homology(1)
        print(f"\n  Inserted triangle {set(tri)}:")
        print(f"    Event type: {event.name}")
        print(f"    H₁ before: ℤ^{old_rank} ⊕ {old_ts}")
        print(f"    H₁ after:  ℤ^{new_rank} ⊕ {new_ts}")


def demo_torsion_creation():
    """Demonstrate torsion creation from non-primitive boundary."""
    print("\n" + "=" * 70)
    print("DEMO 2: Torsion Creation via Saturation Defect")
    print("=" * 70)

    # Direct matrix example: boundary matrix with (2,0) and new vector (1,0)
    print("\nMatrix model: B = [2; 0], new column v = [1; 0]")
    M = np.array([[2], [0]], dtype=np.int64)
    v = np.array([1, 0], dtype=np.int64)

    event, rc = classify_insertion_event(M, v)
    print(f"Event: {event.name}")
    print(f"Δβ_d = {rc.delta_rank_d}, Δβ_{{d-1}} = {rc.delta_rank_dm1}")
    print(f"Torsion changed: {rc.torsion_changed}")
    print(f"Euler constraint: {rc.delta_rank_d} - ({rc.delta_rank_dm1}) = "
          f"{rc.delta_rank_d - rc.delta_rank_dm1} (should be 1)")

    # Show the torsion spectrum change
    old_ts = extract_torsion_spectrum(M)
    M_new = np.column_stack([M, v.reshape(-1, 1)])
    new_ts = extract_torsion_spectrum(M_new)
    print(f"\nTorsion spectrum before: {old_ts}")
    print(f"Torsion spectrum after:  {new_ts}")
    print(f"Torsion mass: {old_ts.mass} → {new_ts.mass}")


def demo_smith_normal_form():
    """Demonstrate Smith normal form computation."""
    print("\n" + "=" * 70)
    print("DEMO 3: Smith Normal Form and Invariant Factors")
    print("=" * 70)

    matrices = [
        ("2×2 diagonal", np.array([[2, 0], [0, 6]])),
        ("2×2 with GCD", np.array([[4, 6], [2, 3]])),
        ("3×3 boundary", np.array([[1, -1, 0], [-1, 0, 1], [0, 1, -1]])),
        ("RP² presentation", np.array([[2, 0, 0], [0, 1, 0], [0, 0, 0]])),
    ]

    for name, M in matrices:
        S, U, V = smith_normal_form(M)
        ts = extract_torsion_spectrum(M)
        diag = [int(S[i, i]) for i in range(min(S.shape))]
        print(f"\n{name}:")
        print(f"  Matrix:\n{M}")
        print(f"  SNF diagonal: {diag}")
        print(f"  Torsion spectrum: {ts}")
        print(f"  Torsion mass: {ts.mass}")


def demo_random_complex_experiment(n_vertices=8, n_trials=50):
    """
    Random experiment testing the Single-Factor Torsion Pulse Conjecture.

    Generates random 2-complexes by inserting triangles one at a time,
    tracking how many invariant factors change per insertion.
    """
    print("\n" + "=" * 70)
    print(f"DEMO 4: Random Complex Experiment (n={n_vertices}, trials={n_trials})")
    print("=" * 70)
    print("\nTesting Single-Factor Torsion Pulse Conjecture:")
    print("Does each triangle insertion change at most one invariant factor?")

    event_counts = {e: 0 for e in SimplexInsertionEvent}
    max_factors_changed = 0
    torsion_events = []

    for trial in range(n_trials):
        K = SimplicialComplex(n_vertices)

        # Add all edges
        for i in range(n_vertices):
            for j in range(i + 1, n_vertices):
                K.simplices.setdefault(1, set()).add(frozenset({i, j}))

        # Generate random triangle ordering
        all_triangles = []
        for i in range(n_vertices):
            for j in range(i + 1, n_vertices):
                for k in range(j + 1, n_vertices):
                    all_triangles.append(frozenset({i, j, k}))
        random.shuffle(all_triangles)

        # Insert triangles one by one
        for tri in all_triangles:
            old_rank, old_ts = K.homology(1)

            try:
                event = K.add_simplex(tri)
            except ValueError:
                continue

            new_rank, new_ts = K.homology(1)
            event_counts[event] += 1

            if event == SimplexInsertionEvent.CHANGE_TORSION:
                # Count how many factors changed
                old_f = old_ts.factors
                new_f = new_ts.factors
                max_len = max(len(old_f), len(new_f))
                old_padded = old_f + [1] * (max_len - len(old_f))
                new_padded = new_f + [1] * (max_len - len(new_f))
                n_changed = sum(1 for a, b in zip(old_padded, new_padded) if a != b)
                n_changed += abs(len(old_f) - len(new_f))
                max_factors_changed = max(max_factors_changed, n_changed)
                torsion_events.append({
                    'trial': trial,
                    'old_spectrum': old_ts,
                    'new_spectrum': new_ts,
                    'factors_changed': n_changed
                })

    print(f"\nEvent distribution across {sum(event_counts.values())} insertions:")
    for event, count in event_counts.items():
        pct = 100 * count / max(1, sum(event_counts.values()))
        print(f"  {event.name:20s}: {count:5d} ({pct:5.1f}%)")

    print(f"\nTorsion events: {len(torsion_events)}")
    print(f"Max invariant factors changed in single insertion: {max_factors_changed}")

    if max_factors_changed <= 1:
        print("\n✓ Conjecture SUPPORTED: No insertion changed more than 1 factor")
    else:
        print(f"\n✗ Conjecture VIOLATED: Found insertion changing {max_factors_changed} factors")
        for te in torsion_events:
            if te['factors_changed'] > 1:
                print(f"  Counterexample in trial {te['trial']}:")
                print(f"    Before: {te['old_spectrum']}")
                print(f"    After:  {te['new_spectrum']}")
                break

    # Show some example torsion events
    if torsion_events:
        print("\nSample torsion events:")
        for te in torsion_events[:5]:
            print(f"  {te['old_spectrum']} → {te['new_spectrum']} "
                  f"(changed {te['factors_changed']} factor(s))")


def demo_euler_constraint_verification():
    """Verify the Euler constraint Δβ_d - Δβ_{d-1} = 1 on random data."""
    print("\n" + "=" * 70)
    print("DEMO 5: Euler Constraint Verification")
    print("=" * 70)

    n_tests = 100
    violations = 0

    for _ in range(n_tests):
        m = random.randint(2, 8)
        n = random.randint(1, 5)
        M = np.random.randint(-5, 6, size=(m, n)).astype(np.int64)
        v = np.random.randint(-5, 6, size=m).astype(np.int64)

        event, rc = classify_insertion_event(M, v)
        euler = rc.delta_rank_d - rc.delta_rank_dm1

        if euler != 1:
            violations += 1

    print(f"Tested {n_tests} random matrix insertions")
    print(f"Euler constraint Δβ_d - Δβ_{{d-1}} = 1 violations: {violations}")
    if violations == 0:
        print("✓ All tests passed")
    else:
        print("✗ Some violations found")


def demo_primewise_analysis():
    """Analyze prime-wise torsion changes."""
    print("\n" + "=" * 70)
    print("DEMO 6: Prime-wise Torsion Event Analysis")
    print("=" * 70)

    # Example: matrix with torsion factors involving multiple primes
    print("\nBuilding complex with rich torsion structure...")

    K = SimplicialComplex(6)
    # Add complete 1-skeleton
    for i in range(6):
        for j in range(i + 1, 6):
            K.simplices.setdefault(1, set()).add(frozenset({i, j}))

    # Add specific triangles to create interesting torsion
    triangles = [
        frozenset({0, 1, 2}), frozenset({0, 2, 3}),
        frozenset({1, 2, 3}), frozenset({0, 1, 3}),
        frozenset({3, 4, 5}), frozenset({2, 3, 4}),
    ]

    print("\nInserting triangles and tracking H₁ torsion:")
    for tri in triangles:
        old_rank, old_ts = K.homology(1)
        event = K.add_simplex(tri)
        new_rank, new_ts = K.homology(1)

        print(f"\n  Triangle {set(tri)} → {event.name}")
        print(f"    H₁: ℤ^{old_rank} ⊕ {old_ts}  →  ℤ^{new_rank} ⊕ {new_ts}")

        if old_ts != new_ts:
            # Analyze which primes are affected
            all_primes = set()
            for f in old_ts.factors + new_ts.factors:
                for p in range(2, f + 1):
                    if f % p == 0:
                        while f % p == 0:
                            f //= p
                        all_primes.add(p)
            if all_primes:
                print(f"    Primes involved: {sorted(all_primes)}")


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)

    demo_triangle_insertion()
    demo_torsion_creation()
    demo_smith_normal_form()
    demo_random_complex_experiment()
    demo_euler_constraint_verification()
    demo_primewise_analysis()

    print("\n" + "=" * 70)
    print("All demos complete.")
    print("=" * 70)


"""
Visualization: Event Type Distribution Across Random 2-Complexes

Shows the statistical distribution of Birth/Kill/Torsion events
as triangles are inserted into random Linial-Meshulam-style complexes.
Reveals the torsion phase transition and tests the prime-local
torsion pulse conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import random

# ============================================================
# Inline all needed functions (self-contained)
# ============================================================

def _extended_gcd(a, b):
    if b == 0:
        return a, 1, 0
    g, x1, y1 = _extended_gcd(b, a % b)
    return g, y1, x1 - (a // b) * y1

def smith_normal_form_small(M):
    M = np.array(M, dtype=np.int64)
    m, n = M.shape
    S = M.copy()
    for k in range(min(m, n)):
        piv = None
        for i in range(k, m):
            for j in range(k, n):
                if S[i, j] != 0 and (piv is None or abs(S[i, j]) < abs(S[piv[0], piv[1]])):
                    piv = (i, j)
        if piv is None:
            break
        i, j = piv
        if i != k:
            S[[k, i]] = S[[i, k]]
        if j != k:
            S[:, [k, j]] = S[:, [j, k]]
        changed = True
        while changed:
            changed = False
            for i in range(k + 1, m):
                if S[i, k] != 0:
                    if S[i, k] % S[k, k] == 0:
                        S[i, :] -= (S[i, k] // S[k, k]) * S[k, :]
                    else:
                        g, x, y = _extended_gcd(int(S[k, k]), int(S[i, k]))
                        a, b = S[k, k] // g, S[i, k] // g
                        rk, ri = S[k, :].copy(), S[i, :].copy()
                        S[k, :] = x * rk + y * ri
                        S[i, :] = -b * rk + a * ri
                    changed = True
            for j in range(k + 1, n):
                if S[k, j] != 0:
                    if S[k, j] % S[k, k] == 0:
                        S[:, j] -= (S[k, j] // S[k, k]) * S[:, k]
                    else:
                        g, x, y = _extended_gcd(int(S[k, k]), int(S[k, j]))
                        a, b = S[k, k] // g, S[k, j] // g
                        ck, cj = S[:, k].copy(), S[:, j].copy()
                        S[:, k] = x * ck + y * cj
                        S[:, j] = -b * ck + a * cj
                    changed = True
        if S[k, k] < 0:
            S[k, :] *= -1
    # Enforce divisibility
    for _ in range(min(m, n)):
        for k in range(min(m, n) - 1):
            if S[k, k] != 0 and S[k+1, k+1] != 0 and S[k+1, k+1] % S[k, k] != 0:
                S[k, :] += S[k+1, :]
                ch = True
                while ch:
                    ch = False
                    for i in range(k+1, m):
                        if S[i, k] != 0:
                            if S[i, k] % S[k, k] == 0:
                                S[i, :] -= (S[i, k] // S[k, k]) * S[k, :]
                            else:
                                g, x, y = _extended_gcd(int(S[k, k]), int(S[i, k]))
                                a, b = S[k, k] // g, S[i, k] // g
                                rk, ri = S[k, :].copy(), S[i, :].copy()
                                S[k, :] = x * rk + y * ri
                                S[i, :] = -b * rk + a * ri
                            ch = True
                    for j in range(k+1, n):
                        if S[k, j] != 0:
                            if S[k, j] % S[k, k] == 0:
                                S[:, j] -= (S[k, j] // S[k, k]) * S[:, k]
                            else:
                                g, x, y = _extended_gcd(int(S[k, k]), int(S[k, j]))
                                a, b = S[k, k] // g, S[k, j] // g
                                ck, cj = S[:, k].copy(), S[:, j].copy()
                                S[:, k] = x * ck + y * cj
                                S[:, j] = -b * ck + a * cj
                            ch = True
                if S[k, k] < 0:
                    S[k, :] *= -1
    return S

def get_torsion(M):
    if M.size == 0 or M.shape[1] == 0:
        return []
    S = smith_normal_form_small(M)
    return sorted([abs(int(S[i,i])) for i in range(min(S.shape)) if abs(S[i,i]) > 1])

def boundary_matrix_2(edges_list, tris_list):
    if not edges_list or not tris_list:
        return np.zeros((max(len(edges_list), 1), 0), dtype=np.int64)
    edge_idx = {e: i for i, e in enumerate(edges_list)}
    M = np.zeros((len(edges_list), len(tris_list)), dtype=np.int64)
    for j, tri in enumerate(tris_list):
        verts = sorted(tri)
        for k, v in enumerate(verts):
            face = frozenset(verts[:k] + verts[k+1:])
            if face in edge_idx:
                M[edge_idx[face], j] = (-1) ** k
    return M

# ============================================================
# Run experiments
# ============================================================

random.seed(42)
np.random.seed(42)

n_vertices_list = [6, 7, 8]
n_trials = 15

fig, axes = plt.subplots(2, 3, figsize=(18, 10))

for col, nv in enumerate(n_vertices_list):
    all_edges = [frozenset({i, j}) for i in range(nv) for j in range(i+1, nv)]
    all_tris = [frozenset({i, j, k}) for i in range(nv)
                for j in range(i+1, nv) for k in range(j+1, nv)]
    n_tris = len(all_tris)

    # Cumulative event fractions
    birth_counts = np.zeros(n_tris)
    kill_counts = np.zeros(n_tris)
    torsion_counts = np.zeros(n_tris)
    mass_history = np.zeros(n_tris)

    for trial in range(n_trials):
        order = list(range(n_tris))
        random.shuffle(order)

        edges_list = sorted(all_edges, key=lambda e: tuple(sorted(e)))
        tris_so_far = []

        for step, idx in enumerate(order):
            tri = all_tris[idx]
            tris_so_far_old = list(tris_so_far)
            tris_so_far.append(tri)

            M_old = boundary_matrix_2(edges_list, tris_so_far_old)
            M_new = boundary_matrix_2(edges_list, tris_so_far)

            old_factors = get_torsion(M_old)
            new_factors = get_torsion(M_new)

            S_old = smith_normal_form_small(M_old) if M_old.shape[1] > 0 else np.zeros((1, 0), dtype=np.int64)
            S_new = smith_normal_form_small(M_new)
            old_rank = sum(1 for i in range(min(S_old.shape)) if S_old[i,i] != 0) if M_old.shape[1] > 0 else 0
            new_rank = sum(1 for i in range(min(S_new.shape)) if S_new[i,i] != 0)

            if old_rank == new_rank:
                if old_factors == new_factors:
                    birth_counts[step] += 1
                else:
                    torsion_counts[step] += 1
            else:
                kill_counts[step] += 1

            mass = 1
            for f in new_factors:
                mass *= f
            mass_history[step] += mass

    # Normalize
    birth_frac = np.cumsum(birth_counts) / (np.arange(n_tris) + 1) / n_trials
    kill_frac = np.cumsum(kill_counts) / (np.arange(n_tris) + 1) / n_trials
    torsion_frac = np.cumsum(torsion_counts) / (np.arange(n_tris) + 1) / n_trials
    avg_mass = mass_history / n_trials

    x = np.arange(n_tris) / n_tris  # Fraction of triangles inserted

    # Top row: stacked area of event fractions
    ax = axes[0, col]
    ax.fill_between(x, 0, birth_counts / n_trials, alpha=0.6, color='#4CAF50', label='Birth')
    ax.fill_between(x, birth_counts / n_trials,
                    (birth_counts + kill_counts) / n_trials, alpha=0.6, color='#2196F3', label='Kill')
    ax.fill_between(x, (birth_counts + kill_counts) / n_trials,
                    (birth_counts + kill_counts + torsion_counts) / n_trials,
                    alpha=0.6, color='#FF9800', label='Torsion')
    ax.set_xlabel('Insertion Step', fontsize=11)
    ax.set_ylabel('Events per Step', fontsize=11)
    ax.set_title(f'n = {nv} vertices ({n_tris} triangles)', fontsize=13, fontweight='bold')
    if col == 2:
        ax.legend(loc='upper right', fontsize=9)
    ax.grid(True, alpha=0.2)

    # Bottom row: torsion mass evolution
    ax2 = axes[1, col]
    ax2.plot(x, avg_mass, '-', color='#E65100', linewidth=1.5)
    ax2.fill_between(x, 1, avg_mass, alpha=0.2, color='#FF9800')
    ax2.set_xlabel('Fraction of Triangles Inserted', fontsize=11)
    ax2.set_ylabel('Avg Torsion Mass', fontsize=11)
    ax2.set_title(f'Torsion Mass Evolution (n={nv})', fontsize=13, fontweight='bold')
    ax2.set_yscale('symlog', linthresh=1)
    ax2.grid(True, alpha=0.2)

    # Mark torsion phase transition region
    if np.max(avg_mass) > 1:
        transition_idx = np.argmax(avg_mass > 1)
        ax2.axvline(x=x[transition_idx], color='red', linestyle='--', alpha=0.5,
                    label='Phase transition')
        ax2.legend(fontsize=9)

fig.suptitle('Simplex Insertion Event Distribution in Random 2-Complexes\n'
             '(Linial-Meshulam model, averaged over 15 trials)',
             fontsize=15, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_event_distribution.png', dpi=150, bbox_inches='tight')
print("Saved viz_event_distribution.png")


"""
Visualization: Torsion Spectrum Evolution Under Simplex Insertion

Shows how the torsion spectrum (invariant factors of H₁) evolves as
triangles are added to a random 2-complex, with events color-coded
by the trichotomy classification.

This visualization makes the "tropical torsion pulse" conjecture
tangible: each insertion changes at most one invariant factor.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import random

# ============================================================
# Inline all needed functions (self-contained)
# ============================================================

def _extended_gcd(a, b):
    if b == 0:
        return a, 1, 0
    g, x1, y1 = _extended_gcd(b, a % b)
    return g, y1, x1 - (a // b) * y1

def smith_normal_form(M):
    M = np.array(M, dtype=np.int64)
    m, n = M.shape
    S = M.copy()
    U = np.eye(m, dtype=np.int64)
    V = np.eye(n, dtype=np.int64)

    for k in range(min(m, n)):
        # Find pivot
        min_val, min_pos = None, None
        for i in range(k, m):
            for j in range(k, n):
                if S[i, j] != 0 and (min_val is None or abs(S[i, j]) < abs(min_val)):
                    min_val, min_pos = S[i, j], (i, j)
        if min_pos is None:
            break
        i, j = min_pos
        if i != k:
            S[[k, i]] = S[[i, k]]; U[[k, i]] = U[[i, k]]
        if j != k:
            S[:, [k, j]] = S[:, [j, k]]; V[:, [k, j]] = V[:, [j, k]]

        changed = True
        while changed:
            changed = False
            for i in range(k + 1, m):
                if S[i, k] != 0:
                    if S[i, k] % S[k, k] == 0:
                        q = S[i, k] // S[k, k]
                        S[i, :] -= q * S[k, :]; U[i, :] -= q * U[k, :]
                    else:
                        g, x, y = _extended_gcd(int(S[k, k]), int(S[i, k]))
                        a, b = S[k, k] // g, S[i, k] // g
                        rk, ri = S[k, :].copy(), S[i, :].copy()
                        S[k, :] = x * rk + y * ri; S[i, :] = -b * rk + a * ri
                        uk, ui = U[k, :].copy(), U[i, :].copy()
                        U[k, :] = x * uk + y * ui; U[i, :] = -b * uk + a * ui
                    changed = True
            for j in range(k + 1, n):
                if S[k, j] != 0:
                    if S[k, j] % S[k, k] == 0:
                        q = S[k, j] // S[k, k]
                        S[:, j] -= q * S[:, k]; V[:, j] -= q * V[:, k]
                    else:
                        g, x, y = _extended_gcd(int(S[k, k]), int(S[k, j]))
                        a, b = S[k, k] // g, S[k, j] // g
                        ck, cj = S[:, k].copy(), S[:, j].copy()
                        S[:, k] = x * ck + y * cj; S[:, j] = -b * ck + a * cj
                        vk, vj = V[:, k].copy(), V[:, j].copy()
                        V[:, k] = x * vk + y * vj; V[:, j] = -b * vk + a * vj
                    changed = True
        if S[k, k] < 0:
            S[k, :] *= -1; U[k, :] *= -1

    for _ in range(min(m, n)):
        for k in range(min(m, n) - 1):
            if S[k, k] != 0 and S[k+1, k+1] != 0 and S[k+1, k+1] % S[k, k] != 0:
                S[k, :] += S[k+1, :]; U[k, :] += U[k+1, :]
                ch = True
                while ch:
                    ch = False
                    for i in range(k+1, m):
                        if S[i, k] != 0:
                            if S[i, k] % S[k, k] == 0:
                                q = S[i, k] // S[k, k]
                                S[i, :] -= q * S[k, :]; U[i, :] -= q * U[k, :]
                            else:
                                g, x, y = _extended_gcd(int(S[k, k]), int(S[i, k]))
                                a, b = S[k, k] // g, S[i, k] // g
                                rk, ri = S[k, :].copy(), S[i, :].copy()
                                S[k, :] = x * rk + y * ri; S[i, :] = -b * rk + a * ri
                                uk, ui = U[k, :].copy(), U[i, :].copy()
                                U[k, :] = x * uk + y * ui; U[i, :] = -b * uk + a * ui
                            ch = True
                    for j in range(k+1, n):
                        if S[k, j] != 0:
                            if S[k, j] % S[k, k] == 0:
                                q = S[k, j] // S[k, k]
                                S[:, j] -= q * S[:, k]; V[:, j] -= q * V[:, k]
                            else:
                                g, x, y = _extended_gcd(int(S[k, k]), int(S[k, j]))
                                a, b = S[k, k] // g, S[k, j] // g
                                ck, cj = S[:, k].copy(), S[:, j].copy()
                                S[:, k] = x * ck + y * cj; S[:, j] = -b * ck + a * cj
                                vk, vj = V[:, k].copy(), V[:, j].copy()
                                V[:, k] = x * vk + y * vj; V[:, j] = -b * vk + a * vj
                            ch = True
                if S[k, k] < 0:
                    S[k, :] *= -1; U[k, :] *= -1
    return S, U, V

def get_torsion_factors(M):
    if M.size == 0 or M.shape[1] == 0:
        return []
    S, _, _ = smith_normal_form(M)
    return sorted([abs(int(S[i, i])) for i in range(min(S.shape)) if abs(S[i, i]) > 1])

class SimpleComplex:
    def __init__(self, nv):
        self.nv = nv
        self.edges = set()
        self.triangles = set()

    def add_edge(self, e):
        self.edges.add(e)

    def add_triangle(self, t):
        self.triangles.add(t)

    def boundary_2(self):
        edges = sorted(self.edges, key=lambda e: tuple(sorted(e)))
        tris = sorted(self.triangles, key=lambda t: tuple(sorted(t)))
        if not edges or not tris:
            return np.zeros((max(len(edges), 1), 0), dtype=np.int64)
        edge_idx = {e: i for i, e in enumerate(edges)}
        M = np.zeros((len(edges), len(tris)), dtype=np.int64)
        for j, tri in enumerate(tris):
            verts = sorted(tri)
            for k, v in enumerate(verts):
                face = frozenset(verts[:k] + verts[k+1:])
                if face in edge_idx:
                    M[edge_idx[face], j] = (-1) ** k
        return M


# ============================================================
# Run experiment and visualize
# ============================================================

random.seed(123)
np.random.seed(123)
n_vertices = 7

K = SimpleComplex(n_vertices)
for i in range(n_vertices):
    for j in range(i+1, n_vertices):
        K.add_edge(frozenset({i, j}))

all_tris = []
for i in range(n_vertices):
    for j in range(i+1, n_vertices):
        for k in range(j+1, n_vertices):
            all_tris.append(frozenset({i, j, k}))
random.shuffle(all_tris)

# Track evolution
steps = []
torsion_history = []
event_colors = []

M_old = K.boundary_2()
old_factors = get_torsion_factors(M_old)

for idx, tri in enumerate(all_tris):
    K.add_triangle(tri)
    M_new = K.boundary_2()
    new_factors = get_torsion_factors(M_new)

    # Classify event
    S_old, _, _ = smith_normal_form(M_old) if M_old.shape[1] > 0 else (np.zeros((1, 0), dtype=np.int64), None, None)
    S_new, _, _ = smith_normal_form(M_new)
    old_rank = sum(1 for i in range(min(S_old.shape)) if S_old[i, i] != 0) if M_old.shape[1] > 0 else 0
    new_rank = sum(1 for i in range(min(S_new.shape)) if S_new[i, i] != 0)

    if old_rank == new_rank:
        if old_factors == new_factors:
            color = '#4CAF50'  # Green: birth free
            event = 'Birth'
        else:
            color = '#FF9800'  # Orange: torsion change
            event = 'Torsion'
    else:
        color = '#2196F3'  # Blue: kill free
        event = 'Kill'

    steps.append(idx + 1)
    torsion_history.append(new_factors.copy())
    event_colors.append(color)

    M_old = M_new
    old_factors = new_factors

# ============================================================
# Create visualization
# ============================================================

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10), gridspec_kw={'height_ratios': [2, 1]})

# Top panel: Torsion spectrum evolution (heatmap-style)
max_factors = max(len(t) for t in torsion_history) if torsion_history else 1
max_factors = max(max_factors, 1)

# Create heatmap data
heatmap = np.zeros((max_factors, len(steps)))
for i, factors in enumerate(torsion_history):
    for j, f in enumerate(factors):
        heatmap[j, i] = np.log2(f) if f > 0 else 0

im = ax1.imshow(heatmap, aspect='auto', cmap='YlOrRd', interpolation='nearest',
                origin='lower', extent=[0.5, len(steps)+0.5, -0.5, max_factors-0.5])

# Mark event types on top
for i, color in enumerate(event_colors):
    ax1.plot(i + 1, max_factors - 0.3, 's', color=color, markersize=4)

ax1.set_xlabel('Insertion Step', fontsize=12)
ax1.set_ylabel('Invariant Factor Index', fontsize=12)
ax1.set_title('Torsion Spectrum Evolution Under Triangle Insertion', fontsize=14, fontweight='bold')

cbar = plt.colorbar(im, ax=ax1, label='log₂(factor)')

# Legend
birth_patch = mpatches.Patch(color='#4CAF50', label='Free Birth')
kill_patch = mpatches.Patch(color='#2196F3', label='Free Kill')
torsion_patch = mpatches.Patch(color='#FF9800', label='Torsion Change')
ax1.legend(handles=[birth_patch, kill_patch, torsion_patch], loc='upper right', fontsize=10)

# Bottom panel: Torsion mass over time
masses = [1]
for factors in torsion_history:
    m = 1
    for f in factors:
        m *= f
    masses.append(m)

ax2.fill_between(range(len(masses)), masses, alpha=0.3, color='#FF9800')
ax2.plot(range(len(masses)), masses, 'o-', color='#E65100', markersize=3, linewidth=1.5)

# Mark torsion events
for i, color in enumerate(event_colors):
    if color == '#FF9800':
        ax2.axvline(x=i+1, color='#FF9800', alpha=0.3, linewidth=1)

ax2.set_xlabel('Insertion Step', fontsize=12)
ax2.set_ylabel('Torsion Mass |Tor(H₁)|', fontsize=12)
ax2.set_title('Torsion Mass Evolution (Product of Invariant Factors)', fontsize=14, fontweight='bold')
ax2.set_yscale('symlog', linthresh=1)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_torsion_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_torsion_spectrum.png")


"""
Visualization: The Integer Simplex Insertion Trichotomy

Visualizes the three cases of the simplex insertion trichotomy over ℤ
using a lattice diagram showing how the boundary vector relates to
the existing boundary submodule.

The three cases:
1. BIRTH_FREE: ∂σ ∈ B (vector is in the span)
2. KILL_FREE: ∂σ primitive mod B (vector extends the lattice rank)
3. CHANGE_TORSION: ∂σ ∈ Sat(B) \ B (vector in saturation but not span)
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyArrowPatch

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

def draw_lattice_case(ax, case_num, title, subtitle):
    """Draw a lattice diagram for one case of the trichotomy."""
    ax.set_xlim(-1, 5)
    ax.set_ylim(-1, 5)
    ax.set_aspect('equal')
    ax.set_title(f'Case {case_num}: {title}\n{subtitle}', fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.15)
    ax.set_xlabel('$e_1$', fontsize=12)
    ax.set_ylabel('$e_2$', fontsize=12)

    # Draw integer lattice points
    for i in range(6):
        for j in range(6):
            ax.plot(i, j, 'o', color='#cccccc', markersize=3, zorder=1)

# Case 1: Birth Free — ∂σ ∈ B
ax = axes[0]
draw_lattice_case(ax, 1, 'Free Birth', '∂σ ∈ B (redundant)')

# Draw submodule B = span{(1,0), (0,2)}
# Lattice points in B
for a in range(-2, 8):
    for b in range(-1, 4):
        x, y = a, 2*b
        if 0 <= x <= 5 and 0 <= y <= 5:
            ax.plot(x, y, 's', color='#4CAF50', markersize=8, alpha=0.4, zorder=2)

ax.annotate('', xy=(1, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#2E7D32', lw=2.5))
ax.text(0.5, -0.4, 'b₁=(1,0)', ha='center', fontsize=9, color='#2E7D32')

ax.annotate('', xy=(0, 2), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#2E7D32', lw=2.5))
ax.text(-0.7, 1, 'b₂=(0,2)', ha='center', fontsize=9, color='#2E7D32', rotation=90)

# ∂σ = (2,0) = 2·b₁ ∈ B
ax.annotate('', xy=(2, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#E91E63', lw=3))
ax.text(1, 0.4, '∂σ=(2,0)∈B', ha='center', fontsize=11, color='#E91E63', fontweight='bold')

ax.text(2.5, 4.5, 'Result:\nNew cycle in H_d\nH_{d-1} unchanged',
        fontsize=10, ha='center', va='top',
        bbox=dict(boxstyle='round', facecolor='#E8F5E9', alpha=0.8))

# Case 2: Kill Free — ∂σ primitive
ax = axes[1]
draw_lattice_case(ax, 2, 'Free Kill', '∂σ primitive mod B')

# B = span{(2,0)}
for a in range(-1, 4):
    x, y = 2*a, 0
    if 0 <= x <= 5:
        ax.plot(x, y, 's', color='#2196F3', markersize=8, alpha=0.4, zorder=2)

ax.annotate('', xy=(2, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#1565C0', lw=2.5))
ax.text(1, -0.4, 'b₁=(2,0)', ha='center', fontsize=9, color='#1565C0')

# ∂σ = (0,1) — primitive, not in Sat(B)
ax.annotate('', xy=(0, 1), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#E91E63', lw=3))
ax.text(0.8, 1.3, '∂σ=(0,1)\nprimitive', ha='center', fontsize=11,
        color='#E91E63', fontweight='bold')

# Show saturation = same as B (1-dimensional)
ax.fill_between([-0.5, 5.5], [-0.1, -0.1], [0.1, 0.1],
                alpha=0.1, color='#1565C0', label='Sat(B)')

ax.text(2.5, 4.5, 'Result:\nKills free class in H_{d-1}\nH_d unchanged',
        fontsize=10, ha='center', va='top',
        bbox=dict(boxstyle='round', facecolor='#E3F2FD', alpha=0.8))

# Case 3: Torsion Change — ∂σ in Sat(B) \ B
ax = axes[2]
draw_lattice_case(ax, 3, 'Torsion Change', '∂σ ∈ Sat(B) \\ B')

# B = span{(2,0)}
for a in range(-1, 4):
    x, y = 2*a, 0
    if 0 <= x <= 5:
        ax.plot(x, y, 's', color='#FF9800', markersize=8, alpha=0.4, zorder=2)

ax.annotate('', xy=(2, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#E65100', lw=2.5))
ax.text(1, -0.4, 'b₁=(2,0)', ha='center', fontsize=9, color='#E65100')

# Saturation = span_ℚ{(2,0)} ∩ ℤ² = span{(1,0)}
for a in range(0, 6):
    ax.plot(a, 0, 'D', color='#FF9800', markersize=6, alpha=0.3, zorder=2)

# ∂σ = (1,0) — in saturation (2·(1,0) = (2,0) ∈ B) but not in B
ax.annotate('', xy=(1, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#E91E63', lw=3))
ax.text(1.8, 0.8, '∂σ=(1,0)\n2·∂σ∈B but ∂σ∉B', ha='center', fontsize=10,
        color='#E91E63', fontweight='bold')

# Show the saturation gap
ax.annotate('Saturation\ngap!', xy=(1, 0.1), xytext=(3, 2),
            fontsize=10, color='#BF360C', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='#BF360C', lw=1.5))

ax.text(2.5, 4.5, 'Result:\nTorsion in H_{d-1} changes\n+ free birth in H_d',
        fontsize=10, ha='center', va='top',
        bbox=dict(boxstyle='round', facecolor='#FFF3E0', alpha=0.8))

plt.suptitle('Integer Simplex Insertion Trichotomy: Three Arithmetic Events',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_trichotomy.png', dpi=150, bbox_inches='tight')
print("Saved viz_trichotomy.png")
