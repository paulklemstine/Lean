#!/usr/bin/env python3
"""
Applications of Apollonian Spectral-Polynomial Transfer

Demonstrates practical applications:
1. Curvature statistics prediction via spectral decay
2. Congruence class equidistribution
3. Random walk mixing on the Apollonian group
4. Low-degree moment estimation
"""

import numpy as np
from collections import Counter
from algorithms import (apollonian_generators, descartes_Q, 
                        build_observable_operator, spectral_gap_analysis,
                        enumerate_apollonian_orbit)


# =============================================================================
# Application 1: Curvature Statistics
# =============================================================================

def curvature_moment_decay():
    """Show how low-degree polynomial statistics decay under random walk.
    
    The spectral transfer theorem predicts that centered moments
    of curvature distributions converge geometrically to their
    invariant values under random application of generators.
    """
    print("=" * 60)
    print("Application 1: Curvature Moment Decay")
    print("=" * 60)
    
    gens = apollonian_generators()
    root = np.array([-1, 2, 2, 3])
    
    # Random walk: at each step, apply a random generator
    np.random.seed(42)
    n_walks = 1000
    n_steps = 50
    
    # Track first and second moments of curvatures
    mean_curv = np.zeros((n_steps + 1, 4))
    var_curv = np.zeros((n_steps + 1, 4))
    
    for walk in range(n_walks):
        v = root.copy().astype(float)
        for step in range(n_steps + 1):
            mean_curv[step] += v / n_walks
            var_curv[step] += v**2 / n_walks
            if step < n_steps:
                gen_idx = np.random.randint(4)
                v = gens[gen_idx] @ v
    
    print("\nMean curvature vector over random walks:")
    for step in [0, 1, 2, 5, 10, 20, 50]:
        print(f"  Step {step:3d}: {mean_curv[step]}")
    
    print("\nVariance of curvatures over random walks:")
    for step in [0, 1, 2, 5, 10, 20, 50]:
        centered_var = var_curv[step] - mean_curv[step]**2
        print(f"  Step {step:3d}: {centered_var}")


# =============================================================================
# Application 2: Congruence Class Distribution
# =============================================================================

def congruence_equidistribution():
    """Show curvatures equidistribute among congruence classes.
    
    For the Apollonian gasket, curvatures modulo q approach
    uniform distribution on the admissible residues.
    """
    print("\n" + "=" * 60)
    print("Application 2: Congruence Class Equidistribution")
    print("=" * 60)
    
    root = np.array([-1, 2, 2, 3])
    orbit = enumerate_apollonian_orbit(root, max_depth=8)
    
    all_curvatures = [c for c in orbit['all_curvatures'] if c > 0]
    
    for q in [6, 12, 24]:
        residues = Counter(c % q for c in all_curvatures)
        total = len(all_curvatures)
        
        print(f"\nCurvatures mod {q} (from {total} positive curvatures):")
        expected = total / q
        
        present_residues = sorted(residues.keys())
        absent_residues = [r for r in range(q) if r not in residues]
        
        print(f"  Present residues: {len(present_residues)}/{q}")
        if absent_residues:
            print(f"  Absent residues: {absent_residues}")
        
        # Chi-squared statistic
        chi2 = sum((residues.get(r, 0) - expected)**2 / expected 
                   for r in range(q))
        print(f"  Chi-squared statistic: {chi2:.2f} "
              f"(uniform would give ~{q-1:.0f})")
        
        # Show distribution for small q
        if q <= 12:
            for r in range(q):
                count = residues.get(r, 0)
                bar = '#' * int(count / max(residues.values()) * 40)
                print(f"    {r:2d}: {count:5d} {bar}")


# =============================================================================
# Application 3: Observable Convergence Rate Prediction
# =============================================================================

def observable_convergence_prediction():
    """Use spectral gap to predict convergence rates of polynomial statistics.
    
    Given the spectral gap γ_k on degree-≤k observables, predict
    how many random walk steps are needed for a polynomial statistic
    to converge within ε of its invariant value.
    """
    print("\n" + "=" * 60)
    print("Application 3: Convergence Rate Prediction")
    print("=" * 60)
    
    gens = apollonian_generators()
    
    print("\nSpectral gaps by observable degree:")
    for k in range(1, 5):
        T_k, basis = build_observable_operator(gens, k)
        analysis = spectral_gap_analysis(T_k)
        
        gap = analysis['relative_gap']
        
        # Number of steps for ε-convergence: n ≥ log(1/ε) / log(1/(1-γ))
        for eps in [0.1, 0.01, 0.001]:
            if gap > 0 and (1 - gap) > 0:
                n_steps = int(np.ceil(np.log(1/eps) / np.log(1/(1 - gap))))
            else:
                n_steps = float('inf')
            print(f"  k={k}, γ={gap:.4f}: "
                  f"ε={eps} convergence in ≤ {n_steps} steps")


# =============================================================================
# Application 4: Pseudorandomness of Apollonian Orbits
# =============================================================================

def apollonian_pseudorandomness():
    """Measure pseudorandomness of Apollonian orbit via polynomial tests.
    
    Low-degree polynomial statistics that distinguish the orbit from
    random should decay exponentially fast — a consequence of the
    spectral transfer theorem.
    """
    print("\n" + "=" * 60)
    print("Application 4: Pseudorandomness Test")
    print("=" * 60)
    
    gens = apollonian_generators()
    root = np.array([-1, 2, 2, 3])
    
    # Compute orbit at each depth and measure polynomial statistics
    print("\nPolynomial test statistics by orbit depth:")
    print(f"{'Depth':>6} {'N_quad':>8} {'Mean_sum':>10} {'Var_sum':>10} "
          f"{'Mean_prod':>12} {'Skewness':>10}")
    
    visited = {tuple(root)}
    frontier = [root.copy()]
    
    for depth in range(8):
        # Compute statistics on all visited quadruples
        quads = np.array([list(v) for v in visited])
        
        # Linear statistics
        sums = quads.sum(axis=1)
        mean_sum = np.mean(sums)
        var_sum = np.var(sums)
        
        # Quadratic statistics
        prods = np.prod(quads, axis=1).astype(float)
        mean_prod = np.mean(prods)
        
        # Skewness of sum
        if var_sum > 0:
            skewness = np.mean((sums - mean_sum)**3) / var_sum**1.5
        else:
            skewness = 0
        
        print(f"{depth:6d} {len(visited):8d} {mean_sum:10.2f} {var_sum:10.2f} "
              f"{mean_prod:12.2f} {skewness:10.4f}")
        
        # Expand frontier
        new_frontier = []
        for v in frontier:
            for S in gens:
                w = S @ np.array(v)
                key = tuple(w)
                if key not in visited:
                    visited.add(key)
                    new_frontier.append(w)
        frontier = new_frontier


if __name__ == "__main__":
    curvature_moment_decay()
    congruence_equidistribution()
    observable_convergence_prediction()
    apollonian_pseudorandomness()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Apollonian Gasket: Spectral-Polynomial Transfer Demonstration

Demonstrates the key theorems about the Apollonian gasket:
1. Descartes quadratic form invariance under generators
2. Polynomial observable space preservation
3. Spectral transfer and geometric decay of iterates
"""

import numpy as np
from itertools import product as iter_product

# =============================================================================
# Core Definitions
# =============================================================================

def descartes_matrix():
    """The Descartes quadratic form matrix J = 2I - 11^T.
    J_ii = 1, J_ij = -1 for i != j."""
    return np.array([
        [ 1, -1, -1, -1],
        [-1,  1, -1, -1],
        [-1, -1,  1, -1],
        [-1, -1, -1,  1]
    ], dtype=int)

def descartes_Q(v):
    """Descartes quadratic form Q(v) = v^T J v = 2 sum(v_i^2) - (sum(v_i))^2."""
    J = descartes_matrix()
    return int(v @ J @ v)

def apollonian_generators():
    """The four Apollonian generators S_0, S_1, S_2, S_3.
    S_i replaces b_i with 2*sum(b_j, j!=i) - b_i."""
    S = [np.eye(4, dtype=int) for _ in range(4)]
    for i in range(4):
        for j in range(4):
            if i == j:
                S[i][i, j] = -1
            else:
                S[i][i, j] = 2
    return S

# =============================================================================
# Demo 1: Descartes Form Invariance
# =============================================================================

def demo_descartes_invariance():
    """Verify that each generator preserves the Descartes matrix: S_i^T J S_i = J."""
    print("=" * 70)
    print("DEMO 1: Descartes Quadratic Form Invariance")
    print("=" * 70)
    
    J = descartes_matrix()
    gens = apollonian_generators()
    
    print(f"\nDescartes matrix J =\n{J}\n")
    
    for i, S in enumerate(gens):
        result = S.T @ J @ S
        match = np.array_equal(result, J)
        print(f"S_{i}^T * J * S_{i} = J ?  {match}")
    
    # Also check involutivity: S_i^2 = I
    print("\nInvolutivity check:")
    for i, S in enumerate(gens):
        sq = S @ S
        match = np.array_equal(sq, np.eye(4, dtype=int))
        print(f"S_{i}^2 = I ?  {match}")
    
    # Check on the classic Apollonian quadruple (-1, 2, 2, 3)
    v0 = np.array([-1, 2, 2, 3])
    Q0 = descartes_Q(v0)
    print(f"\nRoot quadruple v = {v0}, Q(v) = {Q0}")
    
    for i, S in enumerate(gens):
        v_new = S @ v0
        Q_new = descartes_Q(v_new)
        print(f"  S_{i}(v) = {v_new}, Q = {Q_new}, preserved: {Q_new == Q0}")

# =============================================================================
# Demo 2: Word-Level Orbit
# =============================================================================

def demo_word_orbit():
    """Show Descartes invariance under arbitrary words in the generators."""
    print("\n" + "=" * 70)
    print("DEMO 2: Word-Level Orbit and Descartes Invariance")
    print("=" * 70)
    
    gens = apollonian_generators()
    v0 = np.array([-1, 2, 2, 3])
    Q0 = descartes_Q(v0)
    
    # Generate random words and check invariance
    np.random.seed(42)
    print(f"\nStarting from v = {v0}, Q(v) = {Q0}")
    print("\nApplying random words of generators:")
    
    for trial in range(8):
        word_len = np.random.randint(1, 8)
        word = [np.random.randint(0, 4) for _ in range(word_len)]
        
        v = v0.copy()
        for idx in reversed(word):
            v = gens[idx] @ v
        
        Q = descartes_Q(v)
        word_str = "".join(str(w) for w in word)
        print(f"  Word [{word_str}]: v = {v}, Q = {Q}, invariant: {Q == Q0}")

# =============================================================================
# Demo 3: Polynomial Observable Degree Preservation
# =============================================================================

def demo_observable_preservation():
    """Show that precomposition by generators preserves polynomial degree."""
    print("\n" + "=" * 70)
    print("DEMO 3: Polynomial Observable Degree Preservation")
    print("=" * 70)
    
    gens = apollonian_generators()
    
    # Each generator sends X_j to a linear combination of X_0,...,X_3
    # i.e., X_j -> sum_l S[j,l] * X_l, which has degree 1
    print("\nCoordinate functions under each generator:")
    for i, S in enumerate(gens):
        print(f"\n  Generator S_{i}:")
        for j in range(4):
            terms = []
            for l in range(4):
                c = S[j, l]
                if c != 0:
                    if c == 1:
                        terms.append(f"X_{l}")
                    elif c == -1:
                        terms.append(f"-X_{l}")
                    else:
                        terms.append(f"{c}*X_{l}")
            print(f"    X_{j} -> {' + '.join(terms)}")
    
    # A degree-2 monomial: X_0 * X_1
    # Under S_0: X_0 -> -X_0 + 2X_1 + 2X_2 + 2X_3
    #            X_1 -> X_1
    # So X_0*X_1 -> (-X_0 + 2X_1 + 2X_2 + 2X_3) * X_1
    #            = -X_0*X_1 + 2*X_1^2 + 2*X_1*X_2 + 2*X_1*X_3
    # This has degree 2 (preserved!)
    print("\n\nExample: Degree-2 monomial X_0 * X_1 under S_0:")
    print("  X_0*X_1 -> (-X_0 + 2X_1 + 2X_2 + 2X_3) * X_1")
    print("          = -X_0*X_1 + 2*X_1^2 + 2*X_1*X_2 + 2*X_1*X_3")
    print("  Degree = 2 (preserved!)")
    
    # Count observable space dimensions for degree <= k
    print("\n\nDimension of degree-≤k observable space Poly_≤k(Fin 4):")
    for k in range(6):
        # dim = C(4+k, k) = (4+k)! / (4! * k!)
        from math import comb
        dim = comb(4 + k, k)
        print(f"  k = {k}: dim = {dim}")

# =============================================================================
# Demo 4: Spectral Transfer and Mixing
# =============================================================================

def demo_spectral_transfer():
    """Demonstrate geometric decay of the averaging operator on observables."""
    print("\n" + "=" * 70)
    print("DEMO 4: Spectral Transfer and Geometric Mixing")
    print("=" * 70)
    
    gens = apollonian_generators()
    
    # Build the averaging operator T on degree-1 observables
    # Degree-1 observables are spanned by {1, X_0, X_1, X_2, X_3}
    # The constant part is invariant. On the X_j coordinates:
    # T(X_j)(v) = (1/4) * sum_i X_j(S_i v) = (1/4) * sum_i (S_i v)_j
    # = (1/4) * sum_i S_i[j,:] . v
    
    # Matrix of T on (X_0, X_1, X_2, X_3):
    T1 = np.mean([S for S in gens], axis=0)
    
    print(f"\nAveraging operator T on degree-1 observables:")
    print(f"T = (1/4)(S_0 + S_1 + S_2 + S_3) =")
    print(T1)
    
    # Eigenvalue analysis
    eigenvalues = np.linalg.eigvals(T1)
    print(f"\nEigenvalues of T: {np.sort(np.real(eigenvalues))[::-1]}")
    
    # The constant vector (1,1,1,1) should be an eigenvector
    ones = np.ones(4)
    Tones = T1 @ ones
    print(f"\nT * (1,1,1,1) = {Tones}")
    print(f"Eigenvalue for sum-of-curvatures direction: {Tones[0]}")
    
    # Spectral gap on the complement
    sorted_evals = sorted(np.abs(eigenvalues), reverse=True)
    spectral_gap = 1.0 - sorted_evals[1]  # gap from largest non-trivial eigenvalue
    print(f"\nLargest eigenvalue magnitude: {sorted_evals[0]:.4f}")
    print(f"Second largest: {sorted_evals[1]:.4f}")
    print(f"Spectral gap γ = 1 - |λ_2| = {spectral_gap:.4f}")
    
    # Demonstrate geometric decay
    print(f"\nGeometric decay of a centered observable under T^n:")
    # Take a centered vector orthogonal to the invariant subspace
    v = np.array([1, -1, 0, 0], dtype=float)
    # Make it centered (zero projection on invariant subspace)
    
    print(f"  Initial: v = {v}, ||v|| = {np.linalg.norm(v):.4f}")
    for n in range(1, 11):
        Tnv = np.linalg.matrix_power(T1, n) @ v
        norm_Tnv = np.linalg.norm(Tnv)
        bound = (1 - spectral_gap) ** n * np.linalg.norm(v)
        print(f"  n={n:2d}: ||T^n v|| = {norm_Tnv:.6f}, "
              f"bound (1-γ)^n ||v|| = {bound:.6f}")
    
    # Build T on degree-2 observables
    print("\n\nDegree-2 averaging operator analysis:")
    # Basis: monomials X_i * X_j for i <= j, plus X_i, plus 1
    # The action on monomials can be computed from the generator matrices
    # For simplicity, we compute eigenvalues of the degree-2 action matrix
    
    # Enumerate degree-2 monomials (as exponent vectors)
    from math import comb
    mono_deg2 = []
    for a0 in range(3):
        for a1 in range(3 - a0):
            for a2 in range(3 - a0 - a1):
                a3 = 0
                while a0 + a1 + a2 + a3 <= 2:
                    mono_deg2.append((a0, a1, a2, a3))
                    a3 += 1
    
    print(f"  Number of degree-≤2 monomials: {len(mono_deg2)}")
    
    # Build the matrix of T on degree-2 monomials
    # For each monomial m, T(m) = (1/4) sum_i precomp_S_i(m)
    dim = len(mono_deg2)
    T2_matrix = np.zeros((dim, dim))
    
    for gen_idx, S in enumerate(gens):
        for col, (a0, a1, a2, a3) in enumerate(mono_deg2):
            # Evaluate the monomial v -> v_0^a0 * v_1^a1 * v_2^a2 * v_3^a3
            # after applying S: v -> S*v
            # Need to expand (S[0,:].v)^a0 * (S[1,:].v)^a1 * ...
            # Using symbolic expansion via coefficient extraction
            
            # Simple approach: evaluate on many test points and solve
            pass
    
    # Alternative: use numerical evaluation
    # Sample test points and build the operator numerically
    np.random.seed(123)
    n_samples = 100
    mono_vals = np.zeros((dim, n_samples))
    T_mono_vals = np.zeros((dim, n_samples))
    
    for s in range(n_samples):
        v_test = np.random.randn(4)
        for col, (a0, a1, a2, a3) in enumerate(mono_deg2):
            mono_vals[col, s] = v_test[0]**a0 * v_test[1]**a1 * v_test[2]**a2 * v_test[3]**a3
        
        # Average over generators
        for S in gens:
            Sv = S @ v_test
            for col, (a0, a1, a2, a3) in enumerate(mono_deg2):
                T_mono_vals[col, s] += (1.0/4.0) * Sv[0]**a0 * Sv[1]**a1 * Sv[2]**a2 * Sv[3]**a3
    
    # Solve T2_matrix @ mono_vals = T_mono_vals via least squares
    T2_matrix = T_mono_vals @ np.linalg.pinv(mono_vals)
    
    evals2 = np.linalg.eigvals(T2_matrix)
    evals2_sorted = sorted(np.abs(evals2), reverse=True)
    print(f"  Eigenvalue magnitudes (degree ≤ 2): {[f'{e:.4f}' for e in evals2_sorted[:8]]}")
    gap2 = 1.0 - evals2_sorted[1] if len(evals2_sorted) > 1 else 0
    print(f"  Spectral gap on degree-2 space: {gap2:.4f}")


# =============================================================================
# Demo 5: Apollonian Orbit Visualization Data
# =============================================================================

def demo_orbit_growth():
    """Compute orbit curvatures and show growth patterns."""
    print("\n" + "=" * 70)
    print("DEMO 5: Apollonian Orbit Growth")
    print("=" * 70)
    
    gens = apollonian_generators()
    
    # Start with (-1, 2, 2, 3) - the classic Apollonian gasket
    v0 = np.array([-1, 2, 2, 3])
    
    # BFS to generate orbit
    visited = set()
    visited.add(tuple(v0))
    frontier = [v0]
    all_curvatures = set(v0.tolist())
    
    for depth in range(6):
        new_frontier = []
        for v in frontier:
            for S in gens:
                w = S @ v
                key = tuple(w)
                if key not in visited:
                    visited.add(key)
                    new_frontier.append(w)
                    for c in w:
                        all_curvatures.add(int(c))
        frontier = new_frontier
        pos_curvatures = sorted([c for c in all_curvatures if c > 0])
        print(f"  Depth {depth+1}: {len(visited)} quadruples, "
              f"{len(pos_curvatures)} distinct positive curvatures, "
              f"max curvature = {max(pos_curvatures)}")
    
    # Show some curvatures
    sorted_curv = sorted(all_curvatures)
    print(f"\n  First 30 curvatures: {sorted_curv[:30]}")
    
    # All quadruples lie on Q=0
    print(f"\n  Verifying Q=0 for all {len(visited)} quadruples...")
    all_on_cone = all(descartes_Q(np.array(v)) == 0 for v in visited)
    print(f"  All on Descartes light cone Q=0: {all_on_cone}")


if __name__ == "__main__":
    demo_descartes_invariance()
    demo_word_orbit()
    demo_observable_preservation()
    demo_spectral_transfer()
    demo_orbit_growth()
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Apollonian Gasket Visualizations

Generates publication-quality figures for the Apollonian spectral transfer project.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
import base64
import io

from algorithms import (apollonian_generators, descartes_Q, descartes_matrix,
                        build_observable_operator, spectral_gap_analysis,
                        enumerate_apollonian_orbit, degree_le_k_monomials)


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def generate_apollonian_gasket_figure():
    """Generate a figure of the Apollonian gasket via circle inversion."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    # Start with the outer circle and three inner tangent circles
    # Classic Apollonian gasket: curvatures (-1, 2, 2, 3)
    # Outer circle: curvature -1, radius 1
    # Two circles of curvature 2 (radius 0.5) and one of curvature 3 (radius 1/3)
    
    def solve_descartes(k1, k2, k3):
        """Given three mutually tangent circle curvatures, find the fourth."""
        s = k1 + k2 + k3
        discriminant = 2 * (k1**2 + k2**2 + k3**2) - s**2
        # k4 = s + 2*sqrt(k1*k2 + k2*k3 + k3*k1) or s - 2*sqrt(...)
        inner = k1*k2 + k2*k3 + k3*k1
        if inner < 0:
            return [s]
        return [s + 2*np.sqrt(inner), s - 2*np.sqrt(inner)]
    
    # Place circles manually for the (-1, 2, 2, 3) packing
    circles = []
    
    # Outer circle: center (0, 0), radius 1, curvature -1
    circles.append((0, 0, 1, -1))
    
    # Two circles of curvature 2 (radius 0.5)
    # Tangent to each other and to the outer circle
    circles.append((-0.5, 0, 0.5, 2))
    circles.append((0.5, 0, 0.5, 2))
    
    # Circle of curvature 3 (radius 1/3)
    # Tangent to both k=2 circles and to the outer circle
    circles.append((0, 2/3, 1/3, 3))
    
    # Generate more circles by the Apollonian packing algorithm
    def find_inscribed_circle(c1, c2, c3):
        """Find the inscribed circle tangent to three given circles."""
        x1, y1, r1, k1 = c1
        x2, y2, r2, k2 = c2
        x3, y3, r3, k3 = c3
        
        # Use Descartes circle theorem for curvature
        k4_candidates = solve_descartes(k1, k2, k3)
        
        results = []
        for k4 in k4_candidates:
            if k4 <= max(k1, k2, k3) or k4 < 0:
                continue
            if abs(k4) < 1e-10:
                continue
            r4 = 1.0 / k4
            
            # Solve for center using complex Descartes theorem
            z1 = complex(x1, y1) * k1
            z2 = complex(x2, y2) * k2
            z3 = complex(x3, y3) * k3
            
            sz = z1 + z2 + z3
            inner = z1*z2 + z2*z3 + z3*z1
            
            for sign in [1, -1]:
                try:
                    z4 = (sz + sign * 2 * np.sqrt(inner)) / k4
                    x4, y4 = z4.real, z4.imag
                    
                    # Verify tangency
                    d1 = np.sqrt((x4-x1)**2 + (y4-y1)**2)
                    d2 = np.sqrt((x4-x2)**2 + (y4-y2)**2)
                    d3 = np.sqrt((x4-x3)**2 + (y4-y3)**2)
                    
                    ok1 = abs(d1 - abs(r1 + r4 * (1 if k1 > 0 else -1))) < 0.01 * max(r4, abs(r1))
                    ok2 = abs(d2 - abs(r2 + r4 * (1 if k2 > 0 else -1))) < 0.01 * max(r4, abs(r2))
                    
                    if abs(x4) < 2 and abs(y4) < 2:
                        results.append((x4, y4, r4, k4))
                except:
                    pass
        
        return results
    
    # Simple recursive packing
    min_radius = 0.005
    
    def add_circles_recursive(triplets, depth=0, max_depth=6):
        if depth >= max_depth:
            return
        new_triplets = []
        for c1, c2, c3 in triplets:
            inscribed = find_inscribed_circle(c1, c2, c3)
            for c4 in inscribed:
                if c4[2] < min_radius:
                    continue
                # Check if already exists
                exists = False
                for c in circles:
                    if abs(c[0]-c4[0]) < 0.001 and abs(c[1]-c4[1]) < 0.001:
                        exists = True
                        break
                if not exists:
                    circles.append(c4)
                    new_triplets.append((c1, c2, c4))
                    new_triplets.append((c1, c3, c4))
                    new_triplets.append((c2, c3, c4))
        if new_triplets:
            add_circles_recursive(new_triplets, depth + 1, max_depth)
    
    # Initial triplets (each triple of mutually tangent circles)
    c_out = circles[0]
    c1 = circles[1]
    c2 = circles[2]
    c3 = circles[3]
    
    initial_triplets = [
        (c_out, c1, c2),
        (c_out, c1, c3),
        (c_out, c2, c3),
        (c1, c2, c3),
    ]
    
    add_circles_recursive(initial_triplets, max_depth=5)
    
    # Draw
    ax.set_aspect('equal')
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_facecolor('#0a0a2a')
    fig.patch.set_facecolor('#0a0a2a')
    
    for x, y, r, k in circles:
        if k < 0:  # outer circle
            circle = Circle((x, y), r, fill=False, edgecolor='#4488ff', linewidth=1.5)
        else:
            alpha = max(0.3, min(1.0, 0.1 + 0.05 * k))
            color = plt.cm.plasma(min(1.0, k / 50))
            circle = Circle((x, y), r, fill=False, edgecolor=color, linewidth=0.8, alpha=alpha)
        ax.add_patch(circle)
    
    ax.set_title('Apollonian Gasket', color='white', fontsize=16, pad=15)
    ax.axis('off')
    
    return fig_to_base64(fig)


def generate_spectral_decay_figure():
    """Generate figure showing geometric decay of observables under averaging."""
    gens = apollonian_generators()
    
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.patch.set_facecolor('white')
    
    for idx, k in enumerate([1, 2, 3]):
        ax = axes[idx]
        T_k, basis = build_observable_operator(gens, k)
        analysis = spectral_gap_analysis(T_k)
        
        # Normalize operator
        max_ev = analysis['max_eigenvalue']
        T_norm = T_k / max_ev if max_ev > 0 else T_k
        
        # Take several random centered vectors
        dim = T_k.shape[0]
        eigenvalues = analysis['eigenvalues']
        eigenvectors = analysis['eigenvectors']
        
        # Build projection onto complement of leading eigenvector
        inv_dim = analysis['invariant_dim']
        P_inv = np.zeros((dim, dim))
        for i in range(inv_dim):
            ev = np.real(eigenvectors[:, i:i+1])
            P_inv += ev @ ev.T / (ev.T @ ev)
        P_comp = np.eye(dim) - P_inv
        
        np.random.seed(42)
        n_max = 20
        
        for trial in range(5):
            v = np.random.randn(dim)
            v = P_comp @ v
            v_norm = np.linalg.norm(v)
            if v_norm < 1e-10:
                continue
            
            norms = [v_norm]
            w = v.copy()
            for n in range(1, n_max + 1):
                w = T_norm @ w
                norms.append(np.linalg.norm(w))
            
            ax.semilogy(range(n_max + 1), norms, 'o-', alpha=0.5, markersize=3)
        
        # Plot theoretical bound
        gap = analysis['relative_gap']
        bound = [v_norm * (1 - gap)**n for n in range(n_max + 1)]
        ax.semilogy(range(n_max + 1), bound, 'r--', linewidth=2, 
                    label=f'$(1-\\gamma)^n$, $\\gamma$={gap:.3f}')
        
        ax.set_xlabel('Iteration n')
        ax.set_ylabel('$\\|T^n v\\|$')
        ax.set_title(f'Degree ≤ {k} (dim={dim})')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('Spectral Decay of Centered Observables under Apollonian Averaging', 
                 fontsize=14, y=1.02)
    plt.tight_layout()
    
    return fig_to_base64(fig)


def generate_eigenvalue_figure():
    """Generate figure showing eigenvalue distribution for different degrees."""
    gens = apollonian_generators()
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
    
    for idx, k in enumerate(range(1, 5)):
        T_k, basis = build_observable_operator(gens, k)
        eigenvalues = np.linalg.eigvals(T_k)
        
        # Plot on complex plane
        ax.scatter(np.real(eigenvalues), np.imag(eigenvalues), 
                  s=50, c=colors[idx], label=f'Degree ≤ {k} (dim={len(basis)})',
                  alpha=0.7, zorder=5-idx)
    
    # Add unit circle for reference
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.2, linewidth=0.5)
    
    ax.set_xlabel('Re(λ)', fontsize=12)
    ax.set_ylabel('Im(λ)', fontsize=12)
    ax.set_title('Eigenvalue Spectrum of Apollonian Averaging Operator $T_k$', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)
    
    plt.tight_layout()
    return fig_to_base64(fig)


def generate_orbit_growth_figure():
    """Generate figure showing Apollonian orbit growth statistics."""
    root = np.array([-1, 2, 2, 3])
    orbit = enumerate_apollonian_orbit(root, max_depth=8)
    
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    depths = [d['depth'] for d in orbit['depth_data']]
    total_quads = [d['total_quadruples'] for d in orbit['depth_data']]
    max_curvs = [d['max_curvature'] for d in orbit['depth_data']]
    
    axes[0].semilogy(depths, total_quads, 'bo-', markersize=8, linewidth=2)
    axes[0].set_xlabel('BFS Depth', fontsize=12)
    axes[0].set_ylabel('Total Quadruples', fontsize=12)
    axes[0].set_title('Orbit Growth (log scale)', fontsize=14)
    axes[0].grid(True, alpha=0.3)
    
    axes[1].semilogy(depths, max_curvs, 'rs-', markersize=8, linewidth=2)
    axes[1].set_xlabel('BFS Depth', fontsize=12)
    axes[1].set_ylabel('Maximum Curvature', fontsize=12)
    axes[1].set_title('Maximum Curvature Growth', fontsize=14)
    axes[1].grid(True, alpha=0.3)
    
    fig.suptitle('Apollonian Orbit from Root (-1, 2, 2, 3)', fontsize=14, y=1.02)
    plt.tight_layout()
    
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    print("  1/4: Apollonian gasket...")
    gasket_b64 = generate_apollonian_gasket_figure()
    print(f"    Done ({len(gasket_b64)} chars)")
    
    print("  2/4: Spectral decay...")
    decay_b64 = generate_spectral_decay_figure()
    print(f"    Done ({len(decay_b64)} chars)")
    
    print("  3/4: Eigenvalue spectrum...")
    eigen_b64 = generate_eigenvalue_figure()
    print(f"    Done ({len(eigen_b64)} chars)")
    
    print("  4/4: Orbit growth...")
    orbit_b64 = generate_orbit_growth_figure()
    print(f"    Done ({len(orbit_b64)} chars)")
    
    print("\nAll visualizations generated successfully.")
    
    # Save individually for debugging
    for name, data in [("gasket", gasket_b64), ("decay", decay_b64), 
                        ("eigenvalue", eigen_b64), ("orbit", orbit_b64)]:
        # Extract raw PNG
        raw = base64.b64decode(data.split(",")[1])
        with open(f"viz_{name}.png", "wb") as f:
            f.write(raw)
        print(f"  Saved viz_{name}.png")
