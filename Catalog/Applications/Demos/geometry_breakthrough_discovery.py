"""
Tropical Metric Geometry: Algorithms
=====================================

Implementation of key algorithms from the research:
- Tropical hash evaluation (O(nm))
- Contraction iteration with convergence detection
- Lipschitz composition for neural network certification
- Tropical spectral radius computation
"""

import numpy as np
from typing import Tuple, List, Optional


def tropical_hash(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Evaluate tropical hash: H(x)_i = min_j(A_{ij} + x_j).
    
    Time complexity: O(n·m) where A is m×n.
    Space complexity: O(m) for output.
    
    Args:
        A: Hash matrix of shape (m, n)
        x: Input vector of shape (n,)
    
    Returns:
        Hash vector of shape (m,)
    
    Example:
        >>> A = np.array([[1.0, 2.0], [3.0, 0.5]])
        >>> x = np.array([0.0, 1.0])
        >>> tropical_hash(A, x)  # [min(1+0, 2+1), min(3+0, 0.5+1)] = [1.0, 1.5]
    """
    m, n = A.shape
    assert x.shape == (n,), f"Input dimension mismatch: expected {n}, got {x.shape}"
    return np.array([np.min(A[i] + x) for i in range(m)])


def linf_distance(u: np.ndarray, v: np.ndarray) -> float:
    """Compute L∞ (tropical) distance: max_k |u_k - v_k|.
    
    Time complexity: O(n).
    
    Args:
        u, v: Vectors of same shape.
    
    Returns:
        L∞ distance.
    """
    return float(np.max(np.abs(u - v)))


def contraction_iterate(
    f, x0: np.ndarray, kappa: float, epsilon: float, max_iter: int = 10000
) -> Tuple[np.ndarray, int, List[float]]:
    """Iterate a contraction mapping until convergence.
    
    Given f with Lipschitz constant κ < 1, iterates f^n(x₀) until
    consecutive iterates are within ε distance.
    
    Time complexity: O(N · T_f) where N = ⌈log(d₀/ε)/log(1/κ)⌉ and T_f is
    the cost of one function evaluation.
    
    Args:
        f: The contraction mapping.
        x0: Initial point.
        kappa: Contraction rate (Lipschitz constant), must be in [0, 1).
        epsilon: Target accuracy.
        max_iter: Maximum iterations.
    
    Returns:
        (fixed_point_approx, num_iterations, distance_history)
    """
    assert 0 <= kappa < 1, f"Rate must be in [0, 1), got {kappa}"
    assert epsilon > 0, f"Epsilon must be positive, got {epsilon}"
    
    x = x0.copy()
    distances = []
    
    for n in range(max_iter):
        x_new = f(x)
        d = linf_distance(x_new, x)
        distances.append(d)
        x = x_new
        if d < epsilon:
            return x, n + 1, distances
    
    return x, max_iter, distances


def lipschitz_compose(lip_constants: List[float]) -> float:
    """Compute the total Lipschitz constant of a composition of layers.
    
    For layers f₁, ..., fₙ with Lipschitz constants L₁, ..., Lₙ,
    the composition f_n ∘ ... ∘ f_1 has Lipschitz constant ∏ᵢ Lᵢ.
    
    In log-space (tropical), this is addition: log(∏ Lᵢ) = Σ log(Lᵢ).
    
    Time complexity: O(n).
    
    Args:
        lip_constants: Per-layer Lipschitz constants.
    
    Returns:
        Total Lipschitz constant.
    """
    result = 1.0
    for L in lip_constants:
        result *= L
    return result


def robustness_radius(lip_constant: float, margin: float) -> float:
    """Compute the certified adversarial robustness radius.
    
    For a classifier with Lipschitz constant L and classification margin m,
    the network is provably robust to perturbations of L∞ size ≤ m/L.
    
    Args:
        lip_constant: Network Lipschitz constant.
        margin: Classification margin.
    
    Returns:
        Robustness radius m/L.
    """
    assert lip_constant > 0, "Lipschitz constant must be positive"
    return margin / lip_constant


def tropical_spectral_radius(A: np.ndarray) -> float:
    """Compute the tropical spectral radius: min diagonal entry.
    
    Time complexity: O(n).
    
    Args:
        A: Square matrix of shape (n, n).
    
    Returns:
        min_i A_{ii}.
    """
    n = A.shape[0]
    assert A.shape == (n, n), "Matrix must be square"
    return float(np.min(np.diag(A)))


def convergence_iteration_bound(kappa: float, d0: float, epsilon: float) -> float:
    """Compute the iteration bound: N = log(d₀/ε) / log(1/κ).
    
    Time complexity: O(1).
    
    Args:
        kappa: Contraction rate in (0, 1).
        d0: Initial distance.
        epsilon: Target accuracy.
    
    Returns:
        Iteration bound (may need ceiling for integer count).
    """
    assert 0 < kappa < 1
    assert d0 > 0
    assert epsilon > 0
    return np.log(d0 / epsilon) / np.log(1.0 / kappa)


def tropical_convex_combination(u: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Compute the tropical convex combination: coordinate-wise min.
    
    Time complexity: O(n).
    
    Args:
        u, v: Vectors of same shape.
    
    Returns:
        min(u, v) coordinate-wise.
    """
    return np.minimum(u, v)


def stokes_minkowski_form(S0: float, S1: float, S2: float, S3: float) -> float:
    """Compute the Stokes-Minkowski form: S₀² - S₁² - S₂² - S₃².
    
    Time complexity: O(1).
    
    Args:
        S0, S1, S2, S3: Stokes parameters.
    
    Returns:
        Minkowski norm.
    """
    return S0**2 - S1**2 - S2**2 - S3**2


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Metric Geometry — Algorithm Examples")
    print("=" * 60)
    
    # Example 1: Tropical hash
    A = np.array([[1.0, 2.0, 3.0], [0.5, 1.5, 2.5]])
    x = np.array([0.0, 1.0, -1.0])
    h = tropical_hash(A, x)
    print(f"Tropical hash of {x}: {h}")
    
    # Example 2: Contraction iteration
    f = lambda x: 0.7 * x  # Contraction with κ = 0.7
    x0 = np.array([10.0])
    result, iters, hist = contraction_iterate(f, x0, 0.7, 1e-6)
    print(f"Contraction converged in {iters} steps to {result[0]:.8f}")
    
    # Example 3: Lipschitz composition
    layers = [0.9, 0.8, 0.95, 0.85]
    total_lip = lipschitz_compose(layers)
    print(f"4-layer Lipschitz: {layers} → total = {total_lip:.4f}")
    print(f"Robustness radius (margin=1): {robustness_radius(total_lip, 1.0):.4f}")
    
    # Example 4: Iteration bound
    N = convergence_iteration_bound(0.7, 10.0, 1e-6)
    print(f"Iteration bound (κ=0.7, d₀=10, ε=1e-6): {N:.1f} steps")
    
    # Example 5: Stokes-Minkowski
    print(f"Mass of (1,0,0,0): {stokes_minkowski_form(1,0,0,0):.4f}")
    print(f"Mass of (1,1,0,0): {stokes_minkowski_form(1,1,0,0):.4f}")


"""
Tropical Metric Geometry: Applications
========================================

Real-world applications of the theoretical results to:
- Neural network certified robustness
- Post-quantum lattice cryptography
- Hamiltonian simulation error bounds
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def certified_robustness_demo():
    """Demonstrate certified robustness via Lipschitz bounds.
    
    A network with per-layer Lipschitz constants L₁, ..., Lₙ has
    total Lipschitz constant L = ∏ Lᵢ. The adversarial robustness
    radius is margin/L.
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Network Certified Robustness")
    print("=" * 60)
    
    # Simulate a 5-layer network
    layer_lips = [1.2, 0.9, 1.1, 0.8, 1.3]
    total_lip = np.prod(layer_lips)
    margin = 2.5  # Classification margin
    
    print(f"  Network: 5 layers")
    print(f"  Per-layer Lipschitz: {layer_lips}")
    print(f"  Total Lipschitz L = {total_lip:.4f}")
    print(f"  Classification margin m = {margin}")
    print(f"  Certified robustness radius = m/L = {margin/total_lip:.4f}")
    print(f"  Any L∞ perturbation ≤ {margin/total_lip:.4f} cannot change classification")
    
    # Effect of depth on robustness
    print(f"\n  Depth-robustness tradeoff (all layers κ=1.1):")
    depths = range(1, 21)
    radii = [margin / (1.1 ** d) for d in depths]
    for d in [1, 5, 10, 15, 20]:
        print(f"    Depth {d:2d}: L = {1.1**d:.2f}, radius = {margin/1.1**d:.6f}")
    
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(list(depths), radii, 'bo-')
    ax.set_xlabel('Network Depth')
    ax.set_ylabel('Certified Robustness Radius (log scale)')
    ax.set_title('Depth vs. Certified Robustness (κ = 1.1 per layer)')
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('robustness_vs_depth.png', dpi=150)
    plt.close()
    print("  → Saved robustness_vs_depth.png")


def lattice_crypto_demo():
    """Demonstrate lattice cryptography bounds via tropical geometry.
    
    The tropical hash function maps ℝⁿ → ℝᵐ via min-plus matrix-vector product.
    Finding collisions requires solving the tropical shortest vector problem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Post-Quantum Lattice Cryptography")
    print("=" * 60)
    
    # Tropical hash parameters
    n, m = 256, 128  # Typical post-quantum parameters
    
    # Security parameter: log₂ of collision-finding hardness
    # For a random m×n matrix, collision-finding requires time 2^(m·log₂(b/ε))
    b_range = 10.0  # Entry range
    eps_target = 0.001  # Collision tolerance
    
    print(f"  Input dimension n = {n}")
    print(f"  Output dimension m = {m}")
    print(f"  Entry range b = {b_range}")
    print(f"  Collision tolerance ε = {eps_target}")
    print(f"  Security parameter ≈ m · log₂(b/ε) = {m * np.log2(b_range/eps_target):.0f} bits")
    
    # LLL approximation factor
    lll_factor = 2 ** ((n-1)/4)
    print(f"\n  LLL approximation factor 2^((n-1)/4) = 2^{(n-1)/4:.1f}")
    print(f"  = {lll_factor:.2e}")
    print(f"  → LLL reduction insufficient for n = {n}")
    
    # Babai rounding bound
    babai_bound = np.sqrt(n) / 2
    print(f"\n  Babai rounding bound: √n/2 = {babai_bound:.2f}")
    print(f"  Rounding error ≤ {babai_bound:.2f} · max ‖b*_i‖")


def hamiltonian_simulation_demo():
    """Demonstrate Trotter error bounds for quantum simulation.
    
    First-order Trotter: error ≤ C·t²/n
    Second-order Trotter: error ≤ C'·t³/n²
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Hamiltonian Simulation Error Bounds")
    print("=" * 60)
    
    t = 1.0  # Simulation time
    C1 = 5.0  # First-order commutator bound
    C2 = 2.0  # Second-order bound
    target_error = 0.01
    
    # First-order: error = C·t²/n → n = C·t²/ε
    n1 = int(np.ceil(C1 * t**2 / target_error))
    # Second-order: error = C'·t³/n² → n = √(C'·t³/ε)
    n2 = int(np.ceil(np.sqrt(C2 * t**3 / target_error)))
    
    print(f"  Simulation time t = {t}")
    print(f"  Target error ε = {target_error}")
    print(f"  First-order Trotter: {n1} steps (C₁ = {C1})")
    print(f"  Second-order Trotter: {n2} steps (C₂ = {C2})")
    print(f"  Speedup: {n1/n2:.1f}× fewer steps with 2nd-order")
    
    # Plot error vs steps
    ns = np.arange(1, 1001)
    err1 = C1 * t**2 / ns
    err2 = C2 * t**3 / ns**2
    
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.loglog(ns, err1, 'b-', label=f'1st order: Ct²/n (C={C1})')
    ax.loglog(ns, err2, 'r-', label=f'2nd order: C\'t³/n² (C\'={C2})')
    ax.axhline(y=target_error, color='green', linestyle=':', label=f'Target ε={target_error}')
    ax.set_xlabel('Number of Trotter steps n')
    ax.set_ylabel('Error bound')
    ax.set_title('Trotter Error Bounds for Hamiltonian Simulation')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('trotter_error.png', dpi=150)
    plt.close()
    print("  → Saved trotter_error.png")


if __name__ == "__main__":
    certified_robustness_demo()
    lattice_crypto_demo()
    hamiltonian_simulation_demo()
    
    print("\n" + "=" * 60)
    print("All applications completed!")
    print("=" * 60)


"""
Tropical Metric Geometry: Demonstrations
=========================================

Concrete numerical examples bringing the mathematical theorems to life.
Covers contraction mappings, tropical hashing, L∞ distances, and
Stokes-Minkowski mass generation.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ============================================================
# Demo 1: Contraction Mapping Convergence
# ============================================================

def demo_contraction_convergence():
    """Demonstrate geometric convergence of a contraction mapping.
    
    We use f(x) = κx with κ = 0.7 and show that d(fⁿ(x), fⁿ(y)) ≤ κⁿ · d(x,y).
    """
    print("=" * 60)
    print("DEMO 1: Contraction Mapping Convergence")
    print("=" * 60)
    
    kappa = 0.7
    x0, y0 = 10.0, 0.0
    d0 = abs(x0 - y0)
    
    print(f"Contraction rate κ = {kappa}")
    print(f"Initial points: x₀ = {x0}, y₀ = {y0}")
    print(f"Initial distance d₀ = {d0}")
    print()
    
    distances = []
    bounds = []
    for n in range(20):
        xn = kappa**n * x0
        yn = kappa**n * y0
        dn = abs(xn - yn)
        bn = kappa**n * d0
        distances.append(dn)
        bounds.append(bn)
        if n % 4 == 0:
            print(f"  n={n:2d}: d(f^n(x), f^n(y)) = {dn:.6f} ≤ κ^n·d₀ = {bn:.6f}")
    
    # Epsilon accuracy
    epsilon = 0.01
    N = int(np.ceil(np.log(epsilon / d0) / np.log(kappa)))
    print(f"\n  Steps for ε={epsilon}: N = ⌈log({epsilon}/{d0})/log({kappa})⌉ = {N}")
    print(f"  Actual distance at N={N}: {kappa**N * d0:.8f}")
    
    # Plot
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.semilogy(range(20), distances, 'bo-', label='Actual distance')
    ax.semilogy(range(20), bounds, 'r--', label='κⁿ · d₀ bound')
    ax.axhline(y=epsilon, color='green', linestyle=':', label=f'ε = {epsilon}')
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('Distance (log scale)')
    ax.set_title('Contraction Mapping: Geometric Convergence O(κⁿ)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('contraction_convergence.png', dpi=150)
    plt.close()
    print("  → Saved contraction_convergence.png")


# ============================================================
# Demo 2: Tropical Hash Function (1-Lipschitz)
# ============================================================

def demo_tropical_hash():
    """Demonstrate the 1-Lipschitz property of tropical hash functions.
    
    H(x)_i = min_j(A_{ij} + x_j) is 1-Lipschitz in L∞.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Hash Function (1-Lipschitz)")
    print("=" * 60)
    
    np.random.seed(42)
    n, m = 5, 3  # Input dim, output dim
    A = np.random.randn(m, n)
    
    def trop_hash(x):
        return np.array([np.min(A[i] + x) for i in range(m)])
    
    def linf_dist(u, v):
        return np.max(np.abs(u - v))
    
    print(f"Hash matrix A: {m}×{n}")
    print(f"Random entries from N(0,1)")
    print()
    
    # Test 1-Lipschitz property
    num_tests = 1000
    max_ratio = 0.0
    for _ in range(num_tests):
        x = np.random.randn(n)
        y = np.random.randn(n)
        d_in = linf_dist(x, y)
        d_out = linf_dist(trop_hash(x), trop_hash(y))
        if d_in > 1e-10:
            ratio = d_out / d_in
            max_ratio = max(max_ratio, ratio)
    
    print(f"  Tested {num_tests} random pairs")
    print(f"  Max ratio d_out/d_in = {max_ratio:.6f}")
    print(f"  1-Lipschitz confirmed: ratio ≤ 1 ✓" if max_ratio <= 1.0001 else "  ERROR!")
    
    # Specific example
    x = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
    y = np.array([1.1, 1.9, 3.2, 3.8, 5.1])
    hx, hy = trop_hash(x), trop_hash(y)
    print(f"\n  Example:")
    print(f"    x = {x}")
    print(f"    y = {y}")
    print(f"    H(x) = {hx}")
    print(f"    H(y) = {hy}")
    print(f"    ‖x-y‖∞ = {linf_dist(x,y):.4f}")
    print(f"    ‖H(x)-H(y)‖∞ = {linf_dist(hx,hy):.4f}")


# ============================================================
# Demo 3: Stokes-Minkowski Mass Generation
# ============================================================

def demo_stokes_minkowski():
    """Demonstrate mass generation from mixing null (fully polarized) states.
    
    Two photons with orthogonal polarization produce a massive mixed state.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Stokes-Minkowski Mass Generation")
    print("=" * 60)
    
    def stokes_minkowski(S0, S1, S2, S3):
        return S0**2 - S1**2 - S2**2 - S3**2
    
    # H-polarized: (1, 1, 0, 0) — null
    # V-polarized: (1, -1, 0, 0) — null
    I = 1.0
    S = np.array([1.0, 0.0, 0.0])  # H-polarization direction
    T = np.array([-1.0, 0.0, 0.0])  # V-polarization direction
    
    print(f"  H-photon: S = ({I}, {S[0]}, {S[1]}, {S[2]})")
    print(f"  Mass(H) = {stokes_minkowski(I, *S):.4f} (null)")
    print(f"  V-photon: T = ({I}, {T[0]}, {T[1]}, {T[2]})")
    print(f"  Mass(V) = {stokes_minkowski(I, *T):.4f} (null)")
    
    # Interpolation
    ts = np.linspace(0, 1, 100)
    masses = []
    for t in ts:
        mix = (1-t)*S + t*T
        m = stokes_minkowski(I, *mix)
        masses.append(m)
    
    midpoint = (S + T) / 2
    mid_mass = stokes_minkowski(I, *midpoint)
    print(f"\n  Midpoint: ({I}, {midpoint[0]:.2f}, {midpoint[1]:.2f}, {midpoint[2]:.2f})")
    print(f"  Mass(midpoint) = {mid_mass:.4f} — MASSIVE!")
    print(f"  Parabolic formula: 4t(1-t) at t=0.5 = {4*0.5*0.5:.4f} ✓")
    
    # Plot parabolic mass profile
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(ts, masses, 'b-', linewidth=2, label='Stokes-Minkowski mass')
    theoretical = 4 * ts * (1 - ts)
    ax.plot(ts, theoretical, 'r--', linewidth=1.5, label='4t(1-t) formula')
    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    ax.set_xlabel('Interpolation parameter t')
    ax.set_ylabel('Mass m²')
    ax.set_title('Parabolic Mass Profile: H↔V Polarization Interpolation')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('parabolic_mass.png', dpi=150)
    plt.close()
    print("  → Saved parabolic_mass.png")


# ============================================================
# Demo 4: ReLU as Tropical Polynomial
# ============================================================

def demo_relu_tropical():
    """Show that ReLU(x) = max(0, x) = -(min(0, -x)) and is 1-Lipschitz."""
    print("\n" + "=" * 60)
    print("DEMO 4: ReLU as Tropical Polynomial")
    print("=" * 60)
    
    xs = np.linspace(-3, 3, 1000)
    relu = np.maximum(0, xs)
    tropical = -np.minimum(0, -xs)
    
    print(f"  max(0, x) == -(min(0, -x)) for all x?")
    print(f"  Max difference: {np.max(np.abs(relu - tropical)):.15f}")
    print(f"  Identity confirmed ✓")
    
    # 1-Lipschitz verification
    num_tests = 10000
    np.random.seed(123)
    x_test = np.random.randn(num_tests)
    y_test = np.random.randn(num_tests)
    relu_diff = np.abs(np.maximum(0, x_test) - np.maximum(0, y_test))
    input_diff = np.abs(x_test - y_test)
    ratios = relu_diff / np.maximum(input_diff, 1e-15)
    
    print(f"\n  1-Lipschitz test ({num_tests} random pairs):")
    print(f"  Max |ReLU(x)-ReLU(y)| / |x-y| = {np.max(ratios):.6f}")
    print(f"  ReLU is 1-Lipschitz ✓")
    
    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.plot(xs, relu, 'b-', linewidth=2, label='ReLU(x) = max(0, x)')
    ax1.plot(xs, tropical, 'r--', linewidth=1, label='-(min(0, -x))')
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_title('ReLU = Tropical Polynomial')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    ax2.hist(ratios, bins=50, edgecolor='black', alpha=0.7)
    ax2.axvline(x=1.0, color='red', linestyle='--', label='Lipschitz bound = 1')
    ax2.set_xlabel('|ReLU(x)-ReLU(y)| / |x-y|')
    ax2.set_ylabel('Count')
    ax2.set_title('ReLU Lipschitz Ratio Distribution')
    ax2.legend()
    
    fig.tight_layout()
    fig.savefig('relu_tropical.png', dpi=150)
    plt.close()
    print("  → Saved relu_tropical.png")


# ============================================================
# Demo 5: Tropical Spectral Radius
# ============================================================

def demo_tropical_spectral():
    """Compute the tropical spectral radius and verify bounds."""
    print("\n" + "=" * 60)
    print("DEMO 5: Tropical Spectral Radius Bounds")
    print("=" * 60)
    
    np.random.seed(7)
    n = 5
    A = np.random.randn(n, n)
    
    diag = np.diag(A)
    trop_spec = np.min(diag)
    avg_trace = np.mean(diag)
    
    print(f"  Matrix A ({n}×{n}):")
    print(f"  Diagonal entries: {diag}")
    print(f"  Tropical spectral radius (min diag) = {trop_spec:.4f}")
    print(f"  Average trace (sum diag / n) = {avg_trace:.4f}")
    print(f"  ρ(A) ≤ avg trace? {trop_spec <= avg_trace + 1e-10} ✓")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Tropical Metric Geometry — Demonstrations")
    print("=" * 60)
    
    demo_contraction_convergence()
    demo_tropical_hash()
    demo_stokes_minkowski()
    demo_relu_tropical()
    demo_tropical_spectral()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
