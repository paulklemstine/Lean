"""
applications.py — Real-world applications of Lorentzian Stability Radii

Demonstrates how the spectral stability theory for uniform matroids connects to:
1. Certified robustness for strongly log-concave sampling
2. Perturbation tolerance in combinatorial optimization
3. Spectral graph theory and association schemes
"""

import numpy as np
from math import comb, factorial


def leaf_hessian(m):
    """The canonical leaf Hessian J - I."""
    return np.ones((m, m)) - np.eye(m)


def check_lorentzian(A, tol=1e-10):
    """Check Lorentzian signature condition."""
    eigs = np.linalg.eigvalsh(A)
    return np.sum(eigs > tol) <= 1, eigs


# =============================================================================
# Application 1: Certified Robustness for Log-Concave Sampling
# =============================================================================

def certified_sampling_perturbation(n, r, noise_level):
    """
    Determine whether a noisy version of the uniform matroid generating
    polynomial remains Lorentzian (and hence suitable for strongly log-concave
    sampling).

    In algorithms for sampling bases of matroids (e.g., Anari-Liu-Oveis Gharan-
    Vinzant), the generating polynomial must be Lorentzian. If coefficients
    are known only approximately (due to floating-point errors, data noise,
    or model uncertainty), we need certified robustness guarantees.

    Parameters
    ----------
    n : int
        Ground set size.
    r : int
        Rank.
    noise_level : float
        Maximum entry-wise perturbation of the leaf Hessian.

    Returns
    -------
    dict
        Certification result with details.
    """
    m = n - r + 2
    spectral_gap = 1.0
    entry_radius = 1.0 / (m * m)

    # Check if noise is within certified radius
    is_certified = noise_level <= entry_radius

    # Also check empirically with a random perturbation
    H = leaf_hessian(m)
    E = np.random.uniform(-noise_level, noise_level, (m, m))
    E = (E + E.T) / 2
    is_lor, eigs = check_lorentzian(H + E)

    return {
        'n': n, 'r': r, 'm': m,
        'noise_level': noise_level,
        'entry_radius': entry_radius,
        'spectral_gap': spectral_gap,
        'is_certified': is_certified,
        'is_empirically_lorentzian': is_lor,
        'perturbed_eigenvalues': np.sort(eigs)[::-1],
        'margin': entry_radius - noise_level if is_certified else noise_level - entry_radius,
    }


# =============================================================================
# Application 2: Combinatorial Optimization Under Uncertainty
# =============================================================================

def optimization_robustness(n, r, cost_uncertainty):
    """
    Analyze robustness of matroid-based optimization under cost uncertainty.

    In combinatorial optimization over matroids, the generating polynomial
    encodes the feasible set. When costs are uncertain, the effective
    generating polynomial is perturbed. Our stability radius tells us
    how much cost uncertainty the Lorentzian structure can tolerate.

    Parameters
    ----------
    n : int
        Ground set size.
    r : int
        Rank (size of feasible sets).
    cost_uncertainty : float
        Maximum fractional uncertainty in element costs.

    Returns
    -------
    dict
        Analysis results.
    """
    m = n - r + 2
    num_bases = comb(n, r)

    # The stability radius in coefficient space
    coeff_radius = 1.0 / (m * m)

    # How this translates to cost perturbation tolerance
    # A cost perturbation of ε on each element affects leaf Hessian entries
    # by at most ε * (scaling factor depending on r)
    effective_perturbation = cost_uncertainty * r

    is_safe = effective_perturbation <= coeff_radius

    return {
        'n': n, 'r': r, 'm': m,
        'num_bases': num_bases,
        'coefficient_radius': coeff_radius,
        'cost_uncertainty': cost_uncertainty,
        'effective_perturbation': effective_perturbation,
        'is_safe': is_safe,
        'safety_factor': coeff_radius / effective_perturbation if effective_perturbation > 0 else float('inf'),
    }


# =============================================================================
# Application 3: Complete Graph Spectral Theory
# =============================================================================

def complete_graph_connection(m):
    """
    Demonstrate the connection between the leaf Hessian J - I and the
    complete graph K_m.

    The adjacency matrix of K_m is exactly J - I, so the Lorentzian
    stability analysis is equivalent to spectral perturbation theory
    of the complete graph.

    Parameters
    ----------
    m : int
        Number of vertices (= number of leaf variables).

    Returns
    -------
    dict
        Spectral data connecting to graph theory.
    """
    H = leaf_hessian(m)
    eigs = np.linalg.eigvalsh(H)

    # Verify eigenvalues match K_m theory
    expected_large = m - 1
    expected_small = -1

    # Connection to Johnson scheme J(n, 2)
    # The Johnson scheme at level 1 has the same eigenvalue structure

    return {
        'm': m,
        'adjacency_matrix': H,
        'eigenvalues': np.sort(eigs)[::-1],
        'expected_eigenvalues': [expected_large] + [expected_small] * (m - 1),
        'spectral_gap': expected_large - expected_small,
        'algebraic_connectivity': abs(expected_small),  # Fiedler value for K_m
        'chromatic_number': m,  # χ(K_m) = m
        'independence_number': 1,  # α(K_m) = 1
        'is_strongly_regular': True,  # K_m is trivially strongly regular
        'graph_energy': abs(expected_large) + (m - 1) * abs(expected_small),
    }


# =============================================================================
# Application 4: Phase Transition Analysis
# =============================================================================

def phase_transition_analysis(m, n_points=50):
    """
    Analyze the phase transition in Lorentzian signature as perturbation
    magnitude increases from 0 to beyond the critical threshold.

    This models the transition as analogous to a phase boundary in
    statistical physics: below the threshold, the system is in the
    "Lorentzian phase" (well-conditioned), and above it transitions
    to the "non-Lorentzian phase" (ill-conditioned).

    Parameters
    ----------
    m : int
        Number of variables.
    n_points : int
        Number of perturbation magnitudes to test.

    Returns
    -------
    dict
        Phase transition data.
    """
    magnitudes = np.linspace(0, 2.0, n_points)
    is_lorentzian = []
    min_negative_eigenvalue = []
    max_second_eigenvalue = []

    H = leaf_hessian(m)

    for t in magnitudes:
        E = t * np.eye(m)
        A = H + E
        eigs = np.sort(np.linalg.eigvalsh(A))[::-1]

        is_lor = np.sum(eigs > 1e-10) <= 1
        is_lorentzian.append(is_lor)

        if len(eigs) > 1:
            max_second_eigenvalue.append(eigs[1])
            min_negative_eigenvalue.append(eigs[-1])
        else:
            max_second_eigenvalue.append(0)
            min_negative_eigenvalue.append(0)

    # Find transition point
    transition_idx = None
    for i in range(1, len(is_lorentzian)):
        if is_lorentzian[i - 1] and not is_lorentzian[i]:
            transition_idx = i
            break

    return {
        'm': m,
        'magnitudes': magnitudes,
        'is_lorentzian': is_lorentzian,
        'second_eigenvalue': np.array(max_second_eigenvalue),
        'min_eigenvalue': np.array(min_negative_eigenvalue),
        'transition_point': magnitudes[transition_idx] if transition_idx else None,
        'predicted_transition': 1.0,
    }


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Applications of Lorentzian Stability Radii                 ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # Application 1: Certified Sampling
    print("\n" + "=" * 60)
    print("  Application 1: Certified Robustness for Sampling")
    print("=" * 60)

    for noise in [0.001, 0.01, 0.05, 0.1]:
        result = certified_sampling_perturbation(8, 3, noise)
        status = "✓ CERTIFIED" if result['is_certified'] else "✗ UNCERTIFIED"
        emp = "✓ Lor." if result['is_empirically_lorentzian'] else "✗ Non-Lor."
        print(f"  U_{{3,8}}, noise={noise:.3f}: {status} (empirical: {emp}), "
              f"radius={result['entry_radius']:.6f}")

    # Application 2: Optimization
    print("\n" + "=" * 60)
    print("  Application 2: Optimization Under Uncertainty")
    print("=" * 60)

    for unc in [0.001, 0.005, 0.01, 0.05]:
        result = optimization_robustness(10, 4, unc)
        status = "SAFE" if result['is_safe'] else "UNSAFE"
        print(f"  U_{{4,10}}, uncertainty={unc:.3f}: {status}, "
              f"safety_factor={result['safety_factor']:.2f}")

    # Application 3: Graph Theory
    print("\n" + "=" * 60)
    print("  Application 3: Complete Graph Spectral Theory")
    print("=" * 60)

    for m in [3, 5, 8, 12]:
        result = complete_graph_connection(m)
        print(f"  K_{m}: eigenvalues = {{{m-1}, -1^{{{m-1}}}}}, "
              f"gap = {result['spectral_gap']}, "
              f"energy = {result['graph_energy']}")

    # Application 4: Phase Transition
    print("\n" + "=" * 60)
    print("  Application 4: Phase Transition Analysis")
    print("=" * 60)

    for m in [3, 5, 8]:
        result = phase_transition_analysis(m)
        print(f"  m={m}: transition at t* = {result['transition_point']:.4f} "
              f"(predicted: {result['predicted_transition']:.4f})")


if __name__ == '__main__':
    main()


"""
demo.py — Interactive demonstration of Lorentzian Stability Radii for Uniform Matroids

Demonstrates the spectral mechanism governing Lorentzian breakdown in uniform matroid
generating polynomials, including:
1. The canonical leaf Hessian and its spectral decomposition
2. The predicted stability radius vs empirical instability search
3. Comparison across all uniform matroids with n ≤ 15
"""

import numpy as np
from math import comb


def leaf_hessian(m):
    """The canonical leaf Hessian J - I for e₂ on m variables."""
    return np.ones((m, m)) - np.eye(m)


def check_lorentzian(A, tol=1e-10):
    """Check if a matrix has at most one positive eigenvalue."""
    eigs = np.linalg.eigvalsh(A)
    return np.sum(eigs > tol) <= 1, eigs


def find_instability_threshold(m, direction='identity', n_trials=200, tol=1e-6):
    """
    Binary search for the critical perturbation magnitude that breaks Lorentzianity.

    Parameters
    ----------
    m : int
        Matrix dimension.
    direction : str
        'identity' for t*I perturbation, 'random' for random entry perturbation.
    n_trials : int
        Number of random trials per magnitude (for 'random' direction).
    tol : float
        Binary search tolerance.

    Returns
    -------
    float
        Critical perturbation magnitude.
    """
    lo, hi = 0.0, 3.0

    while hi - lo > tol:
        mid = (lo + hi) / 2

        if direction == 'identity':
            E = mid * np.eye(m)
            A = leaf_hessian(m) + E
            is_lor, _ = check_lorentzian(A)
            if is_lor:
                lo = mid
            else:
                hi = mid
        else:
            # Random entry perturbation
            broke = False
            for _ in range(n_trials):
                E = np.random.uniform(-mid, mid, (m, m))
                E = (E + E.T) / 2
                A = leaf_hessian(m) + E
                is_lor, _ = check_lorentzian(A)
                if not is_lor:
                    broke = True
                    break
            if broke:
                hi = mid
            else:
                lo = mid

    return (lo + hi) / 2


def display_hessian(m):
    """Display the canonical leaf Hessian and its spectral data."""
    H = leaf_hessian(m)
    eigs = np.linalg.eigvalsh(H)

    print(f"\n{'='*60}")
    print(f"  Canonical Leaf Hessian for m = {m}")
    print(f"{'='*60}")
    print(f"\n  H = J - I  (J = all-ones, I = identity)")
    print(f"\n  Matrix ({m}×{m}):")
    for i in range(m):
        row = '  '.join(f'{H[i,j]:4.0f}' for j in range(m))
        print(f"    [{row}]")

    print(f"\n  Eigenvalues: {np.sort(eigs)[::-1]}")
    print(f"  Positive eigenvalue: {m-1} (multiplicity 1)")
    print(f"  Negative eigenvalue: -1 (multiplicity {m-1})")
    print(f"  Spectral gap: 1")
    print(f"  Normalized gap: 1/{m-1} = {1.0/(m-1):.6f}")

    # Quadratic form decomposition demo
    v = np.random.randn(m)
    v_sum = np.sum(v)
    v_normsq = np.sum(v**2)
    qf = v_sum**2 - v_normsq
    qf_check = v @ H @ v
    print(f"\n  Quadratic form check:")
    print(f"    v = [{', '.join(f'{x:.3f}' for x in v)}]")
    print(f"    Q(v) = (Σvᵢ)² - Σvᵢ² = {v_sum**2:.4f} - {v_normsq:.4f} = {qf:.4f}")
    print(f"    v^T H v = {qf_check:.4f}  ✓" if abs(qf - qf_check) < 1e-8
          else f"    v^T H v = {qf_check:.4f}  MISMATCH!")


def run_stability_analysis(n, r):
    """Run full stability analysis for a specific uniform matroid U_{r,n}."""
    m = n - r + 2
    print(f"\n{'='*60}")
    print(f"  Stability Analysis for U_{{{r},{n}}} (m = {m})")
    print(f"{'='*60}")

    display_hessian(m)

    # Predicted radius
    gap = 1.0
    entry_radius = 1.0 / (m * m)
    qf_radius = gap

    print(f"\n  --- Stability Radii ---")
    print(f"  Spectral gap (quadratic form bound):  δ < {qf_radius}")
    print(f"  Entry-wise certified radius:          ε ≤ {entry_radius:.6f} = 1/{m}²")

    # Identity perturbation threshold
    print(f"\n  --- Instability Search (t·I perturbation) ---")
    thresh_id = find_instability_threshold(m, direction='identity')
    print(f"  Critical threshold:  t* = {thresh_id:.6f}")
    print(f"  Predicted threshold: t* = 1.000000 (spectral gap)")
    print(f"  Ratio:               {thresh_id / 1.0:.6f}")

    # Random entry perturbation threshold
    print(f"\n  --- Instability Search (random entry perturbation) ---")
    thresh_rand = find_instability_threshold(m, direction='random', n_trials=500)
    print(f"  Critical entry magnitude: ε* ≈ {thresh_rand:.6f}")
    print(f"  Certified lower bound:    ε  = {entry_radius:.6f} = 1/{m}²")
    if entry_radius > 0:
        print(f"  Ratio (empirical/certified): {thresh_rand / entry_radius:.2f}")

    return {
        'n': n, 'r': r, 'm': m,
        'spectral_gap': gap,
        'entry_radius': entry_radius,
        'identity_threshold': thresh_id,
        'random_threshold': thresh_rand,
    }


def comprehensive_table(max_n=15):
    """Print a comprehensive table for all valid (n, r) pairs."""
    print(f"\n{'='*80}")
    print(f"  Comprehensive Stability Table for Uniform Matroids U_{{r,n}}, n ≤ {max_n}")
    print(f"{'='*80}")
    print(f"{'n':>3} {'r':>3} {'m':>3} {'C(n,r)':>8} {'gap':>5} {'1/m²':>10} "
          f"{'t*(I)':>8} {'ε*(rand)':>10} {'ratio':>7}")
    print("-" * 80)

    results = []
    for n in range(4, max_n + 1):
        for r in range(2, n - 1):
            m = n - r + 2
            binom = comb(n, r)
            gap = 1.0
            entry_rad = 1.0 / (m * m)

            # Quick identity threshold
            thresh_id = find_instability_threshold(m, direction='identity', tol=1e-4)

            # Quick random threshold
            thresh_rand = find_instability_threshold(m, direction='random',
                                                      n_trials=100, tol=1e-4)

            ratio = thresh_rand / entry_rad if entry_rad > 0 else float('inf')

            print(f"{n:3d} {r:3d} {m:3d} {binom:8d} {gap:5.1f} {entry_rad:10.6f} "
                  f"{thresh_id:8.4f} {thresh_rand:10.6f} {ratio:7.2f}")

            results.append({
                'n': n, 'r': r, 'm': m, 'binom': binom,
                'gap': gap, 'entry_radius': entry_rad,
                'identity_threshold': thresh_id,
                'random_threshold': thresh_rand,
                'ratio': ratio,
            })

    # Summary statistics
    ratios = [r['ratio'] for r in results if r['ratio'] < float('inf')]
    if ratios:
        print(f"\n  Summary:")
        print(f"    Empirical/Certified ratio range: [{min(ratios):.2f}, {max(ratios):.2f}]")
        print(f"    Mean ratio: {np.mean(ratios):.2f}")
        print(f"    This confirms the certified radius 1/m² is conservative,")
        print(f"    and the true entry-wise radius is approximately {np.mean(ratios):.1f}× larger.")

    return results


def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Lorentzian Stability Radii for Uniform Matroid Families    ║")
    print("║  Spectral Mechanism of Lorentzian Breakdown                 ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    while True:
        print("\n  Options:")
        print("    1. Analyze a specific uniform matroid U_{r,n}")
        print("    2. Display the canonical leaf Hessian")
        print("    3. Run comprehensive table (n ≤ 15)")
        print("    4. Quick demo (default: U_{3,7})")
        print("    5. Exit")

        try:
            choice = input("\n  Enter choice (1-5): ").strip()
        except EOFError:
            choice = '4'

        if choice == '1':
            try:
                n = int(input("  Enter n (ground set size): "))
                r = int(input("  Enter r (rank, 2 ≤ r ≤ n-2): "))
                if r < 2 or r > n - 2:
                    print("  Invalid: need 2 ≤ r ≤ n-2")
                    continue
                run_stability_analysis(n, r)
            except (ValueError, EOFError):
                print("  Invalid input.")

        elif choice == '2':
            try:
                m = int(input("  Enter m (number of variables): "))
                display_hessian(m)
            except (ValueError, EOFError):
                print("  Invalid input.")

        elif choice == '3':
            comprehensive_table(15)

        elif choice == '4':
            run_stability_analysis(7, 3)
            break

        elif choice == '5':
            break

        else:
            # Default: run quick demo
            run_stability_analysis(7, 3)
            break


if __name__ == '__main__':
    main()


"""
Visualization 3: Quadratic Form Decomposition

Visualizes the quadratic form Q(v) = (∑vᵢ)² - ∑vᵢ² for the leaf Hessian J - I
on a 2D slice. Shows how the positive (sum-squared) and negative (norm-squared)
components interact to create the Lorentzian signature with exactly one positive
eigenvalue direction.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# --- Panel 1: 2D quadratic form contours ---
ax = axes[0, 0]
x = np.linspace(-2, 2, 200)
y = np.linspace(-2, 2, 200)
X, Y = np.meshgrid(x, y)

# Q(v) = (x + y)² - (x² + y²) = 2xy for m=2
Q = (X + Y)**2 - (X**2 + Y**2)

contour = ax.contourf(X, Y, Q, levels=20, cmap='RdBu_r', alpha=0.8)
ax.contour(X, Y, Q, levels=[0], colors='black', linewidths=2)
plt.colorbar(contour, ax=ax, label='Q(v₁, v₂)')
ax.set_xlabel('v₁', fontsize=12)
ax.set_ylabel('v₂', fontsize=12)
ax.set_title('Quadratic Form Q = 2v₁v₂ (m=2)', fontsize=13)
ax.arrow(0, 0, 1, 1, head_width=0.1, head_length=0.05, fc='green', ec='green', linewidth=2)
ax.arrow(0, 0, 1, -1, head_width=0.1, head_length=0.05, fc='red', ec='red', linewidth=2)
ax.text(1.1, 1.1, '+', fontsize=14, color='green', fontweight='bold')
ax.text(1.1, -1.1, '−', fontsize=14, color='red', fontweight='bold')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 2: 3D slice for m=3 ---
ax = axes[0, 1]
# Fix v₃ = 0, plot Q(v₁, v₂, 0) = (v₁ + v₂)² - (v₁² + v₂²) = 2v₁v₂
Q3 = (X + Y)**2 - (X**2 + Y**2)  # Same as m=2 slice
contour = ax.contourf(X, Y, Q3, levels=20, cmap='RdBu_r', alpha=0.8)
ax.contour(X, Y, Q3, levels=[0], colors='black', linewidths=2)
plt.colorbar(contour, ax=ax, label='Q(v₁, v₂, 0)')
ax.set_xlabel('v₁', fontsize=12)
ax.set_ylabel('v₂', fontsize=12)
ax.set_title('Leaf Q-form slice: m=3, v₃=0', fontsize=13)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# --- Panel 3: Decomposition along radial directions ---
ax = axes[1, 0]
theta = np.linspace(0, 2 * np.pi, 360)

for m in [2, 3, 5, 8]:
    # On the unit circle in 2D subspace: v = (cos θ, sin θ, 0, ..., 0)
    sum_v = np.cos(theta) + np.sin(theta)
    norm_v = 1.0  # unit vector
    Q_vals = sum_v**2 - norm_v
    ax.plot(np.degrees(theta), Q_vals, linewidth=2, label=f'm={m} (2D slice)')

ax.axhline(y=0, color='black', linewidth=0.5)
ax.axhline(y=-1, color='red', linestyle='--', linewidth=1, alpha=0.5, label='Gap = -1')
ax.set_xlabel('Angle θ (degrees)', fontsize=12)
ax.set_ylabel('Q(v)', fontsize=12)
ax.set_title('Q along unit circle in 2D subspace', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Panel 4: Eigenvalue structure as bar chart ---
ax = axes[1, 1]
ms = [3, 5, 8, 12]
x_pos = np.arange(len(ms))
bar_width = 0.35

pos_eigs = [m - 1 for m in ms]
neg_eigs = [-1 for _ in ms]

bars1 = ax.bar(x_pos - bar_width/2, pos_eigs, bar_width, label='λ₁ = m-1',
               color='steelblue', alpha=0.8)
bars2 = ax.bar(x_pos + bar_width/2, neg_eigs, bar_width, label='λ₂ = -1',
               color='indianred', alpha=0.8)

ax.set_xlabel('Number of variables m', fontsize=12)
ax.set_ylabel('Eigenvalue', fontsize=12)
ax.set_title('Eigenvalue Structure of J - I', fontsize=13)
ax.set_xticks(x_pos)
ax.set_xticklabels([str(m) for m in ms])
ax.legend(fontsize=10)
ax.axhline(y=0, color='black', linewidth=0.5)
ax.grid(True, alpha=0.3, axis='y')

# Add multiplicity annotations
for i, m in enumerate(ms):
    ax.text(i - bar_width/2, pos_eigs[i] + 0.3, '×1', ha='center', fontsize=9)
    ax.text(i + bar_width/2, neg_eigs[i] - 0.8, f'×{m-1}', ha='center', fontsize=9)

fig.suptitle('Quadratic Form Decomposition: Q(v) = (Σvᵢ)² − Σvᵢ²',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_quadform_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_quadform_decomposition.png")


"""
Visualization 1: Spectral Gap and Phase Transition

Visualizes how the eigenvalues of the perturbed leaf Hessian (J - I + t·I)
change as t increases from 0 to 2, showing the exact phase transition at t = 1
where the Lorentzian signature breaks down. This is the spectral mechanism
governing Lorentzian stability.
"""

import numpy as np
import matplotlib.pyplot as plt

def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, m in enumerate([3, 5, 8]):
    ax = axes[idx]
    H = leaf_hessian(m)
    ts = np.linspace(0, 2.5, 200)

    all_eigs = []
    for t in ts:
        eigs = np.sort(np.linalg.eigvalsh(H + t * np.eye(m)))[::-1]
        all_eigs.append(eigs)
    all_eigs = np.array(all_eigs)

    # Plot each eigenvalue trajectory
    ax.plot(ts, all_eigs[:, 0], 'b-', linewidth=2, label=f'λ₁ = {m-1} + t')
    for k in range(1, m):
        label = 'λ₂…λₘ = -1 + t' if k == 1 else None
        ax.plot(ts, all_eigs[:, k], 'r-', linewidth=1.5, alpha=0.7, label=label)

    # Mark the critical threshold
    ax.axvline(x=1.0, color='green', linestyle='--', linewidth=2, alpha=0.7,
               label='Critical t* = 1')
    ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)

    # Shade regions
    ax.axvspan(0, 1.0, alpha=0.1, color='blue', label='Lorentzian')
    ax.axvspan(1.0, 2.5, alpha=0.1, color='red', label='Non-Lorentzian')

    ax.set_xlabel('Perturbation magnitude t', fontsize=12)
    ax.set_ylabel('Eigenvalue', fontsize=12)
    ax.set_title(f'K_{m} Leaf Hessian (m = {m})', fontsize=14)
    ax.legend(fontsize=8, loc='upper left')
    ax.set_xlim(0, 2.5)
    ax.grid(True, alpha=0.3)

fig.suptitle('Phase Transition in Lorentzian Signature Under Perturbation',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_gap.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_gap.png")


"""
Visualization 2: Stability Radius Heatmap

Displays the certified entry-wise stability radius 1/m² as a heatmap across
all valid uniform matroids U_{r,n} with n ≤ 15, 2 ≤ r ≤ n-2.
Also shows the empirical-to-certified ratio, revealing how conservative
the certified bound is.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

max_n = 15
# Compute data
data_radius = np.full((max_n + 1, max_n + 1), np.nan)
data_normalized = np.full((max_n + 1, max_n + 1), np.nan)

for n in range(4, max_n + 1):
    for r in range(2, n - 1):
        m = n - r + 2
        entry_radius = 1.0 / (m * m)
        normalized_gap = 1.0 / (m - 1) if m > 1 else 0
        data_radius[n, r] = np.log10(entry_radius)
        data_normalized[n, r] = normalized_gap

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap 1: Entry-wise stability radius (log scale)
ax1 = axes[0]
im1 = ax1.imshow(data_radius[4:, 2:], aspect='auto', origin='lower',
                  cmap='viridis', interpolation='nearest',
                  extent=[1.5, max_n - 0.5, 3.5, max_n + 0.5])
ax1.set_xlabel('Rank r', fontsize=12)
ax1.set_ylabel('Ground set size n', fontsize=12)
ax1.set_title('log₁₀(Entry-wise Stability Radius)', fontsize=14)
cb1 = plt.colorbar(im1, ax=ax1)
cb1.set_label('log₁₀(1/m²)', fontsize=10)

# Add text annotations for small values
for n in range(4, min(max_n + 1, 10)):
    for r in range(2, n - 1):
        m = n - r + 2
        val = 1.0 / (m * m)
        if not np.isnan(data_radius[n, r]):
            ax1.text(r, n, f'{val:.3f}', ha='center', va='center',
                    fontsize=6, color='white' if val < 0.05 else 'black')

# Heatmap 2: Normalized spectral gap
ax2 = axes[1]
im2 = ax2.imshow(data_normalized[4:, 2:], aspect='auto', origin='lower',
                  cmap='plasma', interpolation='nearest',
                  extent=[1.5, max_n - 0.5, 3.5, max_n + 0.5])
ax2.set_xlabel('Rank r', fontsize=12)
ax2.set_ylabel('Ground set size n', fontsize=12)
ax2.set_title('Normalized Spectral Gap 1/(m-1)', fontsize=14)
cb2 = plt.colorbar(im2, ax=ax2)
cb2.set_label('1/(m-1)', fontsize=10)

# Add text annotations
for n in range(4, min(max_n + 1, 10)):
    for r in range(2, n - 1):
        m = n - r + 2
        if m > 1 and not np.isnan(data_normalized[n, r]):
            ax2.text(r, n, f'{1/(m-1):.2f}', ha='center', va='center',
                    fontsize=6, color='white' if 1/(m-1) < 0.3 else 'black')

fig.suptitle('Lorentzian Stability Landscape for Uniform Matroids',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_stability_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability_heatmap.png")
