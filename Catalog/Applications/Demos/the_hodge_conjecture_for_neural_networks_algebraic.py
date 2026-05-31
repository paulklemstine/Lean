"""
Demo: Neural Hodge Theory — Algebraic Cycles in Decision Surfaces

Demonstrates the key results:
1. Zaslavsky bounds for hyperplane arrangements
2. Network region bounds for various architectures
3. Hodge number bound conjecture verification
4. Polyhedral complex face counting
"""

import numpy as np
from algorithms import (
    relu, zaslavsky_bound, NetworkArchitecture, PLComplex,
    ReLUNetwork, estimate_betti_from_grid, verify_hodge_bound
)


def demo_zaslavsky_bounds():
    """Demonstrate Zaslavsky bound properties."""
    print("=" * 60)
    print("ZASLAVSKY BOUNDS: Regions from Hyperplane Arrangements")
    print("=" * 60)

    print("\nZaslavsky bound Z(m, n) = sum_{k=0}^{n} C(m, k)")
    print("  = max regions from m hyperplanes in R^n\n")

    header = 'm \\ n'
    print(f"{header:>6}", end="")
    for n in range(1, 7):
        print(f"  n={n:>2}", end="")
    print()
    print("-" * 48)

    for m in range(8):
        print(f"m={m:>3} |", end="")
        for n in range(1, 7):
            z = zaslavsky_bound(m, n)
            print(f"  {z:>4}", end="")
        print()

    print("\nVerification: Z(0, n) = 1 for all n (proved in Lean)")
    for n in range(1, 6):
        assert zaslavsky_bound(0, n) == 1, f"Failed for n={n}"
    print("  ✓ All pass")

    print("\nVerification: Z(1, n) = min(2, n+1) (proved in Lean)")
    for n in range(6):
        assert zaslavsky_bound(1, n) == min(2, n + 1), f"Failed for n={n}"
    print("  ✓ All pass")

    print("\nVerification: Z(m, n) ≤ (m+1)^n (proved in Lean)")
    for m in range(1, 8):
        for n in range(1, 6):
            assert zaslavsky_bound(m, n) <= (m + 1) ** n
    print("  ✓ All pass")


def demo_network_bounds():
    """Demonstrate network region bounds for various architectures."""
    print("\n" + "=" * 60)
    print("NETWORK REGION BOUNDS")
    print("=" * 60)

    architectures = [
        NetworkArchitecture(2, [4]),
        NetworkArchitecture(2, [4, 4]),
        NetworkArchitecture(2, [8, 8]),
        NetworkArchitecture(2, [4, 4, 4]),
        NetworkArchitecture(3, [4, 4]),
        NetworkArchitecture(3, [8, 8]),
        NetworkArchitecture(10, [20, 20]),
    ]

    print(f"\n{'Architecture':>30} {'Region Bound':>14} {'Poly Bound':>14} {'Hodge h^01':>12}")
    print("-" * 72)

    for arch in architectures:
        desc = f"{arch.input_dim} → {' → '.join(map(str, arch.hidden_widths))} → 1"
        rb = arch.region_bound()
        pb = arch.polynomial_region_bound()
        hb = arch.hodge_number_bound(0, 1)
        print(f"{desc:>30} {rb:>14,} {pb:>14,} {hb:>12,}")


def demo_polyhedral_complex():
    """Demonstrate polyhedral complex properties."""
    print("\n" + "=" * 60)
    print("POLYHEDRAL COMPLEX FACE COUNTING")
    print("=" * 60)

    # Example: A 2D polyhedral complex (triangulation of a region)
    # with f_0=6 vertices, f_1=10 edges, f_2=5 triangles
    K = PLComplex(dim=2, f_vec=[6, 10, 5])
    print(f"\nExample: Triangulated region")
    print(f"  f-vector: {K.f_vec}")
    print(f"  Total faces: {K.total_faces}")
    print(f"  Euler characteristic: {K.euler_characteristic}")
    print(f"  |χ| ≤ total faces: {abs(K.euler_characteristic)} ≤ {K.total_faces} ✓")

    # Example: Decision surface of a small network
    # In R^2, a 2→4→1 network creates at most Z(4,2) = 11 regions
    # The decision curve has at most 11 linear pieces
    K2 = PLComplex(dim=1, f_vec=[12, 11])  # 12 vertices, 11 edges
    print(f"\nDecision curve (2→4→1 network)")
    print(f"  f-vector: {K2.f_vec}")
    print(f"  Total faces: {K2.total_faces}")
    print(f"  Euler characteristic: {K2.euler_characteristic}")
    print(f"  Betti bound β_0 ≤ f_0 = {K2.betti_bound(0)}")
    print(f"  Betti bound β_1 ≤ f_1 = {K2.betti_bound(1)}")


def demo_hodge_conjecture():
    """Test the neural Hodge bound conjecture empirically."""
    print("\n" + "=" * 60)
    print("NEURAL HODGE BOUND CONJECTURE — EMPIRICAL TEST")
    print("=" * 60)

    architectures = [
        NetworkArchitecture(2, [4, 4]),
        NetworkArchitecture(2, [8, 8]),
        NetworkArchitecture(2, [4, 4, 4]),
        NetworkArchitecture(2, [8, 4]),
    ]

    for arch in architectures:
        result = verify_hodge_bound(arch, num_trials=50)
        desc = result["architecture"]
        print(f"\nArchitecture: {desc}")
        print(f"  Region bound: {result['region_bound']}")
        print(f"  Hodge bound h^{{0,1}}: {result['hodge_bound_01']}")
        print(f"  Max observed β₀: {result['max_beta0']}")
        print(f"  Violations: {result['violations']}/{result['trials']}")
        status = "✓ HOLDS" if result['violations'] == 0 else "✗ VIOLATED"
        print(f"  Status: {status}")


def demo_relu_properties():
    """Demonstrate ReLU properties proved in Lean."""
    print("\n" + "=" * 60)
    print("ReLU PROPERTIES (verified in Lean)")
    print("=" * 60)

    xs = np.linspace(-2, 2, 9)
    print(f"\n{'x':>8} {'relu(x)':>10} {'|x|':>8} {'relu≤|x|':>10} {'(x+|x|)/2':>12}")
    print("-" * 52)
    for x in xs:
        r = relu(x)
        a = abs(x)
        half = (x + abs(x)) / 2
        print(f"{x:>8.2f} {r:>10.2f} {a:>8.2f} {'✓' if r <= a + 1e-10 else '✗':>10} {half:>12.2f}")

    print("\nIdempotency: relu(relu(x)) = relu(x)")
    for x in xs:
        assert abs(relu(relu(x)) - relu(x)) < 1e-15
    print("  ✓ Verified for all test points")

    print("\nLipschitz: |relu(x) - relu(y)| ≤ |x - y|")
    for x in xs:
        for y in xs:
            assert abs(relu(x) - relu(y)) <= abs(x - y) + 1e-15
    print("  ✓ Verified for all test pairs")


if __name__ == "__main__":
    demo_relu_properties()
    demo_zaslavsky_bounds()
    demo_network_bounds()
    demo_polyhedral_complex()
    demo_hodge_conjecture()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


"""
Visualization: Decision surfaces of ReLU neural networks.

Shows how the zero set V(f) = {x : f(x) = 0} forms a piecewise linear
hypersurface, and how its complexity grows with network width and depth.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap


def relu(x):
    return np.maximum(x, 0.0)


def make_random_network(input_dim, hidden_widths, seed=42):
    """Create a random ReLU network."""
    rng = np.random.RandomState(seed)
    widths = [input_dim] + hidden_widths + [1]
    weights = [rng.randn(widths[i+1], widths[i]) * 0.8 for i in range(len(widths)-1)]
    biases = [rng.randn(widths[i+1]) * 0.3 for i in range(len(widths)-1)]
    return weights, biases


def forward(weights, biases, x):
    """Evaluate network at point x."""
    h = x.copy()
    for i, (W, b) in enumerate(zip(weights, biases)):
        h = W @ h + b
        if i < len(weights) - 1:
            h = relu(h)
    return h[0]


def evaluate_grid(weights, biases, bounds=(-3, 3), resolution=400):
    """Evaluate network on a 2D grid."""
    lo, hi = bounds
    xs = np.linspace(lo, hi, resolution)
    ys = np.linspace(lo, hi, resolution)
    X, Y = np.meshgrid(xs, ys)
    Z = np.zeros_like(X)
    for i in range(resolution):
        for j in range(resolution):
            Z[i, j] = forward(weights, biases, np.array([X[i, j], Y[i, j]]))
    return X, Y, Z


def main():
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Decision Surfaces of ReLU Networks\n'
                 'V(f) = {x : f(x) = 0} shown as black curves',
                 fontsize=14, fontweight='bold')

    configs = [
        ("2→2→1 (depth 1)", [2], 1),
        ("2→4→1 (depth 1)", [4], 2),
        ("2→8→1 (depth 1)", [8], 3),
        ("2→4→4→1 (depth 2)", [4, 4], 4),
        ("2→8→8→1 (depth 2)", [8, 8], 5),
        ("2→4→4→4→1 (depth 3)", [4, 4, 4], 6),
    ]

    cmap = LinearSegmentedColormap.from_list('bwr', ['#2166ac', 'white', '#b2182b'])

    for idx, (title, widths, seed) in enumerate(configs):
        ax = axes[idx // 3][idx % 3]
        W, B = make_random_network(2, widths, seed=seed * 17)
        X, Y, Z = evaluate_grid(W, B, bounds=(-3, 3), resolution=300)

        vmax = np.percentile(np.abs(Z), 95)
        ax.contourf(X, Y, Z, levels=50, cmap=cmap, vmin=-vmax, vmax=vmax)
        ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
        ax.set_title(title, fontsize=11)
        ax.set_xlim(-3, 3)
        ax.set_ylim(-3, 3)
        ax.set_aspect('equal')
        ax.set_xlabel('x₁')
        ax.set_ylabel('x₂')

    plt.tight_layout()
    plt.savefig('decision_surfaces.png', dpi=150, bbox_inches='tight')
    print("Saved decision_surfaces.png")


if __name__ == "__main__":
    main()


"""
Visualization: Hodge number bounds for neural network decision surfaces.

Shows the conjectured bound on h^{p,q} for various network architectures,
along with empirical Betti number estimates.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb, prod


def relu(x):
    return np.maximum(x, 0.0)


def hodge_bound(hidden_widths, p, q):
    if len(hidden_widths) < 2:
        return 1
    w1 = hidden_widths[0]
    wL = hidden_widths[-1]
    middle = prod(hidden_widths[1:-1]) if len(hidden_widths) > 2 else 1
    return comb(w1, p) * comb(wL, q) * middle


def estimate_components(hidden_widths, seed=42, resolution=150):
    """Estimate connected components of positive region for a random network."""
    rng = np.random.RandomState(seed)
    widths = [2] + hidden_widths + [1]
    weights = [rng.randn(widths[i+1], widths[i]) * 0.6 for i in range(len(widths)-1)]
    biases = [rng.randn(widths[i+1]) * 0.2 for i in range(len(widths)-1)]

    xs = np.linspace(-4, 4, resolution)
    ys = np.linspace(-4, 4, resolution)
    signs = np.zeros((resolution, resolution), dtype=int)

    for i in range(resolution):
        for j in range(resolution):
            h = np.array([xs[j], ys[i]])
            for k, (W, b) in enumerate(zip(weights, biases)):
                h = W @ h + b
                if k < len(weights) - 1:
                    h = relu(h)
            signs[i, j] = 1 if h[0] > 0 else 0

    visited = np.zeros_like(signs, dtype=bool)
    components = 0
    for i in range(resolution):
        for j in range(resolution):
            if not visited[i, j] and signs[i, j] == 1:
                stack = [(i, j)]
                while stack:
                    ci, cj = stack.pop()
                    if visited[ci, cj]:
                        continue
                    visited[ci, cj] = True
                    for di, dj in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                        ni, nj = ci + di, cj + dj
                        if 0 <= ni < resolution and 0 <= nj < resolution:
                            if not visited[ni, nj] and signs[ni, nj] == 1:
                                stack.append((ni, nj))
                components += 1
    return components


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Hodge Number Bounds for Neural Network Decision Surfaces',
                 fontsize=14, fontweight='bold')

    # Panel 1: h^{0,q} bound as function of width
    ax = axes[0]
    widths = range(2, 17)
    for q in [1, 2, 3, 4]:
        bounds = [hodge_bound([w, w], 0, q) for w in widths]
        ax.plot(list(widths), bounds, 'o-', label=f'h^{{0,{q}}}', markersize=4)
    ax.set_xlabel('Layer width (w)')
    ax.set_ylabel('Hodge bound')
    ax.set_title('h^{0,q} bound (2-layer, width w)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Bound vs empirical for h^{0,1}
    ax = axes[1]
    configs = [
        [4, 4], [6, 6], [8, 8], [4, 4, 4], [6, 6, 6],
        [8, 4], [4, 8], [10, 10],
    ]
    bounds_list = []
    empirical_list = []
    labels = []
    for hw in configs:
        b = hodge_bound(hw, 0, 1)
        # Average over several seeds
        emp = max(estimate_components(hw, seed=s) for s in range(1, 11))
        bounds_list.append(b)
        empirical_list.append(emp)
        labels.append('→'.join(map(str, hw)))

    x_pos = range(len(configs))
    ax.bar([x - 0.15 for x in x_pos], bounds_list, 0.3, label='Hodge bound', color='steelblue')
    ax.bar([x + 0.15 for x in x_pos], empirical_list, 0.3, label='Empirical max β₀', color='coral')
    ax.set_xticks(list(x_pos))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.set_ylabel('Count')
    ax.set_title('Bound vs Empirical β₀')
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 3: Hodge bound matrix h^{p,q} for a specific architecture
    ax = axes[2]
    hw = [8, 8]
    max_pq = 5
    matrix = np.zeros((max_pq, max_pq))
    for p in range(max_pq):
        for q in range(max_pq):
            matrix[p, q] = hodge_bound(hw, p, q)

    im = ax.imshow(matrix, cmap='YlOrRd', aspect='equal')
    for p in range(max_pq):
        for q in range(max_pq):
            val = int(matrix[p, q])
            ax.text(q, p, str(val), ha='center', va='center',
                    fontsize=8, color='black' if val < matrix.max() * 0.7 else 'white')
    ax.set_xlabel('q')
    ax.set_ylabel('p')
    ax.set_title('h^{p,q} bound (8→8 network)')
    ax.set_xticks(range(max_pq))
    ax.set_yticks(range(max_pq))
    plt.colorbar(im, ax=ax, shrink=0.8)

    plt.tight_layout()
    plt.savefig('hodge_bounds.png', dpi=150, bbox_inches='tight')
    print("Saved hodge_bounds.png")


if __name__ == "__main__":
    main()


"""
Visualization: Zaslavsky bounds and network region counting.

Shows how the number of linear regions grows with network width and depth,
and compares the exact Zaslavsky bound with the polynomial approximation.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import comb, prod


def zaslavsky_bound(m, n):
    return sum(comb(m, k) for k in range(n + 1))


def network_region_bound(input_dim, hidden_widths):
    return prod(zaslavsky_bound(w, input_dim) for w in hidden_widths)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Zaslavsky Bounds and Network Region Counting',
                 fontsize=14, fontweight='bold')

    # Panel 1: Zaslavsky bound vs m for various n
    ax = axes[0]
    ms = range(1, 21)
    for n in [1, 2, 3, 5, 10]:
        zs = [zaslavsky_bound(m, n) for m in ms]
        ax.semilogy(ms, zs, 'o-', label=f'n={n}', markersize=3)
    ax.set_xlabel('Number of hyperplanes (m)')
    ax.set_ylabel('Max regions Z(m, n)')
    ax.set_title('Zaslavsky Bound Z(m, n)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Comparison with polynomial bound
    ax = axes[1]
    ms = range(1, 16)
    n = 3
    zs = [zaslavsky_bound(m, n) for m in ms]
    poly = [(m + 1) ** n for m in ms]
    exp = [2 ** m for m in ms]
    ax.semilogy(ms, zs, 'bo-', label=f'Z(m, {n})', markersize=4)
    ax.semilogy(ms, poly, 'r--', label=f'(m+1)^{n}', linewidth=1.5)
    ax.semilogy(ms, exp, 'g:', label='2^m', linewidth=1.5)
    ax.set_xlabel('Number of hyperplanes (m)')
    ax.set_ylabel('Bound value')
    ax.set_title(f'Bound Comparison (n={n})')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Network region bound vs depth
    ax = axes[2]
    widths_list = [4, 8, 16]
    depths = range(1, 8)
    for w in widths_list:
        bounds = [network_region_bound(2, [w] * d) for d in depths]
        ax.semilogy(list(depths), bounds, 'o-', label=f'width={w}', markersize=4)
    ax.set_xlabel('Network depth (L)')
    ax.set_ylabel('Region bound')
    ax.set_title('Network Region Bound (input dim=2)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('zaslavsky_bounds.png', dpi=150, bbox_inches='tight')
    print("Saved zaslavsky_bounds.png")


if __name__ == "__main__":
    main()
