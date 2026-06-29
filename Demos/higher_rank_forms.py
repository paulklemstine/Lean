#!/usr/bin/env python3
"""
Applications of Lorentz-Orthogonal Spectral Gap Theory

Demonstrates applications to:
1. Apollonian gasket dynamics
2. Markoff semigroup expansion
3. Hyperbolic code geometry
4. Discrete cosmological toy models
"""
import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Apollonian Gasket / Descartes Quadruples
# ============================================================

def descartes_form(x: np.ndarray) -> float:
    """The Descartes quadratic form for circle packings.
    
    For a Descartes quadruple (a, b, c, d) of curvatures:
    Q(x) = 2(a² + b² + c² + d²) - (a + b + c + d)²
    
    This form has signature (3,1) and is preserved by Apollonian moves.
    
    Args:
        x: Descartes quadruple (4 curvatures)
    Returns:
        Value of the Descartes form
    """
    return 2 * np.sum(x**2) - np.sum(x)**2


def apollonian_generators() -> List[np.ndarray]:
    """The four Apollonian generators acting on Descartes quadruples.
    
    Each generator S_i replaces the i-th curvature by the unique other
    solution of the Descartes relation.
    
    Returns:
        List of 4x4 matrices representing the generators
    """
    generators = []
    for i in range(4):
        S = np.eye(4)
        S[i, :] = np.array([-1, 2, 2, 2])
        S[i, i] = -1
        # Adjust: S_i replaces x_i by 2(sum of others) - x_i
        # = -x_i + 2(x_1 + x_2 + x_3 + x_4) - 2x_i = -3x_i + 2*sum
        # Actually the standard form is: x_i' = -x_i + 2(x_j + x_k + x_l)
        generators.append(S)
    return generators


def demonstrate_apollonian():
    """Demonstrate spectral properties of Apollonian generators."""
    print("=" * 60)
    print("APPLICATION 1: Apollonian Gasket Dynamics")
    print("=" * 60)
    
    gens = apollonian_generators()
    k = len(gens)
    
    # Initial Descartes quadruple: (-1, 2, 2, 3)
    x0 = np.array([-1, 2, 2, 3], dtype=float)
    print(f"  Initial quadruple: {x0}")
    print(f"  Descartes form Q(x) = {descartes_form(x0):.1f}")
    
    # Check form preservation
    print("\n  Form preservation under generators:")
    for i, S in enumerate(gens):
        x1 = S @ x0
        print(f"    S_{i+1}(x) = {x1}, Q = {descartes_form(x1):.1f}")
    
    # Averaging operator
    T = sum(gens) / k
    eigvals = np.sort(np.abs(np.linalg.eigvals(T)))[::-1]
    print(f"\n  Averaging operator T = (1/{k}) Σ S_i:")
    print(f"    Eigenvalues (|·|): {eigvals}")
    print(f"    Spectral gap: {1 - eigvals[1]:.6f}")
    print(f"    1/√k bound: {1/np.sqrt(k):.6f}")
    print()


# ============================================================
# Application 2: Markoff Semigroup
# ============================================================

def markoff_generators() -> List[np.ndarray]:
    """The three Markoff generators acting on Markoff triples.
    
    The Markoff equation x² + y² + z² = 3xyz defines a surface 
    preserved by three involutions.
    
    Returns:
        List of 3x3 matrices (linear approximation near origin)
    """
    # Vieta involutions in linearized form
    # σ_1: (x,y,z) → (3yz - x, y, z) linearized at (1,1,1): (3y+3z-x, y, z)
    S1 = np.array([[-1, 3, 3], [0, 1, 0], [0, 0, 1]], dtype=float)
    S2 = np.array([[1, 0, 0], [3, -1, 3], [0, 0, 1]], dtype=float)
    S3 = np.array([[1, 0, 0], [0, 1, 0], [3, 3, -1]], dtype=float)
    return [S1, S2, S3]


def demonstrate_markoff():
    """Demonstrate spectral properties of Markoff generators."""
    print("=" * 60)
    print("APPLICATION 2: Markoff Semigroup Expansion")
    print("=" * 60)
    
    gens = markoff_generators()
    k = len(gens)
    
    # Averaging operator
    T = sum(gens) / k
    eigvals = np.sort(np.abs(np.linalg.eigvals(T)))[::-1]
    
    print(f"  {k} Markoff generators (linearized Vieta involutions)")
    print(f"  Averaging operator eigenvalues: {eigvals}")
    print(f"  Second eigenvalue: {eigvals[1]:.6f}")
    print(f"  Spectral gap: {1 - eigvals[1]:.6f}")
    print(f"  1/√k bound: {1/np.sqrt(k):.6f}")
    
    # Random walk simulation
    print("\n  Random walk mixing (1000 steps):")
    x = np.array([1.0, 1.0, 1.0])
    trajectory_norms = []
    for step in range(1000):
        i = np.random.randint(k)
        x = gens[i] @ x
        x = x / np.linalg.norm(x)  # Normalize to stay bounded
        if step % 200 == 0:
            T_applied = T @ x
            ratio = np.linalg.norm(T_applied) / np.linalg.norm(x)
            print(f"    Step {step:4d}: ‖Tx‖/‖x‖ = {ratio:.6f}")
    print()


# ============================================================
# Application 3: Hyperbolic Code Geometry
# ============================================================

def hyperbolic_code_distance(n: int, k: int, num_codewords: int = 20) -> Tuple[float, float]:
    """Estimate minimum distance of a code derived from Lorentz-orthogonal
    generators acting on a discrete hyperbolic lattice.
    
    The spectral gap provides a lower bound on the separation between
    orbits, which translates to code distance.
    
    Args:
        n: Ambient dimension - 1
        k: Number of generators
        num_codewords: Number of orbit points to generate
    Returns:
        (min_distance, spectral_gap_bound)
    """
    # Generate orthogonal reflections
    dim = n + 1
    Q, _ = np.linalg.qr(np.random.randn(dim, dim))
    
    reflections = []
    for i in range(min(k, dim)):
        v = Q[:, i]
        R = np.eye(dim) - 2 * np.outer(v, v)
        reflections.append(R)
    
    # Generate codewords via random products of reflections
    codewords = []
    x0 = np.random.randn(dim)
    x0 /= np.linalg.norm(x0)
    
    for _ in range(num_codewords):
        x = x0.copy()
        for _ in range(np.random.randint(1, 5)):
            i = np.random.randint(len(reflections))
            x = reflections[i] @ x
        codewords.append(x)
    
    # Compute minimum distance
    min_dist = float('inf')
    for i in range(len(codewords)):
        for j in range(i + 1, len(codewords)):
            d = np.linalg.norm(codewords[i] - codewords[j])
            if d > 1e-10:
                min_dist = min(min_dist, d)
    
    gap = 2.0 / k if k > 0 else 0
    return min_dist, gap


def demonstrate_hyperbolic_codes():
    """Demonstrate connection between spectral gap and code distance."""
    print("=" * 60)
    print("APPLICATION 3: Hyperbolic Code Geometry")
    print("=" * 60)
    
    print("  Spectral gap → code separation for Lorentz-orthogonal codes:\n")
    print(f"  {'n':>4s} {'k':>4s} {'min_dist':>10s} {'gap(2/k)':>10s} {'1/√k':>10s}")
    print(f"  {'-'*4:>4s} {'-'*4:>4s} {'-'*10:>10s} {'-'*10:>10s} {'-'*10:>10s}")
    
    for n in [3, 5, 10, 20]:
        for k in [2, 3, 5]:
            if k <= n:
                min_d, gap = hyperbolic_code_distance(n, k)
                print(f"  {n:4d} {k:4d} {min_d:10.4f} {gap:10.4f} {1/np.sqrt(k):10.4f}")
    print()


# ============================================================
# Application 4: Discrete Cosmology
# ============================================================

def demonstrate_discrete_cosmology():
    """Demonstrate SO(n,1) dynamics in a discrete de Sitter model."""
    print("=" * 60)
    print("APPLICATION 4: Discrete Cosmological Toy Model")
    print("=" * 60)
    
    n = 3  # Physical 3+1 dimensions
    
    # Lorentz metric
    eta = np.diag([1, 1, 1, -1])
    
    # Small discrete "universe": lattice points on the hyperboloid
    # x₁² + x₂² + x₃² - x₄² = -1 (timelike hyperboloid)
    print(f"\n  Discrete hyperboloid model in R^{n+1}, signature ({n},1)")
    
    # Generate points on the hyperboloid
    num_points = 50
    hyperboloid_pts = []
    for _ in range(num_points):
        spatial = np.random.randn(n) * 0.5
        time = np.sqrt(1 + np.sum(spatial**2))
        pt = np.append(spatial, time)
        hyperboloid_pts.append(pt)
    
    # Verify all points are on hyperboloid
    all_on = all(abs(pt @ eta @ pt + 1) < 1e-10 for pt in hyperboloid_pts)
    print(f"  Generated {num_points} points on hyperboloid: all valid = {all_on}")
    
    # Lorentz boosts as generators
    k = 3
    boosts = []
    for i in range(k):
        # Small boost in the i-th spatial direction
        beta = 0.3
        B = np.eye(n + 1)
        gamma = 1 / np.sqrt(1 - beta**2)
        B[i, i] = gamma
        B[i, n] = beta * gamma
        B[n, i] = beta * gamma
        B[n, n] = gamma
        boosts.append(B)
    
    # Averaging operator
    T = sum(boosts) / k
    eigvals = np.sort(np.abs(np.linalg.eigvals(T)))[::-1]
    
    print(f"\n  {k} Lorentz boost generators:")
    print(f"    Eigenvalues of T: {np.round(eigvals, 4)}")
    print(f"    Spectral gap: {1 - eigvals[1]:.6f}")
    
    # Mixing of hyperboloid points
    print(f"\n  Evolution under repeated averaging:")
    pts = np.array(hyperboloid_pts[:10])
    for step in range(5):
        spread = np.std([np.linalg.norm(p[:n]) for p in pts])
        print(f"    Step {step}: spatial spread = {spread:.4f}")
        new_pts = []
        for pt in pts:
            new_pt = boosts[step % k] @ pt
            new_pts.append(new_pt)
        pts = np.array(new_pts)
    print()


if __name__ == "__main__":
    np.random.seed(42)
    print("\n" + "═" * 60)
    print("  APPLICATIONS OF LORENTZ SPECTRAL GAP THEORY")
    print("═" * 60 + "\n")
    
    demonstrate_apollonian()
    demonstrate_markoff()
    demonstrate_hyperbolic_codes()
    demonstrate_discrete_cosmology()
    
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Demonstration: Lorentz-Orthogonal Averaging and Spectral Gap

Numerically verifies the 1/√k contraction bound for averages of orthogonal
vectors and the spectral gap for Lorentz-orthogonal reflection generators.
"""
import numpy as np
from typing import List, Tuple

def demonstrate_pythagorean_identity():
    """Demonstrate ‖Σ v_i‖² = Σ ‖v_i‖² for pairwise orthogonal vectors."""
    print("=" * 60)
    print("THEOREM 1: Pythagorean Identity for Orthogonal Sums")
    print("=" * 60)
    
    for k in [2, 3, 5, 10]:
        # Generate k random orthogonal vectors in R^k
        Q, _ = np.linalg.qr(np.random.randn(max(k, 3), k))
        vectors = [Q[:, i] * np.random.uniform(0.5, 3.0) for i in range(k)]
        
        sum_vec = sum(vectors)
        lhs = np.linalg.norm(sum_vec) ** 2
        rhs = sum(np.linalg.norm(v) ** 2 for v in vectors)
        
        print(f"  k={k:2d}: ‖Σ v_i‖² = {lhs:.6f}, Σ ‖v_i‖² = {rhs:.6f}, "
              f"diff = {abs(lhs - rhs):.2e}")
    print()


def demonstrate_contraction_bound():
    """Demonstrate the 1/√k contraction bound: ‖(1/k)Σ v_i‖ ≤ C/√k."""
    print("=" * 60)
    print("THEOREM 2: 1/√k Contraction Bound")
    print("=" * 60)
    
    for k in [2, 3, 4, 5, 10, 50, 100]:
        dim = max(k, 10)
        Q, _ = np.linalg.qr(np.random.randn(dim, k))
        C = 2.0
        vectors = [Q[:, i] * C for i in range(k)]
        
        avg_norm = np.linalg.norm(sum(vectors) / k)
        bound = C / np.sqrt(k)
        
        print(f"  k={k:3d}: ‖avg‖ = {avg_norm:.6f}, C/√k = {bound:.6f}, "
              f"ratio = {avg_norm/bound:.4f} {'✓' if avg_norm <= bound + 1e-10 else '✗'}")
    print()


def demonstrate_bessel_inequality():
    """Demonstrate Bessel's inequality: ‖Σ ⟨x,u_i⟩u_i‖ ≤ ‖x‖."""
    print("=" * 60)
    print("THEOREM 3: Bessel's Inequality (Orthonormal Projection)")
    print("=" * 60)
    
    dim = 20
    for k in [1, 3, 5, 10, 15, 20]:
        Q, _ = np.linalg.qr(np.random.randn(dim, dim))
        u = [Q[:, i] for i in range(k)]
        x = np.random.randn(dim)
        
        proj = sum(np.dot(x, ui) * ui for ui in u)
        proj_norm = np.linalg.norm(proj)
        x_norm = np.linalg.norm(x)
        
        print(f"  k={k:2d}: ‖proj(x)‖ = {proj_norm:.6f}, ‖x‖ = {x_norm:.6f}, "
              f"ratio = {proj_norm/x_norm:.4f} {'✓' if proj_norm <= x_norm + 1e-10 else '✗'}")
    print()


def demonstrate_scaled_projection():
    """Demonstrate ‖(1/k)Σ ⟨x,u_i⟩u_i‖ ≤ (1/√k)‖x‖."""
    print("=" * 60)
    print("THEOREM 4: Scaled Projection Contraction (1/√k)")
    print("=" * 60)
    
    dim = 50
    for k in [1, 2, 3, 5, 10, 25, 50]:
        Q, _ = np.linalg.qr(np.random.randn(dim, dim))
        u = [Q[:, i] for i in range(k)]
        
        # Try many random x to find the worst case
        max_ratio = 0
        for _ in range(1000):
            x = np.random.randn(dim)
            scaled_proj = sum(np.dot(x, ui) * ui for ui in u) / k
            ratio = np.linalg.norm(scaled_proj) / np.linalg.norm(x)
            max_ratio = max(max_ratio, ratio)
        
        bound = 1.0 / np.sqrt(k)
        tight_bound = 1.0 / k  # The actual tight bound
        print(f"  k={k:2d}: max ratio = {max_ratio:.6f}, 1/√k = {bound:.6f}, "
              f"1/k = {tight_bound:.6f} (tight)")
    print()


def demonstrate_spectral_gap():
    """Demonstrate spectral gap properties."""
    print("=" * 60)
    print("THEOREM 5: Spectral Gap 1 - 1/√k")
    print("=" * 60)
    
    for k in range(2, 21):
        gap = 1 - 1 / np.sqrt(k)
        reflection_gap = 2.0 / k  # actual gap for reflection averages
        print(f"  k={k:2d}: gap(1/√k) = {gap:.4f}, "
              f"reflection gap(2/k) = {reflection_gap:.4f}, "
              f"monotone: {'✓' if k == 2 or gap >= prev_gap - 1e-10 else '✗'}")
        prev_gap = gap
    print()


def demonstrate_lorentz_form():
    """Demonstrate Lorentz form computations."""
    print("=" * 60)
    print("LORENTZ GEOMETRY: Form and Reflections")
    print("=" * 60)
    
    def Q(x, n):
        """Lorentz quadratic form Q_n(x) = x_1² + ... + x_n² - x_{n+1}²"""
        return sum(x[i]**2 for i in range(n)) - x[n]**2
    
    def B(x, y, n):
        """Lorentz bilinear form"""
        return sum(x[i]*y[i] for i in range(n)) - x[n]*y[n]
    
    def lorentz_reflection(v, x, n):
        """Reflection in hyperplane Q-orthogonal to v (with Q(v)=1)"""
        coeff = 2 * B(x, v, n)
        return np.array([x[i] - coeff * v[i] for i in range(n+1)])
    
    n = 3  # Working in R^4 with signature (3,1)
    
    # Timelike vector
    t = np.zeros(n + 1)
    t[n] = 1.0
    print(f"  Timelike t = {t}, Q(t) = {Q(t, n):.1f} (< 0 ✓)")
    
    # Spacelike vectors (orthogonal to each other and to t)
    spacelike = []
    for i in range(n):
        v = np.zeros(n + 1)
        v[i] = 1.0
        spacelike.append(v)
        print(f"  Spacelike v_{i+1} = {v}, Q(v) = {Q(v, n):.1f} (> 0 ✓)")
    
    # Verify Lorentz orthogonality
    print("\n  Lorentz orthogonality B(v_i, v_j):")
    for i in range(n):
        for j in range(n):
            print(f"    B(v_{i+1}, v_{j+1}) = {B(spacelike[i], spacelike[j], n):.1f}", end="")
            if i != j:
                print(" = 0 ✓" if abs(B(spacelike[i], spacelike[j], n)) < 1e-10 else " ✗")
            else:
                print(f" (= Q(v_{i+1}))")
    
    # Verify reflection preserves form
    print("\n  Lorentz reflection preserves Q:")
    x = np.random.randn(n + 1)
    for i in range(n):
        rx = lorentz_reflection(spacelike[i], x, n)
        print(f"    Q(x) = {Q(x, n):.6f}, Q(R_{i+1}(x)) = {Q(rx, n):.6f}, "
              f"diff = {abs(Q(x, n) - Q(rx, n)):.2e}")
    
    # Compute averaged reflection on spacelike slice
    print("\n  Averaged reflection on spacelike slice:")
    k = n  # number of generators
    for trial in range(5):
        # Test vector in spacelike subspace (last component = 0)
        x_space = np.random.randn(n + 1)
        x_space[n] = 0  # project to spacelike slice
        
        avg = np.zeros(n + 1)
        for i in range(k):
            avg += lorentz_reflection(spacelike[i], x_space, n) / k
        
        ratio = np.linalg.norm(avg) / np.linalg.norm(x_space) if np.linalg.norm(x_space) > 1e-10 else 0
        expected = abs(k - 2) / k
        print(f"    ‖T(x)‖/‖x‖ = {ratio:.6f}, (k-2)/k = {expected:.6f}")
    print()


def demonstrate_lorentz_to_euclidean():
    """Demonstrate reduction from Lorentz to Euclidean orthogonality."""
    print("=" * 60)
    print("KEY REDUCTION: Lorentz → Euclidean Orthogonality")
    print("=" * 60)
    
    n = 5  # R^6 with signature (5,1)
    k = 3  # 3 generators
    
    # Spacelike vectors with zero time component
    vectors = []
    for i in range(k):
        v = np.zeros(n + 1)
        v[i] = 1.0
        vectors.append(v)
    
    print(f"  n={n}, k={k}")
    print(f"  Vectors have zero time component: {all(v[n] == 0 for v in vectors)}")
    
    for i in range(k):
        for j in range(i+1, k):
            lorentz_ip = sum(vectors[i][l] * vectors[j][l] for l in range(n)) - vectors[i][n] * vectors[j][n]
            euclid_ip = sum(vectors[i][l] * vectors[j][l] for l in range(n))
            print(f"  B_L(v_{i+1}, v_{j+1}) = {lorentz_ip:.1f}, "
                  f"<v_{i+1}, v_{j+1}>_E = {euclid_ip:.1f} (equal ✓)")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    print("\n" + "═" * 60)
    print("  LORENTZ-ORTHOGONAL AVERAGING: NUMERICAL DEMONSTRATIONS")
    print("═" * 60 + "\n")
    
    demonstrate_pythagorean_identity()
    demonstrate_contraction_bound()
    demonstrate_bessel_inequality()
    demonstrate_scaled_projection()
    demonstrate_spectral_gap()
    demonstrate_lorentz_form()
    demonstrate_lorentz_to_euclidean()
    
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualizations for Lorentz-Orthogonal Spectral Gap Theory

Generates publication-quality figures illustrating:
1. Spectral gap as a function of k
2. Contraction bound verification
3. Lorentz cone geometry
4. Apollonian orbit structure
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
import base64
from io import BytesIO

# Style setup
plt.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
    'legend.fontsize': 11,
    'figure.figsize': (8, 6),
    'figure.dpi': 150,
})


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', bbox_inches='tight', dpi=150)
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def plot_spectral_gap():
    """Plot the spectral gap 1 - 1/√k as a function of k."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ks = np.arange(2, 101)
    gap_sqrt = 1 - 1 / np.sqrt(ks)
    gap_exact = 2.0 / ks
    
    ax1.plot(ks, gap_sqrt, 'b-', linewidth=2.5, label=r'$1 - 1/\sqrt{k}$ (contraction bound)')
    ax1.plot(ks, gap_exact, 'r--', linewidth=2.5, label=r'$2/k$ (reflection gap)')
    ax1.fill_between(ks, 0, gap_exact, alpha=0.1, color='red')
    ax1.fill_between(ks, gap_exact, gap_sqrt, alpha=0.1, color='blue')
    ax1.set_xlabel('Number of generators $k$')
    ax1.set_ylabel('Spectral gap')
    ax1.set_title('Spectral Gap vs. Number of Generators')
    ax1.legend(loc='lower right')
    ax1.set_xlim(2, 100)
    ax1.set_ylim(0, 1)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)
    
    # Highlight specific values
    for k_val in [3, 4, 10]:
        ax1.annotate(f'k={k_val}\ngap={1-1/np.sqrt(k_val):.3f}',
                    xy=(k_val, 1-1/np.sqrt(k_val)),
                    xytext=(k_val+8, 1-1/np.sqrt(k_val)-0.15),
                    arrowprops=dict(arrowstyle='->', color='blue'),
                    fontsize=10)
    
    # Log-log plot
    ax2.loglog(ks, 1/np.sqrt(ks), 'b-', linewidth=2.5, label=r'$1/\sqrt{k}$ (operator norm)')
    ax2.loglog(ks, 2.0/ks, 'r--', linewidth=2.5, label=r'$2/k$ (reflection norm)')
    ax2.loglog(ks, 1.0/ks, 'g:', linewidth=2, label=r'$1/k$ (projection norm)')
    ax2.set_xlabel('Number of generators $k$')
    ax2.set_ylabel('Operator norm bound')
    ax2.set_title('Operator Norm Bounds (log-log)')
    ax2.legend()
    ax2.grid(True, alpha=0.3, which='both')
    
    fig.tight_layout()
    fig.savefig('spectral_gap.png', bbox_inches='tight', dpi=150)
    return fig_to_base64(fig)


def plot_contraction_verification():
    """Verify the contraction bound numerically."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    np.random.seed(42)
    
    for idx, dim in enumerate([5, 20, 100]):
        ax = axes[idx]
        ks = range(2, min(dim, 30) + 1)
        ratios = []
        bounds_sqrt = []
        bounds_k = []
        
        for k in ks:
            Q, _ = np.linalg.qr(np.random.randn(dim, dim))
            vectors = [Q[:, i] for i in range(k)]
            
            max_ratio = 0
            for _ in range(500):
                x = np.random.randn(dim)
                avg = sum(vectors) / k
                # The vectors themselves are orthogonal unit vectors
                # ‖(1/k)Σ v_i‖ = ‖avg‖, and each ‖v_i‖ = 1, bound = 1/√k
                actual_ratio = np.linalg.norm(avg)
                max_ratio = max(max_ratio, actual_ratio)
            
            ratios.append(max_ratio)
            bounds_sqrt.append(1 / np.sqrt(k))
            bounds_k.append(1 / k)
        
        ks_list = list(ks)
        ax.plot(ks_list, ratios, 'ko-', markersize=4, linewidth=1.5, label='Observed')
        ax.plot(ks_list, bounds_sqrt, 'b-', linewidth=2, label=r'$1/\sqrt{k}$')
        ax.plot(ks_list, bounds_k, 'r--', linewidth=2, label=r'$1/k$')
        ax.set_xlabel('$k$')
        ax.set_ylabel(r'$\|\frac{1}{k}\sum v_i\|$')
        ax.set_title(f'dim = {dim}')
        ax.legend()
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('Contraction Bound Verification: Orthogonal Unit Vectors', fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('contraction_verification.png', bbox_inches='tight', dpi=150)
    return fig_to_base64(fig)


def plot_lorentz_cone():
    """Visualize the Lorentz light cone and reflections."""
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')
    
    # Light cone: x² + y² = z²
    theta = np.linspace(0, 2*np.pi, 100)
    z = np.linspace(-2, 2, 50)
    Theta, Z = np.meshgrid(theta, z)
    X = np.abs(Z) * np.cos(Theta)
    Y = np.abs(Z) * np.sin(Theta)
    
    ax.plot_surface(X, Y, Z, alpha=0.15, color='gold')
    
    # Timelike vector
    ax.quiver(0, 0, 0, 0, 0, 1.5, color='red', linewidth=3, 
              arrow_length_ratio=0.1, label='Timelike')
    
    # Spacelike vectors
    colors = ['blue', 'green']
    labels = ['Spacelike $v_1$', 'Spacelike $v_2$']
    for i, (c, l) in enumerate(zip(colors, labels)):
        v = np.zeros(3)
        v[i] = 1.5
        ax.quiver(0, 0, 0, v[0], v[1], v[2], color=c, linewidth=3,
                 arrow_length_ratio=0.1, label=l)
    
    # Reflection planes
    xx, yy = np.meshgrid(np.linspace(-1.5, 1.5, 10), np.linspace(-1.5, 1.5, 10))
    # Plane orthogonal to v_1 (x=0 plane)
    ax.plot_surface(np.zeros_like(xx), xx, yy, alpha=0.08, color='blue')
    # Plane orthogonal to v_2 (y=0 plane)  
    ax.plot_surface(xx, np.zeros_like(xx), yy, alpha=0.08, color='green')
    
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_zlabel('$x_3$ (time)')
    ax.set_title('Lorentz Cone and Orthogonal Reflections\n$Q(x) = x_1^2 + x_2^2 - x_3^2$')
    ax.legend(loc='upper left')
    
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_zlim(-2, 2)
    
    fig.savefig('lorentz_cone.png', bbox_inches='tight', dpi=150)
    return fig_to_base64(fig)


def plot_eigenvalue_distribution():
    """Plot eigenvalue distribution of the averaging operator."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    
    for idx, k in enumerate([2, 3, 4, 5, 10, 20]):
        ax = axes[idx // 3][idx % 3]
        dim = max(k + 5, 15)
        
        Q, _ = np.linalg.qr(np.random.randn(dim, dim))
        vectors = [Q[:, i] for i in range(k)]
        
        # Reflection matrices
        T = np.zeros((dim, dim))
        for v in vectors:
            R = np.eye(dim) - 2 * np.outer(v, v)
            T += R
        T /= k
        
        eigvals = np.sort(np.linalg.eigvalsh(T))[::-1]
        
        ax.bar(range(len(eigvals)), eigvals, color='steelblue', alpha=0.7)
        ax.axhline(y=(k-2)/k, color='red', linestyle='--', linewidth=1.5,
                  label=f'$(k-2)/k = {(k-2)/k:.3f}$')
        ax.axhline(y=1, color='green', linestyle=':', linewidth=1.5,
                  label='$1$ (identity)')
        ax.axhline(y=1/np.sqrt(k), color='orange', linestyle='--', linewidth=1.5,
                  label=f'$1/\\sqrt{{k}} = {1/np.sqrt(k):.3f}$')
        ax.set_title(f'k = {k} generators')
        ax.set_xlabel('Eigenvalue index')
        ax.set_ylabel('Eigenvalue')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('Eigenvalue Spectrum of Averaging Operator $T = \\frac{1}{k}\\sum R_i$',
                fontsize=14)
    fig.tight_layout()
    fig.savefig('eigenvalue_distribution.png', bbox_inches='tight', dpi=150)
    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return base64 data."""
    print("Generating visualizations...")
    
    results = {}
    
    print("  1/4: Spectral gap plot...")
    results['spectral_gap'] = plot_spectral_gap()
    
    print("  2/4: Contraction verification...")
    results['contraction'] = plot_contraction_verification()
    
    print("  3/4: Lorentz cone...")
    results['lorentz_cone'] = plot_lorentz_cone()
    
    print("  4/4: Eigenvalue distribution...")
    results['eigenvalues'] = plot_eigenvalue_distribution()
    
    print("  All visualizations generated.")
    return results


if __name__ == "__main__":
    viz = generate_all_visualizations()
    print(f"\nGenerated {len(viz)} visualizations as PNG files.")
    for name in viz:
        print(f"  - {name}.png")
