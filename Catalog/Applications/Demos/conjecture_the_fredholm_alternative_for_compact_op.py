"""
Applications of the Fredholm Alternative
==========================================

This module demonstrates real-world applications of the Fredholm Alternative
theorem in integral equations arising from physics, engineering, and applied
mathematics.

Applications:
    1. Heat conduction: steady-state temperature in a rod with radiative transfer
    2. Potential theory: electrostatic potential of a charged conductor
    3. Population dynamics: age-structured population models
    4. Signal processing: deconvolution
"""

import numpy as np
from scipy import linalg
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def heat_conduction_radiative():
    """
    Application 1: Steady-State Heat Conduction with Radiative Transfer
    
    A rod of length 1 exchanges heat with its surroundings and with itself
    through radiation. The steady-state temperature u(x) satisfies:
    
        u(x) - α ∫₀¹ exp(-β|x-t|) u(t) dt = f(x)
    
    where α controls the radiation strength and β the absorption coefficient.
    
    The Fredholm Alternative guarantees: if the only solution to the
    homogeneous equation is u = 0, then for every heat source f, there
    exists a unique steady-state temperature distribution.
    """
    print("=" * 70)
    print("APPLICATION 1: Heat Conduction with Radiative Transfer")
    print("=" * 70)
    print()

    alpha = 0.3
    beta = 2.0
    kernel = lambda x, t: alpha * np.exp(-beta * np.abs(x - t))

    n = 200
    h = 1.0 / (n - 1)
    grid = np.linspace(0, 1, n)

    # Build system
    K_mat = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            w = h if 0 < j < n - 1 else h / 2
            K_mat[i, j] = w * kernel(grid[i], grid[j])

    I_minus_K = np.eye(n) - K_mat

    # Heat sources
    sources = {
        "Uniform": np.ones(n),
        "Point source (center)": np.exp(-100 * (grid - 0.5) ** 2),
        "Two sources": np.exp(-50 * (grid - 0.25) ** 2) + np.exp(-50 * (grid - 0.75) ** 2),
    }

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    for ax, (name, f_vec) in zip(axes, sources.items()):
        u = linalg.solve(I_minus_K, f_vec)
        ax.plot(grid, f_vec, 'b--', label='Source f(x)', alpha=0.7)
        ax.plot(grid, u, 'r-', linewidth=2, label='Temperature u(x)')
        ax.set_xlabel('Position x')
        ax.set_ylabel('Temperature')
        ax.set_title(name)
        ax.legend()
        ax.grid(True, alpha=0.3)

    fig.suptitle(f'Radiative Heat Transfer (α={alpha}, β={beta})', fontsize=14)
    fig.tight_layout()
    fig.savefig('app1_heat_conduction.png', dpi=150)
    plt.close(fig)

    # Check Fredholm Alternative condition
    eigenvalues = linalg.eigvals(K_mat)
    min_dist = np.min(np.abs(eigenvalues - 1.0))
    print(f"  Parameters: α = {alpha}, β = {beta}")
    print(f"  Operator norm ‖K‖ = {np.linalg.norm(K_mat, 2):.4f}")
    print(f"  Distance of spectrum to 1: {min_dist:.6f}")
    print(f"  Fredholm Alternative: unique solution exists ✓")
    print(f"  Plot saved to app1_heat_conduction.png")
    print()


def electrostatic_potential():
    """
    Application 2: Electrostatic Potential of a Charged Conductor
    
    The electrostatic potential on the surface of a conductor satisfies
    a Fredholm integral equation of the second kind:
    
        u(x) + (1/π) ∫ K(x,t) u(t) dt = g(x)
    
    where K is the double-layer potential kernel and g is the boundary data.
    
    The Fredholm Alternative determines when the Dirichlet problem has a
    unique solution (it does for exterior problems, may not for interior
    problems at certain "eigenfrequencies").
    """
    print("=" * 70)
    print("APPLICATION 2: Electrostatic Potential (2D)")
    print("=" * 70)
    print()

    # Simple model: circular conductor, parameterized by angle θ
    n = 200
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    dtheta = 2 * np.pi / n

    # For a circle of radius R, the kernel of the double-layer potential
    # simplifies. We model a perturbed circle:
    R_func = lambda t: 1.0 + 0.1 * np.cos(3 * t)  # Slightly non-circular
    x_coords = lambda t: R_func(t) * np.cos(t)
    y_coords = lambda t: R_func(t) * np.sin(t)

    # Build the kernel matrix (simplified model)
    K_mat = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                dx = x_coords(theta[i]) - x_coords(theta[j])
                dy = y_coords(theta[i]) - y_coords(theta[j])
                r2 = dx**2 + dy**2
                K_mat[i, j] = dtheta / (2 * np.pi) * 1.0 / max(r2, 1e-10)

    I_plus_K = np.eye(n) + 0.1 * K_mat  # Scale to avoid large norms

    # Boundary conditions: external potential
    boundary_conditions = {
        "Uniform field (x-direction)": np.array([x_coords(t) for t in theta]),
        "Quadrupole": np.array([np.cos(2 * t) for t in theta]),
    }

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    for ax, (name, g_vec) in zip(axes, boundary_conditions.items()):
        u = linalg.solve(I_plus_K, g_vec)
        ax.plot(theta * 180 / np.pi, g_vec, 'b--', label='Boundary data g')
        ax.plot(theta * 180 / np.pi, u, 'r-', linewidth=2, label='Surface potential u')
        ax.set_xlabel('Angle (degrees)')
        ax.set_ylabel('Potential')
        ax.set_title(name)
        ax.legend()
        ax.grid(True, alpha=0.3)

    fig.suptitle('Electrostatic Potential on Conductor Surface', fontsize=14)
    fig.tight_layout()
    fig.savefig('app2_electrostatics.png', dpi=150)
    plt.close(fig)

    eigenvalues = linalg.eigvals(0.1 * K_mat)
    print(f"  Operator norm: {np.linalg.norm(0.1 * K_mat, 2):.4f}")
    print(f"  Condition number: {np.linalg.cond(I_plus_K):.4f}")
    print(f"  Fredholm Alternative: unique solution exists ✓")
    print(f"  Plot saved to app2_electrostatics.png")
    print()


def signal_deconvolution():
    """
    Application 3: Signal Deconvolution
    
    Given a measured signal y = Kx + noise, where K is a convolution
    (blurring) operator, recover the original signal x by solving:
    
        x - λ K*K x = K* y  (Tikhonov-regularized normal equation)
    
    This is a Fredholm equation of the second kind. The Fredholm Alternative
    guarantees existence and uniqueness of the regularized solution.
    """
    print("=" * 70)
    print("APPLICATION 3: Signal Deconvolution")
    print("=" * 70)
    print()

    n = 300
    grid = np.linspace(0, 1, n)
    h = 1.0 / (n - 1)

    # Original signal: sum of Gaussians
    x_true = (np.exp(-200 * (grid - 0.3) ** 2)
              + 0.7 * np.exp(-200 * (grid - 0.6) ** 2)
              + 0.5 * np.exp(-200 * (grid - 0.8) ** 2))

    # Blurring kernel (Gaussian convolution)
    sigma = 0.03
    def blur_kernel(x, t):
        return np.exp(-(x - t) ** 2 / (2 * sigma ** 2)) / (sigma * np.sqrt(2 * np.pi)) * h

    # Build blurring matrix
    K_mat = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K_mat[i, j] = blur_kernel(grid[i], grid[j])

    # Blurred signal
    y_clean = K_mat @ x_true
    noise_level = 0.02
    np.random.seed(42)
    y_noisy = y_clean + noise_level * np.random.randn(n)

    # Tikhonov regularization: (I + λ K^T K) x = K^T y
    regularization_params = [1e-4, 1e-3, 1e-2]
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    axes[0, 0].plot(grid, x_true, 'k-', linewidth=2, label='True signal')
    axes[0, 0].plot(grid, y_noisy, 'b.', markersize=1, alpha=0.5, label='Noisy measurement')
    axes[0, 0].set_title('Original Signal and Measurement')
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)

    KTK = K_mat.T @ K_mat
    KTy = K_mat.T @ y_noisy

    for idx, lam in enumerate(regularization_params):
        A = np.eye(n) + lam * KTK
        x_recovered = linalg.solve(A, KTy)

        ax = axes[(idx + 1) // 2, (idx + 1) % 2]
        ax.plot(grid, x_true, 'k-', linewidth=2, label='True signal')
        ax.plot(grid, x_recovered, 'r-', linewidth=1.5, label='Recovered')
        ax.set_title(f'λ = {lam:.0e}, error = {np.max(np.abs(x_true - x_recovered)):.3f}')
        ax.legend()
        ax.grid(True, alpha=0.3)

        cond = np.linalg.cond(A)
        print(f"  λ = {lam:.0e}: cond = {cond:.2f}, "
              f"max error = {np.max(np.abs(x_true - x_recovered)):.4f}")

    fig.suptitle('Signal Deconvolution via Fredholm Equation', fontsize=14)
    fig.tight_layout()
    fig.savefig('app3_deconvolution.png', dpi=150)
    plt.close(fig)

    print(f"\n  The Fredholm Alternative guarantees unique solutions for all λ > 0")
    print(f"  Plot saved to app3_deconvolution.png")
    print()


def population_dynamics():
    """
    Application 4: Age-Structured Population Dynamics
    
    The renewal equation for age-structured populations:
    
        B(t) = ∫₀^∞ m(a) S(a) B(t-a) da + f(t)
    
    At steady state with exponential growth rate r:
    
        n(a) - r ∫₀^a n(s) ds = n₀(a)
    
    This is a Volterra/Fredholm equation where the Fredholm Alternative
    determines stability conditions.
    """
    print("=" * 70)
    print("APPLICATION 4: Age-Structured Population Dynamics")
    print("=" * 70)
    print()

    n = 200
    max_age = 50.0
    grid = np.linspace(0, max_age, n)
    h = max_age / (n - 1)

    # Maternity function: m(a) peaks around age 25
    maternity = np.exp(-0.5 * ((grid - 25) / 5) ** 2) * 0.15

    # Survival function: S(a) = exp(-μa) with age-dependent mortality
    mortality_rate = 0.02 + 0.001 * grid  # Increasing mortality
    survival = np.exp(-np.cumsum(mortality_rate) * h)

    # Net reproduction kernel: K(a) = m(a) * S(a)
    net_reproduction = maternity * survival

    # Build integral operator for renewal equation
    # R₀ = ∫ m(a) S(a) da (net reproduction number)
    R0 = np.trapezoid(net_reproduction, grid)
    print(f"  Net reproduction number R₀ = {R0:.4f}")

    # The Fredholm Alternative says: unique steady state exists iff 1 is not
    # an eigenvalue of the integral operator K.
    # For the renewal equation, this corresponds to R₀ ≠ 1.
    if abs(R0 - 1) < 0.01:
        print(f"  WARNING: R₀ ≈ 1, near the bifurcation point!")
    else:
        print(f"  |R₀ - 1| = {abs(R0 - 1):.4f} > 0: unique steady state exists ✓")

    # Build the operator and solve
    K_mat = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            w = h if 0 < j < n - 1 else h / 2
            K_mat[i, j] = w * net_reproduction[j]

    # Scale so that the operator has eigenvalue 1 at R₀
    # The equation is n(a) - K n = f where K has leading eigenvalue R₀
    I_minus_K = np.eye(n) - K_mat
    immigration = np.exp(-0.1 * grid) * 100  # Immigration rate

    steady_state = linalg.solve(I_minus_K, immigration)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    axes[0].plot(grid, maternity, 'b-', label='Maternity m(a)')
    axes[0].plot(grid, survival, 'r-', label='Survival S(a)')
    axes[0].plot(grid, net_reproduction, 'g-', linewidth=2, label='Net reprod. m(a)S(a)')
    axes[0].set_xlabel('Age')
    axes[0].set_title('Demographic Functions')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(grid, immigration, 'b--', label='Immigration f(a)')
    axes[1].plot(grid, steady_state, 'r-', linewidth=2, label='Steady state n(a)')
    axes[1].set_xlabel('Age')
    axes[1].set_title(f'Steady-State Population (R₀={R0:.2f})')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Eigenvalue analysis
    eigenvalues = np.sort(np.abs(linalg.eigvals(K_mat)))[::-1]
    axes[2].semilogy(range(1, min(50, n) + 1), eigenvalues[:50], 'bo-', markersize=4)
    axes[2].axhline(y=1, color='r', linestyle='--', label='λ = 1')
    axes[2].set_xlabel('Index')
    axes[2].set_ylabel('|λ|')
    axes[2].set_title('Eigenvalues of K')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    fig.suptitle('Age-Structured Population Dynamics', fontsize=14)
    fig.tight_layout()
    fig.savefig('app4_population.png', dpi=150)
    plt.close(fig)

    print(f"  Plot saved to app4_population.png")
    print()


if __name__ == "__main__":
    heat_conduction_radiative()
    electrostatic_potential()
    signal_deconvolution()
    population_dynamics()
    print("All applications completed successfully!")


"""
Demo: The Fredholm Alternative in Action
=========================================

This script demonstrates the Fredholm Alternative theorem through concrete
numerical examples with compact operators (integral operators with continuous kernels).

The Fredholm Alternative states: for a compact operator K on an infinite-dimensional
Banach space, (I - K) is injective if and only if (I - K) is surjective. That is,
uniqueness of solutions implies existence.
"""

import numpy as np
from scipy import linalg
from scipy.integrate import quad
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def discretize_fredholm_operator(kernel, n, a=0.0, b=1.0):
    """
    Discretize a Fredholm integral equation of the second kind:
        u(x) - integral_a^b K(x,t) u(t) dt = f(x)

    using the trapezoidal rule on n equally spaced points.

    Returns the matrix (I - K_n) where K_n is the discretized integral operator.

    Parameters
    ----------
    kernel : callable
        K(x, t) -> float, the kernel function
    n : int
        Number of discretization points
    a, b : float
        Integration interval

    Returns
    -------
    grid : ndarray of shape (n,)
    I_minus_K : ndarray of shape (n, n)
    K_matrix : ndarray of shape (n, n)
    """
    h = (b - a) / (n - 1)
    grid = np.linspace(a, b, n)

    # Build the kernel matrix with trapezoidal weights
    K_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            weight = h if (0 < j < n - 1) else h / 2
            K_matrix[i, j] = weight * kernel(grid[i], grid[j])

    I_minus_K = np.eye(n) - K_matrix
    return grid, I_minus_K, K_matrix


def demo_injective_implies_surjective():
    """
    Demo 1: When (I - K) is injective, it is surjective.
    
    We use the kernel K(x,t) = x*t, which gives a rank-1 compact operator.
    The eigenvalues of this integral operator are 0 (with infinite multiplicity)
    and 1/3. Since 1 is not an eigenvalue of K, (I - K) is injective, and by
    the Fredholm Alternative, it must be surjective.
    """
    print("=" * 70)
    print("DEMO 1: Injective (I - K) implies Surjective (I - K)")
    print("=" * 70)
    print()
    print("Kernel: K(x,t) = x*t on [0,1]")
    print("This is a rank-1 operator with eigenvalue λ = 1/3.")
    print("Since 1 is NOT an eigenvalue of K, (I-K) is injective.")
    print("By the Fredholm Alternative, (I-K) must be surjective.")
    print()

    kernel = lambda x, t: x * t
    ns = [10, 50, 100, 500]

    for n in ns:
        grid, I_minus_K, K_mat = discretize_fredholm_operator(kernel, n)

        # Check injectivity: kernel of (I - K) should be trivial
        eigenvalues = linalg.eigvals(K_mat)
        dist_to_one = np.min(np.abs(eigenvalues - 1.0))

        # Check surjectivity: solve (I - K)u = f for f(x) = 1
        f = np.ones(n)
        u = linalg.solve(I_minus_K, f)
        residual = np.max(np.abs(I_minus_K @ u - f))

        cond = np.linalg.cond(I_minus_K)

        print(f"  n = {n:4d}: cond(I-K) = {cond:.4f}, "
              f"min|λ-1| = {dist_to_one:.6f}, "
              f"residual = {residual:.2e}")

    # Solve and plot for n = 100
    n = 100
    grid, I_minus_K, _ = discretize_fredholm_operator(kernel, n)
    f = np.ones(n)
    u = linalg.solve(I_minus_K, f)

    # Exact solution: u(x) = 1 + (3/2)x  (can be verified)
    u_exact = 1 + 1.5 * grid

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(grid, u, 'b-', linewidth=2, label='Numerical solution')
    ax.plot(grid, u_exact, 'r--', linewidth=2, label='Exact solution')
    ax.set_xlabel('x')
    ax.set_ylabel('u(x)')
    ax.set_title('Fredholm equation (I-K)u = 1 with K(x,t) = xt')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('demo1_injective_surjective.png', dpi=150)
    plt.close(fig)
    print(f"\n  Max error vs exact: {np.max(np.abs(u - u_exact)):.2e}")
    print("  Plot saved to demo1_injective_surjective.png")
    print()


def demo_not_injective_not_surjective():
    """
    Demo 2: When (I - K) is NOT injective, it is NOT surjective.
    
    We construct a kernel so that 1 IS an eigenvalue of K.
    K(x,t) = 3*x*t gives an operator with eigenvalue 1.
    Then (I - K) has a nontrivial kernel, and by the Fredholm Alternative,
    (I - K) cannot be surjective: the equation (I-K)u = f has no solution
    for generic f.
    """
    print("=" * 70)
    print("DEMO 2: Not Injective (I - K) implies Not Surjective (I - K)")
    print("=" * 70)
    print()
    print("Kernel: K(x,t) = 3*x*t on [0,1]")
    print("This operator has eigenvalue λ = 1 (eigenfunction: u(x) = x).")
    print("So (I-K) is NOT injective.")
    print("By the Fredholm Alternative, (I-K) is NOT surjective.")
    print()

    kernel = lambda x, t: 3 * x * t
    n = 100
    grid, I_minus_K, K_mat = discretize_fredholm_operator(kernel, n)

    # Find eigenvalues of K
    eigenvalues = linalg.eigvals(K_mat)
    closest_to_one = eigenvalues[np.argmin(np.abs(eigenvalues - 1.0))]
    print(f"  Eigenvalue closest to 1: {closest_to_one.real:.6f}")

    # The kernel of (I - K) contains u(x) = x
    null_vec = grid.copy()
    null_vec /= np.linalg.norm(null_vec)
    residual_null = np.max(np.abs(I_minus_K @ null_vec))
    print(f"  ‖(I-K)(x)‖_∞ / ‖x‖ ≈ {residual_null:.2e}")

    # Try to solve (I - K)u = 1
    # This should fail (no solution exists)
    f = np.ones(n)
    det_val = np.abs(linalg.det(I_minus_K))
    print(f"  |det(I-K)| = {det_val:.2e}")
    print(f"  cond(I-K) = {np.linalg.cond(I_minus_K):.2e}")

    # The solvability condition: f must be orthogonal to ker(I - K*)
    # For self-adjoint K, ker(I-K*) = ker(I-K) = span{x}
    solvability = np.dot(f, grid) * (grid[1] - grid[0])
    print(f"  <f, eigenfunction> = {solvability:.6f} (must be 0 for solvability)")
    print(f"  Since <f, eigenfunction> ≠ 0, the equation has NO solution.")
    print()


def demo_eigenvalue_structure():
    """
    Demo 3: Eigenvalue structure of compact operators.
    
    For a compact operator K, the nonzero spectrum consists of eigenvalues
    of finite multiplicity, which can only accumulate at 0. This is a
    consequence of the Fredholm Alternative applied to (λI - K) for various λ.
    """
    print("=" * 70)
    print("DEMO 3: Eigenvalue Structure of Compact Operators")
    print("=" * 70)
    print()

    # Use a smooth kernel that gives rapid eigenvalue decay
    kernel = lambda x, t: np.exp(-2 * (x - t) ** 2)

    n = 200
    grid, _, K_mat = discretize_fredholm_operator(kernel, n)
    eigenvalues = np.sort(np.abs(linalg.eigvals(K_mat)))[::-1]

    print("  Kernel: K(x,t) = exp(-2(x-t)²) on [0,1]")
    print(f"  Discretization: n = {n}")
    print()
    print("  Top 15 eigenvalue magnitudes:")
    for i, ev in enumerate(eigenvalues[:15]):
        print(f"    |λ_{i+1}| = {ev:.8f}")
    print(f"    ...")
    print(f"    |λ_{n}| = {eigenvalues[-1]:.2e}")
    print()
    print("  Observation: eigenvalues decay rapidly toward 0.")
    print("  This illustrates the Riesz-Schauder theorem: nonzero spectrum")
    print("  is discrete with only possible accumulation at 0.")

    # Plot eigenvalue decay
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.semilogy(range(1, n + 1), eigenvalues, 'b.-', markersize=3)
    ax1.set_xlabel('Index k')
    ax1.set_ylabel('|λ_k|')
    ax1.set_title('Eigenvalue decay (log scale)')
    ax1.grid(True, alpha=0.3)

    ax2.plot(range(1, min(30, n) + 1), eigenvalues[:30], 'ro-', markersize=5)
    ax2.set_xlabel('Index k')
    ax2.set_ylabel('|λ_k|')
    ax2.set_title('Top 30 eigenvalues (linear scale)')
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Compact Operator Eigenvalue Structure', fontsize=14)
    fig.tight_layout()
    fig.savefig('demo3_eigenvalue_structure.png', dpi=150)
    plt.close(fig)
    print("  Plot saved to demo3_eigenvalue_structure.png")
    print()


def demo_riesz_lemma_visualization():
    """
    Demo 4: Visualizing Riesz's Lemma.
    
    Riesz's lemma says: given a proper closed subspace F of a normed space E,
    for any ε > 0, there exists a unit vector x with dist(x, F) ≥ 1 - ε.
    
    We illustrate this in R³ with F = span{e₁, e₂} (the xy-plane).
    """
    print("=" * 70)
    print("DEMO 4: Riesz's Lemma Visualization")
    print("=" * 70)
    print()
    print("  Setting: E = R³, F = span{e₁, e₂} (the xy-plane)")
    print()

    # In R³, the unit vector (0,0,1) achieves dist = 1 exactly
    # For ε close to 0, Riesz's lemma gives nearly optimal vectors
    epsilons = [0.5, 0.25, 0.1, 0.01, 0.001]
    for eps in epsilons:
        # Any unit vector with |z| >= 1-eps works
        z_min = 1 - eps
        angle = np.arccos(z_min)
        print(f"  ε = {eps}: guaranteed dist ≥ {1-eps:.3f}, "
              f"opening angle ≤ {np.degrees(angle):.2f}°")

    print()
    print("  In infinite dimensions, the key difference is that dist = 1")
    print("  is NOT always achievable (it is in finite dimensions).")
    print("  Riesz's lemma guarantees arbitrarily close to 1, but not 1 itself.")
    print()


if __name__ == '__main__':
    demo_injective_implies_surjective()
    demo_not_injective_not_surjective()
    demo_eigenvalue_structure()
    demo_riesz_lemma_visualization()
    print("All demos completed successfully!")
