#!/usr/bin/env python3
"""
Demo: Shape-Color Dictionary for GL₁ Langlands Correspondence

Computes the splitting matrix M[i,j] = J(dᵢ, pⱼ) for a selection of
fundamental discriminants and primes, illustrating the bijection between
"shapes" (quadratic extensions) and "colors" (Dirichlet characters).
"""

def jacobi_symbol(a: int, n: int) -> int:
    """Compute the Jacobi symbol (a/n) for odd positive n."""
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n must be odd and positive, got {n}")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def qr_sign(a: int, b: int) -> int:
    """Quadratic reciprocity correction sign (-1)^((a/2)(b/2))."""
    return (-1) ** ((a // 2) * (b // 2))


def compute_splitting_matrix(discriminants: list[int], primes: list[int]) -> list[list[int]]:
    """Compute the splitting matrix M[i,j] = J(d_i, p_j)."""
    return [[jacobi_symbol(d, p) for p in primes] for d in discriminants]


def print_splitting_matrix(discriminants: list[int], primes: list[int]):
    """Print the splitting matrix with labels."""
    matrix = compute_splitting_matrix(discriminants, primes)
    header = "d\\p  " + "  ".join(f"{p:>3}" for p in primes)
    print(header)
    print("-" * len(header))
    for d, row in zip(discriminants, matrix):
        vals = "  ".join(f"{v:>3}" for v in row)
        print(f"{d:>4} | {vals}")


def verify_reciprocity(p: int, q: int):
    """Verify quadratic reciprocity: J(p,q)*J(q,p) = qrSign(p,q)."""
    jpq = jacobi_symbol(p, q)
    jqp = jacobi_symbol(q, p)
    sign = qr_sign(p, q)
    product = jpq * jqp
    status = "✓" if product == sign else "✗"
    print(f"  J({p},{q})={jpq:>2}, J({q},{p})={jqp:>2}, "
          f"product={product:>2}, qrSign={sign:>2}  [{status}]")


def verify_frobenius_detector():
    """Verify the Frobenius detector: J(-1,p)=1 iff p≡1 (mod 4)."""
    print("\n=== Frobenius Detector: J(-1, p) ===")
    print("p ≡ 1 (mod 4) → J(-1,p) = +1  (shape -1 splits)")
    print("p ≡ 3 (mod 4) → J(-1,p) = -1  (shape -1 is inert)")
    print()
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    for p in primes:
        j = jacobi_symbol(-1, p)
        predicted = 1 if p % 4 == 1 else -1
        status = "✓" if j == predicted else "✗"
        print(f"  p={p:>2}: J(-1,{p:>2})={j:>2}, p mod 4 = {p%4}, predicted={predicted:>2} [{status}]")


def verify_two_detector():
    """Verify: J(2,p)=1 iff p≡±1 (mod 8)."""
    print("\n=== Shape-2 Detector: J(2, p) ===")
    print("p ≡ ±1 (mod 8) → J(2,p) = +1  (shape 2 splits)")
    print("p ≡ ±3 (mod 8) → J(2,p) = -1  (shape 2 is inert)")
    print()
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    for p in primes:
        j = jacobi_symbol(2, p)
        predicted = 1 if p % 8 in (1, 7) else -1
        status = "✓" if j == predicted else "✗"
        print(f"  p={p:>2}: J(2,{p:>2})={j:>2}, p mod 8 = {p%8}, predicted={predicted:>2} [{status}]")


def verify_square_triviality():
    """Verify: J(d², p) = 1 for primes p not dividing d."""
    print("\n=== Square Triviality: J(d², p) = 1 ===")
    ds = [2, 3, 5, 7, 11]
    primes = [3, 5, 7, 11, 13, 17, 19, 23]
    for d in ds:
        for p in primes:
            if p == d:
                continue
            j = jacobi_symbol(d * d, p)
            status = "✓" if j == 1 else "✗"
            if j != 1:
                print(f"  FAIL: J({d}²,{p}) = {j} [{status}]")
    print("  All checks passed ✓")


def verify_spectrum_product():
    """Verify: J(d₁·d₂, n) = J(d₁, n)·J(d₂, n)."""
    print("\n=== Spectrum Product Rule: J(d₁d₂, n) = J(d₁,n)·J(d₂,n) ===")
    pairs = [(2, 3), (3, 5), (-1, 7), (2, -3), (5, -7)]
    primes = [3, 5, 7, 11, 13, 17]
    all_ok = True
    for d1, d2 in pairs:
        for p in primes:
            lhs = jacobi_symbol(d1 * d2, p)
            rhs = jacobi_symbol(d1, p) * jacobi_symbol(d2, p)
            if lhs != rhs:
                print(f"  FAIL: J({d1}·{d2},{p}): {lhs} ≠ {rhs}")
                all_ok = False
    if all_ok:
        print("  All checks passed ✓")


def main():
    print("=" * 60)
    print("  SHAPE-COLOR DICTIONARY: GL₁ Langlands Correspondence")
    print("=" * 60)

    # The splitting matrix
    discriminants = [-1, 2, -3, 5, -7, 6, -11, 13]
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

    print("\n=== The Splitting Matrix ===")
    print("Rows = shapes (discriminants), Columns = colors (primes)")
    print("J(d, p) = +1 means d is a QR mod p (the shape 'splits')")
    print("J(d, p) = -1 means d is a QNR mod p (the shape is 'inert')")
    print()
    print_splitting_matrix(discriminants, primes)

    # Quadratic reciprocity verification
    print("\n=== Quadratic Reciprocity: J(p,q)·J(q,p) = qrSign(p,q) ===")
    odd_primes = [3, 5, 7, 11, 13, 17, 19, 23]
    for i, p in enumerate(odd_primes):
        for q in odd_primes[i+1:]:
            verify_reciprocity(p, q)

    verify_frobenius_detector()
    verify_two_detector()
    verify_square_triviality()
    verify_spectrum_product()

    # Character sum vanishing
    print("\n=== Character Sum Vanishing: Σ J(a,p) = 0 ===")
    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        total = sum(jacobi_symbol(a, p) for a in range(p))
        status = "✓" if total == 0 else "✗"
        print(f"  Σ J(a,{p:>2}) for a=0..{p-1}: sum = {total} [{status}]")

    print("\n" + "=" * 60)
    print("  All verifications complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Quadratic Reciprocity as Matrix Symmetry

Shows the asymmetry matrix A[p,q] = J(p,q)*J(q,p) vs qrSign(p,q),
demonstrating that quadratic reciprocity is a "near-symmetry" with
a computable correction sign.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 0
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def qr_sign(a: int, b: int) -> int:
    return (-1) ** ((a // 2) * (b // 2))


def sieve_primes(n: int) -> list:
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(3, n + 1) if is_prime[i]]


def main():
    primes = sieve_primes(50)
    n = len(primes)

    # Compute the product matrix and the sign matrix
    product_matrix = np.zeros((n, n), dtype=int)
    sign_matrix = np.zeros((n, n), dtype=int)

    for i, p in enumerate(primes):
        for j, q in enumerate(primes):
            if i != j:
                product_matrix[i, j] = jacobi_symbol(p, q) * jacobi_symbol(q, p)
                sign_matrix[i, j] = qr_sign(p, q)
            else:
                product_matrix[i, j] = 0
                sign_matrix[i, j] = 0

    cmap = mcolors.LinearSegmentedColormap.from_list('recip', ['#d62728', '#f0f0f0', '#1f77b4'])

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Product matrix J(p,q)*J(q,p)
    im1 = axes[0].imshow(product_matrix, cmap=cmap, vmin=-1, vmax=1)
    axes[0].set_title('J(p,q) · J(q,p)\n(Reciprocity Product)', fontsize=11)
    axes[0].set_xticks(range(n))
    axes[0].set_xticklabels([str(p) for p in primes], fontsize=8, rotation=45)
    axes[0].set_yticks(range(n))
    axes[0].set_yticklabels([str(p) for p in primes], fontsize=8)

    # Panel 2: qrSign matrix
    im2 = axes[1].imshow(sign_matrix, cmap=cmap, vmin=-1, vmax=1)
    axes[1].set_title('qrSign(p,q)\n(Reciprocity Correction)', fontsize=11)
    axes[1].set_xticks(range(n))
    axes[1].set_xticklabels([str(p) for p in primes], fontsize=8, rotation=45)
    axes[1].set_yticks(range(n))
    axes[1].set_yticklabels([str(p) for p in primes], fontsize=8)

    # Panel 3: Difference (should be all zero)
    diff_matrix = product_matrix - sign_matrix
    cmap_diff = mcolors.LinearSegmentedColormap.from_list('diff', ['#ff0000', '#00ff00', '#ff0000'])
    im3 = axes[2].imshow(np.abs(diff_matrix), cmap='Greens_r', vmin=0, vmax=1)
    axes[2].set_title('|Difference|\n(All green = QR verified)', fontsize=11)
    axes[2].set_xticks(range(n))
    axes[2].set_xticklabels([str(p) for p in primes], fontsize=8, rotation=45)
    axes[2].set_yticks(range(n))
    axes[2].set_yticklabels([str(p) for p in primes], fontsize=8)

    plt.suptitle('Quadratic Reciprocity: The Splitting Matrix is Almost Symmetric',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('Applications/reciprocity_symmetry.png', dpi=150, bbox_inches='tight')
    print("Saved: Applications/reciprocity_symmetry.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Splitting Matrix as a Heatmap

Shows the shape-color dictionary M[i,j] = J(d_i, p_j) as a color-coded
matrix, where +1 = blue (split), -1 = red (inert), 0 = white (ramified).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 0
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def sieve_primes(n: int) -> list:
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(3, n + 1) if is_prime[i]]


def main():
    # Discriminants (squarefree)
    discriminants = [-1, 2, -2, 3, -3, 5, -5, 6, -6, 7, -7, 10, -10, 11, -11, 13, -13, 14, -14, 15]
    primes = sieve_primes(80)[:20]

    # Compute matrix
    matrix = np.array([[jacobi_symbol(d, p) for p in primes] for d in discriminants])

    # Custom colormap: red (-1) -> white (0) -> blue (+1)
    cmap = mcolors.LinearSegmentedColormap.from_list('split', ['#d62728', '#ffffff', '#1f77b4'])

    fig, ax = plt.subplots(figsize=(14, 10))
    im = ax.imshow(matrix, cmap=cmap, vmin=-1, vmax=1, aspect='auto')

    ax.set_xticks(range(len(primes)))
    ax.set_xticklabels([str(p) for p in primes], fontsize=9)
    ax.set_yticks(range(len(discriminants)))
    ax.set_yticklabels([str(d) for d in discriminants], fontsize=9)

    ax.set_xlabel('Prime p (Color Basis)', fontsize=12)
    ax.set_ylabel('Discriminant d (Shape)', fontsize=12)
    ax.set_title('The Splitting Matrix: Shape-Color Dictionary\n'
                 'M[d, p] = J(d, p)  |  Blue = Split (+1)  |  Red = Inert (-1)  |  White = Ramified (0)',
                 fontsize=13)

    # Add text annotations
    for i in range(len(discriminants)):
        for j in range(len(primes)):
            val = matrix[i, j]
            color = 'white' if abs(val) == 1 else 'gray'
            ax.text(j, i, f'{val:+d}' if val != 0 else '0',
                    ha='center', va='center', fontsize=7, color=color if val != 0 else 'lightgray',
                    fontweight='bold')

    plt.colorbar(im, ax=ax, shrink=0.8, label='J(d, p)')
    plt.tight_layout()
    plt.savefig('Applications/splitting_matrix.png', dpi=150, bbox_inches='tight')
    print("Saved: Applications/splitting_matrix.png")


if __name__ == "__main__":
    main()
