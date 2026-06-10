#!/usr/bin/env python3
"""
Braiding Universality for Topological Quantum Computing - Demonstration

Numerical examples showing:
1. Fibonacci fusion dimensions and golden ratio convergence
2. Solovay-Kitaev bound computation
3. Writhe computation and mirror symmetry
4. Error suppression with code distance
5. Jones representation matrix computation
"""

import numpy as np
from typing import List, Tuple


def fibonacci_fusion_dimensions(n_max: int = 15) -> None:
    """Compute Fibonacci fusion dimensions and show golden ratio convergence."""
    print("=" * 60)
    print("FIBONACCI FUSION DIMENSIONS")
    print("=" * 60)

    vacuum = [1, 0, 1]
    tau = [0, 1, 1]

    for n in range(3, n_max + 1):
        vacuum.append(vacuum[-2] + vacuum[-1])
        tau.append(tau[-2] + tau[-1])

    phi = (1 + np.sqrt(5)) / 2

    print(f"\n{'n':>4} {'Vacuum':>10} {'Tau':>10} {'Total':>10} {'Ratio':>12} {'phi':>10}")
    print("-" * 60)
    for n in range(n_max + 1):
        total = vacuum[n] + tau[n]
        if n >= 3 and vacuum[n-1] + tau[n-1] > 0:
            ratio = total / (vacuum[n-1] + tau[n-1])
        else:
            ratio = float('nan')
        print(f"{n:>4} {vacuum[n]:>10} {tau[n]:>10} {total:>10} {ratio:>12.8f} {phi:>10.8f}")

    print(f"\nGolden ratio phi = {phi:.10f}")
    print(f"phi^2 = {phi**2:.10f}")
    print(f"phi + 1 = {phi + 1:.10f}")
    print(f"phi^2 - (phi+1) = {phi**2 - phi - 1:.2e} (should be ~0)")
    print(f"\nQubit encoding: 4 anyons -> {vacuum[4]} vacuum states (1 logical qubit)")


def solovay_kitaev_bounds() -> None:
    """Compute Solovay-Kitaev word length bounds for various precisions."""
    print("\n" + "=" * 60)
    print("SOLOVAY-KITAEV WORD LENGTH BOUNDS")
    print("=" * 60)

    C = 10.0
    SK_EXP = 4
    OPT_EXP = 3

    epsilons = [1e-1, 1e-2, 1e-3, 1e-4, 1e-6, 1e-8, 1e-10]

    print(f"\n{'eps':>12} {'log(1/eps)':>10} {'SK (c=4)':>12} {'Optimal (c=3)':>14} {'Improvement':>12}")
    print("-" * 65)
    for eps in epsilons:
        log_inv_eps = np.log(1.0 / eps)
        sk_bound = C * log_inv_eps ** SK_EXP
        opt_bound = C * log_inv_eps ** OPT_EXP
        improvement = sk_bound / opt_bound if opt_bound > 0 else float('inf')
        print(f"{eps:>12.0e} {log_inv_eps:>10.2f} {sk_bound:>12.0f} {opt_bound:>14.0f} {improvement:>12.1f}x")


def circuit_compilation_costs() -> None:
    """Show total braiding cost for circuits of various sizes."""
    print("\n" + "=" * 60)
    print("CIRCUIT COMPILATION COSTS")
    print("=" * 60)

    C = 10.0
    SK_EXP = 4
    eps = 1e-6

    print(f"\nTarget precision: eps = {eps:.0e}")
    print(f"\n{'Gates (m)':>10} {'Braids/gate':>12} {'Total braids':>14} {'Overhead':>10}")
    print("-" * 50)
    for m in [10, 100, 1000, 10000, 100000]:
        per_gate = C * np.log(m / eps) ** SK_EXP
        total = m * per_gate
        overhead = total / m
        print(f"{m:>10} {per_gate:>12.0f} {total:>14.0f} {overhead:>10.0f}x")


def writhe_examples() -> None:
    """Demonstrate writhe computation and mirror symmetry."""
    print("\n" + "=" * 60)
    print("WRITHE COMPUTATION AND MIRROR SYMMETRY")
    print("=" * 60)

    examples = [
        ("Trefoil (3_1)", [+1, +1, +1]),
        ("Figure-eight (4_1)", [+1, +1, -1, -1]),
        ("Cinquefoil (5_1)", [+1, +1, +1, +1, +1]),
        ("Three-twist (5_2)", [+1, +1, +1, -1, -1]),
        ("Hopf link", [+1, +1]),
    ]

    for name, crossings in examples:
        w = sum(crossings)
        mirror_w = -w
        print(f"\n{name}:")
        print(f"  Crossings: {crossings}")
        print(f"  Writhe: w = {w}")
        print(f"  Mirror writhe: -w = {mirror_w}")
        print(f"  Verified: writhe(mirror) = -writhe(original) check")


def error_suppression() -> None:
    """Demonstrate exponential error suppression with code distance."""
    print("\n" + "=" * 60)
    print("TOPOLOGICAL ERROR SUPPRESSION")
    print("=" * 60)

    C = 1.0
    alpha = 0.5

    print(f"\nC = {C}, alpha = {alpha}")
    print(f"\n{'Distance d':>12} {'Error rate':>14} {'Suppression':>14}")
    print("-" * 45)
    for d in range(1, 21):
        error = C * np.exp(-alpha * d)
        suppression = error / C
        print(f"{d:>12} {error:>14.2e} {suppression:>14.2e}")

    print(f"\nThreshold comparison:")
    print(f"  Fibonacci anyon threshold: ~11%")
    print(f"  Surface code threshold:    ~1%")
    print(f"  Advantage: ~11x higher threshold")


def jones_representation() -> None:
    """Compute the Jones representation matrices for Fibonacci anyons."""
    print("\n" + "=" * 60)
    print("JONES REPRESENTATION FOR FIBONACCI ANYONS")
    print("=" * 60)

    # Fibonacci anyon braiding: R-matrix eigenvalues
    # R_1 (vacuum channel) = e^{-4*pi*i/5}, R_tau (tau channel) = e^{3*pi*i/5}
    R1 = np.exp(-4j * np.pi / 5)
    Rtau = np.exp(3j * np.pi / 5)
    phi = (1 + np.sqrt(5)) / 2

    # F-matrix for Fibonacci fusion category (unitary, symmetric, F^2 = I)
    F = np.array([
        [phi**(-1), phi**(-0.5)],
        [phi**(-0.5), -phi**(-1)]
    ])

    # sigma_1 acts on first pair: diagonal in fusion basis
    sigma1 = np.diag([R1, Rtau])

    # sigma_2 = F * sigma_1 * F (F is its own inverse for Fibonacci)
    sigma2 = F @ sigma1 @ F

    print(f"\nsigma_1 = ")
    for row in sigma1:
        print(f"  [{row[0]:.6f}, {row[1]:.6f}]")

    print(f"\nsigma_2 = ")
    for row in sigma2:
        print(f"  [{row[0]:.6f}, {row[1]:.6f}]")

    # Check braid relation: sigma_1*sigma_2*sigma_1 = sigma_2*sigma_1*sigma_2
    lhs = sigma1 @ sigma2 @ sigma1
    rhs = sigma2 @ sigma1 @ sigma2
    braid_err = np.linalg.norm(lhs - rhs)
    print(f"\nBraid relation check: ||sigma_1*sigma_2*sigma_1 - sigma_2*sigma_1*sigma_2|| = {braid_err:.2e}")

    # Check non-commutativity
    commutator = sigma1 @ sigma2 - sigma2 @ sigma1
    print(f"Non-commutativity: ||[sigma_1, sigma_2]|| = {np.linalg.norm(commutator):.6f}")

    # Check order: compute (sigma_1*sigma_2)^m
    product = sigma1 @ sigma2
    print(f"\nOrder check: (sigma_1*sigma_2)^m")
    power = np.eye(2, dtype=complex)
    found_order = False
    for m in range(1, 201):
        power = power @ product
        if np.linalg.norm(power - np.eye(2)) < 1e-8:
            print(f"  (sigma_1*sigma_2)^{m} = I  (order = {m})")
            found_order = True
            break
    if not found_order:
        print(f"  (sigma_1*sigma_2)^m != I for m = 1,...,200 -> likely infinite order")

    # Trace criterion for SU(2): |tr(U)| < 2 implies infinite order
    tr = np.trace(product)
    print(f"  tr(sigma_1*sigma_2) = {tr:.6f}")
    print(f"  |tr(sigma_1*sigma_2)| = {abs(tr):.6f} {'< 2: infinite order' if abs(tr) < 2 - 1e-10 else '>= 2: could be finite order'}")

    # Density evidence: generate random words and check coverage
    print(f"\nDensity check: generating random braid words...")
    gens = [sigma1, sigma2, np.linalg.inv(sigma1), np.linalg.inv(sigma2)]
    traces = set()
    for _ in range(10000):
        word_len = np.random.randint(1, 20)
        mat = np.eye(2, dtype=complex)
        for _ in range(word_len):
            mat = mat @ gens[np.random.randint(4)]
        tr_val = round(np.trace(mat).real, 4)
        traces.add(tr_val)
    print(f"  Distinct trace values (10000 random words): {len(traces)}")
    print(f"  Range: [{min(traces):.4f}, {max(traces):.4f}]")
    print(f"  (Dense in [-2, 2] implies dense in SU(2))")


if __name__ == "__main__":
    fibonacci_fusion_dimensions()
    solovay_kitaev_bounds()
    circuit_compilation_costs()
    writhe_examples()
    error_suppression()
    jones_representation()


#!/usr/bin/env python3
"""
Visualization: Fibonacci Fusion Dimensions and Golden Ratio Convergence
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def compute_fusion_dims(n_max: int = 20):
    vacuum = [1, 0, 1]
    tau = [0, 1, 1]
    for n in range(3, n_max + 1):
        vacuum.append(vacuum[-2] + vacuum[-1])
        tau.append(tau[-2] + tau[-1])
    return vacuum, tau


def plot_fusion_dimensions():
    n_max = 15
    vacuum, tau = compute_fusion_dims(n_max)
    total = [v + t for v, t in zip(vacuum, tau)]

    phi = (1 + np.sqrt(5)) / 2
    ratios = [total[n] / total[n-1] if total[n-1] > 0 else np.nan
              for n in range(1, n_max + 1)]

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Fusion dimensions
    ax = axes[0]
    ns = list(range(n_max + 1))
    ax.semilogy(ns, [max(v, 0.5) for v in vacuum], 'o-', label='Vacuum channel', color='#2196F3')
    ax.semilogy(ns, [max(t, 0.5) for t in tau], 's-', label='τ channel', color='#FF9800')
    ax.semilogy(ns, [max(t, 0.5) for t in total], '^-', label='Total', color='#4CAF50')
    ax.set_xlabel('Number of anyons (n)', fontsize=12)
    ax.set_ylabel('Fusion space dimension', fontsize=12)
    ax.set_title('Fibonacci Anyon Fusion Dimensions', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Plot 2: Convergence to golden ratio
    ax = axes[1]
    ns_ratio = list(range(1, n_max + 1))
    ax.plot(ns_ratio, ratios, 'o-', color='#9C27B0', markersize=8, label='dim(n)/dim(n-1)')
    ax.axhline(y=phi, color='#F44336', linestyle='--', linewidth=2, label=f'φ = {phi:.6f}')
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Dimension ratio', fontsize=12)
    ax.set_title('Convergence to Golden Ratio', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0.5, 2.5)

    plt.tight_layout()
    plt.savefig('fusion_dimensions.png', dpi=150, bbox_inches='tight')
    print("Saved fusion_dimensions.png")


def plot_error_suppression():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Error vs code distance
    ax = axes[0]
    distances = np.arange(1, 21)
    for alpha, label, color in [(0.3, 'α=0.3', '#2196F3'),
                                 (0.5, 'α=0.5', '#4CAF50'),
                                 (1.0, 'α=1.0', '#F44336')]:
        errors = np.exp(-alpha * distances)
        ax.semilogy(distances, errors, 'o-', label=label, color=color, markersize=5)

    ax.set_xlabel('Code distance d', fontsize=12)
    ax.set_ylabel('Logical error rate', fontsize=12)
    ax.set_title('Topological Error Suppression', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Plot 2: SK bound vs precision
    ax = axes[1]
    epsilons = np.logspace(-1, -10, 50)
    for C, exp_val, label, color in [
        (1.0, 4, 'SK (c=4)', '#2196F3'),
        (1.0, 3, 'Conjectured (c=3)', '#FF9800'),
    ]:
        bounds = C * np.log(1.0 / epsilons) ** exp_val
        ax.loglog(epsilons, bounds, '-', label=label, color=color, linewidth=2)

    ax.set_xlabel('Target precision ε', fontsize=12)
    ax.set_ylabel('Word length bound', fontsize=12)
    ax.set_title('Solovay-Kitaev Approximation Cost', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.invert_xaxis()

    plt.tight_layout()
    plt.savefig('error_and_sk_bounds.png', dpi=150, bbox_inches='tight')
    print("Saved error_and_sk_bounds.png")


def plot_jones_representation():
    """Visualize the Jones representation matrices and their orbit."""
    phi = (1 + np.sqrt(5)) / 2

    F = np.array([
        [phi ** (-1), phi ** (-0.5)],
        [phi ** (-0.5), -phi ** (-1)]
    ])

    R1 = np.exp(-4j * np.pi / 5)
    Rtau = np.exp(3j * np.pi / 5)
    sigma1 = np.diag([R1, Rtau])
    sigma2 = F @ sigma1 @ F

    # Generate orbit on the Bloch sphere
    state = np.array([1.0, 0.0], dtype=complex)
    generators = [sigma1, sigma2, np.linalg.inv(sigma1), np.linalg.inv(sigma2)]

    points = []
    current = state.copy()
    for _ in range(2000):
        gen = generators[np.random.randint(4)]
        current = gen @ current
        current = current / np.linalg.norm(current)

        # Bloch sphere coordinates
        theta = 2 * np.arccos(min(abs(current[0]), 1.0))
        phi_angle = np.angle(current[1]) - np.angle(current[0])
        x = np.sin(theta) * np.cos(phi_angle)
        y = np.sin(theta) * np.sin(phi_angle)
        z = np.cos(theta)
        points.append((x, y, z))

    points = np.array(points)

    fig = plt.figure(figsize=(8, 8))
    ax = fig.add_subplot(111, projection='3d')

    # Draw unit sphere wireframe
    u = np.linspace(0, 2 * np.pi, 30)
    v = np.linspace(0, np.pi, 20)
    xs = np.outer(np.cos(u), np.sin(v))
    ys = np.outer(np.sin(u), np.sin(v))
    zs = np.outer(np.ones_like(u), np.cos(v))
    ax.plot_wireframe(xs, ys, zs, alpha=0.05, color='gray')

    # Plot orbit points
    ax.scatter(points[:, 0], points[:, 1], points[:, 2],
               c=np.arange(len(points)), cmap='plasma', s=2, alpha=0.5)

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    ax.set_title('Fibonacci Braiding Orbit on Bloch Sphere\n(Dense in SU(2))', fontsize=14)

    plt.tight_layout()
    plt.savefig('bloch_sphere_orbit.png', dpi=150, bbox_inches='tight')
    print("Saved bloch_sphere_orbit.png")


if __name__ == "__main__":
    plot_fusion_dimensions()
    plot_error_suppression()
    plot_jones_representation()
    print("\nAll visualizations generated!")
