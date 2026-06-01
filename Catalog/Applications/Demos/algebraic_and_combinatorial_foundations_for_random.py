#!/usr/bin/env python3
"""
Demo: Random Matrix Foundations

Demonstrates the key mathematical structures: Catalan numbers,
moment-cumulant inversion, Wigner matrix eigenvalues, and the
semicircle law convergence.
"""

import math
import random

random.seed(42)


def catalan_number(n: int) -> int:
    return math.comb(2 * n, n) // (n + 1)


def semicircle_density(x: float) -> float:
    if abs(x) > 2:
        return 0.0
    return (1 / (2 * math.pi)) * math.sqrt(4 - x ** 2)


def wigner_matrix(n: int) -> list:
    M = [[0.0] * n for _ in range(n)]
    for i in range(n):
        M[i][i] = random.gauss(0, 1) / math.sqrt(n)
        for j in range(i + 1, n):
            val = random.gauss(0, 1 / math.sqrt(2)) / math.sqrt(n)
            M[i][j] = val
            M[j][i] = val
    return M


def eigenvalues_power_method(M: list, n_iter: int = 200) -> list:
    """Simple eigenvalue estimation via trace moments."""
    n = len(M)
    # Compute Tr(M^k) for k = 0, 2, 4
    traces = []
    # M^0 = I
    traces.append(n)
    # M^2
    tr2 = sum(sum(M[i][k] * M[k][i] for k in range(n)) for i in range(n))
    traces.append(tr2)
    return traces


def free_cumulants_from_moments(moments: list) -> list:
    n = len(moments)
    kappa = []
    if n >= 1:
        k1 = moments[0]
        kappa.append(k1)
    if n >= 2:
        k2 = moments[1] - k1 ** 2
        kappa.append(k2)
    if n >= 3:
        k3 = moments[2] - 3 * k1 * k2 - k1 ** 3
        kappa.append(k3)
    if n >= 4:
        k4 = moments[3] - 4 * k1 * k3 - 2 * k2 ** 2 - 6 * k1 ** 2 * k2 - k1 ** 4
        kappa.append(k4)
    return kappa


def catalan_hankel_det(n: int) -> int:
    """Compute Catalan Hankel determinant via Gaussian elimination."""
    # Build matrix as fractions (using floats for simplicity)
    H = [[float(catalan_number(i + j)) for j in range(n + 1)] for i in range(n + 1)]
    size = n + 1
    det = 1.0
    for col in range(size):
        # Find pivot
        pivot_row = None
        for row in range(col, size):
            if abs(H[row][col]) > 1e-10:
                pivot_row = row
                break
        if pivot_row is None:
            return 0
        if pivot_row != col:
            H[col], H[pivot_row] = H[pivot_row], H[col]
            det *= -1
        det *= H[col][col]
        for row in range(col + 1, size):
            factor = H[row][col] / H[col][col]
            for j in range(col, size):
                H[row][j] -= factor * H[col][j]
    return int(round(det))


def main():
    print("=" * 60)
    print("  RANDOM MATRIX FOUNDATIONS - DEMONSTRATION")
    print("=" * 60)

    # 1. Catalan numbers
    print("\n--- Catalan Numbers ---")
    print("C(n) = C(2n,n)/(n+1)")
    for n in range(11):
        print(f"  C({n:2d}) = {catalan_number(n)}")

    # 2. Catalan recurrence verification
    print("\n--- Catalan Recurrence: (n+2)·C(n+1) = (4n+2)·C(n) ---")
    all_ok = True
    for n in range(15):
        lhs = (n + 2) * catalan_number(n + 1)
        rhs = (4 * n + 2) * catalan_number(n)
        ok = "✓" if lhs == rhs else "✗"
        if lhs != rhs:
            all_ok = False
        print(f"  n={n:2d}: ({n+2})·{catalan_number(n+1):6d} = {lhs:8d} = ({4*n+2})·{catalan_number(n):6d} = {rhs:8d}  {ok}")
    print(f"  All verified: {all_ok}")

    # 3. Hankel determinants
    print("\n--- Catalan Hankel Determinants ---")
    print("Conjecture: det[C(i+j)]_{0≤i,j≤n} = 1 for all n")
    for n in range(8):
        d = catalan_hankel_det(n)
        ok = "✓" if d == 1 else "✗"
        print(f"  n={n}: det = {d}  {ok}")

    # 4. Moment-cumulant inversion
    print("\n--- Free Moment-Cumulant Inversion ---")
    print("Semicircle moments: m = [0, 1, 0, 2]")
    moments = [0.0, 1.0, 0.0, 2.0]
    kappas = free_cumulants_from_moments(moments)
    print(f"Free cumulants: κ = {kappas}")
    print("Expected (semicircle): κ = [0, 1, 0, 0]")

    # 5. Wigner matrix trace moments
    print("\n--- Wigner Matrix Trace Moments ---")
    for n in [50, 100, 200, 500]:
        M = wigner_matrix(n)
        tr2 = sum(sum(M[i][k] * M[k][i] for k in range(n)) for i in range(n))
        normalized_m2 = tr2 / n
        print(f"  n={n:4d}: (1/n)·Tr(M²) = {normalized_m2:.4f}  (expected → C(1) = 1.0)")

    # 6. Stieltjes transform
    print("\n--- Stieltjes Transform Fixed Point ---")
    print("G(z) = (z - √(z²-4))/2 satisfies G² - zG + 1 = 0")
    for z_real in [3.0, 5.0, 10.0]:
        z = complex(z_real, 0.1)
        disc = z ** 2 - 4
        G = (z - disc ** 0.5) / 2
        residual = G ** 2 - z * G + 1
        print(f"  z = {z}: |G²-zG+1| = {abs(residual):.2e}")

    print("\n" + "=" * 60)
    print("  All demonstrations completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Catalan Number Growth and Hankel Determinants

Shows the exponential growth of Catalan numbers with the 4^n bound
and verifies the Hankel determinant conjecture.
"""

import math


def catalan_number(n):
    return math.comb(2 * n, n) // (n + 1)


def catalan_hankel_det(n):
    import numpy as np
    H = np.array([[catalan_number(i + j) for j in range(n + 1)]
                   for i in range(n + 1)], dtype=float)
    return int(round(np.linalg.det(H)))


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, skipping visualization")
        return

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Catalan number growth
    ax = axes[0]
    ns = list(range(16))
    catalans = [catalan_number(n) for n in ns]
    four_pow = [4 ** n for n in ns]
    asymptotic = [4 ** n / (n ** 1.5 * math.sqrt(math.pi)) if n > 0 else 1 for n in ns]

    ax.semilogy(ns, catalans, 'bo-', markersize=6, label='C(n)')
    ax.semilogy(ns, four_pow, 'r--', alpha=0.5, label='4ⁿ')
    ax.semilogy(ns, asymptotic, 'g-.', alpha=0.7, label='4ⁿ/(n^{3/2}√π)')
    ax.set_xlabel('n')
    ax.set_ylabel('C(n)')
    ax.set_title('Catalan Number Growth')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Ratio C(n+1)/C(n) → 4
    ax = axes[1]
    ratios = [catalan_number(n + 1) / catalan_number(n) for n in range(1, 25)]
    ax.plot(range(1, 25), ratios, 'bo-', markersize=5)
    ax.axhline(y=4, color='r', linestyle='--', label='Limit = 4')
    ax.set_xlabel('n')
    ax.set_ylabel('C(n+1)/C(n)')
    ax.set_title('Growth Ratio → 4')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Hankel determinants
    ax = axes[2]
    hankel_ns = list(range(12))
    hankel_dets = [catalan_hankel_det(n) for n in hankel_ns]
    ax.bar(hankel_ns, hankel_dets, color='steelblue', alpha=0.8)
    ax.set_xlabel('n')
    ax.set_ylabel('det H(n)')
    ax.set_title('Catalan Hankel Determinant = 1')
    ax.set_ylim(0, 2)
    ax.grid(True, alpha=0.3, axis='y')

    plt.suptitle('Catalan Numbers: Growth, Ratios, and Hankel Determinants',
                 fontsize=14)
    plt.tight_layout()
    plt.savefig('viz_catalan.png', dpi=150, bbox_inches='tight')
    print("Saved viz_catalan.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Wigner Semicircle Law Convergence

Shows the empirical spectral distribution of Wigner matrices converging
to the semicircle law as matrix dimension increases.
"""

import math
import random
import numpy as np

random.seed(42)
np.random.seed(42)


def semicircle_density(x):
    if abs(x) > 2:
        return 0.0
    return (1 / (2 * math.pi)) * math.sqrt(4 - x ** 2)


def wigner_matrix_numpy(n):
    M = np.random.randn(n, n)
    M = (M + M.T) / 2
    M /= np.sqrt(n)
    return M


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    sizes = [50, 200, 500, 2000]
    x_theory = np.linspace(-2.5, 2.5, 500)
    y_theory = np.array([semicircle_density(x) for x in x_theory])

    for ax, n in zip(axes.flat, sizes):
        M = wigner_matrix_numpy(n)
        eigenvalues = np.linalg.eigvalsh(M)
        ax.hist(eigenvalues, bins=60, density=True, alpha=0.7,
                color='steelblue', edgecolor='white', linewidth=0.5,
                label=f'Empirical (n={n})')
        ax.plot(x_theory, y_theory, 'r-', linewidth=2,
                label='Semicircle law')
        ax.set_xlim(-3, 3)
        ax.set_ylim(0, 0.4)
        ax.set_title(f'Wigner Matrix, n = {n}', fontsize=14)
        ax.legend(fontsize=11)
        ax.set_xlabel('Eigenvalue')
        ax.set_ylabel('Density')

    plt.suptitle('Convergence to the Wigner Semicircle Law', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_semicircle.png', dpi=150, bbox_inches='tight')
    print("Saved viz_semicircle.png")


if __name__ == "__main__":
    main()
